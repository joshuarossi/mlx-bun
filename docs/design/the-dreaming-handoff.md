# THE DREAMING — HANDOFF (2026-06-28)

Live handoff for the local personal-wiki memory system (`src/memory/`). A fresh
session can resume from this doc. **Companion docs:** `research-journal.md` (dated
findings), `docs/design/memory-inference-path.md` (the in-progress templating/batching
rework), and the per-phase `p*-judge.md` reports.

---

## TL;DR — where we are

The Dreaming turns conversations → chunks → entities → **subject articles** →
cross-linked, self-healing personal wiki. It **works end-to-end on real data.**

- **Full-corpus import RESUMED from cursor 720/2096** into `~/.mlx-bun/wiki-full`, on the
  corrected templating, batching off (serial, ~50h).
- **Committed + merged to `main`** (the Dreaming pipeline + inference-path rework). tsc 0.
- Templating fix **VERIFIED live** on real convs (bare prompt + a 40-msg conv → valid chunks).

## Resume the import
```
# resumable driver; continues from cursor 720. Writes to ~/.mlx-bun/wiki-full (NOT the
# real vault ~/.mlx-bun/wiki). ~25 min / 20-conv batch, ~50h total, SERIAL.
bun scripts/experiments/dreaming-full-run.ts          # resume (clean-slate guarded by an init flag)
# state files: ~/.mlx-bun/full-run-cursor.txt, ~/.mlx-bun/full-run-initialized, ~/.mlx-bun/full-run.log
# after the import finishes: reindex, then connect the graph:
mlx-bun memory link
```
**Gotcha:** background bash + detached processes get **reaped across turns** in this
harness. Drive long GPU runs as foreground bounded batches, or `nohup … & disown` (still
iffy). The pipeline is resumable, so just re-launch to continue.

---

## Architecture (as-built, after this session's corrections)

**Staged, chronological, resumable pipeline** (`src/memory/stages.ts`). Each stage is an
independent DB-state-keyed worker, ordered `updated_at ASC` (chronological), resumable
(skips done work). CLI: `mlx-bun memory segment|extract|route|synthesize-stage|link` (run
separately/concurrently) — and `mlx-bun memory synthesize` runs the full DAG.

```
ingest → SEGMENT (our e4b-chunk-300 chunker) → EXTRACT (entities) → ROUTE (subject-based,
surface-everything) → CREATE/PATCH (per-section bounded synthesis; self-healing) →
RECONCILE (infobox-ground-truth consistency) → LINK (cross-link) → WIKIFY (editorial) → commit
```

- **Vault = truth** (markdown files in `articles/`); **DB = derived cache** (`reindex`
  rebuilds it). The article FILES are the real artifacts. The `entities.article_stem`
  column being unset mid-run is cosmetic (file-presence is the source of truth).
- **Vaults:** `~/.mlx-bun/wiki` (the REAL vault — untouched), `~/.mlx-bun/wiki-full`
  (import target), `wiki-smoke|slice|pattern|pattern2|link-test` (scratch).
- **Model:** ONE base **Gemma-4-e4b** (`SNAPSHOT_E4B`). **Only ONE adapter trained so far:
  `e4b-chunk-300`** (the chunker), symlinked `~/.cache/mlx-bun/adapters/memory-chunk`.
  `callLocal(stage,…)` picks `memory-<stage>` adapter iff it exists, else base.
- **Lucien is a READ-ONLY oracle/data-source** (`~/Code/lucien/.lucien/lucien.db` opened
  readonly; `~/Dreaming`). We reuse NONE of its derived chunks/buckets — only the raw
  conversation text (≡ a JSONL export / scraper). Never write there.

---

## What we LEARNED / CORRECTED this session (load-bearing — don't re-derive)

1. **NO notability/ownership filter.** Surface everything; notable = "anything that recurs
   in your thinking" (Lucien `Editorial_Guidelines.md`). The plan's "owned/decided/≥3
   chunks → PARK as trivia" was **fabricated by a prior agent and ripped out.** ROUTE now:
   surface everything, strongly prefer an existing article, mint a new one only for a
   substantive/recurring subject, `_captured` bucket (searchable) for the rest — **nothing
   dropped.**
2. **Subject-based articles = the one deliberate improvement over Lucien** (which drifted
   into `X_and_Y` topic-bins). Verified: frameworks (Kaizen, TPS, LessWrong, Free energy
   principle) get good articles; coverage resolves (`resolve("Kaizen")` → article).
3. **Our chunker must be used.** The pipeline's `segment` was a no-op reusing Lucien's
   chunks; fixed — `e4b-chunk-300` segments the raw conversations (better, topic-coherent).
4. **Chronological ordering.** Was `ORDER BY id` (= conv UUID, random); fixed to
   `updated_at ASC` everywhere. Load-bearing for self-healing.
5. **Self-healing.** A later-dated correction flips the LEAD + INFOBOX + every body section
   to the latest value; KEEPS the trajectory in a `## History` section **only for the
   USER's evolving positions** — an AI *factual error* is silently overwritten (no
   history). Date-aware; `reconcile.ts` is the consistency authority (infobox = ground
   truth). Proven via a timestamp-swap demo (`scripts/experiments/dreaming-selfheal-demo.ts`).
6. **Parroting (recurred 5×).** The small model copies ANY concrete example value from
   prompts/Meta pages into unrelated articles (phantom S5IIX, "Anamorphic Video", etc.).
   **ALL prompts + Meta pages must be SCHEMATIC** (no real names/specs/dates). Purged;
   defensive strips added. Keep this rule for any new prompt.
7. **Cross-linking is WIKIFY's job, NOT synthesis** (synthesis updates ONE article, can't
   know others). Built a dedicated `link` stage (`crosslink.ts`): mention-based (prose
   names another article → `[[link]]`) + co-occurrence (shared folded chunks → See also).
   Result on a 587-article snapshot: See-also 18%→96%, resolved edges 309→**7026 (22.7×)**.
   Idempotent; fence-fix handles malformed input.
8. **Metrics.** Do NOT measure articles-per-conversation (there is no conv→article link).
   Measure **topic aggregation** (e.g. `El_Salvador` ← 30 conversations → 1 article).
   Quality is judged by a **CLOUD JUDGE on real output**, never Lucien bucket-F1 (that's the
   bin taxonomy we replace).
9. **Inference path (IN PROGRESS — see `docs/design/memory-inference-path.md`):**
   - **Template mismatch (fixed in working tree):** the chunk adapter was SFT'd with a
     **system role** (Gemma-4 renders `<|turn>system…<turn|>` distinctly), but inference
     dropped it (one user message). `callLocal` now passes `{system, user}` matching
     training; the chunk stage uses `CHUNK_SYSTEM` (its exact trained system prompt). Also
     noted: the live `CHUNK_PROMPT` drifted from training (only 2 of 8 Meta pages; abstracted
     examples) — adapter still generalizes, so quality delta is **modest**.
   - **Batching = DEAD END.** Measured ~**1.7× SLOWER** (warm, uniform: 0.607 vs 0.357
     s/chunk). The `BatchScheduler` pads heterogeneous prefills and doesn't amortize
     weight-loads. Default OFF (`MLX_BUN_MEMORY_BATCH=1`). Import is genuinely ~50h serial;
     batching is NOT the lever (a *better* batched-decode that amortizes weights could help
     in principle, but that's a real perf project, not worth it for a one-time import).
   - **Load-once / persistent server = the REAL efficiency win, for DAILY use.** Each CLI
     invocation today reloads the model + pays warmup; routing memory generation through the
     **resident server** (model loaded once) kills that. Within the single-process import
     the model is already loaded once, so it doesn't speed the import.

## Product framing (from the user)
- **Daily local conversations (pi sessions) folding in is the product** — watermark-gated
  ingest, minutes/day, self-healing. The 4-year Claude/ChatGPT import is a one-time
  **onboarding feature + stress test**. Throughput only matters for the import.

---

## NEXT STEPS (prioritized)

1. **Finish the inference-path rework.** Templating fix is in the working tree (verify it
   end-to-end). **Wire memory generation through the persistent server (load-once)** — the
   user's actual ask — keeping a no-server fallback; default batching OFF. Verify the chunk
   stage decodes on-distribution (system role present).
2. **Import is RUNNING** (resumed from 720, serial, corrected templating). Just let it finish.
   Re-segmenting the first 720 is **low-urgency** (old chunks were valid).
3. **After import:** `reindex` → `mlx-bun memory link` → browse `wiki-full` in Obsidian;
   cloud-judge a broad, diverse sample (not just frameworks/gear).
4. **Promote to the real vault** when satisfied: point `~/.mlx-bun/wiki` at the bootstrapped
   content; wire the **nightly daily fold-in** from pi sessions (`schedule.ts` exists).
5. **Open quality items** (low priority): ~<1% articles leak a prompt fragment; some leads
   run on; the `owned/used/chosen` framing in `Article_Conventions` lead spec can put
   `owned: yes` on abstract concepts (reframe).
6. **Commit when ready** — everything is uncommitted; the user has not asked to commit.

## Gotchas / facts
- `bunx tsc` sometimes can't resolve typescript in this checkout; use global `tsc`. Repo = 0 errors.
- The `mlx-bun train-watch orpo-e4b-chunk` process is a **stale idle daemon, not training** — GPU is free.
- e4b training still OOMs on this 32GB M1 Max; P10 adapter training stays USER-ACTION (segmented-backward).
- The `Reference/` folder in vaults symlinks the mlx-bun repo docs (`setupVault`) — non-portable; fine for now, drop for the real personal vault.
- Methodology memories: cloud-judge not bucket-F1; Lucien read-only; surface-everything notability.
