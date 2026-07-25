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

FORBIDDEN_DIRS=(DailyX digest-skill-workspace)
FORBIDDEN_SKILLS=(bob ship-boteam daily-newsletter tune-newsletter publish-x digest-skill)

# Patterns that must not appear in public repo content (exclude this script's own definitions)
SENSITIVE_PATTERNS=(
  '/Users/puma'
  '/Users/'
  'DailyX'
  'publish-x'
  'daily-newsletter'
  'ship-boteam'
  'boteam.ai'
  'private team HQ'
  'private HQ'
)

echo "=== validate-repo (boteam-skills-set) ==="

# Legacy skill/command names must not exist
[[ -d .cursor/skills/team ]] && err "Legacy skill dir .cursor/skills/team — use boteam"
[[ -f .cursor/commands/team.md ]] && err "Legacy command team.md — use boteam.md"
[[ -f .cursor/skills/boteam/SKILL.md ]] || err "Missing .cursor/skills/boteam/SKILL.md"
[[ -f .cursor/commands/boteam.md ]] || err "Missing .cursor/commands/boteam.md"
ok "boteam skill + command present (no legacy team)"

for forbidden in "${FORBIDDEN_DIRS[@]}"; do
  [[ -e "$forbidden" ]] && err "Forbidden directory: ${forbidden}"
done
for slug in "${FORBIDDEN_SKILLS[@]}"; do
  [[ -d ".cursor/skills/${slug}" ]] && err "Forbidden skill: ${slug}"
done
ok "No forbidden private artifacts"

# Sensitive string audit (skip this script to avoid self-match on pattern list)
while IFS= read -r -d '' f; do
  [[ "$f" == "./scripts/validate-repo.sh" ]] && continue
  for pat in "${SENSITIVE_PATTERNS[@]}"; do
    if grep -qF "$pat" "$f" 2>/dev/null; then
      err "Sensitive pattern '${pat}' in ${f#./}"
    fi
  done
done < <(find . -type f \( -name '*.md' -o -name '*.mdc' -o -name '*.sh' -o -name '*.yml' -o -name '*.json' -o -name '.env.example' \) ! -path './.git/*' -print0)

if [[ "$FAIL" -eq 0 ]]; then
  ok "No sensitive patterns in tracked content"
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
ORG_SKILLS=(boteam help-skills source-skill create-skill ship-skill setup qa-review refine lesson bip headline psych-levers awareness-framing)
for slug in "${ORG_SKILLS[@]}"; do
  [[ -f ".cursor/skills/${slug}/SKILL.md" ]] || err "Org skill missing: ${slug}"
  [[ -f ".cursor/skills/${slug}/.shipped" ]] || err "Org skill not shipped: ${slug}"
done
ok "Org/platform skills present and shipped"

# boteam must be invokable as /boteam
if ! grep -q '/boteam' .cursor/skills/boteam/SKILL.md; then
  err "boteam/SKILL.md missing /boteam invoke documentation"
fi

# Validate each shipped skill frontmatter
for d in .cursor/skills/*/; do
  slug=$(basename "$d")
  [[ "$slug" == "_extras" ]] && continue
  [[ -f "${d}.shipped" ]] || continue
  "${SKILLS_ROOT}/scripts/validate-skill.sh" "$slug" || FAIL=1
done

echo "=== done ==="
exit "$FAIL"
