# Tools

## Edit-Connections.cmd — use this one

Double-click it. Opens the config page in your browser so you can add or change
your Acumatica connection, and the knowledge-base settings.

It works out how the plugin starts the server and reuses exactly that, so there
is no path to type and no chance of configuring one build while a different one
runs. It looks in this order:

1. the version the plugin pins, read out of its own `.mcp.json` — in the
   marketplace clone first, then the installed cache. This is what the MCP
   server itself is launched with, so the config page cannot disagree with it.
   Needs `uv`; if the pin is there and `uv` is not, it says so and gives you the
   `winget` line rather than failing obscurely
2. a bundled `grp-mcp.exe` from 0.81.0-rc14 or earlier, if this machine has not
   updated yet
3. the Claude Desktop extension, if that is how it was installed
4. `GRP-MCP-Setup.exe` beside this file, if someone put one there

If it finds nothing it says so and points you at INSTALL-grp-mcp.md rather than failing
with a path error.

Your settings save to `%USERPROFILE%\grp-mcp\connections.json` — where the
plugin looks on its own. Not `%LOCALAPPDATA%`: Claude installs as an MSIX
package, so a server it launches sees that folder redirected into the package's
`LocalCache`, and an app update empties it. **Restart Claude afterwards.**

---

## Set-KB-Token.cmd — only if you use the knowledge base

Stores your knowledge-base token as the `KB_TOKEN` environment variable.

Double-click it; it must be run interactively, because the prompt hides what you
type by reading the console directly and so cannot be piped or scripted. It
detects an existing token and asks before replacing it, strips a leading
`Bearer ` if you paste the whole header, and reads the value back to confirm it
was stored.

**Why not just `setx KB_TOKEN <value>`:** a command line is visible to every
process running as you — Task Manager shows it and any script can read it out of
the process list — so passing a secret as an argument leaks it. It also lands in
your PowerShell history file on disk. This tool never puts the value on a
command line.

`Set-KB-Token.ps1` beside it does the actual work; the `.cmd` exists only so it
can be double-clicked, since a `.ps1` opens in Notepad by default.

**Restart Claude afterwards**, then ask for `kb_status` — expect
`"variable_is_set": true`.

---

## GRP-MCP-Setup.exe — not in this repository

A standalone copy of the same config page, carrying its own Python. It is **not**
shipped here: it is 21 MB, and `Edit-Connections.cmd` above does the same job
through `uv`.

You only need it to create a `connections.json` on a machine where **nothing is
installed yet and `uv` is not wanted** — preparing a config centrally to hand to
someone, for instance. Ask whoever maintains these tools for it; drop it beside
`Edit-Connections.cmd` and the launcher will find it.

---

## Windows only

Everything in this folder is a `.cmd` or `.ps1` script, so none of it runs on
macOS or Linux. The equivalents there are done by hand, and are written out in
full:

| Instead of | Do this |
| --- | --- |
| `Set-KB-Token.cmd` | [INSTALL-censof-mcp.md](../INSTALL-censof-mcp.md) → *On macOS or Linux — setting the token by hand*. Read it rather than guessing: a shell profile does not reach an app launched from Finder, which fails as an auth error with a healthy-looking plugin. |
| `Edit-Connections.cmd` | `uvx --from grp-mcp-plugin==0.81.0rc31 grp-mcp-setup` — see [INSTALL-grp-mcp-mac.md](../INSTALL-grp-mcp-mac.md) |
