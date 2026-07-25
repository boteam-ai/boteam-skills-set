---
name: qa-review
description: >-
  Independent, read-only QA verification. Launches a separate subagent that runs
  the project's real lint/test/build/typecheck commands (and an optional Playwright
  MCP browser smoke for UI changes) and reports STATUS: DONE or BLOCKED with pasted
  command evidence — it never fixes code. Use after implementing a feature or fix,
  before claiming something is ready, or when the user invokes /qa-review, asks to
  verify, or asks for an evidence check. Do not use for a full interactive browser
  QA + fix loop (use gstack /qa) or for security-focused review (use /review-security).
disable-model-invocation: true
---

# QA Review (independent verification subagent)

> Deep reference: [references/VERIFY-CHECKLIST.md](references/VERIFY-CHECKLIST.md)
> MCP setup: [references/MCP-SETUP.md](references/MCP-SETUP.md)

## Why this exists

The same agent that just wrote code cannot objectively grade it — it lacks a fresh
perspective and has no reason to distrust its own output. This skill delegates
verification to a **separate, read-only subagent** that runs real commands instead of
self-declaring readiness. See `evidence-before-done.mdc` for the reporting contract this
skill fulfills.

## Not a replacement for

| Need | Use instead |
|------|-------------|
| Static code review of the diff | `/review-bugbot` |
| Security-sensitive changes (auth, secrets, DB) | `/review-security` |
| Full interactive browser QA + fix loop | gstack `/qa` |
| Report-only deep browser QA | gstack `/qa-only` |

`qa-review` is deliberately lightweight: lint/test/build/typecheck + an optional UI smoke.
It is the fast, default gate — not a substitute for the deeper tools above.

## Workflow

### 1. Resolve scope

Default to `branch changes` (diff against the repo's default branch). If the user says
"uncommitted", "working tree", or similar, use `uncommitted changes` instead.

### 2. Detect verification commands

Read [references/VERIFY-CHECKLIST.md](references/VERIFY-CHECKLIST.md) for the detection
matrix (per-language default commands). Prefer, in order:

1. Commands already recorded in the repo's `AGENTS.md` Project Context table, if present.
2. Auto-detected from the manifest (`package.json` scripts, `pyproject.toml`, `go.mod`, etc.).

If neither yields anything runnable, do not guess — report `STATUS: NEEDS_CONTEXT` and
list exactly which commands you need the user to provide.

### 3. Launch the QA subagent (read-only, single instance)

Launch exactly one subagent with:

- `subagent_type: generalPurpose`
- `readonly: true` (Cursor Task tool; Claude Code has no `readonly` flag — state the read-only constraint in the prompt below instead)
- `run_in_background: false` unless the user explicitly asks for background
- `description: "QA Review"`

Prompt shape:

```text
Full Repository Path: <absolute repository path>
Diff: branch changes | uncommitted changes
Scope: <affected files from the diff, if useful context>

Assume this is broken. Your job is to disprove readiness, not confirm it.
Run each command below in order. For each, paste the exit code and the last 20 lines
of output. Do not skip a command because an earlier one failed — run all of them.

Commands:
<the resolved list from step 2>

If UI-relevant files changed (components, routes, styles) and a Playwright MCP or
cursor-ide-browser MCP tool is available, navigate to the affected page(s), check the
console for errors, and take a screenshot. Read the MCP tool's schema before the first
call. If no browser MCP is available, state that the browser smoke was skipped and why.
(Claude Code: prefer Playwright MCP; `cursor-ide-browser` is Cursor-only.)

Do not edit any files. Do not fix anything you find. Do not run destructive commands.

Output ONLY in this format:
STATUS: DONE | BLOCKED | NEEDS_CONTEXT
Evidence:
  <command>: exit <code>
  <last 20 lines>
  ... (repeat per command)
Findings:
  | Severity | Location (file:line) | Finding |
  |----------|----------------------|---------|
```

### 4. Summarize, do not fix

Report the subagent's `STATUS` and findings table to the user as-is. Do not
automatically fix anything — that is the next Implement turn's job, not this one.

### 5. Write back to Known Footguns (only if systemic)

If `STATUS: BLOCKED`, classify each finding's root cause using the same gate as
[`lesson/SKILL.md`](../lesson/SKILL.md):

| Root cause | Action |
|------------|--------|
| One-off typo / trivial mistake | Do not write to Known Footguns |
| An existing convention was ignored | Point it out; suggest strengthening the existing `AGENTS.md` entry instead of adding a new one |
| Systemic environment/dependency/framework quirk | Append one row to the project's `AGENTS.md` Known Footguns table |
| Application logic bug | Fix the code / add a regression test — this is not a Known Footguns entry |

Only the third category gets written. This keeps `AGENTS.md` from bloating and ensures
the next `context-before-code.mdc`-triggered implement turn actually benefits from it.

### 6. Optional escalation (suggest, do not auto-run)

- Diff touches auth/secrets/DB → suggest `/review-security`
- User wants a full browser regression pass → suggest gstack `/qa` or `/qa-only`
- High-stakes change → suggest pasting this skill's `Evidence` + `Findings` into a
  different model/provider with the fixed prompt: *"Assume this is broken. Find
  runtime failures only. Output an issue list, do not write code."* This is a manual
  step — do not automate cross-provider calls.

## Rules

1. Never report `STATUS: DONE` unless every resolved command was actually run.
2. Never let the QA subagent edit files, install packages, or run destructive commands.
3. One QA subagent per `/qa-review` invocation — do not fan out multiple in parallel.
4. If the subagent's diff computation fails, retry once per the same pattern as
   `review-bugbot`/`review-security` (natural-language diff description as fallback).
5. Never fabricate a browser smoke result — if no browser MCP is configured, say so.
