# mlx-bun head-to-head (2026-06-10, commit 6cb4a35)

Machine: **Joshs-MacBook-Pro** — Apple M1 Max, 32 GB unified. One machine per file;
cross-machine comparisons go through the per-row machine column.

| model | stack | leg | kv | decode tok/s | spread | prefill tok/s | ttft ms | ready s | gen peak GB | rss GB | rss growth | machine | commit |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 5b1101065d20 | mlx-bun | direct | bf16 | 28.5 | 25.9–28.6 (n=3) | 134 | — | — | 8.99 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-bun | direct | mixed | 28.0 | 27.3–28.2 (n=3) | 131 | — | — | 8.98 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-lm | direct | bf16 | 29.6 | 29.5–29.6 (n=3) | 107 | — | — | 9.10 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | optiq | direct | mixed | 28.9 | 28.9–29.1 (n=3) | 106 | — | — | 9.00 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-bun | direct@8k | mixed | 25.3 | 25.2–25.4 (n=3) | 186 | — | — | 10.99 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-bun | direct@8k | bf16 | 26.5 | 26.3–26.8 (n=3) | 191 | — | — | 11.06 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-lm | direct@8k | bf16 | 29.5 | 29.5–30.0 (n=3) | 107 | — | — | 9.10 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | optiq | direct@8k | mixed | 29.1 | 28.9–29.4 (n=3) | 105 | — | — | 9.00 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | mlx-bun | server | mixed | 29.2 | 29.1–29.3 (n=5) | — | 88 | 0.53 | — | 9.44 | 17 MB | Joshs-MacBook-Pro | 6cb4a35 |
| 5b1101065d20 | optiq | server | mixed | 28.0 | 27.9–28.0 (n=5) | — | 376 | 1.33 | — | 9.87 | 12 MB | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-bun | direct | bf16 | 49.9 | 49.8–50.0 (n=3) | 49 | — | — | 17.71 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-bun | direct | mixed | 49.8 | 49.7–49.8 (n=3) | 53 | — | — | 17.71 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-lm | direct | bf16 | 51.7 | 51.6–51.8 (n=3) | 119 | — | — | 17.78 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | optiq | direct | mixed | 50.1 | 50.0–50.3 (n=3) | 126 | — | — | 17.72 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-bun | server | mixed | 50.2 | 50.1–50.2 (n=5) | — | 60 | 0.52 | — | 17.22 | 22 MB | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-bun | server | bf16 | 50.5 | 50.4–50.7 (n=5) | — | 62 | 0.57 | — | 17.30 | 24 MB | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | mlx-lm | server | bf16 | 45.9 | 45.9–46.0 (n=5) | — | 305 | 1.49 | — | 11.17 | 14 MB | Joshs-MacBook-Pro | 6cb4a35 |
| dbfd2a779b03 | optiq | server | mixed | 45.8 | 45.7–45.9 (n=5) | — | 309 | 1.63 | — | 8.15 | 12 MB | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-bun | direct | bf16 | 54.6 | 54.5–54.7 (n=3) | 254 | — | — | 6.60 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-bun | direct | mixed | 54.2 | 54.2–54.5 (n=3) | 251 | — | — | 6.60 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-lm | direct | bf16 | 61.7 | 61.7–61.8 (n=3) | 181 | — | — | 6.65 | — | — | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-bun | server | mixed | 55.3 | 54.9–55.8 (n=5) | — | 57 | 0.53 | — | 7.14 | 32 MB | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-bun | server | bf16 | 55.3 | 55.2–55.3 (n=5) | — | 59 | 0.57 | — | 7.14 | 29 MB | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | mlx-lm | server | bf16 | 54.4 | 53.7–54.4 (n=5) | — | 281 | 1.51 | — | 7.55 | 14 MB | Joshs-MacBook-Pro | 6cb4a35 |
| fcdb12d740cd | optiq | server | mixed | 54.2 | 54.0–54.2 (n=5) | — | 282 | 5.64 | — | 7.46 | 14 MB | Joshs-MacBook-Pro | 6cb4a35 |

## attempted but failed

- `gemma-4-e4b-it-OptiQ-4bit/optiq/kv=config`: bench.ts failed for gemma-4-e4b-it-OptiQ-4bit/optiq/kv=config:
