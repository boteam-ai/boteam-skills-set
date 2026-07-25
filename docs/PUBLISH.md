# Publish to GitHub (maintainers)

Repo is ready locally at `/Users/puma/boteam-skills-set` with tag `v1.0.0`.

## One-time setup

```bash
gh auth login
cd /Users/puma/boteam-skills-set
```

## Create remote and push

```bash
gh repo create boteam-ai/boteam-skills-set --public \
  --description "Open-source AI expert team for solo founders — Cursor & Claude Code skills with org loop" \
  --source . --remote origin --push

git push origin v1.0.0
```

If the org repo already exists:

```bash
git remote add origin git@github.com:boteam-ai/boteam-skills-set.git
git push -u origin main
git push origin v1.0.0
```

## GitHub Release

```bash
gh release create v1.0.0 --title "v1.0.0 — Solo founder AI expert team" --notes-file docs/RELEASE-v1.0.0.md
```

## Repo settings (manual)

- **Topics:** `cursor`, `claude-code`, `ai-agents`, `solo-founder`, `indie-hacker`, `skills`
- **Social preview:** upload `docs/assets/skill-tree.svg` or a 1280×640 PNG variant

## Launch

See `marketing/x-thread-launch.md` and `marketing/hn-show-post.md`.
