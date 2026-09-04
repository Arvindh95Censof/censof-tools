# Censof tools for Claude

Two Claude Code plugins, and the documentation for both. Install once, and
updates arrive from git — no more emailed files.

| Plugin | What it does |
| --- | --- |
| **`censof-mcp`** | Search the GRP knowledge base — 101,530 closed RFS tickets, the Acumatica documentation and the GRP manuals. Bundles the `rfs-analyze` skill. Read-only. |
| **`grp-mcp`** | Drive an Acumatica instance — read records, write them, run processes, diagnose failures. Talks to your own instance; credentials never leave your machine. **Windows only** — it bundles a Windows binary. |
| **`grp-mcp-mac`** | The same Acumatica server for **macOS and Linux**, run from PyPI instead of a bundled binary. Needs `uv`. Install this *or* `grp-mcp`, never both. |

They are independent. Take one, the other, or both.

---

## Start here

**→ [docs/README.md](docs/README.md)** — pick your plugin and follow that track.

The full documentation lives in [`docs/`](docs/): install guides for each plugin,
the configuration reference, updating, troubleshooting, and a
[changelog](docs/CHANGELOG.md) of what changed in each release. It also carries the
helper tools — `Set-KB-Token.cmd` and `Edit-Connections.cmd`.

Once you have added this marketplace, that folder is also on your own disk —
`claude plugin marketplace add` clones the whole repository, docs included, and
`claude plugin marketplace update` refreshes it:

```
Windows        %USERPROFILE%\.claude\plugins\marketplaces\censof-tools\docs\
macOS, Linux   ~/.claude/plugins/marketplaces/censof-tools/docs/
```

so the guides are there without a separate download, and the two `.cmd` helpers
are there too on Windows. (On macOS and Linux those scripts do not run — the
manual equivalents are in the guides; see
[docs/tools/README.md](docs/tools/README.md).)

Do not edit anything under that folder. It is a managed clone and every
`marketplace update` overwrites it.

---

## The short version

```powershell
winget install Anthropic.ClaudeCode
```

```powershell
claude plugin marketplace add https://github.com/Arvindh95Censof/censof-tools.git
```

```powershell
claude plugin install censof-mcp@censof-tools
```

Use the full `.git` URL — the shorter `owner/repo` form does not reliably
authenticate to a private repository. Swap in `grp-mcp@censof-tools` for the
Acumatica plugin; `grp-mcp` needs your Acumatica credentials as well, which
[docs/INSTALL-grp-mcp.md](docs/INSTALL-grp-mcp.md) walks through.

**On a Mac or Linux?** `grp-mcp` bundles a Windows binary — it will install and
then never start, with no error saying why. Use `grp-mcp-mac@censof-tools`
instead and follow
[docs/INSTALL-grp-mcp-mac.md](docs/INSTALL-grp-mcp-mac.md). `censof-mcp` needs no
variant; it calls a hosted service and runs anywhere. Note the token tools below
are Windows scripts — the Mac equivalent is in
[docs/INSTALL-censof-mcp.md](docs/INSTALL-censof-mcp.md).

Then set your token by double-clicking `docs\tools\Set-KB-Token.cmd`, and restart
Claude Code.

> **Do not `setx` your token.** A command line is readable by every process
> running as you, and it lands in your PowerShell history file on disk. The tool
> above prompts for it instead, and sets both variable names it is read under.

---

## Your token is yours

It carries your name and your access level, and it is logged against you. Never
paste someone else's, and never share yours. Ask the OPEX team if you do not have
one — they start with `grpkb_`.

---

## Updates need the CLI

```powershell
claude plugin marketplace update censof-tools
```

```powershell
claude plugin update grp-mcp@censof-tools
```

Both lines, in that order, then restart. The **Update** button in the app stays
greyed out with "On latest version" even when a new version exists — a known
Claude Code bug, not a fault here. [docs/UPDATING.md](docs/UPDATING.md) has the
issue links.

---

## Which app gets these

Plugins serve **Claude Code** — the desktop app and the terminal share one plugin
store, so installing once covers both.

*Claude Desktop*, the separate chat app, does not use plugins at all.

| You use | Install |
| --- | --- |
| Claude Code (desktop app or terminal), Cowork | these plugins |
| Claude Desktop **chat** | the `.mcpb` extension — plugins do not reach chat |

**Do not run both on one machine.** The `.mcpb` extension connects to the same
server, so you get every tool twice with no way to tell which answered. Keep the
`.mcpb` on that machine and skip the plugin, or the reverse — not both.

---

## If something goes wrong

Full symptom table in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md). The
four most common:

| What you see | What it means |
| --- | --- |
| `repository not found` | Permission, not a typo. GitHub returns 404 for private repos you cannot see — check you can open this page while signed in |
| Tools missing, or auth errors | Your token is not reaching the server. Run `Set-KB-Token.cmd`, then **fully restart** Claude Code — a running program keeps the environment it started with |
| `not permitted to …` | Not an install problem. Your token works; it lacks that access tier. Ask OPEX to add it |
| `/` menu shows nothing at all | You are on the home screen. Skills load once a session starts — send a message first, then look |

---

## For maintainers

`plugins/censof-mcp/skills/*/SKILL.md` is **generated**. Its source of truth is
`ElasticSearch-KB-Server/Operations/grpkb-connector/skills/`. Edit it there, then:

```bash
python Operations/sync_plugin.py
```

and commit this repo. Editing the copy here gets overwritten on the next sync.

`docs/` mirrors `packaging/` documentation in the **grp-mcp** repo where the two
overlap. When you change how the plugin is installed or configured, change it in
both — the drift that this move was meant to end.

**Every release needs three things, not one:** the version bumped in
`plugin.json`, an entry at the top of [docs/CHANGELOG.md](docs/CHANGELOG.md)
written for the reader rather than the maintainer, and the `LATEST (...)`
sentence at the end of the plugin `description` updated to match. That sentence
is the only "what changed" anyone sees without leaving the plugin list.

**Never force-push this repo.** A client records the commit it synced, and
force-pushing strands every client that had synced against it, each needing a
manual remove-and-re-add. Withdraw a bad release with a follow-up commit instead.
