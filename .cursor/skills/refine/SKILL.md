---
name: refine
description: >-
  Refines vague or unclear user prompts into precise, actionable Claude Code
  instructions following best practices. Use when the user invokes /refine,
  asks to "refine this prompt", "clarify my request", "make this clearer", or
  has a rough idea they want turned into a well-structured task for Claude Code.
disable-model-invocation: true
---

# Refine — Prompt Clarity Skill

Turns a vague user intent into a precise, well-structured Claude Code prompt, then executes it.

## Workflow

```
1. Read context → 2. Understand intent → 3. Ask clarifying questions (if needed) → 4. Output refined prompt → 5. Execute
```

---

## Step 1 — Read context

Before asking anything, silently absorb:
- The current file(s) open or recently edited
- Recent conversation history
- The project's CLAUDE.md rules and constraints
- Any error messages, test output, or git state visible

Never ask something the context already answers.

## Step 2 — Understand intent

Identify:
- **Goal** — what outcome does the user want?
- **Scope** — which files, components, or systems are in play?
- **Constraints** — any rules from CLAUDE.md, existing patterns to follow?
- **Ambiguities** — what's unclear that would meaningfully change the approach?

## Step 3 — Clarify (only if needed)

If ambiguities remain after reading context, ask **one focused question per unknown** — no more than 3 questions total. Group them in a single message. Format:

```
Before I refine this, a few quick questions:

1. [Specific question about scope/goal]
2. [Specific question about constraint or preference]
```

Do NOT ask questions whose answers don't change the refined output. Do NOT ask for information already visible in context.

## Step 4 — Output refined prompt

Once intent is confirmed, produce the refined prompt in a clearly labeled block:

```
---
REFINED PROMPT

[The improved prompt — written as a direct instruction to Claude Code]

Context:
- [Relevant file or component]
- [Relevant constraint or rule]

Acceptance criteria:
- [ ] [Specific, verifiable outcome 1]
- [ ] [Specific, verifiable outcome 2]
---
```

### Refinement principles (Claude Code best practices)

- **Specific over vague.** Name exact files, functions, components, routes.
- **One task, one prompt.** Split compound requests into sequential steps.
- **State the constraint up front.** Reference CLAUDE.md rules that apply.
- **Define done.** Include 2–4 acceptance criteria so Claude knows when to stop.
- **Avoid meta-instructions.** Don't say "be careful" — say what specifically to watch out for.
- **Scope guard.** Explicitly state what NOT to change if there's risk of drift.
- **Evidence over adjectives.** Replace "clean" / "nice" with measurable outcomes.

## Step 5 — Execute

After presenting the refined prompt, immediately execute it. Do not wait for the user to copy-paste it back. Say:

```
Executing the refined prompt now...
```

Then proceed with the task as instructed by the refined prompt.

---

## Examples

### Before refinement
> "make the homepage better"

### After refinement
```
---
REFINED PROMPT

Improve the visual hierarchy on the homepage hero section (src/app/page.tsx).

Context:
- Design tokens in src/styles/tokens/
- Components in src/components/ds/
- CLAUDE.md rule: no new colors or fonts; one accent (--rust-500)

Acceptance criteria:
- [ ] Headline uses Newsreader serif at the correct token weight
- [ ] Kicker follows // prefix convention in UPPERCASE mono
- [ ] No inline styles or hardcoded hex values introduced
- [ ] Layout stays responsive at 320 / 768 / 1120px
---
```

---

### Before refinement
> "fix the bug"

### After refinement (after asking which bug):
```
---
REFINED PROMPT

Fix the TypeError thrown when submitting the contact form with an empty email field (src/app/contact/page.tsx, line ~84).

Context:
- Form uses controlled inputs with React state
- Validation currently only runs on the server side

Acceptance criteria:
- [ ] Client-side validation prevents submission when email is empty
- [ ] Error message uses the existing Callout component (src/components/ds/Callout.tsx)
- [ ] No changes to server action or other form fields
---
```
