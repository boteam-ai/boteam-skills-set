#!/usr/bin/env bash
# Resolve Anthropic official skill-creator plugin paths (Cursor plugin cache).
# Usage: ./scripts/locate-skill-creator.sh
# Exits 1 if the plugin is not installed/cached — enable in Cursor Plugin manager.
set -euo pipefail

SKILL_MD=""
while IFS= read -r candidate; do
  [[ -f "$candidate" ]] || continue
  SKILL_MD="$candidate"
  break
done < <(find "${HOME}/.cursor/plugins" -path "*/skill-creator/skills/skill-creator/SKILL.md" 2>/dev/null | sort)

if [[ -z "$SKILL_MD" ]]; then
  echo "ERROR: skill-creator not found under ~/.cursor/plugins" >&2
  echo "" >&2
  echo "This is NOT ~/.cursor/skills-cursor/create-skill (authoring guide only, no eval loop)." >&2
  echo "Enable the official plugin:" >&2
  echo "  Cursor → Plugins → claude-plugins-official → skill-creator" >&2
  exit 1
fi

PLUGIN_ROOT="$(cd "$(dirname "$SKILL_MD")" && pwd)"

echo "SKILL_MD=${SKILL_MD}"
echo "PLUGIN_ROOT=${PLUGIN_ROOT}"
echo "SCRIPTS=${PLUGIN_ROOT}/scripts"
echo "EVAL_VIEWER=${PLUGIN_ROOT}/eval-viewer/generate_review.py"
