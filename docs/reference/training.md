# Training / fine-tuning reference

How to fine-tune a served model with LoRA adapters: the entry points, the
data formats, every config flag, and the methodology behind the knobs.

mlx-bun trains **LoRA adapters** (the base quantized weights stay frozen),
supports **SFT** and **DPO**, and runs on a single Apple-Silicon GPU. The
output is a PEFT-compatible adapter you hot-swap into the server — see
[adapters-end-to-end](../design/adapters-end-to-end.md) for the serving side
and [segmented-backward-training](../design/segmented-backward-training.md)
for the long-context memory mechanism.

> Source of truth: the config schema is `FinetuneSubmit` in
> [`src/train/job.ts`](../../src/train/job.ts); defaults are
> `DEFAULT_TRAIN_CONFIG` in [`src/train/trainer.ts`](../../src/train/trainer.ts).
> This doc is generated against those — if they drift, the code wins.

## Entry points

There is **no `mlx-bun train` CLI verb.** Training runs as a subprocess job,
reachable four ways:

| Path | How | Use when |
|---|---|---|
| **Web UI** | `mlx-bun serve`, open `/finetune` — pick model → dataset → hyperparameters → train; watch live train/val loss; merge/export the adapter | Interactive, the default |
| **HTTP API** | `POST /api/finetune/submit` (job id + SSE events); `POST /api/finetune/inspect-dataset` to probe a file; `POST /api/finetune/merge` to fold an adapter into base weights | Scripted / remote |
| **Script** | [`scripts/chunk-finetune.ts`](../../scripts/chunk-finetune.ts) — an env-driven wrapper that calls the runner directly | Repeatable CLI runs |
| **Shell recipe** | [`scripts/ft-e4b-v2.sh`](../../scripts/ft-e4b-v2.sh) `probe`\|`train` — the actual e4b run we use; sets the required env (see [What we actually run](#what-we-actually-run-the-e4b-recipe)) | Reproducing our e4b fine-tune |
| **Library** | `import { finetuneRunner } from "./src/train/job"` and call it with a config + emitter | Embedding training in your own TS |

### Quick start (HTTP API)

```bash
curl -s localhost:8090/api/finetune/submit -X POST -H 'content-type: application/json' -d '{
  "model_dir": "/path/to/snapshot",
  "data_dir":  "/path/to/dataset",        // dir with train.jsonl (+ optional valid.jsonl)
  "adapter_path": "/path/to/output-adapter",
  "method": "sft",
  "rank": 16, "iters": 300, "learning_rate": 2e-4, "max_seq_length": 2048
}'
# → { "jobId": "..." }   then stream events from the jobs SSE endpoint
```

`model_dir`, `data_dir`, and `adapter_path` are **required**; everything else
falls back to the defaults below.

### Quick start (script)

[`scripts/chunk-finetune.ts`](../../scripts/chunk-finetune.ts) is the worked
example (MiniCPM5 on the chunking task). It calls `finetuneRunner` directly,
driven by env vars:

```bash
# MODEL unset → defaults to the MiniCPM5-1B-OptiQ-4bit snapshot
DATA=/path/to/chunk ITERS=300 RANK=16 SEQ=2048 SEG=4 \
  bun scripts/chunk-finetune.ts
```

Env knobs — note the script applies its **own task-tuned defaults**, which
differ from the trainer/API defaults in the table below:

| Env | Maps to | Script default |
|---|---|---|
| `MODEL` | `model_dir` | MiniCPM5-1B-OptiQ-4bit snapshot (a **path** if set, not a name) |
| `DATA` | `data_dir` | the lucien chunk dataset path |
| `SEQ` | `max_seq_length` | `8192` |
| `ITERS` | `iters` | `2` (probe; use 300 for a real run) |
| `RANK` | `rank` | `16` |
| `LR` | `learning_rate` | `1e-5` |
| `SCALE` | `scale` | `20` |
| `SEG` | `segment_size` | `0` (off) |
| `EVAL_EVERY` | `steps_per_eval` | auto from `ITERS` |
| `ADAPTER` | `adapter_path` | `~/.cache/mlx-bun-finetunes/minicpm5-chunk-seq<SEQ>` |
| `CKPT` | `save_checkpoints` | on (`CKPT=0` disables) |
| `GRAD_CKPT` | `grad_checkpoint` | off (`GRAD_CKPT=1` enables) |

The script hard-codes `method=sft`, `batch_size=1`, `steps_per_report=1`, and
uses the default `ops.sdpa` training attention (set `MLX_BUN_TRAIN_ATTN=flash`
to override — but flash crashes e4b at multi-K; see Methodology).

## Data formats

Each row of `train.jsonl` (and optional `valid.jsonl`) is auto-detected by its
keys ([`src/train/dataset.ts`](../../src/train/dataset.ts)):

| Format | Shape | Loss boundary |
|---|---|---|
| `messages` | `{"messages": [{"role","content"}, …]}` | response-only — loss on the final turn, prompt = chat-template render of all prior turns |
| `prompt-completion` | `{"prompt": "...", "completion": "..."}` | loss on the completion only |
| `text` | `{"text": "..."}` | full-sequence (no prompt mask) |
| `dpo` *(method=dpo)* | `{"prompt", "chosen", "rejected"}` | preference loss on chosen vs rejected |

Probe a file before submitting: `POST /api/finetune/inspect-dataset` with
`{"path": "..."}` returns `{ ok, n_train, n_valid, format }`.

## SFT vs DPO

- **SFT** (`method: "sft"`, default) — supervised fine-tune; response-only
  cross-entropy. Default LR `2e-4`. For instruction-following, formatting,
  task adaptation.
- **DPO** (`method: "dpo"`) — Direct Preference Optimization on
  chosen/rejected pairs; loss `-log σ(β·((π_c − ref_c) − (π_r − ref_r)))`
  with reference log-probs computed at LoRA scale 0. Default LR `5e-5`. Tune
  with `dpo_beta`, `dpo_warmup_iters`, `dpo_lr_schedule`.

## Configuration reference

All fields optional except `model_dir` / `data_dir` / `adapter_path`. Defaults
are `DEFAULT_TRAIN_CONFIG` (trainer.ts:89).

| Field (API) | Type | Default | Effect |
|---|---|---|---|
| `method` | `sft` \| `dpo` | `sft` | Training objective (see above) |
| `rank` | int ≥2 | `8` | LoRA rank per adapted linear |
| `scale` | float >0 | `1.0` | LoRA α (effective update = α·BA) |
| `rank_scaling` | `constant` \| `by_bits` \| `by_kl` | `by_bits` | Per-layer rank policy (see Methodology) |
| `target_modules` | string[] | `q,k,v,o,gate,up,down _proj` | Which linears get adapters |
| `num_layers` | int | `-1` | `-1` = all layers; `N` = last N only |
| `iters` | int >0 | `100` | Total training steps |
| `learning_rate` | float >0 | `2e-4` (sft) / `5e-5` (dpo) | AdamW LR |
| `max_seq_length` | int >0 | `512` | Truncate/pad sequences to this |
| `batch_size` | int ≥1 | `1` | Rows per step (B=1 is the safe path; B>1 length-sorts + pads to 32) |
| `grad_accumulation_steps` | int ≥1 | `1` | Accumulate grads over N micro-steps |
| `seed` | int | `0` | RNG for shuffling + LoRA init |
| `steps_per_report` | int >0 | `10` | Emit a train-loss metric every N steps |
| `steps_per_eval` | int >0 | `50` | Eval on `valid.jsonl` every N steps |
| `weight_decay` | float ≥0 | `0.01` | AdamW weight decay (β = `[0.9, 0.999]`, fixed) |
| `grad_checkpoint` | bool | `false` | Recompute layer activations in backward (memory↔compute; bit-identical) |
| `segment_size` | int | `0` (off) | `>0` enables segmented backward — layers per segment (see below) |
| `save_checkpoints` | bool | `false` | Save every eval-step checkpoint + write `metrics.json` |
| `dpo_beta` | float >0 | `0.1` | DPO strength (dpo only) |
| `dpo_warmup_iters` | int ≥0 | `0` | DPO LR warmup (dpo only) |
| `dpo_lr_schedule` | `constant` \| `cosine` | `cosine` | DPO LR schedule (dpo only) |

### Environment variables (training)

| Env var | Set for training | Default | Why |
|---|---|---|---|
| `MLX_BUN_FUSED_GELU` | **`0` (required for Gemma)** | on | The fused GeGLU is a **CustomKernel with no gradient (vjp)** ([`fused-geglu-kernel.ts`](../../src/model/fused-geglu-kernel.ts)); the Gemma forward uses it ([`gemma4.ts:277`](../../src/model/gemma4.ts)), so a Gemma (e4b/12B/26B) backward fails unless it's off. MiniCPM5 (Llama-arch SwiGLU) never hits it, so the `.ts` script's MiniCPM5 default doesn't need it. |
| `MLX_BUN_PERF_KERNEL` | **`0` for training** | on | The fused quantized-decode kernel likewise has no vjp. It only fires at decode L=1 (rare in the L>1 training forward), but the e4b recipe sets `0` to be safe. |
| `MLX_BUN_TRAIN_ATTN` | **leave unset** | unset → `ops.sdpa` | Default `ops.sdpa` **is** mlx's fused flash-attention kernel — the correct, working path. `flash` selects a *different* hand-rolled custom kernel that crashes e4b at multi-K; do not set it. |
| `MLX_BUN_MEM_LOG` | `1` to profile | off | Print per-step peak/active/cache memory |

> Important: the trainer itself ([`trainer.ts`](../../src/train/trainer.ts))
> only reads `MLX_BUN_TRAIN_ATTN` and `MLX_BUN_MEM_LOG` — but the **model
> forward** it runs reads `MLX_BUN_FUSED_GELU` / `MLX_BUN_PERF_KERNEL`. The
> trainer does **not** disable those itself, so **the caller must** export
> them. The [e4b recipe](#what-we-actually-run-the-e4b-recipe) does this; if
> you train a Gemma model by hand, set `MLX_BUN_FUSED_GELU=0` yourself.

## What we actually run (the e4b recipe)

Everything above is the full surface (*what you can do*). In practice the
fine-tune we run is [`scripts/ft-e4b-v2.sh`](../../scripts/ft-e4b-v2.sh):
e4b (gemma-4-e4b-it-OptiQ-4bit, pinned snapshot) on the lucien `chunk-v2-500`
curated set (450 train convs) through the segmented-backward trainer. It wraps
`chunk-finetune.ts` with the e4b-required env and a two-step workflow:

```bash
scripts/ft-e4b-v2.sh probe   # 2-iter memory/stability check (~1 min) — RUN FIRST
scripts/ft-e4b-v2.sh train   # the real run (~900 iters ≈ 2 epochs, batch_size 1)
ITERS=750 SEQ=4096 SEG=1 scripts/ft-e4b-v2.sh train   # override any knob inline
```

What the recipe pins (and why it differs from the bare defaults):

| Knob | Recipe value | Why |
|---|---|---|
| model | e4b OptiQ-4bit, pinned snapshot `fcdb12d7…` | the validated e4b snapshot |
| data | `chunk-v2-500` (450 train convs) | the curated chunk set |
| `SEQ` | `8192` | long context |
| `SEG` | `4` | **segmented backward**, 4 layers/segment — so 8K-ctx activations fit |
| `RANK` / `SCALE` / `LR` | `16` / `20` / `1e-5` | task-tuned |
| `ITERS` | `2` (probe) / `900` (train) | ~2 epochs over 450 examples |
| `MLX_BUN_PERF_KERNEL` / `MLX_BUN_FUSED_GELU` | `0` / `0` | **required** — the fused kernels have no vjp (see env table) |
| attention | default `ops.sdpa` | mlx's fused flash kernel; **not** `MLX_BUN_TRAIN_ATTN=flash` (that one crashes e4b) |

The two non-negotiables for e4b: **segmented backward** (`SEG>0`, so the
long-context activations fit) and the **fused kernels off** (so the backward
has gradients). Always run `probe` before `train`.

## Methodology

### LoRA
Adapters attach to the target linears; A is initialized uniform, B is zeros,
so the adapted model equals the base model at step 0. Only A/B are
differentiated — base quantized weights are frozen. Default targets are the 7
attention+MLP projections per block (`q/k/v/o_proj`, `gate/up/down_proj`),
following Unsloth. See [`src/train/lora-params.ts`](../../src/train/lora-params.ts).

### Rank scaling (`rank_scaling`)
- `constant` — every target gets `rank`.
- `by_bits` *(default)* — `rank × (bits / 4)`, clamped ≥2; gives wider
  adapters to lower-bit (optiq mixed-precision) layers. Needs the model's
  per-layer bits map.
- `by_kl` — scales by per-layer KL importance, clamped to [0.5×, 2×]; falls
  back to `by_bits` if no KL map is present.

### Long-context memory: segmented backward vs gradient checkpointing
At long `max_seq_length`, activation memory dominates. Two levers:

- `grad_checkpoint: true` — recompute each layer's activations during
  backward. Bit-identical; trades compute for memory.
- `segment_size: N` — **segmented backward**: run the layer stack forward
  detaching the residual stream into graph-free boundary leaves every N
  layers, then backprop segment-by-segment via `mlx_vjp` (cotangent passed
  directly, *not* a surrogate-loss `value_and_grad`, which leaked). Only one
  segment's activations live at a time. This is the path to multi-K context;
  full mechanism, proofs, and measured peaks (e.g. MiniCPM5 10.91→3.29 GB
  @2048) are in
  [segmented-backward-training](../design/segmented-backward-training.md).

### Training attention kernel (`MLX_BUN_TRAIN_ATTN`)
- **default `ops.sdpa`** — mlx's fused SDPA; correct (0.00% vs autograd),
  O(L²) backward memory. Use this.
- **`flash`** — opt-in O(L) memory path, but the hand-rolled dK kernel is
  slow and **crashes e4b at multi-K (≥2K)**; do not use it for e4b LoRA
  training. Detail in segmented-backward-training §6.

## Outputs

A finished run writes a PEFT-compatible adapter directory:

- `adapters.safetensors` — the `lora_a` / `lora_b` tensors
- `optiq_lora_config.json` — mlx-bun/optiq adapter metadata (per-layer ranks)
- `adapter_config.json` — PEFT-compatible config

When `save_checkpoints: true`, each eval step also writes
`checkpoints/step-<NNNNN>-val<loss>/` and a durable `metrics.json` (config,
wall seconds, peak GB, final/best train+val loss, full val trajectory).

**Serving the adapter:** hot-swap it into a running server via the adapter
API and select it per-request — see
[adapters-end-to-end](../design/adapters-end-to-end.md) and the adapter
endpoints in [server-api](server-api.md). Or fold it into the base weights
with `POST /api/finetune/merge`.

## Memory & performance tips

- Start at `batch_size: 1` (the no-padding path); raise only with headroom.
- OOM → lower `max_seq_length`, set `segment_size` (e.g. 2–4), or reduce
  `rank` / `num_layers`.
- Set `MLX_BUN_MEM_LOG=1` to watch per-step peak memory.
- `grad_accumulation_steps` raises effective batch without the memory cost.
