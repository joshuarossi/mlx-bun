# The local write pipeline — conversations → entity articles

Status: **design**, 2026-06-26. Supersedes the bucket-centric routing in
[memory-synthesis.md](./memory-synthesis.md) and [bucketing-stage.md](./bucketing-stage.md)
on **one axis only**: how a chunk reaches an article. Everything else in those
docs (capacity-by-decomposition, the conservative gate, the pointer DB, stage
LoRAs, build sequence) stands. This doc is the write side recentered on the
governing realization:

> **Articles are THINGS (entities). Routing is entity-extraction + name-match,
> Wikipedia-style. Embeddings are at most a test instrument / fallback
> candidate-narrower — never the routing mechanism.** Notability is personal:
> a thing is article-worthy because the user engaged with it.

The cloud original (Lucien) uses **zero embeddings** and works. Wikipedia has no
vector index: it routes by named entities, links, and title search. We copy that
and supply the per-edit labor with local models instead of cloud calls or
volunteers.

## The shift: bucket-vector routing → entity name-match

Lucien's `cluster-assign-recent.ts` is the stage this doc rewrites. There, a
**bucket ≈ an article**: chunks are routed to ~379 buckets by feeding their
labels (25 at a time) to Opus, which reasons globally over the whole taxonomy
and emits assignments. `synthesize-update.ts` then feeds an entire bucket's new
chunks to one Opus call that rewrites the whole article.

Two things break when we localize this:

1. **No global reasoner.** A 1B model cannot hold 379 buckets in its head and
   assign correctly. (bucketing-stage.md already establishes this and decomposes
   it into M×N binary checks.)
2. **bucket ≠ article.** The new model says an article is a **thing**
   ("Panasonic S5IIX", "Photography", "Donald Trump"), and a chunk is *about
   things*. The natural routing key is therefore **the entity name**, not a
   fuzzy cluster centroid. A chunk that mentions the S5IIX routes to the
   `Panasonic_S5IIX` article by **name match**, exactly as a Wikipedia editor
   files a fact under the page whose title names the thing — no vector cosine
   anywhere on the hot path.

The "bucket" survives only as an **optional staging convenience** (a way to let
thin entities accumulate before they earn a page), not as the routing
substrate. The routing substrate is the **entity index**: a name→article map the
pipeline maintains deterministically.

## Why the north-star query forces this

> "What is the best lens that would give me REALLY long reach, but is not crazy
> expensive?"

To answer, the read agent must traverse: `Panasonic_S5IIX` → (infobox: Mount =
L-Mount) → `L-Mount` → compatible lenses; PLUS Josh adapts M42/EF (`Lens_Mount_Adaptation`)
so those qualify; he owns a `Lumix_75-300` so he wants *more* reach than that.

That traversal is only possible if the write pipeline produced:

- **entity articles** (the S5IIX is its own page, not a paragraph buried in
  "Camera Gear"),
- **infobox facts** (`Mount: L-Mount` as a queryable key-value, not prose the
  agent has to re-read and re-extract),
- **wikilinks** (`S5IIX → L-Mount → lenses`),
- **See also / series** (`Part of a series on Lenses`).

The existing corpus proves the gap is real: across 385 Dreaming articles there
are **378 See-also blocks but 0 infoboxes, 0 series banners, 0 {{Main}} links.**
Structured facts like "L-Mount" live as prose inside `Anamorphic_Lens_Adapters.md`
(the S5IIX isn't even its own article — it's a bolded phrase inside
`Camera_Gear_and_Lenses`). The write pipeline below makes entity-granular
articles + infoboxes a first-class output, because the read side needs them.

## The pipeline (DAG)

```
conversation transcripts
      │
      ▼  SEGMENT ··················· local + chunk LoRA (e4b, exists)
  single-topic chunks (+ label)
      │
      ▼  ENTITY-EXTRACT ············ local; "what THINGS is this chunk about?"
  chunk → [entity mentions]   (the routing key — replaces bucket-vector)
      │
      ▼  ROUTE (name-match, deterministic + tiny binary disambiguation)
  each mention → existing article  |  CREATE new article  |  drop (trivial)
      │
      ▼  SECTION-ROUTE ············· M×N binary, hierarchically pruned
  "does chunk i update section j of article A? yes/no"
  all-no + substantive → new section ;  no related article → new article
      │
      ▼  PATCH ····················· local + synth LoRA; one (chunk,section) pair
  integrate chunk into section + [^N] citation  (bounded in/out)
      │
      ▼  NORMALIZE ················· deterministic code (NOT a model)
  footnote bijection · wikilink canonicalize · infobox key sort
      │
      ▼  WIKIFY (periodic) ········· local + editor LoRA + structural pass
  per-section improve · summary-style splits · series/See-also/infobox upkeep
```

Compared to memory-synthesis.md's DAG, the change is **CLASSIFY→bucket** is
replaced by **ENTITY-EXTRACT → ROUTE(name-match)**, and SECTION-ROUTE is lifted
to a first-class M×N stage rather than a sub-step of SYNTHESIZE.

---

## Stage 1 — SEGMENT (chunk)

**Single task the model performs:** *"Split this one conversation into
single-topic chunks; give each a 4-10-word specific label."* Unchanged from
Lucien's `chunk-recent.ts` and already the e4b chunk LoRA's job.

- **Prompt shape:** one conversation in (formatted `[sender] (uuid) text`),
  JSON `{chunks:[{start_message_uuid,end_message_uuid,label}]}` out. Meta policy
  (`Chunking.md`, `Topics_to_Ignore.md`) inlined. Ignore-rule spans are simply
  omitted (the substance filter starts here).
- **LoRA:** **`memory-chunk` (exists, e4b chunk-300).** This is the one stage
  with a trained adapter. Its purity is load-bearing: a chunk fusing two things
  pollutes every entity it routes to. Eval by boundary/label accuracy vs gold,
  not val loss.
- **Output → DB:** pointer `chunks(id, conv, start, end, label)` (no text copy).

A chunk's **label is the entity-extraction input** for the next stage — Lucien
already classifies on labels, and the label is a clean ~6-word topic string.

---

## Stage 2 — ENTITY-EXTRACT (the new routing key)

**Single task:** *"What things (entities) is this chunk about? List them as
canonical names."* This is the stage that **replaces bucket-vector routing.**

A "thing" is any nameable entity the user engaged with: a product
(`Panasonic S5IIX`), a standard (`L-Mount`), a person (`Donald Trump`), a
project (`Archie`), a domain (`Photography`). Broad-domain entities are legal
and expected — they capture domain-level engagement; specific-thing entities
capture the relationship to that exact entity. A chunk yields **0..N entities**
(many-to-many at the root).

- **Prompt shape (atomic, extraction-only — no routing decision here):**

  ```
  A chunk of the user's conversation is below (label + text).
  List the distinct THINGS (entities) it is about — products, people,
  standards, projects, domains. One per line, as the canonical name you'd
  title a wiki article. Include both specific things (e.g. "Panasonic S5IIX")
  and the broad domain (e.g. "Photography") when both are genuinely engaged.
  If it is about nothing nameable/substantive, output NONE.

  LABEL: {{label}}
  CHUNK: {{text}}
  ```

  Output: a short newline list of names. **No JSON object, no batch indices** —
  the failure modes the bucketing critique flagged (multi-item JSON fidelity,
  batch index drift) don't arise. One small list per chunk.

- **Why extract is separate from route:** extraction is "read and name"
  (in-context, reliable for a small model); routing is "match against the
  existing index" (a deterministic + tiny-binary step, Stage 3). Keeping them
  separate keeps each task atomic — the capacity-by-decomposition rule.

- **LoRA:** likely **base + policy first** (`memory-entity`, train only if the
  base over/under-extracts or won't canonicalize names). NER-style extraction is
  near the easy end for a small instruct model; the binary disambiguation in
  Stage 3 is where errors are cheap to catch. Decision keyed off extraction
  precision/recall vs a gold entity set distilled from the cloud pipeline.

- **Output → DB:** `chunk_entities(chunk_id, entity_name, surface_form)` — the
  many-to-many root edge. `entity_name` is the canonicalized title; `surface_form`
  is what the chunk literally said (for the disambiguation step and for never
  losing the user's wording).

### Canonicalization is deterministic, with a tiny binary tiebreak

Name-match must survive aliasing ("S5IIX" / "S5 IIX" / "Lumix S5IIX" / "the
Panasonic"). The pipeline keeps an **entity index** — `entities(name,
aliases[], article_stem)` — built from existing article titles + an `aliases`
list each article's infobox/lead declares. Matching:

1. **Deterministic normalize + alias lookup (no model):** case-fold, collapse
   whitespace, strip articles/possessives; look up in the alias table. Exact or
   alias hit → routed. This is Wikipedia's redirect mechanism.
2. **Tiny binary disambiguation (model, only on miss/ambiguity):** *"Is
   `{{surface_form}}` (context: `{{label}}`) the same thing as the existing
   article `{{candidate}}` — `{{candidate lead sentence}}`? yes/no."* Run only
   over the few lexically-near candidates (a lexical/trigram shortlist over
   titles+aliases — **lexical, not vector**; embeddings are a *fallback*
   narrower only if lexical recall proves insufficient, measured first).
3. **No match + substantive → CREATE article** (Stage 4's create branch).
   No match + trivial → drop.

This is the entity analogue of bucketing-stage.md's "new-bucket global gate":
the disambiguation step prevents `Panasonic S5IIX` and `Lumix S5 IIX` becoming
two pages. The difference from the old design is the candidate set comes from
**name/alias lexical match, not centroid cosine.**

---

## Stage 3 — ROUTE: mention → article

**No new model task** beyond Stage 2's disambiguation binary. Routing is the
deterministic join of `chunk_entities` against the `entities` index:

- mention resolves to an existing article → enqueue `(chunk, article)` for
  section-routing.
- mention resolves to nothing, substantive → CREATE candidate (Stage 4).
- mention trivial / on the ignore list → drop.

A single chunk routes to **multiple articles** (it named multiple things) — this
is where facet extraction falls out: the same S5IIX-anamorphic chunk lands on
`Panasonic_S5IIX`, `Anamorphic_Lens_Adapters`, and `Lens_Mount_Adaptation`,
each of which will keep only what's relevant to *it* at patch time.

**Bucket's residual role (optional):** a thin entity (1-2 mentions, not yet
page-worthy) can park its chunks in a lightweight bucket keyed by the entity
name until it crosses a create-threshold. This is the only thing "buckets"
still do — a staging queue for sub-notable entities — and it's optional; the
default is "substantive new thing → create a {{stub}} immediately," matching
Wikipedia's "a stub is legitimate; coverage earns value" (Article_Conventions.md).

---

## Stage 4 — SECTION-ROUTE (the M×N binary core)

For each routed `(chunk, article)` pair, decide which **section(s)** the chunk
touches. This is bucketing-stage.md's M×N binary pattern, now first-class.

**Single task (one call per pair):** *"Should this chunk update THIS section?
yes/no."*

```
ARTICLE: {{title}}
SECTION: {{heading}} — {{section's first ~2 sentences}}
CHUNK (label): {{label}}
CHUNK adds: {{1-line gist or the chunk text if short}}
Does this chunk add or change information belonging in THIS section? yes/no.
```

Run over the article's *N* TOC sections (from `parseToc`/`extractSection` in
`vault.ts`). Hierarchical pruning keeps M×N small:

- **Coarse gate already passed:** the chunk is here only because it named this
  article's entity (Stage 3), so we never run sections of unrelated articles.
- **Within the article**, *N* is tiny (a handful of sections). Run all *N*
  binaries; optionally prune with a lexical heading match first. **No vector
  required** — N is small enough to brute-force, which is the whole point of
  local ~free inference.

**The uniform growth rule (no-match → create):**

- chunk gets **yes** on ≥1 section → those become PATCH pairs.
- chunk gets **all-no** but is substantive → **CREATE-NEW-SECTION** task:
  *"Name a new section (2-5 words) for this material, or NONE if it's a trivial
  aside."* Mirrors new-article/new-bucket creation.
- article didn't exist at all (Stage 3 create) → **CREATE-ARTICLE**: this is the
  cold-start flow — sub-cluster the entity's chunks into proto-sections, outline,
  draft each section (memory-synthesis.md's CREATE flow, unchanged), seeded with
  an **infobox** for the entity (below).

- **LoRA:** **`memory-section` (train if base misfires).** The binary framing is
  much easier than multi-section JSON; base + policy may clear the bar. Decision
  keyed off per-(chunk,section) yes/no accuracy + per-chunk section-set Jaccard
  vs gold (oracle-shortlist F1 vs real, per bucketing-stage.md's eval design).

- **Output → DB:** `chunk_sections(chunk_id, article, section_anchor)` — the
  patch worklist. `synthesized_chunk_sections` is the per-(chunk,section)
  idempotency ledger (fold each chunk into each section exactly once;
  `NOT IN` resumption like Lucien's `synthesized_bucket_chunks`).

---

## Stage 5 — PATCH (the most atomic synthesis)

**Single task:** *"Integrate THIS chunk into THIS section. Add a `[^N]`
citation. Change nothing else."* Bounded text in, bounded text out — the
opposite of Lucien's whole-article rewrite.

- **Prompt shape:** current section markdown + the chunk (with conv UUID, date,
  source slug in the header for the footnote) + the citation rules (the exact
  footnote contract from `synthesize-update.ts` / `Article_Conventions.md`,
  inlined). Output: the rewritten **section only**, plus any new `[^N]:`
  definition lines. **Everything outside the routed section stays
  byte-identical** — the assembler swaps just that section back into the file.

- **Conservative write gate (per section, ported from Lucien):** preserve
  prose, ≥70% word-count floor on the section, every pre-existing `conv:`
  citation in that section survives, integrate-don't-overwrite. A weak local
  pass that shrinks/strips the section is gated to **NO-OP** (the chunk stays
  un-synthesized and retries next run) rather than allowed to corrupt the vault.
  This is the inviolable "LoRAs propose, deterministic gates dispose" rule.

- **LoRA:** **`memory-synthesis`.** The single most valuable adapter to train,
  distilled from Lucien's cloud synthesis edits — but at **section
  granularity** (one (chunk,section) integration per training example), not
  whole-article. Signal: citation preservation, faithful integration, no
  hallucinated claims.

- **Provisional facts (open question, flagged):** the patch should represent
  trajectory ("work set to begin July") so a later chunk cleanly updates it
  ("began", "completed"). A lightweight convention (e.g. an `as of YYYY-MM`
  tag in prose tied to the citation date) keeps temporal claims updatable
  rather than contradictory. Deferred; called out so the patch prompt can grow
  into it.

---

## Stage 6 — WIKIFY (periodic structural pass) + infoboxes

Section-patches are greedy and local; over many of them an article drifts
(sprawl, stale lead, redundant prose, missing structure). WIKIFY is the periodic
global-but-decomposed pass that keeps articles *good* — and it is where the
**under-explored Wikipedia conventions** the read side needs get maintained.

Two parts (memory-synthesis.md's distinction holds — keep them separate from the
deterministic NORMALIZE below):

**(a) Per-section "improve this section" (local + `memory-editor` LoRA).**
Atomic, same shape as a patch but no new chunk: *"Tighten this section: remove
redundancy, keep every citation and every specific detail, don't generalize away
particulars."* Gated by the same ≥70% floor.

**(b) Cheap structural pass over the TOC (local, single small call per article):**
this is the stage that builds the traversable structure the north-star query
depends on. It performs, as **atomic sub-tasks**, the conventions Josh flagged:

- **Infobox maintenance** — *"From this entity article, extract/refresh the
  structured key-value facts."* For `Panasonic_S5IIX`: `Type: Mirrorless camera`,
  `Mount: [[L-Mount]]`, `Sensor: full-frame`, `Owner-status: owned`. **This is
  the single most load-bearing structural output** — the infobox `Mount` field
  is exactly the queryable fact the lens query traverses, instead of re-reading
  prose. Infobox values that are themselves entities become **wikilinks**, so
  the infobox is part of the link graph. (Corpus today: 0 infoboxes — this stage
  creates them.) The infobox also declares the article's `aliases:` used by the
  Stage-2 entity index — closing the loop.

- **Summary-style split (`{{Main}}`)** — *"Has a section outgrown the article?"*
  When `Camera_Gear_and_Lenses` accumulates a full section on the S5IIX, split
  it into a child `Panasonic_S5IIX` article and leave a summary + `{{Main:
  Panasonic_S5IIX}}` link. This is **how specific-thing articles are born from
  broad-domain ones** — the structural complement to Stage-2 entity extraction,
  and exactly what the corpus needs (the S5IIX is currently trapped as a phrase
  inside a gear article).

- **Article series** — *"Does this article belong to a series?"* Emit/maintain a
  `Part of a series on [[Lenses]]` banner linking siblings, so the read agent
  can enumerate "all lens articles" by following the series, not by guessing
  titles.

- **See also / lead refresh / re-section / split-merge signals** — reorder
  sections, refresh the stale lead, emit Talk-page SPLIT/MERGE/CONTRADICTION
  signals (these *may* use embedding silhouette as a **test/triage instrument**
  — the one sanctioned embedding use, never on the routing hot path).

WIKIFY runs **periodically**, not per-chunk (it's the editorial sweep), and is
decomposed so even the "global" pass is a series of atomic per-section /
per-convention calls — local-tractable for the same reason synthesis is.

---

## Stage 7 — NORMALIZE (deterministic, no model)

Pure code enforces the invariants AI can't be trusted on (the division of labor:
**AI judges, code enforces**). Ported from Lucien's `normalize-footnotes.ts` /
`normalize-wikilinks.ts`; `vault.ts` already has the wikilink resolver.

- **Footnote bijection:** every `[^N]` marker ⇔ exactly one `[^N]:` definition;
  renumber 1..k contiguous in first-appearance order; merge duplicate
  `conv:HASH` definitions to one marker. (Patches append; this re-derives the
  canonical numbering.)
- **Wikilink canonicalization:** resolve `[[Name]]` to the exact on-disk stem
  (underscores, case), repair/flag orphans, never write a spaced target that
  resolves to nothing. Infobox entity-values normalized the same way.
- **Infobox key normalization:** stable key order/format so infoboxes are
  diff-clean and machine-readable for the read agent.
- **Structural guards:** `## References` last, `## See also` before it,
  `{{stub}}` marking for thin articles, title = `# H1` = filename stem.

NORMALIZE is non-fatal (logs + continues) and runs after every write, before the
git commit. It cannot corrupt an article — it only canonicalizes.

---

## Stage → task → model → adapter (summary)

| stage | single task the model does | prompt shape | model / adapter |
|---|---|---|---|
| SEGMENT | split one conv into single-topic chunks + labels | 1 conv → JSON chunks | **memory-chunk (e4b, exists)** |
| ENTITY-EXTRACT | name the THINGS this chunk is about | label+text → name list | base+policy; `memory-entity` only if needed |
| ROUTE | (deterministic) name/alias match; binary "same thing?" on miss | tiny yes/no per near candidate | base+policy (disambig binary) |
| SECTION-ROUTE | "does chunk i update section j?" yes/no, M×N | per (chunk,section) yes/no | `memory-section` if base misfires |
| PATCH | integrate THIS chunk into THIS section + cite | section+chunk → section | **memory-synthesis (highest value)** |
| WIKIFY-improve | tighten THIS section | section → section | `memory-editor` |
| WIKIFY-structure | infobox / split / series / see-also (atomic sub-tasks) | per-convention small calls | `memory-editor` (+ base) |
| NORMALIZE | — | — | **deterministic code** |

**Where a LoRA is genuinely needed vs base+policy:** PATCH (memory-synthesis)
and SEGMENT (memory-chunk) are the two with the hardest judgment and the most
to lose — train these. ENTITY-EXTRACT and SECTION-ROUTE are atomic enough that
**base + inlined Meta policy may clear the bar**; train only on a measured miss,
per the staged LoRA criteria in bucketing-stage.md (Stage 0 instrument → Stage 1
base+prompt → Stage 2 train only if it misses). ROUTE's disambiguation is a tiny
binary that base models do well. WIKIFY-improve/structure can share one
`memory-editor` adapter or stay base+policy initially.

---

## Data model deltas (vs bucketing-stage.md / db.ts)

Keep the pointer design (memory-synthesis.md). Add the entity layer; demote
buckets:

- **`messages`** — text once, `(conv, position)`.
- **`chunks`** — pointers + `label` (no text copy).
- **`entities(name, aliases, article_stem, kind)`** — the **routing index**
  (name→article); `kind` ∈ {thing, person, domain, project, standard}. Built
  from article titles + infobox-declared aliases. *This table replaces
  `buckets` as the routing substrate.*
- **`chunk_entities(chunk_id, entity_name, surface_form)`** — M:N root edge
  (ENTITY-EXTRACT output), the entity analogue of `chunk_buckets`.
- **`chunk_sections(chunk_id, article, section_anchor)`** — SECTION-ROUTE
  worklist (already planned).
- **`synthesized_chunk_sections(chunk_id, article, section_anchor, at)`** —
  per-section idempotency ledger (Lucien's `synthesized_bucket_chunks`, at
  section granularity).
- **`buckets` / `chunk_buckets`** — kept only as an **optional staging queue**
  for sub-notable entities; not on the routing path. May ship empty.
- `PRAGMA foreign_keys = ON` + `ON DELETE CASCADE` (fixes Lucien's orphan
  edges). DB is rebuildable cache; truth = vault + git.

---

## Build sequence (cold-start first — vault is empty)

1. **SEGMENT** to the e4b chunk adapter (the one adapter in hand); verify
   single-topic chunks + labels on real pi sessions.
2. **ENTITY-EXTRACT** base+policy; eval entity precision/recall vs a gold entity
   set distilled from the Lucien corpus (article titles ≈ gold entities).
3. **ROUTE** — deterministic name/alias index + binary disambiguation; from zero
   every substantive entity → CREATE a {{stub}}.
4. **CREATE flow** (sub-cluster → outline → per-section draft + **seed
   infobox**) behind the conservative gate — gets us from zero to first entity
   articles, each with a queryable infobox.
5. **NORMALIZE** (deterministic footnote/wikilink/infobox) — `vault.ts` resolver
   exists.
6. **SECTION-ROUTE + PATCH** (steady state) once articles exist to update.
7. **WIKIFY** structural pass (infobox upkeep, summary-style splits, series,
   See-also) once articles accumulate enough to drift — and to retrofit the
   split-out of specific things (S5IIX) from broad ones (Camera Gear).

Steps 1-5 are cold-start (zero → first entity articles with infoboxes); 6-7 are
steady state. The **first verifiable win** is: ingest a camera conversation →
get a `Panasonic_S5IIX` article whose infobox has `Mount: [[L-Mount]]`, with the
read agent able to traverse that fact for the north-star lens query.

## Open questions (carried + new)

- **Domain vs specific granularity:** when ENTITY-EXTRACT should emit only the
  broad domain vs also the specific thing (and when WIKIFY should split a thing
  out of a domain). Heuristic: emit both; let create-threshold + summary-style
  split decide what becomes its own page.
- **Entity canonicalization recall:** measure lexical-shortlist recall over
  titles+aliases *first* (the bucketing-stage.md "measure the shortlist ceiling"
  discipline, applied to names); only add the embedding fallback narrower if
  lexical recall is insufficient.
- **Create-vs-strong-model for bootstrap** (carried): is first-creation good
  enough local, or is bootstrap the one place a stronger model earns its cost?
- **Provisional/temporal facts:** the `as of` convention for trajectory claims.
- **Infobox schema per entity-kind:** a small set of templates (camera, lens,
  person, project) so infobox fields are consistent enough to query.
