# Workflow: Ship a Chrome extension (store listing)

**Goal:** Chrome Web Store listing assets at exact dimensions, with copy you approved before design.

**Canonical tool:** [boteam-ai/chrome-web-store-asset-generator](https://github.com/boteam-ai/chrome-web-store-asset-generator) (demo preview + batch PNG export)

## Steps

| # | Invoke | Output |
|---|--------|--------|
| 1 | `/copywriter` or `/cmo` | Listing promise, feature bullets, trust claims |
| 2 | `/chrome-web-store-asset-generator` | Context audit → asset map → 3 copy variants per slide → sign-off |
| 3 | (agent builds) | `cws-assets-preview/` — 4 style packages + promo tiles |
| 4 | `/qa-review` | Preview loads; export PNGs at 1280×800 and 440×280 |

## Before you start

- [ ] Raw screenshots in a folder (PNG/JPG/WebP)
- [ ] Filename → slide mapping agreed (see skill Phase 2)
- [ ] `manifest.json` name, description, icon path (if in repo)

## Done when

- [ ] Copy signed off for **every slide** (skill Phase 4 gate)
- [ ] Local preview runs (`npm run dev` in `cws-assets-preview/`)
- [ ] Batch export in `export/screenshots/` + `export/promo-tiles/`
- [ ] You picked one style package (or mix) for CWS upload

## Revision

Cite slide + style: `style-b-slide-04` — change headline or swap asset filename. Re-export affected PNGs.

## Next workflow

[build-in-public.md](build-in-public.md) — announce the listing with `/bip` + `/social-media-manager`
