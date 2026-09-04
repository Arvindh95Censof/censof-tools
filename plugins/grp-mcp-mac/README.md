# grp-mcp-mac

The Acumatica plugin for **macOS and Linux**.

Same server as [`grp-mcp`](../grp-mcp/README.md), started differently: that one
bundles `server/grp-mcp.exe`, a Windows binary a Mac cannot execute, so on macOS
it installs cleanly and then never starts. A plugin's `.mcp.json` cannot select a
different command per operating system, so this had to be a separate plugin
rather than a fix inside the other one.

This plugin ships no binary. It runs the same code from PyPI:

```
uvx --from grp-mcp-plugin==0.81.0rc14 grp-mcp
```

**Install `grp-mcp` or `grp-mcp-mac`, never both.** They register the same server
name, so you would get every tool twice with no way to tell which one answered.

## Prerequisite

[`uv`](https://docs.astral.sh/uv/) — `brew install uv`, or
`curl -LsSf https://astral.sh/uv/install.sh | sh`. This is the one thing the
Windows plugin does not need.

## Setup

Create your connections file once:

```
uvx --from grp-mcp-plugin==0.81.0rc14 grp-mcp-setup
```

It opens `http://127.0.0.1:8765` and writes to `~/.grp-mcp/connections.json`,
which the server finds on its own — no environment variable needed. That file
holds ERP passwords in clear text, so keep it out of any synced folder.

Full walkthrough: [docs/INSTALL-grp-mcp-mac.md](../../docs/INSTALL-grp-mcp-mac.md).

## Why the version is pinned

`--from grp-mcp-plugin==0.81.0rc14` names an exact version on purpose. Unpinned,
`uvx` would fetch whatever is newest at each launch, so the server could change
underneath you between one start and the next while the plugin version stayed
the same — untraceable the moment something breaks. New server versions arrive
by updating the plugin, like everything else.
