#!/usr/bin/env bash
# Ship a team skill: validate → global symlink (Cursor + Claude) → .shipped marker.
#
# Usage:
#   ./scripts/ship-skill.sh <name>              # validate + link + mark shipped
#   ./scripts/ship-skill.sh --all               # ship every skill with SKILL.md missing .shipped or broken link
#   ./scripts/ship-skill.sh --verify <name>     # validate + verify links only, no write
#   ./scripts/ship-skill.sh --mark-all-shipped  # one-time: touch .shipped on all skills with SKILL.md

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEAM_SKILLS="${SKILLS_ROOT}/.cursor/skills"
CURSOR_SKILLS="${HOME}/.cursor/skills"
CLAUDE_SKILLS="${HOME}/.claude/skills"

MODE="ship"
NAME=""

usage() {
  cat <<EOF
Usage: $(basename "$0") <skill-name>
       $(basename "$0") --all
       $(basename "$0") --verify <skill-name>
       $(basename "$0") --mark-all-shipped

  Canonical: ${TEAM_SKILLS}/<name>/
  Global:    ${CURSOR_SKILLS}/<name> and ${CLAUDE_SKILLS}/<name> (symlinks only)
EOF
}

is_linked() {
  local name="$1"
  local cursor_dest="${CURSOR_SKILLS}/${name}"
  local claude_dest="${CLAUDE_SKILLS}/${name}"
  [[ -L "$cursor_dest" ]] && [[ "$(readlink "$cursor_dest")" == "${TEAM_SKILLS}/${name}" ]] \
    && [[ -L "$claude_dest" ]] && [[ "$(readlink "$claude_dest")" == "${TEAM_SKILLS}/${name}" ]]
}

verify_links() {
  local name="$1"
  local cursor_dest="${CURSOR_SKILLS}/${name}"
  local claude_dest="${CLAUDE_SKILLS}/${name}"
  local ok=true

  if [[ -L "$cursor_dest" ]] && [[ "$(readlink "$cursor_dest")" == "${TEAM_SKILLS}/${name}" ]]; then
    echo "  cursor: OK -> $(readlink "$cursor_dest")"
  else
    echo "  cursor: MISSING or wrong ($cursor_dest)" >&2
    ok=false
  fi

  if [[ -L "$claude_dest" ]] && [[ "$(readlink "$claude_dest")" == "${TEAM_SKILLS}/${name}" ]]; then
    echo "  claude: OK -> $(readlink "$claude_dest")"
  else
    echo "  claude: MISSING or wrong ($claude_dest)" >&2
    ok=false
  fi

  $ok
}

ship_one() {
  local name="$1"
  local verify_only="${2:-false}"
  local skill_dir="${TEAM_SKILLS}/${name}"

  echo ""
  echo "=== ship-skill: ${name} ==="

  if [[ ! -f "${skill_dir}/SKILL.md" ]]; then
    echo "Error: ${skill_dir}/SKILL.md not found" >&2
    return 1
  fi

  if ! "${SKILLS_ROOT}/scripts/validate-skill.sh" "$name"; then
    echo "Error: validation failed — not shipping ${name}" >&2
    return 1
  fi

  if $verify_only; then
    echo "Verify only (no changes):"
    verify_links "$name" || return 1
    if [[ -f "${skill_dir}/.shipped" ]]; then
      echo "  .shipped: present"
    else
      echo "  .shipped: missing (draft)" >&2
      return 1
    fi
    return 0
  fi

  "${SKILLS_ROOT}/scripts/publish-skill.sh" "$name"
  touch "${skill_dir}/.shipped"

  echo ""
  echo "Verifying global symlinks..."
  verify_links "$name" || return 1

  echo ""
  echo "Shipped: ${name}"
  echo "  Canonical: ${skill_dir}/"
  echo "  Cursor:    ${CURSOR_SKILLS}/${name} -> team"
  echo "  Claude:    ${CLAUDE_SKILLS}/${name} -> team"
  echo "  Invoke:    /${name}"
  echo ""
  echo "Edits under team/.cursor/skills/${name}/ sync automatically via symlink."
}

mark_all_shipped() {
  echo "Marking all skills with SKILL.md as shipped (.shipped)..."
  for d in "${TEAM_SKILLS}"/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    name="$(basename "$d")"
    touch "${d}.shipped"
    echo "  marked: $name"
  done
}

ship_all() {
  local failed=0
  for d in "${TEAM_SKILLS}"/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    name="$(basename "$d")"
    if [[ ! -f "${d}.shipped" ]] || ! is_linked "$name"; then
      ship_one "$name" false || failed=1
    else
      echo "  skip (already shipped + linked): $name"
    fi
  done
  return "$failed"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) MODE="all"; shift ;;
    --verify) MODE="verify"; NAME="${2:?--verify requires skill name}"; shift 2 ;;
    --mark-all-shipped) MODE="mark-all"; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      if [[ -z "$NAME" ]]; then
        NAME="$1"
      else
        echo "Unknown argument: $1" >&2
        usage
        exit 1
      fi
      shift
      ;;
  esac
done

case "$MODE" in
  all)
    ship_all
    ;;
  verify)
    ship_one "$NAME" true
    ;;
  mark-all)
    mark_all_shipped
    ;;
  ship)
    if [[ -z "$NAME" ]]; then
      echo "Error: skill name required" >&2
      usage
      exit 1
    fi
    ship_one "$NAME" false
    ;;
esac
