# @mlx-bun/module-train

Training as an application module (`AppModule<"jobs" | "storage" | "catalog">`, design:
[Modular application](../../ARCHITECTURE.md#modular-application)). It declares the `finetune` job
(`isolation: "process"`, `gpu: "exclusive"`: a child that stops with its parent, holding the host's execution
lease so no model generates meanwhile), two HTTP routes at their shipped `/api/finetune/*` paths, the `train`,
`train-watch`, `fuse` and `draft` verbs (and, through the host's verb table, the `mlx-bun.lora` and `mlx-bun.fuse`
aliases) and three storage entries: `adapters/`, and `models/` and `datasets/`, which it shares with the
quantize and datasets modules (two modules that declare the same entry, one path and kind, share it). The
numerical work is `@mlx-bun/training` (and `@mlx-bun/quantize` for `draft quantize`); the module only
orchestrates. Nothing here imports an app or another module. `apps/mlx-bun` installs it.

## Routes and job

- `POST /api/finetune/inspect-dataset`: counts a dataset directory's train and validation rows and detects
  its format (`src/inspect.ts`), without loading MLX.
- `POST /api/finetune/submit`: queues a `finetune` job. HTTP owns the request and output-path policy: an
  explicit `adapter_path` wins, else a fresh `adapter-<time>-<uuid>` directory in the `adapters` entry.

`src/job.ts` is the job's runner and `src/config.ts` maps the submit record onto the library's `TrainConfig`
(library defaults are supplied by the trainer, not copied here). It preserves main's ORPO recipe (flash-CCE
head, prefix sharing, segmented backward, token-chunked head, with the bf16 head fallback for an unquantized
base). The child restores its wired-memory limit and releases its model and weights on completion or failure;
progress passes through unchanged to job events, and the job owner alone emits the terminal lifecycle event.
A fine-tuning job selects its own model path; the resident inference model's capabilities do not gate it.
The host runs the runner in a child that activates this module itself, so the runner needs nothing from the host.

## Verbs

`train` validates main's flags before any model resolution, resolves the model through the `catalog` (a
directory, a downloaded model, or the host's automatic choice when none is named), preflights the dataset,
prints the plan and drives `createFinetuneRunner` in this process (`--dry-run` stops at the plan). SIGINT/SIGTERM
abort at the next optimizer-step boundary, after any checkpoint writes already started have completed;
cancellation detaches training state and releases its resources, and completed checkpoints remain usable. A
final save already started is allowed to finish and is reported as success. It writes
`~/.mlx-bun/adapters/<method>-<model>` unless `--adapter` is given. `mlx-bun.lora` is mlx_lm.lora's spelling
of it (the alias table is the host's).

`train-watch` (`src/watch.ts`) tails the trainer's `<adapter>/metrics.jsonl` (default: the most recently
updated run in `adapters/`).

`fuse` merges an adapter through `fuseAdapter` into `--save-path` (default `~/.mlx-bun/models/<model>-fused`,
refused if it exists); `--dequantize` writes dense weights for every quantized module and drops the
quantization block, and `--upload-repo` checks the write token first and pushes the finished model through the
catalog as `convert` does. GGUF export (`--export-gguf`, `--gguf-path`) is refused. The merge cannot be
interrupted, so a signal arriving during it lets the output finish (without pushing) rather than leaving a
partial directory. Fuse belongs here rather than with the models: it consumes a training product and is the
other half of `train`, and `mlx-bun.fuse` is mlx_lm.fuse's spelling.

`draft <regen|train|calibrate|quantize>` produces the drafters `serve --draft-model` mounts, thin over
`@mlx-bun/training/dspark` and `@mlx-bun/quantize/drafter`. A drafter is a small model trained against one
frozen target on the GPU, so it lives with the other training verbs; serving loads it through the engine's draft
provider registry, which this module does not touch. It validates flags before resolving or loading anything,
resolves the target like `train`, runs one stage in the foreground and prints progress. `regen` writes shards
to `~/.mlx-bun/datasets/dspark-<model>`, `train` a drafter directory to `~/.mlx-bun/models/<model>-dspark`,
`quantize` `~/.mlx-bun/models/<drafter>-affine-q<bits>-g<group>` (refused if it exists), and `calibrate` rewrites
the drafter's `dspark.json` in place (refused when it already carries thresholds unless `--force`).
`--tap-layers` defaults to gemma-4 e4b's `20,31,41,42`; other targets pass their own, identical for `regen` and
`train`. SIGINT/SIGTERM stop at the next topic, step or prompt. The acceptance gate for a drafter is
`bun scripts/drafter-ab.ts`, which serves each drafter through `--command` and compares `usage.speculation`.

## Not in the module yet

- Adapter merge and export (`POST /api/finetune/merge`, `/export`, `apps/mlx-bun/src/server/adapter-artifact-routes.ts`)
  are training's by ownership but stay in the app: merge runs native MLX under the engine's execution lock in
  the process that holds the model, and this module activates in the persistent state, which under `--isolate`
  loads no native code. They move with the model host (PLAN item (e)), whose combined service lends a lease.
- The browser's fine-tune wizard (`apps/mlx-bun/src/web/browser/finetune.ts`) stays in the app until the web
  shell exists: it is built from the shell's DOM helpers, toast, controllers and push-to-Hub panel, so it cannot
  yet be a self-contained `mlx-train-panel`. The adapter picker and mount routes (`/v1/adapters*`) are the
  future models module's.

## Tests

The package's tests run the routes, the runner, the verbs, the dashboard renderer and the module's activation
over fakes: a fake native runtime, an injected training library, a recording catalog and terminal. They do not
train real weights. The spawned CLI (native MLX blocked) is exercised in the app
(`apps/mlx-bun/tests/train-cli.test.ts`); the opt-in
[fine-tune preservation test](../../apps/mlx-bun/tests/engine/finetune-preservation.test.ts)
(`MLX_BUN_TEST_NATIVE=1 MLX_BUN_APP_TEST_FINETUNE_REFERENCES=<ref.json>[:…]`) runs this producer on each submit
record main's producer ran, for any family or training path, and requires main's metrics, config files, adapter
and checkpoint tensors, fresh-reload logits, and optionally its `fuse` output exactly; its header gives the
commands that produce the references outside the repository. The opt-in `managed-jobs.test.ts` runs a real
fine-tune job, a spawned `train` interrupted by SIGINT, and `fuse` on cached weights. These CPU checks do not
extend the numerical claims in the [training evidence](../training/README.md).
