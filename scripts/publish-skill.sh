#!/usr/bin/env bash
# Publish a skill: canonical copy in team repo, globally linked for Cursor + Claude.
#
# Usage:
#   ./scripts/publish-skill.sh <skill-name>              # link existing team skill globally
#   ./scripts/publish-skill.sh <skill-name> --from PATH  # import then link
#   ./scripts/publish-skill.sh --from-claude <name>      # import ~/.claude/skills/<name>
#   ./scripts/publish-skill.sh --from-cursor <name>      # import ~/.cursor/skills/<name>
#
# Canonical location:  ${SKILLS_ROOT}/.cursor/skills/<name>/
# Global Cursor:      ~/.cursor/skills/<name>  -> team
# Global Claude:      ~/.claude/skills/<name>  -> team

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEAM_SKILLS="${SKILLS_ROOT}/.cursor/skills"
CURSOR_SKILLS="${HOME}/.cursor/skills"
CLAUDE_SKILLS="${HOME}/.claude/skills"
BACKUP_CURSOR="${CURSOR_SKILLS}/.team-install-backups"
BACKUP_CLAUDE="${CLAUDE_SKILLS}/.team-install-backups"

usage() {
  cat <<EOF
Usage: $(basename "$0") <skill-name> [--from PATH]
       $(basename "$0") --from-claude <skill-name>
       $(basename "$0") --from-cursor <skill-name>

  Canonical: ${TEAM_SKILLS}/<name>/
  Links:     ${CURSOR_SKILLS}/<name> and ${CLAUDE_SKILLS}/<name>
EOF
}

is_team_symlink() {
  local dest="$1"
  local name="$2"
  [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "${TEAM_SKILLS}/${name}" ]]
}

backup_and_remove() {
  local path="$1"
  local name="$2"
  local backup_root="$3"

  if [[ -L "$path" ]]; then
    rm -f "$path"
    return
  fi
  if [[ -e "$path" ]]; then
    mkdir -p "$backup_root"
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    echo "  backup: ${path} -> ${backup_root}/${name}.${ts}"
    mv "$path" "${backup_root}/${name}.${ts}"
  fi
}

import_skill() {
  local name="$1"
  local src="$2"
  local dest="${TEAM_SKILLS}/${name}"

  if [[ ! -d "$src" ]]; then
    echo "Error: source not found: $src" >&2
    exit 1
  fi
  if [[ ! -f "${src}/SKILL.md" ]]; then
    echo "Error: ${src}/SKILL.md missing" >&2
    exit 1
  fi

  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${src}/" "${dest}/"
  else
    rm -rf "${dest:?}/"*
    cp -R "${src}/." "$dest/"
  fi
  echo "  imported: $name -> $dest"
}

link_global() {
  local name="$1"
  local src="${TEAM_SKILLS}/${name}"
  local cursor_dest="${CURSOR_SKILLS}/${name}"
  local claude_dest="${CLAUDE_SKILLS}/${name}"

  if [[ ! -d "$src" ]] || [[ ! -f "${src}/SKILL.md" ]]; then
    echo "Error: team skill missing: ${src}/SKILL.md" >&2
    exit 1
  fi

  mkdir -p "$CURSOR_SKILLS" "$CLAUDE_SKILLS"

  if is_team_symlink "$cursor_dest" "$name"; then
    echo "  cursor: already linked ($name)"
  else
    backup_and_remove "$cursor_dest" "$name" "$BACKUP_CURSOR"
    ln -sfn "$src" "$cursor_dest"
    echo "  cursor: linked $name -> $src"
  fi

  if is_team_symlink "$claude_dest" "$name"; then
    echo "  claude: already linked ($name)"
  else
    backup_and_remove "$claude_dest" "$name" "$BACKUP_CLAUDE"
    ln -sfn "$src" "$claude_dest"
    echo "  claude: linked $name -> $src"
  fi
}

NAME=""
FROM=""
MODE="team"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)
      FROM="${2:?--from requires a path}"
      MODE="import"
      shift 2
      ;;
    --from-claude)
      MODE="from-claude"
      NAME="${2:?--from-claude requires skill name}"
      shift 2
      ;;
    --from-cursor)
      MODE="from-cursor"
      NAME="${2:?--from-cursor requires skill name}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
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

if [[ -z "$NAME" ]]; then
  echo "Error: skill name required" >&2
  usage
  exit 1
fi

if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
  echo "Error: skill name must be lowercase letters, numbers, hyphens only" >&2
  exit 1
fi

echo "Publishing skill: $NAME"

case "$MODE" in
  from-claude)
    import_skill "$NAME" "${CLAUDE_SKILLS}/${NAME}"
    ;;
  from-cursor)
    import_skill "$NAME" "${CURSOR_SKILLS}/${NAME}"
    ;;
  import)
    import_skill "$NAME" "$FROM"
    ;;
  team)
    if [[ ! -d "${TEAM_SKILLS}/${NAME}" ]]; then
      # Auto-detect: Claude first, then Cursor real dir
      if [[ -d "${CLAUDE_SKILLS}/${NAME}" ]] && [[ ! -L "${CLAUDE_SKILLS}/${NAME}" ]]; then
        echo "  auto-import from Claude: ${CLAUDE_SKILLS}/${NAME}"
        import_skill "$NAME" "${CLAUDE_SKILLS}/${NAME}"
      elif [[ -d "${CURSOR_SKILLS}/${NAME}" ]] && [[ ! -L "${CURSOR_SKILLS}/${NAME}" ]]; then
        echo "  auto-import from Cursor: ${CURSOR_SKILLS}/${NAME}"
        import_skill "$NAME" "${CURSOR_SKILLS}/${NAME}"
      else
        echo "Error: ${TEAM_SKILLS}/${NAME} not found; use --from PATH or create SKILL.md first" >&2
        exit 1
      fi
    fi
    ;;
esac

link_global "$NAME"

echo ""
echo "Done. Skill '${NAME}' is canonical in team and available globally in Cursor + Claude."
