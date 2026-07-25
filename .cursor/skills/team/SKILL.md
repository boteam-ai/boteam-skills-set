---
name: team
description: Lists the full one-person-company expert team roster, division of labor by layer, and how to summon each expert or team. Use when the user types /team, /team demo, or asks who is on the team, expert roles, org chart, or how to call product/marketing/engineering experts.
disable-model-invocation: true
---

# Team Directory (专家团队目录)

> **Default: reply in English.** User asks for 中文 → Chinese OK. **`demo` suffix → English, public-safe, no scores.** See § Demo output.

When invoked, output the **complete expert team directory** with division of labor. Do not guess — read live roster data first.

## Mode detection

| Trigger | Mode |
|---------|------|
| `/team`, `/team <question>` | Default — English, live ROSTER scores |
| `/team demo`, `team demo` | **Demo output** — English, redacted, no scores |

Demo redaction rules: [../../references/DEMO-SUFFIX.md](../../references/DEMO-SUFFIX.md)

## Data sources (read in order)

1. [../../../hr/ROSTER.md](../../../hr/ROSTER.md) — current roster, scores, status (canonical).
2. [../../../README.md](../../../README.md) — summon commands and team groupings.
3. If paths fail (e.g. skill used outside team repo), use [references/TEAM-DIRECTORY.md](references/TEAM-DIRECTORY.md) as fallback and note that scores may be stale.

Skills-set repo root (for HR/ops): git root or `SKILLS_ROOT` env var

## Output format (use every time)

Print exactly this structure in Chinese:

```markdown
# 一人公司 AI 专家团队

**状态摘要:** <从 ROSTER 读取 active/probation/retired 数量>

---

## 一、战略层 (Strategy)
| 召唤 | 专家 | 分工 | 状态 | 评分 |
|------|------|------|------|------|
| `/ceo-founder-coach` | 创业导师 | 焦点、风险假设、go/no-go、每周唯一目标 | … | … |
| `/business-model-strategist` | 商业模式策略师 | 定价、变现、单位经济、包装 | … | … |

## 二、产品层 (Product)
| 召唤 | 专家 | 分工 | 状态 | 评分 |
| `/product-manager` | 产品经理 | MVP 范围、PRD、优先级、路线图 | … | … |
| `/ux-designer` | UX/交互设计师 | 流程、onboarding、可用性、行为心理学 | … | … |
| `/ui-brand-designer` | UI/品牌设计师 | 视觉系统、品牌、平台规范 | … | … |
| `/researcher` | 研究员 | 用户/市场验证、竞品、go/pivot/kill | … | … |

## 三、工程层 (Engineering)
| 召唤 | 专家 | 分工 | 状态 | 评分 |
| `/full-stack-engineer` | 全栈工程师 | Extension/iOS/Android/Web/SaaS，Karpathy 准则 | … | … |
| `/ai-application-engineer` | AI 应用工程师 | RAG、Agent、Prompt、Evals | … | … |

## 四、GTM 层 (Go-To-Market)
| 召唤 | 专家 | 分工 | 状态 | 评分 |
| `/cmo` | CMO | 定位、渠道、发布策略 | … | … |
| `/growth-hacker` | 增长黑客 | 漏斗实验、激活/留存、PLG | … | … |
| `/content-seo-strategist` | 内容+SEO | 有机获客、SEO、AEO | … | … |
| `/social-media-manager` | 社媒运营 | 公开建造、X/LinkedIn/TikTok | … | … |
| `/sales-bizdev` | 销售/BizDev | 创始人销售、外联、合作 | … | … |
| `/copywriter` | 文案 | 落地页、邮件、品牌声音 | … | … |

## 五、元层 (Meta)
| 召唤 | 专家 | 分工 | 状态 | 评分 |
| `/hr-evaluator` | HR 考核官 | 专家评分、去留、缺口分析 | … | … |

---

## 团队召唤 (一次召集多人)

| 命令 | 成员 | 适用场景 |
|------|------|----------|
| `/product-team` | PM + UX + UI + researcher | 产品定义、MVP、体验 |
| `/mkt-team` | CMO + growth + content-seo + social + copywriter | GTM、推广、品牌 |
| `/growth-team` | growth + content-seo + social + sales | 获客、转化、留存 |
| `/clevel` | CEO + CMO + 工程 + 商业模式 | 战略董事会 |

## 运营命令

| 命令 | 用途 |
|------|------|
| `/hire-expert` | 招募新专家（巨人肩膀流程） |
| `/hr-review` | 全员考核（建议在 team 仓库执行） |
| `/source-skill` | 权威来源：开源库 + thought leaders + 许可 |
| `/log-expert-use` | 轻量记录专家调用（日常） |
| `/distill-to-team` | 提炼方法论 → `methodology/` |

---

## 组织状态（可选附录）

读取 `ops/executions/index.json` 最近 **3** 条 + `CHANGELOG.md` `[Unreleased]` 摘要，附在目录末尾（「最近组织动态」）。

---

## 快速选用

- 定本周做什么 → `/ceo-founder-coach`
- 做什么功能 → `/product-manager` 或 `/product-team`
- 写代码 → `/full-stack-engineer`
- 怎么卖 → `/cmo` 或 `/mkt-team`
- 看全员 → `/team`（本命令）
```

After the table, add **one line**: how many experts are `active` and remind that `/hr-review` runs best from the team repo.

---

## Demo output (`/team demo`)

**English only.** Read ROSTER for expert names and slugs; **omit scores, dates, source columns, and ops appendix.**

Do **not** print `Team repo root`, execution logs, or CHANGELOG.

Use this structure:

```markdown
# AI Expert Team — One-Person Company

**Shared skill pack for Cursor and Claude Code.** Each expert is a skill installed globally on both tools. Summon with `/slug` or by name in chat.

**Status:** <N> active experts across 5 layers

---

## Strategy
| Invoke | Role | Responsibility | Status |
| `/ceo-founder-coach` | Founder Coach | Focus, riskiest assumption, weekly priority | Active |
| `/business-model-strategist` | Business Model | Pricing, packaging, unit economics | Active |

## Product
| Invoke | Role | Responsibility | Status |
| `/product-manager` | Product Manager | MVP scope, PRD, prioritization | Active |
| `/ux-designer` | UX Designer | Flows, onboarding, behavioral UX | Active |
| `/ui-brand-designer` | UI / Brand | Visual system, design tokens, platform UI | Active |
| `/researcher` | Researcher | Demand validation, interviews, market map | Active |

## Engineering
| Invoke | Role | Responsibility | Status |
| `/full-stack-engineer` | Full-Stack Engineer | Extensions, mobile, web, SaaS — minimal shippable code | Active |
| `/ai-application-engineer` | AI App Engineer | RAG, agents, prompts, evals, cost/latency | Active |

## Go-To-Market
| Invoke | Role | Responsibility | Status |
| `/cmo` | CMO | Positioning, channels, launch strategy | Active |
| `/growth-hacker` | Growth | Funnel experiments, activation, PLG | Active |
| `/content-seo-strategist` | Content & SEO | Organic growth, SEO, AEO | Active |
| `/social-media-manager` | Social | Build in public — X, LinkedIn, short video | Active |
| `/sales-bizdev` | Sales / BizDev | Founder-led sales, outbound, partnerships | Active |
| `/copywriter` | Copywriter | Landing pages, email, brand voice | Active |

## Meta (Org)
| Invoke | Role | Responsibility | Status |
| `/hr-evaluator` | HR Evaluator | Expert scoring, hire/upgrade/retire recommendations | Active |

---

## Team summons (multi-expert)

| Command | Members | Use when |
| `/product-team` | PM + UX + UI + researcher | Product definition, MVP, experience |
| `/mkt-team` | CMO + growth + content + social + copy | GTM, launch, brand |
| `/growth-team` | growth + content + social + sales | Acquisition, conversion, retention |
| `/clevel` | CEO + CMO + engineering + business model | Strategy board |

## Org operations

| Command | Purpose |
| `/hire-expert` | Recruit a new expert (sourcing + rubric) |
| `/hr-review` | Full team evaluation cycle |
| `/source-skill` | Authoritative sources catalog |
| `/team` | This directory |
```

Fill rows from live ROSTER; keep **Status** as `Active` only (no numeric scores).

## Rules

- Always include **召唤 (slash name)** and **分工 (one line)** for every expert.
- Do not list retired experts unless ROSTER has entries in Retired pool.
- Keep the reply scannable; no long prose before the tables.
