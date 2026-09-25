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
`trainDiffusionLora` returns caller-owned LoRA parameters to save and dispose. An optional seventh argument `{ signal }` cancels cooperatively at the boundaries: on entry, before every optimizer step, and once more after the last step and after every checkpoint write has completed. A cancellation observed at a boundary rejects with the signal's reason, detaches the caller's model, keeps checkpoints saved earlier on disk (the adapter directory then holds `metrics.jsonl` and those checkpoints, no final adapter), and writes no final adapter. Starting the final save is the commit point: a signal arriving after it does not stop the complete save, and the run reports success. Steps themselves are never interrupted, so numerics are unchanged.

Opt-in native checks over a caller-supplied cached snapshot (`MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot dir>`; skipped before any native import otherwise) restore main's end-to-end training assertions under `tests/native/`: SFT loss decrease with a mountable adapter that changes greedy generations, batched training with per-row masking parity, ORPO with reported accuracy, and regularization (dropout, rsLoRA, LoRA+, segmented backward). The weight-free finite-difference and VJP checks live in `@mlx-bun/mlx`.

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
The native command opts in with `MLX_BUN_TEST_NATIVE=1`; Mac CI runs it after
staging natives. Bare test discovery skips those tests before native imports.
An explicitly requested native run fails if its native installation is missing.

Inherited experimental selectors remain in the [trainer](src/trainer.ts),
[segmented backward](src/segmented.ts), [loss](src/loss.ts), and
[flash CCE kernel](src/kernels/flash-cce.ts). Record their `MLX_BUN_*` settings
with numerical evidence. `MLX_BUN_MEM_LOG` and `MLX_BUN_SEG_MEM_LOG` enable
diagnostic console output independently of the progress callback.


[Adapter merge ownership tests](tests/native/merge.test.ts) additionally check
exact synthetic merged tensors and cleanup after source, materialization,
concatenation, and native-map allocation failures. This is a resource-lifetime
check; real-model adapter fusion/export remains separate verification.
