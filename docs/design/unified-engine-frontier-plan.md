# Unified engine + the frontier program — the reorganization plan

Status: **PLAN** (2026-07-05, from the flag-architecture discussion with Josh
after the naked-=-L1 decision). This is the design that makes the library
"make sense": one engine, one honest flag surface, per-scheme oracles, and a
Lab where optimization experiments live until they earn defaults.

Supersedes: batching-v2-plan.md's standing decision that `--batch N` is a
mode switch (reversal documented in §4, with the new rationale — the old
rejection's determinism argument is answered, not ignored). Builds on:
faithful-l1-consolidation.md (the L1 baseline, now the naked default),
parity-tier-dag.md (per-scheme oracles), omlx-adoption-map.md (survey),
batching-perf-path.md (the B=1 gap numbers this plan must close).

---

## 1. North star: beyond the Pareto frontier

The claim we are building toward: **"the best way to run local AI on a Mac."**
Formally: every (model, workload) point we ship should sit on or beyond the
current local-inference Pareto frontier in this space:

| axis | direction | measured by |
|---|---|---|
| memory | less is better | generation peak (Metal), fit-model predictions |
| decode tok/s | more | bench-h2h (stable cells only) |
| prefill / TTFT | faster | bench-h2h, server TTFT |
| throughput | higher | batched aggregate tok/s (bench-serving-load) |
| intelligence | higher | frozen eval suite (MMLU/GSM8K/IFEval/HumanEval/BFCL/HashHop, evals.sqlite) |

Two consequences drive everything below:

- **The baseline must be even and proven before optimizing.** We now have it:
  the L1 faithful path is bit-exact with mlx-lm at 1.00× speed on every
  model. Anything that claims to beat it proves it with a paired A/B on a
  stable pass — otherwise it is noise or a regression (2026-07-05 evidence:
  every output-changing lever failed this bar).
- **Frontier-shifting work is usually a *quality-per-byte* play, not a raw
  kernel play.** Mixed-precision quantization (weights AND KV) moves memory
  down while holding or raising intelligence — a genuine beyond-the-frontier
  move, unlike micro-kernel wins that trade along it. This is why quantized
  KV stays first-class even though it lost the speed A/B: it buys context
  headroom (12B@16k: −1.3 GB, growing linearly) and mixed schemes buy
  intelligence-per-byte.

## 2. Survey — what the other engines got right (and wrong for us)

- **mlx-lm** (`server.py`/`generate.py`): the L1 oracle. Its server is
  **concurrency-driven by default** — it auto-creates a `BatchGenerator`
  (decode-concurrency cap 32, prefill concurrency, chunked
  `prefill_step_size`) and routes any batchable request into it; only
  non-batchable requests (draft models etc.) serve sequentially. There is no
  "batching mode" flag — the cap is the only knob. Uniform KV quant only;
  count-capped prompt cache (the OOM footgun we already fixed by byte-capping).
  → **Adopt: the concurrency-driven default is our drop-in-parity behavior.**
- **vLLM**: continuous batching + PagedAttention — the KV cache is block-paged
  with a block table per sequence, which is what makes batching, long context,
  and prefix sharing *compose* instead of conflict. No batch flag; `max_num_seqs`
  caps. Chunked prefill interleaves with decode so TTFT doesn't starve running
  streams. → **Adopt (long-term): block-paged KV as the structure that unifies
  batch + quantized KV + prompt cache + SSD tier. Adopt (near-term): the
  no-mode-flag scheduler and prefill/decode interleaving policy.**
- **llama.cpp** (server): slot-based (`-np` = slot count), one shared KV
  buffer partitioned by sequence — concurrency-driven, no mode flag. KV cache
  default is **f16; quantized KV (q8_0/q4_0) is opt-in** — independent
  confirmation of our bf16-default decision. Its imatrix (importance-matrix)
  quantization is the ecosystem's calibration-driven intelligence-per-byte
  play — the same family as oQ and our knapsack `--target-bpw`.
  → **Adopt: nothing structural we don't have; validates KV defaults; imatrix
  is prior art for the §7 quant program.**
- **oMLX**: scheduler on mlx-lm's BatchGenerator + product appliances. Already
  systematically mapped (omlx-adoption-map.md): batching parity + SSD tier
  ported and won; burst decode ported and REFUTED (Python-GIL medicine, our
  disease doesn't exist); oQ quant + DFlash queued. → **Keep mining the queue;
  its engine architecture is not ahead of ours.**
- **mlx-optiq**: the L2 oracle — per-layer mixed KV (`kv_config.json`), fused
  quantized SDPA, vision sidecar. Not a batching engine. → **Its role is the
  oracle for mixed-precision schemes (§5) and the source of the next quant
  ideas (TurboQuant per Josh).**

## 3. The architecture (four layers, each with one job)

```
┌─ Serving surface ──────────────────────────────────────────────┐
│ OpenAI /v1 API · Pi (chat/CLI) · web UI · MCP                   │
├─ Engine (ONE loop) ────────────────────────────────────────────┤
│ Continuous-batching scheduler; a lone request = batch of 1.     │
│ Admission (memory budget, kv-budget), prompt cache, SSD tier,   │
│ spec decode, grammar — implemented ONCE, apply to every request.│
├─ Model layer ──────────────────────────────────────────────────┤
│ Universal graph: ANY HF model, best effort (the wide funnel).   │
│ Optimized-verified graphs: per-model custom files (gemma4-12b/  │
│ e4b, minicpm5, qwen3.5, …), selected by config fingerprint —    │
│ never by flags — each with parity goldens + bench entries.      │
├─ Numerics / KV schemes ────────────────────────────────────────┤
│ bf16 (default) · uniform 4/8 · mixed per-layer (kv_config) ·    │
│ future: TurboQuant, oQ-style weights. Each scheme has an oracle │
│ or a Lab gate (§5).                                             │
└────────────────────────────────────────────────────────────────┘
```

**The model-layer philosophy (Josh's, verbatim intent):** the universal layer
is the promise that anything from Hugging Face *runs*; the optimized-verified
layer is the promise that the models we care about run *better than anywhere
else*. Promotion from universal → optimized is a defined checklist: custom
graph file, bit-exact parity goldens vs the scheme oracle, h2h bench entry at
≥1.00× vs mlx-lm, eval-suite scores recorded. "Optimized and verified" is a
badge with teeth, and the badge list is the marketing claim.

## 4. The engine: concurrency IS the batch size

**Decision (Josh, 2026-07-05): batching is determined by how many concurrent
requests are in flight, not by a flag.** One request = batch of 1 at full
serial speed; N requests = continuous batching; requests join/leave running
batches (the extend-join machinery already landed and is token-exact vs
mlx-lm B=2).

This **reverses** batching-v2-plan.md's standing decision (`--batch N` as a
mode switch, auto-batching rejected for determinism). The old objection was
"an idle-vs-loaded server produces different numerics for the same request."
It gets a real answer, not a shrug:

1. **The L1 oracle itself behaves this way.** mlx_lm.server auto-batches by
   default; "drop-in for mlx-lm" now *requires* concurrency-driven batching.
   Our parity contract becomes: **bit-exact to mlx-lm at the same batch
   composition** — already golden-verified at B=1 and B=2.
2. Anyone who needs load-independent numerics pins the cap to 1 (see below).
3. **Batch-invariant kernels** (identical numerics regardless of B — the
   Thinking-Machines-style program) go to the Lab as a research item; if that
   ever lands, determinism-under-load comes back for free and it's an
   arXiv-lens result on Apple Silicon.

**Flag decision (Josh, 2026-07-05): the flag stays `--batch` — no rename.**
Its *semantics* change from mode switch to cap: `--batch N` = maximum
concurrent rows (mlx-lm's `--decode-concurrency` twin), **default 32**, and
`--batch 1` is the force-serial / determinism pin. TIMING: the 32 default
lands **with Phase 2, not before** — flipping it while the batched lane is
still 1.8× slower at B=1 would regress every single-request user ~44%. Until
GATE-B1-SPEED passes, `--batch` keeps today's default (1 = the serial lane).

**The crux gate — the B=1 gap.** Today the batched lane at B=1 runs cpm5 at
~149 tok/s vs 267 serial (batching-perf-path.md): the unified engine is
**1.8× off** at the composition that matters most for a single-user runtime.

**Measured 2026-07-05 (paired in-process A/B, cpm5, M1 Max): mlx-lm's own
`BatchGenerator` at B=1 runs 256.5 tok/s vs 264.6 for its `stream_generate`
— a 3.3% tax on the most host-tax-sensitive model we have.** Two
consequences: (1) the unified design is *proven achievable* — a continuous-
batching loop can serve a lone request at ~0.97× of the best serial loop,
so our lane's 1.8× gap is an implementation artifact, not an inherent cost
of the architecture; (2) our h2h 1.00× parity numbers were measured against
`stream_generate` (mlx-lm's FASTEST single-stream path), so the baseline we
match is not batched-handicapped — and `mlx_lm.server` actually serves a
single request ~3% below the number we already match. The serial lane
cannot be deleted until:

- `GATE-B1-SPEED`: unified engine at B=1 ≥ 99% of today's serial decode tok/s
  and TTFT on cpm5 + e4b + 12B (stable bench pass), and
- `GATE-B1-PARITY`: unified engine at B=1 bit-exact vs the L1 goldens (full
  logprobs, not just greedy).

How to close 1.8×: the serial lane's wins are known and portable — the
pipelined decode loop (async-eval overlap), compiled per-step graph replay,
and no per-token scheduler hops. The likely landing: **the scheduler owns
admission and join/leave; when exactly one sequence is active it executes the
same pipelined/compiled step the serial path runs today** (B=1 specialization
inside one engine — a fast path, not a second lane), falling back to the
general batched step at B≥2. Same public machinery, no gateway routing rules,
no feature×lane matrix.

**Feature composition targets** (the point of unification — kill the
"batching OR performance" choice):
1. Quantized KV under batching (one active scheme per server, not
   per-request) — the agent-fan-out-with-long-context composition.
2. Prompt cache / prefix reuse for batched rows (vLLM/SGLang-style prefix
   sharing is the long-term shape; whole-entry reuse first).
3. Spec decode in the engine (serial-only today; drafts per slot later —
   DFlash/DSpark slot behind the same seam).
4. Chunked prefill interleaved with decode (vLLM policy) so a 16k prefill
   doesn't stall running streams.

## 5. Fidelity: per-SCHEME oracles (fixes "L1 can't oracle mixed")

The tier ladder stops being a product mode and becomes what it always really
was — a **map from numeric scheme to its verification oracle**:

| scheme | oracle | verification |
|---|---|---|
| bf16 (default), any batch B | **mlx-lm** at same composition | bit-exact goldens (serial + B=2 landed) |
| uniform kv 4/8 | **mlx-lm** `--kv-bits` (+ optiq's rotating cache class where upstream is NYI) | bit-exact (kv-quant.test) |
| mixed per-layer kv (`kv_config.json`) | **mlx-optiq** `install_mixed_kv` | bit-exact (mixed-kv-parity.test, landed 2026-07-05, maxDiff 0) |
| mixed-precision weights (knapsack/oQ/TurboQuant), original kernels, batch-invariant kernels | **none exists** → Lab gates | KL vs our own reference path + frozen eval suite (intelligence axis) + envelope tests + kill switch |

So: mixed-precision quantization is NOT demoted by the naked-=-L1 decision —
it is the flagship of the row that mlx-lm cannot oracle, verified against
optiq where optiq reaches (KV) and against the eval suite where no oracle
exists (weights). `--l1/--l2` survive as *bench/test vocabulary* for the
first three rows; they stop being user-facing product modes.

## 6. The flag surface (end state — every flag with its reason)

User-facing serve/generate flags after the deletion pass:

| flag | why it exists |
|---|---|
| `--kv-quant config\|4\|8\|off` | the ONE performance trade-off a user makes: decode speed vs context headroom (+ intelligence-per-byte with mixed). Default off (bf16). Composition (fused vs unfused quantized SDPA) is DERIVED from the scheme's oracle, not chosen. |
| `--batch N` | cap on concurrent rows (mlx-lm's `--decode-concurrency` twin). Default 32 once Phase 2's B=1 gate passes; `--batch 1` = force-serial / determinism pin. Name kept (Josh 2026-07-05) — semantics change from mode to cap. |
| `--draft-model`, `--num-draft-tokens` | speculative decoding (mlx-lm parity) |
| `--adapter`, `--memory-budget`, `--kv-budget`, `--prompt-cache`, `--ssd-cache`, `--expert-offload`, `--force-wire` | capacity/serving features, not numerics levers |
| sampling flags (`--temperature` etc., HLG family) | request-default sampling |

Everything else becomes either a **kill switch** (env-only, documented for
debugging: `MLX_BUN_COMPILED_DECODE=0`, `MLX_BUN_COMPILED_GEGLU=0`,
`MLX_BUN_NO_FUSED_SDPA=1`) or a **Lab flag** (env-only, lives with its bench
script and expiry — §7). Kill switches are bit-exact by definition (they
select a slower same-parity path); anything output-changing is Lab.

**Deleted** (2026-07-05 evidence, one funeral each):
- `--fused-decode` / `MLX_BUN_FUSED_DECODE` — 1.00×, forces uncompiled,
  silent-wrongness footgun. Delete kernel path + flag + backstop throw.
- `--fused-gelu` / `MLX_BUN_FUSED_GELU` + `MLX_BUN_FUSED_SWIGLU` — +0–1%;
  the compiled closures already own the fusion win bit-exactly. Delete both
  custom Metal kernels + flags (git history keeps the source).
- `--perf-kernel` / `MLX_BUN_PERF_KERNEL` — **DELETE** (Josh 2026-07-05:
  "we are going to start a full optimization program anyway… we will end up
  redoing all the work we have currently done given that we now have a
  different starting point"). The kernel, its frozen-oracle test scaffolding
  (perf-kernel-oracle.test.ts, freeze-perf-oracle.ts), and the flag all go;
  git history + the h2h evidence (+6% 12B@16k, −38% e4b@16k, KL WARN) are
  the breadcrumb. If a flash-decode kernel returns, it's re-derived from the
  L1 baseline in the Lab under the §7.4 program, not resurrected.
- `MLX_BUN_CPM5_FAITHFUL` + `FaithfulMiniCPM5` — the default IS the faithful
  path now; the A/B reference served its purpose.
- `--l3` as a product mode — the Lab replaces it. `--l1`/`--l2` demote to
  documented bench/test aliases.

**Lab lifecycle rule** (the anti-flag-pile law): every Lab experiment ships
with (a) a hypothesis stated in frontier-axis terms, (b) a paired A/B bench
script, (c) an expiry review date. Outcomes: promote to default (with the
stable-pass numbers) or delete (with a breadcrumb in the design doc). No
third state. "Off in every regime with no promotion path" — the fused-decode
condition — is a deletion that hasn't happened yet.

## 7. The frontier program (AFTER stability — the order matters)

Phase gate: none of this starts until §8 phases 0–2 are done. "Now we
finally have a baseline that is even and proven; investigate THAT."

Ranked by expected frontier shift (memory ↓ / intelligence ↑ first, then
speed):

1. **Mixed-precision weights** — knapsack `--target-bpw` (ours) vs oQ
   (calibration-driven sensitivity, omlx-adoption-map §4) vs llama.cpp
   imatrix as prior art. Gate: perplexity + frozen 6-task eval at equal bpw.
   The purest beyond-the-frontier play we know: same memory, more
   intelligence. (arXiv-lens candidate.)
2. **TurboQuant KV** (Josh) — next-gen KV quantization; slots into the §5
   Lab row (no external oracle → KL + eval + long-context retrieval gates).
   Composes with §4's batched-quantized-KV target.
3. **Speculative decoding depth** — DFlash/DSpark behind the existing
   `DraftSource` seam; decode tok/s at zero quality cost when drafts land.
4. **Per-model graph work from the baseline** — the optimized-verified
   layer's whole point: unroll a model's flat DAG, find fusion the compiler
   misses, prove with kernel-trace diffs, promote per model. The perf-kernel
   root-cause lives here.
5. **Batch-invariant kernels** (research) — restores determinism-under-load;
   novel on Apple Silicon.

## 8. Migration phases (each with a hard gate)

- **Phase 0 — measure the gap** (no code): stable-pass bench of the batched
  lane at B=1/2/4 vs serial on cpm5/e4b/12B (the 149-vs-267 number is one
  model, one day). Output: the closure worklist.
- **Phase 1 — the deletion pass** (§6): dead kernels, flag surface, docs,
  Lab scaffolding (move perf-kernel + its bench + oracle tests). Gate: full
  suite green; naked defaults byte-identical to today's L1 route.
- **Phase 2 — engine unification**: scheduler owns everything; B=1 fast path
  = today's pipelined/compiled step; gateway routing rules deleted; `--batch`
  → `--max-concurrency` (default 32, mlx-lm parity). Gates: `GATE-B1-SPEED`,
  `GATE-B1-PARITY`, B=2 goldens still token-exact, TTFT within 5% at B=1.
- **Phase 3 — composition**: quantized KV under batching (B=1-row
  batched-quant bit-exact vs serial kv-config — the gate batching-perf-path
  already names), then prompt-cache reuse for batched rows, then chunked
  prefill interleaving. Gate per feature: parity + no aggregate-throughput
  regression at B=4.
- **Phase 4 — the frontier program opens** (§7 order).

## 9. Decisions log (was: open questions)

1. **Cap default 32** (Josh 2026-07-05) — lands with Phase 2 (see §4 timing
   note); kv-budget admission keeps it safe on small boxes.
2. **Flag stays `--batch`** — no rename; semantics become the cap;
   `--batch 1` = force-serial pin.
3. **Perf kernel: deleted in Phase 1** (§6) — the optimization program
   re-derives from the L1 baseline; no resurrection.
4. Still open: PagedAttention-style block KV — Phase 3 follow-up or its own
   design doc when prefix sharing under batching becomes the bottleneck.
