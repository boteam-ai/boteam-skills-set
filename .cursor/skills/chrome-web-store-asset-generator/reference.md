# CWS Asset Generator — Reference

## 4 visual style packages

Same approved copy + assetMap applied to each theme.

### Style A — Clean Minimal

- **Canvas:** `#000000`–`#0A0D14` or `#F5F5F7`
- **Elements:** Frosted glass, rounded desktop-style window frames, soft radial flares
- **Typography:** System sans, silver/white headings

```js
export const themeA = {
  canvas: 'bg-[#0A0D14]',
  window: 'rounded-xl border border-white/10 bg-[#1C1C1E] shadow-[0_24px_80px_rgba(0,0,0,0.45)]',
  heading: 'font-sans font-semibold tracking-tight text-white',
  pill: 'bg-white/10 text-white/80 border border-white/15 rounded-full px-3 py-1 text-sm',
};
```

### Style B — Neon Tech

- **Canvas:** `#030712` + subtle grid + neon glows (cyan / indigo)
- **Elements:** Glowing borders, sharp geometry, uppercase micro-badges
- **Typography:** Modern sans, vivid accent colors

```js
export const themeB = {
  canvas: 'bg-[#030712] bg-grid-cyber bg-grid',
  window: 'rounded-lg border border-indigo-500/30 bg-[#0B0F19] shadow-[0_0_40px_rgba(56,189,248,0.15)]',
  heading: 'font-sans font-bold tracking-tight text-white',
  pill: 'bg-indigo-500/20 text-cyan-300 border border-indigo-500/40 rounded-md px-2.5 py-0.5 text-xs uppercase tracking-wider',
};
```

### Style C — Warm Editorial

- **Canvas:** `#FAF8F5` or warm dark `#141413`
- **Elements:** Soft stone shadows, generous whitespace, serif headings
- **Typography:** Editorial serif + clean sans body

```js
export const themeC = {
  canvas: 'bg-[#FAF8F5]',
  window: 'rounded-xl border border-stone-200/80 bg-white shadow-2xl shadow-stone-900/5',
  heading: 'font-serif font-medium tracking-tight text-stone-900',
  pill: 'bg-stone-100 text-stone-600 border border-stone-200 rounded-full px-3 py-1 text-sm',
};
```

### Style D — Bold Contrast

- **Canvas:** Split or full `#0F0F0F` with high-contrast accent blocks (`#FF4D00` or product accent if provided)
- **Elements:** Large typographic headlines, hard dividers, minimal decoration, strong CTA blocks
- **Typography:** Bold geometric sans, oversized headlines, mono kickers

```js
export const themeD = {
  canvas: 'bg-[#0F0F0F]',
  window: 'rounded-none border-2 border-white/20 bg-[#1A1A1A] shadow-none',
  heading: 'font-sans font-black tracking-tighter text-white uppercase',
  pill: 'bg-[#FF4D00] text-white rounded-sm px-3 py-1 text-xs font-bold uppercase',
  accent: 'text-[#FF4D00]',
};
```

Use product brand accent in Style D when available from repo tokens; otherwise default orange.

---

## Slide layout types

Map each `assetMap` entry to a layout `type`:

| Type | Use when | Layout |
|------|----------|--------|
| `hero` | First slide / main value prop | Title top + centered window |
| `workflow` | Process / how-it-works | Text left + tilted mockup right |
| `feature` | Single power feature | Centered zoom + spotlight |
| `checklist` | 2 related screens on one slide | Dual windows side-by-side |
| `trust` | Settings, privacy, CTA finale | CTA stack + 1–2 setting screenshots |
| `context` | In-page / before-after | Comparison or browser chrome mockup |

Multi-file entries: `files: ['a.png', 'b.png']` with `layout: 'dual' | 'stacked'`.

---

## Copy lock file (optional)

After Phase 4, optionally persist:

```json
{
  "lockedAt": "2026-08-06T12:00:00Z",
  "slides": {
    "01": { "variant": "B", "kicker": "…", "headline": "…", "subline": "…", "pills": [] }
  },
  "promo": { "01": { "headline": "…", "tagline": "…" } }
}
```

`productMeta.js` is the runtime source; `copy.lock.json` is the audit trail.

---

## assetMap schema

```js
export const assetMap = [
  {
    slideId: '01',
    type: 'hero',
    role: 'Hero — main value prop',
    files: ['01-hero-main-ui.png'],
    publicPaths: ['/assets/raw/1.png'],
    layout: 'single',
  },
];
```

Agent derives `publicPaths` by copying/symlinking; `files` stays as user-facing names for revisions.

---

## Small promo tiles (440×280)

3 layout options (copy from Phase 4):

1. **Logo focus** — icon + name + tagline
2. **UI banner** — text left + cropped screenshot right
3. **Trust badges** — logo row + headline + pill strip

---

## Export naming

| Asset | Pattern | Example |
|-------|---------|---------|
| Screenshot | `style-{a|b|c|d}-slide-{ID}-1280x800.png` | `style-b-slide-04-1280x800.png` |
| Promo | `promo-tile-{01|02|03}-440x280.png` | `promo-tile-02-440x280.png` |

Batch export via Puppeteer: [scripts/batch-export.mjs pattern in project `cws-assets-preview/`].

Each export target: `data-export-filename="{pattern}"` on the card root element.

---

## html2canvas / Puppeteer notes

- `scale: 1` for exact CWS dimensions
- `useCORS: true` for Vite-served local images
- Wait for all `document.images` complete before batch screenshot
- Output directory: `export/screenshots/` + `export/promo-tiles/` + `export/manifest.json`

---

## CWS dimensions

| Asset | Size |
|-------|------|
| Screenshot | 1280 × 800 |
| Small promo tile | 440 × 280 |

640×400 and 1400×560 marquee — out of scope unless user asks.
