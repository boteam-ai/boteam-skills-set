#!/usr/bin/env bash
# Append lightweight expert usage to ops/usage/index.json and EVALUATION.md usage log.
# Usage: log-expert-use.sh <slug> <score-1-5> "<note>" [project]
# Example: ./scripts/log-expert-use.sh product-manager 5 "Scoped MVP for Chrome ext" my-extension

set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SLUG="${1:?slug required}"
SCORE="${2:?score 1-5 required}"
NOTE="${3:?note required}"
PROJECT="${4:-unknown}"
DATE="$(date +%Y-%m-%d)"
TIME="$(date +%H:%M)"
INDEX="${SKILLS_ROOT}/ops/usage/index.json"
EVAL="${SKILLS_ROOT}/.cursor/skills/${SLUG}/EVALUATION.md"

if [[ ! "$SCORE" =~ ^[1-5]$ ]]; then
  echo "Score must be 1-5" >&2
  exit 1
fi

if [[ ! -f "$EVAL" ]]; then
  echo "Unknown expert slug: $SLUG (no EVALUATION.md)" >&2
  exit 1
fi

# Escape note for JSON (minimal)
NOTE_JSON=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$NOTE")

python3 <<PY
import json
from pathlib import Path

index_path = Path("${INDEX}")
data = json.loads(index_path.read_text())
entry = {
    "date": "${DATE}",
    "time": "${TIME}",
    "slug": "${SLUG}",
    "useful": int("${SCORE}"),
    "note": ${NOTE_JSON},
    "project": "${PROJECT}",
}
data.setdefault("entries", []).append(entry)
index_path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print(f"Logged to {index_path}")
PY

# Append to EVALUATION usage log table (after header row)
if grep -q "## Usage log" "$EVAL"; then
  # shellcheck disable=SC2016
  printf '| %s | %s | %s | %s |\n' "$DATE" "$NOTE" "$SCORE" "project: $PROJECT" >> "$EVAL"
  echo "Appended to $EVAL"
fi
