---
name: create-skill
description: >-
  Creates a team skill using the official Anthropic skill-creator eval loop
  (benchmark, subagent testing, description optimizer), with canonical storage
  in team repo and ship via /ship-skill. Use when the user invokes /create-skill,
  asks to create a new skill, or wants an org skill in Cursor and Claude Code.
  Do NOT use Cursor built-in skills-cursor/create-skill (no eval loop).
disable-model-invocation: true
---

# Create Skill (Team workflow)

> **Reply in Chinese.** Skill files stay in English.

## Cursor bootstrap (mandatory first turn)

Before any drafting:

```bash
cd ${SKILLS_ROOT}
./scripts/locate-skill-creator.sh
```

1. Read the printed **`SKILL_MD`** path in full — that is the official eval-loop engine.
2. **Never** read `~/.cursor/skills-cursor/create-skill/SKILL.md` for this workflow (style guide only, no eval/benchmark).
3. If locate fails → stop; tell user to enable **claude-plugins-official → skill-creator** in Cursor Plugins. See [references/SKILL-CREATOR-CURSOR.md](references/SKILL-CREATOR-CURSOR.md).

Claude Code: invoke the same plugin via Skill tool as `anthropic-skills:skill-creator`.

## Default engine = official `skill-creator`, unmodified

The quality process for building a skill is the **official Anthropic
`skill-creator` plugin** — the one with the eval loop, benchmarking, and
description optimizer. In Claude Code, invoke it via the Skill tool as
`anthropic-skills:skill-creator`.

**Do not confuse this with Cursor's own built-in `create-skill`**
(`~/.cursor/skills-cursor/create-skill/SKILL.md`) — that one is only an
authoring-style guide (frontmatter conventions, progressive disclosure); it
has no eval loop, no subagent testing, no benchmark.

Resolve the official plugin via team script (preferred over raw `find`):

```bash
cd ${SKILLS_ROOT} && ./scripts/locate-skill-creator.sh
```

Read the printed `SKILL_MD` and use `SCRIPTS=` / `EVAL_VIEWER=` paths from
output when running aggregate/viewer commands. If locate fails, tell the
user to enable the `skill-creator` plugin from the `claude-plugins-official`
marketplace in Cursor's plugin manager before continuing.

Run the **full loop** as documented in `skill-creator` — do not shortcut it:

1. Capture intent / interview (purpose, triggers, output format, edge cases)
2. Draft `SKILL.md`
3. Write 2-3 realistic test prompts, spawn with-skill + baseline subagents in parallel
4. Grade against assertions, aggregate a benchmark, do an analyst pass
5. Generate the eval viewer (`generate_review.py`) so the user reviews outputs qualitatively
6. Iterate based on feedback until the user is satisfied or feedback is empty
7. Optimize the trigger `description` (20 should/should-not-trigger queries, then the `run_loop.py` train/test optimization)

None of that changes. This team wrapper only bolts on **two things**: where
the files physically live, and how the finished skill gets published. Skip
the eval loop only if the user explicitly says so ("just vibe with me") —
same rule as the official skill.

## The only two adaptations

### Adaptation 1 — placement

Everywhere the official flow would create `skill-name/` (and its sibling
`skill-name-workspace/` for eval runs), root it at the team canonical path
instead of cwd or `/tmp`:

```
${SKILLS_ROOT}/.cursor/skills/<name>/            <- the skill itself
${SKILLS_ROOT}/.cursor/skills/<name>-workspace/   <- eval iterations, benchmarks, viewer output
```

| Never leave a real (non-symlink) copy here | Canonical |
|---------------------------------------------|-----------|
| `~/.cursor/skills/<name>/` | `${SKILLS_ROOT}/.cursor/skills/<name>/` |
| `~/.claude/skills/<name>/` | (same path — this is the single source of truth) |

**Expert vs utility skill** (decide this first, unrelated to placement):

| Type | Extra files | Use instead |
|------|--------------|-------------|
| Expert (org persona) | SOUL + SOURCES + EVALUATION | redirect to `/hire-expert`, don't use this skill |
| Utility / functional | `SKILL.md` only (+ optional `reference.md`, `scripts/`) | this skill, full official loop applies |

### Adaptation 2 — publishing replaces packaging

The official skill-creator ends with `scripts/package_skill.py` to produce a
distributable `.skill` file. Skip that (or keep it only if the user also
wants an external `.skill` export) — the team publishing step is the ship
gate instead:

```bash
cd ${SKILLS_ROOT}
./scripts/validate-skill.sh <name>   # frontmatter + four-piece structural check
./scripts/ship-skill.sh <name>       # symlinks ~/.cursor/skills + ~/.claude/skills, writes .shipped
```

or just say **`/ship-skill <name>`**. Draft period: before this runs, the
skill lives only in team with no `.shipped` marker and no global symlink —
that's expected, keep iterating with the official eval loop during this time.

Frontmatter conventions the validator checks:
- `name`: lowercase, hyphens, matches directory
- `description`: <= 1536 chars, third person, WHAT + WHEN + trigger terms
  (per official guidance: make it a little "pushy" so Claude doesn't under-trigger)
- Default `disable-model-invocation: true` unless ambient auto-invoke is intended
- Cursor's `AskQuestion` -> Claude Code's `AskUserQuestion` when a skill needs
  to run in both

After ship, edits to files under the team path sync automatically to both
global locations — no re-ship needed unless a symlink breaks.

### Confirm to user

```markdown
## Skill 已 ship: `<name>`

- **Canonical:** `${SKILLS_ROOT}/.cursor/skills/<name>/`
- **Cursor 全局:** `~/.cursor/skills/<name>` -> team
- **Claude 同步:** `~/.claude/skills/<name>` -> team
- **触发:** /<name>
- **质量验证:** [summary of eval loop results — pass rate, description optimization score, or "skipped per user request"]
- **后续编辑:** 改 team 内文件即可，无需 re-ship
```

## Importing skills created elsewhere

If the user already created a skill in Claude or Cursor (real directory, not symlink):

```bash
# From Claude
./scripts/publish-skill.sh --from-claude <name>

# From Cursor global (orphan copy)
./scripts/publish-skill.sh --from-cursor <name>

# From arbitrary path
./scripts/publish-skill.sh <name> --from /path/to/skill-dir
# Then ship:
./scripts/ship-skill.sh <name>
```

Existing real dirs are backed up before replacing with symlinks. If the
imported skill never went through the official eval loop, offer to run it
now (skill-creator's "Improving the skill" section works the same for
adopting an existing draft).

## Re-ship after structural changes

Edit files under `team/.cursor/skills/<name>/` only. Content edits sync via
symlink automatically.

Re-run ship only if:
- First-time publish (draft -> shipped)
- Global symlinks broken: `./scripts/ship-skill.sh <name>` or `./scripts/ship-skill.sh --all`
- Re-validation needed after frontmatter changes

## Anti-patterns

- Skipping the official eval loop for a functional/testable skill "to save time" — the loop is cheap (parallel subagents) and is what catches under/over-triggering before it ships
- Creating skill content only in `~/.cursor/skills/` or `~/.claude/skills/` directly — breaks sync, lost on reinstall
- Duplicating a team skill inside a product repo
- Skipping `/ship-skill` after create (draft stays invisible globally)
- Calling `publish-skill.sh` directly for brand-new skills (use `/ship-skill` for the validation gate)
