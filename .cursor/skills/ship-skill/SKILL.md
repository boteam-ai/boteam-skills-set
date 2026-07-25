---
name: ship-skill
description: >-
  Ship a team skill to global Cursor and Claude after validation. Validates
  SKILL.md frontmatter, creates global symlinks, and marks .shipped. Use with
  /ship-skill, "ship this skill", "publish skill to global", or after finishing
  a skill in team/.cursor/skills/. Does not copy files — symlinks only (SSOT).
disable-model-invocation: true
---

# Ship Skill (SSOT publish)

> **Reply in Chinese.** Skill files stay in English.

## Purpose

**Single source of truth** = `${SKILLS_ROOT}/.cursor/skills/<name>/`. Global dirs are **symlinks only**:

| Path | Role |
|------|------|
| `team/.cursor/skills/<name>/` | Canonical — edit here |
| `~/.cursor/skills/<name>` | Cursor global symlink → team |
| `~/.claude/skills/<name>` | Claude Code global symlink → team |

**Draft** = canonical exists, no `.shipped`, no global link.  
**Shipped** = `.shipped` + both global symlinks.

After ship, edits in team sync automatically — re-ship only for broken links or re-validation.

## Workflow

```
1. Resolve skill name → 2. Confirm canonical in team → 3. validate-skill.sh → 4. ship-skill.sh → 5. Report
```

### 1. Resolve skill name

- From user arg: `/ship-skill my-skill` → `my-skill`
- From context: directory being edited under `team/.cursor/skills/<name>/`
- If ambiguous, ask (Cursor: `AskQuestion`; Claude Code: `AskUserQuestion`)

### 2. Confirm canonical location

**Never ship from orphan copies.** Canonical must be:

```
${SKILLS_ROOT}/.cursor/skills/<name>/SKILL.md
```

If skill only exists in `~/.cursor/skills/` or `~/.claude/skills/` as a real directory (not symlink), redirect:

```bash
./scripts/publish-skill.sh --from-cursor <name>
# or
./scripts/publish-skill.sh --from-claude <name>
```

Then run ship.

### 3. Validate

```bash
cd ${SKILLS_ROOT}
./scripts/validate-skill.sh <name>
```

If exit non-zero → report **BLOCKED** with failures; do not ship.

### 4. Ship

```bash
./scripts/ship-skill.sh <name>
```

This runs validate again, `publish-skill.sh`, touches `.shipped`, verifies both global symlinks.

Bulk / recovery:

```bash
./scripts/ship-skill.sh --all              # ship unshipped or broken-link skills
./scripts/install-team-skills.sh --global --shipped-only  # new machine: link shipped only
```

### 5. Report to user

```markdown
## Skill 已 ship: `<name>`

- **Canonical:** `${SKILLS_ROOT}/.cursor/skills/<name>/`
- **Cursor 全局:** `~/.cursor/skills/<name>` → team
- **Claude 全局:** `~/.claude/skills/<name>` → team
- **触发:** /<name>
- **后续编辑:** 直接改 team 内文件即可同步，无需 re-ship
```

## Relationship to other tools

| Tool | When |
|------|------|
| `/create-skill` | Write canonical; **do not** auto-ship — user runs `/ship-skill` when ready |
| `/hire-expert` | Four-piece expert; ship as final step |
| `publish-skill.sh` | Low-level linker + import orphan; prefer `/ship-skill` for gated publish |
| `install-team-skills.sh --global` | Bulk recovery; use `--shipped-only` to respect draft skills |

## Anti-patterns

- ❌ Copying skill files into `~/.cursor/skills/` (breaks SSOT)
- ❌ Shipping before validation passes
- ❌ Editing global symlink target paths instead of team canonical
- ❌ Re-shipping after every edit (symlinks propagate changes)
