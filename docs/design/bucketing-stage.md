# Bucketing / Classify stage — local build plan

Status: **design**, 2026-06-26. Companion to [memory-synthesis.md](./memory-synthesis.md).
Grounded in a research+critique workflow over the real Lucien classify + the local
foundation; re-centered on the governing principle below.

## Governing principle — capacity by decomposition

**A small local model's effective capacity scales inversely with task size. You don't
make the model smarter; you make each task narrower.** Every stage is a *ladder of
atomic, single-purpose tasks*, each one a single clear question. The full pipeline:

```
"what buckets should we have?"        ← taxonomy (cold-start)
"which buckets need this chunk?"      ← classify / assignment
"which section needs this info?"      ← section routing
"integrate THIS chunk into THIS section"  ← synthesis patch (most atomic)
```

…and each rung decomposes *further* into the smallest decisive question. We never ask
the local model to "assign a chunk among 12 buckets and emit JSON" — that is still too
big. We ask **"does this chunk belong in bucket B? yes/no,"** one bucket at a time.

**Retrieval (embeddings, lexical) exists only to NARROW the candidate set so the model
makes the fewest, smallest, clearest calls. It never decides — the model decides, one
tiny question at a time.** This is the production home for the embedding work: a
candidate-narrower, not a classifier.

**Why brute-force decomposition is affordable: the model is LOCAL, so inference is ~free.**
A cloud model forces you to minimize calls (which is exactly why Lucien made one big
"reason over everything" call). A local model flips the economics — you can run **M×N tiny
binary checks** ("does chunk *i* belong in bucket *j*?" / "should chunk *i* update section
*j*?") where a cloud model would have to make one expensive combined decision. We trade one
big unreliable call for many tiny reliable ones. Local-ness is what makes radical
decomposition viable; retrieval just keeps M×N from getting silly.

This is adapting + improving Lucien, not duplicating it. Lucien put all 379 buckets in
Opus's context and let it reason globally in one shot — a capability a 1B model does not
have. We replace "one global decision" with "many tiny local decisions."

## What we keep from Lucien

- Classify on chunk **labels** (~49-char topic strings), not text or vectors.
- The `Bucketing.md` policy governs behavior, inlined into the task prompt — editing it
  re-tunes routing with no code change.
- **Many-to-many** (a chunk → 0..3 buckets; empty is legal = the substance filter).
- **Create buckets by judgment** when nothing fits and the topic is substantive.
- **Existing-buckets-win** (re-scoped to global below — fix E).
- Idempotent set-difference resumption (`NOT IN chunk_buckets`).

## The bucketing stage, decomposed

### "which buckets need this chunk?" — assignment

For one chunk (its label):
1. **Narrow (no model):** embedding shortlist — cosine(label, bucket centroid) → top-K
   candidates; PLUS a **lexical floor** (any bucket whose name token-overlaps the label)
   so an embedding miss can't drop an obvious match [fix C].
2. **Decide (atomic model task, one per candidate):** *"Does this chunk — `<label>` —
   belong in bucket `<name>: <description>`? Answer yes or no."* Run over the (few)
   shortlisted candidates. No multi-item JSON, no batch indices → the JSON-fidelity and
   batching failure modes (critique D) simply don't exist. A chunk can get "yes" on
   several candidates (many-to-many falls out naturally) or none.
3. **New bucket (atomic task, only if every candidate was "no" AND substantive):**
   *"This topic fits no existing bucket. Propose one Wikipedia-style bucket name (2–6
   words) + one-line description, or answer NONE if too thin."* Then the **global gate
   [fix E — the #1 correctness fix]:** re-embed the proposed name against the FULL bucket
   centroid cache; if the nearest existing bucket clears a similarity threshold, downgrade
   to it. This restores Lucien's "none of 379 fit" discipline that a shortlist-only view
   would break (→ taxonomy explosion).

Each model call is a tiny yes/no or a single short proposal — the clear single tasks a
1B model can do reliably. Cost is more calls, but each is fast and reliable; embeddings
keep K small so it's bounded.

### "what buckets should we have?" — cold-start taxonomy (from zero)

There are **7308 distinct labels of 7316** — dedup collapses nothing, and a 1B model
cannot globally compress thousands of labels into a coherent 30–60-bucket taxonomy
(that is exactly Opus's global-reasoning ability). Decompose:
1. **Group (geometry, no model):** embed all labels → k-means (k∈[30,60], pick by
   silhouette). The geometry does the grouping the model can't do globally.
2. **Purity-gate each group (atomic task) [fix B]:** *"Do these labels form ONE topic or
   more than one?"* k-means optimizes cohesion and is blind to fusion (the ρ≈0.32 purity
   blind spot we measured) — split any group the model flags before it becomes a bucket.
3. **Name each group (atomic task):** *"Here are ~15 representative labels. Give ONE
   Wikipedia-style bucket name (2–6 words) + a one-line description. Be specific, not
   generic."*
4. **Seed centroids from members [fix H]:** each new bucket's centroid = mean of the
   cluster labels that birthed it (those vectors already exist) — so the first assignment
   pass runs on strong member-based centroids, not weak name-only ones.

### later rungs (designed here, built after classify)

- **"which section needs this info?"** — the **M×N binary** pattern: for an article's
  assigned bucket of *M* chunks and its *N* TOC sections, ask *"should chunk i update
  section j? yes/no"* — M×N times. The "yes" pairs become atomic patches. A chunk that gets
  **all "no" and is substantive → an atomic CREATE-NEW-SECTION task** (mirrors new-bucket).
  (Embeddings can prune N, but with a local model you can also just run all M×N.)
- **"integrate THIS chunk into THIS section"** — the atomic synthesis patch (memory-synthesis.md),
  applied to each (chunk, section) "yes" pair.

### The entities (distinct — do not conflate)

- **chunk** — one topical segment of a conversation (pointer + label).
- **bucket** — a single-topic GROUP OF CHUNKS (the classify output; the "Cameras and
  Camera Gear" container you drop camera chunks into). **A bucket is NOT an article.**
- **article** — a synthesized wiki page. A bucket RELATES TO **one or more** articles
  (many-to-many): the reflecting-pool-renovation bucket relates to the *Lincoln Memorial
  Reflecting Pool* article AND a *Trump* article.
- **section** — a part of an article (its TOC entries).

### Hierarchical pruning (coarse gates fine)

Decompose top-down and **prune the subtree at every "no."** The levels are distinct:
chunk → bucket → article(s) → section(s). The coarse gate is **"does this bucket relate to
this article? yes/no"** — if no, skip *every* section of that article (a bucket can't
relate to a section of an article it doesn't relate to). So the M×N section checks run
*only inside the few articles a bucket relates to*, never "× every section in the wiki."
Same idea recursively: each coarser binary check prunes the finer ones beneath it.
Retrieval narrows candidates *within* a level; pruning eliminates whole levels.

### The uniform growth rule (no-match → create)

At *every* rung, "no existing candidate matched" branches on substance, it does not just
drop: **substantive → CREATE, trivial → drop.** A chunk that fits no bucket → new bucket;
a bucket that relates to no existing article → new article; a chunk that fits no section of
a related article → new section. Only non-substantive trivia is filtered. So substantive
content always lands *somewhere* — this is how the taxonomy grows new buckets, the wiki
grows new articles, and articles grow new sections (the Wikipedia editor adds a page or a
section for a fact that fits nowhere). Each create is its own atomic task, gated against
the existing set (the new-bucket global gate, fix E).

## Data model (`src/memory/db.ts`)

Rewrite the copy-schema to the pointer design (memory-synthesis.md; no live data):
`messages` (text once, `(conv, position)`), `chunks` (pointers + `label`, no text),
`buckets` (writable), `chunk_buckets` (M:N — the classify output). `PRAGMA foreign_keys
= ON` + `ON DELETE CASCADE` (fixes Lucien's 368 orphan edges / 570 dangling pointers).
**Keep `synthesized_bucket_chunks` per-(bucket,chunk) [fix G]** — do not rename the
working ledger for the unbuilt section feature; `chunk_sections` may exist as a
future-proof empty table only.

## Eval — embeddings as the test instrument

`scripts/experiments/bucket-cohesion-signal.ts` (mirrors `chunk-embedding-signal.ts`):
- **[measure FIRST — the #1 risk] shortlist recall ceiling:** is each gold bucket in its
  chunk's embedding top-K? Report overall **and per bucket-size-bin** (122/379 buckets
  have <5 chunks — the global number hides tail collapse [fix C]). If low, the shortlist
  caps recall and must be re-tuned before building on it.
- **bucket cohesion / separation / subcluster-gap** baseline over the 379 cloud buckets.
- **purity (LLM judge)** on lowest-subcluster-gap buckets — embeddings can't grade purity
  (ρ≈0.32); confirm the asymmetry so the judge stays load-bearing.
- **decision accuracy:** since each task is binary, eval is per-(chunk,candidate-bucket)
  yes/no accuracy + per-chunk Jaccard vs the 8441 valid gold edges. Report **oracle-shortlist**
  F1 (force gold into candidates → pure model judgment) vs **real-shortlist** F1 (end-to-end);
  the gap is the retrieval tax. **The LoRA decision keys off the oracle F1 [fix F].**

## LoRA decision (staged)

- **Stage 0 — embedding-only:** top-K cosine + threshold vs the 8809 gold edges → F1/Jaccard.
  Might end it (classify could be embedding-shaped).
- **Stage 1 — base MiniCPM5-1B, prompt-only, binary tasks + shortlist:** measure oracle-F1,
  yes/no consistency. The binary framing is *much* easier for a small base model than JSON
  multi-assignment — Stage 1 may clear the bar with no LoRA precisely because the tasks are atomic.
- **Stage 2 — train `memory-bucket` LoRA, only if Stage 0/1 miss.** Data from lucien.db, one
  example per (chunk, candidate-bucket) binary decision (gold = belongs?), shortlist regime =
  serve regime. Recipe = `chunk-finetune.ts` (sft, rank 16, lr 1e-5, seq 8192,
  `MLX_BUN_PERF_KERNEL=0 MLX_BUN_FUSED_GELU=0`, no train-flash); adapter →
  `~/.cache/mlx-bun/adapters/memory-bucket`; pick checkpoints by the F1 judge, not val loss.
  **GPU-gated.**

## Build sequence

Runnable now (no GPU training, no server):
1. **[FIRST]** `bucket-cohesion-signal.ts` → shortlist recall ceiling (per size-bin) +
   cohesion/sep/subcluster baseline. Verifies the shortlist foundation before any build.
2. Rewrite `db.ts` to the pointer schema + `foreign_keys` + helpers; in-memory test.
3. Stage-0 embedding-only baseline (oracle + real F1).
4. Purity judge on lowest-subcluster-gap buckets; confirm the asymmetry.
5. Implement `cluster.ts` as **atomic tasks**: shortlist → per-candidate yes/no → new-bucket
   proposal + global gate; cold-start = cluster → purity-gate → name → member-seed.
6. Stage-1 eval (base, no adapter) → apply LoRA criteria.

GPU-gated (only if needed): 7. build binary SFT data · 8. train `memory-bucket` · 9. re-eval.
Integration: 10. wire `clusterChunks` into `pipeline.ts`.

**First command:** `bun scripts/experiments/bucket-cohesion-signal.ts`

## Open risks

- Shortlist recall ceiling (measure per size-bin first — step 1).
- More model calls per chunk (K binary vs 1 JSON) — bounded by K; each call is tiny/fast.
- Cold-start naming going generic — seed with distinctive labels + "specific not generic".
- Distilled labels ≠ ground truth — don't over-trust exact-match F1; use reference-free
  silhouette + purity on divergences.
