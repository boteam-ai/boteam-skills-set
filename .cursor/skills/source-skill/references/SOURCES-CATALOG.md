# Authoritative Sources Catalog

Canonical registry of open-source repos, thought leaders, and per-expert provenance for the one-person-company expert team. **Maintained here;** each expert's `SOURCES.md` should stay in sync via weekly radar or `/hire-expert`.

Last updated: 2026-06-30

---

## 1. Master open-source repositories

| Repo | URL | Stars | License | Role in this team | Local clone |
|------|-----|------:|---------|-------------------|-------------|
| **alirezarezvani/claude-skills** | https://github.com/alirezarezvani/claude-skills | ~18.8k | MIT | Primary skeleton: C-level, product, marketing, engineering, personas, orchestration | `sources/claude-skills/` |
| **theneoai/awesome-skills** | https://github.com/theneoai/awesome-skills | ~1k+ | MIT (attribution required) | 956 persona skills; `EVALUATION_REPORT` pattern → HR rubric | `sources/awesome-skills/` |
| **multica-ai/andrej-karpathy-skills** | https://github.com/multica-ai/andrej-karpathy-skills | ~181k | Public (single CLAUDE.md) | LLM coding behavioral guidelines (think-first, simplicity, surgical, goal-driven) | — (cite URL) |
| **NicholasSpisak/claude-code-subagents** | https://github.com/NicholasSpisak/claude-code-subagents | 76+ personas | **No LICENSE** | Scope reference only (growth, social, ASO); **no verbatim copy** | `sources/claude-code-subagents/` |
| **EricGrill/agent-personalities-skills** | https://github.com/EricGrill/agent-personalities-skills | 40+ personas | MIT | Persona style reference | `sources/agent-personalities-skills/` |
| **ComposioHQ/awesome-claude-skills** | https://github.com/ComposioHQ/awesome-claude-skills | ~1k+ | (curated list) | Supplementary skill discovery | — |
| **nowork-studio/toprank** | https://github.com/nowork-studio/toprank | ~107 | MIT | SEO / schema / keyword skill framing | — |
| **Digidai/product-manager-skills** | https://github.com/Digidai/product-manager-skills | n/a | reference only | PM domain framing (discovery/strategy/delivery) | — |
| **elvisun/newsjack** | https://github.com/elvisun/newsjack | ~503 | MIT | PR headline skills; `/headline` from `skills/headline-generator/` | `sources/newsjack/` |

### License handling rules

| License | Action |
|---------|--------|
| MIT / Apache | Distill, rewrite, attribute in `SOURCES.md` |
| MIT + attribution (theneoai) | Credit repo + link in catalog and expert `SOURCES.md` |
| No LICENSE (claude-code-subagents) | Reference scope only; original synthesis |
| Research sites (onepc.org, etc.) | Cite URL; do not copy long passages |

---

## 2. Industry & operating-practice sources

| Source | URL | Used for |
|--------|-----|----------|
| ONEPC — AI stack of solo founders 2026 | https://onepc.org/stats/ai-stack-solo-founders-2026 | Levels, Lou, Postma, Welsh stacks; audience-first |
| One Person Company — AI OS | https://onepersoncompany.com/ai-operating-system-solo-founders | 6-role AI OS (marketing/sales/support/dev/design/ops) |

---

## 3. Per-expert provenance map

| Expert (`/slug`) | Open-source sources | Thought leaders |
|------------------|---------------------|-----------------|
| `/ceo-founder-coach` | claude-skills (founder-coach, ceo-advisor, solo-founder persona); onepc.org | Paul Graham, Eric Ries, Pieter Levels, Rob Walling |
| `/business-model-strategist` | claude-skills (pricing-strategy, saas-metrics-coach, cfo-advisor) | Osterwalder, Ash Maurya, Patrick Campbell |
| `/product-manager` | claude-skills (product-manager-toolkit, product-discovery); Digidai (ref) | Marty Cagan, Teresa Torres, Melissa Perri, Shreyas Doshi |
| `/ux-designer` | claude-skills (ux-researcher-designer, marketing-psychology, onboarding-cro) | Don Norman, Nielsen/NN/g, Steve Krug, Nir Eyal, BJ Fogg |
| `/ui-brand-designer` | claude-skills (ui-design-system, apple-hig-expert, brand-guidelines) | Apple HIG, Material Design, Refactoring UI, Dieter Rams |
| `/researcher` | claude-skills (product-discovery, competitive-teardown, market-research) | Rob Fitzgerald (*Mom Test*), Teresa Torres, Steve Blank, April Dunford |
| `/full-stack-engineer` | **Karpathy skills**; claude-skills (engineering-team, saas-scaffolder) | Karpathy, DHH/37signals, Pieter Levels, Kent Beck |
| `/ai-application-engineer` | claude-skills (rag-architect, agent-designer, prompt-engineer-toolkit) | Karpathy, Eugene Yan, Hamel Husain, Jason Liu, Anthropic/OpenAI guides |
| `/cmo` | claude-skills (cmo-advisor, marketing-strategy-pmm, launch-strategy) | April Dunford, Seth Godin, Gabriel Weinberg, Dave McClure |
| `/growth-hacker` | claude-skills (ab-test, onboarding-cro, page-cro); subagents (ref only) | Sean Ellis, Brian Balfour, Andrew Chen, Casey Winters |
| `/content-seo-strategist` | claude-skills (seo-audit, aeo, programmatic-seo); toprank | Pat Walls, Brian Dean, Eli Schwartz, Rand Fishkin |
| `/social-media-manager` | claude-skills (x-twitter-growth, social-content); subagents (ref only) | Justin Welsh, Pieter Levels, Marc Lou, Dan Koe |
| `/sales-bizdev` | claude-skills (cold-email, business-growth, commercial) | Steli Efti, Aaron Ross, Chris Voss, April Dunford |
| `/copywriter` | claude-skills (copywriting, content-humanizer, email-sequence) | Joanna Wiebe, Eugene Schwartz, David Ogilvy, Harry Dry |
| `/hr-evaluator` | awesome-skills (EVALUATION_REPORT); claude-skills (self-improving-agent) | Andy Grove, YC partner review discipline |
| `/team` | Aggregates all above | — |
| `/source-skill` | This catalog | — |
| `/bip` | claude-skills (x-twitter-growth, social-content); humanizer (MIT, bundled pass) | Pieter Levels, Marc Lou, Justin Welsh |
| `/headline` | newsjack (`headline-generator`) | David Ogilvy, Eugene Schwartz, Joanna Wiebe, John Caples |

Detail per expert: `.cursor/skills/<slug>/SOURCES.md`

---

## 4. Thought leaders by domain (quick index)

| Domain | Authorities |
|--------|-------------|
| **Founder / strategy** | Paul Graham, Eric Ries, Pieter Levels, Rob Walling, Andy Grove |
| **Product** | Marty Cagan, Teresa Torres, Melissa Perri, Shreyas Doshi |
| **UX / psychology** | Don Norman, Jakob Nielsen, Steve Krug, Nir Eyal, BJ Fogg |
| **Design** | Apple HIG, Material, Refactoring UI (Wathan/Schoger) |
| **Research** | Rob Fitzgerald, Steve Blank, April Dunford |
| **Engineering** | Andrej Karpathy, DHH, Kent Beck |
| **AI apps** | Karpathy, Eugene Yan, Hamel Husain, Jason Liu |
| **Marketing / GTM** | April Dunford, Seth Godin, Gabriel Weinberg, Dave McClure |
| **Growth** | Sean Ellis, Brian Balfour, Andrew Chen, Casey Winters |
| **SEO / content** | Pat Walls, Brian Dean, Eli Schwartz, Rand Fishkin |
| **Social / audience** | Justin Welsh, Pieter Levels, Marc Lou |
| **Sales** | Steli Efti, Aaron Ross, Chris Voss |
| **Copy** | Joanna Wiebe, Eugene Schwartz, David Ogilvy |
| **Business model** | Osterwalder, Ash Maurya, Patrick Campbell |

---

## 5. claude-skills subpaths used (MIT — primary mine)

| Path in repo | Experts served |
|--------------|----------------|
| `c-level-advisor/founder-coach`, `ceo-advisor`, `cmo-advisor` | ceo-founder-coach, cmo |
| `agents/personas/solo-founder.md` | ceo-founder-coach |
| `product-team/product-manager-toolkit`, `product-discovery`, `ux-researcher-designer`, `ui-design-system`, `apple-hig-expert` | product-manager, ux-designer, ui-brand-designer, researcher |
| `engineering-team/`, `engineering/rag-architect`, `agent-designer`, `prompt-engineer-toolkit` | full-stack-engineer, ai-application-engineer |
| `marketing-skill/*` (seo, aeo, copywriting, social, cold-email, pricing, launch, cro) | cmo, growth-hacker, content-seo, social, sales, copywriter, business-model |
| `finance/saas-metrics-coach`, `commercial/pricing-strategist` | business-model-strategist |

Full tree: clone `sources/claude-skills/` locally (gitignored; not committed).

---

## 6. Freshness & updates

- **Weekly cron** (`ops/weekly-automation.md`): scan for new high-star MIT skill repos → append to §1 → update affected expert `SOURCES.md` → refresh this catalog's date.
- **New expert** (`/hire-expert`): must add a row to §3 and a master repo entry if new.
- **Star counts**: approximate at install time; refresh on radar pass.

Team repo root: `${SKILLS_ROOT}`
