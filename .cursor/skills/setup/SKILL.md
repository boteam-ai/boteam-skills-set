---
name: setup
description: >-
  Onboards a new or existing product repo with the full team AI stack: ensures global
  team skills are linked, installs project slash commands and QA rules, generates or
  refreshes AGENTS.md (Project Context + Known Footguns), and runs the onboarding
  checklist. Skips duplicating skills into the project when ~/.cursor/skills/ already
  links team. Use when the user invokes /setup, sets up a new project, onboards a repo,
  or asks to wire team skills into a product workspace.
disable-model-invocation: true
---

# Setup — product repo onboarding

> **Reply in Chinese.** Skill files stay in English.
> Checklist: [references/ONBOARDING-CHECKLIST.md](references/ONBOARDING-CHECKLIST.md)

## Purpose

Wire a **product repo** (not team HQ) into the one-person-company expert system:

- **Global:** all team skills via `~/.cursor/skills/` (every Cursor project)
- **Project-only:** slash commands, QA rules, `AGENTS.md` (context + footguns live here)

Does **not** duplicate skills into `.cursor/skills/` when global links already exist.

## Resolve target

1. **Path:** user argument, else the active workspace root (`git rev-parse --show-toplevel` or cwd).
2. **Block team HQ:** if target is `${SKILLS_ROOT}`, stop and tell the user `/setup` is for product repos only.

## Run setup (always execute the script)

```bash
cd ${SKILLS_ROOT}
chmod +x scripts/setup-project.sh
./scripts/setup-project.sh "<absolute-path-to-product-repo>"
```

Do not hand-roll individual install steps unless the script fails — then diagnose and retry once.

## After the script — verify and report

1. Read [references/ONBOARDING-CHECKLIST.md](references/ONBOARDING-CHECKLIST.md).
2. Read `<project>/AGENTS.md` — note which Project Context rows are still `_(unset)_`.
3. List installed commands: `ls .cursor/commands/` (or note if missing).
4. Confirm QA rules: `.cursor/rules/context-before-code.mdc` and `evidence-before-done.mdc`.

## Reply template (Chinese)

```markdown
## /setup 完成 — `<project-name>`

**路径:** `<absolute path>`

### 已自动完成
- [x/ ] 全局 skills（~/.cursor/skills/ → team）
- [x/ ] 项目 commands（/qa-review、/product-team …）
- [x/ ] QA rules（context-before-code、evidence-before-done）
- [x/ ] AGENTS.md（Project Context + Known Footguns）

### Project Context 摘要
| 项 | 值 |
|----|-----|
| … | … |

### 待你手动完成
- [ ] 补全 AGENTS.md 中仍为 _(unset)_ 的行
- [ ] 检查 .env.example
- [ ] （可选）Playwright MCP：`${SKILLS_ROOT}/scripts/merge-playwright-mcp.sh`
- [ ] 首次 ship 后跑 `/qa-review`

### 下一步
在此仓库打开 Cursor，实现功能 → `/qa-review` 验证（不要同一 turn 自评 ready）。
```

## Rules

1. Never run `/setup` against `${SKILLS_ROOT}` — org HQ is out of scope.
2. Never commit secrets; only `.env.example` belongs in git.
3. If global skills were missing, mention that `--global` ran once — all future projects benefit.
4. If the user already has duplicate `.cursor/skills/` in the project from an old install, mention they can remove them when global is complete (optional cleanup, not automatic).
5. Do not claim setup is done without running `setup-project.sh` and reading `AGENTS.md`.

## Optional follow-ups (suggest only if relevant)

- Playwright MCP not configured → point to `scripts/merge-playwright-mcp.sh` + MCP-SETUP in qa-review skill
- Monorepo / unusual stack → hand-fill AGENTS.md rows the detector missed
- Re-setup on existing repo → safe; script is idempotent
