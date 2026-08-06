---
name: chrome-web-store-asset-generator
description: >-
  Generates Chrome Web Store listing assets from raw screenshots via a gated
  workflow: audit product context, collect asset folder + naming convention,
  propose 3 copywriting variants per slide for user confirmation, then build
  4 visual style packages plus promo tiles in a local React preview with PNG
  export. Use when the user asks to generate CWS screenshots, store promo
  tiles, StoreAssetsPreview, or chrome-web-store-asset-generator.
disable-model-invocation: true
---

# Chrome Web Store Asset Generator

> **Canonical repo (demo + showcase + releases):** [boteam-ai/chrome-web-store-asset-generator](https://github.com/boteam-ai/chrome-web-store-asset-generator) · Provenance: [SOURCES.md](SOURCES.md)

Transform raw extension screenshots into **4 visual style packages** + **promo tiles**, with **copy confirmed slide-by-slide before any design work**.

## Workflow overview

```
1. Context audit → 2. Asset intake → 3. Copy proposal (3 variants) →
4. Per-slide copy confirmation → 5. Build preview app → 6. Deliver + export →
7. Revision loop (by slide ID / style / filename)
```

**Gate:** Do **not** scaffold the preview app or render final cards until the user explicitly approves copy for **every slide**.

---

## Phase 1 — Context audit

On trigger, first check whether the **current project** contains enough product context.

### Read (when in a project repo)

| Source | Look for |
|--------|----------|
| `manifest.json` | `name`, `description`, icons |
| `docs/` store copy, privacy, playbook | features, trust claims |
| `CHANGELOG.md`, README | shipped features, value props |
| User message | explicit product brief |

### Minimum product context required

| Field | Required |
|-------|----------|
| Product name | Yes |
| One-line tagline | Yes |
| 3+ core features with benefit wording | Yes |
| Trust / privacy claims (accurate to product) | Yes |
| Target user / use case | Yes |
| Icon path or asset | Yes |

### If context is insufficient

Stop and ask the user **once**, in one message. Request:

1. **Product introduction** — what it is, who it's for
2. **Feature list** — each feature + user benefit (not just feature names)
3. **Highlight / value props** — top 3 reasons to install
4. **Trust claims** — privacy, pricing tier, MV3, BYOK, etc. (must be truthful)
5. **Tone preference** — professional / playful / technical (optional)

Do **not** invent features or metrics. Do **not** proceed to Phase 3 until answers arrive.

---

## Phase 2 — Asset intake

Guide the user to provide:

### 2a. Raw assets folder path

Ask for an **absolute or workspace-relative path**, e.g.:

```
/Users/me/project/assets/raw/
```

Scan the folder. List every image found. Accept `.png`, `.jpg`, `.webp`.

### 2b. Naming convention

Ask the user to confirm or define how filenames map to slide roles. Examples:

| Convention | Example | Maps to |
|------------|---------|---------|
| Numbered | `1.png` … `8.png` | Slide order by number |
| Descriptive prefix | `01-hero-ai-reply.png` | Parse prefix / keywords |
| Feature-named | `reply-angles.png`, `checklist-post.png` | User provides mapping table |

**Agent must produce an `assetMap`** before copy proposal:

```js
// src/assetMap.js — single source of truth
export const assetMap = [
  { slideId: '01', role: 'hero', files: ['01-hero-main-ui.png'], layout: 'single' },
  { slideId: '07', role: 'checklist', files: ['07-checklist-post.png', '07-checklist-reply.png'], layout: 'dual' },
  // …
];
```

Rules:

- If naming is ambiguous, ask **one** clarifying question — do not guess slide placement.
- Multi-image slides (e.g. two checklists): record `layout: 'dual' | 'stacked'` and all filenames.
- Copy or symlink assets into `public/assets/raw/` with stable internal names; keep original names in `assetMap` for revision reference.

---

## Phase 3 — Copy proposal (3 variants)

After context + asset map exist, **research the product** (repo docs, manifest, user brief) and draft **3 copywriting variants** for **each slide**.

Present as a table per slide:

```markdown
### Slide 07 — Optimization Checklist
Assets: `07-checklist-post.png` + `07-checklist-reply.png`

| | Variant A | Variant B | Variant C |
|---|-----------|-----------|-----------|
| Kicker | … | … | … |
| Headline | … | … | … |
| Subline | … | … | … |
| Pills | … | … | … |
```

Variant tones (suggested):

- **A** — Benefit-led, plain language
- **B** — Feature-led, technical clarity
- **C** — Outcome-led, conversion punch

Also propose promo tile copy (3 tile layouts × headline/tagline/badges).

**Do not build React components yet.**

---

## Phase 4 — Per-slide copy confirmation

Walk through **every slide** (and promo tiles). For each:

1. Show the 3 variants (or user's edited mix)
2. Ask user to pick, edit, or supply final copy
3. Record approved copy in `src/productMeta.js` (or `copy.lock.json`)

Use a confirmation checklist:

```
Copy sign-off:
- [ ] Slide 01 … 0N — approved
- [ ] Promo tile 01–03 — approved
- [ ] User said "copy is final" or equivalent
```

**Only after all boxes checked** → proceed to Phase 5.

User may revise copy during this phase freely. Reflect changes in the proposal table before locking.

---

## Phase 5 — Build preview app

Create Vite + React + Tailwind project (default: `./cws-assets-preview/` in project or user-specified path):

```
cws-assets-preview/
├── src/
│   ├── StoreAssetsPreview.jsx
│   ├── productMeta.js      # locked copy from Phase 4
│   ├── assetMap.js         # filename → slide mapping
│   ├── components/
│   └── themes/             # 4 style packages
├── public/assets/raw/
├── scripts/batch-export.mjs
└── export/                 # batch PNG output
```

### 4 visual style packages

| Package | Name | Vibe |
|---------|------|------|
| A | Apple Pro Minimalist | Clean Apple product page |
| B | Cyber / Modern SaaS | Linear / Vercel energy |
| C | Editorial Studio | Stripe / Notion warmth |
| D | Bold Contrast | High-contrast dark/light split, strong typographic hierarchy |

Apply the same **approved copy** and **assetMap** to all 4 packages. Theme tokens: [reference.md](reference.md).

Slide count = number of entries in `assetMap` (not fixed at 5). Promo tiles: 3 options at 440×280.

### Technical specs (non-negotiable)

```css
.cws-screenshot { width: 1280px; height: 800px; overflow: hidden; position: relative; }
.cws-promo-tile { width: 440px; height: 280px; overflow: hidden; position: relative; }
```

Each card: `data-export-filename` attribute for batch export.

Tab bar:

- `[ Style A: Apple Pro ]` `[ Style B: Cyber SaaS ]` `[ Style C: Editorial Studio ]` `[ Style D: Bold Contrast ]` `[ Promo Tiles ]`

Run `npm install && npm run dev` — verify all assets render.

---

## Phase 6 — Deliver

Provide to user:

1. **Local preview URL** — `npm run dev` (typically `http://localhost:5173/`)
2. **Batch export** — `npm run export:batch` → `export/screenshots/` + `export/promo-tiles/`
3. **Revision guide** — how to request changes by ID

### Completion message template

```markdown
## CWS assets ready

**Preview:** `cd cws-assets-preview && npm run dev`
**Exports:** `cws-assets-preview/export/` (run `npm run export:batch` to refresh)

**Slide IDs:** 01–0N — see `src/assetMap.js`
**Styles:** A (Apple Pro) · B (Cyber SaaS) · C (Editorial) · D (Bold Contrast)

**Request a tweak:** cite `style-b-slide-04` + change copy and/or swap asset filename.
```

---

## Phase 7 — Revision loop

When user requests tweaks, they should specify:

| Input | Example |
|-------|---------|
| **Slide ID + style** | `style-b-slide-04` or "Slide 04, Style B" |
| **Copy change** | new headline / subline / pills in `productMeta.js` |
| **Asset swap** | "use `7 Filter Saved Posts.png` instead" — update `assetMap.js` entry |

Agent workflow:

1. Apply change to `productMeta.js` and/or `assetMap.js`
2. Re-run dev verification
3. Re-export affected PNGs (or full batch if easier)
4. Report updated file paths

Do **not** require full copy re-approval for asset swaps or minor copy edits unless user changes core claims.

---

## Rules

- **No design before copy lock** — Phases 5–6 wait on Phase 4 sign-off.
- **No invented product claims** — copy must match repo / user-provided facts.
- **No critical UI crop** — prefer contained mockup frames over aggressive `object-fit: cover`.
- **Naming is authoritative** — slide placement follows `assetMap`, not agent guesswork.
- **Scope discipline** — scaffold in subfolder; do not refactor unrelated project code.
- **4 styles, 1 copy set** — visual themes vary; approved copy is shared across A–D.

## Additional resources

- Theme tokens, slide layouts, Style D tokens: [reference.md](reference.md)
- Invocation examples, naming conventions, copy tables: [examples.md](examples.md)
