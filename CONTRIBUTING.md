# Contributing

Thanks for helping solo founders get a better AI expert system.

## What we welcome

- Bug fixes in skills, scripts, docs
- New **utility** skills (SKILL.md + clear description + `.shipped` after review)
- Workflow improvements in `docs/workflows/`
- Translations in `docs/` (keep SKILL files English for LLM quality)

## Core experts (higher bar)

New core experts need:

1. Four-piece set: SKILL, SOUL, SOURCES, EVALUATION
2. At least one verifiable MIT (or compatible) upstream source
3. `## Handoffs` with ≥2 routing rows
4. HR rubric alignment — open an issue before large PRs

## Dev loop

```bash
./scripts/validate-skill.sh <name>
./scripts/ship-skill.sh <name>
./scripts/validate-repo.sh
```

## PR checklist

- [ ] No `/Users/` or personal paths
- [ ] No product app code
- [ ] `validate-repo.sh` passes
- [ ] CHANGELOG.md updated under `[Unreleased]` for user-visible changes
