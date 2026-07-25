# skill-creator on Cursor — resolution guide

Team `/create-skill` uses the **Anthropic official `skill-creator` plugin** (eval loop, benchmark, description optimizer). It is **not** Cursor's built-in authoring guide.

## Two different things in Cursor

| Path | What it is | Eval loop? |
|------|------------|------------|
| `~/.cursor/skills-cursor/create-skill/SKILL.md` | Cursor built-in style guide | **No** — do not use for team skill creation |
| `~/.cursor/plugins/.../skill-creator/skills/skill-creator/SKILL.md` | Anthropic official plugin (cached) | **Yes** — this is the engine |

## Resolve paths (run from team repo)

```bash
cd ${SKILLS_ROOT}
./scripts/locate-skill-creator.sh
```

Example output:

```
SKILL_MD=/Users/.../.cursor/plugins/.../skill-creator/skills/skill-creator/SKILL.md
PLUGIN_ROOT=...
SCRIPTS=.../scripts
EVAL_VIEWER=.../eval-viewer/generate_review.py
```

**First action in every `/create-skill` session:** run the script, read `SKILL_MD` in full, follow that loop. Then apply team adaptations from [`../SKILL.md`](../SKILL.md) (canonical path + `/ship-skill`).

## Enable the plugin (if locate fails)

1. Cursor → **Plugins** (or Settings → Plugins)
2. Marketplace: **claude-plugins-official** (Anthropic)
3. Enable **skill-creator**
4. Re-run `./scripts/locate-skill-creator.sh`

## Verify the eval loop ran

After creating a test skill, confirm the workspace exists:

```
${SKILLS_ROOT}/.cursor/skills/<name>-workspace/
  iteration-1/
    evals/
    benchmark.json
    feedback.json   (after user review)
```

If only `SKILL.md` exists with no `-workspace/`, the agent likely used the wrong guide — restart with `/create-skill` and explicit locate step.

## Claude Code equivalent

Claude Code invokes the same plugin as `anthropic-skills:skill-creator` via the Skill tool. Team placement and ship gate are identical; only the invoke path differs.
