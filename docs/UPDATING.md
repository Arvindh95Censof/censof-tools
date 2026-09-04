# Getting updates

**Two commands, in this order.** Open PowerShell:

```powershell
claude plugin marketplace update censof-tools
```

```powershell
claude plugin update grp-mcp@censof-tools
```

On macOS or Linux the Acumatica plugin is named differently:

```powershell
claude plugin update grp-mcp-mac@censof-tools
```

For the knowledge-base plugin it is the same shape, with the other name:

```powershell
claude plugin update censof-mcp@censof-tools
```

The first command is shared — one marketplace refresh covers both plugins.

Then **fully restart Claude Code** — the desktop app, the terminal, or both if
you use both. The update lands in one shared store; each running program still
has to be restarted to pick it up.

That is the whole procedure. The rest of this page explains why it is not a
button, and how to confirm it worked.

**Wondering what you just installed?** [CHANGELOG.md](CHANGELOG.md) lists every
release and what you will notice about it. The plugin list also shows a one-line
summary of the latest version in each plugin’s description.

---

## The Update button in the app does not work

You will find an **Update** button on the plugin's page. It stays greyed out
with the tooltip *"On latest version"* even when a newer version has been
published.

This is a known bug in Claude Code, not a problem with this plugin:

- [#54276](https://github.com/anthropics/claude-code/issues/54276) — Desktop
  fails to detect newer versions; the same *"On latest version"* tooltip.
  Closed as a duplicate, so it is tracked rather than fixed.
- [#45809](https://github.com/anthropics/claude-code/issues/45809) — Update
  button unresponsive when the plugin version is outdated
- [#45810](https://github.com/anthropics/claude-code/issues/45810) — marketplace
  update button disabled / not pressable
- [#48912](https://github.com/anthropics/claude-code/issues/48912) — greyed out,
  reports "already up to date" after the marketplace was updated

Confirmed here while publishing a release: **Check for updates worked** — the
orange "update available" dot appeared on the plugin card — but the Update
button stayed disabled. Detection succeeds; only applying the update is broken.

This is why the CLI is a prerequisite rather than a convenience. If you skipped
it:

```powershell
winget install Anthropic.ClaudeCode
```

Then reopen PowerShell.

---

## Why the first command is not optional

`claude plugin marketplace update` fetches new commits from the repository.
`claude plugin update` installs what was fetched.

Until the marketplace is refreshed, the plugin page shows your installed version
as the latest — and it is telling the truth about what it has. Run both, in
order.

---

## Confirming the update actually took

Two different things have to be true: the files on disk changed, and the
*running* server picked them up. A restart is what connects them.

**After restarting**, ask Claude:

> whoami

and read `grp_mcp_version` in the reply. That is the version actually serving
you — not what a settings page claims.

If it still shows the old version, Claude was not fully restarted. Closing a
conversation is not enough; quit the application.

---

## Your settings are not touched

Neither plugin keeps your settings inside itself. `censof-mcp` has none beyond
its token, which lives in your environment. For `grp-mcp`, `connections.json`
and `kb_server.json` live in `%LOCALAPPDATA%\grp-mcp\`, outside the plugin. Updating replaces the program only. You do not need to
re-enter anything, and you do not need to re-run the setup.

*(This page is about the **plugin**, which serves Claude Code — desktop app and
terminal alike. If you instead run **Claude Desktop**, the separate chat app,
you have a `.mcpb` **extension**, and updating that is a different and worse
story: an update there has ended with the extension removed, reinstalled, and
its settings re-entered by hand. Write them down first. This is the main reason
the plugin is the recommended route.)*

---

## Going back to an earlier version

Old versions stay on disk under
`%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\`, one folder per
version. If a new release causes a problem, say so and include the `whoami`
output — do not hand-edit that folder, as the installed-version record is kept
separately and editing one without the other leaves an inconsistent state.
