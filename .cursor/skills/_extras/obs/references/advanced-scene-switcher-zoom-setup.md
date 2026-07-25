# Click-triggered zoom via Advanced Scene Switcher

Stock OBS has no "zoom in where the user clicked" feature. The plugin
`WarmUpTill/SceneSwitcher` ("Advanced Scene Switcher", ASS) does — verified
directly from its source (not guessed): `plugins/base/macro-condition-cursor.cpp`
defines a `Cursor` macro condition with three modes:

- `REGION` — true while the cursor is inside a min/max X/Y box
- `MOVING` — true while the cursor is in motion
- `CLICK` — true on a mouse button click (left/middle/right)

ASS also registers itself as an obs-websocket vendor (`AdvancedSceneSwitcher`),
but today that only exposes Start/Stop/IsRunning for the whole macro engine —
not per-macro remote triggering or remote macro authoring. That means: **the
macro itself (condition + action pairing) has to be built once in ASS's own
GUI** — this skill can install the plugin and walk the user through that
one-time setup, but can't fully script it end-to-end via websocket yet.

## 1. Install (macOS)

```bash
curl -L -o /tmp/ass.pkg \
  "$(curl -s https://api.github.com/repos/WarmUpTill/SceneSwitcher/releases/latest \
     | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next(a["browser_download_url"] for a in d["assets"] if a["name"].endswith("macos-universal.pkg")))')"
open /tmp/ass.pkg
```

This opens the standard macOS installer GUI — the user has to click through
it (installer packages can't be silently run without their confirmation).
It installs as an OBS plugin; **fully quit and relaunch OBS** afterward so
it loads. Verify it loaded: OBS menu bar → **Tools** should now show
**"Advanced Scene Switcher"**.

## 2. One-time macro setup (user does this in ASS's GUI)

Tell the user to open **Tools → Advanced Scene Switcher → Macros** and
create one macro:

1. **New macro**, name it e.g. `Click Zoom`.
2. **Condition**: add a `Cursor` condition, mode `CLICK`, button `Left`.
   Optionally add a second condition (AND) using mode `REGION` set to the
   window-capture source's on-canvas bounding box, so clicks outside the
   demo window don't trigger a zoom.
3. **Action**: add a `Source filter settings` (or the availble "Scene item
   transform" action, depending on ASS version) action targeting the
   window-capture source's crop filter — set new crop values that frame a
   region around the current cursor position. ASS exposes the cursor's live
   X/Y as macro temp variables (see the `Cursor` condition's variable
   picker in its edit UI) — use those to compute the crop offset instead of
   a fixed region, so it actually follows the click.
4. Add a **second macro** (`Click Zoom Reset`) with a condition like "no
   click for N seconds" or a second hotkey/click to restore the original
   (non-zoomed) crop values, so the view doesn't stay zoomed in forever.

Exact field names shift slightly between ASS versions — if the user's
installed version's UI doesn't match a label above, have them hover the
`(?)` tooltips in that dialog, or check the "Macros" section of the ASS
GitHub wiki for their installed version.

## 3. What this skill automates vs. doesn't

| Step | Automated by this skill? |
|---|---|
| Installing ASS | Yes (downloads + opens the installer; user clicks through) |
| Verifying it's loaded | Yes (`Tools` menu check) |
| Building the zoom macro | **No** — one-time manual setup in ASS's GUI, per above |
| Everything else in this skill (scenes, window capture, round camera, ring, recording) | Yes, via `scripts/obs_control.py` |

If the user wants full remote scriptability of the zoom macro itself later,
the fallback (unimplemented, would need scoping as its own project) is a
custom Python global-mouse-click listener that computes crop values and
pushes them via `obs_control.py`'s `SetSourceFilterSettings`-equivalent
directly — this was the alternative the user didn't pick when this skill was
drafted (they chose ASS over a homemade listener for stability).
