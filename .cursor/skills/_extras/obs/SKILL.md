---
name: obs
description: Configures OBS Studio for a product demo / screen recording from a plain-language description of the desired layout -- captures a local app window (e.g. localhost:8000), adds a round camera bubble with a colored accent ring, sets canvas aspect ratio, and optionally wires up click-triggered zoom via the Advanced Scene Switcher plugin. Controls OBS through its WebSocket API (obs-websocket, OBS 28+), not by clicking through the GUI. Use whenever the user invokes "/obs" or asks to set up/configure OBS for a demo video, product walkthrough recording, or livestream layout -- e.g. "record my product at localhost:3000 with my camera in the corner", "set up OBS for a demo", "add a round webcam overlay", "make my camera a circle", "zoom in when I click".
disable-model-invocation: true
---

# OBS Demo Recording Setup

Turns a request like:

> "我准备针对我的产品本地开发 localhost:8000 进行展示，需要设置合适比例的产品界面，在我点击时候适当 zoom in 我点击的局部，同时也有显示我的 camera 我的讲解，圆形的头像，同时背景用蓝色，避免看到我后面的背景"

into an actual configured OBS scene, by driving OBS's WebSocket API (not
GUI automation) via `scripts/obs_control.py`. That script is the source of
truth for every OBS-specific detail (kind IDs, filter settings fields) --
they were read out of the OBS Studio source itself, not guessed. Read it
before writing any one-off OBS calls; don't reinvent what's already there.

## Why WebSocket, not clicking the GUI

OBS is a native macOS app with no reliable accessibility-automation surface
available in this environment. `obs-websocket` (built into OBS 28+) is the
real, supported way to configure it programmatically. This means: OBS must
be running, and its WebSocket server must be enabled once (Tools ->
WebSocket Server Settings -> Enable WebSocket server -- this specific
checkbox can't be toggled remotely; it's a one-time manual step the user
does, same as granting camera/screen-recording permissions).

## Step 1 -- Parse the request, confirm what's ambiguous

Extract these fields from the user's description. Reply in whatever
language they used (Chinese in the example above) when asking for
clarification -- don't silently guess on anything in the "must confirm"
column, since a wrong guess here means redoing the whole scene.

| Field | Default if unstated | Must confirm instead of defaulting when... |
|---|---|---|
| Target window/app/URL | -- (required) | more than one open window plausibly matches the description (run `list-windows` first, fuzzy-match, and if 2+ results share the query term, list them and ask which one) |
| Canvas resolution/aspect | 1920x1080 (16:9) | user mentions a specific product UI aspect ratio, portrait/vertical, or an unusual canvas size |
| Camera device | auto-pick if `list-cameras` returns exactly one real camera | 2+ cameras available (this machine has had MacBook Pro Camera + iPhone Continuity Camera + Desk View variants show up in `list-cameras` -- don't assume which one) |
| Round camera + ring color | -- | always confirm the actual hex color, even if they name a color in words ("blue" could be many hexes) -- propose one (e.g. `#2D6CDF` for "blue") and get a yes/no rather than silently picking |
| Corner position / size | bottom-right, 300px diameter, 40px margin | user describes a different placement |
| "蓝色背景，挡住我身后真实背景" / real background replacement | -- | **always** surface this: stock OBS has no AI background segmentation plugin bundled, so true background replacement isn't achievable without either a physical color backdrop (real chroma key) or a separate, unverified third-party plugin. What this skill actually ships for "blue background" is a colored ring frame around the round camera bubble -- confirm that's an acceptable interpretation before proceeding, don't silently substitute it without saying so. |
| Click-triggered zoom | off (don't build it unless asked) | if requested, this needs the Advanced Scene Switcher plugin (see references/advanced-scene-switcher-zoom-setup.md) -- tell the user up front that its zoom macro is a one-time manual setup in that plugin's own GUI, not something this skill can fully configure remotely today |

## Step 2 -- Make sure OBS + WebSocket are reachable

```bash
pgrep -fl OBS || open -a OBS   # launch if not running; wait ~3-4s after launch
cd <a working dir with a .env holding OBS_WS_HOST/PORT/PASSWORD>
python3 scripts/obs_control.py status
```

If this fails with a connection error, the WebSocket server toggle is off
-- tell the user: **OBS menu bar -> Tools -> WebSocket Server Settings ->
check "Enable WebSocket server"**, then retry. Password/port live in OBS's
own `~/Library/Application Support/obs-studio/plugin_config/obs-websocket/config.json`
(`server_password`, `server_port`) -- read them from there instead of
asking the user, they won't know it offhand.

Requires `obsws-python` (protocol v5 -- OBS 28+'s WebSocket server). **Not**
`obs-websocket-py`, which only speaks the old v4 protocol and silently
won't connect to modern OBS. Also requires `Pillow` for overlay generation.
Install with whatever this project already uses (`uv add obsws-python
pillow` if it's a uv project, else `pip install obsws-python pillow`).

## Step 3 -- Generate the camera overlay assets (if a round camera was requested)

```bash
python3 scripts/make_overlay_assets.py --color "#2D6CDF" --out-dir <workdir> \
  --camera-px 300 --ring-thickness 14
```

Produces `circle-mask.png` (luma mask, color-independent -- the bundled
`assets/circle-mask.png` is already this, regenerating is only needed if
you change `--camera-px`) and `ring-backer.png` (a filled circle in the
chosen accent color, sized `camera-px + 2*ring-thickness`).

## Step 4 -- Apply the configuration

Import `scripts/obs_control.py` as a library and write a short script for
*this specific request* -- don't shell out per field, compose the calls:

```python
import sys
sys.path.insert(0, "<skill-path>/scripts")
import obs_control as oc

with oc.connect() as client:
    win = oc.add_window_capture(client, "Product Demo", "App Window", window_query="localhost:8000")
    if not win["matched"]:
        # surface win["options"] to the user and ask which window, then:
        # oc.select_window(client, "App Window", chosen_item_value)
        ...

    cam = oc.add_round_camera(client, "Product Demo", "Camera", device_query="MacBook Pro Camera")

    oc._ensure_input_in_scene(client, "Product Demo", "Camera Ring", "image_source",
                               {"file": "<workdir>/ring-backer.png"})
    oc.set_camera_with_ring(
        client, "Product Demo",
        camera_source="Camera", camera_cropped_size=cam["cropped_size"],
        ring_source="Camera Ring", ring_backer_size=300 + 2 * 14,
        corner="bottom-right", camera_px=300, ring_thickness=14,
    )

    oc.switch_scene(client, "Product Demo")
```

Then tell the user to check the OBS preview pane before recording -- this
skill can't see the rendered frame itself, so a final human visual check is
the only real verification step.

## Step 5 (optional) -- Click-triggered zoom

Only if the user asked for it. Read
`references/advanced-scene-switcher-zoom-setup.md` in full before doing
anything here -- it has the verified install command and the one-time
macro-building recipe, plus an honest table of what this skill can and
can't automate for that specific feature.

## Step 6 -- Recording

```python
oc.start_recording(client)   # ... later:
path = oc.stop_recording(client)
```

## Known gotchas (read before debugging something that looks like a bug)

- **A kind id read from the OBS source tree is a hypothesis, not a fact --
  confirm it against the live instance.** The source and a given shipped
  binary can be different points in OBS's history. This bit the companion
  `/product-demo` skill: the cloned source registers the text source as
  `text_ft2_source`, but this machine's actual installed OBS (32.1.2, via
  Homebrew cask) reports `text_ft2_source_v2` via `GetInputKindList`. Before
  wiring up any new source kind, run
  `client.get_input_kind_list(False).input_kinds` and confirm it's actually
  there under the name you expect.
- **Source/input names are global in OBS, not per-scene.** Reusing a name
  across scenes links the *same* source object, it doesn't create a fresh
  copy. `obs_control.py`'s `_ensure_input_in_scene()` handles this
  correctly (create if the name is unused anywhere, else link the existing
  source into the current scene) -- always go through it or
  `add_window_capture`/`add_round_camera` rather than calling
  `create_input` directly, or you'll silently end up with an "empty" new
  scene that's actually referencing sources set up for a different one.
- **Never assume camera resolution.** `add_round_camera` auto-detects the
  real capture resolution by polling `sourceWidth`/`sourceHeight` (with
  debouncing -- AVFoundation reports transient garbage sizes like `1x1`
  while a capture session is still negotiating). A hardcoded resolution
  guess will silently turn the "round" camera into an oval whenever the
  actual hardware differs -- this was caught and fixed during drafting
  using a real MacBook Pro Camera, which reports 1920x1080, not the more
  common webcam default of 1280x720.
- **If camera detection times out / the camera renders as a sliver or
  dot**, the physical camera's AVFoundation session is probably wedged
  (this reliably happens after many rapid open/close cycles against the
  same device, e.g. during iteration/testing). Fully quit OBS (Cmd+Q,
  confirm any dialog) and relaunch; if that doesn't clear it, have the user
  physically reconnect the camera or restart the Mac.
- **"Blue background" is a ring, not real background replacement** --
  see the Step 1 table. Don't let a request for "隐藏我身后的背景" turn into
  silently building something that only frames the camera; say what's
  actually being built.

## Bundled resources

- `scripts/obs_control.py` -- all OBS WebSocket control logic (scenes,
  window capture, round camera + ring positioning, recording, status) plus
  a small CLI (`status`, `list-windows`, `list-cameras`, `record start|stop`)
  for quick checks. Read this file's module docstring for the verified
  kind IDs before adding any new source type.
- `scripts/make_overlay_assets.py` -- generates the circle mask + colored
  ring backer PNGs for a given accent color and size.
- `assets/circle-mask.png` -- pre-generated default luma mask (1000x1000,
  color-independent).
- `references/advanced-scene-switcher-zoom-setup.md` -- click-to-zoom
  plugin install + one-time macro setup, read only if that feature was
  requested.
