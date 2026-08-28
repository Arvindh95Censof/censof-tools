---
name: rfs-analyze
description: >-
  Diagnose one RFS support ticket end to end: read the ticket and its attachments, find duplicate
  and precedent tickets in the closed-ticket history, cross-check the GRP/Acumatica documentation,
  then give the likely cause and a step-by-step fix, labelled proven, proposed, or a proven
  workaround over a root cause that was never fixed. Answers in plain
  language first, technical detail second. Use whenever an RFS ticket number appears in any of its
  forms -- RFS-2026-353578155, a bare 9-digit live id like 260853801, or a legacy id like
  26080381P -- or when asked to triage, diagnose, find precedent for, or check whether something
  is a duplicate of an existing GRP or Acumatica support issue.
trigger: /rfs-analyze
---

# /rfs-analyze

**Version 2.7 — 2026-08-27.** Check this line before reporting a problem: if it is older
than the one the OPEX team is shipping, you are on a stale copy. Ask for
`rfs-analyze-skill.zip` again, remove the old skill first, then add the new one.

> **State the version out loud, every time, at the top of every answer.** Not because the
> reader asked — because a silent version number is a version number nobody checks. Open
> with one line: *"Running rfs-analyze v2.7."* A stale copy is only caught if it is said,
> not left to be noticed.

*2.7 — six additions, all found by running v2.6 against real tickets, not by
inspection: (1) a mandatory reverification pass (step 6) — v2.6 forces good EVIDENCE
gathering but nothing forces the final write-up to actually match that evidence; two
claims in one session looked fabricated on review and were not, but only a re-check proved
it. (2) clustering guidance for 3+ near-identical precedents, so "read every hit" doesn't
mean re-deriving the same finding N times. (3) a third fix label,
`PROVEN WORKAROUND / ROOT CAUSE NOT FIXED`, for the extremely common shape where the
per-instance data patch is proven but the underlying code defect has never actually been
fixed — the old binary had no way to say both things at once. (4) explicit handling for a
ticket number that appears only inside another ticket's attachment and resolves in neither
system — hit 3 times in one session, improvised differently each time. (5) explicit handling
for an attachment that reveals a second, unrelated issue outside the ticket's own described
scope — found live in 23120195P's own verification PDF, and the original ticket was closed
without it ever being raised separately. (6) the version-announcement line above, since a
passive "check this line" produced zero actual staleness detection until someone manually
handed over a newer copy.
2.6 — the attachment reader now opens doc/xls/pptx/zip/rar and returns images alongside
text; an image-only document is content, not a failure.
2.5 — leakage figure corrected to the current gate baseline (21.1%, not 22.9%).
2.4 — corpus counts and product names removed from the description.
2.3 — richer skill description so it triggers on a bare ticket number.
2.2 — every answer written twice: a plain-language section for anyone, then the technical
detail for whoever applies the fix.
2.1 — omit `exclude_referno` on live tickets (a bare numeric id is coerced to int and
rejected); survey-docx mismatch confirmed on a third ticket.
2.0 — five-step flow; cross-analysis table comparing precedent against docs; cause and fix
split into separate steps; every fix labelled PROVEN or PROPOSED.
1.2 — attachments mandatory on the ticket and on every precedent presented; bare numeric live
ticket IDs; per-file relevance verdict; pre-answer checklist.*

Take one RFS ticket through six steps, in order:

| | Step | Produces |
| --- | --- | --- |
| 1 | Read the ticket **and its attachments** | what was actually reported |
| 2 | Find precedent | duplicate verdict + what happened last time |
| 3 | Read the docs, then **cross-analyse** against precedent | candidate causes, side by side |
| 4 | Likely cause | what to check, and where |
| 5 | The fix | step by step, labelled proven or proposed |
| 6 | **Reverify** the finished answer against what the tools actually returned | a checked answer, not a remembered one |

Both corpora are mandatory. Precedent tells you the OUTCOME; documentation tells you the
MECHANISM. Neither alone is a root cause — step 3 is where they meet, and that comparison is
the point of the whole skill.

**Work in tables.** Prose hides gaps; a table with an empty cell shows them.

## Write it twice: plain first, technical second

Two different people read this. A coordinator needs to know what went wrong and what happens
next. An engineer needs the table names and the script. Writing for only one of them fails
the other.

So steps 4 and 5 each have **two parts, in this order**:

| | Section | Who it is for | Rule |
| --- | --- | --- | --- |
| a | **In plain terms** | anyone — coordinator, manager, the client | No codes, no table names, no jargon. Short. |
| b | **Technical detail** | whoever applies the fix | Everything: screens, tables, fields, scripts |

**The plain section is not a summary of the technical one — it is written first and stands
alone.** Someone who reads only part (a) should understand what broke and what happens next.

Rules for part (a):

* **No screen codes, table names, extension names, or SQL.** Not `LMLoanMaster` — say
  *"the loan record"*. Not `AP.50.52.00` — say *"the payment release step"*.
* **Say what the USER sees**, not what the system does internally: *"the loan still shows
  Ready even though the money went out"*.
* **Three to five sentences.** If it runs longer, it has turned into part (b).
* **Plain words for how sure we are**: *"this has happened before and we know the fix"* /
  *"we have not seen this exact problem before"*.
* **No hedging a non-technical reader cannot act on.** "Likely a write-back failure in the
  extension" means nothing to them. *"The payment went out but the loan was never updated to
  match"* does.

In part (b), spell out a code the FIRST time it appears — `AP.50.52.00` (the screen that
releases payments) — then use it freely.

## Usage

```
/rfs-analyze RFS-2026-353578155     # live ticket, prefixed form
/rfs-analyze 260853801              # live ticket, BARE numeric form -- equally valid
/rfs-analyze 18010041P              # historical ticket, already closed
/rfs-analyze <referno> --docs-only  # skip precedent; docs are NEVER skippable
```

**Ticket number tells you which system it is.**

| Shape | System | Tool |
| --- | --- | --- |
| `RFS-YYYY-NNNNNNNNN` | NEW, live/open | `fetch_live_ticket` |
| **all digits, no trailing letter** (`260853801`) | NEW, live/open | `fetch_live_ticket` |
| `YYMMNNNNP` — digits ending in **`P`** (`24071041P` = 2024-07) | LEGACY, closed | `fetch_ticket` |

**Bare numeric IDs are normal, not malformed — pass them through UNCHANGED.** Verified
2026-08-26 against the live API: `260853801` and `260837899` both resolve. The server does no
normalisation at all; whatever string you pass goes to the RFS API verbatim as
`ticketNumber`. So never "helpfully" add an `RFS-2026-` prefix, strip digits, or reformat —
you will turn a findable ticket into `found: false`.

The trailing **`P`** is the only reliable legacy tell. A 9-digit number with no `P` is live.
If a live lookup returns `found: false`, try `fetch_ticket` before concluding the ticket does
not exist, and vice versa.

**A ticket number found only inside another ticket's attachment (filename or body text) may
resolve in NEITHER system.** Observed 3 times in one session — an attachment named
`26060854P` or a docx referencing `RFS25051238P` that neither `fetch_ticket` nor
`fetch_live_ticket` could find. This is not a dead end and not a reason to drop the lead:

* Try both tools regardless of which shape it looks like — the source ticket's own author
  may have gotten the shape wrong, or it may be a different system's ID entirely (an internal
  issue-tracker number, not an RFS number).
* If both return `found: false`, say so explicitly and name what you tried:
  *"`26060854P` (referenced in this ticket's attachment filename) was not found via
  `fetch_ticket` or `fetch_live_ticket` — treating as an unconfirmed cross-reference, not
  precedent."*
* Never silently drop it and never silently treat it as confirmed precedent either — an
  unconfirmed reference is a real, nameable state, not an error to hide.

## Requires

`censof-mcp` connected (https://cen-kb.my/mcp). If it is not, say so and stop — there is no
HTTP fallback. **Exact signatures — a wrong parameter name is a hard validation error:**

```
fetch_live_ticket(ticket_number="RFS-2026-353578155")   # NOT ticket_no
fetch_ticket(referno="26080381P")
search_similar_tickets(query=..., exclude_referno=..., k=5, product_family="GRP")
search_docs(query=..., k=10)
list_ticket_attachments(referno=...)
read_ticket_attachment(referno=..., filename=..., page=N)   # page = which image / archive member / PDF page
fetch_topic(topic_id=..., max_chunks=20)
```

## What your token is allowed to see

Access is per person, in **three separate grants**. Not every caller has all three:

```
documentation   search_docs, fetch_topic
rfs-tickets     search_similar_tickets, fetch_ticket, attachments on CLOSED tickets
                -- CUSTOMER DATA, granted deliberately
rfs-live        fetch_live_ticket, and attachments on a ticket still OPEN
                -- reaches the RUNNING production RFS system. Opt-in, and NOT implied
                   by full index access
```

**A refusal is explicit and is never disguised as an empty result:**

```
"not permitted to read support tickets"
"not permitted to use the live RFS API. This is a SEPARATE grant..."
```

**If you get one, say so plainly and name the missing grant — NEVER report it as "no
precedent found".** *"You are not allowed to look at this"* and *"the corpus has nothing
on this"* are completely different statements, and conflating them sends someone hunting a
problem that does not exist. Tell them to ask the OPEX team for that grant by name.

Degrade usefully rather than stopping: if `fetch_live_ticket` is refused, try
`fetch_ticket` — a closed ticket needs only `rfs-tickets`. If precedent search is refused,
run step 3 anyway and answer from documentation alone, saying that is what you did.

## What the corpus actually contains

Verified 2026-08-26 — every index 100% embedded, bge-m3 1024-dim, zero gaps:

```
rfs-tickets         101,530   closed legacy tickets, 2018-01-01+, 'Client Close' only
                              GRP 33,151 | CF 40,619 | other 27,747
acumatica-knowledge  34,958   acumatica-learning 8,334   grp-sharepoint 8,237
grp-manuals             415   grp-resource-centre  364   grp-configuration  113
```

NOT included: 43,166 closed tickets before 2018, 5,199 status-11 closures, open tickets.
Attachments are NOT in Elasticsearch — 117,046 files on disk, reached only through the
attachment tools. Every ticket carries attachment metadata regardless.

## Steps

### 1 — Pull the ticket, and READ ITS ATTACHMENTS

Read the description, and for a legacy ticket the `thread` too. Note module/screen codes and
any error text — those are the strongest query material. If found in neither system, stop.

### Attachments are MANDATORY, not a judgement call

**Every ticket, every time. `list_ticket_attachments` is not optional and never has been
optional — it transfers no file content, so there is no cost argument for skipping it.**

```
list_ticket_attachments(referno=<this ticket>)     # ALWAYS. free.
read_ticket_attachment(referno=..., filename=...)  # then read -- see below
```

**You may not report an analysis of a ticket whose attachment list you have not pulled.**
If you did not list, you do not know what evidence exists, and any confidence level you state
is unearned. A screenshot routinely carries what the prose leaves out: the exact error
dialog, the field values, the screen state.

**Then READ them — the default is read, and a skip must be justified out loud.** The only
acceptable reasons to skip a file are:

* it is one of many near-identical files and you have read a representative (say so)
* the file is enormous and the sample already answered the question (say so)
* the fetch itself failed (report the failure — never silently omit it)

"Looked unrelated from the filename" is **not** an acceptable reason. See below for why.

**State a relevance verdict for every file you read.** One line each is enough:
*"screenshot — shows the L26000144 status field reading Ready; this is the evidence"* or
*"survey docx — unrelated to this ticket, disregarded"*.

> ### The attachment may belong to a DIFFERENT ticket. Check before you believe it.
>
> Verified 2026-08-26 on the live system. `Customer_Satisfaction_Survey_v3.docx` — identical
> filename, identical **26,997 bytes** — is attached to **three unrelated tickets**:
> **260853801** (loan status stuck at Ready), **260837899** (bank reconciliation), and
> earlier **ticket 18**. It was read in full: a **blank feedback survey template**, Sections
> A/B/C with empty rating boxes. It is boilerplate stapled to tickets indiscriminately, and
> it is evidence of nothing.
>
> Three occurrences makes this **systemic, not a one-off**. Treat any attachment as
> guilty until it matches the description — especially a generic-sounding filename that
> could belong to any ticket.
>
> **So reading the attachment is mandatory, but BELIEVING it is not.** Judge the content
> against the ticket's own description. If they do not match, say so explicitly — *"the
> attached file appears to belong to a different ticket"* — and carry on from the description.
> Silently reasoning from an unrelated document is far worse than having no attachment at all.

### An attachment can hand you a SECOND, unrelated issue. Do not fold it in, and do not drop it.

Verified on `23120195P`: the ticket's own closure-verification PDF, meant only to prove the
reported fix worked, also showed a completely different error — *"User must be an Employee
to use current screen."* — for a case the ticket was never actually about. The ticket was
closed anyway, and that second problem was never raised again anywhere.

An attachment answering the reported symptom can still contain evidence of something else
entirely. When that happens:

* **Do not merge it into the main cause** — it is a different defect with a different cause,
  even if it was found in the same file.
* **Do not drop it because it is out of scope** — you now know something true that nobody
  has acted on, and it appeared during your read of a ticket you are handing back to a human.
* **Give it its own row in the cross-analysis table (3b) and its own line in the decision
  (step 5)** — typically *"raise as a separate product bug: found during verification of
  `<this ticket>`, never independently tracked."*

### What the reader can actually open (rebuilt 2026-08-27)

Almost everything. Do not decide from the extension that a file is unreadable — try it.

| Format | What comes back |
| --- | --- |
| `png jpg jpeg jfif gif bmp webp` | the image |
| `pdf` | text **and** any embedded images. No text layer → the page is **rendered** |
| `docx` | text, tables **and every embedded image** |
| `xlsx` | sheet shape + sample rows **and every embedded image** |
| `doc` | text (Word 97-2003) **and images carved out of it** |
| `xls` | the workbook — or text, when the file is HTML wearing an `.xls` name |
| `pptx` | slide text, **speaker notes**, and slide images |
| `zip` `rar` | the **listing**; then any member with `page=N`, read as its own format |
| text | `txt log csv sql out json xml html rpx md ini conf yaml yml`, plus files with **no extension** that sniff as text |

**`page=N` means "which one".** Which image in a document, which member in an archive, which
page of a scanned PDF. Images are ordered largest first, and a pasted screenshot is always
larger than a logo, so `page=1` is the one that matters.

**A document with no text is NOT empty — it is a picture.** A .docx or .doc whose whole
content is a pasted screenshot returns `text: null` and the image beside it. That is the
content. Never report such a file as unreadable or empty; the reader says so itself with
`IMAGE-ONLY DOCX` / `IMAGE-ONLY DOC`, and a PDF with no text layer says `SCANNED PDF`.

**Text and images arrive together.** A file with a line of context and a screenshot of the
error gives you both. In that shape the screenshot is the evidence and the text is its
caption — read the picture.

**Archives are worth opening.** `zip` and `rar` list their contents for free, and the listing
usually settles what to ask for. An archive holding exactly one readable file is opened
automatically. A `.42m`, `.mp4` or `.gpg` inside one is reported by name as unreadable — that
is the MEMBER failing, not the archive.

**A long text file is clipped from the MIDDLE, not the end.** `chars_total` tells you the real
size. For a log the tail is the important half and it is always included — a 706 KB 4GL dump
returns both ends with the elided middle marked.

**A refusal names its reason.** Video, `.gpg` (encrypted) and `.42m` (proprietary) genuinely
cannot be read, and say so. That is different from an empty result — report it as "this file
type cannot be opened", never as "the attachment had nothing in it".

### 2 — Find precedent, and decide whether this is a DUPLICATE

```
search_similar_tickets(query=<problem in the reporter's own words>, k=5,
                       exclude_referno="<this ticket>",           # LEGACY tickets only -- see below
                       product_family=<"GRP" | "CF" | "other">)   # pass it when you know it
```

> **OMIT `exclude_referno` entirely for a LIVE ticket.** The corpus holds closed legacy
> tickets only, so a live ticket cannot appear in the results and excluding it does nothing.
>
> Passing it also *fails*: a bare numeric id like `260853801` gets coerced to an integer by
> the client and the server rejects it outright —
> `exclude_referno Input should be a valid string [type=string_type, input_type=int]`.
> Observed twice on 2026-08-26 before the parameter was dropped. On a legacy referno
> (`26080381P`) the trailing letter keeps it a string, so it is safe there.

Build the query from the PROBLEM — symptom, module, error text. Do not paste the whole
ticket; do not include the ticket number (an ID carries no semantic meaning).

**Pass `product_family` — this is measured, not a style preference.**

| Path | Wrong-product hits in the top 5 |
| --- | --- |
| **without** `product_family` (the default) | **21.1%** |
| **with** `product_family` | **~0%** |

The filter is **opt-in**, so the default path still leaks — that is the whole reason this is a
rule and not a suggestion. Setting it constrains both retrieval legs so wrong-product hits
never arrive, at **zero cost to ranking**: recall@1, recall@5 and MRR were all unchanged when
it shipped, and clearing the noise promoted real GRP precedent that had been crowded out.

*Figures from the regression gate, rebased 2026-08-26 after `w_lexical` 0.6 -> 1.0 for ticket
search. An earlier revision of this file quoted 22.9%, which was the pre-rebase number.*

Derive it from the ticket: a live ticket's client/project, or a legacy ticket's own
`product_family`. When you genuinely do not know, leave it off and enforce the product rule
by reading instead.

**Then run ONE unfiltered pass** when the mechanism might be shared across products — that
is the only way a cross-product hit can appear at all. Label anything it returns as a
different product. Filtered is your precedent; unfiltered is a lead, never a fix.

### SEARCH IN BOTH LANGUAGES — the corpus is Malay AND English

**Measured 2026-08-26: the same question asked in Malay and in English returns ~80%
DIFFERENT tickets** (mean overlap 1.33 of 5, Jaccard 0.198). This is not a bug you can wait
out — it decides what you see.

It is NOT a broken retrieval leg. Both legs fire in both languages (lexical 36/60 vs 38/60,
semantic 60/60 both). The corpus is simply **partitioned by language**, and your query
language silently selects which half you search.

```
run 1: the problem in ENGLISH   (or the reporter's own words)
run 2: the SAME problem in MALAY
       then merge and dedupe by referno
```

**This is not optional on a Malaysian government client.** USM, and most GRP clients, log
tickets in Malay. Searching the loan-disbursement defect in English returned 6 tickets; the
Malay phrasing returned 12 — the same defect, twice the evidence.

Queries carrying English technical terms embedded in Malay ("Make Disbursement", "EFT",
"General Ledger", screen codes) bridge well on their own. **Pure-Malay business vocabulary
shares nothing** — those are the ones that come back completely disjoint. Useful pairs:

```
status/berstatus   receipt/resit      balance/baki        difference/perbezaan, beza
approval/kelulusan loan/pinjaman      payment/bayaran     salary/gaji
deduction/potongan invoice/invois     vendor/pembekal     report/laporan
print/cetak        posted/diposting   asset/aset          still/masih
cannot/tidak boleh should/sepatutnya  already/telah       not/tiada, tidak
```

If the ticket is already written in Malay, run the English version too — the asymmetry
works in both directions.

**Read the metadata on every hit before using it:**

* **`product_family` — the one hard rule.** A GRP problem answered from a CF ticket is a
  different product with a different fix. Label a cross-product hit; never present it as
  precedent unmarked.
* **`has_thread_detail: true` -> `fetch_ticket(referno)` and read the thread.** The fix is
  frequently in the conversation, not the resolution field: 49% of thin/empty resolutions
  still carry real diagnostic detail. Never judge a ticket from `resolution_quality` alone.
* **`fix_documented: false` is NOT a reason to skip a ticket.** The outcome is often the
  answer, and `fix_type` says which — `U01`/`U02` "Advised User" = USER ERROR not a bug,
  `N` = no fault found, `P01` = a known gap deferred to an enhancement request.
* **Recurrence is evidence.** The same symptom across several tickets is a finding in itself
  — including "this keeps happening and was never properly fixed".
* **A precedent's attachments are part of the precedent** — see 2b. Do not judge a past
  ticket from its text alone any more than you would the current one.

**State a duplicate verdict explicitly.** If a past ticket is the same defect, say
*"this is a duplicate of <referno>"* and carry its fix forward. That verdict is usually the
single most actionable thing this skill produces — do not leave it implied.

### 2b — Read the attachments on every precedent you PRESENT

Same rule as step 1, applied to history: **a ticket you lean on must be a ticket whose
evidence you have looked at.** A past screenshot is routinely where the real error dialog,
field values and screen state live — the resolution field says "issue resolved", the
screenshot says what the issue WAS.

**Listing is free. Do it on EVERY hit, without exception:**

```
list_ticket_attachments(referno=<every precedent returned>)   # free, mandatory, all of them
read_ticket_attachment(referno=..., filename=...)             # costs context -- see rule
```

**The rule, in one line: if a precedent appears in your synthesis, its attachments have been
read.** Not "the strongest one". Not "the one you carry the fix from". Every precedent you
put in front of the reader.

| Precedent | List | Read |
| --- | --- | --- |
| Any hit returned at all | **always** | — |
| Any hit you **mention in the synthesis** | always | **always** |
| Duplicate verdict, or fix carried forward | always | **always — both sides compared** |
| Hit you **discard** (wrong product, different symptom) | always | not required — **name it and say why** |

Discarding is the only exemption, and it costs you a sentence: *"26050912P — CF, different
product, not used."* A reader can then tell a deliberate skip from an oversight. What you may
NOT do is mention a ticket as supporting evidence while having looked only at its text.

**When 3 or more hits are visibly the same finding, cluster them — do not fully re-derive
each one.** "Fully read every hit" is right when each hit might say something different; it
becomes waste when they don't. If several hits share the same subject line pattern, the same
`fix_type`, and the same one-line resolution shape, they are one finding wearing several
referno's, not several findings:

* `list_ticket_attachments` on all of them — still free, still mandatory, no exception.
* Fully read **one representative** in depth (thread + attachments) — pick the one with the
  richest `resolution_quality`/`has_thread_detail`.
* For the rest, confirm from the metadata alone that they match the same shape, and say so as
  a **cluster**: *"24061779P, 24061777P, 24061770P, 24061799P, 24061773P — same subject, same
  fix_type (S03), same templated resolution text, closed the same week. Read 24061779P in
  full as the representative; the other four confirmed matching from metadata, not
  individually re-read."*
* **This is a disclosure, not a shortcut you take silently.** The reader needs to know a
  cluster was compressed, and needs the referno list to go verify any one of them themselves.
* If even one member of the apparent cluster turns out to differ on inspection, stop
  clustering — read the rest individually. A cluster is a finding about the data, not an
  assumption you get to keep once it stops being true.

**Apply the same relevance test as step 1.** Precedent attachments carry the same mismatch
risk — read the file, then judge whether it actually belongs to that ticket. An unrelated
document on a past ticket is evidence of nothing, and treating it as confirmation is how two
merely-similar tickets get called duplicates.

**Comparing the past screenshot against the current one is the actual test** for whether two
tickets are the SAME defect or merely similar wording. Matching figures, identical field
states or the same error dialog turn a plausible match into a confirmed one — that comparison
is what upgrades confidence from medium to high, and it is worth the context it costs.

~968 legacy files (mostly pre-2019) were deleted server-side, so an empty listing on an old
ticket is expected, not a bug — report it as "files no longer on disk", not "no evidence".
Legacy attachments live on the KB server under
`C:\GRPKB\kb-media\rfs-attachments\<YYMM>\<referno>\`; both tools accept a legacy referno and
a live `RFS-...` number alike.

### 3 — Documentation, then CROSS-ANALYSE it against the precedent

Two halves. Do not merge them: gather first, compare second.

#### 3a — Find the MECHANISM in the docs (MANDATORY, never skipped)

Precedent says what was *done* last time. Docs say how the feature is *built* — which is what
turns "apply the same data fix again" into "here is the component that fails".

**Docs describe intended behaviour, not failures, so a symptom query mostly misses.** Run
BOTH, and treat the second as the one that pays:

```
search_docs(query=<the symptom, in product terms>, k=10)                   # often thin
search_docs(query=<the MODULE and its architecture/customization>, k=10)   # the one that works
```

The second surfaces module-architecture documents listing the DACs, tables and customization
extensions behind a screen — the actual code that runs. Ask for the module's design, its
extensions, or how its posting/integration works, not for the error.

Keep `k` at 10+. `acumatica-knowledge` is ~35k chunks against GRP's few hundred, so
GRP-specific answers sit mid-list and a lower `k` drops them entirely. Prefer `grp-*` indices
for a GRP ticket, and check the citation path — `grp-sharepoint` also holds **CF Implementors
Guides**. Follow a `related` topic_id with `fetch_topic` when a hit is on-point but truncated.

**Never skip this because precedent already looked conclusive.** That is the failure mode this
skill exists to prevent: precedent produces a plausible answer, which *feels* like done. On
the loan-disbursement case it was the docs — not the five precedent tickets — that named the
failing extension.

#### 3b — The cross-analysis table (always produce this)

Now put the two sources side by side. **One row per candidate cause.** This is the core of the
analysis and it is not optional.

| # | Candidate cause | Precedent says | Docs say | Agree? | Confidence |
|---|---|---|---|---|---|
| 1 | Disbursement write-back skipped | `26050912P`, `25110387P` — 4 status fields patched by hand | `AP.50.52.00` extension owns that write-back | **yes** | high |
| 2 | Approval step not released | not seen in any precedent | screen requires release before status advances | **untested** | low |
| 3 | User read the wrong screen | `24071041P` — `U01 Advised User` | n/a | **conflict** | medium |

Rules for filling it:

* **Every cause gets a row**, including ones you end up rejecting. Rejecting a cause in a
  visible row is information; dropping it silently is not.
* **"not seen" and "n/a" are real answers.** An empty cell is not — it reads as "not checked".
* **`Agree?` is the whole point.** Mark **conflict** when precedent and docs point different
  ways, and say which you believe and why. Precedent saying "just patch the data" while docs
  name a component that *should* have written it is the classic recurring-defect signal, and
  in prose it gets smoothed over. In this table it cannot be.
* **Confidence is PER ROW, not one label for the answer.** You can be certain of the cause and
  unsure of the fix; a single confidence line hides that.

---

### 4 — Likely cause, and what to check in the system

#### 4a — In plain terms

Three to five sentences, no codes, no table names. Cover:

1. **What the user is seeing** — in their words, not the system's
2. **What went wrong** — the everyday version of it
3. **Whether we have seen it before** — and if so, roughly how often

> *Example.* "The loan was approved and the money was paid out, but the loan record was never
> updated to match — so it still shows as waiting to start, and its balances are all zero.
> The payment itself is fine; only the loan's own record is out of step. We have seen this
> same problem several times before, including on this client six days ago."

#### 4b — Technical detail

State the cause you land on, referencing the row number from 3b.

Then a concrete check list. Not "verify the configuration" — say **where to look and what a
wrong value looks like**:

| # | Check | Where | Expected | Wrong looks like |
|---|---|---|---|---|
| 1 | Loan status field | `LM.50.10.00`, loan `L26000144` | `In Progress` | `Ready` after a posted disbursement |
| 2 | AP release ran | `AP.50.52.00` batch for that loan | released, with a batch nbr | no batch, or batch unreleased |
| 3 | GL transaction posted | `CA` transaction on the disbursement | `Posted` | `Unposted` |

The reader of this is a support engineer with the system open. Every row must be something
they can go and look at within a minute.

#### Showing the break point

When the failure is about *where* in a sequence things stop, one line of plain text beats a
paragraph:

```
Make Disbursement -> AP.50.52.00 release -> GL posted -> [X] status write-back never runs
```

Optional, and only when the docs actually named the components. Skip it when the outcome is
user error, or when you would be inventing the steps — a tidy-looking flow makes a guess read
like a fact.

---

### 5 — The fix, step by step

#### 5a — In plain terms

Two or three sentences: **what will be done, and whether it is a known fix or a best effort.**
No SQL, no table names.

> *Example, known fix.* "We can correct this directly: the loan record needs to be brought
> back in line with the payment that already went out. The same correction was applied to
> another loan for this client last week and it worked. It has to be done by someone with
> database access, and it changes live data, so it needs sign-off first."

> *Example, best effort.* "We have not found a recorded fix for this exact problem. Based on
> what the past tickets and the manuals show, the most likely correction is X — but it has
> not been done before, so it should be tried on a test system first."

#### 5b — The technical steps

**Always give one.** But say plainly which kind it is — this is the difference between a fix
someone can apply and a guess someone will trust by mistake.

Open the section with exactly one of these three labels:

> **PROVEN FIX** — recorded in `<referno>` / documented at `<citation>`.

> **PROPOSED FIX — not recorded anywhere.** Worked out from the evidence gathered above: the
> ticket, `<referno(s)>`, and `<citation(s)>`. Verify on a test company before applying to
> production.

> **PROVEN WORKAROUND / ROOT CAUSE NOT FIXED** — the per-instance data patch is proven
> (recorded in `<referno(s)>`), but no code-level fix to the underlying component has ever
> been recorded, in any of the occurrences checked.

**The third label exists because the first two cannot both be true at once, and on a
recurring defect they usually are.** Confirmed live on the loan-disbursement defect: the same
3-table SQL patch is proven across 4 occurrences, 2 clients, 2021–2026 — genuinely a proven
fix for the loan in front of you. But `APReleaseChecks_ExtensionLM`, the documented component
responsible, has never been patched at the code level in any of those 4 tickets. Calling this
**PROVEN FIX** overstates it (the defect will recur); calling it **PROPOSED FIX** understates
it (the immediate correction is not a guess). Use the third label whenever the precedent shows
the SAME data patch applied more than once with no code fix on record — and pair it with a
"raise a product bug" decision, never with "verify and close" alone.

**Roughly a third of tickets have no recorded fix** — 37.6% carry one in the resolution field,
64.2% once thread content counts. So the second and third labels are not the rare case, and
neither must ever be quietly dropped to make the answer sound stronger.

Then the steps. Numbered, one action each, in the order they must happen:

```
1. Open LM.50.10.00, find loan L26000144.
2. Confirm the disbursement batch in AP.50.52.00 shows Released.
3. If released but status is still Ready -> the write-back was skipped.
4. Patch the 4 status fields (see 26050912P for the exact set).
5. Re-open the loan and confirm status now reads In Progress.
```

Say what to do if a step fails, where that is known — a step-by-step that only covers the
happy path strands the reader at exactly the point they needed help.

#### Close with the decision

The last line names what the human should DO — not what you found:

* **verify and close** — the fix is proven and low risk
* **close as duplicate of `<referno>`** — the strongest, most actionable verdict this skill
  produces; never leave it implied
* **escalate** — recurring defect, or the fix touches production data
* **raise a product bug** — recurrence with no root cause on record, OR a
  **PROVEN WORKAROUND / ROOT CAUSE NOT FIXED** situation. Say how many times and over what
  period; that count is the argument. This decision and "verify and close" are not
  exclusive — apply the workaround to close THIS ticket, and separately raise the bug so the
  next occurrence isn't a surprise.

---

### 6 — REVERIFY the finished answer against what the tools actually returned (MANDATORY, never skipped)

Steps 1–5 make sure you gathered the right evidence. This step makes sure the answer you are
about to hand over actually says what the evidence says — a different failure mode, and the
one the earlier five steps do nothing to catch.

**Confirmed necessary, not theoretical: in one session, two claims in a draft answer looked
fabricated on review** — a specific code name and CP number in one case, three named
documentation mechanisms in another. Both turned out to be **accurate** once re-checked
against the actual tool calls. The claims were fine. What was not fine is that this was only
established by going back and checking — nothing in the drafting process itself had done
that. A reader cannot tell "verified and true" from "unverified and happens to be true" by
reading the sentence. Only re-checking tells them apart, and only step 6 does that checking.

**Go through the finished draft claim by claim and ask one question of each: which tool call
in this exchange actually produced this?**

* **Every quoted thread excerpt, code/component name, SQL script, screen ID, exact figure, or
  "the docs say" sentence must trace to a specific tool result you can point to.** If you
  cannot name the call, you have not verified it — re-run it now, or remove the claim. "I
  recall this from the product" is not a source.
* **A precedent cited from its search-result summary alone, never fully fetched, is
  under-verified if it is load-bearing** — a duplicate verdict, a carried-forward fix, or the
  strongest evidence in the synthesis. Fetch it in full before the answer goes out. A summary
  can hide the actual mechanism: one summary read as "pay run completed after removing a
  settled loan" — the full thread showed the real fix was a temporary SQL status flip,
  applied and then reverted. Not wrong, just not the whole answer, and the missing part was
  the useful one.
* **A documentation claim is only as good as the excerpt actually in front of you.** If the
  specific text is not sitting in the `search_docs` results you received, do not present it
  as found — run a sharper query first. Plausible product knowledge that did not come from an
  actual hit is a fabrication wearing a citation, whether or not it happens to be true.
* **This is a separate pass, done after the draft exists — not a mental note kept while
  writing it.** The moment of drafting is exactly when filling a gap plausibly feels cheapest;
  reading the finished thing back against the raw tool output is what catches it.
* **Fix what reverification finds before releasing, not after** — verify it for real, rewrite
  the sentence to say only what is supported, or mark it explicitly as inference under step
  4's confidence language. A finding from this step never ships as a footnote for later.

## Before you answer — check every line

Not style. Each of these has produced a wrong answer in practice.

**Step 1 — the ticket**
- [ ] Ticket number passed **verbatim** — no prefix added, nothing reformatted
- [ ] `list_ticket_attachments` called on this ticket
- [ ] Every attachment **read**, or the skip justified out loud
- [ ] A **relevance verdict** per file — including "belongs to a different ticket"

**Step 2 — precedent**
- [ ] Searched in **both languages**, results merged and deduped
- [ ] `list_ticket_attachments` called on **every precedent returned**
- [ ] Attachments **read for every precedent that appears in the answer**
- [ ] Discarded precedents **named**, with the reason
- [ ] Duplicate verdict stated explicitly, or explicitly ruled out

**Step 3 — docs and cross-analysis**
- [ ] `search_docs` run — **never skipped**, even when precedent looked conclusive
- [ ] Both doc queries run: the symptom AND the module's architecture
- [ ] **Cross-analysis table produced**, one row per candidate cause
- [ ] No empty cells — "not seen" and "n/a" written in full
- [ ] Any **conflict** between precedent and docs called out, not smoothed over
- [ ] Confidence given **per row**

**Step 4 — cause**
- [ ] **4a written FIRST** — plain terms, no codes, no table names, 3–5 sentences
- [ ] 4a says what the USER sees, not what the system does internally
- [ ] Cause stated in 4b, referencing its row number
- [ ] Checks are concrete — screen, field, expected value, what wrong looks like
- [ ] Every code spelled out on first use in 4b

**Step 5 — fix**
- [ ] **5a written FIRST** — plain terms, no SQL, says known fix or best effort
- [ ] Labelled **PROVEN FIX**, **PROPOSED FIX — not recorded anywhere**, or
      **PROVEN WORKAROUND / ROOT CAUSE NOT FIXED**
- [ ] A PROPOSED fix names the evidence it was worked out from
- [ ] A PROVEN WORKAROUND is paired with "raise a product bug", not left as "verify and close"
      alone
- [ ] Steps numbered, one action each, in the order they must happen
- [ ] Closes with the decision: verify / close as duplicate / escalate / raise a product bug

**Step 6 — reverify**
- [ ] Every quoted excerpt, code name, SQL script, screen ID, and figure traced to a specific
      tool call — not to memory or general product familiarity
- [ ] Every precedent that is load-bearing (duplicate verdict, carried-forward fix, strongest
      evidence) was fully fetched, not cited from its search-result summary alone
- [ ] Every "the docs say" claim checked against the actual `search_docs` excerpts received
- [ ] Any claim that failed this check has been fixed, re-verified, or explicitly marked as
      inference — before this answer was sent, not after
- [ ] The version line was stated at the top of the answer

If a box cannot be ticked because a tool refused, say which tool and why — a permission
boundary is not the same as an absence of evidence, and the reader cannot tell them apart
unless you say so.

## Pitfalls

* **`confidence` from the tools measures RETRIEVAL, not answerability.** A question about a
  different product, or a feature that does not exist, can score `high` on genuinely
  irrelevant content. Judge from the excerpts, never the level alone.
* **`rare_terms` in the confidence block is worth reading.** It lists query terms that
  barely appear in the corpus, with their document counts, and downgrades `level` when a
  term looks like an entity the corpus has never heard of. A hit there usually means the
  question names a product or feature we do not cover. It is EVIDENCE, not a verdict — a
  legitimate Malay term or a niche screen name can appear too, so read what it flagged
  before acting on it.
* **Stopping after step 2 is the failure mode this skill exists to prevent.** Ticket
  precedent produces a plausible answer, which feels like done. Run step 3 anyway — on the
  loan-disbursement case it was the docs, not the 5 precedent tickets, that named the
  failing extension.
* **An empty `search_similar_tickets` is not a final answer** — the corpora are independent.
* **A thin resolution is not a dead end** — read the thread.
* **Do not claim to have read an attachment you have not opened.** Metadata is not content.
* **Pre-2018 tickets are not in the corpus.** For a long-standing issue, absent early
  precedent means the window starts in 2018 — not that it never happened before.
* **A confident, specific-sounding claim is not evidence that it was verified.** This is the
  exact failure mode step 6 exists to catch: a detail that reads as sourced because it is
  precise — an exact SQL script, a named component, a specific figure — when it was actually
  reconstructed from general familiarity rather than checked against a real tool result.
  Precision and verification are different properties of a sentence; only step 6 confirms the
  second one. Do not let how right a claim sounds substitute for checking it.
