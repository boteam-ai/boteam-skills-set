# /headline — 标题生成

从故事/raw facts 生成标题候选：新闻标题、通稿标题、pitch subject line、feature headline。

## Usage

```
/headline
/headline <paste story facts or context>
/headline press release for product launch — <facts>
/headline subject lines only — <facts>
```

| 输入 | 说明 |
|------|------|
| 无参 | 从当前对话提取素材 |
| 故事事实 | 直接粘贴数据、人物、变化、数字 |
| 格式限定 | 如 `press release`、`subject lines only`、`news-style` |

## Execution

1. Load [`.cursor/skills/headline/SKILL.md`](../skills/headline/SKILL.md).
2. Run Steps 1–5: materials → charge → moves → sprint → tighten.
3. Reply in **English**; headline candidates in **English** (unless user asks otherwise).

## Related

- `/copywriter` — 压测与终稿润色
- `/content-seo-strategist` — SEO 标题变体
- `/bip` — 发布文案 hook
