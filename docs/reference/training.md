# Training / fine-tuning reference

How to fine-tune a served model with LoRA adapters: the commands, the data
formats, every config field, the long-context memory stack, and the
methodology behind the knobs.

mlx-bun trains **LoRA adapters** (the base quantized weights stay frozen),
supports **SFT**, **DPO**, and **ORPO**, and runs on a single Apple-Silicon
GPU. The output is a PEFT-compatible adapter directory you mount into the
server (`mlx-bun serve <model> --adapter <dir>`) or fold into the base
weights (`mlx-bun fuse`).

> Source of truth: `mlx-bun train` in [`src/cli.ts`](../../src/cli.ts)
> (flags + defaults), the submit schema `FinetuneSubmit` in
> [`src/train/job.ts`](../../src/train/job.ts), and `DEFAULT_TRAIN_CONFIG` in
> [`src/train/trainer.ts`](../../src/train/trainer.ts). If this doc and the
> code disagree, the code wins.

## Entry points

Every path drives the **same** runner (`finetuneRunner` in `src/train/job.ts`):

| Path | How | Use when |
|---|---|---|
| **CLI** | `mlx-bun train <model> --data <dir> [options]` — foreground, streams loss to the terminal, ORPO with the full memory stack by default. `mlx-bun help train` lists every flag. | **The default.** |
| **Live dashboard** | `mlx-bun train-watch <adapter-dir>` — tails `<adapter-dir>/metrics.jsonl` from another terminal. | Watching a detached run |
| **Fuse** | `mlx-bun fuse <model> --adapter <dir> [--save-path <out>]` — fold the adapter into the base weights → standalone snapshot. | Shipping a merged model |
| **Web app** | The Fine-tune tab (`#/finetune`, behind the app's Developer toggle): model → dataset → hyperparameters → train, live train/val loss, merge/export. | Interactive |
| **HTTP API** | `POST /api/finetune/{inspect-dataset,submit,merge,export}` — same runner as a subprocess job with SSE events; documented in [server-api.md](server-api.md). | Scripted / remote |
| **ORPO launcher** | [`scripts/train-orpo.ts`](../../scripts/train-orpo.ts) — the CLI's ORPO stack driven by env vars (`MODEL=`, `DATA=`, `SEQ=`, `SEG=`, `RESUME=`, …). | Env-var scripting |
| **Library** | `import { finetuneRunner } from "./src/train/job"` (snake_case submit record + event emitter) or `trainLora` / `DEFAULT_TRAIN_CONFIG` from `./src/train` (camelCase `TrainConfig`). | Embedding training in your own TS |

The CLI and the launcher run in-process in the foreground; the web app and
HTTP API run the job as a subprocess (crash isolation, one GPU lease across
concurrent server requests).

## Quickstart — ORPO on preference data

ORPO is the CLI default: reference-free, two forwards per step, and the
whole long-context stack (flash-CCE head + prefix-sharing + segmented
backward) is on unless you turn pieces off.

**1. Data.** `--data <dir>` must contain `train.jsonl` (+ optional
`valid.jsonl`); rows are `{"prompt": "...", "chosen": "...", "rejected": "..."}`
(`prompt` may also be a chat-messages array — it is rendered through the
model's chat template). To build one from UltraFeedback:

```bash
# <input.jsonl> = HuggingFaceH4/ultrafeedback_binarized exported to JSONL (you fetch it)
bun scripts/curate-ultrafeedback.ts <input.jsonl> ./prefs [maxTokens=2048] [valFrac=0.02]
```

**2. Plan without training.** `--dry-run` inspects the dataset (counts,
detected format) and prints the resolved plan box: model, loop knobs, head,
stack, adapter path.

```bash
mlx-bun train e4b --data ./prefs --dry-run
```

**3. Train — detached from your own shell.** The command blocks and streams
per-step loss, s/step, and peak memory until done. Save a mountable
checkpoint every N steps so a crash costs you nothing, and put the adapter
somewhere the server discovers it (see [Outputs](#outputs)).

```bash
nohup mlx-bun train e4b --data ./prefs --iters 1000 --save-every 200 \
  --adapter ~/.cache/mlx-bun/adapters/my-e4b > train.log 2>&1 &
```

**4. Watch it from another tab.**

```bash
mlx-bun train-watch ~/.cache/mlx-bun/adapters/my-e4b
```

**5. Resume** warm-starts the LoRA weights from a checkpoint or adapter dir
(optimizer state + LR schedule restart; rank/targets must match).

```bash
mlx-bun train e4b --data ./prefs --iters 500 \
  --resume ~/.cache/mlx-bun/adapters/my-e4b/checkpoints/step-00200-val<loss> \
  --adapter ~/.cache/mlx-bun/adapters/my-e4b-2
```

**6. Serve or fuse.**

```bash
mlx-bun serve e4b --adapter ~/.cache/mlx-bun/adapters/my-e4b
mlx-bun fuse e4b --adapter ~/.cache/mlx-bun/adapters/my-e4b --save-path ./my-e4b-merged
mlx-bun serve ./my-e4b-merged
```

`<model>` is a registry query or a snapshot path (`e4b`, `MiniCPM5`, …);
omit it to auto-pick the default model. Per-model defaults: Gemma/e4b gets
`--seq 8192`, everything else `4096`. ORPO defaults `--rank 16 --scale 2.0
--seg 2`; SFT/DPO default `--rank 8 --scale 1.0` and **no** segmented
backward unless you pass `--seg <n>`.

Measured memory/throughput for these runs live in
[benchmarks.md](benchmarks.md) — this doc records only the ceilings that
decide whether a run fits (see [Sequence-length ceilings](#sequence-length-ceilings-measured)).

### `mlx-bun train` flags

| Flag | Default | Meaning |
|---|---|---|
| `--data <dir>` | required | dataset dir with `train.jsonl` (+ `valid.jsonl`) |
| `--method <m>` | `orpo` | `sft` · `dpo` · `orpo` |
| `--adapter <dir>` | `~/.cache/mlx-bun/mlx-bun-finetunes/<method>-<model>` | output adapter dir (`<model>` = `e4b` for Gemma, else `cpm5`) |
| `--iters <n>` | 100 | training iterations |
| `--lr <f>` | orpo 1e-5 · dpo 5e-5 · sft 2e-4 | learning rate (ORPO/DPO: cosine schedule; ORPO warmup = min(10, iters/10)) |
| `--rank <n>` | orpo 16 · else 8 | LoRA rank (`by_bits`-scaled per layer) |
| `--scale <f>` | orpo 2.0 · else 1.0 | LoRA scale |
| `--seq <n>` | gemma 8192 · else 4096 | max sequence length |
| `--batch <n>` | 1 | batch size |
| `--grad-accum <n>` | 1 | gradient accumulation steps (effective batch = batch × grad-accum at batch-1 memory) |
| `--grad-clip <f>` | 1.0 | gradient-norm clip (0 = off) |
| `--seed <n>` | 0 | data-shuffle / init seed |
| `--val-size <n>` | 256 | max validation examples per eval |
| `--lambda <f>` | 0.1 | ORPO odds-ratio weight |
| `--sft-scope <s>` | `full` | ORPO chosen-NLL scope: `full` (paper/TRL-faithful prompt+response) · `response` (pre-2026-07 runs, bit-exact) |
| `--seg <n>` | orpo 2 · else 0 | layers per segment (segmented backward) |
| `--no-segment` | — | disable the segmented backward (all activations resident) |
| `--save-every <n>` | off | crash-safe mountable checkpoint every n steps (turns on `save_checkpoints`; eval runs at the same cadence) |
| `--resume <dir>` | — | warm-start LoRA weights from a checkpoint/adapter dir |
| `--no-flash` | — | ORPO: use the MLX fused linear-CE head instead of the flash-CCE Metal head |
| `--no-prefix` | — | ORPO: disable prefix-sharing (two-forward branches) |
| `--dry-run` | — | inspect the dataset + print the plan, don't train |

The CLI always sets `rank_scaling: by_bits`, `num_layers: -1`,
`steps_per_report: 1`, and for ORPO `orpo_chunk_size: 512` plus
`orpo_flash_ce` / `orpo_fused_ce` / `orpo_prefix_shared` from the flags
above. Anything not exposed as a flag (`lora_dropout`, `rs_lora`,
`lora_plus_ratio`, `grad_checkpoint`, `target_modules`, …) is reachable
through the submit record — see [Configuration reference](#configuration-reference).

### The launcher (env-var alternative)

[`scripts/train-orpo.ts`](../../scripts/train-orpo.ts) runs the identical
ORPO stack from env vars. `MODEL` is a snapshot **path** (a dir with
`config.json`), not a query.

```bash
MODEL=<snapshot-dir> DATA=./prefs ITERS=200 bun scripts/train-orpo.ts
```

| Env | Default | Meaning |
|---|---|---|
| `SEQ` | e4b 8192 · cpm 4096 | max sequence length |
| `SEG` | 2 | layers per segment; `SEGOFF=1` disables the segmented backward |
| `ITERS` / `LR` | 100 / 1e-5 | iterations / learning rate (cosine + short warmup) |
| `RANK` / `SCALE` | 16 / 2.0 | LoRA rank (by_bits scaled) / scale |
| `LAMBDA` | 0.1 | ORPO odds-ratio weight |
| `SFT_SCOPE` | `full` | `full` · `response` (as `--sft-scope`) |
| `FLASH=0` | (on) | MLX fused head instead of the flash Metal head |
| `PREFIX=0` | (on) | disable prefix-sharing |
| `SAVE_EVERY` | 0 (off) | mountable checkpoint every N steps |
| `RESUME` | — | adapter/checkpoint dir to warm-start from |
| `ADAPTER` | `~/.cache/mlx-bun/mlx-bun-finetunes/orpo-<e4b\|cpm5>` | output dir |

## Data formats

Each row of `train.jsonl` (and optional `valid.jsonl`) is auto-detected by
its keys ([`src/train/dataset.ts`](../../src/train/dataset.ts)):

| Format | Shape | Loss boundary |
|---|---|---|
| `messages` | `{"messages": [{"role","content"}, …]}` | response-only — loss on the final turn; prompt = chat-template render of all prior turns |
| `prompt-completion` | `{"prompt": "...", "completion": "..."}` | loss on the completion only |
| `text` | `{"text": "..."}` | full-sequence (no prompt mask) |
| `preference` *(dpo / orpo)* | `{"prompt", "chosen", "rejected"}` | preference loss on chosen vs rejected; `prompt` may be a string or a messages array |

`mlx-bun train --dry-run` (or `POST /api/finetune/inspect-dataset`) reports
`n_train`, `n_valid`, and the detected format before any weights load.

## SFT vs DPO vs ORPO

- **SFT** (`--method sft`) — supervised fine-tune; response-only
  cross-entropy. Default LR `2e-4`. Instruction-following, formatting, task
  adaptation. Segmented backward is available (`--seg <n>`) but off by
  default.
- **DPO** (`--method dpo`) — Direct Preference Optimization on
  chosen/rejected pairs; loss `-log σ(β·((π_c − ref_c) − (π_r − ref_r)))`
  with reference log-probs computed at LoRA scale 0 (4 forwards/step).
  Default LR `5e-5`. Tune with `dpo_beta`, `dpo_warmup_iters`,
  `dpo_lr_schedule`. No segmented backward on this path.
- **ORPO** (`--method orpo`, the default) — Odds Ratio Preference
  Optimization (Hong et al. 2024): a **reference-free** objective
  `L = L_NLL(chosen) + λ·L_OR`, `L_OR = -log σ(log_odds)`,
  `log_odds = (ℓ_w − ℓ_r) − (log1mexp(ℓ_w) − log1mexp(ℓ_r))`, where `ℓ` is
  the length-normalized (mean over response tokens) log-prob. `--sft-scope
  full` (default; paper/TRL-faithful) computes `L_NLL` as the token-mean CE
  over the **full prompt+response** of the chosen sequence from the same
  forward; `response` uses `L_NLL = −ℓ_w` (pre-2026-07 behavior, kept for
  reproducing old runs). The odds-ratio terms are response-only in both
  modes. Same data as DPO, no reference model (2 forwards/step). Default LR
  `1e-5` — the loss carries a full NLL term a high LR destabilizes. Design:
  [orpo-training](../design/orpo-training.md).

## The long-context stack (ORPO defaults)

Each piece is independently toggled, composes with the others (all B=1),
and falls back with a logged message when a precondition isn't met.

- **flash-CCE head** (`--no-flash` to disable; `orpo_flash_ce`) — the
  `[M,vocab]`-free cross-entropy head in
  [`src/train/flash-cce.ts`](../../src/train/flash-cce.ts): Apple's Cut
  Cross-Entropy + Liger's fused linear-CE transpiled Triton → Metal, over
  the **quantized** head (in-kernel dequant, MLX steel GEMM tiles, forward
  and backward). Neither the logits nor a dequantized head ever touch HBM,
  so head memory is flat in vocab and sequence length. Batches with
  `M < MLX_BUN_FLASH_MIN_M` (default 1024) auto-take the exact MLX fused
  head, which is faster at short M; `=0` always honors flash. Falls back to
  the fused head when the tiling isn't clean. Two backward skips default ON
  at `1e-5` (`MLX_BUN_CCE_BWD_FILTER_EPS`, the coefficient filter;
  `MLX_BUN_CCE_BWD_BLOCK_EPS`, the lossless cold-block skip); set either to
  `0` for exact gradients.
- **segmented backward** (`--seg <n>` / `--no-segment`; `segment_size`) —
  [`src/train/segmented.ts`](../../src/train/segmented.ts). The forward
  materializes and **detaches** the residual stream every n layers; the
  head is differentiated against the last boundary; then each segment is
  back-propagated in reverse via `mlx_vjp` with the incoming cotangent, so
  only one segment's activations are live. Bit-identical to the plain
  backward on MiniCPM5; bf16-class on e4b. Wired for MiniCPM5 and Gemma4
  (SFT and ORPO); mutually exclusive with `grad_checkpoint`. Design + proofs:
  [segmented-backward-training](../design/orpo-training.md).
- **prefix-sharing** (`--no-prefix`; `orpo_prefix_shared`) —
  [`src/train/prefix-shared.ts`](../../src/train/prefix-shared.ts). One
  forward over `[prompt; chosen; rejected]` with a block-sparse mask and
  block-wise RoPE (each response resets to position P), so the shared
  prompt is encoded once: layer-token cost `2(P+R) → P+2R`. Bit-exact with
  the two-forward path; a big win when the prompt dominates, ~0 when the
  response does. Rows whose chosen/rejected prompts aren't byte-identical
  fall back to two-forward for that row (logged once). MiniCPM5 + Gemma4;
  other models error out rather than silently degrade.
- **gradient checkpointing** (`grad_checkpoint`, API/library only) —
  per-layer recompute; bit-identical. Cheaper than nothing, but it does not
  stream the backward: at long context every layer's recompute is held at
  once, which is what segmented backward fixes. `mlp_split` (Gemma4)
  refines it to attention/MLP halves.
- **warm-start** (`--resume <dir>`; `warm_start_adapter`) — load LoRA
  weights from an adapter/checkpoint dir; optimizer + schedule restart.

## Configuration reference

The snake_case submit record (`FinetuneSubmit`) — what the CLI builds, what
the web app and `POST /api/finetune/submit` accept, and what
`finetuneRunner` takes. `model_dir`, `data_dir`, `adapter_path` are
required; defaults are `DEFAULT_TRAIN_CONFIG` (the CLI overrides several —
see the flags table).

| Field | Type | Default | Effect |
|---|---|---|---|
| `method` | `sft` \| `dpo` \| `orpo` | `sft` | training objective |
| `rank` | int ≥2 | `8` | LoRA rank per adapted linear |
| `scale` | float >0 | `1.0` | LoRA α (effective update = α·BA) |
| `rank_scaling` | `constant` \| `by_bits` \| `by_kl` | `by_bits` | per-layer rank policy (see Methodology) |
| `target_modules` | string[] | `q,k,v,o,gate,up,down _proj` | which linears get adapters |
| `num_layers` | int | `-1` | `-1` = all layers; `N` = last N only |
| `iters` | int >0 | `100` | total training steps |
| `learning_rate` | float >0 | `2e-4` | AdamW LR (CLI: orpo 1e-5 / dpo 5e-5) |
| `max_seq_length` | int >0 | `512` | truncate/pad sequences (CLI: 8192 / 4096) |
| `batch_size` | int ≥1 | `1` | rows per step (B=1 is the no-padding path; B>1 length-sorts + pads to 32) |
| `grad_accumulation_steps` | int ≥1 | `1` | accumulate grads over N micro-steps |
| `seed` | int | `0` | RNG for shuffling + LoRA init |
| `steps_per_report` | int >0 | `10` | train-loss metric every N steps (CLI: 1) |
| `steps_per_eval` | int >0 | `50` | eval on `valid.jsonl` every N steps (CLI: `--save-every`, else never) |
| `weight_decay` | float ≥0 | `0.01` | AdamW weight decay (β = `[0.9, 0.999]`, fixed) |
| `lora_dropout` | float [0,1) | `0.0` | LoRA-input dropout (PEFT-style); mask keyed by step+layer so segmented/checkpointed recompute reproduces it |
| `rs_lora` | bool | `false` | rsLoRA — scale by α/√rank so `rank_scaling` changes capacity, not step size; recorded in the adapter config and honored at inference |
| `lora_plus_ratio` | float ≥1 | `1.0` | LoRA+ — LR multiplier for the B leaves (A stays at base LR); 1 = off |
| `grad_checkpoint` | bool | `false` | recompute layer activations in backward (bit-identical) |
| `mlp_split` | bool | `false` | attention/MLP split inside the checkpoint (Gemma4; needs `grad_checkpoint`) |
| `segment_size` | int | `0` | `>0` = segmented backward, layers per segment (CLI: orpo 2) |
| `save_checkpoints` | bool | `false` | keep every eval-step checkpoint + write `metrics.json` (CLI: on with `--save-every`) |
| `grad_clip_norm` | float ≥0 | `1.0` | global-norm gradient clipping; `0` = off |
| `val_max_examples` | int >0 | `256` | fixed validation subset per eval |
| `warm_start_adapter` | string | `""` | adapter dir to warm-start from (`--resume`) |
| `dpo_beta` | float >0 | `0.1` | DPO strength |
| `dpo_warmup_iters` | int ≥0 | `0` | DPO LR warmup |
| `dpo_lr_schedule` | `constant` \| `cosine` | `cosine` | DPO LR schedule |
| `orpo_lambda` | float >0 | `0.1` | ORPO λ — weights only the odds-ratio term |
| `orpo_warmup_iters` | int ≥0 | `0` | ORPO LR warmup (CLI: min(10, iters/10)) |
| `orpo_lr_schedule` | `constant` \| `cosine` | `cosine` | ORPO LR schedule |
| `orpo_chunk_size` | int | `0` | token-chunk the response head to `[chunk,vocab]`; exact (CLI: 512) |
| `orpo_fused_ce` | bool | `false` | fused linear-CE head: one CustomVjp with the analytic softmax−onehot backward, no retained `[M,vocab]` (CLI: on when `--no-flash`) |
| `orpo_flash_ce` | bool | `false` | route the fused head through the flash-CCE Metal kernel; implies fused (CLI: on) |
| `orpo_prefix_shared` | bool | `false` | shared prompt-prefix single forward (CLI: on) |
| `sft_scope` | `full` \| `response` | `full` | scope of ORPO's chosen-NLL term (`--sft-scope`) |

### Environment variables (training)

| Env var | Default | Effect |
|---|---|---|
| `MLX_BUN_TRAIN_ATTN` | unset → `ops.sdpa` | `ops.sdpa` **is** mlx's fused flash-attention kernel with an exact vjp — the working path. `flash` selects a hand-rolled O(L)-memory kernel: FD-validated at T≤256 (`tests/unit/flash-attention.test.ts`) but ~30× slower, and the trainer **refuses it for Gemma models** (e4b SIGTRAPed at seq ≥2048 and has not been re-validated at that scale). Leave unset. |
| `MLX_BUN_MEM_LOG` | off | `1` prints per-step peak/active/cache memory |
| `MLX_BUN_SEG_MEM_LOG` | off | `1` logs the within-step peak after each segmented phase (forward / head vjp / each segment) |
| `MLX_BUN_SEG_HEAD` | `checkpoint` | bounded head inside the segmented vjp: `checkpoint` (per-chunk recompute) or `fused` |
| `MLX_BUN_SEG_HEAD_CHUNK` | 512 | token-chunk for the segmented SFT head |
| `MLX_BUN_FLASH_MIN_M` | 1024 | rows shorter than this take the exact fused head instead of flash; `0` = always flash |
| `MLX_BUN_CCE_BWD_FILTER_EPS` / `MLX_BUN_CCE_BWD_BLOCK_EPS` | `1e-5` / `1e-5` | flash-CCE backward skips; `0` compiles each out (exact gradients) |

`MLX_BUN_CCE_*` beyond those two (`NOSTEEL`, `BWD_NOSTEEL`, `SCALAR`,
`LANE`, `BWD_SCALAR`, `SG_SKIPDQ`, `BWD_SKIP_P2*`) select kernel variants
for A/B work in `flash-cce.ts`; they are not user knobs. Training needs no
other env setup — the Gemma-specific flag sanitization older recipes
exported is gone (those kernels were deleted 2026-07-05; exporting the old
variables does nothing).

## Sequence-length ceilings (measured)

What decides whether a run fits. Full tables (peak GB and s/step per
seq/config) are in [benchmarks.md](benchmarks.md); the mechanism and the
measurement method are in
[segmented-backward-training](../design/orpo-training.md).

- **MiniCPM5-1B (24 layers), M1 Max 32 GB, 2026-06-16** — segmented
  backward (`segment_size` 4) @2048: peak live **10.91 → 3.29 GB** vs the
  plain backward; @4096 the plain backward spikes to 21–26 GB while
  segmented stays at 6–8 GB. Trains at 8192 comfortably.
- **e4b (Gemma4, 42 layers), M1 Max 32 GB, 2026-06-16** — without
  segmentation, `ops.sdpa` + `grad_checkpoint` peaks at **23.2 GB live @2048**
  and crashes at 4096 (linear: ≈ 7.7 GB + 7.6 MB/token). With segmented
  backward all 42 layers train at **8192 in 17.5 GB** (`segment_size` 2),
  where `mlx_lm.lora --grad-checkpoint` OOMs on all-42 @8192 and needs its
  default 16 trainable layers (25.7 GB) to fit.
- **e4b, M1 Max 32 GB, 2026-07-02** — `segment_size` is the whole knob:
  mlx's sdpa backward materializes O(L²) scores for every layer (sliding
  window is only a mask), so the worst segment is set by layer count.
  `segment_size` 1 = **14.59 GB @8K**, +3% step time, loss identical —
  fits a 24 GB M4 Pro.
- **e4b ORPO full stack (flash + prefix-share + seg 2), M1 Max 32 GB** —
  fits at 8192 with headroom; prefix-sharing is what makes prompt-dominant
  data cheap (memory and step time both drop when the prompt is encoded
  once). Numbers are from short probe runs — they prove fit and finite
  decreasing loss, not training quality.

Rules of thumb: e4b at multi-K context **requires** segmented backward
(`--seg`, on by default for ORPO; pass it explicitly for SFT); memory is
linear in `--seq`; on a 24 GB machine use `--seg 1` at 8K.

## Examples (task-specific recipes)

These are the scripts behind our own chunk-segmentation fine-tunes. They
carry task defaults (data paths, eval corpus) that point at a sibling
repo — override `DATA=` / `MODEL=` / `ADAPTER=` for your own data and treat
them as templates, not tools.

- [`scripts/examples/chunk-finetune.ts`](../../scripts/examples/chunk-finetune.ts)
  — SFT via `finetuneRunner` directly, env-driven. `MODEL` defaults to a
  MiniCPM5-1B-OptiQ-4bit snapshot; `SEQ` 8192, `ITERS` 2 (probe), `RANK`
  16, `LR` 1e-5, `SCALE` 20, `SEG` 0, `EVAL_EVERY` auto, `CKPT=0` disables
  keep-all checkpoints, `GRAD_CKPT=1` enables gradient checkpointing.
  ```bash
  DATA=<dir> SEQ=8192 ITERS=2 bun scripts/examples/chunk-finetune.ts            # memory/stability probe
  DATA=<dir> SEQ=8192 ITERS=300 SEG=2 bun scripts/examples/chunk-finetune.ts    # real run
  ```
- [`scripts/examples/ft-e4b-v2.sh`](../../scripts/examples/ft-e4b-v2.sh)
  `probe|train` — wraps `chunk-finetune.ts` for e4b with `SEQ=8192 SEG=4
  RANK=16 SCALE=20 LR=1e-5`, pinning the validated e4b OptiQ-4bit snapshot;
  `probe` = 2 iters (run first), `train` = 900 iters (~2 epochs over 450
  rows at batch 1).
  ```bash
  DATA=<dir> scripts/examples/ft-e4b-v2.sh probe
  DATA=<dir> ITERS=750 SEQ=4096 SEG=1 scripts/examples/ft-e4b-v2.sh train
  ```
- [`scripts/examples/chunk-eval.ts`](../../scripts/examples/chunk-eval.ts)
  — in-process task eval (no server): loads a model, optionally mounts
  `ADAPTER=<dir>`, generates over a frozen holdout, and scores with the
  task's metric. Its holdout/scorer imports live in the sibling repo; copy
  the shape for your own task eval. Pick checkpoints by the task eval, not
  by val loss.

## Methodology

### LoRA
Adapters attach to the target linears; A is initialized uniform, B zeros,
so the adapted model equals the base at step 0. Only A/B are differentiated.
Default targets are the 7 attention+MLP projections per block
(`q/k/v/o_proj`, `gate/up/down_proj`). See
[`src/train/lora-params.ts`](../../src/train/lora-params.ts).

### Rank scaling (`rank_scaling`)
- `constant` — every target gets `rank`.
- `by_bits` *(default)* — `rank × (bits / 4)`, clamped ≥2: wider adapters
  on the more-sensitive (higher-bit) layers of a mixed-precision model. The
  per-layer bits come from the loaded model's quant specs.
- `by_kl` — scales by per-layer KL importance from `optiq_metadata.json`,
  clamped to [0.5×, 2×]; falls back to `by_bits` when none is recorded.

### Long-context memory
At long `max_seq_length` activation memory dominates, not the head. Two
levers, mutually exclusive: `grad_checkpoint` (per-layer recompute, does not
stream) and `segment_size` (segmented backward, streams one segment at a
time — the path to multi-K context). Detail, proofs, and the `mlx_vjp`
vs surrogate-`value_and_grad` leak lesson:
[segmented-backward-training](../design/orpo-training.md).

### Training attention
`ops.sdpa` (mlx's fused SDPA, exact vjp, O(L²) backward memory) is the
only supported path for Gemma and the default everywhere. The opt-in
`MLX_BUN_TRAIN_ATTN=flash` kernel is an O(L)-memory experiment — ~30×
slower and blocked for Gemma by the trainer (see the env table).

## Outputs

A finished run writes a PEFT-compatible adapter directory:

- `adapters.safetensors` — the `lora_a` / `lora_b` tensors
- `optiq_lora_config.json` — mlx-bun/optiq metadata (per-layer ranks, scale, base model)
- `adapter_config.json` — PEFT-compatible config
- `metrics.jsonl` — append-only per-step log (what `train-watch` tails)

The save completes only after both config files are written — including
eval-step checkpoints — so a successful exit always leaves a mountable
directory. With `save_checkpoints` (`--save-every`), each eval step also
writes `checkpoints/step-<NNNNN>-val<loss>/` (each a full mountable adapter)
and `metrics.json` (config, wall seconds, peak GB, final/best train+val
loss, full val trajectory).

**Where to save.** The CLI default is
`~/.cache/mlx-bun/mlx-bun-finetunes/<method>-<model>`. The server's adapter
discovery (`GET /v1/adapters/available`, the web chat's adapter picker)
scans `~/.cache/mlx-bun-finetunes` and **`~/.cache/mlx-bun/adapters`** —
so pass `--adapter ~/.cache/mlx-bun/adapters/<name>` if you want the
adapter selectable without typing a path. `serve --adapter <dir>` and
`fuse --adapter <dir>` accept any directory.

Serving accepts both mlx-lm tensor layout (`[in, rank]` / `[rank, out]`)
and standard PEFT layout (`[rank, in]` / `[out, rank]`, including
`base_model.model.*` names); PEFT `use_rslora` metadata is honored as
`lora_alpha / sqrt(rank)`. Hot-swap and per-request selection:
[server-api.md](server-api.md) (Adapters) and
[adapters-end-to-end](../design/web-chat-redesign.md).

## Memory & performance tips

- Start at `--batch 1` (the no-padding path); raise only with headroom.
  `--grad-accum` raises the effective batch at batch-1 memory.
- OOM → lower `--seq`, lower `--seg` (1 at 8K on 24 GB), or reduce
  `--rank`.
- `MLX_BUN_MEM_LOG=1` for per-step peak; `MLX_BUN_SEG_MEM_LOG=1` to see
  which phase the peak lives in.
- Short rows already take the exact fused head automatically
  (`MLX_BUN_FLASH_MIN_M`); on response-dominant data `--no-prefix` costs
  nothing and `--no-flash` is worth an A/B.
- Select checkpoints by the downstream task eval or val accuracy/loss —
  not by preference margin, which keeps rising after the model has
  started overfitting.

## Rules for agents working alongside a run

- **No GPU work while a training run is active.** The GPU is fully
  occupied; a "quick" benchmark, parity test, or model load corrupts both
  the probe's numbers and the run's throughput. Verify by reading source
  and logs (`train-watch`, `train.log`, `metrics.jsonl`), not by executing.
- Long runs are launched by the user from their own shell (`nohup … &`),
  never as a session-spawned background task.
- Docs for a training-surface change (flags, fields, defaults) land in the
  same commit: this file, [cli.md](cli.md), and
  [server-api.md](server-api.md) for the HTTP routes.
