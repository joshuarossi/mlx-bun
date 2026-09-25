# @mlx-bun/training

Trains and produces adapters for graphs from `@mlx-bun/inference`. The package
owns SFT, DPO, ORPO, diffusion LoRA, training datasets, losses, optimizers,
trainable adapter parameters, and adapter merging, fusion, and export.
Job orchestration, terminal dashboards, and model discovery belong to the app.

`trainLora(model, tokenizer, template, dataDirectory, config, onProgress)` takes
a caller-loaded graph and reads `train.jsonl` plus optional `valid.jsonl`.
It saves mountable adapters at `config.adapterPath`. `TrainingProgress` describes
training observations; an app maps them into its own job events. Callbacks run
synchronously and must not throw. Training borrows the model exclusively and
mutates its adapter/training state; do not infer concurrently on that graph.
`trainDiffusionLora` returns caller-owned LoRA parameters to save and dispose.

| Module | Owns |
| --- | --- |
| `trainer` | Training loops, checkpoint output, progress, and run configuration |
| `dataset`, `rank` | Tokenized SFT/preference batches and adapter rank assignment |
| `lora` | Trainable A/B leaves, attachment, warm start, save, and disposal |
| `optimizer`, `loss` | AdamW, schedules, and differentiable training objectives |
| `prefix-shared`, `segmented` | Specialized shared-prefix forwards and bounded backward passes |
| `kernels/flash-cce` | Callable fused cross-entropy Metal forward/backward kernels |
| `diffusion` | DiffusionGemma's denoising training objective |
| `merge`, `fuse`, `export` | Adapter combination, checkpoint fusion, and export manifests |

These module subpaths are available for composition. The Steel Metal header is
an implementation detail of flash CCE. Full-sequence forward operations remain
in `@mlx-bun/inference/scoring`; autograd remains in `@mlx-bun/mlx/autograd`.
Training consumes those public owners instead of duplicating them.

Run `bun run --filter @mlx-bun/training test` for CPU-only behavior tests.
[Dataset tests](tests/cpu/dataset.test.ts) demonstrate encoding and batching with
caller-supplied tokenizers/templates, and [rank tests](tests/cpu/rank.test.ts)
exercise per-target rank selection. They need no native library or weights.
`bun run --filter @mlx-bun/training test:native` runs the separate numerical
optimizer, accumulation, batching, ORPO, and regularization tests; it uses MLX
and must only run when GPU work is allowed.

The [migration preservation record](measurements/2026-09-25-training-preservation.json)
compares fixed-seed MiniCPM5-1B training against main: three SFT steps, two DPO
steps, and two ORPO steps. Step metrics, every saved A/B tensor, and full-sequence
logits after adapter reload match exactly. These runs cover rank-2 adapters on
the last layer's query/value projections, batch size one, and short sequences.
The 47 native tests also pass, and every public entry imports from installed
package archives. This establishes migration preservation for those paths;
other model families and specialized training paths still need real-weight
evidence. It is not an independent training-oracle or performance claim.
