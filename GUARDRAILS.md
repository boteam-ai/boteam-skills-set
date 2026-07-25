# GUARDRAILS — boteam-skills-set boundaries

This repo is the **public SSOT** for solo-founder AI expert skills — not a product codebase.

## In scope

| Type | Path |
|------|------|
| Expert four-piece | `.cursor/skills/<slug>/` (SKILL, SOUL, SOURCES, EVALUATION) |
| Utility skills | `.cursor/skills/<slug>/` (SKILL.md; SOUL optional) |
| Slash commands | `.cursor/commands/` |
| HR rubric + roster | `hr/` |
| Install / ship scripts | `scripts/` |
| Docs + marketing | `docs/`, `marketing/` |

## Out of scope

- Product application code (ship in your app repo)
- Secrets, `.env` values, customer data
- Private site-ops or newsletter automation pipelines
- Raw upstream clones (`sources/` — local only, gitignored)

## SSOT workflow

```
boteam-skills-set/.cursor/skills/<name>/   ← edit here
         │
         │  ./scripts/ship-skill.sh <name>
         ▼
~/.cursor/skills/<name>  ──┐
~/.claude/skills/<name>  ──┴→ symlinks only (no real copies)
```

Entry command: **`/boteam`** — full expert roster.

## Quality bar (core experts)

- `SKILL.md` ≤ ~200 lines; depth in `references/`
- At least one verifiable open-source source in `SOURCES.md`
- `## Handoffs` section with clear next-expert routing
- Ship gate: `./scripts/validate-skill.sh <name>` then `./scripts/ship-skill.sh <name>`

## Public audit

Run `./scripts/validate-repo.sh` before every release — blocks personal paths, private project names, and legacy `/team` artifacts.

See [CONTRIBUTING.md](CONTRIBUTING.md).
