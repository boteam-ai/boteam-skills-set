# boteam-skills-set — Claude Code entry

Public SSOT for solo-founder AI expert skills (Cursor + Claude Code).

Read [GUARDRAILS.md](GUARDRAILS.md) before adding files.

## Install (once)

```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
./scripts/install-skills.sh --global --shipped-only
```

## Skills

- Canonical path: `.cursor/skills/<name>/`
- Global consumption: symlinks in `~/.cursor/skills/` and `~/.claude/skills/`
- Ship: `./scripts/validate-skill.sh <name>` → `./scripts/ship-skill.sh <name>`

## Org loops

Run from this repo: `/hire-expert`, `/hr-review`, `/clevel`, `/distill-to-team`

## Product repos

Use `/setup` or `./scripts/setup-project.sh /path/to/app` — never run setup against this repo.
