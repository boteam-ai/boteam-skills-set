# AGENTS.md

Context for AI agents working in this repo. Read this before implementing anything.
See `evidence-before-done.mdc` and `context-before-code.mdc` in `.cursor/rules/` for the
rules that reference this file.

## Project Context

<!-- Auto-generated/updated by scripts/init-project-context.sh. Safe to hand-edit — the
     script only fills in blank rows, it never overwrites a non-empty value. -->

| Item | Value |
|------|-------|
| Runtime | _(unset)_ |
| Package manager | _(unset)_ |
| Test command | _(unset)_ |
| Build command | _(unset)_ |
| Lint / typecheck command | _(unset)_ |
| Env config | _(unset)_ |

## Known Footguns

<!-- Append-only. Only add an entry here if the root cause is systemic (environment,
     dependency, framework quirk) — not a one-off typo or a plain application bug.
     See qa-review/SKILL.md step 6 for the write-back decision gate. -->

| Date | Symptom | Root cause | How to avoid |
|------|---------|-----------|---------------|
| _(none yet)_ | | | |

## Definition of Done

Do not claim a task is "done", "ready", or "QA passed" without evidence. Follow this loop:

1. **Implement** — write the change. Do not self-declare QA complete in the same turn.
2. **Verify** — run `/qa-review` (or the project's test/build/lint commands directly) and
   paste the actual output. Status must be `DONE` or `BLOCKED`, never a bare "looks good".
3. **Fix** — if `BLOCKED`, fix only what was reported, then re-run verification.

For deeper checks, hand off instead of reinventing them here:

- Static code review → `/review-bugbot`
- Security-sensitive changes (auth, secrets, DB) → `/review-security`
- Full browser QA + fix loop → `/qa` (gstack)
- Report-only browser QA → `/qa-only` (gstack)

## Optional: cross-model review

For high-stakes changes, manually paste the `/qa-review` findings + evidence into a
different model/provider with a fixed prompt: *"Assume this is broken. Find runtime
failures only. Output an issue list, do not write code."* This is a manual step, not
automated — different models have different blind spots.
