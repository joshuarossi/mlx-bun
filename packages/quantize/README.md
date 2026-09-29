# @mlx-bun/quantize

Produces the quantized checkpoints that [`@mlx-bun/inference`](../inference/README.md)
loads and specializes on. Inference never quantizes; this package never serves.

| Module | Owns |
| --- | --- |
| `quantizer` | Quantize a checkpoint directory: per-module bit selection, dequantize/requantize through MLX, sharded output, config rewrite |
| `convert` | Non-quantizing rewrite of a checkpoint: cast floating tensors to one dtype and/or dequantize quantized modules to dense weights (`mlx_lm.convert` without `-q`) |
| `allocator` | Mixed-precision allocation from per-layer sensitivity under a bits-per-weight budget |
| `sensitivity` | Exact per-layer KL sensitivity on calibration text |
| `calibration` | Calibration sample loading and tokenization |
| `rotate`, `weight-transform` | Rotation and fold plans for Llama and Qwen families before quantization |
| `trellis` | Trellis state packing, interleaving, and the host decoder. The 1MAD codebook and word geometry are imported from the inference kernels, which own the packed format |
| `trellis-quantizer` | `quantizeTrellisModelDir`: fold an HF-layout Qwen3.5-family checkpoint (γ + R1), code every MLP tensor with the Trellis (QTIP TCQ, L=12, 1MAD, T=256, tail-biting) and write the packed format the inference kernels serve; the rest keeps the shipped-compact affine tiers |
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

Job orchestration and the CLI verb (`mlx-bun convert --q-mode trellis`) belong to the app.

