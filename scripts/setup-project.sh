#!/usr/bin/env bash
# Onboard a product repo: global skills-set (if missing) + project commands/rules/AGENTS.md.
# Skips duplicating skills into the project when global ~/.cursor/skills/ already links team.
#
# Usage:
#   ./scripts/setup-project.sh [path-to-project]
#   ./scripts/setup-project.sh              # uses current directory

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_SKILLS="${HOME}/.cursor/skills"
TARGET="${1:-.}"
PROJECT="$(cd "$TARGET" && pwd)"

if [[ "$PROJECT" == "$SKILLS_ROOT" ]]; then
  echo "Error: ${PROJECT} is the skills-set repo repo. /setup targets product repos, not team." >&2
  echo "Run HR/hire/clevel from team; run /setup from a product workspace." >&2
  exit 1
fi

echo "=== setup-project ==="
echo "Skills root:  ${SKILLS_ROOT}"
echo "Target:     ${PROJECT}"
echo ""

# --- Step 1: ensure global skills-set ---
global_ok=0
global_missing=0
global_total=0

for d in "${SKILLS_ROOT}/.cursor/skills"/*/; do
  [[ -d "$d" ]] || continue
  [[ -f "${d}.shipped" ]] || continue
  name="$(basename "$d")"
  global_total=$((global_total + 1))
  dest="${GLOBAL_SKILLS}/${name}"
  if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "${SKILLS_ROOT}/.cursor/skills/${name}" ]]; then
    global_ok=$((global_ok + 1))
  else
    global_missing=$((global_missing + 1))
  fi
done

if [[ "$global_missing" -gt 0 ]]; then
  echo "[1/4] Global shipped skills: ${global_ok}/${global_total} linked — installing --global --shipped-only..."
  "${SKILLS_ROOT}/scripts/install-skills.sh" --global --shipped-only
else
  echo "[1/4] Global shipped skills: ${global_ok}/${global_total} already linked — skip --global"
fi

# --- Step 2: project commands + QA rules (+ skills only if global failed) ---
echo ""
if [[ "$global_missing" -eq 0 ]]; then
  echo "[2/4] Project wiring: commands + rules + AGENTS.md (--skip-skills)..."
  "${SKILLS_ROOT}/scripts/install-skills.sh" --project "$PROJECT" --skip-skills
else
  echo "[2/4] Project wiring: full --project (global was incomplete)..."
  "${SKILLS_ROOT}/scripts/install-skills.sh" --project "$PROJECT"
fi

# --- Step 3: always refresh AGENTS.md Project Context (fill _(unset)_ only) ---
echo ""
echo "[3/4] Refresh AGENTS.md Project Context..."
"${SKILLS_ROOT}/scripts/init-project-context.sh" "$PROJECT"

# --- Step 4: Playwright MCP hint (non-fatal) ---
echo ""
echo "[4/4] Playwright MCP (optional, for /qa-review UI smoke)..."
if command -v jq >/dev/null 2>&1 && [[ -f "${HOME}/.cursor/mcp.json" ]] \
   && jq -e '.mcpServers.playwright' "${HOME}/.cursor/mcp.json" >/dev/null 2>&1; then
  echo "  playwright MCP already in ~/.cursor/mcp.json"
else
  echo "  not configured — run: ${SKILLS_ROOT}/scripts/merge-playwright-mcp.sh"
  echo "  then: npx -y playwright install chromium && restart Cursor"
fi

echo ""
echo "=== setup complete ==="
echo "Product repo: ${PROJECT}"
echo "Next: open this repo in Cursor, read AGENTS.md, fill any _(unset)_ rows, then use /qa-review after shipping."
