# Expert offload for single-user local MoE — findings + design sketch

*2026-06-14. Research spike. Question: can Apple's AFM-3 "flash-resident
experts" idea (Instruction-Following Pruning) be applied to the MoE models
we already run, to stop the inactive experts from squatting in RAM? Sources:
Apple AFM-3 blog + IFP (arXiv 2501.02086) + LLM-in-a-flash (2312.11514);
MoE-offload prior art (Mixtral-offloading 2312.17238, Fiddler 2402.07033,
KTransformers SOSP'25, llama.cpp `--n-cpu-moe`). Grounded against PLAN
Phase 6 (MoE bring-up, measured), Phase 8 (LoRA hot-swap, shipped),
Phase 14 (Qwen 35B-A3B fit-table line), Phase 18 (slots).*

---

## 0. TL;DR

A trained MoE already activates a tiny fraction of its weights per token, but
we currently hold **all** experts resident — measured at 14.09 GB of expert
pool to use ~0.9 GB/token on `gemma-4-26B-A4B` (PLAN Phase 6). Those cold
experts are read-only and rarely touched; the KV cache is hot, dirty, and
un-offloadable. The hardware is telling us which one goes to disk.

The catch with Apple's approach — it needs **task locality** (you can't swap
experts per token across the flash bus, only per prompt/period) — is the exact
property **single-user local AI gives us for free**: one human works on one
kind of thing for minutes-to-hours at a time. A multi-tenant server can't
promise that; a personal appliance can. So this is a feature that fits *our*
product identity specifically.

Two payoffs from one residency manager:
1. **Shrink a model that already fits**: 26B-A4B from ~16.4 GB resident →
   ~4–6 GB, returning ~10 GB to KV-context-length and to the user's other
   apps. (Today the 26B leaves ~0 GB for anything else — see §2.)
2. **Admit a model that doesn't fit**: e.g. a 35B-A3B class model on 24 GB,
   flipping PLAN Phase 14's "larger hardware only" line into "fits, with a
   domain-switch warm-up cost."

**What's already done (de-risks this a lot):** the MoE forward is bit-exact
today (Phase 6, `gather_qmm`, `tests/moe-ops.test.ts`). The missing piece is
*only* the memory-tiering layer — not a new architecture.

---

## 0.5 Empirical findings — the mechanism is de-risked (2026-06-14)

Two probes on the M4 Pro (`scripts/probe-expert-residency.ts`,
`scripts/probe-mmap-gather.ts`) turned the design from a sketch into a verified
mechanism. Three results:

1. **Disposing MLX *device* buffers does NOT reliably return RAM to the OS.**
   In the controlled case, allocating a 512 MB array and then calling
   `dispose()` *and* `clearCache()` moved `rss` not one byte; `cache_memory`
   read 0 throughout. So a **fixed device-buffer slot pool is the wrong
   mechanism** — it can hold *less*, but it can't give RAM *back* when idle,
   which is the whole point.
2. **The mmap clean-page path returns RAM to the OS deterministically.**
   `munmap` of a mapped region dropped `rss` by exactly the mapped size
   (−1 GB, and −2 GB at scale). This is the elastic-eviction substrate, and
   it's exactly what expert weights are: read-only files.
3. **The GPU gathers straight from a page-aligned mmap, bit-exact.** GPU
   `gather_qmm` reading a quantized expert directly from a 16 KB-page-aligned
   mmap (at a realistic non-zero offset) was **bit-exact** vs the same weights
   resident (`max|diff| = 0`, no NaN). The Phase-1 "GPU reads garbage from
   unaligned wrapped pointers" hazard is avoided purely by page alignment — so
   we need **no copy into (sticky) device buffers** at all.

**Revised design (supersedes the "materialize into resident MLX buffers / slot
pool" framing in §5):** bit-exact transparent offload where expert weights live
as **page-aligned, mmap-backed clean file pages** — a miss *maps* the region
(GPU gathers from it directly), eviction *unmaps* it (`munmap`/
`madvise(DONTNEED)`). Idle footprint collapses toward the core; a cold expert
is just an unmapped clean region re-faulted from SSD when routing asks. The one
requirement this forces: a one-time conversion to an **offload-ready expert
file** with each expert's weight/scales/biases starting on a page boundary
(safetensors packs them contiguously; the registry already scans the per-expert
byte offsets).

---

## 1. What Apple actually does — and what's portable

Apple's AFM-3 "Core Advanced" is **two separable things**, and only one is
bolt-on:

- **Portable (inference-time runtime):** store the model in flash, stream only
  the needed experts into DRAM, manage a resident working set. This is a
  memory-management strategy — adoptable.
- **NOT portable (trained architecture):** the *per-prompt routing* that makes
  it work is **Instruction-Following Pruning** — a predictor co-trained
  end-to-end with the base weights so the model is *prunable by prompt*. The
  base weights are updated during training. You cannot bolt IFP onto a
  finished model, and trained-MoE experts are **not** human-interpretable by
  task ("expert 7 = Python" is a myth). LLM-in-a-flash additionally needs a
  ReLU-sparse FFN (a relufication fine-tune for SiLU/GeGLU models).

**Why per-prompt, not per-token:** flash→DRAM is ~1 GB/s on a phone vs ~100
GB/s DRAM — a standard token-routed MoE would thrash the bus, so Apple decides
the expert set once per prompt and freezes it. We don't need to copy the
*mechanism* (we have unified memory + a fast SSD, not a 1 GB/s phone bus); we
need the *insight* — amortize expert movement over a span where the working
set is stable.

---

## 2. The memory problem, measured

On the M4 Pro (24 GB), a real desktop commits memory before the model loads:
macOS baseline ~4–6 GB, plus a working set of Chrome + IDE + Slack + Claude
Desktop + Mail + WhatsApp + Calendar ≈ 6–10 GB. That is ~10–16 GB gone before
inference.

`gemma-4-26B-A4B-OptiQ-4bit`, measured (PLAN Phase 6):
- **16.4 GB resident**, of which **14.09 GB is the expert pool**.
- **~0.9 GB of experts read per token** (top_k/num_experts of the pool). The
  other ~13 GB is resident-but-idle on any given token — the squat.
- KV is *not* the hog for this model: 5/30 global layers, 2 global KV heads,
  Gemma sliding window ⇒ max safe context ~17.6k at bf16 KV, gated by the
  weight footprint, not the cache. (KV bites harder on longer contexts or
  models with fatter global attention; the tiering principle below still
  holds, but for *this* model the experts are unambiguously the target.)

So today the 26B leaves ~0 GB for apps and limits context to ~17.6k — and that
is the *good* case (a model that fits at all).

**The tiering principle.** Rank everything that wants RAM by access-frequency ×
mutability:

| What | Touched | Mutable | Belongs |
|---|---|---|---|
| KV cache | every token | read **+ write**, per-session dirty | resident — cannot offload (only quantize) |
| Attention / embeddings / shared experts | every token | read-only | resident |
| Active routed experts | ~top_k/N per token | read-only | resident working set + LRU |
| Cold routed experts | rarely, this token | read-only, **clean file pages** | **SSD** — the natural victim |

The current layout is backwards: it spends the fast tier on the coldest data.
Cold experts are read-only and clean (cheap to evict / re-read); KV is dirty
and hot (must stay). Two orthogonal levers compose along this split — quantized
KV shrinks the hot tier (Phase 9, shipped), expert offload shrinks the cold
tier (this note).

---

## 3. The personal-AI insight: task locality is the unlock

Per-prompt/period expert selection only avoids thrash if the working set is
stable across that span. That is false for a topic-hopping chat and false for a
multi-tenant server — but **true for one human doing one job**: two hours of
coding, then a session reorganizing a 5,000-doc wiki. Within a task the hot
expert set is stable; you pay a re-warm only at task boundaries.

This is structurally the **same shape as the LoRA adapter system we already
ship** (Phase 8): one resident base model, the calling app declares intent
("use the coding fine-tune") via `/v1/adapters` + `adapterScoped()` in
`src/lora.ts` / `src/generate.ts`. Expert offload reuses that surface: the app
declares a *domain*, and the residency manager warms the experts that domain
has historically hit. The difference from LoRA: a hint, not a hard mount —
misses fall through to SSD (see §4), so correctness never depends on the hint.

**Scope boundary (important):** this is a single-user / single-active-task
feature. Under Phase 18 concurrent slots with diverse requests the locality
guarantee disappears — in that mode experts should stay resident (or accept
thrash). Don't combine the two naively; keep offload files separate from the
batch/slots work, per the slots discipline.

---

## 4. The correctness fork

Two designs, very different parity implications:

- **A — Transparent offload (BIT-EXACT).** Cold experts on SSD; materialize
  whichever experts routing picks into a resident buffer before `gather_qmm`;
  hot LRU cache. Output is identical to today's all-resident path — same
  `gather_qmm`, same tokens — only latency varies on a miss. Stays L1/L2. This
  is the foundation.
- **B — Task-pinned routing (LOSSY).** Restrict routing to a pinned set and
  skip cold experts → zero misses, lower latency, but the computation changed →
  L3, KL-gated, default-off. This is the closest off-the-shelf analog to IFP's
  select-and-freeze, and it's quality-risky on weights trained for per-token
  routing.

**Recommendation:** ship A as the always-correct floor; layer the §3 domain
hint as a *prefetch* on top of A (warms the likely set, still bit-exact because
misses fall to SSD). Offer B only as an opt-in mode for users who'll trade a
little quality to eliminate switch latency — and keep it as a documented
default-off flag, never the only path (per the "don't delete optionality"
principle).

---

## 5. Proposed architecture

Layered, each layer independently useful and independently gated:

1. **Offload-ready expert file (page-aligned).** A one-time conversion stores
   each expert's packed weight/scales/biases starting on a 16 KB page boundary
   (safetensors packs them contiguously; the registry already scans the per-
   expert byte offsets). This is what lets the GPU gather straight from the
   mmap — confirmed bit-exact in §0.5.
2. **Residency manager (mmap-backed).** Per (layer, expert) state: `unmapped`
   (clean on SSD) / `mapped`. A miss maps the expert's page-aligned region
   (`MlxArray.fromView` over the mmap) and the GPU gathers from it directly —
   **no copy into device buffers** (§0.5 showed those don't reliably return to
   the OS). Eviction = `munmap`/`madvise(DONTNEED)`, which returns RAM to the
   OS deterministically. Attention + embeddings + shared experts stay pinned;
   LRU over the mapped expert set under a byte budget. Default = everything
   mapped (inert, like the slots flag), opt-in via `--expert-offload`.
3. **Domain prefetch (the LoRA-shaped surface).** Per-session/request `domain`
   hint → prefetch that domain's profiled hot-set. Profiles are per-user,
   persisted, updated online from observed routing (ties into the memory
   flywheel). No hint ⇒ pure adaptive cache (still works, just pays re-warm at
   task boundaries).
4. **(Optional) Pinned mode (B).** Hard-restrict routing to the warm set; L3
   gated; default-off.

Correctness is preserved at layers 1–3 by construction: we always compute with
the experts routing actually selected; offload changes *where weights live and
when they arrive*, not *what is computed*.

---

## 6. The two payoffs, quantified where we can

- **Shrink the 26B (already fits):** resident floor after offload ≈ non-expert
  (16.4 − 14.09 ≈ 2.3 GB) + active working set + a hot cache. With a ~2–3 GB
  hot cache that's ~5–6 GB resident vs 16.4 GB today → ~10 GB returned to KV
  context length and to the user's apps. Decode cost is the unknown to measure
  (§7).
- **Admit a 35B-A3B (doesn't fit):** characterize as a fit-table row today
  (Phase 14), then show it runs usable with offload; the domain-switch warm-up
  is the price. This *changes* the Phase 14 line.

All tok/s figures here are **unmeasured** until §7 runs on a cleared machine —
treat as hypotheses, not promises.

---

## 7. Tradeoffs and the load-bearing unknown

- **The #1 thing to measure: per-task expert skew.** Does a coding session
  actually concentrate its routing on a stable subset, and how big is it? If
  the hot ~50% of experts covers ≥90% of activations and is stable within a
  task, the whole idea works; if routing is near-uniform per task, it doesn't.
  This is empirical and unknown — measure before building anything else.

  **E0 result (scripted, 2026-06-14 — `scripts/run-expert-trace.ts`, 8 prompts
  × coding/writing/chat on the 26B): gate PASSES all three.** 90% of
  activations land on ~40–47% of experts (51/53/60 of 128; uniform ≈ 90%) —
  concentrated but moderate. Within-task stability (hot-set Jaccard over 4
  windows) 0.63–0.70. Unique experts touched over ~1.2k tokens: 81–85% of the
  3840 instances → the *touched* working set is large (~12 GB) even though
  *activations* concentrate. Cross-task: coding vs prose 0.42–0.44
  (specialised — domain prefetch pays), writing vs chat 0.68 (similar). Net:
  bit-exact offload realistically frees ~6–7 GB (resident ~9–10 GB vs 16.4),
  keeping the 90% hot set resident and re-faulting the rare tail — the exact
  footprint-vs-miss-rate curve is E1's measurement, not an E0 promise. Caveat:
  scripted short sessions; a real long focused session may tighten or broaden
  the curve — worth a confirming real-session trace before locking a budget.
- **Switch cost.** = (bytes that must become newly resident) / SSD bandwidth
  (~5–7 GB/s) + dequant + buffer setup. Pure I/O floor for a few-GB working set
  is single-digit seconds; the conservative "30–60 s" budget leaves room for
  dequant/repack and a near-total set change. Measure the real number; it
  depends on how much the hot set overlaps between domains.
- **Miss latency on the bit-exact path.** A cold expert miss is a synchronous
  SSD read on the decode critical path; bounded by ~7 GB/s × miss-rate. Hot
  cache + domain prefetch are what keep miss-rate low.
- **Not for multi-tenant serving** (§3 scope boundary).

---

## 8. Phased plan (proposed — for promotion into PLAN.md)

- **E0 — Measurement spike (no runtime risk).** Instrument the existing MoE
  forward to log per-(layer,expert) selection over real coding / writing / chat
  sessions. Produce the coverage curve (% experts covering 90/95/99% of
  activations), within-task stability, and cross-task set shift. **Gate to
  proceed:** hot-set coverage + stability good enough that offload pays. This
  is the make-or-break, and it's pure observation.
- **E1 — Transparent offload (bit-exact).** Expert store + residency manager +
  on-demand materialization + hot LRU, behind `--expert-offload` (default off /
  inert). **Parity gate:** bit-exact vs current all-resident (L1/L2 unchanged).
  Measure resident footprint + decode tok/s vs miss-rate on a cleared machine.
- **E2 — Domain prefetch (LoRA-shaped).** Per-session `domain` hint reusing the
  adapter surface; per-user profile, learned online. Still bit-exact. Measure
  cold-start vs warm latency and task-boundary switch cost.
- **E3 — Admit a non-fitting model.** Bring a 35B-A3B-class model up under
  offload; show usable serving on 24 GB; flip the Phase 14 fit-table line.
- **E4 — (Optional) Pinned mode.** L3 KL-gated, default-off flag; only where the
  quality delta is acceptable.

**Exit criterion (overall):** 26B-A4B served at bit-exact parity with resident
footprint cut to a measured target, leaving a usable machine, with a quantified
domain-switch cost — promoted into `benchmarks/RESULTS.md`.
