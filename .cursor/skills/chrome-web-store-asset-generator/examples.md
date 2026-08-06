# CWS Asset Generator — Examples

Generic, de-identified examples for the Chrome Web Store Asset Generator skill.

## Invocation

```
/chrome-web-store-asset-generator
```

```
Generate Chrome Web Store assets from ./assets/raw/
```

---

## Phase 1 — Context insufficient (agent asks)

```
Before we start, I need product context not found in this workspace:

1. What is the product and who is it for? (1–2 sentences)
2. List 3–5 core features with the user benefit of each
3. Top 3 install reasons / value highlights
4. Trust claims we can use on slides (privacy, pricing, MV3, BYOK)
5. Preferred tone: professional / playful / technical
```

---

## Phase 2 — Asset intake (agent asks)

```
Please confirm:

1. **Asset folder path:** e.g. `./assets/raw/`
2. **Naming convention:** How should I map filenames to slides?

   Option A — numbered: `1.png`, `2.png`, …
   Option B — descriptive: `01-hero-main-ui.png`, `07-checklist-post.png`
   Option C — provide a mapping table (filename → slide role)

3. **Multi-image slides:** Any slides that combine 2+ screenshots?
   Example: `checklist-post.png` + `checklist-reply.png` → Slide 07
```

---

## assetMap example (fictional extension "DraftFlow")

```js
export const assetMap = [
  { slideId: '01', type: 'hero', role: 'Main value prop', files: ['01-hero-main-ui.png'], layout: 'single' },
  { slideId: '02', type: 'workflow', role: 'Highlight-only reply', files: ['02-highlight-reply.png'], layout: 'single' },
  { slideId: '03', type: 'feature', role: 'Angle picker', files: ['03-angle-picker.png'], layout: 'single' },
  { slideId: '04', type: 'workflow', role: 'Save inspirations', files: ['04-save-inspirations.png'], layout: 'single' },
  { slideId: '05', type: 'workflow', role: 'Create from library', files: ['05-create-panel.png'], layout: 'single' },
  { slideId: '06', type: 'feature', role: 'Post assistant', files: ['06-post-assistant.png'], layout: 'single' },
  { slideId: '07', type: 'checklist', role: 'Optimization checklist', files: ['07-checklist-post.png', '07-checklist-reply.png'], layout: 'dual' },
  { slideId: '08', type: 'trust', role: 'Settings + tracking', files: ['08-settings.png', '08-tracking.png'], layout: 'stacked' },
];
```

---

## Phase 3 — Copy proposal excerpt

```markdown
### Slide 07 — Optimization Checklist
Assets: `07-checklist-post.png` + `07-checklist-reply.png`

| | Variant A | Variant B | Variant C |
|---|-----------|-----------|-----------|
| Kicker | Before you post | Optimization Checklist | Quality gate |
| Headline | Optimize before you publish | Score drafts against your playbook | Fix weak drafts before they go live |
| Subline | Post and reply checklists flag gaps in your draft. | Playbook rules for Post + Reply modes. | Actionable fixes — one tap to Optimize. |
| Pills | Post + Reply · Actionable fixes · One-tap Optimize | Playbook rules · Both modes · Optimize | Checklist · Post mode · Reply mode |

Which variant for Slide 07? You can mix fields across A/B/C or paste your own.
```

Repeat for every slide + promo tiles before building.

---

## Phase 7 — Revision requests (user → agent)

```
Change style-b-slide-04 headline to "Bookmark posts. Draft faster."
```

```
style-c-slide-07: use stacked layout with checklist-reply.png only
```

```
Re-export all Style D screenshots after copy update
```

---

## Export matrix (8 slides × 4 styles + 3 promos = 35 PNGs)

| Pattern | Count |
|---------|-------|
| `style-{a,b,c,d}-slide-{01..08}-1280x800.png` | 32 |
| `promo-tile-{01,02,03}-440x280.png` | 3 |

---

## Local preview commands

See `examples/demo-preview/` in this repository for a runnable reference implementation.

```bash
cd examples/demo-preview
npm install
npm run dev          # http://localhost:5173
npm run export:batch # writes to export/
```
