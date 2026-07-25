#!/usr/bin/env bash
# Validate boteam-skills-set OSS repo (run from repo root).
set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SKILLS_ROOT"
FAIL=0

warn() { echo "WARN: $*"; }
err() { echo "FAIL: $*"; FAIL=1; }
ok() { echo "OK: $*"; }

CORE_EXPERTS=(
  ceo-founder-coach business-model-strategist
  product-manager ux-designer ui-brand-designer researcher
  full-stack-engineer ai-application-engineer
  cmo growth-hacker content-seo-strategist social-media-manager sales-bizdev copywriter
  hr-evaluator
)

echo "=== validate-repo (boteam-skills-set) ==="

# Forbidden paths / dirs
for forbidden in DailyX digest-skill-workspace bob ship-boteam daily-newsletter; do
  if [[ -e "$forbidden" ]] || [[ -d ".cursor/skills/${forbidden}" ]]; then
    err "Forbidden artifact present: ${forbidden}"
  fi
done
ok "No forbidden private artifacts at root/skills"

# No personal path leaks
leak_files=$(grep -rl '/Users/puma' . \
  --include='*.md' --include='*.sh' --include='*.mdc' --include='*.yml' \
  --exclude-dir='.git' 2>/dev/null || true)
if [[ -n "$leak_files" ]]; then
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    err "Personal path leak: $f"
  done <<< "$leak_files"
else
  ok "No /Users/puma path leaks"
fi

# Required governance
for f in README.md LICENSE GUARDRAILS.md CHANGELOG.md docs/skill-tree.md; do
  [[ -f "$f" ]] || err "Missing required: $f"
done
[[ -f GUARDRAILS.md ]] && ok "Governance + docs present"

# Core experts: four-piece + Handoffs + .shipped
for slug in "${CORE_EXPERTS[@]}"; do
  d=".cursor/skills/${slug}"
  for f in SKILL.md SOUL.md SOURCES.md EVALUATION.md; do
    [[ -f "${d}/${f}" ]] || err "Core expert ${slug} missing ${f}"
  done
  [[ -f "${d}/.shipped" ]] || err "Core expert ${slug} missing .shipped"
  if ! grep -qE '^## Handoffs|^## Hand-off' "${d}/SKILL.md" 2>/dev/null; then
    err "Core expert ${slug} missing ## Handoffs section"
  fi
done
ok "Core experts four-piece + Handoffs + shipped"

# Org skills must ship
ORG_SKILLS=(team help-skills source-skill create-skill ship-skill setup qa-review refine lesson bip headline psych-levers awareness-framing)
for slug in "${ORG_SKILLS[@]}"; do
  [[ -f ".cursor/skills/${slug}/SKILL.md" ]] || err "Org skill missing: ${slug}"
  [[ -f ".cursor/skills/${slug}/.shipped" ]] || err "Org skill not shipped: ${slug}"
done
ok "Org/platform skills present and shipped"

# Validate each shipped skill frontmatter
for d in .cursor/skills/*/; do
  slug=$(basename "$d")
  [[ "$slug" == "_extras" ]] && continue
  [[ -f "${d}.shipped" ]] || continue
  "${SKILLS_ROOT}/scripts/validate-skill.sh" "$slug" || FAIL=1
done

echo "=== done ==="
exit "$FAIL"
