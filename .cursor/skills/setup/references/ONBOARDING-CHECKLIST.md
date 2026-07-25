# New Product Repo — Onboarding Checklist

Used by [`../SKILL.md`](../SKILL.md) after `setup-project.sh` runs. Mark each item and
report gaps to the user in Chinese.

## Automated (setup-project.sh)

| # | Item | How to verify |
|---|------|----------------|
| 1 | Global team skills in `~/.cursor/skills/` | Each team skill symlink → `${SKILLS_ROOT}/.cursor/skills/<name>` |
| 2 | Project slash commands in `.cursor/commands/` | e.g. `/qa-review`, `/product-team`, `/full-stack-engineer` via linked `.md` files |
| 3 | QA rules in `.cursor/rules/` | `context-before-code.mdc`, `evidence-before-done.mdc` symlinked from team |
| 4 | `AGENTS.md` at repo root | Exists; Project Context table has detected runtime/commands |
| 5 | Known Footguns table | Present (may be empty — filled by `/qa-review` over time) |

## Manual follow-up (agent reports, user completes)

| # | Item | Action |
|---|------|--------|
| 6 | Fill `_(unset)_` rows in AGENTS.md | Hand-edit anything init-project-context could not detect |
| 7 | `.env.example` | Create or review; never commit real secrets |
| 8 | Playwright MCP (optional) | `scripts/merge-playwright-mcp.sh` from team repo if UI QA needed |
| 9 | First `/qa-review` | Run after first feature ship to validate the evidence loop |
| 10 | Remove redundant `.cursor/skills/` | If an old full `--project` install duplicated skills and global is active, project-local skill symlinks are optional — safe to remove if all globals are linked |

## What global vs project each provide

| Layer | Global (`~/.cursor/skills/`) | Project (this repo) |
|-------|------------------------------|---------------------|
| Expert skills (`/product-manager`, etc.) | Yes — all Cursor projects | Skipped when global OK |
| Slash commands (`/qa-review`, `/clevel`, …) | No | Yes — `.cursor/commands/` |
| QA rules | No | Yes — `.cursor/rules/` |
| AGENTS.md + Footguns | No | Yes — product-specific context |

## Re-run safety

`setup-project.sh` is idempotent: safe on an already-setup repo. It will refresh
`_(unset)_` Project Context rows but never overwrite Known Footguns or filled values.
