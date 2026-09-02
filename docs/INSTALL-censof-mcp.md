# censof-mcp — search the GRP knowledge base

Gives Claude read-only search over **101,530 closed RFS support tickets**, the
Acumatica documentation, and the GRP manuals. It also bundles the
**`rfs-analyze`** skill, which diagnoses a single ticket end to end: reads its
attachments, finds precedent in the closed-ticket history, cross-checks the
documentation, and proposes a fix labelled *proven*, *proposed*, or *a
workaround over a root cause that was never fixed*.

**This is the light one.** Four steps, about five minutes. It reads a hosted
service over HTTP — no download, no Python, no Acumatica credentials, nothing
that can change your ERP.

> Looking to **drive Acumatica** — read records, write them, run processes?
> That is a different plugin. See [INSTALL-grp-mcp.md](INSTALL-grp-mcp.md).
> The two are independent; neither needs the other, and installing both is fine.

---

## What you need

- **Windows, macOS or Linux.** Nothing platform-specific here.
- **Claude Code** — the desktop app, a terminal, or both. One install covers
  both; they share a single plugin store.
- **The Claude Code CLI**, even if you only use the desktop app — `claude` is the
  only working way to install and update plugins.
- **Access to the private `censof-tools` GitHub repository.**
- **Your personal knowledge-base token**, which starts with `grpkb_`. Ask
  whoever sent you this package.

---

## Step 1 — Check you can get the software

**The `censof-tools` repository is private.** Open this in a browser:

<https://github.com/Arvindh95Censof/censof-tools>

- **You see the repository** → continue.
- **You see a 404 or a sign-in wall** → your GitHub account lacks access.
  Request it before going further. Step 3 will otherwise fail with
  `repository not found`, which reads like a typo and sends you hunting the
  wrong problem — GitHub returns 404 rather than "forbidden" for private
  repositories you cannot see.

You also need git able to authenticate as you from the command line. If you have
ever cloned a private company repo on this machine, that is already set up. If
not, install [Git for Windows](https://git-scm.com/download/win), which includes
Git Credential Manager and will prompt you the first time it needs to.

---

## Step 2 — Install the Claude Code CLI

```powershell
winget install Anthropic.ClaudeCode
```

Then **close and reopen PowerShell** — the installer adds `claude` to your PATH
and an already-open window will not see it.

```powershell
claude --version
```

**Expect:** a version number. If you get "not recognized", reopen PowerShell; if
it still fails, sign out of Windows and back in.

> *Claude Desktop* — the separate chat app — is a different application and does
> not use plugins at all. This plugin serves **Claude Code**: the desktop app and
> the terminal, which share one plugin store.

---

## Step 3 — Add the marketplace and install

```powershell
claude plugin marketplace add https://github.com/Arvindh95Censof/censof-tools.git
```

**Expect:** `Successfully added marketplace: censof-tools`

Use the full `.git` URL exactly as written. The shorter `owner/repo` form works
for public repositories but does not reliably authenticate to a private one.

```powershell
claude plugin install censof-mcp@censof-tools
```

**Expect:** `Installed plugin "censof-mcp" … Restart to apply changes.`

Nothing is downloaded beyond the plugin definition itself — the knowledge base is
a hosted service the plugin calls over HTTP.

---

## Step 4 — Set your token

Double-click:

```
tools\Set-KB-Token.cmd
```

Paste your `grpkb_…` token when it asks. It is not displayed as you type.

The tool sets **two** variables from that one prompt:

| Variable | Read by |
|---|---|
| `CENSOF_MCP_TOKEN` | this plugin |
| `KB_TOKEN` | `grp-mcp`'s write preflight, if you ever install it |

Both get the same value. Setting only one is the most common half-working setup,
so the tool does both — and the spare is harmless if you never install the other
plugin, because nothing reads it.

> **Why not `setx CENSOF_MCP_TOKEN …`?** A command line is visible to every
> process running as you, and it lands in your PowerShell history file on disk.
> This tool prompts inside PowerShell and never puts the value on a command line.
> It must be double-clicked — the hidden prompt reads the console directly and
> cannot be piped or scripted.

---

## Step 5 — Restart and check

**Fully restart Claude Code.** Quit the application; closing a conversation is
not enough. A running program keeps the environment it started with, so this is
the only way it sees your token.

Then ask Claude something the knowledge base would know:

> Search the GRP knowledge base for GL301000 Journal Transactions

**Expect:** several results with titles, screen codes and citations.

Or try the skill it bundles, on any real ticket number:

> Analyse RFS ticket 260853801

---

## If it does not work

| Symptom | Cause and fix |
|---|---|
| No knowledge-base tools appear | Are you in Claude Code, or Claude Desktop? The chat app does not use plugins. Otherwise `claude plugin list` and restart. |
| Every search fails with an auth error | The token is not reaching the server. Run `tools\Set-KB-Token.cmd`, then **restart**. |
| `repository not found` | Permission, not a typo. See Step 1. |
| `claude` not recognized | CLI not installed, or PowerShell not reopened. See Step 2. |

Confirm the token is genuinely stored:

```powershell
([Environment]::GetEnvironmentVariable('CENSOF_MCP_TOKEN','User')).Length
```

A number means it is set. Use this rather than `$env:CENSOF_MCP_TOKEN`, which
shows only what your current window inherited when it opened.

---

## Updating

Same two commands as any plugin here, in this order:

```powershell
claude plugin marketplace update censof-tools
```

```powershell
claude plugin update censof-mcp@censof-tools
```

Then restart. **The Update button in the app does not work** — that is a known
Claude Code bug, not a problem with this plugin. See [UPDATING.md](UPDATING.md).

---

## What it can and cannot do

**Read-only.** It searches; it cannot change anything, in the knowledge base or
anywhere else. There is no configuration beyond the token, and no credentials of
yours are involved.

One thing worth knowing about how it reports itself: its `confidence` score says
how closely the corpus **matches** your query, not whether it **answers** it. A
question about a different product can score high on content that is genuinely
irrelevant. Every hit carries its source and citation — read those rather than
the score.
