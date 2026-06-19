# ORPO training quickstart — the full stack, preconfigured

One launcher runs the complete new system — **flash-CCE Metal head** (steel fwd+bwd,
`[M,V]`-free) + **segmented backward** (gradient-checkpointed layer activations) +
**prefix-sharing** (one forward over `[prompt; chosen; rejected]`) + LoRA. Each feature
**falls back and logs** if a precondition isn't met (e.g. a row whose chosen/rejected
prompts aren't identical → two-forward for that row).

## Command

```bash
MODEL=/path/to/snapshot DATA=/path/to/datadir bun scripts/train-orpo.ts
```
- `DATA` is a directory with `train.jsonl` (+ optional `valid.jsonl`); rows are
  `{"prompt": "...", "chosen": "...", "rejected": "..."}`.
- The script **auto-detects e4b/Gemma** and sets its required training env flags
  (`MLX_BUN_PERF_KERNEL=0`, `MLX_BUN_FUSED_GELU=0`) before loading the model — you don't
  set them yourself.

### Preconfigured defaults (override via env)
| env | default | meaning |
|---|---|---|
| `SEQ` | e4b 8192 · cpm 4096 | max sequence length |
| `SEG` | 2 | segment size (layers/segment); the validated e4b@8192 sweet spot |
| `ITERS` | 100 | iterations |
| `LR` | 1e-5 | learning rate (cosine + short warmup) |
| `RANK` / `SCALE` | 16 / 2.0 | LoRA rank (by_bits scaled) / scale |
| `LAMBDA` | 0.1 | ORPO odds-ratio weight |
| `FLASH=0` | (on) | use the MLX fused head instead of the flash Metal head |
| `PREFIX=0` | (on) | disable prefix-sharing (plain two-forward) |
| `SEGOFF=1` | (off) | disable the segmented backward (more memory) |
| `ADAPTER` | `~/.cache/mlx-bun/mlx-bun-finetunes/orpo-<model>` | output dir (the finetunes cache, not the repo) |

Example — e4b overnight at 8192:
```bash
MODEL=~/.cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots/<snap> \
DATA=./data/mydpo ITERS=200 bun scripts/train-orpo.ts
```

## What to expect — performance (measured, M1 Max 32 GB)

### e4b (Gemma4, H=2560, V=262144) — full stack
| seq | config | peak GB | s/step |
|---|---|---|---|
| 8192 | flash + segmented(2) + **prefix-share** (prompt-dominant data) | **13.3** | **~70** |
| 8192 | flash + segmented(2), no prefix | 16.1 | ~175 |
| 4096 | flash + segmented(2), no prefix | 11.7 | ~81 |
| 2048 | flash + segmented(2), no prefix | 10.2 | ~40 |
| 1024 | flash + segmented(2), no prefix | 8.7 | ~21 |

- **Fits comfortably in 32 GB at 8192** (the historical "e4b OOMs ≥2048" ceiling is gone).
- **Prefix-sharing is a real win when the prompt dominates** — at 8192 with a long shared
  prompt it cut memory 16→13 GB *and* step time 175→70 s (prompt encoded once, not twice).
  On response-dominant data the saving shrinks toward zero (and it falls back per-row when
  prompts differ); it never hurts correctness.
- Memory is **linear in sequence length** (~+1.5 GB / 1024 tokens) — segmenting + flash
  attention keep it linear, not quadratic. The head itself is **flat 0.93 GB** regardless
  of vocab/seq.
- An ~8 h run at 8192 ≈ 100–400 steps depending on the prompt/response split.

### MiniCPM5 (1B, H=1536, V=130560) — full stack
- Fits easily (~1–2 GB at short seq). ~0.4–1 s/step at seq 256; scales with seq.
- Everything composes (flash / segmented / prefix-share, in any combination).

### The flash-CCE head in isolation (the piece that made large-vocab affordable)
- Forward 180 ms, backward **754 ms** (e4b) / 224 ms (cpm) — exact (dh 0.40% / 0.28%
  bf16-class), `[M,V]`-free, peak **0.93 GB flat at M=8192**. The backward is **5× the old
  hand-rolled kernel** (3687 ms) via the verbatim MLX steel GEMM + fused dequant.

## Fallback behavior (logged)
- **Prefix-share, per row**: if `chosen`/`rejected` prompts aren't byte-identical →
  two-forward for that row. The first occurrence logs `prefix-share: row prompt mismatch
  → two-forward fallback`; the saving is lost only on mismatched rows.
- **`FLASH=0`** → the MLX fused linear-CE head (`quantizedMatmul` both ways; exact,
  `[chunk,V]` transient) instead of the Metal kernel.
- **`SEGOFF=1`** → all layer activations resident (only viable at short seq on e4b).
- Models other than MiniCPM5 / Gemma4 with `orpoPrefixShared` error out (not silently).

## Optional / experimental
- The Apple-CCE backward skips (`MLX_BUN_CCE_BWD_BLOCK_EPS=1e-5`, the lossless vocab-block
  skip; `MLX_BUN_CCE_BWD_FILTER_EPS=1e-5`, the coeff filter) are **off by default** — on
  the now-fast steel kernel they give little and the coeff filter costs gradient accuracy.
  The block skip *can* help on long genuinely-peaked real text; A/B it on your data and
  watch that the loss doesn't move.

## Caveats (honest)
- The e4b numbers above are from **short probe runs** (2–3 steps); they confirm the
  pipeline runs, fits memory, and produces finite/decreasing loss — **not** training
  quality (that's your data + hyperparameters).
- e4b gradients are **bf16-class** (~1–3% vs an exact reference) — expected for the fused
  bf16 path; MiniCPM5 is tighter (forward bit-exact, grads ~1%).
