# ORPO future enhancements

Performance-first follow-on ideas for mlx-bun's ORPO trainer, plus a short
appendix of objective variants that may be useful once the runtime path is
comfortable.

> **LANDED since this was written (2026-06-19):** the top items here are now in
> production — **Priority 1 (Cut Cross Entropy / fused linear CE)** and **§1
> (vocab-axis chunked CE)** shipped as the `[M,vocab]`-free **flash-CCE Metal head**
> (verbatim MLX steel GEMM, fwd+bwd; `orpo_flash_ce`), and **§3 (prefix sharing in the
> trainer)** shipped as `orpo_prefix_shared`, composed with the flash head AND the
> segmented backward for MiniCPM5 **and** e4b. See [training.md](../reference/training.md),
> [orpo-quickstart.md](../reference/orpo-quickstart.md), and the live record
> [steel-flash-cce-handoff.md](../investigations/steel-flash-cce-handoff.md). The
> remaining sections (§2, §4–§9, the objective variants) are still genuinely future.

Product relevance: ORPO is not only a researcher feature. It is the path to
small, downloadable task adapters that make the default local assistant better
without forcing every user onto a larger base model. The performance work below
matters when it turns adapter training from a fragile lab run into a repeatable
part of the mlx-bun product loop.

## Priority 1: Cut Cross Entropy / Liger Fused Linear CE

The top ORPO performance priority is a Cut Cross Entropy / Liger-style Fused
Linear Cross Entropy path for the LM head. This should be treated as the next
major kernel project before lower-impact objective variants.

Why it is first:

- Gemma's vocab is huge, so materializing `[tokens, vocab]` logits dominates
  peak memory in ORPO.
- ORPO needs chosen and rejected response log-probs, so the head cost is paid
  twice unless the trainer can share or fuse more work.
- Token-axis chunking already helps fit the run, but vocab-axis chunking cuts
  the largest remaining logits allocation at the source.
- The same fused engine can support SFT, DPO, ORPO, SimPO, IPO, and hinge-style
  preference losses once it exposes mean log-prob with a custom upstream
  cotangent.
- A Metal fused version can avoid extra MLX dispatches and intermediate memory
  traffic in the hot training path.

The implementation target is not just "chunk logits"; it is a fused log-prob
head that computes the linear projection, online vocab logsumexp, target-logit
gather, loss reduction, and backward replay without ever storing full logits.

## Performance focus

### 1. Vocab-axis chunked cross entropy

The current ORPO head optimization is **token-axis chunking**: split the response
positions into chunks, run the LM head on `[chunk, vocab]`, and rematerialize
those chunks in the backward. That bounds peak logits by `chunk_tokens * vocab`.

The complementary trick is **vocab-axis chunking**: split the vocabulary instead,
run the head on `[tokens, vocab_chunk]`, and combine chunks with an
online-logsumexp recurrence. This is the idea behind **Cut Cross Entropy** and
Liger-style **Fused Linear Cross Entropy**. This is priority 1 for the ORPO
performance roadmap.

Exact forward sketch:

1. For each vocab chunk, compute partial logits `h @ W_chunk`.
2. Gather the target logit only if the target id falls inside this chunk.
3. Maintain per-token online `logsumexp` across vocab chunks.
4. At the end, `logp = target_logit - lse`.

Backward reconstructs the softmax chunk-by-chunk from the saved per-token LSE
and never materializes full `[tokens, vocab]` logits. For Gemma's 262k vocab,
this is likely the next real moat after segmented backward.

Two implementation levels:

- Pure MLX chunked VJP first: exact, easier to validate, probably enough to fit
  longer contexts.
- Metal fused kernel later: fuse quantized head matmul + online LSE + target
  gather + backward. This is the high-performance version.

### 2. Fold ORPO gradients into the fused CE path

ORPO needs two mean log-probs, `lw` and `lr`, then applies the odds-ratio loss.
For a fused CE/log-prob kernel, the clean design is to feed the upstream scalar
gradient for each branch back into the chunked head backward. In other words,
the fused head should expose "mean logp with custom upstream cotangent", not
only cross-entropy.

This avoids materializing logits while still letting ORPO, SimPO, and future
preference losses share the same head engine.

### 3. Prefix sharing in the trainer

`src/train/prefix-shared.ts` already proves the MiniCPM5 shared-prefix idea:
one forward over `[prompt; chosen; rejected]` with block-sparse masking and
block-wise RoPE. It is not yet wired into `orpoLoop`.

Next useful path:

- Add an opt-in flag, for example `orpo_prefix_sharing`.
- Gate it by prompt/response ratio so short-prompt data stays on the simple
  two-forward path.
- Wire MiniCPM5 first.
- Port e4b later, where sliding-window masks, donor-KV reuse, and per-layer
  input make it trickier.

### 4. Sequence-chunk the MLP sub-block

The MLP is per-token independent. Inside segmented backward, run MLP blocks over
sequence chunks so the GeGLU/SwiGLU intermediate is `chunk_tokens * d_ff` instead
of `seq_len * d_ff`.

This stacks with depth segmentation and vocab-axis CE:

`layer segment -> layer -> MLP seq chunk -> vocab chunk`

Attention cannot be chunked this naively, but the MLP can.

### 5. Rotor / budget-aware segment planner

Replace fixed `segment_size` with a planner that chooses segment boundaries from
estimated activation bytes and a target memory budget. The planner should isolate
expensive full-attention layers and larger MLP regions instead of treating every
layer equally.

This is the practical version of rotor/checkpoint scheduling for this codebase:
less hand tuning, better fit at 8K+.

### 6. Faster flash-attention backward

The custom flash backward is now correctness-useful but too slow. A serious
performance version should mimic MLX's tuned SDPA style: simdgroup tiling,
larger threadgroups, and FA2-style backward that stores only per-row LSE and
recomputes attention probabilities.

This matters most when `ops.sdpa` backward's O(L^2) memory is the blocker.

### 7. Fused LoRA epilogue

Today LoRA adds multiple ops after the quantized base matmul:

`base(x) + scale * ((x @ A) @ B)`

A fused dequant-GEMM + LoRA epilogue would reduce dispatches and intermediate
traffic. Backward can recompute the cheap rank projection:

- `h = x @ A`
- `dB = scale * h.T @ dy`
- `dA = scale * x.T @ (dy @ B.T)`
- `dx = dy @ W.T + scale * (dy @ B.T) @ A.T`

This is more kernel work, but it benefits SFT, DPO, ORPO, and serving with
adapters.

### 8. Shape-specialized compile for training graphs

Shapeless compile is mainly required when a dimension changes every replay, such
as autoregressive decode with a growing KV cache:

`active_kv_len = prompt_len + generated_tokens`

ORPO training is different. Each dataset row already has concrete lengths:

- `P`: prompt length
- `Rc`: chosen response length
- `Rr`: rejected response length
- `T`: prefix-shared length, `P + Rc + Rr`

That means ORPO does not need shapeless compile in the same way decode does. A
training graph can be compiled for an exact `(P, Rc, Rr)` shape, or for a padded
length bucket, and cached under a key that includes the model, flags, segment
plan, token/vocab chunk sizes, and objective mode.

This is especially relevant for e4b prefix-sharing: the proof path should stay
eager first, but a later L3 speed tier can use shape-specialized compiled graphs
for known training shapes instead of requiring every primitive to support
shapeless output-shape inference.

The deeper L3 framing is **model-checksum-specific specialization**. For a fixed
model snapshot, we know the architecture, layer count, hidden sizes, quantization
layout, RoPE geometry, vocab, layer types, KV-sharing pattern, and supported
context budget in advance. It is acceptable to spend much more work up front if
that buys a faster hot path later.

Practical version:

- Treat the model snapshot checksum as part of the compilation key.
- Generate/compile/cache a table of exact graph variants for the shapes and
  modes we care about.
- Bucket or pad examples into those graph variants when helpful.
- Fall back to eager only for shapes/modes not in the table.

This is effectively a lookup table of specialized execution plans: more compile
and analysis cost up front, less branching, shape handling, and dispatch overhead
at runtime.

### 9. Fixed-shape decode cache as a compile route

Decode is harder because the active KV length grows by one token per step. The
current shapeless-compile path exists to avoid recompiling for:

`L = 17, 18, 19, 20, ...`

A separate route is to make decode shapes fixed:

1. Preallocate K/V buffers to a known maximum context length.
2. Write the new token into a dynamic position.
3. Carry `active_length` / `write_position` as scalar array inputs.
4. Mask out inactive cache positions, or preferably use an
   active-length-aware attention kernel that simply does not scan them.

The correctness version is "fixed cache + mask". The performance version is
"fixed cache + active-length-aware attention"; otherwise early decode steps may
pay for the full max context even when only a short prefix is active.

There is also a more aggressive specialization route: prebuild a graph table for
specific active lengths or length buckets. Even if that means many compiled graph
variants, the trade can be valid for a fixed model/checksum if compile cost is
paid once and reused. In that regime, the important design question is not "can
one shapeless graph infer every shape?" but "which finite set of exact shapes and
runtime states should we specialize for?"

If every op in a chosen route is compile-safe, the whole decode graph can become
a stable compiled graph. Custom Metal kernels still need to stay outside compiled
regions unless the route is intentionally eager/custom-kernel-only or MLX compile
can accept the primitive's output contract.

## Quality and robustness ideas

These are lower priority if the current goal is performance, but they are useful
once ORPO can run comfortably.

### SimPO

SimPO is a reference-free preference loss that uses the **average log-probability
of each response** as the reward and adds a target reward margin. It reuses the
same `lw` / `lr` values ORPO already computes.

Rough shape:

`loss = softplus(-beta * ((lw - lr) - gamma))`

where `gamma` is the desired chosen-vs-rejected margin. It should be cheap to add
as a sibling objective because the expensive part, response mean log-probs, is
already implemented.

### IPO

IPO means **Identity Preference Optimization**. It was introduced as a more
overfit-resistant alternative to the original DPO logistic objective. Instead of
driving preference probabilities toward hard 0/1 labels indefinitely, IPO uses a
smoother identity-style objective over preference gaps. The practical point:
when preference labels are noisy, IPO is often less eager to push margins to
extremes.

For mlx-bun, IPO is interesting mainly as a loss-family option after the shared
logp engine exists.

### Hinge / SLiC-style loss

The hinge loss is a margin-ranking objective:

`loss = max(0, margin - reward_gap)`

For preference training, `reward_gap` is usually the chosen score minus rejected
score. Once the gap exceeds the margin, that pair contributes no gradient. This
can be useful when you want to stop over-optimizing already-solved pairs and
focus compute on pairs whose preference margin is still too small.

### Label smoothing and robust weighting

Preference pairs are noisy. Cheap robustness knobs:

- `label_smoothing`: treat a pair as, for example, 95% chosen / 5% rejected
  rather than a hard label.
- Per-example `weight`: let curated data carry confidence or score gap.
- Loss clipping / winsorization: cap extreme high-loss pairs so noisy examples
  do not dominate gradients.
- Ambiguity filtering: skip pairs with tiny initial margin or near-identical
  chosen/rejected responses.

### Better curation

The current UltraFeedback curation mostly extracts rows and filters by length.
Quality can likely improve by filtering for:

- Large enough chosen-vs-rejected score gap when available.
- Similar response length, or at least bounded length ratio.
- High semantic contrast but not unrelated answers.
- Instruction-following categories if IFEval is the target metric.

Data quality may beat objective cleverness on small ORPO runs.

## Short answer to "token vs vocab"

The thing to look for is **vocab-axis chunked / fused cross entropy**, especially
under the names **Cut Cross Entropy** or **Liger Fused Linear Cross Entropy**.
Token chunking slices `[tokens, vocab]` by rows. Vocab chunking slices it by
columns and combines chunks with online logsumexp so the full logits matrix is
never live.
