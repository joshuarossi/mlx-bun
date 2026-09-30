# @mlx-bun/module-quantize

Quantization as an application module (`AppModule<"jobs" | "storage" | "catalog">`, design:
[Modular application](../../ARCHITECTURE.md#modular-application)). It declares the `quantize` job
(`isolation: "process"`, `gpu: "exclusive"`: a child that stops with its parent, holding the host's
execution lease so no model generates meanwhile), three HTTP routes under `/api/quantize`, the
`convert` verb (and, through the host's verb table, the `mlx-bun.convert` alias) and one storage entry,
`models/`. The numerical work is `@mlx-bun/quantize`; nothing here imports an app or another module.
`apps/mlx-bun` installs it.

## Routes and job

- `POST /api/quantize/inspect`: whether a model is quantizable and its size, from its config and the
  `catalog` entry (no tensor bytes).
- `POST /api/quantize/resolve-folder`: where a folder the browser's picker selected lives, from the
  catalog's `locate` (hub cache snapshot, the models directory, or an indexed model).
  `/api/model/resolve-folder` is the same question asked by the fine-tune wizard; the app answers it.
- `POST /api/quantize/submit`: names a plain model directory under the `models/` storage entry
  (`<name>-<bits>bit`, `-mixed-<bpw>bpw`, `-rot<seed>`; the same request names the same directory, which the
  producer refuses to overwrite) and submits the `quantize` job.

`src/job.ts` is the job's runner: uniform affine, mixed precision (OptiQ sensitivity sweep and knapsack),
rotation, `--dtype` casts, dequantization and packed Trellis, with the source resolved through the catalog
when the config names a `model_id`. The host runs it in a child that activates this module itself, so the
runner never depends on the host's services beyond `catalog` and `storage`.

## `convert`

`mlx-bun convert <repo-or-path> -q` is main's mlx_lm.convert counterpart: a
local model directory, a downloaded model, or an `org/name` repo id (fetched
first, resumable) is quantized into `--mlx-path` (default
`~/.mlx-bun/models/<model>-<bits>bit`, or `-mixed-<bpw>bpw` with `-rot<seed>`
for a rotated run, named from the resolved source; either must not already
exist) by the same `createQuantizeRunner` producer the web
quantize job runs, as a job child process through the host's `jobs` service (the
sensitivity sweep is synchronous, so only a separate process keeps the parent
responsive; progress is followed from the job's events). `--q-bits 4|8` and `--q-group-size 32|64` select
uniform affine quantization; `--target-bpw` with `--candidate-bits`,
`--calibration-mix`, `--n-calibration`, `--rotate-weights`, and
`--rotation-seed` select the mixed path. `--upload-repo` resolves the write
token before any work and publishes through the catalog's publisher afterwards; an
upload failure keeps the model and prints the retry hint. Without `-q` or
`--target-bpw` the model is rewritten only as asked: `--dtype float16|bfloat16|float32`
casts every floating tensor (a quantized model's scales and biases included; router
and expert biases and SSM decay parameters keep their dtype, as mlx-lm's per-model
cast predicates do) and `-d`/`--dequantize` writes dense weights and drops the
quantization block (`convertModelDir` in `@mlx-bun/quantize`); with `-q`, `--dtype`
is the scales/biases dtype and the dtype of the unquantized tensors (bf16 scales
and unchanged tensors without it). `--q-mode trellis` (implies `-q` and the rotation fold,
seed from `--rotation-seed`) runs `quantizeTrellisModelDir` on a full-precision
`model.language_model.*` Qwen3.5-family checkpoint instead: MLP tensors become packed
Trellis (`~/.mlx-bun/models/<model>-trellis-<k>bit`, or `-trellis-mixed` with a k-map, plus
`-rot<seed>` only when the seed is given) that the engine serves and stock mlx-lm cannot
load. Its options are `--trellis-bits`, `--trellis-k-map` with `--trellis-k-budget`,
`--trellis-ldlq`, `--trellis-reuse`, `--trellis-down-axis`, `--trellis-interleave`, and
`--trellis-layers`; they need `--q-mode trellis`, which refuses `--target-bpw`, `--q-bits`,
`--q-group-size`, `--dtype`, and the calibration options. It codes with Viterbi and is
slow on a full model. `--quant-predicate` and any other `--q-mode` are refused, as are
`-q` with `-d`. Each conversion owns a
private root beside the destination holding the job's result, staging and
temporary probes (its `TMPDIR`); only a complete result is published, by one rename.
SIGINT/SIGTERM stop the job and join its child immediately, even mid-sweep
(SIGKILL after a grace period if it ignores SIGTERM), and on every failure or
cancellation the parent removes only that owned root, never anything inferred
from a name. `src/convert.ts` owns the verb.

## Tests

The package's tests run the routes, the runner and the verb over fakes: an injected producer for the native
work, a recording job service whose "child" is a function (complete-result publish, cancellation joined
before the private root is removed, a failing job, an existing destination left intact), and a recording
catalog (source resolution, downloads with the signal, credential ordering, upload). They do not quantize
real weights. The spawned CLI (native MLX blocked) and the real job child are exercised in the app
(`apps/mlx-bun/tests/convert-cli.test.ts`); the opt-in `managed-jobs.test.ts` runs a real quantize job and a
`convert` on cached weights.

## Panel

`<mlx-quantize-panel>` (`./panel`) owns the existing four-step wizard, its markup and styles in shadow DOM.
The shell mounts it at `/quantize`. It reaches inspection, submission and the job stream through its
`PanelConnection`; optional host `ui` hooks provide notifications, publishing and catalog refresh.
An unfinished job reconnects and replays its stream after returning to the panel; leaving closes the stream
without cancelling the managed job. Panel tests cover inspection, mixed-precision submission, progress,
reconnection and publishing over a remote backend under a URL prefix.
