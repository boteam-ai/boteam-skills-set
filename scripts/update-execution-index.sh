#!/usr/bin/env bash
# Rebuild ops/executions/index.json from markdown logs in ops/executions/
set -euo pipefail

SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXEC_DIR="${SKILLS_ROOT}/ops/executions"
INDEX="${EXEC_DIR}/index.json"

python3 <<PY
import json, re
from pathlib import Path

exec_dir = Path("${EXEC_DIR}")
entries = []
for p in sorted(exec_dir.glob("*.md")):
    if p.name == "README.md":
        continue
    text = p.read_text(encoding="utf-8", errors="replace")
    m = re.match(r"(\d{4}-\d{2}-\d{2})-(.+)\.md$", p.name)
    if not m:
        continue
    date, trigger = m.group(1), m.group(2)
    summary = ""
    for line in text.splitlines():
        if line.startswith("## Intent") or line.startswith("One sentence"):
            continue
        if line.strip() and not line.startswith("#") and not line.startswith("-"):
            summary = line.strip()[:120]
            break
        if line.startswith("- **Decision:**"):
            summary = line.replace("- **Decision:**", "").strip()[:120]
            break
    entries.append({
        "date": date,
        "trigger": trigger,
        "path": f"ops/executions/{p.name}",
        "summary": summary or trigger,
    })

entries.sort(key=lambda e: (e["date"], e["trigger"]), reverse=True)
out = {"version": 1, "description": "Index of org-level execution logs. Regenerate with scripts/update-execution-index.sh", "entries": entries}
exec_dir.joinpath("index.json").write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
print(f"Updated {len(entries)} entries -> {exec_dir}/index.json")
PY
