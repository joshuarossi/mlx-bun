---
status: active
axis: USING
canonical-for: memory-synthesis (the Dreaming)
plan-anchor: none
last-verified: 2026-08-23
---

# The Dreaming — memory write path + synthesis (canonical design)

This is THE design doc for mlx-bun's memory write path: the pipeline that
turns conversations into a personal wiki (`src/memory/`, `scripts/memory/`),
the local-model inference seam it runs on, the read path it feeds, and the
evaluation methodology that sits beside it. It consolidates, in supersession
order, `memory-synthesis.md` → `write-pipeline-entity.md` →
`bucketing-stage.md` → this doc, plus the architecture half of
`memory-system.md`, `memory-inference-path.md`, and the still-open task list
from `the-dreaming-master-plan.md`. Where those docs disagree, this doc wins.

- User-facing behaviour (CLI, tools, vault layout as the user sees it) lives
  in `docs/reference/memory.md`. Status and changelog prose belong in
  `PLAN.md`; this doc carries design plus a short dated History.
- Every code claim below was re-read against `src/memory/` on 2026-08-23.
  Where the code and the settled design differ, both are stated
  ("as built" vs "target") — the code is the truth about what runs; the
  design is the truth about where it goes.

The system is the second iteration of Lucien's memory pipeline
(`~/Code/lucien`, cloud models), rebuilt to run entirely on local models. Same
methodology at the core — do whatever Wikipedia does — with two consequences
of the local constraint:

1. **Small tasks.** Every AI step is the smallest single-purpose unit a small
   local model does well — one chunk, one section, ideally a binary judgment.
   Never a whole-article blob in or out. And every AI step is pure
   text-in/text-out: no tool calls, no agent loop. The pipeline hands the
   model exactly the context it needs and applies the output
   deterministically.
2. **Deterministic gates between AI steps.** AI does judgment; code enforces
   invariants (citations, footnotes, wikilinks, infobox shape, word floors).
   A weak output is gated to NO-OP, never allowed to corrupt the vault.
   "LoRAs propose, gates dispose."

## 1. Contract and fixed principles

**The memory contract (ported from Lucien):** chat-time agents READ memory;
the synthesis pipeline WRITES memory. Articles are durable priors,
conversations are evidence, synthesis is the deliberate, auditable process
that turns evidence into updated articles. Normal chat never mutates an
article; writes happen only through `mlx-bun memory synthesize` (or its
per-stage subcommands) and the user's own edits in the vault.

Fixed principles (do not re-derive, do not contradict):

- **Conversations are the base.** The pipeline's only input is conversation
  transcripts — pi sessions in steady state, a one-time historical import
  through the same code for onboarding.
- **Articles are THINGS (subjects), with sections.** One subject per
  article: a lead, an infobox, `##` sections, See also, References. Subject
  mentions are `[[wikilinks]]`. Every article is "the thing AND how the user
  relates to it"; general world-facts link out.
- **No notability filter.** "If I talk about it, it's notable." Nothing is
  dropped as trivia. A thin subject is CAPTURED (kept searchable in
  `_captured`) until it recurs; stubs are a feature.
- **Capacity by decomposition.** A small model's effective capacity scales
  inversely with task size; you don't make the model smarter, you make each
  task narrower. Decompose to binary where possible and run M×N — affordable
  because local inference is nearly free. Coarse gates prune fine ones
  (chunk → article → section).
- **No embeddings in the pipeline.** Routing, grouping, and reading are
  deterministic name/alias/category lookup plus small-model judgments. The
  hot path asserts the `src/embed.ts` tripwire (`getEmbedCounter()`) stays
  at 0. Embeddings survive only as offline eval instruments (§8) — see the
  contradiction note there.
- **Vault = truth, DB = derived cache.** Markdown in the vault is canonical
  and git-tracked; SQLite is pipeline ledger + rebuildable index
  (`reindex`).
- **Chronology is load-bearing.** Every stage walks
  `conversations.updated_at ASC, chunks.start ASC`. This is what makes
  self-healing correct: the user's latest statement dominates.
- **Self-healing through ordinary use.** Corrections arrive as ordinary
  chunks; a later-dated contradiction resolves the article toward the
  user's latest position. The user's evolving positions keep a `## History`
  trace; an AI factual error is silently overwritten.
- **Prompts and Meta pages are SCHEMATIC** — no real names, specs, or dates.
  The small model parrots concrete example values into unrelated articles
  (observed five times during bring-up). Every prompt carries a no-copy
  guard; leaky drafts are rejected (`isLeakyDraft`).
- **Runs nightly, locally, unattended** (launchd, `src/memory/schedule.ts`).
- **Lucien is a read-only oracle.** `~/Code/lucien/.lucien/lucien.db` is
  opened read-only; `~/Dreaming` is never written. Never suggest modifying
  Lucien's code, DB, or vault.
- **Model evals are beside the system, not inside it.** Judges, gold sets,
  and signal scripts choose and train the models the pipeline uses; they are
  never a pipeline stage.

## 2. Data model

### 2.1 Vault (truth)

- Root `~/.mlx-bun/wiki/` (override `MLX_BUN_WIKI`, honoured by `vaultRoot()`
  — every script and test redirects the whole pipeline by setting it).
- `articles/*.md` user articles · `Meta/*.md` editable policy pages ·
  `Talk/` restructure suggestions · `Reference/*.md` read-only symlinks to
  mlx-bun's own docs (chat tools may read them; synthesis must never write
  through them).
- Plain Markdown, git-tracked, usable as an Obsidian vault. Every pipeline
  write ends in `commitVault`.
- Meta pages seeded by `setupVault` (`src/memory/vault.ts` `META_PAGES`):
  Editorial_Guidelines, Bucketing, Article_Conventions, Infobox_Schemas,
  Category_Definitions, Entities, Summary_Style, Buckets, Chunking,
  Topics_to_Ignore. Policy lives in the vault, not in code:
  `loadMetaPolicy(names)` (`src/memory/prompts.ts`) inlines pages into a
  stage prompt (single-turn, bounded prefill — never "go read the page")
  and throws if a requested page is missing.

### 2.2 Article grammar (`src/memory/article.ts`)

Fixed skeleton, top to bottom: `# H1` (== filename stem with `_`→space) →
optional series banner `*Part of a series on [[X]].*` → optional infobox
(fenced ```` ```info ```` block of `key: value` lines) → lead (present-tense
relationship abstract) → `##` sections → `## See also` → optional `## Notes`
→ `## References` last. Templates the parser and NORMALIZE recognise:
`{{stub}}`, `*Main article: [[Child]]*`, `*Redirects to [[X]]*`.

- **Infobox** — `snake_case` keys; entity-valued fields are `[[wikilinks]]`
  (they feed the link graph); `aliases:` is a comma list feeding the entity
  index; `kind:` is the closed set `ENTITY_KINDS = thing | person | domain |
  project | standard`; `type:` and every other field label are EMERGENT
  (governed by `Infobox_Schemas.md`, never a code enum). Fields are either
  world-facts (citable specs) or relationship-facts (owned / used_for /
  opinion / status … — the personal layer). The infobox is CONTENT the model
  reads, never a query/filter engine; there is no field query anywhere.
- **Categories** — emergent and explicit: an article declares
  `[[Category:Name]]`; the deriver accumulates names into `categories`. A
  fresh vault has zero.
- **Citations** — footnote defs in the Lucien standard
  `` [^N]: `conv:HASH` (YYYY-MM-DD, source) — desc ``, HASH = first 8 hex of
  the conversation UUID. A hash identifies the CONVERSATION only; chunk →
  section provenance is recovered from the ledger, never by parsing
  footnotes. The model only PLACES markers; code writes every definition
  line (`buildFootnoteMap`, `footnoteDefLine` in `synthesize.ts`).
- One shared fence scanner (`isFenceLine`/`fenceLabel`) so `article.ts`,
  `vault.ts`, `normalize.ts`, `crosslink.ts` agree on "inside a code block";
  `repairFences` closes a dangling fence deterministically.

### 2.3 Store (`src/memory/db.ts`, `~/.cache/mlx-bun/memory.sqlite`)

bun:sqlite, WAL, `PRAGMA foreign_keys = ON`, `ON DELETE CASCADE`. A DB
carrying the pre-rewrite schema (`chunks.text` column or a
`synthesized_bucket_chunks` table) is dropped and recreated on open.

- **Derived cache** (rebuilt from markdown by `reindex`, never the reverse):
  `entities` · `entity_aliases` · `categories` · `article_categories` ·
  `infobox_facts` · `links` (`via ∈ prose|infobox|seealso|series|main`).
- **Synthesis ledger** (authoritative pipeline progress, not derivable from
  the vault): `conversations` · `messages` · `chunks` · `chunk_entities` ·
  `chunk_sections` · `synthesized_chunk_sections` · `reconciled_articles` ·
  `watermarks` · `buckets` / `chunk_buckets` · `subject_redirects`.
- **Pointers, not copies.** `messages` holds text once, keyed
  `(conv, position)`. A chunk is a `[start,end]` range plus a label, id
  `${conv}:${start}-${end}` (deterministic, idempotent re-chunking);
  `chunkText(id)` reassembles on demand. Assignments are join tables
  (many-to-many at every layer). The article markdown is the only
  materialised synthesis; its `conv:` citations point back at sources.
- `reindex` (`src/memory/reindex.ts`) drops and rebuilds exactly the six
  derived tables from the vault with foreign keys off (so pipeline
  `chunk_entities` rows survive), in sorted-stem order, deterministically.
  It also PROJECTS `subject_redirects` into `entity_aliases` so a subject
  that folded into or was captured near another article still resolves.

Turso/sqlite-vec were considered as a vector-capable engine and are moot
under the no-embeddings rule; the driver stays bun:sqlite.

## 3. The pipeline as built (verified 2026-08-23)

```
pi sessions / Lucien import   ingest.ts  (watermark per source)          [NOT wired into the nightly run — §9]
        │
        ▼  SEGMENT ─────────── AI (memory-chunk adapter): one conversation → single-topic chunks + labels
        ▼  ENTITY-EXTRACT ──── AI (base+Entities.md): one chunk → the THINGS it is about (name list)
        ▼  ROUTE ────────────── deterministic resolve → binary disambiguate → create | routed | capture
        ▼  SYNTHESIZE
        │    CREATE ─────────── AI: sub-cluster → OUTLINE → per-section DRAFT → INFOBOX → assemble
        │    SECTION-ROUTE ──── AI: M×N binary "does this chunk update THIS section?" (+ name a new one)
        │    PATCH ──────────── AI: one (chunk, section) → replacement section, rest byte-identical
        │    RECONCILE ──────── AI+code: infobox = ground truth; lead/body/infobox agree; History
        │    ── every write: NORMALIZE (code) → conservative gate (code) → weak ⇒ NO-OP ──
        ▼  LINK ─────────────── code: first-mention [[links]] + co-occurrence See also (idempotent)
        ▼  commit (git)
        ▼  WIKIFY sweep ─────── AI (editor): per-section tighten + infobox refresh, every article
```

Orchestration: `runSynthesis` (`src/memory/pipeline.ts`) drives
`runPipeline` = `runSegmentStage → runExtractStage → runRouteStage →
runSynthesizeStage → runLinkStage`, then `wikifyVault` over every article.
Each stage worker (`src/memory/stages.ts`) pulls its eligible work from the
DB by state, processes a bounded batch, persists, and is individually
runnable: `mlx-bun memory segment | extract | route | synthesize-stage |
link`; `mlx-bun memory synthesize` is the full DAG; `--dry-run` plans without
model calls. A failed article never blocks the rest of a run.

### 3.1 INGEST (`ingest.ts`)

Two sources, watermark-gated per `source`: pi sessions via
`SessionManager.listAll()` (`ingestSessions`) and the one-time Lucien
bootstrap (`ingestLucien`, read-only; maps Lucien's UUID-anchored chunks to
positions). Idempotent — a re-touched conversation is rewritten in place.
**As built, neither entry point is called by `runSynthesis` or any
`scripts/memory/` driver** (only `tests/memory-ingest.test.ts` exercises
`ingestLucien`); `runPipeline` emits "ingest: corpus already in the store".
The nightly fold-in of new pi sessions is therefore not yet end-to-end — see
§9.

### 3.2 SEGMENT (`chunk.ts`, `chunk-validation.ts`)

The `memory-chunk` adapter (`e4b-chunk-300`, symlinked to
`~/.cache/mlx-bun/adapters/memory-chunk`) segments each conversation whose
`chunked_at` is NULL or older than `updated_at`. Prompt = `CHUNK_SYSTEM`
(the exact trained system turn, byte-for-byte) + `CHUNK_PROMPT` with
`Chunking.md` + `Topics_to_Ignore.md` inlined. Output is JSON of message-UUID
anchors + a 4–10-word label; anchors are validated and repaired
(`validateChunks`) before pointer rows are written; a conversation whose
output fails validation is left unmarked and retried next run. Re-run is a
no-op by watermark. Chunk purity is the foundation of everything downstream:
a chunk that fuses two topics pollutes every article it routes to.

### 3.3 ENTITY-EXTRACT (`entity.ts`, `resolve.ts`)

One chunk per call, base model + `Entities.md`: "what things is this chunk
about? canonical wiki-title names, one per line, specific things AND the
broad domain, NONE if nothing nameable." Plain newline list parsed by
`parseLines` — no multi-item JSON, no batch indices (the batch-index drift
that sank Lucien's batched assign). Persists `chunk_entities(chunk_id,
entity_name, surface_form)` and a candidate `entities` row (article_stem
NULL). Canonicalisation is deterministic and conservative
(`EntityResolver`): `canonicalize` (casefold, whitespace, leading
articles/possessives) → `squeeze` (strip all non-alphanumerics) → alias index
(store + `goldens/dreaming-entities-gold.json` seeds) → token-subset fuzzy
match requiring a distinctive token (the over-merge guard). When in doubt it
mints a new canonical rather than fusing two things.

### 3.4 ROUTE (`route.ts`, `redirect.ts`)

Per surface: (1) RESOLVE against the known-entity index — a hit folds into
that article with no model call; (2) DISAMBIGUATE a miss with a trigram
shortlist of existing entities and one bounded binary per candidate ("is X
the same thing as Y? yes/no", `parseBinary`, existing wins); (3) CREATE /
CAPTURE for a surface matching nothing: it earns its own article when it
RECURS (`RECURRENCE_THRESHOLD = 2` routed chunks) or, with the optional
`useSubjectGate`, when a chunk engages it as a genuine subject; otherwise it
is CAPTURED — its chunks go to the reserved `_captured` bucket, `notable = 0`,
still searchable, never dropped, promoted later if it recurs. There is no
ownership/usefulness test. `runRouteStage` also registers
`subject_redirects` so every discussed subject resolves to a home (a folded
subject → its article; a captured subject → the article it most co-occurs
with). A chunk fans out to every article it names — this is where facet
extraction falls out: the same chunk lands on several articles, each keeping
only what is relevant to it at patch time.

### 3.5 SYNTHESIZE (`stages.ts` `runSynthesizeStage`, `synthesize.ts`, `cluster.ts`)

Chronological throughout; commits once at the end.

- **CREATE** (`synthesizeCreate`) for each `notable = 1` entity with no
  article file, oldest entity first, capped by `DEFAULT_ARTICLE_CAP = 20`
  per pass: `subClusterChunks` groups the entity's chunks into proto-sections
  by label/text token overlap (deterministic, no embeddings) → OUTLINE (2–6
  headings) → per-section DRAFT from only that section's chunks → LEAD →
  seed INFOBOX (`buildInfoboxFields`, kind + declared aliases) → assemble →
  NORMALIZE → gate → write + `synthesized_chunk_sections` ledger. The model
  never holds a whole article. Leaky drafts retry once, then NO-OP.
- **SECTION-ROUTE** (`routeSections`) for each chunk routed to an existing
  article and not yet in the ledger: one binary per routable section
  (structural tails References/See also/Notes excluded; the lead is a
  first-class target, `LEAD_ANCHOR`), prompt = title + heading + section's
  first ~2 sentences + chunk label + gist. All-no + substantive → "name a new
  section (2–5 words) or NONE"; a named section is honoured
  (`synthesizeNewSection`), never a silent drop. Hierarchical pruning is
  structural: only articles ROUTE matched are ever gridded.
- **PATCH** (`synthesizePatch`, `patchSection`) — the model is handed the
  current section + the chunk (with its pre-assigned `[^N]`) and outputs a
  complete REPLACEMENT SECTION; code swaps exactly that section
  (`replaceSection`), appends the definition line, and leaves the rest of
  the file byte-identical. Contradiction = correction: rewrite toward the
  latest statement, classified by `classifyContradiction` (`history.ts`) as
  EVOLUTION (keep a `## History` entry citing both sources; default when
  ambiguous) or ERROR (silent overwrite, the wrong value's citation may be
  pruned via `allowDroppedHashes`). Idempotent via the ledger PK.
- **RECONCILE** (`reconcileArticle`) runs after the patch loop over every
  article touched this run: the infobox is ground truth; relationship
  fields (favourite/opinion/status/owned … — never `PHYSICAL_SPEC_KEYS`) and
  sibling body sections still asserting a superseded value are refreshed
  toward the latest-dated position, provenance-preserving (every `[^k]`
  survives, phrased as change over time). Consistent article ⇒ NO-OP;
  unresolved present-tense assertions are logged, not forced.

### 3.6 The conservative write gate (`gate.ts`) and NORMALIZE (`normalize.ts`)

`gateEdit(before, after)` is a faithful port of Lucien's editorial gate and
guards every write (create, patch, new section, reconcile, link, wikify):
every pre-existing `conv:` citation survives (unless deliberately pruned),
footnote bijection, edited word count ≥ `floor` (default 0.7) of the
original, H1 and `## References` survive, at most one `## See also`. It can
only reject, never rewrite; it catches citation/structure/bulk-prose loss,
not nuance loss (that is the judge's job, §8).

`normalizeArticle` runs inside every write before the gate, pure and
idempotent: footnote renumber/merge (`normalizeFootnotes`), wikilink
canonicalisation to on-disk stems (`normalizeWikilinks`), infobox key sort,
section order (`## See also` before `## References` last), `{{stub}}` guard
for thin articles (`articleThinness`), `title = H1 = stem`, fence repair.
Non-fatal per step. `normalizeVault` exists for a whole-vault pass but is not
a nightly stage; normalisation is constitutive of each write instead.

### 3.7 LINK (`crosslink.ts`)

Cross-linking is its own deterministic stage because synthesis is bounded to
one article and cannot know the others. (1) MENTION edges: wrap the first
whole-word mention of another article's title/alias as
`[[Stem|surface]]` — never inside an existing link, code span, marker,
infobox, heading, or References. (2) CO-OCCURRENCE edges from shared folded
chunks (`synthesized_chunk_sections` ⋈ `chunk_entities`). (3) Rebuild
`## See also` idempotently (mentions first, then top co-occurring articles
that exist). Every edit passes `normalizeWikilinks` + `gateEdit`; a fully
linked article re-runs to a byte-identical no-op. Measured on a 587-article
snapshot of the import (2026-06-28, M1 Max 32 GB): See-also coverage 18% →
96%, resolved edges 309 → 7026.

### 3.8 WIKIFY — the editorial pass (`wikify.ts`)

The periodic sweep, distinct from NORMALIZE: the model supplies judgment, the
gate disposes of weak judgment. As built, `runSynthesis` runs `wikifyVault`
over EVERY article every night after the write branch; each article commits
its own change or NO-OPs, and a wikify defect cannot lose the committed
create/patch work.

- Per-section IMPROVE (`improveSections`, `editor` stage): "tighten this
  section — remove redundancy, keep every citation and every specific
  detail." Behind the gate.
- Infobox EXTRACT/REFRESH (`refreshInfobox`): creates a missing infobox,
  refreshes present ones without losing a grounded fact, entity-valued
  fields as wikilinks, declared `aliases:` feed the entity index on reindex.
- Summary-style SPLIT (`detectSplitCandidate`, `applySplit`): when one body
  section dominates the article it becomes a child article with the full
  cited prose; the parent keeps a summary + `*Main article: [[Child]]*`
  (a `via=main` edge). Skips the word floor (a sanctioned bulk move); gated
  structurally instead. Series banner maintenance (`setSeriesBanner`).
- MERGE signals (`detectMergeCandidates`) and structure suggestions are
  written to `Talk/<stem>.md` (`writeTalkPage`) — the pass never
  restructures across articles on its own. `sectionCohesion` (an injected
  `EmbedFn` silhouette) exists here as an offline triage instrument only;
  `wikify.ts` never imports `src/embed.ts`.

### 3.9 Nightly run contract

- Trigger: launchd `com.mlx-bun.memory` (`schedule.ts`; `mlx-bun memory
  schedule --at HH:MM`, default 03:00), running `mlx-bun memory synthesize`;
  logs `~/.mlx-bun/logs/memory-synthesis.{out,err}.log`.
- Scope: only work past each stage's state (watermark / missing downstream
  row / ledger). A normal night is minutes, not hours; throughput only
  matters for the one-time import.
- Inference: one resident Gemma-4-e4b (§4); a stage's adapter is mounted iff
  `~/.cache/mlx-bun/adapters/memory-<stage>` exists, else base + policy.
- Every article change is a git commit; the run ends with a summary line.
- Never started by an agent: the full-corpus import and any GPU training are
  user actions.

## 4. The inference seam (`src/memory/model.ts`)

One shared runtime: one `RuntimeModel` (Gemma-4-e4b OptiQ-4bit, snapshot
resolved by globbing for `config.json`), the `memory-chunk` adapter mounted
once and ACTIVATED per call (`loraState.active`), one in-process
`BatchScheduler`. Two seams: `callLocal(stage, {system?, user})` (bit-exact
greedy via the eval runner's raw-forward decode) and `callLocalBatch(stage,
inputs[])` (order-preserving; batched only when `MLX_BUN_MEMORY_BATCH > 1`
and N > 1, else the same serial loop). Never auto-downloads; throws with the
`hf download` hint until the snapshot lands.

**Templating.** Each stage renders a `[system?, user]` message array through
the model's chat template exactly as the server and the trainer's
prompt-region render do (render with generation prompt → encode → dedupe a
double BOS; `memoryPromptIds`). This fixed the bring-up defect where the
chunk adapter — SFT'd with a system turn that Gemma-4 renders as a distinct
`<|turn>system…<turn|>` block — was decoded with the system segment dropped.
`tests/memory-templating.test.ts` asserts `memoryPromptIds("chunk", …)` is
id-identical to a real training row's prompt region. Base stages get concise
default systems (`DEFAULT_STAGE_SYSTEM`); only `chunk` must match training
byte-for-byte.

**Token budget.** `MAX_OUTPUT_TOKENS = 64_000` is the single backstop; stages
pass it rather than per-call caps, because a finished answer stops at EOS and
a cap can only truncate an unfinished one. (The per-stage 4/16/128/2048 caps
in the original inference-path design are superseded; `extractEntityNamesRaw`
still defaults to 128 when called directly.)

**Batching — implemented, off by default (decision: Josh, 2026-07-01).**
Measured 2026-06-28 on Gemma-4-e4b OptiQ-4bit, held-out
`chunk-data-le4000/valid.jsonl` + the live 2096-conversation store, M-series
GPU: 8 extract-style prompts (~400-token prefills) batched 9345 ms vs serial
5001 ms (≈1.9× slower, 8/8 exact); 8 short replies batched 2085 ms vs 1067 ms
(≈2× slower, 7/8 match — one documented near-tie divergence); only 16 short
uniform one-liners won (≈1.2× faster). The warm uniform chunk workload on the
M1 Max 32 GB measured 0.607 vs 0.357 s/chunk (~1.7× slower). Root cause: the
scheduler pads heterogeneous prefills to the batch max, losing to one
efficient single-sequence prefill per row. The real efficiency lever for
daily use is load-once (the shared runtime above; a persistent-server route
remains open, §9), not batching.

**Adapter constraint.** `loraState.active` is a single global field read per
forward, so a batch is necessarily single-adapter; `callLocalBatch` is
per-stage and stage→adapter is fixed. The seam must never be shared with a
live server process.

## 5. Target design: the BUCKET layer (settled with Josh 2026-07-01, not built)

**The Wikipedia-editor analogy.** A news story is reported seven times in a
day, each report carrying a little different information; an editor who
heard ALL of them incorporates everything into every article the story
affects. Conversations are the news shows, topics (chunks) are the stories,
and the **bucket is the editor's brain** — where everything reported TODAY
about THAT STORY accumulates before any article is touched.

**A bucket is keyed by the STORY, not by a subject.** Worked example: the
story "2026 Lincoln Memorial Reflecting Pool controversy" has no article of
its own and may never get one, but it affects three: *Lincoln Memorial
Reflecting Pool*, *Second presidency of Donald Trump*, *John J. Cafaro*. Each
receives the facet relevant to it. Bucket ≠ article is structural: articles
are THINGS, buckets are STORIES, story→things is many-to-many. Buckets are
emergent (never a predefined list) and short-lived relative to articles.

Target stage order:

```
SEGMENT → BUCKET → RESOLVE → SYNTHESIZE (delta-at-once) → RECONCILE → LINK → NORMALIZE → EDITORIAL
```

- **BUCKET** — group chunks by story: normalise/compare labels
  deterministically first, a binary "same story? yes/no" for near-misses, a
  new-bucket proposal for genuinely new stories. `_captured` remains the
  catch-all so nothing is dropped.
- **RESOLVE** — per non-empty bucket delta (all new chunks since the last
  run, TOGETHER): "which articles does this story affect?" Existing article →
  UPDATE (section-route the delta's facet for that article); missing →
  CREATE the subject article (a THING, never an article named after the
  story). The as-built entity-keyed ROUTE becomes RESOLVE.
- **SYNTHESIZE, one edit per (bucket, article)** — the cardinal rule. Never
  patch a section from one chunk and re-patch it from the next five minutes
  later: sequential single-chunk edits overwrite each other, churn
  citations, and produce patchwork prose. The delta arrives aggregated; the
  model rewrites one section once, weaving everything in, resolving
  contradictions within the delta toward the latest chunk. Edit mechanics
  stay as built (replacement section, code performs the write, same gate).
  Two buckets touching the SAME section of one article fold
  chronologically; the editorial pass smooths the seam.

As-built vs target, so nobody re-derives it:

| Target (2026-07-01) | As built (2026-08-23) |
| --- | --- |
| Story-keyed BUCKET stage between SEGMENT and article fan-out | No bucket stage; `buckets`/`chunk_buckets` hold only `_captured` |
| RESOLVE: bucket delta → affected articles | ROUTE: chunk-entity surfaces → articles (`route.ts`) |
| One edit per (bucket, article) per run | One PATCH per (chunk, section), chronological |
| RECONCILE every night over every article | RECONCILE over articles touched by this run's patches |
| EDITORIAL over touched articles (cadence open) | `wikifyVault` over every article every run |

## 6. The read path (design; user-facing details in `docs/reference/memory.md`)

The read path is deliberately trivial — all the acceptance pressure is on
the write side keeping each article a good, current account. FIND → READ →
ANSWER in small reads, never a context dump: find the one article (name /
alias / category / a `[[link]]` hop), open its TOC, read the ONE relevant
section, answer from the user's recorded position there. Silent-colleague
contract (ported from Lucien): look up before answering; each article is the
consolidated position, don't reconstruct from raw history; speak as a
continuation, never "per the wiki…".

- Tools (`src/memory/tools.ts`, registered by the shared pi surface for
  terminal and web, read-only, auto-allowed): `memory_resolve`,
  `memory_category`, `memory_read` (TOC + lead by default; full text only on
  request), `memory_section` (the default read), `memory_links`,
  `memory_infobox` (readable content, not a query), `memory_list`,
  `memory_status`, `memory_search` (last-resort substring fallback). There is
  deliberately no infobox-field query tool. mlx-bun's own docs are a
  separate `reference_*` surface, never mixed into personal memory.
- Navigation index (`src/memory/query.ts`): mtime-incremental in-memory maps
  (alias → stem, category/series/kind/type → stems, infobox, lead, link
  graph) mirroring the derived tables; zero embedding calls by contract.
- Exposure: tools and the bundled memory skill appear only when the vault
  exists; `memoryIndexHint()` adds a one-line presence hint, never a title
  dump. Memory is for personal continuity, not weather, public facts, or
  ordinary coding tasks.
- Acceptance budget (the bar Lucien's traces failed at 33–150 KB per query,
  one 671-line blob read up to 42× in a query): mean context < 5 KB (8 KB
  hard ceiling), no single read > 2 KB, `getEmbedCounter() == 0`, local
  only, silent. Harness: `scripts/memory/eval-northstar.ts` over the frozen
  `scripts/memory/northstar-queries.json` (Q1–Q6; Q6 is the negative
  control), graded by `scripts/memory/judge-answer.ts`; traversal proof
  `scripts/memory/north-star-traversal.ts`.

## 7. Adapters and training

One base model for every stage. Per-stage adapters are product assets (the
creator trains them, publishes to Hugging Face, `memory init` may offer to
download); they never get write authority — they produce candidates, the
gates decide.

| stage string | task | adapter |
| --- | --- | --- |
| `chunk` | one conversation → single-topic chunks + labels | **`memory-chunk` = `e4b-chunk-300` (exists, the only trained adapter)** |
| `entity` | one chunk → the things it is about | base + `Entities.md` (`memory-entity` only on a measured recall miss) |
| `route` | binary "same thing?" / "engages as subject?" | base |
| `section` | binary "does this chunk update THIS section?" / name a new one | base (`memory-section` only if the binary misfires) |
| `synthesis` | draft one section / integrate one chunk into one section / reconcile | base (`memory-synthesis` is the highest-value adapter to train) |
| `editor` | tighten one section / refresh an infobox / summarise a split | base (`memory-editor` if base misfires) |

Staged LoRA decision, per stage: measure the base + inlined policy on the
stage's own judge first; train only on a measured miss; pick checkpoints by
the task judge, never validation loss. Recipe: `scripts/examples/chunk-finetune.ts`
(sft, rank 16, lr 1e-5, seq 8192, `ops.sdpa`; e4b needs the segmented-backward
path — `SEG=2` as `e4b-chunk-300` was trained; see
`docs/design/segmented-backward-training.md`). Training data uses the
trainer's `messages` row shape with loss masked to the assistant turn.
Section-granular synthesis gold can be mined from Lucien's structured tables
plus `~/Dreaming` git history (chunk identity from `chunks`/`chunk_buckets`/
`synthesized_bucket_chunks`, section before/after from integration commits) —
never from footnote parsing. All training is a user action.

Recorded chunk-adapter numbers (`reports/orpo-chunk-paper/research-journal.md`,
via `scripts/examples/chunk-eval.ts`): `e4b-chunk-300` purity 92.2 /
cohesion 87.8 vs base e4b 99.5 / 58.8; the e4b metric is purity × cohesion.
The chunk eval score is well-formedness, not accuracy — see the memory note
"chunk-eval 95.10 = format, not accuracy".

## 8. Evaluation methodology (beside the system)

- **Lucien bucket-gold is NOT the write-path oracle.** Its 379-bucket /
  385-article topic-bin taxonomy (245 `X_and_Y` bins, 0 infoboxes) is
  exactly what this pipeline replaces; bucket-F1 / Jaccard against it are
  routing-instrument numbers, never a pipeline-health gate.
- **Cloud LLM-judge on real output + hand-curated gold.** Quality is judged
  by a strong cloud model reading END articles (the article the user reads
  next morning, after every stage has run — not intermediate drafts), against
  `goldens/dreaming-entities-gold.json` (hand-curated variant groups and
  notable entities, grounded by reading `~/Dreaming` and live chunks; NOT
  derived from bucket-gold). The judge is never in the hot path.
- **Metrics that mean something:** topic aggregation (many conversations →
  one article), coverage (0 engaged-with things lost even as article count
  drops), structural invariants (title is a thing, infobox present and
  resolvable, footnote bijection, every claim cited), gate pass-rate, and
  the read-path byte/embedding budgets. Do not measure articles per
  conversation — there is no conv→article link.
- **Embeddings as instruments only.** They measure cohesion/dispersion well
  (silhouette ρ≈0.68 vs the LLM judges, per-conversation) and purity poorly
  (ρ≈0.32) — so purity rides on the chunker, never on cosine geometry. The
  P4 label-proxy routing measured a pessimistic ~39% recall@12 on chunk
  labels, which is why ENTITY-EXTRACT reads full chunk text.

Instruments, all under `scripts/memory/` (moved 2026-08-23; Lucien read-only
throughout):

| script | what it measures |
| --- | --- |
| `bucket-cohesion-signal.ts` | embedding shortlist recall ceiling chunk→bucket, per bucket-size bin (the bucketing-stage foundation check) |
| `chunk-embedding-signal.ts` · `chunk-judge-correlate.ts` | boundary-local embedding features vs the two LLM chunk judges |
| `eval-name-recall.ts` · `dreaming-lex.ts` | lexical (trigram + token-overlap) shortlist recall over names, no model |
| `eval-route.ts` | no-vector routing proof; `--phase embed` and `--phase route` run as separate processes so the embedder and e4b are never co-resident |
| `eval-entity-extract.ts` | precision/recall/F1 + canonicalisation rate for ENTITY-EXTRACT |
| `eval-section-route.ts` | per-pair accuracy + section-set Jaccard on frozen proxy gold; new-section-not-drop |
| `eval-patch.ts` | only-that-section-changed + self-healing scenarios, judged on output |
| `eval-wikify-split.ts` · `p8-judge-wikify.ts` · `wikify-smoke.ts` | split/series/merge/Talk mechanics; cloud-judge fixture for improve-not-degrade |
| `audit-bootstrap.ts` · `eval-coverage.ts` | structural audit of a bootstrap; migration parity against the notable-entity gold |
| `north-star-traversal.ts` · `eval-northstar.ts` · `judge-answer.ts` · `northstar-queries.json` | read-path proof, acceptance harness, grader |
| `segment-smoke.ts` · `dreaming-create-smoke.ts` · `dreaming-coldstart-smoke.ts` · `dreaming-stages-independent.ts` | wiring smokes (real adapter; one entity; whole DAG; stage independence, model-free) |
| `dreaming-selfheal-demo.ts` | the timestamp-ordered self-healing demonstration |
| `dreaming-full-run.ts` · `dreaming-slice-select.ts` · `dreaming-slice-run.ts` · `dreaming-slice-inventory.ts` · `dreaming-chunk-diag.ts` | the resumable full-corpus import driver (user-launched, writes `~/.mlx-bun/wiki-full`, cursor `~/.mlx-bun/full-run-cursor.txt`) and its slice tools |
| `mine-gold-entities.ts` | the frozen entity vocabulary (`goldens/entities.json`) from `~/Dreaming` titles/lead bolds/bucket names |
| `eval-pi-memory-fixation.ts` | the pi surface exposes memory only when enabled and names the negative cases |

**Contradiction with the no-embeddings principle, recorded rather than
hidden:** `wikify.ts sectionCohesion` (injected `EmbedFn`), the
`bucket-cohesion-signal` / `chunk-embedding-signal` / `chunk-judge-correlate`
scripts and `eval-route.ts --phase embed` still use an embedder. None of them
is on the pipeline or read path (`src/memory/` never imports `src/embed.ts`;
the tripwire asserts 0). The design rule as settled 2026-07-01 says "no
embeddings anywhere in the project"; the code keeps them as offline
instruments. Deleting them is an open decision (§9), not a silent rewrite.

## 9. Open work (verified against `src/memory/` 2026-08-23)

Ordered. None of it touches the user's real vault (`~/.mlx-bun/wiki`) without
the promotion step.

1. **Wire ingest into the nightly run.** `ingestSessions` has no caller
   outside tests; `runSynthesis` assumes the corpus is already in the store.
   Without this the launchd job cannot fold in new pi sessions. Sequence:
   ingest → the existing DAG; watermark per source already exists.
2. **Bucket layer** (§5): story-keyed BUCKET stage, RESOLVE, delta-at-once
   synthesis replacing the per-chunk patch loop (not wrapping it). The
   `buckets`/`chunk_buckets` tables already exist.
3. **Nightly DAG order**: RECONCILE over every article (today: touched
   stems only) and a single NORMALIZE/EDITORIAL closing pass in the settled
   order.
4. **Persistent-server inference routing**: route memory generation through
   the resident server when one is running (load-once for daily use), with
   the in-process runtime as the no-server fallback. Batching is not the
   lever (§4).
5. **Chunk user-turn drift**: `CHUNK_PROMPT` still differs from the trained
   user turn (an added no-copy line; 2 inlined Meta pages vs 8 in training;
   abstracted label examples; the training vault-path line). Either
   reconcile the prompt to training or retrain `e4b-chunk-300` on the live
   prompt — pick one, don't stay half-aligned. Re-segmenting conversations
   chunked under the old user-only template is principled but low-urgency
   (old output was valid in-range).
6. **Promote + schedule**: after the import (`~/.mlx-bun/wiki-full`) is
   judged good on a broad, diverse cloud-judged sample — `reindex`,
   `mlx-bun memory link`, browse in Obsidian — point `~/.mlx-bun/wiki` at
   it and enable the nightly job. The `Reference/` symlinks into the repo
   are non-portable; drop them for the real personal vault.
7. **Known quality fixes**: schematic-prompt leaks (<1% of articles), run-on
   leads, `owned:` framing on abstract concepts (reframe the lead spec per
   subject kind), and stale in-code comments that still describe the dead
   "≥3 chunks or owned/decided" CREATE rule (`synthesize.ts` header;
   `prompts.ts` M1 stub constants) — the live rule is
   `RECURRENCE_THRESHOLD = 2` in `route.ts`.
8. **Per-stage adapters** (§7), each a user-launched training run gated on a
   measured base miss: `memory-synthesis` first (RECONCILE logs
   "UNRESOLVED … a memory-synthesis LoRA would close it" when the base model
   leaves a stale present-tense assertion), then section, entity, editor.
   Prerequisite: give `chunk-finetune.ts` a `TASK` selector defaulting
   DATA/ADAPTER per stage and an e4b (not MiniCPM5) default model.
9. **Embedding residue** (§8): decide whether `sectionCohesion` and the
   embedding signal scripts stay as instruments or go.
10. **Jobs-runner integration**: move `memory synthesize` onto the jobs
    runner with SSE progress once manual synthesis is boring.

## 10. Decisions overridden (explicit, so no agent re-derives them)

| Earlier statement | Superseded by |
| --- | --- |
| Personal-notability checklist; CREATE gate "≥3 chunks OR owned/decided, else PARK as trivia"; ≤40-article first-run cap (master plan P1-T5, P5-T4, R5, P9-T3) | **No notability filter.** Everything surfaces; `_captured` keeps the tail searchable; recurrence (2 chunks) or subject engagement earns an article; thin subjects → stubs. |
| Buckets demoted to "optional staging, may ship empty" (master plan L4, write-pipeline-entity) | **Buckets are first-class** story-keyed accumulators between chunks and articles (§5). |
| Embeddings as routing narrower / offline instruments (bucketing-stage, memory-synthesis section-routing, master plan P4/P8-T4) | **No embeddings in the pipeline**; the tripwire is permanent. Residual instruments are catalogued in §8 pending deletion. |
| Routing / section-route acceptance gated on Lucien bucket-F1 / Jaccard (P4-T2, P7-T1) | Model-selection evals live outside the design; pipeline health is judged on real END output by a cloud judge, never Lucien's bin taxonomy. |
| Cross-linking + infobox work assigned to periodic WIKIFY (P8) | LINK and RECONCILE are nightly stages; wikify is the readability pass. |
| Whole-article synthesis (Lucien `synthesize-update`) and per-chunk sequential patches (as built) | One replacement section per (bucket, article) per run, code performs the write (§5). |
| Per-stage `maxTokens` caps 4/16/128/2048 (inference-path design) | One `MAX_OUTPUT_TOKENS` backstop; never cap below it. |
| Batching as the import throughput lever | Measured slower for the real workload; default serial; load-once is the lever. |
| Turso / vector-capable store evaluation | Moot without embeddings; bun:sqlite stays. |

## 11. Open questions

- **When does a `_captured` chunk graduate?** Re-scan `_captured` nightly for
  subjects that have since accumulated related chunks, or only when a new
  bucket's name matches? (Today: promotion happens when ROUTE recomputes and
  the subject recurs.)
- **Editorial cadence.** Every night over every article (as built), or
  touched articles nightly plus a slower full-vault sweep?
- **Provisional / temporal facts.** A convention (e.g. "as of YYYY-MM" tied
  to the citation date) so "work set to begin July" updates cleanly to
  "began / completed" rather than contradicting.
- **Domain vs specific granularity.** ENTITY-EXTRACT emits both; the
  summary-style split decides what becomes its own page. Is that enough?
- **Bootstrap on a stronger model?** Is first creation good enough locally,
  or is the one-time import the one place a stronger model earns its cost?

## History

- 2026-06-19 — M0 landed: vault, read tools, CLI, launchd scheduling
  (`memory-system.md`); synthesis a safe no-op stub.
- 2026-06-26 — M1 design (`memory-synthesis.md`): pointer DB, create/update
  split, wikify as its own node; bucketing decomposition
  (`bucketing-stage.md`); entity-keyed routing (`write-pipeline-entity.md`).
- 2026-06-28 — Pipeline built end-to-end on real data; stage workers,
  chronological order, self-healing, LINK stage, templating fix; batching
  measured and shelved (`memory-inference-path.md`); full import resumed
  from 720/2096 into `~/.mlx-bun/wiki-full`.
- 2026-07-01 — Settled with Josh: no notability filter, no embeddings,
  buckets are stories, one edit per (bucket, article), replacement-section
  edit mechanics; `MLX_BUN_MEMORY_BATCH` default 1. This doc became
  canonical.
- 2026-08-23 — Consolidated the source docs into this one; scripts moved to
  `scripts/memory/`; every code claim re-verified; ingest-not-wired and
  embedding-residue contradictions recorded.
