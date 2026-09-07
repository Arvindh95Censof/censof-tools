# Templates

Only needed if you are writing the config by hand instead of using
`tools\Edit-Connections.cmd`. The config page is easier and validates as you go.

To use one: copy it to `%USERPROFILE%\grp-mcp\`, drop the `.example` from the
name, and fill in the real values.

```powershell
mkdir "$env:USERPROFILE\grp-mcp" -Force
copy connections.example.json "$env:USERPROFILE\grp-mcp\connections.json"
```

> **Not `%LOCALAPPDATA%`, which this page used to say.** Claude installs as an
> MSIX package, so a server it launches sees that folder redirected into the
> package's `LocalCache` — and an app update reset it on 2026-09-04, deleting a
> `connections.json` holding twelve profiles with live client credentials.
> `%USERPROFILE%\grp-mcp` is outside `AppData`, so no container maps it and no
> update reaches it. On macOS and Linux the equivalent is `~/.grp-mcp/`.

Then restart Claude.

`kb_server.example.json` uses `${KB_TOKEN}` rather than a pasted token, so the
file itself is not a secret. Set the variable with `tools\Set-KB-Token.cmd`.

**connections.json holds your ERP password in clear text.** Keep it out of
OneDrive, Dropbox, or any other synced folder. `%LOCALAPPDATA%` is never synced,
which is why it is the default.
