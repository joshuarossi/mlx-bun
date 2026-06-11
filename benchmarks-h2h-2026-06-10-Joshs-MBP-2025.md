# mlx-bun head-to-head (2026-06-10, commit 3c6c879)

Machine: **Joshs-MBP-2025** — Apple M4 Pro, 24 GB unified. One machine per file;
cross-machine comparisons go through the per-row machine column.

| model | stack | leg | kv | decode tok/s | spread | prefill tok/s | ttft ms | ready s | gen peak GB | rss GB | rss growth | machine | commit |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 5b1101065d20 | mlx-bun | direct | mixed | 25.3 | 25.3–25.4 (n=3) | 203 | — | — | 8.98 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-bun | direct | bf16 | 25.3 | 25.1–25.3 (n=3) | 205 | — | — | 8.99 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-lm | direct | bf16 | 25.9 | 25.9–26.0 (n=3) | 142 | — | — | 9.10 | — | — | ? | 0ee00dd |
| 5b1101065d20 | optiq | direct | mixed | 25.6 | 25.5–25.7 (n=3) | 140 | — | — | 9.00 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-bun | direct@8k | mixed | 22.7 | 22.7–22.8 (n=3) | 253 | — | — | 10.99 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-bun | direct@8k | bf16 | 23.4 | 23.4–23.4 (n=3) | 255 | — | — | 11.06 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-lm | direct@8k | bf16 | 26.0 | 25.9–26.0 (n=3) | 143 | — | — | 9.10 | — | — | ? | 0ee00dd |
| 5b1101065d20 | optiq | direct@8k | mixed | 25.7 | 25.6–25.7 (n=3) | 137 | — | — | 9.00 | — | — | ? | 0ee00dd |
| 5b1101065d20 | mlx-bun | server | mixed | 25.6 | 25.6–25.6 (n=5) | — | 89 | 0.36 | — | 9.44 | 17 MB | ? | 0ee00dd |
| 5b1101065d20 | optiq | server | mixed | 25.5 | 25.5–25.5 (n=5) | — | 327 | 0.90 | — | 9.87 | 10 MB | ? | 0ee00dd |
| dbfd2a779b03 | mlx-bun | direct | mixed | 54.3 | 54.3–54.4 (n=3) | 231 | — | — | 17.71 | — | — | ? | 0ee00dd |
| dbfd2a779b03 | mlx-bun | direct | bf16 | 54.5 | 54.4–54.6 (n=3) | 233 | — | — | 17.71 | — | — | ? | 0ee00dd |
| dbfd2a779b03 | mlx-lm | direct | bf16 | 55.7 | 55.6–55.8 (n=3) | 186 | — | — | 17.78 | — | — | ? | 0ee00dd |
| dbfd2a779b03 | optiq | direct | mixed | 54.9 | 54.6–54.9 (n=3) | 191 | — | — | 17.72 | — | — | ? | 0ee00dd |
| dbfd2a779b03 | mlx-bun | server | mixed | 55.1 | 55.0–55.1 (n=5) | — | 48 | 0.48 | — | 18.23 | 20 MB | ? | 0ee00dd |
| dbfd2a779b03 | mlx-bun | server | bf16 | 55.1 | 55.0–55.2 (n=5) | — | 47 | 0.47 | — | 18.22 | 20 MB | ? | 0ee00dd |
| dbfd2a779b03 | mlx-lm | server | bf16 | 52.1 | 52.1–52.2 (n=5) | — | 226 | 0.80 | — | 5.89 | 11 MB | ? | 0ee00dd |
| fcdb12d740cd | mlx-bun | direct | mixed | 54.0 | 54.0–54.2 (n=3) | 400 | — | — | 6.60 | — | — | ? | 0ee00dd |
| fcdb12d740cd | mlx-bun | direct | bf16 | 54.2 | 54.1–54.3 (n=3) | 406 | — | — | 6.60 | — | — | ? | 0ee00dd |
| fcdb12d740cd | mlx-lm | direct | bf16 | 56.7 | 56.5–56.8 (n=3) | 385 | — | — | 6.65 | — | — | ? | 0ee00dd |
| fcdb12d740cd | mlx-bun | server | mixed | 54.4 | 54.3–54.4 (n=5) | — | 45 | 0.37 | — | 7.14 | 31 MB | ? | 0ee00dd |
| fcdb12d740cd | mlx-bun | server | bf16 | 54.6 | 54.5–54.6 (n=5) | — | 45 | 0.36 | — | 7.13 | 28 MB | ? | 0ee00dd |
| fcdb12d740cd | mlx-lm | server | bf16 | 53.6 | 53.6–54.2 (n=5) | — | 220 | 0.95 | — | 7.55 | 20 MB | ? | 0ee00dd |
| fcdb12d740cd | optiq | server | mixed | 53.5 | 53.5–53.7 (n=5) | — | 220 | 0.79 | — | 7.52 | 11 MB | ? | 0ee00dd |

## attempted but failed

- `gemma-4-e4b-it-OptiQ-4bit/optiq/kv=config`: ValueError: [quantized_matmul] The shapes of the weight and scales are incompatible based on bits and group_size. w.shape() == (1,2,1,102,64) and scales.shape()
- `gemma-4-26B-A4B-it-OptiQ-4bit/optiq/kv=config`: no content chunks received (curl exit 52)
