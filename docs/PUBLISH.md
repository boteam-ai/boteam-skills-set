# Publish to GitHub (maintainers)

## One-time setup

```bash
gh auth login
cd boteam-skills-set   # clone root
```

## Create remote and push

```bash
gh repo create boteam-ai/boteam-skills-set --public \
  --description "Open-source AI expert team for solo founders — Cursor & Claude Code skills with org loop" \
  --source . --remote origin --push

git push origin v1.0.0
```

If the repo already exists:

```bash
git remote add origin git@github.com:boteam-ai/boteam-skills-set.git
git push -u origin main
git push origin --tags
```

## GitHub Release

```bash
gh release create v1.0.0 --title "v1.0.0 — Solo founder AI expert team" --notes-file docs/RELEASE-v1.0.0.md
```

## Pre-release checklist

```bash
./scripts/validate-repo.sh
```

Must pass with zero sensitive-pattern failures.

## Repo settings (manual)

- **Topics:** `cursor`, `claude-code`, `ai-agents`, `solo-founder`, `indie-hacker`, `skills`
- **Social preview:** `docs/assets/skill-tree.svg` or 1280×640 PNG variant

## Launch

See `marketing/x-thread-launch.md` and `marketing/hn-show-post.md`.
