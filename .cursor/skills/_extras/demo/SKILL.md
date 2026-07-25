---
name: demo
description: >-
  Record a polished product feature demo video after shipping. Reads the
  development chat context to propose an English-narrated demo flow, confirms
  unknowns (target page, platform, login, viewport) with the user, then drives
  the browser via the cursor-ide-browser MCP and records the screen (macOS
  screencapture, with a CDP frame-capture fallback), then burns English
  subtitles into the final mp4 with ffmpeg. Use when the user says /demo,
  "record a demo of this feature", "demo this", or ships a feature and wants a
  demo video. Output is English.
disable-model-invocation: true
---

# Demo (Product Feature Demo Recorder)

> **Reply in English.** Skill file, narration, and subtitles are **English only**.
> Deep reference: [references/DEMO-PLAYBOOK.md](references/DEMO-PLAYBOOK.md)

## Usage

```
/demo Chrome, Extension XXX
/demo Chrome, <Product>
/demo Safari, <Product>
```

Parses `<Browser>, <Product/Target>`. Browser defaults to **Chrome**.

### Not the same as `demo` suffix

Commands like `/help-skills demo` or `/team demo` use **Demo Output Mode** — English, redacted catalog text for screen recording. They do **not** start video capture. See `team/.cursor/references/DEMO-SUFFIX.md`.

## Output

Folder: `./demos/<feature-slug>-<YYYY-MM-DD>/` (in the product repo you ran it from)

```text
├── flow.md          # confirmed demo flow (steps + English narration)
├── demo.srt         # English subtitle track, timed to steps
├── raw.mp4          # captured video (no subtitles)
├── demo.mp4         # FINAL — video with burned-in English subtitles
└── manifest.json    # run metadata + status
```

## Workflow

1. **Parse args** — `<Browser>, <Product>`. If browser unsupported or product unclear, ask once.
2. **Mine chat context** — from the dev conversation summarize: what shipped, the user-visible value, and the exact flow a viewer must see. Do NOT pull unrelated history.
3. **Propose demo flow** — numbered steps. Each step:
   - **action** (click / type / navigate / scroll / wait)
   - **target** (URL or element description)
   - **narration** — one English line, ≤ 60 chars, present-tense, benefit-led
   - **expected** — what the viewer should see
   - **seconds** — estimated dwell (1.5–4s)
   Present the full flow in chat for approval.
4. **Confirm unknowns** (AskQuestion, only what chat context does not reveal):
   - target page/URL or which platform site to demo on
   - login / seed data / account state needed
   - viewport (default 1440×900) + browser profile with the product/extension installed
   - total target length (default 30–45s)
5. **Prep browser** — `browser_navigate` to start URL, `browser_lock` lock the tab, set viewport, verify the extension/product is installed & enabled. Tell the user to: bring Chrome to front, fullscreen it (⌃⌘F), close unrelated tabs/windows (no terminals, secrets, personal tabs on screen). Wait for explicit "scene ready" confirmation.
6. **Record** — compute `duration = sum(step.seconds) + 2s buffer`.
   - Default (macOS screencapture): launch `scripts/record-demo.sh <out_dir> <duration>` in the **background**, then immediately drive the flow with `browser_click` / `browser_type` / `browser_scroll` / `browser_press_key`. Await the recorder when the flow ends.
   - Fallback (if screencapture denied/unavailable): loop `browser_cdp Page.captureScreenshot` (PNG) at ~8 fps while driving, then stitch with ffmpeg at 8 fps → `raw.mp4` (see playbook §CDP fallback).
7. **Write subtitles** — generate `demo.srt` timed to each step's start/end from the flow. English, one short line per beat. Format in playbook §Subtitles.
8. **Burn-in** — `scripts/burn-subs.sh raw.mp4 demo.srt demo.mp4`. **Default = Pillow PNG-overlay path** (`burn-subs.py`): renders each cue to a transparent caption PNG and composites with ffmpeg `overlay` — true burned-in English captions, works on stock homebrew `ffmpeg` (no libass needed). Opt-in fast path: set `DEMO_USE_LIBASS=1` with a libass-enabled ffmpeg to use the `subtitles` filter.
9. **Verify + report** — confirm `demo.mp4` exists and `ffprobe` shows a video stream; report folder path, duration, step count, and `file://` link to `demo.mp4`. Offer a shorter recut or a different page.

## Rules

- **Never start recording** before the user approves the flow AND confirms the scene is ready.
- One demo = one feature. Multiple features → run `/demo` per feature.
- Subtitles: English, present tense, show the **benefit**, not internals. No code, no log lines.
- Capture user-visible product only. Hard-stop and ask the user to perform any manual step (login, captcha, OAuth consent) — never fake it.
- Reuse the existing `cursor-ide-browser` MCP tab. Do not spawn a second browser.
  (Claude Code: `cursor-ide-browser` is Cursor-only — use Playwright MCP or another browser MCP; see `qa-review/references/MCP-SETUP.md`.)
- If a step fails twice, stop, report what blocked progress, and ask the user how to proceed (per browser MCP rabbit-hole rule).

## Dependencies

- macOS `screencapture` (built-in) + **Screen Recording permission** granted to Cursor (System Settings → Privacy → Screen Recording). One-time.
- `ffmpeg` — `brew install ffmpeg` (verify: `ffmpeg -version`). Burn-in uses the **Pillow path by default** — no libass/freetype required.
- `python3` + **Pillow** — `pip install pillow` (default burn-in; Pillow 12 verified)
- `cursor-ide-browser` MCP enabled
- Optional fast path: a libass-enabled ffmpeg (e.g. `homebrew-ffmpeg/ffmpeg` tap `--with-libass`) + `DEMO_USE_LIBASS=1`

## Scripts

- `scripts/record-demo.sh <out_dir> <duration_sec>` — screencapture → `raw.mp4`
- `scripts/burn-subs.sh <raw_mp4> <srt> <out_mp4>` — burn styled English captions → final `demo.mp4`

## Reference

- Flow template, SRT format, ffmpeg styling, CDP frame fallback, manifest schema: [references/DEMO-PLAYBOOK.md](references/DEMO-PLAYBOOK.md)
