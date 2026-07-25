#!/usr/bin/env bash
# Merge the Playwright MCP server into ~/.cursor/mcp.json without touching
# any other configured servers. Idempotent — safe to re-run.
#
# Usage:
#   ./scripts/merge-playwright-mcp.sh

set -euo pipefail

MCP_JSON="${HOME}/.cursor/mcp.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required (brew install jq)." >&2
  exit 1
fi

mkdir -p "$(dirname "$MCP_JSON")"

if [[ ! -f "$MCP_JSON" ]]; then
  echo '{"mcpServers":{}}' > "$MCP_JSON"
  echo "Created ${MCP_JSON}"
fi

if ! jq -e . "$MCP_JSON" >/dev/null 2>&1; then
  echo "Error: ${MCP_JSON} is not valid JSON — fix it manually before merging." >&2
  exit 1
fi

if jq -e '.mcpServers.playwright' "$MCP_JSON" >/dev/null 2>&1; then
  echo "playwright already configured in ${MCP_JSON} — nothing to do."
  exit 0
fi

TMP="$(mktemp)"
jq '.mcpServers.playwright = {"command": "npx", "args": ["-y", "@playwright/mcp@latest"]}' \
  "$MCP_JSON" > "$TMP"
mv "$TMP" "$MCP_JSON"

echo "Added playwright MCP server to ${MCP_JSON}."
echo "Next steps:"
echo "  1. npx -y playwright install chromium"
echo "  2. Restart Cursor"
echo "  3. Settings -> MCP -> confirm 'playwright' is connected"
