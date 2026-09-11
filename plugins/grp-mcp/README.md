# GRP MCP

Drive an Acumatica ERP instance from Claude — read, write, run processes, and
diagnose failures.

Claude talks to **your** instance directly. Nothing is proxied through a server in
the middle, and your credentials stay on your machine.

## Prerequisite — `uv`

The plugin ships no binary. It runs the server from PyPI:

```
uvx --from grp-mcp-plugin==0.81.0rc34 grp-mcp
```

So [`uv`](https://docs.astral.sh/uv/) has to be installed once:

```
winget install astral-sh.uv
```

Check it with `uv --version`, and **reopen your terminal** if it is not found —
the installer adds `%USERPROFILE%\.local\bin` to PATH and open windows do not
pick that up. Claude itself does: it passes your user PATH through to the
plugin, verified on a running server.

You do not need Python. `uv` fetches its own.

> **This changed in rc15.** Until then this plugin carried a 23 MB
> `server/grp-mcp.exe` and needed no prerequisite. That binary was built with
> `fastembed` excluded, which left `find_tool` — semantic search over all 120
> tools — permanently unavailable on Windows. Bundling `fastembed` instead would
> have taken the binary to roughly 120 MB, re-downloaded on every single update
> because marketplace clones are shallow. Running from PyPI costs one `winget`
> line and fixes it.

## Setup — run it once

The server needs a `connections.json` holding your Acumatica instance and its
credentials. It can create one for you:

```
uvx --from grp-mcp-plugin==0.81.0rc34 grp-mcp-setup
```

That opens a config page in your browser. Add your instance, save, close the
window, and restart Claude. The file lands in `%USERPROFILE%\grp-mcp\` and the
server looks there on its own — **there is no environment variable to set.**

`%USERPROFILE%` rather than `%LOCALAPPDATA%` is deliberate. Claude installs as an
MSIX package, so processes it launches see `%LOCALAPPDATA%` redirected into the
package's `LocalCache` — and an app update empties that folder. Connection
profiles have been lost that way.

Already have a `connections.json` from someone else? Drop it in
`%USERPROFILE%\grp-mcp\` and skip the setup step. **Keep it out of OneDrive or
Dropbox** — it holds ERP passwords in clear text.

### Optional

Only if your config lives somewhere other than `%USERPROFILE%\grp-mcp\`:

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

## The first launch is slow, once

`uvx` downloads the wheel and its dependencies the first time, then caches them —
later launches start in about a second. Nothing else downloads — as of rc17
`find_tool` needs no model.

## Why the version is pinned

`--from grp-mcp-plugin==0.81.0rc34` names an exact version on purpose.
Unpinned, `uvx` would fetch whatever is newest at each launch, so the server
could change underneath you between one start and the next while the plugin
version stayed the same — untraceable the moment something breaks. New server
versions arrive by updating the plugin, like everything else.

`find_tool` needs no extra as of rc17: it ranks by a lexical scorer built into
the package, and measured better without the old embedding model than with it.

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

**Updating from 0.81.0-rc14 or earlier?** Install `uv` before you restart — see
the prerequisite at the top. Up to rc14 this plugin carried its own program and
needed nothing; without `uv` the server cannot start, and the symptom is no
Acumatica tools and no error message.

[bug]: https://github.com/anthropics/claude-code/issues/54276
