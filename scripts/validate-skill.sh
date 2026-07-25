#!/usr/bin/env bash
# Pre-ship validation for a single team skill.
# Usage: ./scripts/validate-skill.sh <skill-name>
set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL=0

warn() { echo "WARN: $*"; }
err() { echo "FAIL: $*"; FAIL=1; }
ok() { echo "OK: $*"; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <skill-name>

  Validates SKILL.md frontmatter and expert four-piece set (if SOUL.md present).
  Exit 0 = ready to ship; exit 1 = blocked.
EOF
}

NAME="${1:-}"
if [[ -z "$NAME" ]]; then
  echo "Error: skill name required" >&2
  usage
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  err "Invalid skill name: $NAME (lowercase letters, numbers, hyphens only)"
  exit 1
fi

SKILL_DIR="${SKILLS_ROOT}/.cursor/skills/${NAME}"
SKILL_MD="${SKILL_DIR}/SKILL.md"

echo "=== validate-skill: ${NAME} ==="

if [[ ! -f "$SKILL_MD" ]]; then
  err "Missing ${SKILL_MD}"
  echo "=== blocked ==="
  exit 1
fi

# Frontmatter: name matches directory
fm_name=$(grep -m1 '^name:' "$SKILL_MD" | sed 's/^name:[[:space:]]*//' | tr -d '\r' || true)
if [[ -z "$fm_name" ]]; then
  err "Missing name: in SKILL.md frontmatter"
elif [[ "$fm_name" != "$NAME" ]]; then
  err "Frontmatter name '${fm_name}' does not match directory '${NAME}'"
else
  ok "name matches directory"
fi

# description required, ≤1536 chars (Claude listing cap)
if ! grep -q '^description:' "$SKILL_MD"; then
  err "Missing description: in SKILL.md frontmatter"
else
  desc_len=$(awk '
    /^description:/ { in_desc=1; line=$0; sub(/^description:[[:space:]]*/, "", line)
      if (line != "" && line != ">-" ) { print line; exit }
      next
    }
    in_desc && /^[a-zA-Z_-]+:/ { exit }
    in_desc { print; exit }
  ' "$SKILL_MD" | wc -c | tr -d ' ')
  # Also count block scalar lines if description uses >-
  if [[ "$desc_len" -lt 2 ]]; then
    desc_len=$(sed -n '/^description:/,/^[a-zA-Z_-]*:/p' "$SKILL_MD" | grep -v '^description:' | grep -v '^---' | grep -v '^[a-zA-Z_-]*:' | wc -c | tr -d ' ')
  fi
  if [[ "$desc_len" -gt 1536 ]]; then
    err "description too long (${desc_len} chars; max 1536 for Claude listing)"
  else
    ok "description present (${desc_len} chars)"
  fi
fi

if grep -q 'disable-model-invocation:' "$SKILL_MD"; then
  ok "disable-model-invocation set"
else
  warn "Missing disable-model-invocation in SKILL.md (default: add true for manual /slash skills)"
fi

# Expert four-piece if SOUL.md exists (expert skill)
if [[ -f "${SKILL_DIR}/SOUL.md" ]]; then
  ok "expert skill detected (SOUL.md present)"
  for f in SOUL.md SOURCES.md EVALUATION.md; do
    [[ -f "${SKILL_DIR}/${f}" ]] || err "Expert ${NAME} missing ${f}"
  done
  [[ -f "${SKILL_DIR}/SOURCES.md" && -f "${SKILL_DIR}/EVALUATION.md" ]] && ok "expert four-piece complete"
else
  ok "utility skill (no SOUL.md — four-piece not required)"
fi

# Cursor-only tool portability warnings
if grep -q 'AskQuestion' "$SKILL_MD" && ! grep -q 'AskUserQuestion' "$SKILL_MD"; then
  warn "Uses AskQuestion without Claude Code note (add: Claude Code: AskUserQuestion)"
fi
if grep -q 'cursor-ide-browser' "$SKILL_MD" && ! grep -q 'Claude Code' "$SKILL_MD"; then
  warn "References cursor-ide-browser without Claude Code portability note"
fi

if [[ "$FAIL" -eq 0 ]]; then
  echo "=== ready to ship ==="
else
  echo "=== blocked ==="
fi
exit "$FAIL"
