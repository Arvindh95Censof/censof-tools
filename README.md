# Censof plugins

Internal Claude plugins for the GRP knowledge base. Install once, and updates arrive
from git — no more emailed files.

Contains one plugin, **`censof-mcp`**: the knowledge base connector plus the
`rfs-analyze` skill that runs on top of it.

---

## Before you install — set your token

The plugin reads your personal token from an environment variable. Ask the OPEX team
for one if you do not have it; it starts with `grpkb_`.

Open a terminal and run this once, with your own token:

```bash
setx CENSOF_MCP_TOKEN "grpkb_your_token_here"
```

Close that terminal afterwards. `setx` only affects windows opened *after* it runs.

> **Your token is yours.** It carries your name and your access level, and it is logged
> against you. Never paste someone else's, and never share yours.

---

## Install

```
/plugin marketplace add Arvindh95Censof/censof-tools
/plugin install censof-mcp@censof
```

Then restart Claude. Both halves arrive together — the tools and the skill.

### Check it worked

Send any message first, then type `/`. You are looking for **`censof-mcp:rfs-analyze`**.

> An empty `/` menu on the Claude Code home screen means nothing — skills only load once
> a session has started. Send a message, then look.

Then ask Claude to *"list your Censof MCP tools"*. Seven is right.

---

## Updating

```
/plugin update censof-mcp
```

That is the whole point of this repo: a fix lands here, you run one command.

---

## Do not run this alongside the `.mcpb` extension

The older `censof-mcp.mcpb` Claude Desktop extension connects to the same server. With
both installed you get **every tool twice** and no way to tell which answered.

| You use | Install |
| --- | --- |
| Claude Code, Cowork | this plugin |
| Claude Desktop **chat** | the `.mcpb` extension — plugins do not reach chat |

If you need chat as well, keep the `.mcpb` on that machine and skip the plugin, not both.

---

## If something goes wrong

| What you see | What it means |
| --- | --- |
| Tools missing, or auth errors | `CENSOF_MCP_TOKEN` is not set, or the terminal predates `setx`. Check with `echo %CENSOF_MCP_TOKEN%` in a **new** terminal |
| `not permitted to ...` | Not an install problem. Your token works; it lacks that access tier. Ask OPEX to add it |
| `/` menu shows nothing at all | You are on the home screen. Send a message first |
| Every tool appears twice | The `.mcpb` extension is also installed. Remove one |
| Skill answers with an old version number | Run `/plugin update censof-mcp` |

---

## For maintainers

`plugins/censof-mcp/skills/*/SKILL.md` is **generated**. Its source of truth is
`ElasticSearch-KB-Server/Operations/grpkb-connector/skills/`. Edit it there, then:

```bash
python Operations/sync_plugin.py
```

and commit this repo. Editing the copy here gets overwritten on the next sync.
