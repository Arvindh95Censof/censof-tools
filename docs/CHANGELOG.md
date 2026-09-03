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
