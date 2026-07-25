# Install — Claude Code

Skills symlink to `~/.claude/skills/` during global install.

```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
./scripts/install-skills.sh --global --shipped-only
```

Invoke experts with slash commands in Claude Code sessions, e.g. `/ceo-founder-coach`.

Org loops (`/hr-review`, `/hire-expert`) expect this repo as workspace so `hr/` and `templates/` resolve.

## Claude Code vs Cursor differences

Some skills reference Cursor-only tools (browser MCP, AskQuestion). Each skill notes Claude Code equivalents where applicable.

Product QA: use `/qa-review` for evidence-based verification; full interactive QA loops may need additional tooling.
