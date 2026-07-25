# /setup — Onboard a product repo with the team AI stack

Wire a **product repository** into the one-person-company expert system: global team
skills (if missing), project slash commands, QA rules, and `AGENTS.md` with auto-detected
Project Context. Skips duplicating skills into the project when global links already exist.

**Not for the skills-set repo** (`${SKILLS_ROOT}`) — that is org layer, not a product.

## Usage

```
/setup
/setup /path/to/your-app
```

- No path → use the current workspace root as the product repo.
- With path → onboard that directory.

## Execution

1. Load [`.cursor/skills/setup/SKILL.md`](../skills/setup/SKILL.md).
2. Resolve the target product repo path (never this skills-set repo).
3. Run:

```bash
cd ${SKILLS_ROOT}
./scripts/setup-project.sh "<absolute-path>"
```

4. Read the project's `AGENTS.md` and [ONBOARDING-CHECKLIST](../skills/setup/references/ONBOARDING-CHECKLIST.md).
5. Reply in **Chinese** using the skill's report template — what ran, what's set, what's still manual.

## What gets installed

| Layer | Where | Skipped when |
|-------|-------|--------------|
| Team skills | `~/.cursor/skills/` (global) | Already linked → skip `--global` |
| Slash commands | `<project>/.cursor/commands/` | Always installed |
| QA rules | `<project>/.cursor/rules/` | Always installed |
| AGENTS.md | `<project>/AGENTS.md` | Created or Project Context refreshed |

Project `.cursor/skills/` is **not** populated when global skills are already linked.

## Do not

- Run against `${SKILLS_ROOT}`.
- Duplicate install steps manually if `setup-project.sh` succeeded.
- Claim onboarding complete without evidence from the script output and `AGENTS.md`.
