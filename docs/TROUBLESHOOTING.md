# Troubleshooting

Symptom, cause, fix. Covers both plugins; sections are marked where they apply
to only one.

If nothing here matches and you have `grp-mcp`, send whoever supports this the
output of `whoami` and `kb_status` — those two answer most questions at once.

**The first thing to try, for almost anything: fully restart Claude.** Quit the
application, do not just start a new conversation. A running server keeps the
configuration and environment it started with, so most "I changed it and nothing
happened" reports are a missing restart.

---

## Installing

### `claude` is not recognized

The CLI is not installed, or PowerShell has not been reopened since it was.

```powershell
winget install Anthropic.ClaudeCode
```

Close and reopen PowerShell. Still failing? Sign out of Windows and back in —
PATH changes need a fresh session.

Note that **Claude Desktop** (the chat app) is a separate application and ships
no `claude` command. The Claude Code desktop app and the Claude Code CLI are
what this package targets, and they share one plugin store — install once,
and both see it.

### `repository not found` when adding the marketplace

Almost always permission, not a typo. GitHub returns 404 rather than "forbidden"
for private repositories you cannot see.

Open <https://github.com/Arvindh95Censof/censof-tools> in a browser. If you
cannot see it there, request access — nothing will work until you can.

### `Authentication failed` / `could not read Username`

Git cannot sign in as you from the command line. Install
[Git for Windows](https://git-scm.com/download/win), which includes Git
Credential Manager, then run the marketplace command again — it will prompt you
to sign in.

### `Nested zip files are not allowed`

You are installing a build that was packaged the wrong way. Report it; it is not
something you can fix locally.

---

## Starting up

### No tools appear from either plugin

0. **Are you in Claude Code, or in Claude Desktop?** The chat app does not use
   plugins at all — it needs the `.mcpb` extension instead. This is the one
   failure where every command succeeded and nothing is wrong with your install.
1. `claude plugin list` — is the plugin you installed there,
   `grp-mcp@censof-tools` or `censof-mcp@censof-tools`?
2. If yes, restart Claude completely.
3. Still nothing: the server may be failing at launch. Ask Claude to check its
   MCP server status, or reinstall:
   ```powershell
   claude plugin install grp-mcp@censof-tools
   ```

### The first tool call takes about five seconds

Expected. The server is a single self-contained executable and unpacks itself to
a temporary folder on each launch. Once per Claude session, not per call.

---

## Connections

### "No configuration found"

No `connections.json` anywhere it looks. Run `tools\Edit-Connections.cmd`, add a
profile, Save, restart Claude.

### `whoami` says `reachable: false`

Work through it in this order — `reachable` covers only the main REST plane, so
it is specifically the credentials-and-URL check.

| Check | How |
|---|---|
| **base_url** | Must include the instance path and no trailing slash: `https://host/MyCompany`, not `https://host/` or `https://host/MyCompany/frames/...`. Paste it into a browser — you should get the Acumatica sign-in page. |
| **tenant** | Must match the *Company* dropdown value exactly, spaces and all. |
| **username / password** | Try them in the browser. |
| **client_id / client_secret** | From a Connected Application using the *Resource Owner Password Credentials* flow. The secret is shown once — if unsure, create a new one. |
| **API role** | The user needs the Web Services API role, or the login is rejected. |

### "API Login Limit" / logins suddenly failing

Acumatica licenses a limited number of concurrent *Web Services API Users* — a
trial allows two, and sessions linger. Ask Claude:

> release_sessions

### Claude is using the wrong instance

Ask `whoami` to see which is active. Change it in the config page, or ask Claude
to `set_active_instance`. For one request, just name it: *"read that from the
staging instance."*

### I edited connections.json and nothing changed

Two possibilities, in order of likelihood:

1. **Claude was not restarted.** The file is read at startup. Ask for
   `reload_config`, or restart.
2. **A different file is winning.** A `connections.json` in the current working
   directory takes precedence over the one in `%USERPROFILE%\grp-mcp`, and a
   `GRP_MCP_CONNECTIONS` variable beats both. Ask `whoami` — it reports the file
   actually in use. See [CONFIGURE.md](CONFIGURE.md).

---

## Writes

### "This instance is read-only" / a write is refused

Working as designed. Every profile starts with `allow_write`, `allow_delete` and
`allow_publish` off. Turn on what you need in the config page, for that profile,
then restart Claude.

### A write came back `unverified`

Not a failure and not a success — it means the write could not be *confirmed*.
Acumatica returns success-shaped responses for writes that quietly did nothing,
so results are read back and compared, and anything unconfirmable is reported
honestly rather than optimistically.

The result names the instruments to find out what really happened. Nothing is
rolled back automatically — cross-plane undo is not safe, so a failure is
surfaced, never silently reversed. Check the record in Acumatica before retrying,
or the retry may duplicate work that already succeeded.

---

## Knowledge base

### Every search fails with an auth error — `censof-mcp`

The token is not reaching the server. Run `tools\Set-KB-Token.cmd`, then
**restart Claude Code completely.** To confirm it is genuinely stored:

```powershell
([Environment]::GetEnvironmentVariable('CENSOF_MCP_TOKEN','User')).Length
```

A number means it is set. If `KB_TOKEN` is set but `CENSOF_MCP_TOKEN` is not,
that is the one-token-two-names trap — the tool above fixes both at once.

### `kb_status` says `configured: false` — `grp-mcp`

No `kb_server.json` found. Add it in the config page's knowledge-base section,
or copy `templates\kb_server.example.json` into `%USERPROFILE%\grp-mcp\`.

### `variable_is_set: false` — `grp-mcp`

`kb_server.json` refers to `${KB_TOKEN}` but that variable is not reaching the
server.

1. Run `tools\Set-KB-Token.cmd`.
2. **Restart Claude completely.**

To confirm the value is genuinely stored:

```powershell
([Environment]::GetEnvironmentVariable('KB_TOKEN','User')).Length
```

A number means it is set. Use this rather than `$env:KB_TOKEN`, which only shows
what your current window inherited when it opened.

### `Illegal header value b'Bearer '`

The same problem as above, seen from the other end: `${KB_TOKEN}` expanded to
nothing, leaving an empty token. Set the variable and restart.

### `reachable: false` with the token set

The endpoint or the token is wrong. `kb_status` reports the target URL and the
variable name it used — check both. It never prints the token itself.

---

## Diagnostics worth knowing

| Ask Claude for | Tells you |
|---|---|
| `whoami` | Active profile, tenant, base URL, whether the instance answers, running version. |
| `kb_status` | Which knowledge-base config file is in use, whether it answers, how the token is supplied. |
| `release_sessions` | Frees Acumatica API seats. |
| `reload_config` | Re-reads `connections.json` without a restart. |

`kb_status` makes a real search call rather than echoing configuration — a spec
can be perfectly well-formed and point at a dead host, and both look identical
in the file.

---

## macOS and Linux

| What you see | What it means |
| --- | --- |
| `grp-mcp` installed, but no Acumatica tools and no error | You installed the Windows plugin. It bundles `server/grp-mcp.exe`, which a Mac cannot execute, so the server never starts and nothing reports it. Remove it and install **`grp-mcp-mac`** — see [INSTALL-grp-mcp-mac.md](INSTALL-grp-mcp-mac.md) |
| **Add marketplace** in the app appears to work, but no plugin is installed | The button registers the marketplace and stops. The app logs `Found 0 local plugins` even though the clone is there, because it never writes `~/.claude/plugins/installed_plugins.json`. Editing `enabledPlugins` in `settings.json` by hand does not fix it either. Install from the CLI: `claude plugin install <name>@censof-tools` |
| Profiles save in the config page but the server does not see them | The page and the server are using two different `connections.json`. Run the check in [INSTALL-grp-mcp-mac.md](INSTALL-grp-mcp-mac.md) step 6: compare the path the setup tool prints against `kb_status`'s `spec_path`. This is the macOS shape of a bug that was real on Windows |
| `uvx: command not found` | `grp-mcp-mac` needs `uv`. `brew install uv`, or `curl -LsSf https://astral.sh/uv/install.sh \| sh`, then reopen the terminal |
| Both `grp-mcp` and `grp-mcp-mac` installed | Every tool appears twice and you cannot tell which answered. Remove one: `claude plugin uninstall grp-mcp@censof-tools` |
