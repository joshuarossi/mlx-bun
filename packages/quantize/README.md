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
| `drafter` | Quantize a released DeepSpec (`Gemma4DSparkModel`) drafter: every matmul weight and gather table, `confidence_head` kept bf16, then a load smoke through the drafter loader |
| `rotate`, `weight-transform` | Rotation and fold plans for Llama and Qwen families before quantization |
| `trellis` | Trellis state packing, interleaving, and the host decoder. The 1MAD codebook and word geometry are imported from the inference kernels, which own the packed format |
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

Job orchestration and the CLI verb belong to the app.

