# Templates

Only needed if you are writing the config by hand instead of using
`tools\Edit-Connections.cmd`. The config page is easier and validates as you go.

To use one: copy it to `%LOCALAPPDATA%\grp-mcp\`, drop the `.example` from the
name, and fill in the real values.

```powershell
mkdir "$env:LOCALAPPDATA\grp-mcp" -Force
copy connections.example.json "$env:LOCALAPPDATA\grp-mcp\connections.json"
```

Then restart Claude.

`kb_server.example.json` uses `${KB_TOKEN}` rather than a pasted token, so the
file itself is not a secret. Set the variable with `tools\Set-KB-Token.cmd`.

**connections.json holds your ERP password in clear text.** Keep it out of
OneDrive, Dropbox, or any other synced folder. `%LOCALAPPDATA%` is never synced,
which is why it is the default.
