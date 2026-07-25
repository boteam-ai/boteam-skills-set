# /bip — Build in Public

Summarize **recent coding and product progress from this chat**, extract shareable lessons, and draft **platform-native posts**. Always runs **humanizer** before delivery.

## Usage

```
/bip
/bip 24hr
/bip x
/bip x, thread
/bip x, long article
/bip linkedin
/bip 48hr x, post, focusing on auth bugs and what we learned
```

| Argument | Examples | Default |
|----------|----------|---------|
| Time | `24hr`, `48hr`, `7d`, `week`, `session` | `session` |
| Platform | `x`, `linkedin`, `threads`, `mastodon`, `ship-log` | `x` |
| Format | `post`, `thread`, `long article`, `article` | platform default |
| Focus | `focusing on …` | inferred from context |

## Execution

1. Load [`.cursor/skills/bip/SKILL.md`](../skills/bip/SKILL.md).
2. Parse user args → mine conversation → draft → **humanizer pass** → deliver.
3. Reply in **English**; post copy in **English** (unless user asks otherwise).

## Related

- `/social-media-manager` — strategy and calendar
- `/headline` — hook options
- `/copywriter` — polish only
