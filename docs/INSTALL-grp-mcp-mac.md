# Install `grp-mcp-mac` — Acumatica on macOS or Linux

Same server as [`grp-mcp`](INSTALL-grp-mcp.md), started a different way.

**Why there are two.** The `grp-mcp` plugin bundles `server/grp-mcp.exe`, a
Windows binary. macOS cannot run it, so on a Mac that plugin installs fine and
then never starts — no error you would recognise, just no Acumatica tools. A
plugin's `.mcp.json` has no way to pick a different command per operating
system, so the answer could not be a fix inside `grp-mcp`; it had to be a second
plugin. This one runs the identical Python code from PyPI instead of a bundled
binary.

**Install one or the other, never both.** They register the same server name and
you would get every tool twice, with no way to tell which answered.

---

## What you need

- **Claude Code**, and the `claude` CLI — see
  [INSTALL-censof-mcp.md](INSTALL-censof-mcp.md) step 1 if you do not have it.
  On macOS the **Add marketplace** button in the app registers the marketplace
  and then stops without installing; the CLI is the working route.
- **`uv`** — this is the one thing Windows users do not need. It fetches and runs
  the server in its own isolated environment.

  ```bash
  brew install uv
  ```

  or, without Homebrew:

  ```bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  ```

  Check it: `uv --version`. Reopen your terminal if it is not found.
- **Your Acumatica credentials**, and a user with the *Web Services API* role on
  the instance you are connecting to.

---

## 1. Add the marketplace

```bash
claude plugin marketplace add https://github.com/Arvindh95Censof/censof-tools.git
```

Use the full `.git` URL. A `repository not found` here almost always means
permission, not a typo — GitHub returns 404 for private repositories you cannot
see.

## 2. Install the plugin

```bash
claude plugin install grp-mcp-mac@censof-tools
```

## 3. Create your connections file

The server reads its instances from `connections.json`. Create it with the same
config page Windows users get:

```bash
uvx --from grp-mcp-plugin==0.81.0rc13 grp-mcp-setup
```

A browser tab opens on `http://127.0.0.1:8765`. Add your instance, click **Save
profile**, then close the terminal window.

The file lands in `~/.grp-mcp/connections.json`, and the server looks there on
its own — no environment variable to set. The terminal prints the exact path
before the browser opens; that is the one place you are told where your
credentials went.

> **Keep that file out of any synced folder.** It holds ERP passwords in clear
> text. `~/.grp-mcp/` is local and is not iCloud- or Dropbox-synced by default.

## 4. Restart Claude Code

Fully quit and reopen. A running program keeps the environment it started with.

## 5. Check it

Start a session and ask Claude to run `whoami`. You should get your instance
name, tenant and endpoint back. If the tools are missing entirely, see
[TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## 6. Confirm both halves agree on where the file is — once

Thirty seconds, first install only. It catches a failure that produces no error
at all, and the Windows version of it cost a day on 2026-09-03.

1. Note the **Connections file** path that step 3 printed.
2. Ask Claude: **`what does kb_status say?`**
3. Compare the `spec_path` it reports with the folder from step 1.

**Same folder → you are done.** Different → the config page and the server are
looking at two different places, and every edit you make will appear to save and
have no effect.

<details>
<summary>Why this can happen, and what to do</summary>

On Windows this is exactly what went wrong: Claude installs as an MSIX package,
so processes it launches run inside a container where writes to
`%LOCALAPPDATA%\grp-mcp` are silently redirected into
`%LOCALAPPDATA%\Packages\Claude_<id>\LocalCache\Local\grp-mcp`. The config page,
double-clicked from Explorer, ran outside that container and used the real, empty
folder. It reported "No profiles yet" on a machine with twelve profiles working,
and a save there would have created a second file the server never reads.

macOS can do the same thing for a different reason: if the Claude app is
sandboxed, `~` for the server resolves to
`~/Library/Containers/<bundle-id>/Data/` rather than your real home, while a
terminal-launched `grp-mcp-setup` writes to the real `~/.grp-mcp/`. Whether that
applies here is untested — hence the check rather than a claim.

**If the paths differ**, point both halves at the file the *server* named, and
tell the OPEX team so the launcher can resolve it automatically the way the
Windows one now does:

```bash
export GRP_MCP_CONNECTIONS="<the spec_path folder>/connections.json"
```

Put it in your shell profile, and re-run `grp-mcp-setup` afterwards — it honours
that variable ahead of everything else, so the page will then edit the file the
server actually reads.

</details>

---

## Updating

```bash
claude plugin marketplace update censof-tools
```

```bash
claude plugin update grp-mcp-mac@censof-tools
```

Then restart Claude Code.

The version of the server is **pinned in the plugin**, not resolved fresh each
time — `uvx --from grp-mcp-plugin==0.81.0rc13`. That is deliberate: an unpinned
`uvx` would silently change the server underneath you between one launch and the
next, and a plugin whose behaviour drifts without its version changing is
untraceable when something breaks. New server versions arrive the same way
everything else does, by updating the plugin.

---

## Differences from the Windows plugin

| | `grp-mcp` (Windows) | `grp-mcp-mac` |
| --- | --- | --- |
| How it starts | bundled `grp-mcp.exe` | `uvx` fetches the wheel from PyPI |
| Extra prerequisite | none | `uv` |
| Config page | `grp-mcp.exe --setup` | `uvx --from grp-mcp-plugin==<version> grp-mcp-setup` |
| Config file | `%LOCALAPPDATA%\grp-mcp\connections.json` | `~/.grp-mcp/connections.json` |
| First launch | instant | a few seconds while `uv` downloads the wheel, once |

Everything above the launch mechanism — the tools, the gates, the write
verification, the KB preflight — is the same code.
