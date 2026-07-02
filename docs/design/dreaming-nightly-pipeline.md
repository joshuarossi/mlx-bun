# The Dreaming — nightly memory pipeline (CANONICAL design)

Status: **canonical**, 2026-07-01. This document states the system design as
settled with Josh and **supersedes any conflicting statement** in
[the-dreaming-master-plan.md](./the-dreaming-master-plan.md) (task breakdown still
useful; several decisions overridden below),
[memory-synthesis.md](./memory-synthesis.md) (superseded), and
[the-dreaming-handoff.md](./the-dreaming-handoff.md) (session log, mostly aligned).

The system is the second iteration of Lucien's memory pipeline, rebuilt to run
**entirely on local models** inside mlx-bun (`src/memory/`). Same methodology and
pipeline at the core; the local constraint drives two design consequences:

1. **Small tasks.** Every AI step is decomposed to the smallest single-purpose
   unit a small local model can do well — one chunk, one bucket, one section,
   ideally a binary judgment. Never a whole-article blob in or out.
   **And every AI step is pure text-in/text-out — no tool calls, no agent
   loop.** The model never edits a file, never searches, never decides what to
   do next; the pipeline hands it exactly the context it needs and applies its
   output deterministically. This lowers the capability bar dramatically: a
   small model that could never drive an agentic edit session can absolutely
   rewrite one section given the section and the new information — and pure
   completion tasks are exactly what per-stage LoRA SFT trains well.
2. **Deterministic gates between AI steps.** AI does judgment; deterministic
   code enforces invariants (citations, footnotes, wikilinks, infobox shape,
   word floors). A weak AI output is gated to NO-OP, never allowed to corrupt
   the vault.

## Fixed principles (do not re-derive, do not contradict)

- **Conversations are the base.** The pipeline's only input is conversation
  transcripts (pi sessions daily; historical imports are a one-time onboarding
  path through the same code).
- **No notability filter.** *"If I talk about it, it's notable."* Everything
  surfaces; nothing is dropped or parked as trivia. Any prior "owned/decided/≥3
  chunks else PARK" gate is dead — the catch-all bucket exists only so that
  low-volume topics remain searchable until they warrant their own article.
- **No embeddings, anywhere in the project.** Not for routing, not for
  clustering, not as "offline instruments." Grouping and routing are done by
  deterministic name/alias/category lookup plus small local-model judgments.
- **Articles are real single-topic wiki articles with sections** — one subject
  per article, a lead, an infobox, `##` sections, See also, References. All
  subject mentions are `[[wikilinks]]`.
- **Vault = truth, DB = derived cache.** Markdown in the vault is canonical and
  git-tracked; the SQLite store is pipeline state + rebuildable index
  (`reindex`).
- **Self-healing through ordinary use.** Corrections arrive as ordinary chunks;
  chronological processing (`updated_at ASC`) resolves claims toward the user's
  latest position.
- **Prompts and Meta pages are SCHEMATIC** (no real names/specs/dates) — the
  small model parrots concrete example values into unrelated articles.
- **Runs nightly**, locally, unattended (launchd, `src/memory/schedule.ts`).
- **Model evals are not part of this design.** The eval harnesses (chunk-eval,
  judges, F1/Jaccard gates, cloud-judge sampling) are tooling for *choosing and
  training the models used by* the pipeline. They live beside the system, never
  inside it, and belong in their own docs.

## The pipeline

```
conversations                                    (ingest, watermark/cursor-gated)
     │
     ▼  SEGMENT ──────────────── AI: find the topics in each conversation
  chunks: single-topic segments with labels (pointer ranges, no text copies)
     │
     ▼  BUCKET ───────────────── AI + deterministic: group similar topics
  buckets: one per STORY/TOPIC; everything discussed about that topic since the
  last run accumulates here (a bucket usually has NO article of its own)
     │
     ▼  RESOLVE ──────────────── which articles does each story affect?
  bucket delta → the subject articles it touches (update · create · sections)
     │
     ▼  SYNTHESIZE ───────────── AI: per-section create/patch, bounded in and out
  create: outline → per-section draft · update: patch one section, rest byte-identical
     │
     ▼  ── deterministic gates ── citation survival · footnote bijection ·
     │     word floor · wikilink resolution · weak output → NO-OP
     │
     ▼  RECONCILE ────────────── infobox = ground truth; lead/body/infobox agree
     ▼  LINK ─────────────────── cross-link: mentions → [[links]], co-occurrence → See also
     ▼  NORMALIZE ────────────── deterministic: footnote renumber, wikilink canonicalize,
     │                           structure guards (References last, stub marking)
     ▼  EDITORIAL (wikify) ───── AI: remove redundancy, organize, make it read well —
     │                           per-section improve + structural pass over the TOC
     ▼
  commit to vault (git) + run changelog
```

Every stage is an independent, resumable, DB-state-keyed worker
(`src/memory/stages.ts`), runnable separately or as the full DAG
(`mlx-bun memory synthesize`).

### SEGMENT — conversations → topics

The e4b chunk adapter (`e4b-chunk-300`, symlinked `memory-chunk`) segments each
conversation into single-topic chunks with short labels. One chunk = one
coherent topic; a multi-stage process is ONE topic; long single-topic
conversations stay whole. Chunks are pointer ranges over `messages` — text is
materialized exactly once. Deterministic anchor repair validates every boundary.

### BUCKET — group similar topics (first-class stage)

**The Wikipedia-editor analogy (this is the model — Josh's framing).** A news
story gets reported seven times in a day — Fox says one thing, MSNBC another,
CBS a third, each report carrying a bit of different information. A Wikipedia
editor who heard ALL of the reports incorporates everything they learned into
every article the story affects. In our system: the news shows are
**conversations**, the stories are **topics (chunks)**, and the **bucket is the
editor's brain** — the place where everything reported TODAY about THAT TOPIC
accumulates before any article is touched.

**A bucket is keyed by the STORY/TOPIC, not by a subject.** The worked example:
the topic is *"2026 Lincoln Memorial Reflecting Pool controversy"* (the algae
issue in the pool that Trump renovated). Every report about it that day goes in
that one bucket. There is **no article for that topic** — and there may never
be — but the story affects THREE articles: *Lincoln Memorial Reflecting Pool*,
*Second presidency of Donald Trump*, and *John J. Cafaro*. Each article
receives the facet of the delta relevant to it (renovation/algae facts vs.
abuse-of-power framing vs. the contract angle). This is why bucket ≠ article is
**structural**: articles are THINGS (subjects); buckets are STORIES (what got
discussed); the story→things relationship is inherently many-to-many.

Assignment mechanics: group chunks by topic — normalize/compare chunk labels
deterministically first, with a small-model binary judgment ("are these two
chunks about the same story? yes/no") for near-misses, and a new-bucket
proposal for genuinely new topics. The taxonomy is emergent: buckets come into
existence because the user talked about something, never from a predefined
list. Buckets are naturally short-lived relative to articles — a story
accumulates while it's live and goes quiet when the user stops discussing it;
the articles it fed persist.

`_captured` is the reserved catch-all bucket: chunks whose subject doesn't yet
justify assignment stay there, searchable, and are revisited on later runs —
**nothing is dropped**.

### RESOLVE — bucket deltas → articles/sections

The unit of work from here on is the **bucket delta**: all of a bucket's new
(un-synthesized) chunks since the last run, taken TOGETHER. For each non-empty
delta, RESOLVE answers the editor's question: **"which articles does this story
affect?"** (the Reflecting Pool story → the pool article, the presidency
article, the contractor article). For each affected subject:

- **The article exists** → UPDATE. Section-route the delta's *facet for that
  article* via binary per-section judgments over the TOC ("does this new
  information update THIS section? yes/no"); all-no → propose a new section.
- **The article doesn't exist yet** → CREATE the subject article (a THING —
  never an article named after the story itself). Thin is fine — 2–3 chunks
  make a legitimate stub (stubs are a feature, not a failure).

The per-section ledger (`synthesized_chunk_sections`) records which chunks each
fold incorporated, making every fold idempotent and every claim traceable to
its source chunks.

### SYNTHESIZE — one edit per (bucket, article), never chunk-at-a-time

**The cardinal rule:** synthesis is the editor sitting down ONCE per article
with everything the bucket learned. Never patch a section from one chunk and
then re-patch it from the next chunk five minutes later — sequential
single-chunk edits overwrite each other, churn citations, and produce
patchwork prose. The whole point of the bucket layer is that the delta arrives
at the article **already aggregated**.

- **CREATE**: group the bucket's chunks into proto-sections (by label/subject
  affinity — small-model judgment, no embeddings) → outline (title, lead,
  section names) → draft each section from only its chunks. The model never
  holds a whole article in its head.
- **UPDATE (patch)**: hand the model one section + the delta's facet relevant
  to that article and section (all of it, with per-conversation `[^N]` citation
  material); it rewrites that one section once, weaving everything in. Facet
  extraction is implicit: the same story becomes algae/renovation facts in the
  Reflecting Pool article and framing in the presidency article, because the
  model writes what's relevant to the section it's editing.
  Contradiction = correction: resolve toward the latest statement, including
  contradictions *within* the delta (latest chunk wins — the editor heard all
  seven reports and writes the reconciled version, not seven amendments).
  User's evolving positions keep a `## History` trace; AI factual errors are
  silently overwritten.
- **Edit mechanics (SETTLED 2026-07-01, Josh-confirmed — and how Lucien always
  worked): the model never edits the article; it is handed the current section
  + the new information and outputs a complete REPLACEMENT SECTION.** Not an
  in-place file edit (the
  model would have to hold the whole article — the exact blob failure this
  design avoids) and not a diff (small local models produce brittle patch
  formats, and a diff is hard to gate). A full replacement section is bounded
  in and out, trivially appliable (`extractSection` swap — the rest of the file
  byte-identical by construction), and directly gateable: the gate compares old
  section vs. new section for word floor and citation survival. Deterministic
  code performs the actual write. CREATE works the same way — the model emits
  one section at a time; code assembles the article.
- **Multiple buckets converging on one article** (the algae-controversy bucket
  AND the olympian-arrest bucket both affect *Reflecting Pool*): each bucket's
  facet folds as its own section-level edit within the run — different stories
  usually land in different sections. If two buckets touch the SAME section,
  fold chronologically (latest wins, per self-healing) and let the nightly
  EDITORIAL pass smooth the seam; the editorial pass runs after all folds, so
  the article the user reads next morning is one coherent account.
- **Conservative write gate** on every output: ≥70% word floor on the touched
  section, every pre-existing `conv:` citation survives, H1/References survive,
  footnote bijection. Weak output → NO-OP; the delta retries next run.

### RECONCILE · LINK · NORMALIZE — nightly deterministic/structural stages

These run **every night**, not periodically:

- **RECONCILE** (`reconcile.ts`): the infobox is the article's ground truth;
  lead, body sections, and infobox must agree; date-aware (latest wins).
  Infobox extraction/refresh is part of this — every article carries a current,
  parseable infobox whose entity-valued fields are `[[wikilinks]]`.
- **LINK** (`crosslink.ts`): cross-linking is a dedicated stage, NOT
  synthesis's job (synthesis sees one article and cannot know the others).
  Mention-based prose links + co-occurrence See-also. Idempotent. Ensures **all
  subjects are wikilinked** across the vault.
- **NORMALIZE** (`normalize.ts`): pure code — footnote renumber/merge, wikilink
  canonicalization, orphan repair, structure guards (`## References` last,
  `{{stub}}`/`{{Main}}` recognition, title == H1 == stem).

### EDITORIAL (wikify) — make the article good

The final AI pass, and the reason articles stay readable instead of accreting
patches: per-section "tighten this — remove redundancy, keep every citation and
every specific detail" plus a structural pass over the TOC (reorder sections,
refresh the lead, split a section that outgrew the article into its own article
with a `{{Main}}` summary, merge duplicate stubs). Behind the same conservative
gate; a weak edit is rejected and the original kept.

## Nightly run contract

- Trigger: launchd (`com.mlx-bun.memory`), logs under `~/.mlx-bun/logs/`.
- Scope: only conversations past the per-source watermark — a normal night is
  minutes of work, not hours.
- Inference: one resident base model (Gemma-4-e4b), per-stage adapter mounted
  iff `~/.cache/mlx-bun/adapters/memory-<stage>` exists, else base+policy.
  Route generation through the persistent server (load-once) when available;
  no-server fallback works but pays model load per invocation.
- Every article change is a git commit; the run ends with a changelog summary.
- Failure isolation: stages are resumable; a failed bucket/article never blocks
  the rest of the run.

## Decisions overridden from the master plan (explicit, so no agent re-derives them)

| Master-plan statement | Superseded by |
| --- | --- |
| Personal-notability checklist; CREATE gate "≥3 chunks OR owned/decided, else PARK as trivia"; ≤40-article first-run cap (P1-T5, P5-T4, R5, P9-T3) | **No notability filter.** Everything surfaces; `_captured` keeps the tail searchable; thin buckets → stubs. |
| Buckets demoted to "optional staging, may ship empty" (L4) | **Buckets are first-class**: the per-subject accumulation layer between chunks and articles; synthesis consumes buckets. |
| Embeddings allowed as offline instruments (P4 recall tripwire experiments, P8-T4 silhouette triage) | **No embeddings anywhere in the project.** The tripwire (`getEmbedCounter()==0`) remains as a guard, permanently. |
| Routing/section-route acceptance gated on Lucien bucket-F1 / Jaccard (P4-T2, P7-T1) | Model-selection evals live **outside** the system design; pipeline health is judged on real output quality, never Lucien's bin taxonomy. |
| Cross-linking + infobox work assigned to periodic WIKIFY (P8) | RECONCILE + LINK are **nightly stages** in the DAG; editorial wikify is the readability pass. |

## Work plan (docs-only reconciliation done; implementation next)

Ordered; none of it touches the running full-corpus import
(`~/.mlx-bun/wiki-full`, cursor file `~/.mlx-bun/full-run-cursor.txt`) or the
uncommitted `src/model/universal` / trainer work.

1. **Bucket layer made explicit** — a topic-keyed BUCKET stage between SEGMENT
   and the article fan-out (`buckets` + `chunk_buckets` tables already exist):
   group chunks by story (label normalization + binary "same story?"
   judgments), `_captured` catch-all, and **delta-at-once synthesis** — the run
   collects each bucket's new chunks, then makes ONE edit per (bucket, article).
   The as-built entity-keyed ROUTE becomes RESOLVE (bucket → affected subject
   articles); the per-chunk patch loop is replaced, not wrapped. (Settled
   2026-07-01 — the Wikipedia-editor / Reflecting-Pool framing above; buckets
   are STORIES, articles are THINGS, many-to-many by nature.)
2. **Nightly DAG order** — ensure `mlx-bun memory synthesize` runs
   segment → bucket → resolve → synthesize → reconcile → link → normalize →
   editorial every run (reconcile/link/infobox currently periodic/partial).
3. **Editorial stage** — wire the per-section improve + structural pass as the
   closing stage behind the conservative gate.
4. **Persistent-server inference routing** — load-once for all memory
   generation, no-server fallback (the in-progress inference-path rework;
   finish, don't fork).
5. **Promote + schedule** — after the import is judged good: point
   `~/.mlx-bun/wiki` at the bootstrapped content, enable the nightly launchd
   fold-in from pi sessions.
6. **Known quality fixes** — schematic-prompt leaks (<1% of articles), run-on
   leads, `owned:` framing on abstract concepts (reframe the lead spec per
   subject kind).

## Open questions (for discussion with Josh)

- ~~Bucket granularity vs article granularity~~ — **SETTLED 2026-07-01**:
  buckets are a separate layer from articles (many-to-many both ways); the
  bucket is the editor's brain that aggregates the day's information about a
  subject, and RESOLVE fans the delta out to every affected article. Bucket is
  never a 1:1 alias for an article.
- **When does a `_captured` chunk graduate?** Re-scan `_captured` every night
  for subjects that have since accumulated enough related chunks, or only when
  a new bucket's name matches?
- **Editorial cadence.** Every night over every touched article, or touched
  articles nightly + a slower full-vault sweep?
