# Demo suffix — public-safe output mode

When the user appends **`demo`** to any slash command or skill name (e.g. `/help-skills demo`, `/boteam demo`, `help-skills demo`), switch to **Demo Output Mode**.

> **Not the same as `/demo`:** `/demo` (optional extra) records a product feature video. The **`demo` suffix** only changes how catalog/directory commands are formatted for screen recording or public sharing.

## Triggers

Match any of:

- `/help-skills demo`, `/boteam demo`, `/foo demo`
- `help-skills demo`, `boteam demo`
- "help-skills for demo video", "boteam demo output"

If **`demo`** appears as the second token (or clearly modifies the command), use Demo Output Mode. Otherwise use the skill's default language and format.

## Demo Output Mode rules

| Rule | Default mode | Demo mode |
|------|--------------|-----------|
| Language | Per skill (often English) | **English only** |
| Structure | Per skill | Clear headings, tables, department/function grouping |
| Personal paths | May include scan output | **Never** — no home-directory paths, iCloud paths, vault names |
| Usernames | May appear in paths | **Never** |
| Credentials | May mention env files | **Never** mention `.env`, API keys, tokens, cookie import details |
| HR scores | Exact decimals from ROSTER | **Omit scores**; status = `Active` only |
| Internal ops | execution logs, changelog detail | **Omit** org execution logs and internal changelog |
| Scan scripts | Run local scanners | **Do not run** — use static demo templates (scan stdout leaks paths) |
| Branding | Internal names OK | Use **"shared skill pack"**; say skills work in **Cursor and Claude Code** via global symlinks |
| Length | Complete | Complete roster/catalog, but no appendix noise |

## Safe placeholders (OK in demo output)

- `~/.cursor/skills/<name>/`
- `~/.claude/skills/<name>/`
- "workspace skills" (not vault/product-specific folder names)

## Opening line (catalog commands)

Start with one short paragraph:

> **Shared AI skill pack for Cursor and Claude Code.** One canonical definition per skill, installed globally on both tools. Invoke by slash command or by naming the skill in chat.

## Skills with demo templates

| Skill | Template location |
|-------|-------------------|
| `help-skills` | `help-skills/SKILL.md` → § Demo output |
| `boteam` | `boteam/SKILL.md` → § Demo output |

Other catalog skills should follow this file until they define their own § Demo output section.
