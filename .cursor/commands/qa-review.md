# /qa-review — Independent QA verification

Runs an independent, read-only QA subagent that executes the project's real
lint/test/build/typecheck commands (and an optional browser smoke for UI changes),
then reports `STATUS: DONE` or `STATUS: BLOCKED` with pasted command evidence.
It never fixes code — that stays with the implement turn.

## Usage

```
/qa-review
/qa-review uncommitted
/qa-review --browser
```

- No argument → branch changes against the default branch (most common case after
  implementing on a feature branch).
- `uncommitted` → verify only the working-tree diff instead.
- `--browser` → force a Playwright MCP / cursor-ide-browser MCP smoke even if the diff
  doesn't obviously touch UI files.

## Execution

1. Load [`.cursor/skills/qa-review/SKILL.md`](../skills/qa-review/SKILL.md).
2. Resolve scope and verification commands (see the skill's step 1-2).
3. Launch exactly one read-only `generalPurpose` subagent per the skill's prompt shape.
4. Report the subagent's `STATUS`, evidence, and findings table to the user in Chinese.
5. If `STATUS: BLOCKED` and a finding is systemic, follow the skill's step 5 to decide
   whether to append a Known Footguns row to the project's `AGENTS.md`.

## Prerequisites

- The project should have runnable test/lint/build commands (Node/Python/Go/Rust/etc.).
- For `--browser` or UI-touching diffs: Playwright MCP configured globally — see
  [`.cursor/skills/qa-review/references/MCP-SETUP.md`](../skills/qa-review/references/MCP-SETUP.md) —
  or `cursor-ide-browser` MCP enabled as a fallback.

## Do not

- Do not fix findings in this command — hand off to the next implement turn.
- Do not report `STATUS: DONE` unless the subagent actually ran every resolved command.
- Do not run this as the same turn that wrote the code — it must be a separate invocation.
