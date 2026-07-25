---
name: product-demo
description: Plans and produces a fully automated product demo recording -- Claude Code explores a local project (reads the code, browses the running app) to understand its features, drafts a scene-by-scene demo plan with per-step captions, gets the user's sign-off on that plan, then drives a visible browser and OBS Studio (via the /obs skill's WebSocket control) to record the walkthrough with live burned-in captions. Use whenever the user gives a project path and asks for an automated/hands-off demo video, product walkthrough recording, or says something like "give Claude Code my project and have it make the demo", "auto-generate a product demo video", or "/product-demo". Does not add voiceover/audio narration -- captions only. For manually describing a one-off OBS layout instead of a full automated recording, use /obs directly.
disable-model-invocation: true
---

# Automated Product Demo Video

Two hard phases, in order. **Never skip the confirmation gate between
them** -- the whole point of planning first is that fixing a bad plan is a
few edits to a text list; fixing a bad *recording* means doing the recording
over.

```
PLAN  (explore -> draft plan+captions -> user confirms)
  |
  v  (only after explicit user sign-off)
EXECUTE  (drive visible browser -> drive OBS with live captions -> record)
```

## Scope

- No voiceover/audio narration. Captions only (this was an explicit scope
  cut -- if the user asks for narration later, that's a separate feature,
  don't quietly try to bolt on TTS here).
- No click-triggered zoom via mouse tracking / Advanced Scene Switcher.
  Since Claude Code itself drives every click here (not a live human), it
  already knows the exact next click target and can zoom to it directly via
  `obs_control.py`'s scene-item transform calls -- no need for the
  human-input-tracking plugin `/obs` uses for *live, human-driven*
  recording. Don't install or reference Advanced Scene Switcher for this
  skill's own flow.
- Depends on the `/obs` skill (`../obs/scripts/obs_control.py`) for all
  OBS-specific control, and adds only what /obs doesn't need: caption text
  sources (`scripts/captions.py`) and this two-phase planning workflow. If
  `/obs` hasn't been shipped yet on this machine, it still works read
  directly from its team path -- but flag to the user that they may want to
  `/ship-skill obs` too so it's globally available.

## Why a visible browser, not `/browse`

This project's CLAUDE.md says to use `/browse` (gstack) for web browsing --
but `/browse` is a **headless** browser (no on-screen window), and OBS's
Window Capture can only capture a window that actually renders on screen.
Use gstack's **`connect-chrome`** skill instead for the Execute phase: it
launches a real, visible, AI-controlled Chrome window -- still within the
gstack family the CLAUDE.md requires, just the variant built for this
capture-a-visible-window use case rather than headless QA. Keep using
`/browse` for anything read-only/exploratory that doesn't need to be
recorded (e.g. quickly checking a page exists before planning around it).

## Phase 1 -- Plan

### 1a. Understand the product

- Read the project at the given path: routes/pages, main components,
  README, any existing docs describing features. Use this to draft a
  *candidate* feature list -- don't treat it as final, code structure
  often doesn't match what's actually visually interesting to demo.
- Start the project's dev server if it isn't already running (check its
  package.json / README for the actual command -- don't assume `npm run
  dev`).
- Open it with `connect-chrome` and actually click through the candidate
  features. This step exists specifically to catch drift between "what the
  code suggests exists" and "what's actually reachable and demo-able right
  now" (broken pages, features behind auth/flags, empty states). Note real
  selectors/URLs/element descriptions as you go -- Phase 2 needs concrete
  targets, not vague feature names.

### 1b. Draft the demo plan

Structure it as an ordered list of scenes, each scene being one
page/feature. For each scene, list ordered steps; each step is one
{action, target, caption}:

```
Scene 1: Dashboard overview
  URL: localhost:8000/dashboard
  Step 1: {action: "load page", target: null,
           caption: "Your dashboard gives you a live view of..."}
  Step 2: {action: "click", target: "the 'Filters' button top-right",
           caption: "Click Filters to narrow down by date range"}
  Step 3: {action: "click", target: "'Last 7 days' option",
           caption: "..."}

Scene 2: Creating a report
  URL: localhost:8000/reports/new
  ...
```

Keep captions short (one line, ~8-12 words) -- they're burned into the
video permanently, a viewer needs to read them in the time that step is on
screen, not pause the video.

### 1c. Confirm with the user

Present the full plan (scenes, steps, captions -- the actual caption text,
not placeholders) and ask explicitly: does this cover the right features,
in the right order, and do the captions read well? Get real sign-off
before touching OBS. Expect edits -- caption wording especially benefits
from a human pass, since Claude doesn't know the product's voice as well as
its owner does.

## Phase 2 -- Execute

Only after Phase 1 is confirmed.

1. Ensure OBS is running and its WebSocket server is reachable (see the
   `/obs` skill's Step 2 -- same check, same troubleshooting).
2. Open the project in a visible `connect-chrome` window.
3. Set up the OBS scene once per demo (not per step): a Window Capture of
   the `connect-chrome` browser window (via `obs_control.add_window_capture`,
   fuzzy-matched against the browser window's title), plus a caption text
   source (`scripts/captions.py`'s `add_caption`), positioned bottom-center
   (`update_caption` re-centers automatically on every call). Add the round
   camera too if the plan calls for presenter video -- same as /obs.
4. Start recording (`obs_control.start_recording`).
5. Walk the plan step by step. For each step:
   - `captions.update_caption(client, scene_name, caption_source, step["caption"])`
   - Perform the actual browser action via `connect-chrome` (navigate/click/type).
   - If the step benefits from a zoom-in (a small but important UI
     element), compute the on-screen region of the target element yourself
     (you already know exactly what you're about to click) and push a
     temporary `set_scene_item_transform` on the window-capture source to
     scale/crop into that region -- then transform back out before the next
     step. This replaces what a live human would need Advanced Scene
     Switcher for.
   - Pace steps for a human viewer, not machine speed: pause briefly after
     each action so the caption is actually readable and the click's effect
     is visible before moving on.
6. Stop recording (`obs_control.stop_recording`) once the plan is complete.
7. Tell the user where the output file is and to sanity-check it -- this
   skill can't watch its own output, a human check is the real
   verification step here, same as with `/obs`.

## Bundled resources

- `scripts/captions.py` -- caption text-source control (`add_caption`,
  `update_caption`, position auto-recentering). Read its module docstring
  before touching the text source kind id -- it documents a real
  source-vs-shipped-binary version mismatch that was caught while building
  this skill (`text_ft2_source` in the source tree vs. the actually
  installed `text_ft2_source_v2`); don't reintroduce that bug elsewhere.
- `../obs/scripts/obs_control.py` (via `/obs`, not duplicated here) --
  scenes, window capture, round camera, recording, status.
