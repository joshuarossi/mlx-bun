---
name: memory
description: >-
  Use when the answer depends on the user's prior conversations or personal context: explicit memory/recall requests, named personal projects, people, preferences, decisions, or history not explained in the current chat. Do not use for weather, current public facts, generic web research, or ordinary coding/file tasks when current files are sufficient. Also use when the user wants to set up, inspect, or manage memory.
---

# Memory

The user has a personal **memory** — a wiki of Markdown articles synthesized
from their past conversations, stored in the app-configured local vault (ask `memory_status` for its path). User memory
articles live under `articles/`. Read-only mlx-bun reference docs live under
`Reference/` as symlinks and are also searchable/readable, but synthesis never
writes them. Each user article is the consolidated, finished understanding of one
topic. Your job is to *use it* so the user never has to re-explain what they've
already told you.

It is entirely local: the articles, the synthesis, and these tools all run on
the user's machine. The retrieval tools read only local files.

## Consulting memory (the common case)

When the answer depends on personal continuity — an explicit memory/recall
request, or a named project, person, decision, preference, or history that is
not explained in the current chat — look it up **before** answering or asking
the user to re-explain. Doing the lookup first, instead of answering from first
principles, is itself the helpful move.

Do **not** use memory for weather, current public facts, generic web research,
or ordinary coding/file tasks when the current files or the web tools answer the
question. Memory is for user-specific context, not for performing familiarity.

The read path is **FIND the article → READ it small → answer**. It is
deterministic navigation — never a vector search, and there is no way to
query/sort articles by an infobox field (the infobox is facts you *read*, via
`memory_infobox`, not a filter).

1. **FIND the article.**
   - When the user names a specific thing, person, or project, call
     `memory_resolve` with the name as said ("S5 IIX", "the Lumix"). It returns
     the matched stem, title, kind, and lead — no search, no guessing.
   - For "what do I have about X", call `memory_category` with a `category`
     (e.g. `Lenses`), `type`, or `series`. This is membership, not search: it
     lists the articles that are actually about X.
2. **READ it small (the default).** Call `memory_read` to get the article's TOC
   + lead, then `memory_section` to read just the **one** section you need. The
   whole article is the exception — pass `force=true` only when you truly need
   all of it. The article is the user's consolidated current position; read it
   rather than reconstructing their view from scattered fragments.
3. **Follow the graph / read the infobox when useful.** `memory_links` shows
   outgoing links grouped by origin (infobox / series / see also / prose) plus
   backlinks — use it to hop to a neighbour (e.g. from a camera's infobox
   `mount: [[L-Mount]]` to the mount article). `memory_infobox` surfaces the
   structured facts to read. `memory_list` is a bare overview;
   `memory_status` answers setup/schedule/location questions. mlx-bun reference
   docs are separate from personal memory; use `reference_search`,
   `reference_read`, and `reference_list` for those.
4. **`memory_search` is the LAST resort.** Only fall back to it when
   `memory_resolve` / `memory_category` have failed across a couple of
   phrasings. It is a plain substring scan that doesn't understand meaning.
5. **Use it silently, as a continuation.** Let what you find shape your response
   like a long-time colleague who already knows the state of things. Speak as a
   continuation, never as a retrieval report: do not preface answers with "per
   the wiki…", "according to the article…", "I checked your memory…", or
   "welcome back, I see you're working on X". Cite an article by name only if
   the user asks where something came from, or to distinguish "the wiki says X"
   from "I think Y".

Use memory as an invisible prior: it should narrow relevance and improve the
answer, not become the topic of the answer. Avoid performative recall — do not
name-drop unrelated remembered facts to sound familiar.

## Availability

The memory panel can browse the vault and explicitly initialize one with the
user's agreement. These tools only read existing articles and references.
Synthesis runs on demand: `mlx-bun memory synthesize` (or the web app's
synthesize route) against a serving mlx-bun. `mlx-bun memory schedule` installs
a nightly launchd job that runs that same command; it needs a serving mlx-bun
at its time. `memory_status` reports whether that job is installed and loaded
plus the last synthesis commit; do not claim a scheduled run happened unless
the last synthesis commit shows it.

## What not to do

- Don't claim a fact "from memory" that you didn't read in an article — find
  and read the article first, or say you don't have it.
- Don't write to or edit the wiki during a normal conversation; the read tools
  are read-only by design. Synthesis is a separate, deliberate step.
- Direct the user to the memory panel when they want to browse the vault.
- Don't dump article contents at the user verbatim — use them to inform a
  direct, relevant answer.
- Don't perform familiarity. If the user asks for weather, current facts, or a
  normal coding task, use the task-appropriate tool instead of memory.
