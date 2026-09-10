# grp-mcp-mac

**Use [`grp-mcp`](../grp-mcp/README.md) instead. This plugin is now identical to
it.** It stays here so that anyone who already installed it keeps receiving
updates; nothing about it is broken.

## Why it existed, and why it no longer needs to

`grp-mcp` used to bundle `server/grp-mcp.exe`, a Windows binary a Mac cannot
execute — it installed cleanly on macOS and then never started. A plugin's
`.mcp.json` cannot select a different command per operating system, so the fix
had to be a second plugin rather than a branch inside the first.

As of rc15 `grp-mcp` ships no binary either. Both plugins now run the same line:

```
uvx --from grp-mcp-plugin==0.81.0rc29 grp-mcp
```

which works the same on Windows, macOS and Linux. The reason for the split is
gone.

**Install one or the other, never both.** They register the same server name, so
you would get every tool twice with no way to tell which one answered.

## Prerequisite

[`uv`](https://docs.astral.sh/uv/) — `brew install uv`, or
`curl -LsSf https://astral.sh/uv/install.sh | sh`.

## Setup

Create your connections file once:

```
uvx --from grp-mcp-plugin==0.81.0rc29 grp-mcp-setup
```

It opens `http://127.0.0.1:8765` and writes to `~/.grp-mcp/connections.json`,
which the server finds on its own — no environment variable needed. That file
holds ERP passwords in clear text, so keep it out of any synced folder.

Full walkthrough: [docs/INSTALL-grp-mcp-mac.md](../../docs/INSTALL-grp-mcp-mac.md).

## Why the version is pinned

`--from grp-mcp-plugin==0.81.0rc29` names an exact version on purpose.
Unpinned, `uvx` would fetch whatever is newest at each launch, so the server
could change underneath you between one start and the next while the plugin
version stayed the same — untraceable the moment something breaks. New server
versions arrive by updating the plugin, like everything else.

`find_tool` needs no extra as of rc17 — it ranks by a lexical scorer built into
the package. (`[search]` was pinned from rc15 to rc16 for an embedding model that
measured worse than the lexical scorer, and is no longer needed.)
