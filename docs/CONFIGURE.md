# Configuration reference

Where every file lives, every environment variable, how to set one safely, and
what the safety switches actually do.

**Mostly `grp-mcp`.** `censof-mcp` has no configuration beyond its token — if
that is the only plugin you installed, the only part of this page that applies
to you is [the knowledge-base token](#the-knowledge-base-token).

If you followed [INSTALL-grp-mcp.md](INSTALL-grp-mcp.md) and it works, **you do not need
anything on this page.** The defaults are the recommended setup.

Read on if you want to **keep either config file somewhere other than the
default** — a shared folder, another drive — or you want to know why the
defaults are what they are.

**Contents**

- [Where files live](#where-files-live)
- [Environment variables](#environment-variables)
- [How to set an environment variable](#how-to-set-an-environment-variable)
- [The knowledge-base token](#the-knowledge-base-token)
- [Safety switches](#safety-switches)
- [Running against several instances](#running-against-several-instances)
- [The file formats](#the-file-formats)

---

## Where files live

Two files hold your configuration. **Both default to a location the plugin finds
on its own** — there is nothing to point it at.

```
%USERPROFILE%\grp-mcp\connections.json    your instance profiles and credentials
%USERPROFILE%\grp-mcp\kb_server.json      which knowledge base to consult
```

On a normal Windows machine that expands to `C:\Users\<you>\grp-mcp\`.

> **This changed on 2026-09-04, and the old location is still read.** It used to
> be `%LOCALAPPDATA%\grp-mcp`. Claude installs as an MSIX package, so the server
> it launches sees `%LOCALAPPDATA%` as the package's *LocalCache* — and an app
> update reset that container overnight, deleting a user's `connections.json`
> with twelve profiles in it, including live client credentials. It was
> recovered only because an unrelated copy happened to still be in a OneDrive
> recycle bin.
>
> `%USERPROFILE%\grp-mcp` is outside `AppData`, so no container maps it and no
> update reaches it. If your config is already in the old place it keeps
> working — it is still searched, and writes go back to whatever file was
> loaded, so nothing forks into two copies. To move it:
>
> ```powershell
> move "$env:LOCALAPPDATA\grp-mcp\*" "$env:USERPROFILE\grp-mcp\"
> setx GRP_MCP_CONNECTIONS "$env:USERPROFILE\grp-mcp\connections.json"
> ```
>
> **Back that file up wherever it lives.** It is the only copy of your ERP
> credentials, and nothing else on your machine has one.

**On macOS and Linux** (the `grp-mcp-mac` plugin) there is no `LOCALAPPDATA`, so
the same two files live in your home directory instead:

```
~/.grp-mcp/connections.json    your instance profiles and credentials
~/.grp-mcp/kb_server.json      which knowledge base to consult
```

Everything below applies to both — read `%USERPROFILE%\grp-mcp\` and
`~/.grp-mcp/` as the same place under two names.

`%USERPROFILE%\grp-mcp` is deliberate. It is per-machine and is **never roamed or
synced** — which matters because `connections.json` holds your ERP password in
clear text. The older habit of keeping these beside the program put them in
Downloads or on the Desktop, both of which are routinely OneDrive-synced.

### How the plugin finds them

`connections.json` is looked for in this order, first hit wins:

1. `%GRP_MCP_CONNECTIONS%`, if that variable is set
2. `connections.json` in the current working directory
3. `%USERPROFILE%\grp-mcp\connections.json` ← **the normal answer**
   (macOS/Linux: `~/.grp-mcp/connections.json`)
4. `%USERPROFILE%\grp-mcp\connections.json` — the pre-2026-09-04 location, still
   read so existing installs keep working, never written to again
5. the source checkout, for developers

`kb_server.json` follows the same idea: `%GRP_MCP_KB_SERVER%`, then beside
`connections.json`, then the working directory, then `%USERPROFILE%\grp-mcp\`.

Note item 2. A stray `connections.json` in a project folder **wins** over the
one in `%USERPROFILE%\grp-mcp`. If a profile change seems to have no effect, look for
one of those before anything else.

> **Writing** never targets the working directory — the config page always saves
> to `%USERPROFILE%\grp-mcp\` (or wherever an environment variable points). This
> is asymmetric on purpose: a program's working directory is chosen by whatever
> launched it, so writing credentials there would scatter them into whichever
> project folder happened to be open.

---

## Environment variables

**All of these are optional.** A standard install sets none of them.

| Variable | Default | What it does |
|---|---|---|
| `GRP_MCP_CONNECTIONS` | *(unset)* | Full path to a `connections.json` somewhere other than the default. |
| `GRP_MCP_KB_SERVER` | *(unset)* | Full path to a `kb_server.json` somewhere other than the default. |
| `KB_TOKEN` | *(unset)* | Your knowledge-base token, read by **`grp-mcp`'s write preflight** via `kb_server.json`. See below. |
| `CENSOF_MCP_TOKEN` | *(unset)* | The **same token**, read by the **`censof-mcp`** plugin. Set both — `tools\Set-KB-Token.cmd` does. |
| `GRP_MCP_CORE_ONLY` | `true` | Lists about 17 core tools instead of all 120, handing roughly 48k tokens of context back before you ask anything. The rest stay reachable — Claude finds them itself. **Leave this on.** |
| `GRP_MCP_ALLOW_ADMIN` | `false` | Lets Claude change and save connection profiles, including the write and delete switches. Leave off unless actively reconfiguring. |

Set `GRP_MCP_CONNECTIONS` **only** if you deliberately keep the file elsewhere —
a shared team location, say. Setting it to the default path is redundant, and
setting it to a stale path is a common cause of "my profile changes do nothing":
an explicit variable wins over the default, so it will keep reading the old file.

---

## How to set an environment variable

### The safe way for secrets

**Do not use `setx` for a token, password or secret.**

A command line is visible to every process running as you. Task Manager shows
it, and any script can read it out of the process list. `setx KB_TOKEN abc123`
therefore hands your token to anything watching — and it also lands in your
PowerShell history file on disk, where it stays.

For the knowledge-base token use the supplied tool, which prompts for the value
and never puts it on a command line:

```
tools\Set-KB-Token.cmd
```

Double-click it. (It has to be run interactively — the hidden prompt reads the
console directly and cannot be piped or scripted.)

### On macOS and Linux

There is no `.cmd` to run. Put the exports in your shell profile — `~/.zshrc` on
macOS, `~/.bashrc` on most Linux — using an editor rather than `echo … >>`, so
the value does not also land in your shell history:

```bash
export CENSOF_MCP_TOKEN="grpkb_your_token_here"
export KB_TOKEN="$CENSOF_MCP_TOKEN"
```

**A shell profile does not reach an app launched from Finder, the Dock or
Spotlight.** Those are not started by a shell, so they never read `~/.zshrc`. The
variable ends up set for `claude` in a terminal and unset for the desktop app,
which surfaces as every knowledge-base call failing authorisation while the
plugin itself looks perfectly healthy. Either launch Claude Code from a terminal,
or publish the values to the GUI session as well:

```bash
launchctl setenv CENSOF_MCP_TOKEN "$CENSOF_MCP_TOKEN"
```

`launchctl setenv` applies to apps started afterwards, so restart Claude Code —
and note it does **not** survive a reboot.

Paths work the same way:
`export GRP_MCP_CONNECTIONS="$HOME/shared/connections.json"`.

Check what a shell actually holds, without printing the value:

```bash
echo ${CENSOF_MCP_TOKEN:+set, ${#CENSOF_MCP_TOKEN} characters}
```

### For non-secret values (Windows)

Paths are not secrets, so `setx` is fine:

```powershell
setx GRP_MCP_CONNECTIONS "D:\shared\grp\connections.json"
```

**Expect:** `SUCCESS: Specified value was saved.`

The knowledge-base file works the same way. Note it points at the **file**, not
its folder:

```powershell
setx GRP_MCP_KB_SERVER "D:\shared\grp\kb_server.json"
```

Setting `GRP_MCP_CONNECTIONS` alone is often enough for both: `kb_server.json` is
looked for *beside* the connections file before anywhere else, so moving the pair
together needs only the one variable.

Three things people get wrong with `setx`:

1. **It does not affect the window you typed it in**, or any program already
   running. It writes the value for programs started *afterwards*. Close and
   reopen PowerShell to see it.
2. **It does not affect a running Claude.** A program keeps the environment it
   was launched with. You must fully quit and restart Claude — not just start a
   new conversation.
3. **It truncates at 1024 characters.** Not a problem for paths.

Check what is actually stored:

```powershell
[Environment]::GetEnvironmentVariable('GRP_MCP_CONNECTIONS','User')
```

That reads the saved value, unlike `$env:GRP_MCP_CONNECTIONS`, which reads only
what the current window inherited when it started.

### Removing one

```powershell
[Environment]::SetEnvironmentVariable('GRP_MCP_CONNECTIONS', $null, 'User')
```

Again: restart Claude afterwards. Until then it still holds the old value —
though if that value points at a file that no longer exists, the plugin falls
through to the default location rather than failing.

---

## The knowledge-base token

One token, two variable names. The same `grpkb_…` value is read as
`CENSOF_MCP_TOKEN` by the `censof-mcp` plugin and as `KB_TOKEN` by `grp-mcp`'s
write preflight. Setting one and not the other is the most common half-working
setup — search works and the preflight silently does not, or the reverse.
`tools\Set-KB-Token.cmd` sets both from one prompt, and a spare variable is
harmless if you only installed one plugin, because nothing reads it.

For `grp-mcp`, `kb_server.json` should refer to the token, not contain it:

```json
{
  "url": "https://cen-kb.my/mcp",
  "tool": "search_docs",
  "headers": { "Authorization": "Bearer ${KB_TOKEN}" }
}
```

`${KB_TOKEN}` is expanded from the environment at the moment the call is made.

**Why this is worth doing.** With the token written into the file, that file is
itself a secret: it cannot be copied to another machine, backed up, put in a
shared folder, or attached to a support ticket without leaking. With `${KB_TOKEN}`
the file is ordinary configuration and only the environment variable is
sensitive.

**What it costs.** Each person needs `KB_TOKEN` set on their own machine, and an
environment variable is inherited by *every* program you run, not just this one.
It is a real trade, not a free win — but the failure it prevents (a config file
quietly ending up in a synced folder) is the one that actually happens.

Set it with `tools\Set-KB-Token.cmd`, then **restart Claude** and check:

> kb_status

```json
"auth": { "mode": "env_var", "variable": "KB_TOKEN", "variable_is_set": true },
"reachable": true
```

If `variable_is_set` is `false`, the token is not reaching the server: either it
was never set, or Claude has not been restarted since. The request then goes out
with an empty token and the knowledge base rejects it — it fails loudly rather
than silently returning nothing.

---

## Safety switches

Each profile carries its own. All default to **off**.

| Switch | Allows |
|---|---|
| `allow_write` | Creating and updating records. |
| `allow_delete` | Deleting. Strictly stronger than write, and enforced across every API plane. |
| `allow_publish` | Publishing customization projects. |
| `allow_unrestricted_fs` | Lets the file tools reach the whole disk. Left off, they are confined to the working directory. |

A profile pointed at production can stay strictly read-only no matter what
Claude is asked to do. Turn these on per profile, deliberately, and turn them
off again when the task is done.

Changing them in the config page needs nothing special. Letting **Claude** change
them additionally requires `GRP_MCP_ALLOW_ADMIN=true`, which is off by default —
so an agent cannot grant itself write access.

### Risk and knowledge-base enforcement

| `risk` | Default enforcement |
|---|---|
| `dev` | `off` |
| `production` | `warn` |

Setting `enforcement` explicitly overrides that.

- **off** — the knowledge base is not consulted before writes at all.
- **warn** — consulted, evidence attached to the result, the write proceeds
  either way.
- **enforce** — the write is **blocked** if the knowledge base cannot be reached.

Mark any profile pointing at a real client instance as `risk = production`.

---

## Running against several instances

One `connections.json` holds many profiles. One is **active** and is used when
you do not name an instance.

- Switch the active one in the config page, or ask Claude to
  `set_active_instance`.
- Use a different one for a single request by naming it: *"read that from the
  staging instance."*
- **Editing the file while Claude is running has no effect** — it is read at
  startup. Ask Claude for `reload_config`, or restart.

Before any write, it is worth asking `whoami` first. It reports the profile,
tenant and base URL actually in use.

---

## The file formats

Only needed if you are writing these by hand instead of using the config page.
Working examples are in `templates\`.

### connections.json

```json
{
  "default": "staging",
  "instances": {
    "staging": {
      "base_url": "https://acumatica.example.com/MyCompany",
      "client_id": "A1B2C3D4-0000-0000-0000-000000000000@MyCompany",
      "client_secret": "your-shared-secret",
      "username": "integration.user",
      "password": "the-password",
      "tenant": "MyCompany 270326",
      "branch": "",
      "endpoint_name": "Default",
      "endpoint_version": "24.200.001",
      "risk": "dev",
      "allow_write": false,
      "allow_delete": false,
      "allow_publish": false
    }
  }
}
```

`default` names which profile is active and must match a key under `instances`.

### kb_server.json — hosted

```json
{
  "url": "https://cen-kb.my/mcp",
  "tool": "search_docs",
  "headers": { "Authorization": "Bearer ${KB_TOKEN}" }
}
```

### kb_server.json — local server

```json
{
  "command": "C:\\path\\to\\grp-kb.exe",
  "args": [],
  "env": {
    "KB_INDEX_DIR": "C:\\path\\to\\index",
    "KB_VAULT_DIR": "C:\\path\\to\\vault",
    "HF_HOME": "C:\\path\\to\\models",
    "HF_HUB_OFFLINE": "1",
    "TRANSFORMERS_OFFLINE": "1"
  }
}
```

The three offline variables stop the embedding model reaching out to
HuggingFace at startup. Omit them and a local knowledge base hangs on a network
call rather than failing quickly.
