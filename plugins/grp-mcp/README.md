# GRP MCP

Drive an Acumatica ERP instance from Claude — read, write, run processes, and
diagnose failures.

Claude talks to **your** instance directly. Nothing is proxied through a server in
the middle, and your credentials stay on your machine.

This plugin carries its own Python runtime. You do not need Python installed.

## Setup — run it once

The plugin needs a `connections.json` holding your Acumatica instance and its
credentials. The plugin can create it for you. In PowerShell:

```
& "$env:USERPROFILE\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp\server\grp-mcp.exe" --setup
```

That opens a config page in your browser. Add your instance, save, close the
window, and restart Claude. The file lands in `%LOCALAPPDATA%\grp-mcp\` and the
server looks there on its own — **there is no environment variable to set.**

If the command reports the path was not found, the plugin is installed but the
marketplace clone has moved. Find the binary with:

```
Get-ChildItem "$env:USERPROFILE\.claude\plugins" -Recurse -Filter grp-mcp.exe | Select-Object -First 1 -ExpandProperty FullName
```

Already have a `connections.json` from someone else? Drop it in
`%LOCALAPPDATA%\grp-mcp\` and skip the setup step. **Keep it out of OneDrive or
Dropbox** — it holds ERP passwords in clear text.

### Optional

Only if your config lives somewhere other than `%LOCALAPPDATA%\grp-mcp\`:

| Variable | Default | What it does |
|---|---|---|
| `GRP_MCP_CONNECTIONS` | auto | Full path to a `connections.json` elsewhere. |
| `GRP_MCP_KB_SERVER` | auto | Path to a `kb_server.json`. The server consults that knowledge base itself before every write. Blank still works — writes just carry no KB evidence. |
| `GRP_MCP_CORE_ONLY` | `true` | Lists ~17 core tools instead of all 120, handing back roughly 48k tokens of context. The rest stay reachable via `find_tool` then `call_tool`. |
| `GRP_MCP_ALLOW_ADMIN` | `false` | Lets Claude save changes to connection profiles, including the write/delete switches. Leave off unless reconfiguring. |

## Writes are off until you turn them on

Each profile carries `allow_write`, `allow_delete` and `allow_publish`, all
defaulting to off, so a profile pointed at production stays read-only no matter
what Claude is asked to do.

A clean `ok` from Acumatica proves nothing — success-shaped no-ops are routine.
Writes are read back and compared against what was sent; anything that cannot be
confirmed is reported as **unverified** rather than as success. Nothing is ever
rolled back automatically.

## First call after starting Claude is slower

The server is a single self-contained executable, so it unpacks itself to a temp
folder on each launch — expect roughly five seconds before the first tool
answers. That happens once per Claude session, not per tool call.

## Check it works

Ask Claude `whoami` — it reports the active profile, tenant, endpoint and
reachability.

If you edit `connections.json` while Claude is running, ask for `reload_config`;
the server only reads that file at startup.

## Updates need the Claude Code CLI

The Update button in the desktop app does not work — it stays greyed out even
when a new version has been published ([a known bug][bug]). Install the CLI
once:

```
winget install Anthropic.ClaudeCode
```

Then, to update, run both lines in this order:

```
claude plugin marketplace update censof-tools
claude plugin update grp-mcp@censof-tools
```

The first line is not optional and is invisible from the plugin's page: until
the marketplace is refreshed, that page reports your installed version as the
latest and is telling the truth about what it has.

[bug]: https://github.com/anthropics/claude-code/issues/54276
