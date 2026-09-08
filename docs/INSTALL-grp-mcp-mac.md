# Install `grp-mcp-mac` — Acumatica on macOS or Linux

Same server as [`grp-mcp`](INSTALL-grp-mcp.md), started a different way.

> **`grp-mcp` now works on macOS and Linux too**, and new installs should use
> it. This page is still the right walkthrough — every step below is the same —
> just install `grp-mcp@censof-tools` instead of `grp-mcp-mac@censof-tools`.

**Why there were two.** Up to 0.81.0-rc14 the `grp-mcp` plugin bundled
`server/grp-mcp.exe`, a Windows binary. macOS cannot run it, so on a Mac that
plugin installed fine and then never started — no error you would recognise,
just no Acumatica tools. A plugin's `.mcp.json` has no way to pick a different
command per operating system, so the answer could not be a fix inside `grp-mcp`;
it had to be a second plugin.

As of rc15 `grp-mcp` ships no binary either — both plugins run the identical
Python code from PyPI, by the identical command. `grp-mcp-mac` stays published
so that anyone already on it keeps receiving updates.

**Install one or the other, never both.** They register the same server name and
you would get every tool twice, with no way to tell which answered.

---

## What you need

- **Claude Code**, and the `claude` CLI — see
  [INSTALL-censof-mcp.md](INSTALL-censof-mcp.md) step 1 if you do not have it.
  On macOS the **Add marketplace** button in the app registers the marketplace
  and then stops without installing; the CLI is the working route.
- **`uv`** — it fetches and runs the server in its own isolated environment.
  Windows needs it too now (`winget install astral-sh.uv`); until rc15 it did
  not, because that plugin carried a binary.

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
uvx --from grp-mcp-plugin==0.81.0rc26 grp-mcp-setup
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
time — `uvx --from grp-mcp-plugin==0.81.0rc26`. That is deliberate: an unpinned
`uvx` would silently change the server underneath you between one launch and the
next, and a plugin whose behaviour drifts without its version changing is
untraceable when something breaks. New server versions arrive the same way
everything else does, by updating the plugin.

---

## Differences from the Windows plugin

As of 0.81.0-rc15, **none that matter.** Both plugins run
`uvx --from grp-mcp-plugin==<version> grp-mcp`, need `uv`, and open the
config page with `grp-mcp-setup`. The only remaining difference is where the
config file lands — `%USERPROFILE%\grp-mcp\connections.json` on Windows,
`~/.grp-mcp/connections.json` here.

**What it used to look like, and why the split ended:**

| | `grp-mcp` up to rc14 | both, from rc15 |
| --- | --- | --- |
| How it starts | bundled `grp-mcp.exe` | `uvx` fetches the wheel from PyPI |
| Extra prerequisite | none | `uv` |
| Config page | `grp-mcp.exe --setup` | `uvx --from grp-mcp-plugin==<version> grp-mcp-setup` |
| `find_tool` | unavailable — built without `fastembed` | works |
| Repo cost per release | 23 MB, re-downloaded on every update | none |
| Every launch | ~1.6 s, steady | ~1.2 s median, more variable |

**Dropping the binary did not cost speed.** Measured 2026-09-03, five launches
each, start to a completed MCP handshake: the `.exe` took 1.63 s at the median
and the `uvx` wheel 1.23 s. The bundled binary is a PyInstaller one-file build,
so it unpacks itself to a temporary directory on *every* start, while `uvx` runs
from an environment already on disk. Windows was steadier (1.63–1.70 s) and
macOS quicker but more variable (1.23–2.60 s). Only the first launch, which
downloads, is meaningfully slower. Worth stating because the bundled-installer
version is naturally assumed to be the faster one, and it was not.

Everything above the launch mechanism — the tools, the gates, the write
verification, the KB preflight — is the same code.
