# Show HN post

**Title:** Show HN: boteam-skills-set – AI expert team for solo founders (Cursor + Claude Code)

**Body:**

I'm open-sourcing the expert skill system I use to run a one-person company — not a prompt dump, but 15 named roles (founder coach, PM, full-stack, CMO, etc.) with personas, upstream attribution, and explicit handoffs.

**Why:** Solo founders context-switch across strategy, product, eng, and GTM. Flat skill lists don't tell you *what to call next*. This repo ships a skill tree + workflows (validate idea → ship MVP → price → first customers → build in public).

**Install:**
```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
./scripts/install-skills.sh --global --shipped-only
```

**Diff vs claude-skills:** Narrow solo-founder focus, four-piece experts, org loop (/hire-expert, /hr-review), symlink SSOT with ship gate.

**Stack:** Markdown skills, bash install scripts, GitHub Actions validation.

Would love feedback on the skill tree and which workflow to document next.

**URL:** https://github.com/boteam-ai/boteam-skills-set
