#!/usr/bin/env bash
# Generate or incrementally update a product repo's AGENTS.md Project Context table
# by detecting runtime, package manager, and test/build/lint commands.
#
# Usage:
#   ./scripts/init-project-context.sh <path-to-project>
#
# Behavior:
#   - No AGENTS.md at target -> copy templates/AGENTS.md, then fill in detected values.
#   - AGENTS.md exists -> only fill rows still marked "_(unset)_". Never touches
#     Known Footguns or any hand-written content. Idempotent — safe to re-run.

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="${SKILLS_ROOT}/templates/AGENTS.md"

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") <path-to-project>" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$1" && pwd)"
AGENTS_FILE="${PROJECT_DIR}/AGENTS.md"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: template not found: ${TEMPLATE}" >&2
  exit 1
fi

if [[ ! -f "$AGENTS_FILE" ]]; then
  cp "$TEMPLATE" "$AGENTS_FILE"
  echo "Created ${AGENTS_FILE} from template."
else
  echo "Found existing ${AGENTS_FILE} — updating Project Context rows only."
fi

cd "$PROJECT_DIR"

# --- Detect runtime(s) ---
RUNTIMES=()
[[ -f package.json ]] && RUNTIMES+=("Node $(node --version 2>/dev/null || echo 'unknown')")
{ [[ -f requirements.txt ]] || [[ -f pyproject.toml ]]; } && RUNTIMES+=("Python $(python3 --version 2>/dev/null | sed 's/Python //')")
[[ -f go.mod ]] && RUNTIMES+=("Go $(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')")
[[ -f Cargo.toml ]] && RUNTIMES+=("Rust $(cargo --version 2>/dev/null | awk '{print $2}')")
[[ -f Gemfile ]] && RUNTIMES+=("Ruby $(ruby --version 2>/dev/null | awk '{print $2}')")
[[ -f composer.json ]] && RUNTIMES+=("PHP $(php --version 2>/dev/null | head -1 | awk '{print $2}')")
RUNTIME=""
if [[ ${#RUNTIMES[@]} -gt 0 ]]; then
  RUNTIME=$(IFS=" / "; echo "${RUNTIMES[*]}")
fi

# --- Detect package manager ---
PKG_MGR=""
RUN_PREFIX=""
if [[ -f pnpm-lock.yaml ]]; then PKG_MGR="pnpm"; RUN_PREFIX="pnpm"
elif [[ -f yarn.lock ]]; then PKG_MGR="yarn"; RUN_PREFIX="yarn"
elif [[ -f bun.lockb ]]; then PKG_MGR="bun"; RUN_PREFIX="bun run"
elif [[ -f package-lock.json ]]; then PKG_MGR="npm"; RUN_PREFIX="npm run"
elif [[ -f poetry.lock ]]; then PKG_MGR="poetry"
elif [[ -f Pipfile.lock ]]; then PKG_MGR="pipenv"
elif [[ -f requirements.txt ]]; then PKG_MGR="pip"
elif [[ -f go.mod ]]; then PKG_MGR="go modules"
elif [[ -f Cargo.lock ]]; then PKG_MGR="cargo"
fi
[[ -f package.json ]] && [[ -z "$RUN_PREFIX" ]] && RUN_PREFIX="npm run"

# --- Detect test/build/lint commands ---
TEST_CMD=""
BUILD_CMD=""
LINT_CMD=""

if [[ -f package.json ]] && command -v jq >/dev/null 2>&1; then
  script_test=$(jq -r '.scripts.test // empty' package.json)
  script_build=$(jq -r '.scripts.build // empty' package.json)
  script_lint=$(jq -r '.scripts.lint // empty' package.json)
  script_typecheck=$(jq -r '.scripts.typecheck // .scripts["type-check"] // empty' package.json)
  [[ -n "$script_test" ]] && TEST_CMD="${RUN_PREFIX} test"
  [[ -n "$script_build" ]] && BUILD_CMD="${RUN_PREFIX} build"
  if [[ -n "$script_lint" && -n "$script_typecheck" ]]; then
    LINT_CMD="${RUN_PREFIX} lint && ${RUN_PREFIX} typecheck"
  elif [[ -n "$script_lint" ]]; then
    LINT_CMD="${RUN_PREFIX} lint"
  elif [[ -n "$script_typecheck" ]]; then
    LINT_CMD="${RUN_PREFIX} typecheck"
  fi
elif [[ -f pyproject.toml || -f requirements.txt ]]; then
  [[ -d tests ]] || [[ -d test ]] && TEST_CMD="pytest"
  command -v ruff >/dev/null 2>&1 && LINT_CMD="ruff check ."
elif [[ -f go.mod ]]; then
  TEST_CMD="go test ./..."
  BUILD_CMD="go build ./..."
elif [[ -f Cargo.toml ]]; then
  TEST_CMD="cargo test"
  BUILD_CMD="cargo build"
fi

# --- Env config ---
ENV_CFG=""
[[ -f .env.example ]] && ENV_CFG="see .env.example"

# --- Write detected values into AGENTS.md (only replaces rows still "_(unset)_") ---
update_row() {
  local label="$1"
  local value="$2"
  [[ -z "$value" ]] && return
  local line
  line=$(grep -n "^| ${label} |" "$AGENTS_FILE" | grep '_(unset)_' | head -1 | cut -d: -f1) || true
  if [[ -n "$line" ]]; then
    local esc
    esc=$(printf '%s' "$value" | sed -e 's/[&/\]/\\&/g')
    sed -i.bak "${line}s#| ${label} | .* |#| ${label} | ${esc} |#" "$AGENTS_FILE"
    rm -f "${AGENTS_FILE}.bak"
    echo "  set ${label}: ${value}"
  fi
}

update_row "Runtime" "$RUNTIME"
update_row "Package manager" "$PKG_MGR"
update_row "Test command" "$TEST_CMD"
update_row "Build command" "$BUILD_CMD"
update_row "Lint / typecheck command" "$LINT_CMD"
update_row "Env config" "$ENV_CFG"

echo "Done. Review ${AGENTS_FILE} and fill in any remaining _(unset)_ rows by hand."
