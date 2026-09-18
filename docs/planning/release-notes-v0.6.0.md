# mlx-bun v0.6.0

The speculative decode round, rebuilt around what the GPU was waiting for. On the
packed Qwen3.8-27B q4b quant (11.99 GB, MTP depth two, KV4) an M4 Pro 24 GB goes
from 18.92 to 20.24 decode tok/s on the frozen 64-item reasoning screen with the
score unchanged at 61/64.

- **Device-first speculative round** (default on, shared batched lane). A 27B
  verify forward is about 2,560 graph nodes built from JavaScript; the round used
  to build it only after reading the draft tokens back, idling the GPU about 3 ms
  per round. The drafts now stay on the device, the verify ids are assembled
  there, and the verify graph is built while the GPU runs the draft chain; drafts
  and window samples come back in one read. Same arithmetic, same draws, same
  decisions: served outputs are byte-identical. GPU active 97.5% -> 99.6%.
  `MLX_BUN_SPEC_DEVICE_ROUND=0` restores the old order.
- **Whole-window sampling.** Requests whose token choice depends only on a
  position's scores and its `(seed, step)` key (temperature, top-p, top-k, min-p,
  no penalties, grammar or logprobs) sample every verify position in one graph,
  with top-p and top-k batched across the window. Bit-identical per row at
  248,320 vocabulary entries.
- **Frequency-ranked draft vocabulary** (FR-Spec). The native MTP drafter can
  project onto a frequency-ranked subset of the target's vocabulary head instead
  of all of it: 3.02 -> 0.93 ms per draft step at 65,536 of 248,320 rows, with
  acceptance unchanged. The target still verifies and samples over the full
  vocabulary, so the output distribution does not change. A list shipped beside
  the draft companion as `draft_vocab.json` loads automatically;
  `MLX_BUN_SPEC_DRAFT_VOCAB=<path>` selects one and `=0` turns it off. A token
  outside the list cannot be drafted, so text far from the list's corpus drafts
  worse than the full head would.
- **A purpose-built graph per published quant.** Loading the published
  Qwen3.8-27B packed-Trellis q4b quant selects a hand-written graph by a
  fingerprint of the architecture and the complete per-tensor quantization table;
  every other artifact keeps the generic model. Two kernel substitutions in it are
  bit-identical to what they replace, each made by reproducing the MLX kernel's
  arithmetic in the same type: one fused gate/up kernel for the layers whose gate
  and up projections were allocated different bit widths (0 differing of
  6,963,200 outputs; 1.23 ms per verify forward), and DeltaNet's q/k scale carried
  as the weight of the norm before it (96 fewer kernels per forward).
  `MLX_BUN_QWEN38_TQ_GRAPH=0` is the control.
- Measured and left as default-off flags: greedy drafts, a separate draft
  temperature and unfiltered drafts. Greedy drafts lower acceptance under a
  sampled request, because draft and target draw by inverse CDF from the same
  per-step key and an argmax draft discards that coupling.
- Round diagnostics: `MLX_BUN_SPEC_PHASE_TIMING`, `MLX_BUN_SPEC_LAYER_PROFILE`
  and `MLX_BUN_SPEC_OP_INVENTORY` report draft/verify/sample/commit time, the
  verify forward by component, and graph nodes per round in
  `usage.speculation.phaseMs`.
- N-gram proposals keep an incremental position index per history instead of
  scanning it each round.
- Benchmark tooling: the serial HTTP campaign runner, sandboxed scorer and
  report scripts used for the Qwen3.8 publication program; the Trellis quantizer
  accepts a bank of packed artifacts to reuse and a per-tensor affine bit map.

Native pack unchanged: `native-v0.5.0`.
