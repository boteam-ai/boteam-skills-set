# /boteam — Expert team directory

Output the **full expert team roster and division of labor**.

## Default mode

**Reply in English** unless the user asks for Chinese.

1. Load and follow `.cursor/skills/boteam/SKILL.md` default output format.
2. Read `hr/ROSTER.md` for latest status and scores; read `README.md` for team bundles if needed.
3. Output all five layers + team summons + org commands — do not omit any active expert.

If the user asks a specific routing question (e.g. "who for GTM?"), add **≤3 lines** of recommendation after the directory.

## Demo mode (`/boteam demo`)

When the user appends **`demo`**:

1. Read [`.cursor/references/DEMO-SUFFIX.md`](../references/DEMO-SUFFIX.md).
2. Follow `boteam/SKILL.md` **§ Demo output** — **English only**, grouped by department, **redacted** (no paths, no scores, no internal ops logs).
3. Safe for screen recording and public sharing.
