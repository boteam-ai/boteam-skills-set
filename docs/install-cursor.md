# Install — Cursor

## Global skills (recommended)

```bash
git clone https://github.com/boteam-ai/boteam-skills-set.git
cd boteam-skills-set
./scripts/install-skills.sh --global --shipped-only
```

Restart Cursor if skills do not appear immediately.

## Project commands + QA rules

Skills are global; **team slash commands** (`/product-team`, `/clevel`, etc.) install per project:

```bash
./scripts/setup-project.sh /path/to/your-app
```

Or invoke `/setup` from a product workspace.

## Uninstall global symlinks

```bash
./scripts/install-skills.sh --global --unlink
```

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `/product-manager` not found | Run global install; check `~/.cursor/skills/product-manager` is a symlink |
| Commands missing | Run `setup-project.sh` on the product repo |
| Name collision | Script backs up existing dirs to `~/.cursor/skills/.team-install-backups/` |
