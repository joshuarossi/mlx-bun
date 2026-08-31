# Quality evals — the acceptance gate for non-bit-exact perf work

Fusing kernels (GELU, norm+add, online-softmax attention) reorders bf16
float ops, so the model is **no longer bit-exact to the mlx-lm oracle**.
Logit parity stops being a usable gate. This harness is the replacement —
a faithful port of **optiq's eval framework**
(`optiq/eval/` in the oracle venv): KL divergence as the continuous
acceptance gate, plus the six-task capability score as the ship gate.

## The gate, in two tiers (optiq methodology)

1. **Smoketest (~5 min):** KL divergence (64 prompts × 256 tok, mean/median/p95)
   + GSM8K-50. Fast triage — "did the distribution drift?"
2. **Capability suite (~2 h):** MMLU · GSM8K · IFEval · BFCL · HumanEval ·
   **HashHop@12k**. `Capability_Score = unweighted mean` of the six
   (`score.ts`). HashHop@12k is the long-context guard — where online-softmax
   error (opportunity A) is worst.

KL math (`kl.ts`, port of `kl.py`): `KL(ref‖cand)` per token =
`Σ softmax(ref)·(logsoftmax(ref) − logsoftmax(cand))`. **Teacher-forced** —
same fixed prompt to both arms, compare per-position distributions (the
repo rule: free-running greedy "measures chaos").

## KL reference modes

- **self-flag (default — the kernel-drift gate):** one weight load; forward
  each prompt twice with a perf lever set to its ref vs cand value. Directly
  measures the drift a lever introduces. Fits in 24 GB (no second model).
  `KL(compat ‖ fused)` is literally "measure the output difference."
- **two-model (optiq-style absolute quality):** a separate reference model
  (bf16 if it fits, else uniform-4bit), both resident.
- **saved-teacher (`--reference-logits <dir>`):** the reference is a
  **dump on disk**, not a resident model — the only way to score against a
  bf16 teacher on 32 GB. A Python-side script forwards the teacher once and
  writes, per teacher-forced position, the top-2048 logits plus the
  **full-vocab logsumexp**; every candidate is then scored through OUR
  engine. Format (`format_version` 1, read by `reference-logits.ts`):

  ```
  runs/kl-teacher/<tag>/
    manifest.json  {format_version, model, corpus_sha256, ctx_len, n_seqs,
                    top_k, positions_per_seq, created, notes}
    tokens.bin     int32 LE [n_seqs][ctx_len]
    seq-<i>.bin     record r (r = 0…ctx_len-2, the distribution over token
                    r+1, i.e. candidate POSITION r):
                      int32[top_k] indices, descending by logit
                      float16[top_k] reference logits
                      float32 full-vocab logsumexp
  ```

  `KL = Σ_{j∈topK} p_j·(log p_j − log q_j)`, `p_j = exp(ref_j − ref_lse)`,
  `log q_j = cand_j − logsumexp(cand, full vocab)`, float32 throughout.
  The sum is truncated to top-k, so the run also reports **captured mass**
  `Σ_j p_j` (how much of `p` the number covers — a low-mass run is not a
  comparable KL) and **top-1 agreement** (argmax over the full vocab).
  The forward is the SERVING path (`makeCache` + chunked `forwardHidden` +
  `logitsFromHidden` per chunk, `--chunk` positions at a time so a 4k
  context's full-vocab logits never exist at once), **not** `trainForward` —
  which is why this works on qwen3_5, where `mlx-bun perplexity` cannot go
  (docs/design/turboquant.md, "Known engine gaps"). KV stays bf16: this is a
  weights-only instrument.

  Noise floor (measured, M1 Max, Qwen3.5-0.8B-OptiQ-4bit, 2×128 ctx,
  top-64): scoring a dump against the model that produced it gives KL
  **exactly 0** at the same `--chunk`, and mean 9.3e-6 / p95 8.3e-7 across
  chunk 64 → 40. float16 storage is lossless for a bf16 teacher (bf16's
  7 mantissa bits fit float16's 10, and logits sit far inside float16's
  65504 range), so the residual is only the engine's own L-dependent bf16
  rounding — the same effect that makes prefill chunk size ulp-visible
  (`generate.ts`, prefill-tail-split). Compare candidates at one `--chunk`.

## Run (on a cleared machine — loads models, not from an agent session)

```sh
# drift gate on an existing non-bit-exact lever (validates the harness today):
bun scripts/eval.ts kl --candidate e4b

# self-arm A/B on an output-affecting lever (fused-sdpa on vs off):
bun scripts/eval.ts kl --candidate e4b --self MLX_BUN_NO_FUSED_SDPA --ref-value 1 --cand-value 0

# optiq-style absolute drift vs a reference model:
bun scripts/eval.ts kl --candidate e4b --reference <bf16-or-4bit-id>

# vs a saved bf16 teacher-logits dump (--n caps sequences, --chunk positions
# per forward; the dump brings its own corpus, so --prompts-file/--seq don't apply):
bun scripts/eval.ts kl --candidate <model> --reference-logits runs/kl-teacher/<tag>

# higher-fidelity prompts (optiq's calibration mix):
bun scripts/eval.ts kl --candidate e4b --prompts-file \
  /Users/joshrossi/Code/mlx-lm/.venv/.../optiq/calibration/data/optiq.jsonl
```

Rows land in `~/.cache/mlx-bun/evals.sqlite` → `quality_runs` (separate from
the throughput `runs` table). Each row records the active perf levers
(`config_json`) so it's self-describing: which head-to-head arm produced it.

## Status / milestones

- **M0 (done):** KL drift gate + capability score + `quality_runs` DB + CLI.
- **M0b (done):** *serving-path* KL (`evaluateKlServingDecode` in `kl.ts`,
  `bun scripts/eval.ts kl --decode`). Validated at the time: identical arms →
  KL 0; the since-deleted `MLX_BUN_FUSED_DECODE` tiled-decode → KL 0.27 (real
  drift on the quantized path — the lever was removed 2026-07-05, but the
  validation stands). Motivation below — the compat KL couldn't see it:
  The compat `forward()` path with `makeCache()` uses **plain bf16 caches**. That is wrong
  twice over: (1) e4b's KV is **per-layer mixed 4-bit/8-bit** (group 64, from
  `kv_config.json` → `config.kvQuant`; 8-bit layers 3,4,9,10,11,14, 4-bit
  elsewhere), NOT bf16; (2) bf16 caches fail the generated class's `#matches`
  guard, so the model silently falls back to the monolith — a path that
  doesn't exist in production. M0b must reproduce the serve setup: build
  caches, then `cache[i] = c.toQuantized(e.groupSize, e.bits)` per
  `config.kvQuant` (the logic already at `generate.ts:68-86`), so the
  teacher-forced prefill runs the real mixed-4/8-bit quantized path and the
  perf levers (NO_FUSED_SDPA) actually bite.
- **M1 (done):** all six capability tasks ported + runtime-validated, plus
  `capability` aggregation and the `smoketest` (KL + GSM8K-50) gate. Datasets
  exported by `scripts/oracle/export-datasets.py` → `~/.cache/mlx-bun/eval-data/`.
  Tasks run through the real quantized-KV path (`runner.ts`). HumanEval executes
  in a sandbox-exec + venv-python subprocess; HashHop reconstructs Magic AI's
  generator (`MultiHopEval` isn't on PyPI). **Open quality checks** (need a real
  `--n 100+` run to confirm the port, not the harness): MMLU read ~chance at n=5
  (raw-completion port may underperform for instruct models — consider chat
  template or logit-scoring); BFCL produced no-calls (gemma-4 `<|tool_call>`
  format vs the textual-fallback prompt).
- **M2 (done):** compile-vs-fused paired A/B (`scripts/bench-compile-vs-fused.ts`).
  Plumbing validated; the `fused` arm is a placeholder (compile-off) until the
  kernels land — edit `ARMS.fused` to add each kernel's lever.
- **M3–M4 (next):** the fused kernels themselves (E → B/C → D → A), each gated
  + measured (KL/capability for drift, the A/B for speed) before it ships.
- **M5:** head-to-head @600/@8k + KL/capability → decide.
