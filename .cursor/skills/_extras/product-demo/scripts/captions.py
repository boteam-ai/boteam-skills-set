#!/usr/bin/env python3
"""Live OBS caption/text-source control for the /product-demo skill.

Depends on ../../obs/scripts/obs_control.py (the /obs skill) for
connect()/scene/positioning primitives -- this file only adds the text
source, which /obs doesn't need for its own scope.

Settings fields confirmed against the OBS Studio source (macOS build):
  plugins/text-freetype2/text-freetype2.c -- settings: text (str), from_file
  (bool, default False), font (obj: face/size/flags/style), color1 (int,
  0xAABBGGRR-packed, default 0xFFFFFFFF = opaque white), word_wrap (bool),
  outline (bool), drop_shadow (bool)

The *kind id* is NOT taken from that source file, though -- the cloned
source tree registers plain "text_ft2_source", but this machine's actually
installed OBS (32.1.2, via Homebrew cask) reports "text_ft2_source_v2" when
queried live via GetInputKindList. The source tree and a given shipped
binary can be different points in OBS's history; a kind id read from source
is a hypothesis, not a fact, until confirmed against the live instance you're
actually driving. Before assuming any kind id below (or any new one you add)
still matches, run:

    python3 -c "import obs_control as oc
    with oc.connect() as c: print(c.get_input_kind_list(False).input_kinds)"

and grep for the source type you expect ("text", "capture", etc). This bit
us once already while building this skill -- don't skip it. (For
reference: this is definitely not "text_gdiplus_v2" either, which is a
Windows-only kind and can't exist on macOS at all -- GDI+ is a Windows API.)
"""

import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent / "obs" / "scripts"))
import obs_control as oc  # noqa: E402

TEXT_KIND = "text_ft2_source_v2"


def _wait_for_rendered_size(
    client, scene_name: str, item_id: int, baseline: tuple[float, float] = (0, 0), timeout: float = 1.5
) -> tuple[float, float]:
    """Polls until the source's bounding box differs from `baseline` and is
    nonzero, or returns the last-seen value on timeout.

    A text source's bounding box takes one render tick (~0.2s observed) to
    reflect a text change. On first creation the box starts at 0x0, so
    baseline=(0,0) (the default) correctly waits for "any real size". But on
    a later text *update*, the box already holds the *previous* text's
    nonzero size right up until the new render lands -- a plain "is it
    nonzero" check would immediately (and wrongly) accept that stale value.
    Pass the pre-update size as `baseline` so this waits for it to actually
    change instead.
    """
    deadline = time.monotonic() + timeout
    last = baseline
    while time.monotonic() < deadline:
        t = client.get_scene_item_transform(scene_name, item_id).scene_item_transform
        current = (t["sourceWidth"], t["sourceHeight"])
        if current != baseline and current[0] and current[1]:
            return current
        last = current
        time.sleep(0.1)
    return last


def add_caption(
    client,
    scene_name: str,
    source_name: str,
    initial_text: str = "",
    font_face: str = "Helvetica Neue",
    font_size: int = 48,
    color_argb: int = 0xFFFFFFFF,
) -> None:
    """Creates (or reuses) a live-updatable text source for step captions."""
    oc.create_scene(client, scene_name)
    settings = {
        "text": initial_text,
        "from_file": False,
        "font": {"face": font_face, "size": font_size, "flags": 0, "style": ""},
        "color1": color_argb,
        "word_wrap": True,
        "outline": True,
    }
    oc._ensure_input_in_scene(client, scene_name, source_name, TEXT_KIND, settings)
    # _ensure_input_in_scene only applies `settings` on first creation; if the
    # source already existed (e.g. re-running this skill), push them explicitly.
    client.set_input_settings(source_name, settings, True)
    update_caption(client, scene_name, source_name, initial_text)


def update_caption(client, scene_name: str, source_name: str, text: str, margin_px: int = 60) -> None:
    """Sets the caption text for the current step and re-centers it at the
    bottom of the canvas. Call this once per demo step, right before that
    step plays out -- re-centering matters every time because each step's
    caption is a different length.
    """
    item_id = client.get_scene_item_id(scene_name, source_name).scene_item_id
    before = client.get_scene_item_transform(scene_name, item_id).scene_item_transform
    baseline = (before["sourceWidth"], before["sourceHeight"])

    client.set_input_settings(source_name, {"text": text}, True)
    text_w, text_h = _wait_for_rendered_size(client, scene_name, item_id, baseline=baseline)
    if not text_w or not text_h:
        return  # render didn't settle in time; leave position as-is rather than guess

    video = client.get_video_settings()
    canvas_w, canvas_h = video.base_width, video.base_height
    client.set_scene_item_transform(
        scene_name,
        item_id,
        {
            "positionX": (canvas_w - text_w) / 2,
            "positionY": canvas_h - margin_px - text_h,
            "alignment": oc.ALIGN_TOP_LEFT,
        },
    )
