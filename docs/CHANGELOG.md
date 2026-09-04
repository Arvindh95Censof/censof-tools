# What changed

Newest first. Written for people using the plugins, not for whoever built them —
each entry says what you will actually notice.

**How to check what you are on:** ask the skill anything and read its first line —
*"Running rfs-analyze v2.8.4."* Or run `claude plugin list`, which shows the plugin
version.

Two version numbers, deliberately different:

| Number | What it counts |
| --- | --- |
| `censof-mcp 1.1.4` | the **plugin** — what `claude plugin update` installs |
| `rfs-analyze v2.8.4` | the **skill** inside it — what the answers are written by |

The plugin can change without the skill changing, and vice versa.

---

## censof-mcp

### 1.1.4 — rfs-analyze v2.8.4 · 3 Sep 2026

**An attachment is judged by its content, not its filename.** The rule about
attachments that belong to a different ticket had been written around one named file,
which read as a rule about *that file*. A live run then found a ticket whose second
attachment was a stock photograph of a mountain, with a filename that gave nothing
away either direction.

Corpus counts are now marked as a snapshot rather than a constant, and any figure
that carries an argument has to come from a live search rather than from that block.

### 1.1.3 — rfs-analyze v2.8.3 · 3 Sep 2026

**Answers use tables where they used to use paragraphs.** Precedent tickets, occurrence
counts, report facts and process state are now tables — five precedent tickets described
in a run-on paragraph was the previous behaviour, and the pattern that mattered got
buried mid-sentence. Causes and action lists stay prose, because an argument is not a
list and steps carry conditionals.

Self-corrections no longer reach you. A visible *"— sorry, I meant X"* in an answer means
it was not checked before it was sent; the correction now just gets applied.

### 1.1.2 — rfs-analyze v2.8.2 · 3 Sep 2026

**`--docs-only` is gone.** It was documented and nothing honoured it, so typing it
silently gave you a normal run. "The search was skipped" and "the search found nothing"
are different claims and you could not tell which you had.

Also fixed a step count that said six over a seven-row table, and a search rule that was
contradicted by every example beneath it.

### 1.1.1 — rfs-analyze v2.8.1 · 3 Sep 2026

**The instructions for updating a stale copy were themselves stale.** They told you to
ask for a zip file and swap the skill by hand — a route that died when this moved into
the plugin. They now give the two commands that work.

### 1.1.0 — rfs-analyze v2.8 · 3 Sep 2026

The largest change so far, from running the previous version against live open tickets.

| What | Why it matters to you |
| --- | --- |
| **Answers are five plain sections, then stop** | The technical hand-over is offered rather than written. Previously every answer was written twice and the technical half buried the diagnosis. |
| **Screen IDs are in the plain answer** | Being told to open the Loan Register did not tell you *where* it is. Identifiers you must type, click or quote are now in the readable part. |
| **Nothing unverified is written** | An identifier not confirmed from a live tool result never appears. Of the first three written from memory while testing, one was the wrong screen and one could not be confirmed at all. |
| **Live tickets are checked for being a re-key** | Every live ticket examined had a word-for-word twin already closed. One was open 54 days after the fix for its twin shipped — diagnosing it fresh would have sent a developer after a solved problem. |
| **SLA, assignment and age are reported** | Returned by every lookup and used by nothing. Tickets sat unassigned and breached with no one saying so. |
| **Two new verdicts** | *Fix deployed, verification outstanding* — the true state of three of five live tickets checked. And *refer to the external system owner*, for faults that are not in GRP. |
| **A shared error string is not a shared cause** | Five tickets carrying the same error had three different root causes, and every confidence signal called it a strong cluster. |

### 1.0.0 — rfs-analyze v2.7 · 28 Aug 2026

First release through the marketplace. Knowledge-base search plus the `rfs-analyze`
skill.

---

## grp-mcp

### grp-mcp-mac · 3 Sep 2026

**A new plugin, for macOS and Linux.** The `grp-mcp` plugin bundles
`server/grp-mcp.exe`, a Windows binary. On a Mac it installed cleanly and then
never started — no error, just no Acumatica tools, which is a hard thing to
diagnose from the outside. Reported by a Mac user who had worked around it by
running the server by hand from source, four releases behind and off the update
path entirely.

It could not be fixed inside `grp-mcp`: a plugin's `.mcp.json` has no way to
choose a different command per operating system, so the Windows binary and a Mac
executable cannot live behind one plugin. Hence a second one.

`grp-mcp-mac` ships no binary. It runs the same code from PyPI through `uvx`,
pinned to an exact version so the server cannot change underneath you while the
plugin version stays the same. One extra prerequisite — `uv`. Everything else is
identical: same tools, same gates, same write verification.

**Install `grp-mcp` or `grp-mcp-mac`, never both.** They register the same server
name, so you would get every tool twice with no way to tell which answered.

Also fixed, and the reason this works at all: **`grp-mcp --setup` now opens the
config page.** The flag was only ever implemented in the Windows build, so
running the Python package with it silently started an MCP server instead —
which would have left Mac users with no way to create a `connections.json`.

And a second one found by testing rather than by report: the server looked up its
own version under one distribution name only, so installed under the new name it
announced itself as **`0+unknown`** — over the MCP handshake and in `whoami`, i.e.
the first thing anyone is asked for when reporting a problem. Caught by driving
the published package over stdio instead of trusting that it worked.

Two macOS notes now in the docs: the **Add marketplace** button in the app
registers the marketplace and stops without installing (`Found 0 local plugins`),
so install from the CLI there; and the config file lives at
`~/.grp-mcp/connections.json`.

The two Acumatica plugins carry different version numbers on purpose:
`grp-mcp` **0.81.0-rc12** (its bundled Windows binary is unaffected by the
version-reporting fix, so it was not rebuilt) and `grp-mcp-mac` **0.81.0-rc13**.

### Setup tools · 3 Sep 2026

**`Edit-Connections.cmd` now opens the connections file the server actually reads.**
Claude installs as an MSIX package, so everything it launches — the grp-mcp server
included — runs inside that package container, where writes to
`%LOCALAPPDATA%\grp-mcp` are quietly redirected into
`%LOCALAPPDATA%\Packages\Claude_<id>\LocalCache\Local\grp-mcp`. Double-clicking
the launcher from Explorer runs *outside* the container, where that same path is a
different and usually empty folder.

The result looked like a broken tool: the editor opened on nothing and said
*"No profiles yet"* on a machine with twelve profiles configured and working. The
worse half was silent — saving a profile from that empty page wrote a **second**
`connections.json` that the server never reads, so edits appeared to succeed and
simply had no effect.

The launcher now finds the real file and points `GRP_MCP_CONNECTIONS` at it, which
also settles `kb_server.json` since that is written beside whichever connections
file is in use. First run on a packaged Claude creates the file inside the
container, where the server will look for it. If a config exists in both places it
says so, without telling you to delete either — on a launcher run from inside the
container, the "other" path is the same file under a second name.

Also fixed alongside: the fallback that locates `grp-mcp.exe` in the version cache
sorted by **name**, so `rc9` outranked `rc12` and a machine with more than one
build cached would launch the oldest. It now sorts by date.

Delivered by `claude plugin marketplace update censof-tools` — no plugin version
change and no `claude plugin update` needed.

### 0.81.0-rc12 · 28 Aug 2026

**The knowledge-base settings no longer save into whatever project you have open.**
A first-ever save wrote `kb_server.json` — which can hold a bearer token — into the
current working directory. It now goes to `%LOCALAPPDATA%\grp-mcp` like everything else.

`kb_status` also stopped naming a file nobody was reading: it reported a candidate path
rather than the file actually in use, so it could name a path that did not exist while
every knowledge-base call succeeded.

### 0.81.0-rc11 · 28 Aug 2026

**`grp-mcp.exe --setup` creates your connections file.** Before this there was no way to
produce one from the plugin at all — the documentation pointed at a setup program that
plugin users never received.

Also stopped a first-ever save writing your ERP password into the current working
directory, for the same reason as rc12's fix.

### 0.81.0-rc10 · 28 Aug 2026

Finds `connections.json` in `%LOCALAPPDATA%\grp-mcp` on its own. No environment variable
needed.

---

## Where the detail lives

This page is the short version. For any release:

| Want | Look at |
| --- | --- |
| Every rule that changed, with the evidence | the skill's own changelog, at the top of `SKILL.md` |
| The reasoning and what it cost to find | the commit message for that version |
| How to update | [UPDATING.md](UPDATING.md) |
