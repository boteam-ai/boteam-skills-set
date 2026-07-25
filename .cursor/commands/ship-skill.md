# /ship-skill — Ship skill to global Cursor + Claude (SSOT)

Validate a team skill and publish it globally via symlinks. Canonical copy stays in `team/.cursor/skills/<name>/`; global dirs are links only.

用法：`/ship-skill <skill-name>` 或 `/ship-skill`（从当前编辑的 skill 目录推断）

## 执行流程

1. Read [`.cursor/skills/ship-skill/SKILL.md`](../skills/ship-skill/SKILL.md) and follow it.
2. Resolve skill name from argument or context.
3. Run `./scripts/validate-skill.sh <name>` — if blocked, report failures and stop.
4. Run `./scripts/ship-skill.sh <name>`.
5. Reply in Chinese with ship report (canonical path, Cursor + Claude links, invoke hint).

## 批量 / 恢复

- `./scripts/ship-skill.sh --all` — ship all skills missing `.shipped` or broken links
- `./scripts/install-team-skills.sh --global --shipped-only` — relink shipped skills on new machine

## 与 create-skill 的关系

新建 skill 后先在 team 内测试；**不要**自动 publish。用户确认后再 `/ship-skill <name>`。
