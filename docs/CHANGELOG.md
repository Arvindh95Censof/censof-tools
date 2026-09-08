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

### Both Acumatica plugins at 0.81.0-rc21 · 8 Sep 2026

**A delete that did not happen can no longer be reported as confirmed.**

After a delete, the tool checks the record is actually gone — Acumatica will
refuse to delete a record that something else references, and it does that
*without* reporting an error, so the check is the only thing standing between you
and a false success.

The problem was what happened when that check could not run. If the instance
timed out, or returned an error, or the screen re-read came back unreadable,
three separate code paths treated the silence as proof the record was gone. You
were told the delete was confirmed. Delete is the one thing here with no undo,
so a wrong "confirmed" is the worst possible place for this.

You now get **unverified**, plus a line saying which half failed — the delete
itself reported success, it is the confirmation that could not run. That matters,
because "unproven" and "doubtful" call for different reactions, and the message
now tells you not to re-issue the delete on the strength of that verdict.

Nothing changes when the check *does* run: a confirmed delete still says
verified, and a record that survived still says SILENT NO-OP.

**A failed knowledge-base lookup now says what actually went wrong.** If the KB
server answered but its search failed, you were shown a JSON parsing error —
which sent people looking for a formatting problem in their config file. The real
explanation was already there and was being thrown away. You now see what the KB
said.

### Both Acumatica plugins at 0.81.0-rc20 · 8 Sep 2026

**Error messages actually reach you now.** This is the one to know about, because
it was quietly making everything else look worse than it was.

Every failure — a mistyped argument, a record that does not exist, a permission
refusal — arrived as the same sentence:

```
Error executing tool get_entity
```

No status code, no message, no field name. Three unrelated problems produced
byte-identical output, so one fault looked like three, and the fix was never in
what you were shown. The server had written a perfectly good explanation every
time; something between it and you was deleting the text and keeping only the
tool's name. It was not in the logs either, so there was no way to go and look.

You now get the whole thing. Including the ones that tell you exactly what to do:

```
field 'Department' is ambiguous - qualify it: Employee.Department, AddressInfo.Department
Writes are disabled for instance 'X'. Set "allow_write": true in its connections.json profile
API Login Limit
```

Genuine internal faults are still kept back — that part was deliberate and stays.
What changed is that our own messages, the ones written for you to read, are no
longer treated as internal.

This also means last release's work is finally visible: rc19 rewrote Acumatica's
refusals so the cause comes first, and none of it could reach a client.

**A write that worked is no longer reported as failed.** Creating a record and
setting an account to `200000` could come back "the read-back CONTRADICTS this
write — treat it as NOT persisted", on a record that was complete and correct.
The screen takes the code you typed; the table stores an internal ID for it, and
the two were being compared directly. Eight fields at once in one case. If you
have re-done work because of that message, it may not have needed re-doing.

**`dry_run` works on a read-only profile.** Rehearsing a write is the one thing
you would want *before* asking for write access, and it was refused for not
having write access. Nothing about what it does has changed — it still writes
nothing.

**The undo instructions no longer point at a dead end.** After creating a record,
the `undo` block named a tool that could not accept the details it was given, and
often could not reach that record at all. It now gives the route that works, or
both routes and how to tell which applies.

### Both Acumatica plugins at 0.81.0-rc19 · 7 Sep 2026

**When Acumatica refuses something, you now get the reason first.**

Acumatica explains a refusal in a way that buries the useful sentence. A failed
read used to come back looking like this, and the part you needed was about two
hundred characters in, after a constant phrase, a .NET type name and a stack
trace from Acumatica's own build machine:

```
GET .../Customer -> 500: {"message":"An error has occurred.","exceptionMessage":
"The required configuration data is not entered on the Account Receivable
Preferences form.","exceptionType":"PX.Data.PXSetupNotEnteredException`1[[...
```

Now the cause leads:

```
GET .../Customer -> 500: The required configuration data is not entered on the
Account Receivable Preferences form. [PXSetupNotEnteredException: ARSetup] | {...}
```

The seat-limit failure got the same treatment — it arrives as a styled web page
whose entire message is the title, so you now see **API Login Limit** instead of
a doctype and a stylesheet.

Nothing was removed. The original response is still there, in full, after the
summary — several tools read it to decide whether to retry a different way, and
shortening it would have broken them silently.

Found while testing rc18 against a live instance: a read failed, and the message
that came back named neither the cause nor the fix.

```powershell
claude plugin marketplace update censof-tools
claude plugin update grp-mcp@censof-tools
```

### Both Acumatica plugins at 0.81.0-rc18 · 7 Sep 2026

**A small one, and worth saying so.** Nothing here changes what the plugin can do.

**`find_tool` understands more of the words you actually use.** Asking for a
supplier, a payment, a receipt, a purchase order, a sales order, a warehouse or a
bill now finds the right tool — those words appeared in none of the 120 tool
descriptions before, so a question phrased that way had nothing to match. Measured
on the same test questions: 67% to 70% first-time-right on real wording. Two more
questions out of a hundred. Real, but small.

Some words were left out on purpose. There is no bank reconciliation, cheque,
email or claims tool in this server, so teaching `find_tool` those words would
only make it answer confidently with something that cannot do the job. Ask about
those and you still get "nothing here answers that", which is the truthful reply.

**`find_tool` stopped printing a long notice about an optional component.** Every
result carried a paragraph explaining how to install a search add-on, written when
that add-on was normally present. Since rc17 nobody has it — it was removed
because the plugin measured *better* without it — so the notice appeared every
time and read like a fault. It is one short line now.

Nothing to do differently. Update when convenient:

```powershell
claude plugin marketplace update censof-tools
claude plugin update grp-mcp@censof-tools
```

### Both Acumatica plugins at 0.81.0-rc17 · 7 Sep 2026

**`find_tool` got a lot better, and lost its only heavy dependency.** It is the
tool that finds the right one of 120 from a plain description of what you want.
It used to rank by an AI embedding model; it now ranks by a lexical scorer built
into the package, with the model gone.

Measured on the same questions, before and after — top hit correct:

| | before | after |
| --- | --- | --- |
| real user wording, lifted verbatim from transcripts | 39% | **67%** |
| all 117 labelled questions | 56% | **76%** |

The embedding model was not misconfigured; it was the wrong tool for a small
corpus of ERP jargon, where rare exact terms matter more than paraphrase. It was
measured to score *lower* alongside the lexical scorer than the lexical scorer
alone, so it is no longer pinned.

**What you will notice:** the first `find_tool` call no longer downloads a
~210 MB model, and `uv` installs about 95 MB less on first launch. `find_tool`
also now says `OFF_DOMAIN` when a question shares no vocabulary with any tool,
instead of returning a confident-looking wrong answer.

Everyday words — dropdown, approve, void, reopen, stuck — that appeared in no tool
description now do, so asking in your own words works more often.

```powershell
claude plugin marketplace update censof-tools
claude plugin update grp-mcp@censof-tools
```

### Both Acumatica plugins at 0.81.0-rc16 · 7 Sep 2026

**Nothing you will notice, and that is the point of saying so.** The server is
byte-for-byte the same as rc15. This release exists because the checks that guard
what gets published were not catching enough, and the fix belongs in an artifact
rather than in a note somewhere.

The release gate now catches **client names and internal hostnames**, not only
things shaped like passwords and API keys. On 7 Sep three of them reached public
packages while that gate reported clean, because a customer's name looks nothing
like a credential. It cannot simply hold a list of the names, either — the gate
itself is published, so writing them into it would be the leak. It reads them at
release time from the configuration that never leaves the maintainer's machine.

If you are already on rc15 there is no urgency. Update when convenient:

```powershell
claude plugin marketplace update censof-tools
claude plugin update grp-mcp@censof-tools
```

**One thing worth knowing if you update immediately after a release is
announced:** `uv` caches its view of the package index, so a brand-new version
can report *"requirements are unsatisfiable"* for a minute or two. It is not a
broken install — wait, or force a refresh once:

```powershell
uv cache clean grp-mcp-plugin
```

### Both Acumatica plugins at 0.81.0-rc15 · 7 Sep 2026

**`grp-mcp` no longer ships a Windows binary, and now needs `uv` like the Mac one
does.** One new step, once:

```powershell
winget install astral-sh.uv
```

Then reopen PowerShell — the installer adds a folder to your PATH and an
already-open window will not see it.

**What this buys you: `find_tool` works.** It is the tool that finds the right
one of 120 from a description of what you want, and on Windows it had never once
run. The bundled `.exe` was built with its search library deliberately excluded
to keep the download to 23 MB, so every Windows install has been answering
*"fastembed not installed"* since the feature shipped. Putting the library back
in the binary would have taken the download to roughly 120 MB — re-downloaded in
full on **every** update, because the marketplace clone is shallow. Running from
PyPI costs one `winget` line instead, and starts measurably faster: 1.23 s to a
completed handshake against the binary's 1.63 s.

**`grp-mcp-mac` is superseded.** It only ever existed because a Mac cannot
execute a Windows `.exe`. Both plugins now run the identical line, so there is
nothing left to choose between them. **You do not have to do anything** — it
stays published and keeps updating. New installs should take `grp-mcp`.
As before: install one or the other, never both.

**Also fixed:** the Mac plugin's version pin had been asking for the package
*without* its `[search]` extra, so `find_tool` reported itself unavailable there
too. Both pins now include it. And `Edit-Connections.cmd` reads the version the
plugin pins straight out of its own `.mcp.json` rather than looking for a binary,
so the config page cannot be a different build from the server it is configuring.

**First launch after updating is slow** — a minute or so while `uv` fetches the
server. Once. The first `find_tool` then downloads its embedding model (~210 MB),
also once, after which it runs offline. Everything else works meanwhile.

### Both Acumatica plugins at 0.81.0-rc14 · 4 Sep 2026

The Windows binary was rebuilt so it actually carries the location fix below —
until now the config page wrote to the new place while the shipped binary still
read the old one. Both plugins are on rc14 now and agree.

**Update both commands, then restart.** If you already had a config, it stays
exactly where it is and keeps working; nothing is moved for you.

### Config moved out of AppData · 4 Sep 2026

**A Claude app update deleted a user's saved connections overnight.** Twelve
profiles, including live client credentials, gone with no warning and no error —
the folder was recreated empty. Recovered only because an unrelated copy happened
to still be sitting in a OneDrive recycle bin.

The cause: `connections.json` defaulted to `%LOCALAPPDATA%\grp-mcp`. Claude
installs as an MSIX package, so the server it launches sees `%LOCALAPPDATA%` as
the package's *LocalCache* — and a container reset takes that folder with it. A
default a routine update can delete is not a default.

It is now **`%USERPROFILE%\grp-mcp`**, outside `AppData`, where no container maps
it and no update reaches it. Verified by listing the same path from inside the
container and outside — both see the same files, where the old path showed files
to one and an empty folder to the other.

**Nothing moves on its own.** The old location is still searched, and saves go
back to whichever file was loaded, so an existing install keeps working and no
config forks into two copies. `Edit-Connections.cmd` now says plainly when it
finds a config somewhere an update can delete, and gives the two commands to move
it.

Worth doing even so: **back that file up.** It holds every ERP password you have
configured, in clear text, and nothing else on your machine has a copy.

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

### Docs: macOS, everywhere it was missing · 3 Sep 2026

Adding the `grp-mcp-mac` plugin covered how to install it, and left three holes
elsewhere. An audit found them by counting, not by reading: `CONFIGURE.md` had 18
Windows-only references and zero mentions of macOS, and the repo README had six
and none.

**How a Mac user sets their token was documented nowhere.** `docs/tools/` holds
only `.cmd` and `.ps1` scripts, and the token step in the censof-mcp guide was
entirely PowerShell. That blocked the plugin *everyone* installs, not just the
Acumatica one.

Written out now, including the part that would have cost someone an afternoon:
on macOS an app launched from **Finder, the Dock or Spotlight never reads
`~/.zshrc`**. So exporting the token in a shell profile works for `claude` in a
terminal and does nothing for the desktop app — and it fails as an authorisation
error on every search while the plugin looks perfectly healthy. Either launch
from a terminal, or `launchctl setenv` and restart.

`CONFIGURE.md` now gives `~/.grp-mcp/` alongside `%LOCALAPPDATA%\grp-mcp\`
throughout. `docs/tools/README.md` says outright that everything in it is a
Windows script and points at the manual equivalents. `INSTALL-grp-mcp.md` opens
by telling a Mac reader they are in the wrong guide.

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
