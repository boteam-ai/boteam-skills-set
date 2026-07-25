# /create-skill — Team skill creation (official skill-creator + SSOT)

Create a new team skill using the **Anthropic official skill-creator eval loop**, then publish via SSOT when ready.

用法：`/create-skill` 或 `/create-skill <skill-name>`

## 执行流程（不可跳步）

1. Read [`.cursor/skills/create-skill/SKILL.md`](../skills/create-skill/SKILL.md) — team wrapper (placement + ship).
2. Run `./scripts/locate-skill-creator.sh` from team repo root.
   - **成功** → Read the printed `SKILL_MD` path in full. That is the eval-loop engine.
   - **失败** → 停止。告诉用户在 Cursor Plugin 里启用 `claude-plugins-official` → `skill-creator`。不要用 `~/.cursor/skills-cursor/create-skill/`。
3. Follow the **full official loop** (draft → test prompts → subagent eval → benchmark → viewer → iterate → description optimize).
4. Root skill + workspace at team paths only:
   - `${SKILLS_ROOT}/.cursor/skills/<name>/`
   - `${SKILLS_ROOT}/.cursor/skills/<name>-workspace/`
5. When user is satisfied → **`/ship-skill <name>`** (do not auto-ship during draft).

## 禁止

- ❌ `~/.cursor/skills-cursor/create-skill/` — 无 eval 循环
- ❌ 直接写 `~/.cursor/skills/` 或 `~/.claude/skills/` 真实目录
- ❌ 跳过 eval 直接 ship（除非用户明确说 "just vibe with me"）

## 参考

- [SKILL-CREATOR-CURSOR.md](../skills/create-skill/references/SKILL-CREATOR-CURSOR.md)
- [ship-skill.md](./ship-skill.md)
