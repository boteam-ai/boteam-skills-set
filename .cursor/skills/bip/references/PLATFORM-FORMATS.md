# Platform formats — `/bip`

Defaults and constraints for each platform. Draft in English unless user requests otherwise.

---

## X (`x` / `twitter`)

| Format | Default when | Constraints |
|--------|----------------|-------------|
| **post** | `/bip x` | ≤280 chars; hook in first line; 0–2 hashtags max; link at end |
| **thread** | `/bip x, thread` | 3–8 tweets; `T1:` … `Tn:`; T1 = hook; last tweet = soft CTA or question (no "follow for more") |
| **long article** | `/bip x, long article` or `article` | 800–2500 words; `##` headers; opening paragraph = standalone hook; include 1 concrete code/snippet reference if relevant |

### X post skeleton

```text
{hook — what shipped or what broke}

{1–2 sentences: what you did + one lesson}

{optional: metric or timeframe}

{link or "more in thread"}
```

### X thread skeleton

```text
T1: {hook — result or contrarian take}

T2: Context — what you were trying to do

T3–T5: What happened (build steps, bug, fix) — one idea per tweet

T6: Lesson another builder can steal

T7: What's next / question to audience
```

### X long article skeleton

```markdown
# {Title — specific, not "My Journey Building X"}

{Opening: 2–3 sentences — the outcome or surprise}

## What I set out to do
…

## What actually happened
…

## The bug / decision / tradeoff
…

## What I'd do again (and what I wouldn't)
…

## Numbers (if any)
…

## What's next
…
```

**Voice:** Pieter Levels / Marc Lou — short paragraphs, numbers when real, no corporate tone.

---

## LinkedIn (`linkedin`)

| Format | Default when | Constraints |
|--------|----------------|-------------|
| **post** | `/bip linkedin` | 150–1300 chars sweet spot; line breaks every 1–2 sentences; optional `→` bullets for lessons |
| **article** | `/bip linkedin, article` | 600–1500 words; professional but personal; first line visible before "see more" must hook |

### LinkedIn post skeleton

```text
{hook line — visible before fold}

{story: problem → action → result}

What I learned:
→ {lesson 1}
→ {lesson 2}

{question or invitation to comment}
```

**Voice:** Justin Welsh — value-first, skimmable, no hashtag spam (3 max at bottom).

---

## Threads (`threads`)

| Format | Default | Constraints |
|--------|---------|-------------|
| **post** | default | ≤500 chars; casual; 1 emoji max if any |
| **thread** | `thread` | Similar to X but slightly longer per post; conversational |

---

## Mastodon (`mastodon`)

| Format | Default | Constraints |
|--------|---------|-------------|
| **post** | default | ≤500 chars (instance-dependent); content warning if discussing failures involving third parties |

---

## Ship log (`ship-log`)

Markdown for README, changelog, or newsletter paste — no character limit.

```markdown
## Ship log — {YYYY-MM-DD}

### Shipped
- …

### Learned
- …

### Broken / fixed
- …

### Next
- …
```

Use when user wants internal documentation or email newsletter raw material, not a social post.

---

## Format selection guide

| User intent | Invoke |
|-------------|--------|
| Quick daily update | `/bip` or `/bip x` |
| Story with nuance | `/bip x, thread` |
| Deep dive / SEO on X | `/bip x, long article` |
| Professional network | `/bip linkedin` |
| Document for self | `/bip ship-log` |
| Emphasize failures/lessons | add `, focusing on lessons learned and …` |

---

## Anti-patterns (all platforms)

- Cross-posting identical copy (adapt per platform)
- "Excited to announce" / "game-changer" / "thrilled"
- Vague "making great progress"
- Invented metrics or fake timelines
- Hashtag clouds (#buildinpublic #startup #ai …)
- Ending with "What do you think?" as pure engagement bait without a real question
- **Banned AI voice patterns** (see `/bip` SKILL §2): e.g. "The … is real", "It's not …, it's …", "The hard part was never …", "The real X is …", "The honest truth", "X turned Y into …", and similar pseudo-profound / quote-generator lines
