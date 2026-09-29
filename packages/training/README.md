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

Opt-in native checks over a caller-supplied cached snapshot (`MLX_BUN_TEST_NATIVE=1 MLX_BUN_TRAINING_MODEL=<snapshot dir>`; the DiffusionGemma LoRA check reads `MLX_BUN_TRAINING_DIFFUSION_MODEL=<DiffusionGemma snapshot dir>` instead; skipped before any native import otherwise) restore main's end-to-end training assertions under `tests/native/`: SFT loss decrease with a mountable adapter that changes greedy generations, batched training with per-row masking parity, ORPO with reported accuracy, regularization (dropout, rsLoRA, LoRA+, segmented backward), and DiffusionGemma LoRA denoising-loss decrease with an adapter that changes the canvas logits, then saves it, mounts it on a fresh graph, and requires the in-memory adapter's exact canvas logits and seeded generations (`MLX_BUN_TRAINING_DIFFUSION_ADAPTER_OUT=<new directory>` keeps that adapter for the app's serving check). `MLX_BUN_TRAINING_DIFFUSION_MODEL` set without `MLX_BUN_TEST_NATIVE=1`, or naming a directory that is not a `diffusion_gemma` snapshot, fails instead of skipping. `MLX_BUN_TRAINING_QWEN35_MODEL=<Qwen3.5 snapshot dir>` runs the all-layer SFT and padded-batch checks through the gated-DeltaNet recurrence (its backward is checked weight-free in `@mlx-bun/inference`). The weight-free finite-difference and VJP checks live in `@mlx-bun/mlx`.

| Module | Owns |
| --- | --- |
| `trainer` | Training loops, checkpoint output, progress, and run configuration |
| `dataset`, `rank` | Tokenized SFT/preference batches and adapter rank assignment |
| `lora` (`lora-params.ts`) | Trainable A/B leaves, attachment, warm start, save, and disposal |
| `optimizer`, `loss` | AdamW, schedules, and differentiable training objectives |
| `declared` | The graph's declared training operations the other modules consume |
| `prefix-shared`, `segmented` | Shared-prefix losses and bounded backward drivers, generic over the graph's declaration |
| `kernels/flash-cce` | Callable fused cross-entropy Metal forward/backward kernels |
| `diffusion` (`diffusion-lora.ts`) | DiffusionGemma's denoising training objective |
| `merge`, `fuse`, `export` | Adapter combination, checkpoint fusion, and export manifests |
| `dspark/` | Drafter production: shards, the DSpark objective, the training loop, STS calibration |

Training consumes a graph only through the `trainable` declaration
(`TrainableGraph` in `@mlx-bun/inference/contracts`), never a model class:
`lmHead`, `segmented`, `prefixShared`, `gradCheckpoint`, `flashAttention` and
`denoising`. The graph owns how its layers run in segments, its prefix-shared
mask and RoPE, its checkpointing, and which reused K/V crosses segment boundaries;
the drivers here own the autograd. A run that needs an operation the graph does not
declare fails with "the graph does not declare ...". Gradient checkpointing is a
memory-for-compute hint, so a graph without it trains without and reports that in a
setup stage. Gemma 4 and MiniCPM5 declare the parts above they implement, and
DiffusionGemma the denoising objective; the architecture gate rejects concrete
model imports and model-class `instanceof` in this package.

`@mlx-bun/training/dspark` produces the drafters `--draft-model` mounts (the DSpark/DFlash
KV-injection module of `@mlx-bun/inference`), in three stages that share one frozen target.
`regenDrafterData(model, tokenizer, template, topics, { outDir, tapLayers })` has the target
answer each topic with its own greedy generation (`generate`) and records the tapped layers'
hiddens over each full sequence through the speculative target binding, as shards.
`trainDrafter(model, config, onProgress?, signal?)` trains the drafter on those shards with
`dsparkLoss` (weighted CE, total variation to the target's distribution recomputed from the
stored final hiddens, and confidence BCE against the analytic acceptance) and saves the best
held-out expected accepted length (τ) as `<outDir>` (`dspark.json`, `model.safetensors` and a
`config.json` whose `dspark_assistant` type marks it a companion `--draft-model` resolves by
path). `calibrateDrafter` runs speculative generations through a provider that drafts the
unpruned block, fits per-position confidence thresholds with `fitStsThresholds`, and
`writeSts` sets them in `dspark.json`. The target is any graph declaring hidden-layer taps and
the draft projection (`embed`, `logitsFromHidden`); `tapLayers` must be identical for regen
and train (shards record them, and a mismatch is refused). Losses, shard sampling geometry,
seeded reproducibility, resume and the calibration provider have [synthetic-target
tests](tests/native/dspark.test.ts); the fit's math is a [CPU test](tests/cpu/dspark-sts.test.ts).
`mlx-bun draft` is the CLI over these.

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
