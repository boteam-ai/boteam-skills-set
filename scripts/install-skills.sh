#!/usr/bin/env bash
# Install one-person-company expert skills-set for global or per-project use.
# Usage:
#   ./scripts/install-skills.sh --global          # symlink skills -> ~/.cursor/skills/ + ~/.claude/skills/
#   ./scripts/install-skills.sh --project /path   # symlink skills + commands into a project
#   ./scripts/install-skills.sh --global --shipped-only  # link only .shipped skills (respect drafts)

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL_CURSOR_SKILLS="${HOME}/.cursor/skills"
GLOBAL_CLAUDE_SKILLS="${HOME}/.claude/skills"
GLOBAL_COMMANDS="${HOME}/.cursor/commands"
BACKUP_CURSOR="${GLOBAL_CURSOR_SKILLS}/.team-install-backups"
BACKUP_CLAUDE="${GLOBAL_CLAUDE_SKILLS}/.team-install-backups"

MODE=""
PROJECT=""
UNLINK=false
SKIP_SKILLS=false
SHIPPED_ONLY=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [--global | --project PATH] [--unlink] [--skip-skills]

  --global           Symlink all skills-set to ~/.cursor/skills/ and ~/.claude/skills/.
  --project PATH     Symlink commands + QA rules + AGENTS.md into PATH/.cursor/
                     (and skills unless --skip-skills — see setup-project.sh).
  --skip-skills      With --project: skip .cursor/skills/ (use when global install
                     already links skills-set — avoids duplicate symlinks).
  --unlink           With --global: remove team symlinks from ~/.cursor/skills/ and ~/.claude/skills/
  --shipped-only     With --global: link only skills that have .shipped (skip drafts)

Skills root: ${SKILLS_ROOT}
EOF
}

is_team_skill_symlink() {
  local dest="$1"
  local name="$2"
  [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "${SKILLS_ROOT}/.cursor/skills/${name}" ]]
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) MODE="global"; shift ;;
    --project) MODE="project"; PROJECT="${2:?--project requires a path}"; shift 2 ;;
    --skip-skills) SKIP_SKILLS=true; shift ;;
    --shipped-only) SHIPPED_ONLY=true; shift ;;
    --unlink) UNLINK=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Error: specify --global or --project PATH" >&2
  usage
  exit 1
fi

link_skill() {
  local name="$1"
  local dest="$2"
  local backup_root="$3"
  local src="${SKILLS_ROOT}/.cursor/skills/${name}"

  if [[ ! -d "$src" ]]; then
    echo "  skip (missing): $name"
    return
  fi

  if [[ -L "$dest" ]]; then
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$backup_root"
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local backup="${backup_root}/${name}.${ts}"
    echo "  backup existing -> ${backup}"
    mv "$dest" "$backup"
  fi

  ln -sfn "$src" "$dest"
  echo "  linked: $name -> $src"
}

link_rule() {
  local name="$1"
  local src="${SKILLS_ROOT}/.cursor/rules/${name}"
  local dest="$2"

  if [[ ! -f "$src" ]]; then
    echo "  skip (missing): $name"
    return
  fi

  if [[ -L "$dest" ]]; then
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    mkdir -p "$BACKUP_CURSOR"
    local ts
    ts="$(date +%Y%m%d-%H%M%S)"
    local backup="${BACKUP_CURSOR}/${name}.${ts}"
    echo "  backup existing -> ${backup}"
    mv "$dest" "$backup"
  fi

  ln -sfn "$src" "$dest"
  echo "  linked rule: $name"
}

unlink_global_dir() {
  local global_dir="$1"
  echo "Removing global team skill symlinks from ${global_dir}..."
  mkdir -p "$global_dir"
  for d in "${SKILLS_ROOT}/.cursor/skills"/*/; do
    name="$(basename "$d")"
    [[ "$name" == "_extras" ]] && continue
    dest="${global_dir}/${name}"
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "${SKILLS_ROOT}/.cursor/skills/${name}" ]]; then
      rm -f "$dest"
      echo "  removed: $name"
    fi
  done
}

unlink_global() {
  unlink_global_dir "$GLOBAL_CURSOR_SKILLS"
  unlink_global_dir "$GLOBAL_CLAUDE_SKILLS"
}

install_global_skills() {
  if $SHIPPED_ONLY; then
    echo "Installing shipped skills-set globally -> ${GLOBAL_CURSOR_SKILLS} + ${GLOBAL_CLAUDE_SKILLS}"
  else
    echo "Installing all skills-set globally -> ${GLOBAL_CURSOR_SKILLS} + ${GLOBAL_CLAUDE_SKILLS}"
  fi
  mkdir -p "$GLOBAL_CURSOR_SKILLS" "$GLOBAL_CLAUDE_SKILLS"
  for d in "${SKILLS_ROOT}/.cursor/skills"/*/; do
    name="$(basename "$d")"
    [[ "$name" == "_extras" ]] && continue
    if $SHIPPED_ONLY && [[ ! -f "${d}.shipped" ]]; then
      echo "  skip draft (no .shipped): $name"
      continue
    fi
    link_skill "$name" "${GLOBAL_CURSOR_SKILLS}/${name}" "$BACKUP_CURSOR"
    link_skill "$name" "${GLOBAL_CLAUDE_SKILLS}/${name}" "$BACKUP_CLAUDE"
  done
  echo ""
  echo "Done. Skills available in every Cursor project and Claude Code via /slash (e.g. /boteam, /product-manager)."
  echo "Team commands (/product-team, /clevel) are project-only unless you run:"
  echo "  $(basename "$0") --project /path/to/your-app"
  echo ""
  echo "HR / hire / weekly cron: run from skills-set repo (${SKILLS_ROOT}) or open it as workspace."
}

install_project() {
  local proj
  proj="$(cd "$PROJECT" && pwd)"
  local skills_dir="${proj}/.cursor/skills"
  local commands_dir="${proj}/.cursor/commands"
  local rules_dir="${proj}/.cursor/rules"
  echo "Installing team project wiring -> ${proj}"
  mkdir -p "$skills_dir" "$commands_dir" "$rules_dir"

  if $SKIP_SKILLS; then
    echo "  skip project skills (--skip-skills; use ~/.cursor/skills/ global links)"
  else
    for d in "${SKILLS_ROOT}/.cursor/skills"/*/; do
      name="$(basename "$d")"
      [[ "$name" == "_extras" ]] && continue
      link_skill "$name" "${skills_dir}/${name}" "${proj}/.cursor/.team-install-backups"
    done
  fi

  for f in "${SKILLS_ROOT}/.cursor/commands"/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    dest="${commands_dir}/${name}"
    if [[ -L "$dest" ]]; then
      rm -f "$dest"
    elif [[ -e "$dest" ]]; then
      mkdir -p "${proj}/.cursor/.team-install-backups"
      mv "$dest" "${proj}/.cursor/.team-install-backups/${name}.$(date +%Y%m%d-%H%M%S)"
    fi
    ln -sfn "$f" "$dest"
    echo "  linked command: /${name%.md}"
  done

  # QA loop rules — product-repo scoped, not team-guardrails.mdc (org HQ only)
  link_rule "context-before-code.mdc" "${rules_dir}/context-before-code.mdc"
  link_rule "evidence-before-done.mdc" "${rules_dir}/evidence-before-done.mdc"

  if [[ ! -f "${proj}/AGENTS.md" ]]; then
    "${SKILLS_ROOT}/scripts/init-project-context.sh" "$proj"
  else
    echo "  AGENTS.md exists — run init-project-context.sh separately to fill _(unset)_ rows"
  fi

  echo ""
  if $SKIP_SKILLS; then
    echo "Done. Project ${proj} has slash commands, QA loop rules, and AGENTS.md (skills via global)."
  else
    echo "Done. Project ${proj} has skills-set, slash commands, QA loop rules, and AGENTS.md."
  fi
}

if [[ "$MODE" == "global" ]]; then
  if $UNLINK; then
    unlink_global
    exit 0
  fi
  install_global_skills
elif [[ "$MODE" == "project" ]]; then
  install_project
fi
