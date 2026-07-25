---
name: bip
description: >-
  Build in Public: summarize recent coding and product progress from the current
  chat context, extract shareable lessons, and draft platform-native posts.
  Supports time windows (24hr, 7d), platforms (X, LinkedIn, Threads), and formats
  (post, thread, long article). Runs humanizer pass before delivery. Use when the
  user invokes /bip, asks to build in public, ship log, or share progress on social.
disable-model-invocation: true
---

# Build in Public (`/bip`)

> **Reply to the user in English.** Skill files and draft post copy stay in English unless the user asks otherwise.

Turn **this conversation's** coding and shipping work into authentic, platform-native Build in Public content. Always finish with a **humanizer pass** (bundled step — see §6).

## Invocation syntax

```
/bip
/bip 24hr
/bip x
/bip x, thread
/bip x, long article
/bip linkedin
/bip 48hr x, post, focusing on auth bugs and what we learned
/bip week linkedin, article
```

### Argument parsing (order-flexible)

| Token type | Examples | Default |
|------------|----------|---------|
| **Time window** | `24hr`, `48hr`, `12h`, `7d`, `week`, `today`, `session` | `session` (full current chat) |
| **Platform** | `x`, `twitter`, `linkedin`, `threads`, `mastodon`, `ship-log` | `x` |
| **Format** | `post`, `thread`, `long article`, `article`, `carousel`, `short` | platform default (see [references/PLATFORM-FORMATS.md](references/PLATFORM-FORMATS.md)) |
| **Focus** | text after `focusing on`, `about`, or trailing comma clause | none — infer from context |

**Rules:**
- Comma-separated segments are fine: `/bip x, long article, focusing on lessons from the refactor`
- Platform aliases: `twitter` → `x`; `long article` / `article` on X → X Article (long-form)
- If only a time window is given (`/bip 24hr`), use default platform `x` + format `post`
- If only platform is given (`/bip linkedin`), use default format for that platform

---

## Workflow

```
- [ ] 1. Parse invocation → time, platform, format, focus
- [ ] 2. Mine conversation context for the time window
- [ ] 3. Extract BIP material (§3)
- [ ] 4. Draft platform-native copy (§4 + PLATFORM-FORMATS.md)
- [ ] 5. Humanizer pass — mandatory (§6)
- [ ] 6. Deliver final output (§7)
```

---

## 1. Context mining

Scan **this chat** (and attached files / diffs referenced in it) for the requested window.

**Include:**
- Features shipped, partially shipped, or explicitly attempted
- Files/modules touched and why
- Bugs found and fixes (especially non-obvious ones)
- Decisions made (and what you rejected)
- Blockers still open
- Metrics or before/after if mentioned (latency, test count, LOC — only if real)
- User-visible outcomes ("users can now…")

**Exclude:**
- Generic AI assistant meta ("I'll help you with…")
- Speculation not grounded in this thread
- Fake metrics or invented timelines
- Internal tool/skill names unless the user builds in public about their stack

**Time window heuristics:**
- `session` — entire conversation
- `24hr` / `48hr` / `7d` — prioritize messages and work that plausibly fall in that window; if timestamps are unavailable, use the **most recent contiguous arc** of coding work and say so in the meta line
- `today` — same calendar day as user_info date when available

If context is thin, say so honestly and draft a **short honest update** instead of padding.

---

## 2. BIP principles (voice)

Distilled from Levels, Lou, Welsh, and team `/social-media-manager`:

| Principle | In practice |
|-----------|-------------|
| **Show the work** | Name what you built or tried, not "made progress" |
| **One real lesson** | Each post should teach something another builder can use |
| **Numbers when true** | Ship counts, timing, error rates — never invent |
| **Failure is content** | What broke and what you'd do differently |
| **No performative hustle** | Skip "exciting journey" / "game-changer" / "thrilled to announce" |
| **Audience = builders** | Assume readers ship software; respect their time |

Default voice: first-person founder/builder, concrete, slightly opinionated.

### Banned AI voice patterns (hard block)

These are typical LLM tells. **Never use them** in any option, highlight, hook, or final copy — including alternate hooks.

| Pattern | Example (do not write) |
|---------|-------------------------|
| **"The … is real"** | "the struggle is real", "the speed is real" |
| **"It's not …, it's …"** | "It's not about features, it's about focus" |
| **"X turned Y into …"** | "AI turned my backlog into a roadmap" |
| **"The hard part was never … It was …"** | "The hard part was never coding. It was deciding." |
| **"The real X is …"** | "The real bottleneck is thinking" |
| **"The honest truth"** | "The honest truth is…" (fake-sincerity opener) |

Also avoid close cousins: pseudo-profound reversals, fake sincerity, forced contrast pairs, and quote-generator one-liners. Say what happened in plain words. If a line could sit on a motivational poster, cut it.

**Self-check before delivery:** scan every tweet/post for the table above and rewrite any hit.

---

## 3. Extraction checklist

Before drafting, produce an internal brief (shown in output §7 as **Context summary**):

```markdown
### Shipped / attempted
- …

### Problems hit
- …

### Lessons (shareable)
- …

### Still open
- …

### Hook candidates (pick 1)
- …
```

Pick **one primary hook** — contrarian, result, or "here's what broke."

---

## 4. Platform drafting

Read [references/PLATFORM-FORMATS.md](references/PLATFORM-FORMATS.md) for limits, structure, and examples.

**Cross-cutting rules:**
- English copy for X / LinkedIn / Threads unless user requests Chinese
- Preserve links and @handles from context
- Thread: number tweets T1/T2/…; each ≤280 chars
- X long article: markdown with `##` sections, 800–2500 words, scannable headers
- LinkedIn: line breaks between short paragraphs; optional bullet block for lessons
- `ship-log`: markdown file suitable for README changelog or newsletter paste

Do **not** publish — deliver copy only. User runs `/publish-x` or posts manually.

---

## 5. Humanizer pass (mandatory)

**Before showing the user the final post**, run the bundled de-AI step:

1. Read `~/.claude/skills/humanizer/SKILL.md` (or `~/.cursor/skills/humanizer/SKILL.md` if Claude path missing).
2. Apply its process to the draft:
   - Remove AI vocabulary, significance inflation, rule-of-three, em-dash spam, chatbot artifacts
   - Enforce **Banned AI voice patterns** (§2) — zero tolerance in options and final copy
   - Add voice: opinions, varied rhythm, specific details from this thread
   - Run the two-step audit: "What makes this obviously AI generated?" → revise → final
3. **Platform tune after humanize:**
   - X: shorter sentences, hook in line 1, no LinkedIn-style sign-off
   - LinkedIn: keep paragraph breaks; trim thread-style numbering
   - Long article: keep headers; remove tutorial signposting ("Let's dive in")

If humanizer skill is unreachable, still run a manual pass using the same pattern list (see humanizer §CONTENT/LANGUAGE/STYLE patterns).

**Never skip this step.** The user-facing deliverable is the **humanized final**, not the first draft.

---

## 7. Output format (English)

Reply in English. Structure:

```markdown
## BIP Summary

**Window:** {time} · **Platform:** {platform} · **Format:** {format}
{optional: note how the time window was inferred}

### Context summary
{brief from §3}

### Publish copy (final · humanized)

{platform-native English copy — ready to paste}

---

**Alternate hook:** {1 alternate opening line}

**Suggested media:** {screenshot, demo GIF, diff stat — or "none needed"}

**Next steps:** Publish as-is · `/publish-x` (if DailyX draft exists) · re-run `/bip …` with a different focus
```

For **thread** format, show numbered tweets inside the 发布文案 block.
For **long article**, use a collapsible-style header `### X Article draft` then full markdown body.

---

## Hand-offs

| Need | Skill |
|------|-------|
| Social strategy / calendar | `/social-media-manager` |
| Copy polish only (no BIP mining) | `/copywriter` |
| Publish DailyX draft to X API | `/publish-x` |
| Weekly signal article | `/daily-newsletter-article` |

## Provenance

See [SOURCES.md](SOURCES.md). Thought leaders: Pieter Levels, Marc Lou, Justin Welsh, Dan Koe (build-in-public / audience-first).
