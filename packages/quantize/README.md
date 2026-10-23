# @mlx-bun/quantize

Produces the quantized checkpoints that [`@mlx-bun/inference`](../inference/README.md)
loads and builds its graphs for. Inference never quantizes; this package never serves.

| Module | Owns |
| --- | --- |
| `quantizer` | Quantize a checkpoint directory: per-module bit selection, dequantize/requantize through MLX, sharded output, config rewrite |
| `convert` | Non-quantizing rewrite of a checkpoint: cast floating tensors to one dtype and/or dequantize quantized modules to dense weights (`mlx_lm.convert` without `-q`) |
| `allocator` | Mixed-precision allocation from per-layer sensitivity under a bits-per-weight budget |
| `sensitivity` | Exact per-layer KL sensitivity on calibration text |
| `calibration` | Calibration sample loading and tokenization |
| `drafter` | Quantize a released DeepSpec (`Gemma4DSparkModel`) drafter: every matmul weight and gather table, `confidence_head` kept bf16, then a load smoke through the drafter loader |
| `moss-image` | Quantize a MOSS-Image snapshot (Base or SFT) into a local MLX pipeline directory: the DiT's joint-block projections and the conditioner's projections and token embedding at the requested affine bits, the rest kept or copied |
| `rotate`, `weight-transform` | Rotation and fold plans for Llama and Qwen families before quantization |
| `trellis` | Trellis state packing, interleaving, and the host decoder. The 1MAD codebook and word geometry are imported from the inference kernels, which own the packed format |
| `trellis-quantizer` | `quantizeTrellisModelDir`: fold an HF-layout Qwen3.5-family checkpoint (γ + R1), code every MLP tensor with the Trellis (QTIP TCQ, L=12, 1MAD, T=256, tail-biting) and write the packed format the inference kernels serve; the rest keeps the shipped-compact affine tiers. `turboquant_fold.json` records the R1 seed and the final-norm gain the fold moved into the head, the residual basis a drafter reads through the graph |
| `trellis-encoder` | The Viterbi encode of one folded tensor into packed codes and fp16 row scales, unweighted or with BlockLDLQ error feedback against a Hessian factor |
| `trellis-allocation`, `qwen35-hf-fold` | Pure planning: which tensor gets which treatment (k-map, axis, layer limit) and the fold plan for the `model.language_model.*` layout with stored γ−1 norms |
| `config-writer`, `atomic-output` | Quantization metadata and atomic directory publication |

Sharded safetensors writing lives in `@mlx-bun/inference/artifacts` and is
re-exported here for convenience. Auxiliary checkpoint file copying lives in
`@mlx-bun/inference/artifacts/auxiliary-files`; `config-writer` re-exports
`copyAuxFiles` for compatibility.

Executed usage lives in the package tests: [weight-transform-plan](tests/weight-transform-plan.test.ts)
plans a fold, [weight-transform-numerics](tests/weight-transform-numerics.test.ts) applies one, and
[trellis-roundtrip](tests/trellis-roundtrip.test.ts) packs states here and expands them with the
inference kernels. `quantizeModelDir(sourceDirectory, outputDirectory, { bits, groupSize })`
is the entry point for a whole checkpoint; it needs a real one.

`quantizeDrafterDir(sourceDirectory, outputDirectory, { bits, groupSize })` applies the drafter policy
(the confidence head's sigmoid is compared against thresholds, so it stays bf16); drafter numerics move
acceptance, never correctness, so gate the result with `scripts/drafter-ab.ts`. A [synthetic DeepSpec
checkpoint test](tests/drafter.test.ts) covers the policy and refusals; a released drafter is not run here.

`quantizeMossImageDir(sourceDirectory, outputDirectory, { bits, groupSize })` applies the
quantizer per pipeline component. It quantizes the DiT's 252 joint-block projections
(`layers.N.proj.*`; the embedders, timestep MLP, modulations, text refiner and video head
stay bf16, the allocation unsloth's MOSS-Image INT8 release uses) and the conditioner's
projections and token embedding (its DeltaNet `in_proj_a`/`in_proj_b` stay bf16), and copies
the VAE, tokenizer, scheduler and index. It refuses anything but a full-precision MOSS-Image
layout before writing, and publishes the directory atomically. A
[synthetic snapshot test](tests/moss-image.test.ts) loads the output through the family's graphs
against the full-precision graphs. On Base `85975793` (2026-10-23, M4 Pro), 8-bit group 64 took
35 s and wrote 15.31 GB (14.26 GiB: DiT 5.71 GB, conditioner 9.35 GB, VAE 0.25 GB; 8.5 bits
per quantized weight). Measured with the conditioner's earlier linear-attention layers (tree
`4c527080`, before they were rewritten to the reference's dtypes), against the bf16 graphs
from identical inputs the conditioner's hidden states differ by 2.5e-2 / 3.4e-2 relative
(minimum token cosine 0.9986), the velocity by 8.5e-3 at step 0 and
1.9e-2 at step 4, the 8-step trajectory by 1.17e-1, and the decoded 256x256 image by
29.9 dB PSNR. Those are this graph's quantization error, measured separately from the
reference comparison; no quality evaluation has been run.

`quantizeTrellisModelDir(sourceDirectory, outputDirectory, options)` produces a packed
Trellis artifact from a full-precision `model.language_model.*` checkpoint (Qwen3.8-27B
layout; a quantized source is refused). `bits` sets k for every coded tensor; `kMap`
(an allocation file's `budgets[budget]`) sets it per tensor and may raise affine tiers;
`downAxis: "in"` codes down_proj along the un-rotated dim; `layers` codes only the first
N layers; `interleave` reorders eligible k=3 axis-0 codes for the scatter kernel; `reuse`
copies tensors of unchanged geometry from earlier packed artifacts, so a new allocation
encodes only the tensor/k pairs no source holds; `ldlq` names a directory of per-layer
Hessian factors (`layer-NNN-mlp.safetensors` for gate/up, `layer-NNN-down.safetensors`,
each holding one tensor `L`, the block-LDL factor of that site's input Hessian in the
folded basis) and switches the objective to BlockLDLQ with a guard that falls back to the
unweighted codes for any tensor whose feedback grows past 4x the unweighted magnitude.
The Hessian factors and the k-map are inputs: collecting activation Hessians runs a
calibration forward pass and is not part of this package. The encoder is numerically
the frozen producer's (`02d723a:scripts/turboquant/tq-quantize-trellis-packed.ts`);
[trellis-quantizer](tests/trellis-quantizer.test.ts) runs the whole path on a synthetic
checkpoint, [trellis-encoder](tests/trellis-encoder.test.ts) checks the codec and the
LDLQ arm, and [trellis-allocation](tests/trellis-allocation.test.ts) the planning.

Job orchestration and the CLI verbs belong to the app's modules: `mlx-bun convert --q-mode trellis` to [`@mlx-bun/module-quantize`](../module-quantize/README.md), `mlx-bun draft quantize` to [`@mlx-bun/module-train`](../module-train/README.md).

