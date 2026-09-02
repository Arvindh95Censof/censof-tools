# GRP MCP — installation, step by step

From nothing installed to Claude answering `whoami` against your Acumatica
instance. Allow about fifteen minutes the first time.

Every step tells you **what to expect**, so you can tell success from
"it printed something and I hope that was fine."

**Contents**

- [Step 0 — Check you can get the software](#step-0--check-you-can-get-the-software)
- [Step 1 — Install the Claude Code CLI](#step-1--install-the-claude-code-cli)
- [Step 2 — Add the marketplace](#step-2--add-the-marketplace)
- [Step 3 — Install the plugin](#step-3--install-the-plugin)
- [Step 4 — What you need from Acumatica](#step-4--what-you-need-from-acumatica)
- [Step 5 — Create your connection](#step-5--create-your-connection)
- [Step 6 — Connect the knowledge base (optional)](#step-6--connect-the-knowledge-base-optional)
- [Step 7 — Restart and verify](#step-7--restart-and-verify)
- [Appendix A — Every field on the connection form](#appendix-a--every-field-on-the-connection-form)
- [Appendix B — Installing without the plugin](#appendix-b--installing-without-the-plugin-claude-desktop-extension)
- [If you are an AI assistant helping someone through this](#if-you-are-an-ai-assistant-helping-someone-through-this)

---

## Step 0 — Check you can get the software

**The `censof-tools` repository is private.** Open this in a browser:

<https://github.com/Arvindh95Censof/censof-tools>

- **You see the repository** → good, continue.
- **You see "404" or a sign-in wall** → your GitHub account does not have
  access. Request it before going further. Steps 2 and 3 will fail with a
  confusing git error rather than a clear "you lack permission."

You also need git to be able to authenticate as you from the command line. If
you have ever cloned a private company repo on this machine, that is already
set up. If not, install [Git for Windows](https://git-scm.com/download/win),
which includes Git Credential Manager and will prompt you to sign in the first
time it needs to.

---

## Step 1 — Install the Claude Code CLI

**Install this even if you only use the Claude Code desktop app.** The `claude`
command is the only working way to install and update the plugin
([UPDATING.md](UPDATING.md) explains why), and *Claude Desktop* — the separate
chat app — ships no `claude` command at all.

Open **PowerShell** and run:

```powershell
winget install Anthropic.ClaudeCode
```

Then **close and reopen PowerShell** — the installer adds `claude` to your PATH,
and an already-open window will not see it.

Check it worked:

```powershell
claude --version
```

**Expect:** a version number. If you get "not recognized", reopen PowerShell; if
it still fails, sign out of Windows and back in.

> **Which app gets the plugin.** Claude Code has two faces — the desktop app and
> the terminal — and they share one plugin store at `%USERPROFILE%\.claude\plugins`.
> Installing once covers both; there is nothing to repeat.
>
> *Claude Desktop* (`winget install Anthropic.Claude`) is a different application.
> It does not use plugins or marketplaces — only `.mcpb` extensions. If that is
> what you run, skip to [Appendix B](#appendix-b--installing-without-the-plugin-claude-desktop-extension).

---

## Step 2 — Add the marketplace

A "marketplace" is just the repository the plugin is published from.

```powershell
claude plugin marketplace add https://github.com/Arvindh95Censof/censof-tools.git
```

**Expect:** `Successfully added marketplace: censof-tools`

Use the full `.git` URL exactly as written. The shorter `owner/repo` form works
for public repositories but does not reliably authenticate to a private one.

**If it fails:**

| Message | Cause |
|---|---|
| `Authentication failed` / `could not read Username` | Git cannot sign in as you. See Step 0. |
| `repository not found` | Almost always permission, not a typo — GitHub returns 404 for private repos you cannot see. Recheck Step 0. |
| `not recognized as ... cmdlet` | The CLI is not installed or PowerShell was not reopened. Back to Step 1. |

Confirm it registered:

```powershell
claude plugin marketplace list
```

**Expect:** `censof-tools` in the list.

---

## Step 3 — Install the plugin

```powershell
claude plugin install grp-mcp@censof-tools
```

**Expect:** `Installed plugin "grp-mcp" ... Restart to apply changes.`

It installs at **user scope**, into `%USERPROFILE%\.claude\plugins`. Both the
Claude Code desktop app and the terminal read that same location, so this one
command serves both.

This downloads about 23 MB — the server plus its own bundled Python runtime.
There is nothing else to install.

Confirm:

```powershell
claude plugin list
```

**Expect:** `grp-mcp@censof-tools` with a version like `0.81.0-rc12`.

> **Also available:** `censof-mcp` in the same marketplace searches the GRP
> knowledge base — closed RFS tickets, Acumatica documentation and the GRP
> manuals. Install it the same way:
> `claude plugin install censof-mcp@censof-tools`. It is independent of GRP MCP;
> neither needs the other.

---

## Step 4 — What you need from Acumatica

Before the next step, collect six things. If you do not have the client ID and
secret, this is the section to forward to your Acumatica administrator.

| What | Looks like | Where it comes from |
|---|---|---|
| **Base URL** | `https://acumatica.example.com/MyCompany` | Your Acumatica address, including the instance path. **No trailing slash, no `/frames/...`.** |
| **Tenant** | `MyCompany 270326` | The company login name — the value you pick from the *Company* dropdown when signing in. Copy it exactly, spaces included. |
| **Username** | `integration.user` | An Acumatica user. Give it only the rights it needs. |
| **Password** | | That user's password. |
| **Client ID** | `A1B2C3D4-...@MyCompany` | From a **Connected Application**, below. |
| **Client secret** | | Shown **once**, when the secret is created. |

### Creating the Connected Application

In Acumatica, go to **Integration → Connected Applications** (screen `SM303010`)
and add one:

- **OAuth 2.0 flow:** `Resource Owner Password Credentials`
- Add a **shared secret** and copy the value immediately — Acumatica shows it
  once and never again.
- The **Client ID** is shown on the same screen and usually ends with `@` and
  your tenant name.

The user in Step 4 also needs the **Web Services API** role, or the login will
be rejected. Note that Acumatica licences a limited number of concurrent
*Web Services API Users* — a trial allows two. If logins start failing with
"API Login Limit", ask Claude for `release_sessions`.

---

## Step 5 — Create your connection

Double-click:

```
tools\Edit-Connections.cmd
```

A console window opens and your browser opens on `http://127.0.0.1:8765`.

The console prints where your settings will be saved. It will say:

```
Connections file : C:\Users\<you>\AppData\Local\grp-mcp\connections.json
```

**That location is not a coincidence and you do not need to configure it.** The
plugin looks there on its own. There is no environment variable to set.

Need the file somewhere else — a shared team folder, another drive? That is the
one case where you do set a variable: see [CONFIGURE.md](CONFIGURE.md).

In the browser:

1. Give the profile a **short name** — `prod`, `staging`, `dbkk`. This is what
   you will say to Claude when you want a specific instance.
2. Fill in the six values from Step 4.
3. Leave **allow_write**, **allow_delete** and **allow_publish** **off** for now.
   Get reading working first. [CONFIGURE.md](CONFIGURE.md) covers turning them on.
4. Click **Test** if the page offers it, then **Save**.
5. **Close the console window.**

Every field is explained in [Appendix A](#appendix-a--every-field-on-the-connection-form).

> **Keep that file out of OneDrive, Dropbox or any synced folder.** It holds your
> ERP password in clear text. `%LOCALAPPDATA%` is deliberately a per-machine
> location that is never synced — which is exactly why the tool defaults there.
> If you move the file somewhere else, see [CONFIGURE.md](CONFIGURE.md).

### Adding more than one instance

Run the same tool again and add another profile. One machine can hold many. The
one marked **active** is what Claude uses when you do not name an instance;
you can say "use the staging instance" to switch for a single request.

---

## Step 6 — Connect the knowledge base (optional)

GRP MCP can consult an Acumatica knowledge base **itself** before every write —
checking prerequisites and validation rules rather than driving a screen cold.
This is optional. Without it, writes still work; they just carry no
knowledge-base evidence behind them.

The Censof knowledge base is at `https://cen-kb.my/mcp`. You need a **token**
for it — ask whoever sent you this package if you do not have one.

**Set the token first**, using:

```
tools\Set-KB-Token.cmd
```

It asks for the token, stores it as a `KB_TOKEN` environment variable, and never
puts it on a command line. (Why that matters: command lines are visible to every
process on the machine, so `setx KB_TOKEN abc123` leaks the token to anything
watching. See [CONFIGURE.md](CONFIGURE.md).)

**Then**, in the config page from Step 5, open the knowledge-base section:

- **Where is the KB?** → `Hosted — call a KB endpoint over HTTP`
- **URL** → `https://cen-kb.my/mcp`
- **Tool** → `search_docs`
- **Token** → `Read from an environment variable`, with the variable named
  `KB_TOKEN`

Leave Token on **Read from an environment variable**. The alternative pastes the
secret into the config file, which then cannot be copied, backed up or attached
to a support ticket without leaking it.

Click **Save**, then **close the console window**. It saves beside
`connections.json`; to keep it elsewhere, see [CONFIGURE.md](CONFIGURE.md).

---

## Step 7 — Restart and verify

**Fully restart Claude Code** — quit the desktop app, or exit and relaunch
`claude`. If you use both, restart whichever one you are about to work in. This matters more than it looks: a running server keeps the
environment and configuration it started with, so a restart is the only way
anything you just set takes effect.

Then ask Claude:

> whoami

**Expect** something like:

```json
{
  "grp_mcp_version": "0.81.0rc12",
  "instance": "staging",
  "tenant": "MyCompany 270326",
  "base_url": "https://acumatica.example.com/MyCompany",
  "reachable": true,
  "entity_count": 877
}
```

`reachable: true` means the credentials work and the instance answered.

If you set up the knowledge base, also ask:

> kb_status

**Expect** `"reachable": true`, a `match_count` above zero, and:

```json
"auth": { "mode": "env_var", "variable": "KB_TOKEN", "variable_is_set": true }
```

If `variable_is_set` is `false`, you have not restarted since setting the token —
restart again.

Anything unexpected: [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

### Try it

> List the first 5 customers

> What screens can you reach for GL301000?

> Show me the fields on the Journal Transactions screen

---

## Appendix A — Every field on the connection form

### Connection

| Field | Required | Notes |
|---|---|---|
| **Name** | yes | Your label for this profile. Short and memorable — you will say it to Claude. |
| **base_url** | yes | `https://host/InstancePath`. No trailing slash. Get this wrong and every plane fails at once. |
| **client_id** | yes | From the Connected Application. Usually ends `@TenantName`. |
| **client_secret** | yes | Shown once when created. If lost, create a new secret — you cannot read the old one back. |
| **username** | yes | An Acumatica user with the Web Services API role. |
| **password** | yes | Stored in clear text in `connections.json`. Use a dedicated integration account, not a person's login. |
| **tenant** | strongly recommended | The company login name. Technically optional, but the OData and screen planes need it — without it, some tools work and others fail confusingly. |
| **branch** | no | Only if you must log in to a specific branch. |
| **endpoint_name** | no | Defaults to `Default`. Change only if your admin published a custom endpoint. |
| **endpoint_version** | no | Defaults to `24.200.001`. Must match a version that exists on the instance. |

### Safety switches

| Field | Default | What it allows |
|---|---|---|
| **allow_write** | off | Creating and updating records. |
| **allow_delete** | off | Deleting. Strictly stronger than write and enforced across every API plane. |
| **allow_publish** | off | Publishing customization projects. |
| **allow_unrestricted_fs** | off | Lets file tools reach the whole disk. Left off, they are confined to the working directory. |

All off by default. A profile pointed at production can stay strictly read-only
no matter what Claude is asked to do.

### Risk and enforcement

| Field | Values | Effect |
|---|---|---|
| **risk** | `dev`, `production` | Labels the profile, and sets the default enforcement level. |
| **enforcement** | `off`, `warn`, `enforce` | Whether the knowledge base is consulted before a write. Leave blank to derive it from **risk**: `production` → `warn`, `dev` → `off`. |

- **off** — the knowledge base is not consulted at all.
- **warn** — consulted, evidence attached to the result, the write proceeds either way.
- **enforce** — the write is **blocked** if the knowledge base cannot be reached.

For anything pointed at a real client instance, set **risk = production** — or
set enforcement to `warn` explicitly.

---

## Appendix B — Installing without the plugin (Claude Desktop extension)

The plugin above is the recommended route. If you have been given a
`grp-mcp-<version>.mcpb` file instead, that is the Claude Desktop extension
build of the same software.

1. Open **Claude Desktop → Settings → Extensions → Install from file**, and
   choose the `.mcpb`. **Double-clicking the file does not work** — Windows has
   no association for `.mcpb` and will just ask you what to open it with.
2. Leave **Connections file** blank. The extension checks
   `%LOCALAPPDATA%\grp-mcp\` on its own, the same place `Edit-Connections.cmd`
   writes.
3. Leave **List only the core tools** on. It lists about 17 tools instead of
   120, handing roughly 48k tokens of context back to you before you ask
   anything. The rest stay fully available — Claude finds them itself when
   needed.
4. Then continue from Step 5 above.

**Before updating an extension, write your settings down.** A real
extension-to-extension update has ended with the extension removed, reinstalled,
and its settings re-entered by hand. Treat re-entering them as a normal outcome.

The plugin route does not have this problem, which is the main reason it is the
recommended one.

---

# If you are an AI assistant helping someone through this

You can run most of this. Three things you cannot, and the order matters.

## You cannot restart Claude Code — plan for the handoff

Every phase here ends in a restart, and the restart kills the session doing the
guiding. Do not treat that as a failure. Get to a natural stopping point, tell
the person exactly what to do and what to ask for next, and let the session end:

> Installed. Now fully quit Claude Code and start it again, then ask me `whoami`.

Then verify in the NEW session. A `whoami` before the restart reports the old
state and is worse than not checking at all, because it looks like a check.

## Two steps are the human's, not yours

- **The connection form takes an ERP password.** Launch
  `tools\Edit-Connections.cmd` if that helps, then stop. Do not type credentials
  into the form, and do not read `connections.json` back afterwards — it holds
  live ERP passwords in clear text. `whoami` answers every identity question
  without it.
- **`tools\Set-KB-Token.cmd` cannot be automated.** Its prompt is
  `Read-Host -AsSecureString`, which reads the console directly and ignores piped
  input — scripting it hangs rather than fails. Tell the person to double-click
  it. Never ask them to paste the token to you, and never suggest
  `setx KB_TOKEN <value>` as a shortcut: a command line is readable by every
  process on the machine and lands in their PowerShell history.

## Things that look like problems and are not

- **A missing `connections.json` in the working tree is correct.** It lives in
  `%LOCALAPPDATA%\grp-mcp\`. Absence from the project folder is the intended
  state, not a broken install.
- **`variable_is_set: false` right after setting `KB_TOKEN`** means only that
  Claude Code has not been restarted since. It is not a wrong token.
- **The first tool call taking ~5 seconds** is the onefile binary unpacking. Once
  per session.

## Getting it wrong in ways that cost real time

- **Do not suggest `pip install grp-mcp`.** That installs a *second* copy from
  PyPI, at an older published version, and the two fight over Acumatica licence
  seats. The plugin carries its own Python; nothing needs installing.
- **Check `whoami` before any write.** A profile switch is invisible in the
  transcript, and several profiles in one file routinely point at different
  customers. Writes are also gated per profile — if one is refused, point at
  `allow_write` / `allow_delete` and let the human change it. Do not turn them on
  mid-task.
- **If the wrong instance is active after they edited the config**, call
  `reload_config` rather than debugging further — the server caches
  `connections.json` from startup and an edit made in another program does not
  reach it. Confirm with `whoami`.
- **If a `connections.json` change appears to do nothing**, look for a stray
  `connections.json` in the working directory, or a `GRP_MCP_CONNECTIONS`
  variable. Both beat the default location. `whoami` reports the file actually in
  use.

## This plugin serves Claude Code only

The desktop app and the CLI share one plugin store, so installing once covers
both. **Claude Desktop** — the separate chat app — does not use plugins at all
and needs a `.mcpb` extension instead. If someone has run every command
successfully and still has no GRP tools, check which application they are in
before anything else.
