# boteam-skills-set

**The open-source AI expert team for solo founders** — 15 slash-command experts + org loop, distilled from 18k★ MIT skill libraries.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/experts-15-green.svg)](docs/skill-tree.md)
[![CI](https://github.com/boteam-ai/boteam-skills-set/actions/workflows/validate.yml/badge.svg)](https://github.com/boteam-ai/boteam-skills-set/actions/workflows/validate.yml)

![Skill tree](docs/assets/skill-tree.svg)

## Why not just prompts?

- **Named experts** with SOUL personas — not anonymous system prompts
- **SOURCES.md** on every core expert — upstream attribution (MIT libraries)
- **Handoffs** — each expert tells you who to call next
- **Org loop** — `/hire-expert`, `/hr-review`, `/clevel` to evolve the roster

## Install in 30 seconds

```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
chmod +x scripts/*.sh
./scripts/install-skills.sh --global --shipped-only
```

Restart Cursor, then type **`/team`** in any project.

Wire slash commands into a product repo:

```bash
./scripts/setup-project.sh /path/to/your-app
```

Details: [docs/quickstart.md](docs/quickstart.md)

## Skill tree

| Layer | Experts |
|-------|---------|
| **Strategy** | `/ceo-founder-coach` · `/business-model-strategist` |
| **Product** | `/researcher` · `/product-manager` · `/ux-designer` · `/ui-brand-designer` |
| **Engineering** | `/full-stack-engineer` · `/ai-application-engineer` |
| **GTM** | `/cmo` · `/growth-hacker` · `/content-seo-strategist` · `/social-media-manager` · `/sales-bizdev` · `/copywriter` |
| **Meta** | `/hr-evaluator` + `/hire-expert` · `/hr-review` · `/clevel` |
| **Quality** | `/qa-review` · `/refine` · `/lesson` · `/bip` · `/headline` |

Full map: **[docs/skill-tree.md](docs/skill-tree.md)** · Index: **`/help-skills`**

## Founder workflows

| Workflow | Chain |
|----------|-------|
| [Validate an idea](docs/workflows/validate-idea.md) | researcher → PM → CEO coach |
| [Ship MVP](docs/workflows/ship-mvp.md) | PM → UX → full-stack → qa-review |
| [Price & launch](docs/workflows/price-and-launch.md) | biz model → CMO → copywriter |
| [First 10 customers](docs/workflows/first-10-customers.md) | sales → growth → CEO coach |
| [Build in public](docs/workflows/build-in-public.md) | bip → headline → social |

## Team bundles

```
/product-team   — PM + UX + UI + researcher
/mkt-team       — CMO + growth + SEO + social + copywriter
/growth-team    — growth + SEO + social + sales
/clevel         — CEO + CMO + engineering + business model
```

## SSOT workflow

```
.cursor/skills/<name>/     ← edit here (git)
        │
        │  ./scripts/ship-skill.sh <name>
        ▼
~/.cursor/skills/<name>  ──┐
~/.claude/skills/<name>  ──┴→ symlinks (no copies)
```

## Compare

See [docs/comparisons.md](docs/comparisons.md) vs claude-skills and awesome lists.

## Attribution

Distilled from MIT-licensed upstream libraries. Every expert cites sources. [docs/attribution.md](docs/attribution.md)

## Optional extras

macOS/OBS-dependent skills live in `.cursor/skills/_extras/` (`demo`, `product-demo`, `obs`) — not linked by default.

## Star if you're building solo

Helps the next indie founder find a coherent expert system instead of prompt roulette.

## License

MIT — see [LICENSE](LICENSE)
