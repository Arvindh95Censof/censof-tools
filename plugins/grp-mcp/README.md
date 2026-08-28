# GRP MCP

Drive an Acumatica ERP instance from Claude — read, write, run processes, and
diagnose failures.

Claude talks to **your** instance directly. Nothing is proxied through a server in
the middle, and your credentials stay on your machine.

This plugin carries its own Python runtime. You do not need Python installed.

## Setup

**If you created your config with `GRP-MCP-Setup.exe`, there is nothing to set.**
The server looks in `%LOCALAPPDATA%\grp-mcp\` — the same place the setup
tool writes — so it finds `connections.json` and `kb_server.json` on its own.

Only if your config lives somewhere else, point at it explicitly:

```
GRP_MCP_CONNECTIONS = C:\path\to\connections.json
```

That file holds your Acumatica instance profiles and their credentials. Ask
whoever set up your GRP environment, or create one with `GRP-MCP-Setup.exe` from
the GRP MCP package.

**Keep it out of OneDrive or Dropbox** — it holds ERP passwords in clear text.

### Optional

| Variable | Default | What it does |
|---|---|---|
| `GRP_MCP_CORE_ONLY` | `true` | Lists ~17 core tools instead of all 120, handing back roughly 48k tokens of context. The rest stay reachable via `find_tool` then `call_tool`. |
| `GRP_MCP_KB_SERVER` | blank | Path to a `kb_server.json`. The server consults that knowledge base itself before every write. Blank still works — writes just carry no KB evidence. |
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
