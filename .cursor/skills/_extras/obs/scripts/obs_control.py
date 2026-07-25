#!/usr/bin/env python3
"""Self-contained OBS WebSocket control for the /obs skill's demo-recording layout.

Requires `obsws-python` (protocol v5 — OBS 28+'s built-in WebSocket server;
NOT the old `obs-websocket-py`, which only speaks v4 and won't connect).

Kind IDs and settings-field names below are not guessed -- they were read
directly out of the OBS Studio source (macOS build):
  plugins/mac-capture/mac-window-capture.m -> kind "window_capture", prop "window" (int)
  plugins/mac-avcapture/plugin-main.m      -> kind "macos-avcapture", prop "device" (str UUID)
  plugins/obs-filters/crop-filter.c        -> kind "crop_filter", fields relative/left/right/top/bottom
  plugins/obs-filters/mask-filter.c        -> kind "mask_filter", fields type/image_path

Camera capture resolution is auto-detected at runtime by polling the scene
item's sourceWidth/sourceHeight (AVFoundation activates the capture session
asynchronously, ~0.5-1s delay) rather than assumed -- webcams vary, and a
wrong guess silently turns the "round" camera into an ellipse.
"""

import argparse
import json
import os
import sys
import time
from contextlib import contextmanager
from pathlib import Path

import obsws_python as obs

WINDOW_CAPTURE_KIND = "window_capture"
CAMERA_KIND = "macos-avcapture"
CROP_FILTER_KIND = "crop_filter"
MASK_FILTER_KIND = "mask_filter"
ALIGN_TOP_LEFT = 5  # OBS alignment bitmask: LEFT(1) | TOP(4)

ASSETS_DIR = Path(__file__).resolve().parent.parent / "assets"


# --------------------------------------------------------------------------
# Connection
# --------------------------------------------------------------------------


def _load_dotenv(env_path: Path):
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        os.environ.setdefault(key.strip(), value.strip())


@contextmanager
def connect(host=None, port=None, password=None):
    _load_dotenv(Path.cwd() / ".env")
    host = host or os.environ.get("OBS_WS_HOST", "localhost")
    port = int(port or os.environ.get("OBS_WS_PORT", 4455))
    password = password if password is not None else os.environ.get("OBS_WS_PASSWORD", "")
    client = obs.ReqClient(host=host, port=port, password=password, timeout=5)
    try:
        yield client
    finally:
        client.disconnect()


# --------------------------------------------------------------------------
# Scenes
# --------------------------------------------------------------------------


def list_scenes(client) -> list[str]:
    return [s["sceneName"] for s in client.get_scene_list().scenes]


def create_scene(client, name: str) -> None:
    if name not in list_scenes(client):
        client.create_scene(name)


def switch_scene(client, name: str) -> None:
    client.set_current_program_scene(name)


# --------------------------------------------------------------------------
# Discovery + sources
# --------------------------------------------------------------------------


def _input_exists(client, input_name: str) -> bool:
    return input_name in [i["inputName"] for i in client.get_input_list().inputs]


def _scene_item_names(client, scene_name: str) -> list[str]:
    return [i["sourceName"] for i in client.get_scene_item_list(scene_name).scene_items]


def _ensure_input_in_scene(client, scene_name: str, source_name: str, kind: str, settings: dict, enabled=True):
    """Creates source_name if it doesn't exist anywhere, and makes sure it's
    linked as a scene item in scene_name.

    Input/source names are global in OBS -- a source created in one scene is
    reusable in others. If we only check "does this name exist anywhere"
    before deciding whether to create it, we can find a same-named source
    from a *different* scene and wrongly assume it's already set up here,
    leaving this scene without that item. So: create only if the name is
    unused anywhere; otherwise explicitly link the existing source into this
    scene if it isn't already a member.
    """
    if not _input_exists(client, source_name):
        client.create_input(scene_name, source_name, kind, settings, enabled)
    elif source_name not in _scene_item_names(client, scene_name):
        client.create_scene_item(scene_name, source_name, enabled)


def list_property_options(client, input_name: str, prop_name: str) -> list[dict]:
    return client.get_input_properties_list_property_items(input_name, prop_name).property_items


def _best_match(options: list[dict], query: str) -> dict | None:
    query = query.lower()
    for opt in options:
        if query in str(opt["itemName"]).lower():
            return opt
    return None


def add_window_capture(client, scene_name: str, source_name: str, window_query: str | None = None) -> dict:
    """Create a Window Capture source; fuzzy-match window_query against live window titles.

    Returns {"matched": <title or None>, "options": [...]} -- when nothing
    matches (or window_query is None), inspect "options" and call
    select_window() explicitly rather than guessing.
    """
    create_scene(client, scene_name)
    _ensure_input_in_scene(client, scene_name, source_name, WINDOW_CAPTURE_KIND, {})

    options = list_property_options(client, source_name, "window")
    matched = _best_match(options, window_query) if window_query else None
    if matched:
        client.set_input_settings(source_name, {"window": matched["itemValue"]}, True)
    return {"matched": matched["itemName"] if matched else None, "options": options}


def select_window(client, source_name: str, window_item_value: int) -> None:
    client.set_input_settings(source_name, {"window": window_item_value}, True)


def _detect_source_size(client, scene_name: str, source_name: str, timeout: float = 5.0) -> tuple[int, int]:
    """Poll sourceWidth/sourceHeight until they settle on a stable, plausible value.

    AVFoundation reports garbage intermediate sizes (observed: literal 1x1)
    while a capture session is still negotiating its real resolution, on top
    of the ~0.5-1s startup delay before it reports anything at all. A single
    nonzero reading isn't trustworthy -- require the same value on two
    consecutive polls, and reject anything smaller than a real camera frame
    (<16px either dimension) as still-negotiating noise.
    """
    item_id = client.get_scene_item_id(scene_name, source_name).scene_item_id
    deadline = time.monotonic() + timeout
    last = (0, 0)
    while time.monotonic() < deadline:
        t = client.get_scene_item_transform(scene_name, item_id).scene_item_transform
        current = (int(t["sourceWidth"]), int(t["sourceHeight"]))
        if current[0] >= 16 and current[1] >= 16 and current == last:
            return current
        last = current
        time.sleep(0.2)
    return 0, 0


def add_round_camera(
    client,
    scene_name: str,
    source_name: str,
    device_query: str | None = None,
    mask_path: str | None = None,
    fallback_size: tuple[int, int] = (1280, 720),
) -> dict:
    """Create a camera source, cropped + luma-masked to a circle.

    Positioning is handled separately by set_camera_with_ring() so the ring
    backer and the camera line up on the same center point.
    """
    mask_path = mask_path or str(ASSETS_DIR / "circle-mask.png")
    create_scene(client, scene_name)
    _ensure_input_in_scene(client, scene_name, source_name, CAMERA_KIND, {})

    options = list_property_options(client, source_name, "device")
    matched = _best_match(options, device_query) if device_query else None
    if matched:
        client.set_input_settings(source_name, {"device": matched["itemValue"]}, True)

    # If this source was reused from a previous run, drop its old crop/mask
    # filters *before* measuring size. A crop filter shrinks the effective
    # sourceWidth/sourceHeight OBS reports -- measuring without removing it
    # first would crop an already-cropped image on every re-run, compounding
    # down towards nothing.
    existing_filters = [f["filterName"] for f in client.get_source_filter_list(source_name).filters]
    for stale in ("Square Crop", "Round Mask"):
        if stale in existing_filters:
            client.remove_source_filter(source_name, stale)

    native_w, native_h = _detect_source_size(client, scene_name, source_name)
    if not native_w or not native_h:
        native_w, native_h = fallback_size

    side = min(native_w, native_h)
    pad_lr = (native_w - side) // 2
    pad_tb = (native_h - side) // 2

    client.create_source_filter(
        source_name,
        "Square Crop",
        CROP_FILTER_KIND,
        {"relative": True, "left": pad_lr, "right": pad_lr, "top": pad_tb, "bottom": pad_tb},
    )
    client.create_source_filter(
        source_name,
        "Round Mask",
        MASK_FILTER_KIND,
        {"type": "mask_alpha_filter.effect", "image_path": mask_path},
    )

    return {
        "matched": matched["itemName"] if matched else None,
        "options": options,
        "cropped_size": side,
    }


# --------------------------------------------------------------------------
# Positioning
# --------------------------------------------------------------------------


def _corner_position(canvas_w, canvas_h, item_w, item_h, corner, margin_px):
    positions = {
        "top-left": (margin_px, margin_px),
        "top-right": (canvas_w - item_w - margin_px, margin_px),
        "bottom-left": (margin_px, canvas_h - item_h - margin_px),
        "bottom-right": (canvas_w - item_w - margin_px, canvas_h - item_h - margin_px),
    }
    if corner not in positions:
        raise ValueError(f"corner must be one of {list(positions)}")
    return positions[corner]


def _set_item_transform(client, scene_name, source_name, pos_x, pos_y, scale_x, scale_y):
    item_id = client.get_scene_item_id(scene_name, source_name).scene_item_id
    client.set_scene_item_transform(
        scene_name,
        item_id,
        {
            "positionX": pos_x,
            "positionY": pos_y,
            "scaleX": scale_x,
            "scaleY": scale_y,
            "alignment": ALIGN_TOP_LEFT,
        },
    )


def set_camera_with_ring(
    client,
    scene_name: str,
    camera_source: str,
    camera_cropped_size: int,
    ring_source: str | None,
    ring_backer_size: int | None,
    corner: str = "bottom-right",
    camera_px: int = 300,
    ring_thickness: int = 14,
    margin_px: int = 40,
) -> None:
    """Positions the camera bubble and its ring backer so they share a center.

    The ring backer is a plain filled-circle image source (see
    make_overlay_assets.py) sized camera_px + 2*ring_thickness; because it
    sits directly behind the (smaller, fully-opaque) round camera, only its
    border shows -- that's the "ring" effect. If ring_source is None, only
    the camera is positioned (no ring).
    """
    video = client.get_video_settings()
    canvas_w, canvas_h = video.base_width, video.base_height

    ring_px = ring_backer_size or (camera_px + 2 * ring_thickness)
    ring_x, ring_y = _corner_position(canvas_w, canvas_h, ring_px, ring_px, corner, margin_px)
    cam_x, cam_y = ring_x + ring_thickness, ring_y + ring_thickness

    if ring_source:
        _set_item_transform(client, scene_name, ring_source, ring_x, ring_y, 1.0, 1.0)

    scale = camera_px / camera_cropped_size
    _set_item_transform(client, scene_name, camera_source, cam_x, cam_y, scale, scale)


# --------------------------------------------------------------------------
# Recording / status
# --------------------------------------------------------------------------


def start_recording(client) -> None:
    client.start_record()


def stop_recording(client) -> str:
    return client.stop_record().output_path


def get_status(client) -> dict:
    record = client.get_record_status()
    return {
        "current_scene": client.get_current_program_scene().current_program_scene_name,
        "scenes": list_scenes(client),
        "inputs": [i["inputName"] for i in client.get_input_list().inputs],
        "recording": record.output_active,
        "recording_timecode": record.output_timecode,
    }


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------


def cmd_status(client, _args):
    print(json.dumps(get_status(client), indent=2, ensure_ascii=False))


def cmd_list_windows(client, _args):
    create_scene(client, "_scratch")
    result = add_window_capture(client, "_scratch", "_probe_window")
    for opt in result["options"]:
        print(f"{opt['itemValue']}\t{opt['itemName']}")
    client.remove_scene("_scratch")


def cmd_list_cameras(client, _args):
    create_scene(client, "_scratch")
    result = add_round_camera(client, "_scratch", "_probe_camera")
    for opt in result["options"]:
        print(f"{opt['itemValue']}\t{opt['itemName']}")
    client.remove_scene("_scratch")


def cmd_record(client, args):
    if args.action == "start":
        start_recording(client)
        print("recording started")
    else:
        print(f"recording stopped -> {stop_recording(client)}")


def main():
    parser = argparse.ArgumentParser(description="OBS WebSocket control for the /obs skill")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status").set_defaults(func=cmd_status)
    sub.add_parser("list-windows").set_defaults(func=cmd_list_windows)
    sub.add_parser("list-cameras").set_defaults(func=cmd_list_cameras)
    p_record = sub.add_parser("record")
    p_record.add_argument("action", choices=["start", "stop"])
    p_record.set_defaults(func=cmd_record)

    args = parser.parse_args()
    try:
        with connect() as client:
            args.func(client, args)
    except (ConnectionRefusedError, TimeoutError) as e:
        print(
            f"Could not connect to OBS's WebSocket server ({e}).\n"
            "In OBS: Tools -> WebSocket Server Settings -> check 'Enable WebSocket server'.",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
