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

### Both Acumatica plugins at 0.81.0-rc34 - 11 Sep 2026

**Six ways a write or a delete could tell you the wrong thing.** Every fix here came
out of driving the tools against a live instance and reading the database afterwards,
rather than trusting what the tool reported.

**A delete your profile forbids could still happen.** The diagnostic replay accepted
`operation="delete"` but ran under the *write* permission instead of the delete one.
A profile set to allow writes and refuse deletes therefore had a delete path it was
configured to forbid. It now refuses and points at the proper delete tool.

**A segmented key could be reported deleted while it was still there.** The tool
decided whether the key existed by asking three tables that, on some instances, answer
successfully with no rows at all - so it concluded "nothing to delete", said `ok`, and
left the key untouched. Its final check asked the same empty tables, so the wrong
answer was confirmed twice. It now confirms on a plane that can actually see the
record, and returns "cannot confirm" rather than "absent" when nothing can.

**A committed import could report that it committed nothing.** The per-row processed
flags lag the run's own status, so reading them once, straight after the status
changed, caught every row still false - while the records existed in the database.
The rows are now polled until they are all accounted for.

**Import scenarios silently dropped `=` formulas.** On any screen with a lookup key
field the screen inserts extra rows of its own, which knocked the repair step out of
alignment; every formula was stored mangled and the tool reported success. Constants
became bare text, functions were evaluated away, and references became null.

**A delete could be confirmed against the wrong record.** Some screens jump to a
different record after saving. The check asked "is the row I deleted missing from what
I can see now?" - and it was missing, because it was looking at another record.

**Classic screens that page through records now work at all.** Screens with no way to
jump straight to a record by key - Segmented Keys among them - were unreachable to
every classic-plane tool, which reported the key field name as wrong when it was
correct. They now page to the record instead. That also makes a multi-segment
segmented key deletable for the first time.

### Both Acumatica plugins at 0.81.0-rc33 - 11 Sep 2026

**Saving a change to a large table no longer reports a failure that did not
happen.** After you change a row, the tools read the table back to check the
change really landed - that read-back is the whole basis of the promise not to
trust a clean *"OK"*. It was fetching only the first twenty rows. So a change to
any row further down came back as **rejected** when it had saved perfectly. On
the Chart of Accounts, which holds 405 rows, that meant everything past the
twentieth.

**It was the same setting rc32 caught, sitting in a second place nobody looked.**
The last entry described finding a row-count value copied out of a browser window
and fixing it before it could do any harm. That fix went into one of the two
places carrying that number. The other was already live, and it wins whenever a
row is selected - which is every change and every delete. The trap described last
time as *caught on the way out* had in fact been sprung for a while, in the
function next door.

**A delete could be reported as successful when it may not have happened.** This
is the worse direction, and worth saying plainly. The check for *did the delete
work?* was: is the row still in the table? On a table too large to read in one go,
a row beyond what could be seen looks exactly like a row that was removed. So a
delete that did nothing could come back confirmed. It now says it could not check.

**Past a thousand rows it now says so, instead of guessing.** The tools still read
a limited number of rows at a time; what changed is what they say on reaching that
limit. Before, you got either *your change was rejected* or *there is no such row*
- both stated confidently, both apparently about your data, when the real cause
was their own reading limit. They now say they could not check, say how to check,
and decline the change rather than send one they cannot confirm afterwards. If you
work with tables this large, narrow them with a filter first.

**An error that said nothing now says what was refused.** A permissions failure
came back as `403:` - ending there, nothing after the colon. The explanation had
been in the response the whole time, in a place the code never read. It now names
what was denied. This surfaced while deliberately removing a user role to test a
claim in our own notes, and it mattered more than it looked: that same blank error
appears when the tools lose the access they use to find their way around a site,
and it was indistinguishable from a screen simply not having an old-style page.

**The written record now matches the software.** Checking our own notes against a
live system, four claims did not survive contact with it - including one that
described a whole family of tools as read-only when six of them write, and one
that blamed a behaviour on an Acumatica version when it actually depends on how
the individual site was installed. All corrected against measurement.

**The pattern, for the third time.** The last entry noted a recurring shape:
something reports success, or reports nothing, while quietly doing nothing - and
the note about it gets filed narrower than the problem really is. This release is
that shape again, one level up: a fix was correct, and the search for other copies
of the same fault was too narrow. Three separate defects here were each a second
copy of something already found and fixed elsewhere. The lesson being written down
is that finding a bug is not finishing it; the sweep for its siblings is part of
the fix.

### Both Acumatica plugins at 0.81.0-rc32 - 11 Sep 2026

**Reading a table now returns its rows.** On older-style Acumatica screens, asking
the tools to look at a table came back with the right column names and **no rows
at all** - on every such screen, since the day that feature existed. The Chart of
Accounts reported nothing where it holds 406 accounts.

It is the same missing piece that broke the Excel import in rc31, and filing that
as an import problem was the mistake. The tools use those reads twice: to check a
row exists before changing it, and to confirm afterwards that a change really
happened. Both were reading from a table that always looked empty, so neither
check could do its job.

Worth being precise about what that did and did not mean. Nothing was ever
reported as saved when it had not been - an empty read was treated as "could not
check", never as "confirmed". But **"could not check" was as good as it ever got**
for this kind of change, and that is the opposite of what this product promises.
It now confirms properly.

**A trap caught on the way out.** The fix carries a setting that decides how many
rows come back, and the value in the code had been copied from a browser window:
sixteen. That was harmless while only the Excel import used it, because importing
reads no rows. Switched on everywhere unchanged, it would have turned "sees
nothing" into "sees the first sixteen" - so changing the fortieth row of a table
would come back as *row not found*. A wrong answer is worse than no answer, and
this one would have looked authoritative. Found by asking why the first successful
read returned exactly sixteen rows.

**Importing into the wrong table now says so.** A screen can hold five tables with
only one import button. Asking to import into one of the others used to get past
the check and fail later blaming something unrelated. It now refuses immediately
and tells you which tables on that screen do take an import.

**We also counted properly for once.** The note in our own records said the import
button appeared on "3 of 8 screens sampled" - a handful of screens checked by hand,
written down as though it were a survey. Counting every screen Acumatica ships:
**185 tables across 125 screens**. Four screens picked from that list at random
worked on the first attempt, having never been tried before.

**Worth recording, because it is becoming a pattern.** Three times now the same
shape has appeared: something reports success, or reports nothing, while quietly
doing nothing at all - and the record of it gets filed narrower than the problem
actually is. rc29 fixed saving and the note was filed as applying to one kind of
screen. rc31 fixed the import and the note was filed as being about imports. Each
time the real fault was wider than the place it was noticed, and each time the
filing is what hid the rest. The fix this release is the part rc31 should have
caught.

### Both Acumatica plugins at 0.81.0-rc31 - 10 Sep 2026

**The green Excel button on a table toolbar now works.** On older-style Acumatica
screens, some tables carry a toolbar button that loads rows in from a .csv or
.xlsx file. Driving that button through Claude had been *accepted* by Acumatica
and then quietly written nothing - no error, no warning, a clean-looking result
and an unchanged table.

The cause was one piece of information a web browser fills in and a script does
not. The page carries a hidden field describing the table, and the page itself
always sends it empty; the browser fills it in a moment later from the screen
running in front of you. Nothing readable off the page would ever show that
value, which is why this took as long as it did - every response we got back
matched a real browser's exactly, while the request was missing the one field
that mattered.

It is now sent, and the load works end to end: verified by importing rows,
reading them back out of the database, and deleting them again. Checked against
every screen we could find that offers the button.

**A save is no longer lost when your session is taken over.** Acumatica ends your
screen session if the same login is used again somewhere else - including by our
own housekeeping, which frees up the small number of API seats an instance
allows. A write refused for that reason is now retried once. The retry is
deliberately narrow: it only happens when we can confirm nothing was written, so
a save that might have gone through is never sent twice.

**One correction.** A note about a screen used for numbering setup said the
screen could not be driven at all. It can - just not the way that was tried.
Adding a new row there opens a dialog, and a request that ignores the dialog
comes back reporting success over nothing at all. That is now recorded properly.

**Worth recording, because it is the same lesson twice.** Eleven separate
explanations for the file-load failure were tested and ruled out, every one of
them against the same four saved requests. What actually found the answer was
looking *wider* rather than closer - listing every request the screen makes,
including several nobody had ever opened. Two of the ruled-out explanations had
already been written down as fact by then; both were wrong, and both are now
marked as such. A difference you can see is not automatically the difference
that matters.

### Both Acumatica plugins at 0.81.0-rc30 - 10 Sep 2026

**Guidance only - nothing about how the tools work has changed.** rc29 fixed
editing and deleting rows in tables on older-style Acumatica screens. This
release fixes the explanations that still described the broken behaviour.

Seven of them, and one was doing real harm: if you asked for a table by a name
the screen did not recognise, the tool concluded the table could only be edited
a different way and sent you off down that road. The real cause was almost
always just the name - these screens have an internal name for each table that
is not always the one shown elsewhere. It now lists the names that screen
actually has, so a wrong guess costs one attempt instead of a wrong conclusion.

Also fixed: two tools never explained that setting at all; one screen was being
held up as the standard example of something it demonstrably is not; and the
advice for a table that asks "are you sure?" described a leftover state that no
longer happens.

**Worth recording, because it explains the seven weeks.** The note that had to
be rewritten here turned out to have recorded rc29's fix correctly back in July.
It identified the exact missing step. It was then filed as applying only to one
narrow kind of screen - and on every other kind the same problem was failing
silently, so nothing ever contradicted it. The answer sat there, correct and
shelved, while the underlying bug went unnoticed. The note now carries that
lesson rather than the limitation.

### Both Acumatica plugins at 0.81.0-rc29 - 10 Sep 2026

**Editing or deleting a row in a table now actually saves it.** On older-style
Acumatica screens it had been going through the motions: the tool reported
success, and nothing reached the database.

Those screens need two steps - prepare the change, then save it - and only the
first was ever sent. Every edit and every delete of a table row on that kind of
screen was affected.

It stayed hidden this long because a change that has been prepared but not saved
looks identical to a change that was never needed: no error, a clean-looking
response, the right number of rows. Worse, because the symptom showed up
everywhere, it kept being written down as a limitation of whichever screen
happened to be in front of us at the time. Three such notes turn out to have
been describing this one missing step. The most misleading of them said a
particular family of screens simply could not be edited this way; they can, and
now do.

**Checked properly this time.** Five genuinely different kinds of table were
driven end to end against a live system - simple ones, ones with multi-part row
identifiers, one where the table IS the screen, one that asks "are you sure?"
before deleting, and one tucked inside a tab. Every result was confirmed by
reading the database back, not by believing the tool.

**Four smaller problems surfaced during that testing and are fixed too:**

- Asking for a table by name could fail with no way forward, because the name
  the tool wanted was not the one it had shown you. It now lists the names that
  screen actually has.
- If a screen asked for confirmation and none was given, the half-finished edit
  was left sitting there and interfered with whatever you did next - including
  the retry the tool itself suggested.
- The first request after another part of the system had been used could come
  back empty and fail.
- A connection dropped by the server was kept and reused, so one bad moment
  turned into every following action failing.

**One known limitation.** When Acumatica signs you out and straight back in -
which it does on its own when the instance runs short of licences - the very
next save is refused. Only that one; the following attempt works. The tool now
says plainly that nothing was saved, rather than appearing to succeed.

### Both Acumatica plugins at 0.81.0-rc28 - 9 Sep 2026

**Adding a step to an existing approval map works again on older Acumatica
builds.** On those builds it did not work at all - it stopped with a message
saying nothing had been saved.

That message was the worst part of it. The step *had* been created correctly.
What failed was the tool reading its own work back afterwards: the screen
answered that question with nothing at all, which is indistinguishable from
"the map is empty", so the tool concluded it had failed and said so. Anyone
following that advice would have gone looking for a problem that was not there,
and might reasonably have built the map again from scratch.

Only that one operation was affected. Building a map, changing its amount
limits, removing a step, and everything on the Company Tree screen all worked on
those builds throughout - which is why this went unnoticed: four of the five
newest tools were fine.

Found by running all five against a real older instance rather than the newest
one, end to end, and cleaning up afterwards.

**Also in this release, though you will not see it directly:** the server keeps
a knowledge base and consults it on your behalf before every write. Because the
bug above came from a finding that was recorded from one Acumatica version and
read as though it were true of all of them, every claim in that knowledge base
was re-checked against a live older instance. Most held unchanged. Three did
not, and were corrected - including one that had been left explicitly
unfinished, where the real answer turned out to affect roughly two thirds of
screens rather than the single one it had been recorded against.

### Both Acumatica plugins at 0.81.0-rc27 - 8 Sep 2026

**Writes that succeeded stop being reported as unproven.**

After any write, the server checks whether it actually landed and tells you the
answer: confirmed, refused, or unproven. That label matters, because Acumatica
will sometimes accept a change and quietly do nothing, and the check is what
catches it.

A bug meant some writes that HAD been fully checked were labelled unproven
anyway, with a long note attached about how to investigate a failure that had not
happened. Building a company tree was the clearest case: every workgroup was
confirmed against the database, and you were still told nothing had been proven.

The data was never wrong. The report about the data was wrong - which is worse
than it sounds, because a label that cries wolf is one people learn to skip, and
this is the label worth reading.

Found by running the tools the way you run them, rather than from a test script.
The mislabelling happened in a layer that only exists on the real call path, so
nothing internal had ever shown it.

### Both Acumatica plugins at 0.81.0-rc26 - 8 Sep 2026

**No change to what the tools do.** This one is worth taking anyway, but it is
honest to say up front that nothing behaves differently.

The server keeps a knowledge base and consults it on your behalf before every
write - that is where the warnings and prerequisites attached to a write come
from. This release adds a section to it, generalizing what a run of releases
across the Company Tree and Approval Maps screens kept re-teaching.

The most useful of those, if you ever read a result and wonder whether something
is missing: **a screen answers with only what was asked for.** A grid that comes
back empty, or a list showing one row where you expected several, very often
means the question was incomplete rather than the data absent. Three times in one
day that reading produced a wrong conclusion - twice deciding a command had done
nothing when it had worked perfectly, and once treating an insert as successful
when it had saved nothing at all.

That reasoning now travels with the package instead of living only in the source
repository, so the guidance you see attached to a write reflects it.

### Both Acumatica plugins at 0.81.0-rc25 - 8 Sep 2026

**An approval map can be changed instead of rebuilt.**

Until now a map was fixed once created: its steps, and the amount limits on them.
Raising a threshold from 10,000 to 25,000 meant deleting the map and building it
again from scratch. That is the change a live approval matrix needs most often,
because limits get renegotiated while everything else stays the same.

Three things you can now do to a map that already exists:

- **Change the amount bands on a rule.** Give it the full set of limits you want
  and it works out the difference.
- **Add a step**, with the workgroup that approves it and optionally its own
  limits. It is added at the end of the sequence.
- **Remove a step or a single approver.** Removing a step takes its approvers with
  it; removing just an approver leaves the step in place.

Two of these do quiet extra work so that the result is what you asked for. A new
step genuinely ends up last, rather than landing in the middle because of how the
screen numbers things. And when limits change, a rule is never briefly left with
none - which matters, because a rule with no limit matches every document, and
for a moment everything would route through that approver.

**There is still no undo.** Removing a step is permanent; it is rebuilt by adding
it again, not recovered.

### Both Acumatica plugins at 0.81.0-rc24 · 8 Sep 2026

**Workgroups can be reordered within their branch.**

Moving a workgroup up or down among its siblings changes the display order only —
never which workgroup it sits under. Other branches are left alone.

If you ask to move it further than there is room for, it moves as far as it can
and says so. That matters more than it sounds: at the top or bottom of a branch
the screen accepts the click and silently does nothing — no error, no message —
so the honest answer has to be worked out beforehand rather than read back
afterwards.

Together with rc23's move, the Company Tree can now be built, staffed,
rearranged and taken apart without opening the screen.

One thing worth stating plainly, because it is easy to assume otherwise: **there
is no undo.** Cancel discards changes you have not saved yet; nothing reverses a
change already saved. A reorder is undone by reordering back, and a deletion is
not undone at all.

### Both Acumatica plugins at 0.81.0-rc23 · 8 Sep 2026

**Workgroups on the Company Tree can be moved.**

Creating a workgroup and deleting one already worked. Moving an existing one did
not — the Move button opens a picker dialog rather than acting on its own, so
nothing happened. You can now move a workgroup under a different parent, or
promote it back up to the top level.

It refuses the moves that would leave you without a tree: a workgroup under
itself, or under one of its own children. Moving one to where it already is does
nothing rather than reporting a change. Either way the result is checked against
the database afterwards, not taken from the screen.

### Both Acumatica plugins at 0.81.0-rc22 · 8 Sep 2026

**Four tools that did nothing on Acumatica 2026 R1 work again.**

Building a workgroup on the Company Tree, adding a member to one, building an
approval map, and editing a step of an existing one all failed immediately on
2026 R1. Each of them drove a page style that version removed — the screens are
still there, but the older page behind them is not, so the tools could not even
open them. Earlier Acumatica versions were never affected.

They now choose the route per call: the current interface where that page is
gone, the original route where it still exists. If you are on an earlier version
nothing changes for you.

Two things previously written down as limitations turn out not to be:

- **Approval-map amount conditions work.** "This approver above RM10,000" can be
  built again — the condition had been reported as added while landing nowhere.
- **A multi-step approval map gets one approver per step.** The second step could
  come out with no approver at all and its workgroup written onto the first step,
  producing a map that looked complete and would not have routed correctly.

Checked against a live 2026 R1 instance rather than assumed: a three-level
workgroup tree with every parent correct, a member read back off the screen, a
two-step approval map with an amount condition on each step, and an in-place step
edit confirmed against the database.

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
