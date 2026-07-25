# Skill tree — boteam-skills-set

Canonical map of experts, utilities, and handoffs. Summon with `/team` or `/help-skills`.

![Skill tree](assets/skill-tree.svg)

## Entry points

| Slash | Purpose |
|-------|---------|
| `/team` | Full roster + division of labor |
| `/help-skills` | Skill tree index + when to use what |
| `/setup` | Wire a product repo (commands, QA rules, AGENTS.md) |

## Layer 1 — Strategy

| Expert | Invoke | Primary job |
|--------|--------|-------------|
| Founder Coach | `/ceo-founder-coach` | Focus, riskiest assumption, weekly priority |
| Business Model | `/business-model-strategist` | Pricing, packaging, unit economics |

**Flow:** `/ceo-founder-coach` → `/business-model-strategist` when monetization is the bottleneck.

## Layer 2 — Product

| Expert | Invoke | Primary job |
|--------|--------|-------------|
| Researcher | `/researcher` | User/market validation, competitive intel |
| Product Manager | `/product-manager` | MVP scope, PRD, prioritization |
| UX Designer | `/ux-designer` | Flows, onboarding, usability |
| UI / Brand | `/ui-brand-designer` | Visual system, brand, platform UI |

**Flow:** `/researcher` → `/product-manager` → `/ux-designer` → `/ui-brand-designer`

## Layer 3 — Engineering

| Expert | Invoke | Primary job |
|--------|--------|-------------|
| Full-stack | `/full-stack-engineer` | Ship extension/mobile/web/SaaS |
| AI Apps | `/ai-application-engineer` | LLM features, RAG, agents, evals |

**Flow:** `/product-manager` → `/full-stack-engineer` → `/qa-review` (evidence before done)

## Layer 4 — GTM

| Expert | Invoke | Primary job |
|--------|--------|-------------|
| CMO | `/cmo` | Positioning, channels, launch |
| Growth | `/growth-hacker` | Experiments, funnel, retention |
| Content + SEO | `/content-seo-strategist` | Content, SEO, AEO |
| Social | `/social-media-manager` | Build in public, social ops |
| Sales | `/sales-bizdev` | Founder-led sales, partnerships |
| Copywriter | `/copywriter` | Conversion copy, brand voice |
| Build in Public | `/bip` | Turn shipping into social posts |
| Headlines | `/headline` | News-style headline candidates |
| Psych levers | `/psych-levers` | Five-lever persuasion sequence |
| Awareness | `/awareness-framing` | Schwartz five awareness levels |

**Flow:** `/cmo` → `/content-seo-strategist` → `/bip` → `/social-media-manager`

## Layer 5 — Meta (org loop)

| Command | Purpose |
|---------|---------|
| `/hr-evaluator` | Score experts, hire/retire recommendations |
| `/hire-expert` | Recruit new expert (sources + rubric) |
| `/hr-review` | Full roster review |
| `/clevel` | Strategy board (CEO + CMO + eng + biz model) |
| `/distill-to-team` | Extract reusable methodology |

## Layer 6 — Quality

| Skill | Purpose |
|-------|---------|
| `/qa-review` | Independent lint/test/build verification |
| `/refine` | Turn vague intent into precise prompts |
| `/lesson` | Bug → durable Cursor rule (when systemic) |

## Team bundles

| Command | Members | When |
|---------|---------|------|
| `/product-team` | PM, UX, UI, researcher | Discovery → spec → design |
| `/mkt-team` | CMO, growth, SEO, social, copywriter | Launch + positioning |
| `/growth-team` | growth, SEO, social, sales | Funnel + early revenue |
| `/clevel` | CEO coach, CMO, full-stack, biz model | Weekly strategy |

## Founder workflows

See [workflows/](workflows/) for step-by-step playbooks:

1. [validate-idea.md](workflows/validate-idea.md)
2. [ship-mvp.md](workflows/ship-mvp.md)
3. [price-and-launch.md](workflows/price-and-launch.md)
4. [first-10-customers.md](workflows/first-10-customers.md)
5. [build-in-public.md](workflows/build-in-public.md)

## Optional extras

Under `.cursor/skills/_extras/` (macOS / OBS dependent):

- `demo`, `product-demo`, `obs` — not installed by default global link
