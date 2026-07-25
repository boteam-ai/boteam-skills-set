---
name: source-skill
description: Authoritative source registry for the one-person-company expert team. Lists validated open-source repos (URL, stars, license), thought leaders, and per-expert provenance. Use when the user types /source-skill or asks where skills come from, citations, attribution, or which GitHub repos and experts back each team member.
disable-model-invocation: true
---

# Source Skill (权威来源注册表)

> **Reply to the user in Chinese (中文).** This file stays in English.

When invoked, output the team's **authoritative sources**: open-source repos, licenses, thought leaders, and which expert each source backs.

## Primary data (read first)

1. [references/SOURCES-CATALOG.md](references/SOURCES-CATALOG.md) — **canonical catalog** (master repos, per-expert map, thought-leader index, license rules).
2. Per-expert detail: `.cursor/skills/<slug>/SOURCES.md` (under team repo `${SKILLS_ROOT}`).
3. Live clones for mining (local, gitignored): `${SKILLS_ROOT}/sources/`.

If the user names one expert (e.g. "product-manager 的来源"), filter §3 of the catalog to that slug only plus its `SOURCES.md` rationale.

## Output format (Chinese)

```markdown
# 专家团队 — 权威来源

**数据日期:** <from catalog Last updated>
**取材原则:** MIT 优先 · 蒸馏改写 · 标注 star/license · 无 license 仅参考

---

## 一、核心开源库（巨人肩膀）

| 仓库 | Stars | License | 团队用途 |
| … |

## 二、行业实操来源

| 来源 | 用途 |
| … |

## 三、专家 ↔ 来源对照

| 专家 | 主要开源来源 | 对标 thought leaders |
| … |

## 四、许可与署名规则

<3-5 bullets from catalog §1 license table>

## 五、本地挖掘路径

`sources/claude-skills/` · `sources/awesome-skills/` · …

---

需要某专家的完整出处？说 `/source-skill <slug>` 或打开 `.cursor/skills/<slug>/SOURCES.md`
```

## Rules

- Always show **URL + stars + license** for every open-source repo listed.
- Flag **no LICENSE** repos as "仅参考，不复制原文".
- Do not invent sources; if catalog is stale, say so and offer to run weekly radar.
- Cross-link: `/boteam` for roster, `/hire-expert` to add new sourced experts.

## Maintenance

Updating this skill: edit `references/SOURCES-CATALOG.md` first, then sync expert `SOURCES.md` files. Weekly cron should refresh star counts and append new repos.
