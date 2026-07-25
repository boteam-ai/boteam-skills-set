# Quickstart

Get from zero to `/ceo-founder-coach` in under two minutes.

## 1. Clone and install globally

```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
chmod +x scripts/*.sh
./scripts/install-skills.sh --global --shipped-only
```

This symlinks **shipped** skills to:

- `~/.cursor/skills/` (Cursor, all projects)
- `~/.claude/skills/` (Claude Code)

## 2. Verify

Open any Cursor chat and type:

```
/boteam
```

You should see the full expert roster.

## 3. Wire a product repo

From your app directory (not this repo):

```bash
/path/to/boteam-skills-set/scripts/setup-project.sh .
```

Or in chat: `/setup`

This adds slash **commands**, QA rules, and `AGENTS.md` — without duplicating global skills.

## 4. Run a workflow

Example — validate an idea:

1. `/researcher` — interview plan + demand signals
2. `/product-manager` — MVP scope from findings
3. `/ceo-founder-coach` — go/no-go on the bet

Full playbooks: [workflows/](workflows/)

## Next

- [Skill tree](skill-tree.md)
- [Install — Cursor](install-cursor.md)
- [Install — Claude Code](install-claude-code.md)
