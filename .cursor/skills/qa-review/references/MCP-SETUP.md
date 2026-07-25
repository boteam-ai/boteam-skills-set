# Playwright MCP — Global Setup

`/qa-review` uses the Playwright MCP server for UI smoke checks (navigate, console errors,
screenshot) when a diff touches UI files. This is a **one-time, global** setup — it is not
part of any product repo and must never be committed with secrets.

## Prerequisites

- Node.js 20+ (`node --version`)

## 1. Add the server to `~/.cursor/mcp.json`

Merge this block into the `mcpServers` object. **Do not overwrite the file** — other MCP
servers (e.g. `cursor-ide-browser`) may already be configured there.

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

Use `scripts/merge-playwright-mcp.sh` (below) to do this merge safely, or edit the file by
hand.

## 2. Install browser binaries (first run only)

```bash
npx -y playwright install chromium
```

## 3. Restart Cursor and verify

1. Restart Cursor completely (MCP servers are not always hot-reloaded).
2. Open **Settings → MCP** (or **Tools & MCP**) and confirm `playwright` shows a green/connected status.
3. Before the first tool call in any session, **read the tool's descriptor/schema** — same
   rule as any other MCP tool (see [`lesson/SKILL.md`](../../lesson/SKILL.md) example on
   MCP parameter mistakes). Never guess parameters.

## Fallback: no Playwright MCP available

If the user has not installed Playwright MCP and does not want to, `/qa-review` falls back to:

1. `cursor-ide-browser` MCP if enabled (already used by [`demo/SKILL.md`](../../demo/SKILL.md)) — reuse its existing tab, do not spawn a second browser.
2. If neither is available, skip the browser smoke step and note in the report:
   `Browser smoke skipped — no Playwright MCP or cursor-ide-browser MCP configured.`

Never fake a browser check or claim a UI was verified without one of these two MCP tools.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Server shows red / not connected | Restart Cursor; check Settings → MCP → logs |
| `spawn ENOENT` in logs | Replace `"command": "npx"` with the absolute path from `which npx` |
| `0 tools enabled` | Confirm Node 20+; re-run `npx -y playwright install chromium` |
| Works in terminal, not in Cursor | PATH mismatch — use absolute binary paths in `command` |
