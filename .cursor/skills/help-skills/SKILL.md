---
name: help-skills
description: >-
  Print the boteam-skills-set skill tree index: layers, slash commands, team
  bundles, and founder workflows. Use when the user invokes /help-skills, asks
  which skill to use, wants the org chart, or needs routing between experts.
disable-model-invocation: true
---

# Help Skills — Skill Tree Index

> **Default: reply in English.** User asks for 中文 → Chinese OK.

When invoked, output a **condensed skill tree** — do not dump every SKILL.md.

## Read first

1. [docs/skill-tree.md](../../../docs/skill-tree.md) — canonical map
2. [hr/ROSTER.md](../../../hr/ROSTER.md) — active experts
3. [README.md](../../../README.md) — install + bundles

## Output format

```markdown
# boteam-skills-set — Skill Tree

**Install:** `./scripts/install-skills.sh --global --shipped-only`
**Full map:** docs/skill-tree.md

## Entry
/team · /help-skills · /setup

## Strategy
/ceo-founder-coach · /business-model-strategist

## Product
/researcher → /product-manager → /ux-designer → /ui-brand-designer

## Engineering
/full-stack-engineer · /ai-application-engineer → /qa-review

## GTM
/cmo · /growth-hacker · /content-seo-strategist · /social-media-manager
/sales-bizdev · /copywriter · /bip · /headline

## Org
/hire-expert · /hr-review · /clevel · /hr-evaluator

## Bundles
/product-team · /mkt-team · /growth-team · /clevel

## Workflows (docs/workflows/)
validate-idea · ship-mvp · price-and-launch · first-10-customers · build-in-public
```

If the user asks **which skill for X**, answer in **3 lines max** with one primary slash + one handoff.

## Demo mode (`/help-skills demo`)

English only. No internal paths. See [../../references/DEMO-SUFFIX.md](../../references/DEMO-SUFFIX.md).
