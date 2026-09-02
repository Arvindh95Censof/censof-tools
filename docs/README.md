# Censof tools for Claude

Two plugins. They are independent — take one, the other, or both.

---

## Which one do you want?

### Search the knowledge base — `censof-mcp`

101,530 closed RFS support tickets, the Acumatica documentation and the GRP
manuals, searchable from Claude. Bundles the **`rfs-analyze`** skill, which
diagnoses one ticket end to end and labels its answer *proven*, *proposed*, or
*a workaround over a root cause that was never fixed*.

**Read-only — it cannot change anything.** No download, no Python, no Acumatica
credentials; it calls a hosted service. Five steps, about five minutes.

→ **[INSTALL-censof-mcp.md](INSTALL-censof-mcp.md)**

### Drive Acumatica — `grp-mcp`

Read records, write them, run processes and diagnose failures, across all five of
Acumatica's APIs. Claude talks to **your** instance directly; nothing is proxied
and your credentials never leave your machine.

**Needs your Acumatica credentials.** Writes are off per profile until you turn
them on. Carries its own Python, so there is nothing else to install. Seven
steps, about fifteen minutes.

→ **[INSTALL-grp-mcp.md](INSTALL-grp-mcp.md)**

### Both?

Do `censof-mcp` first. It is quick, and it proves your GitHub access and your
token before you take on the longer setup. Then `grp-mcp`, skipping what you have
already done — the CLI and the marketplace are shared.

**One token, two variable names.** The same `grpkb_…` token is read as
`CENSOF_MCP_TOKEN` by one plugin and `KB_TOKEN` by the other.
`tools\Set-KB-Token.cmd` sets both from a single prompt, so this cannot catch you
out — but it is why you will see two names for one secret.

---

## What both need first

- **Claude Code** — the desktop app, a terminal, or both. One install covers
  both; they share a single plugin store.
- **The Claude Code CLI**, even if you only use the desktop app. `claude` is the
  only working way to install and update plugins: the Update button in the app
  does not work, and that is a known Claude Code bug, not a fault in these
  plugins. See [UPDATING.md](UPDATING.md).
- **Access to the private `censof-tools` GitHub repository.** If you cannot open
  <https://github.com/Arvindh95Censof/censof-tools> in a browser, stop and
  request access — nothing here will work without it.
- **Windows 10 or 11** for `grp-mcp`. `censof-mcp` runs anywhere Claude Code does.

> **Not for Claude Desktop.** These are **plugins**, which serve Claude Code.
> *Claude Desktop* — the separate chat app — does not use plugins at all; it
> takes a `.mcpb` extension, which is a different download. See
> INSTALL-grp-mcp.md, Appendix B.

---

## Everything in this folder

| Item | What it is |
|---|---|
| **[INSTALL-censof-mcp.md](INSTALL-censof-mcp.md)** | Knowledge-base search. The quick one. |
| **[INSTALL-grp-mcp.md](INSTALL-grp-mcp.md)** | Acumatica. The full one. |
| [CONFIGURE.md](CONFIGURE.md) | Where every file lives, all environment variables, `setx`, the safety switches. Mostly `grp-mcp`. |
| [UPDATING.md](UPDATING.md) | How to get new versions of either plugin. |
| [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | Symptom → cause → fix. |
| `tools\Set-KB-Token.cmd` | Stores your `grpkb_` token under both variable names, without it appearing on a command line. **Either plugin.** |
| `tools\Edit-Connections.cmd` | Opens the Acumatica config page. Finds the installed binary for you. **`grp-mcp` only.** |
| `templates\` | Example `connections.json` and `kb_server.json`, if you would rather write them by hand. |

> **Handing this to Claude?** Give it the **folder**, not a shared link — the
> `.md` files are read verbatim. INSTALL-grp-mcp.md ends with a section for
> assistants covering what they can run, what they must leave to you, and why the
> restarts break the session guiding you.

---

## Two things worth knowing before you start

**Writes are off by default.** Every `grp-mcp` connection profile carries its own
`allow_write`, `allow_delete` and `allow_publish` switches, all starting off, so
a profile pointed at production stays read-only no matter what Claude is asked to
do. `censof-mcp` cannot write at all.

**A clean "ok" from Acumatica is not proof.** Acumatica returns success-shaped
responses for writes that quietly did nothing. Every write is read back and
compared against what was sent; anything that cannot be confirmed is reported as
**unverified** rather than as success. Nothing is ever rolled back
automatically — a failure is surfaced, never silently reversed.
