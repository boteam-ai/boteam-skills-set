# Demo Playbook (reference)

Deep reference for `/demo`. Read when authoring the flow, writing SRT, or running the CDP fallback.

## 1. Flow template (`flow.md`)

```markdown
# Demo flow — <Product> · <feature> · <YYYY-MM-DD>

- **Browser:** Chrome
- **Viewport:** 1440×900
- **Target length:** ~38s
- **Start URL:** https://example.com/app

## Steps

| # | Action | Target | Narration (EN) | Expected | s |
|---|--------|--------|----------------|----------|---|
| 1 | navigate | https://example.com/app | Open the workspace | App dashboard loads | 3 |
| 2 | click | "New item" button | Start a new item | Empty item form appears | 2.5 |
| 3 | type | title field, "Ship the demo skill" | Name it | Text entered | 2 |
| 4 | click | "Save" | Save and publish | Item appears in list | 2.5 |
| 5 | wait | — | The change is live | Toast: "Saved" | 2 |

## Totals
- steps: 5
- estimated duration: 12s + 2s buffer = 14s
```

Narration rules:
- Present tense, second person ("You ...") or imperative. ≤ 60 chars.
- One idea per beat. Show the viewer the **outcome**, not the implementation.
- No marketing fluff, no internal names/IDs, no code.

## 2. Subtitle format (`demo.srt`)

Generate from the flow. Cumulative timestamps in `HH:MM:SS,mmm` (SRT). One cue per step; keep cue visible across the step's dwell.

```text
1
00:00:00,000 --> 00:00:03,000
Open the workspace

2
00:00:03,000 --> 00:00:05,500
Start a new item

3
00:00:05,500 --> 00:00:07,500
Name it

4
00:00:07,500 --> 00:00:10,000
Save and publish

5
00:00:10,000 --> 00:00:12,000
The change is live
```

Tips:
- Add a 0.5s lead cue (title card) for the product name if useful.
- If a step's narration is short, extend the cue to the next action so captions don't flicker.
- Keep ≤ 42 chars per line; wrap long lines into two lines inside one cue.

## 3. ffmpeg subtitle styling (burn-subs.sh)

`burn-subs.sh` **defaults to the Pillow path** (`burn-subs.py`). It only uses the
ffmpeg `subtitles` filter when you set `DEMO_USE_LIBASS=1` AND a libass-enabled
ffmpeg is present.

**Default path — Pillow PNG overlay** (`burn-subs.py`): renders each cue to a
transparent PNG (dark rounded box, white Helvetica with black stroke,
bottom-center) and composites with ffmpeg `overlay` +
`enable=between(t,start,end)`. Works **without libass/freetype**; output is true
burned-in captions. This is the verified path on stock homebrew `ffmpeg`.

**Opt-in fast path — ffmpeg `subtitles` filter** (needs libass). Default
`force_style`:

```text
FontName=Helvetica,FontSize=22,
PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,
BorderStyle=1,Outline=2,Shadow=1,MarginV=44,Alignment=2
```

`PrimaryColour` is `&H00BBGGRR` (ASS). White text, black outline → readable on any UI.

To enable the fast path: install a libass-enabled ffmpeg (e.g.
`brew tap homebrew-ffmpeg/ffmpeg && brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-libass`)
then run with `DEMO_USE_LIBASS=1`.

Path escaping (fast path): the `subtitles` filter splits options on `:` — the
script escapes `:` in the SRT path. If the SRT path contains single quotes, move
the file to a quote-free path first.

## 4. CDP frame fallback (when screencapture is denied)

Use only when macOS screen recording permission is missing or `screencapture` fails.

Loop while driving:

```
browser_cdp → Page.captureScreenshot { format: "png" }  → save frame_NNNN.png
sleep ~125ms  (≈ 8 fps)
```

Drive the same browser_click / browser_type / browser_scroll actions between frames. After the flow:

```bash
ffmpeg -y -framerate 8 -pattern_type glob -i 'frames/*.png' \
  -pix_fmt yuv420p raw.mp4
```

Then continue at step 7 (write SRT) and step 8 (burn-subs.sh).

Tradeoff: frame-stitched video is a slideshow (~8 fps), not smooth motion. Prefer screencapture whenever the permission is granted.

## 5. manifest.json

```json
{
  "date": "YYYY-MM-DD",
  "product": "<Product>",
  "feature": "<feature>",
  "browser": "Chrome",
  "viewport": "1440x900",
  "capture": "screencapture | cdp-frames",
  "status": "recorded | burned | failed",
  "duration_sec": 14,
  "steps": 5,
  "start_url": "https://example.com/app",
  "files": {
    "flow": "flow.md",
    "srt": "demo.srt",
    "raw": "raw.mp4",
    "final": "demo.mp4"
  }
}
```

## 6. Failure handling

| Symptom | Fix |
|---------|-----|
| `screencapture` writes 0-byte mov | Screen Recording permission missing → grant to Cursor, or switch to CDP fallback |
| `raw.mp4` odd dimensions / ffmpeg pixel format error | record-demo.sh already re-encodes with `-pix_fmt yuv420p` + even-scale; burn-subs also forces even scale |
| subtitles filter "not found" / "No such filter" | Expected on stock homebrew `ffmpeg` — Pillow path is the default and needs no libass; fast path requires `DEMO_USE_LIBASS=1` + a libass build |
| subtitles filter "failed to open file" (fast path only) | SRT path has `:` or quote → escape `:` (script does) or move file |
| Step can't be automated (login/captcha) | Stop, ask user to perform it, resume recording by re-running recorder for the remaining steps |
| Extension UI not visible | Extension must be installed in the Chrome profile the MCP drives; ask user to confirm, reload page |

## 7. Privacy

Before recording, the agent must tell the user to close: terminals, chat windows, password managers, email, personal tabs. If a secret appears on screen, delete that run's folder and re-record — never publish a frame containing credentials.
