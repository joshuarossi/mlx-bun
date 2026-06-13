# mlx-bun head-to-head (2026-06-11, commit 8b2b44b)

Machine: **Joshs-MBP-2025** — Apple M4 Pro, 24 GB unified. One machine per file;
cross-machine comparisons go through the per-row machine column.

| model | stack | leg | kv | decode tok/s | spread | prefill tok/s | ttft ms | ready s | gen peak GB | rss GB | rss growth | machine | commit |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 5b1101065d20 | mlx-bun | direct | mixed | 25.1 | 25.0–25.1 (n=3) | 149 | — | — | 8.97 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-bun | direct | bf16 | 25.4 | 24.9–25.4 (n=3) | 166 | — | — | 8.99 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-lm | direct | bf16 | 25.8 | 25.4–25.8 (n=3) | 141 | — | — | 9.10 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | optiq | direct | mixed | 25.5 | 25.1–25.7 (n=3) | 138 | — | — | 9.00 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-bun | direct@8k | mixed | 23.4 | 23.4–23.5 (n=3) | 247 | — | — | 10.08 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-bun | direct@8k | bf16 | 24.2 | 24.1–24.2 (n=3) | 254 | — | — | 11.06 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-lm | direct@8k | bf16 | 24.3 | 24.2–24.3 (n=3) | 260 | — | — | 11.08 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | optiq | direct@8k | mixed | 23.2 | 23.1–23.2 (n=3) | 258 | — | — | 10.63 | — | — | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | mlx-bun | server | mixed | 25.2 | 25.2–25.3 (n=5) | — | 88 | 0.36 | — | 9.47 | 24 MB | Joshs-MBP-2025 | 8b2b44b |
| 5b1101065d20 | optiq | server | mixed | 25.5 | 25.5–25.5 (n=5) | — | 328 | 1.04 | — | 9.85 | 10 MB | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-bun | direct | mixed | 54.0 | 53.9–54.0 (n=3) | 208 | — | — | 17.71 | — | — | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-bun | direct | bf16 | 55.0 | 54.9–55.0 (n=3) | 220 | — | — | 17.71 | — | — | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-lm | direct | bf16 | 55.8 | 55.7–56.2 (n=3) | 19 | — | — | 17.78 | — | — | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | optiq | direct | mixed | 54.9 | 54.9–55.0 (n=3) | 19 | — | — | 17.72 | — | — | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-bun | server | mixed | 54.0 | 54.0–54.1 (n=5) | — | 45 | 0.48 | — | 18.26 | 50 MB | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-bun | server | bf16 | 55.1 | 55.0–55.2 (n=5) | — | 44 | 0.46 | — | 18.22 | 16 MB | Joshs-MBP-2025 | 8b2b44b |
| dbfd2a779b03 | mlx-lm | server | bf16 | 52.2 | 52.1–52.2 (n=5) | — | 229 | 0.87 | — | 5.47 | 15 MB | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-bun | direct | mixed | 55.7 | 55.7–55.8 (n=3) | 260 | — | — | 6.59 | — | — | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-bun | direct | bf16 | 57.2 | 56.5–57.5 (n=3) | 290 | — | — | 6.60 | — | — | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-lm | direct | bf16 | 56.6 | 56.6–56.9 (n=3) | 384 | — | — | 6.65 | — | — | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-bun | server | mixed | 55.8 | 55.7–55.8 (n=5) | — | 43 | 0.37 | — | 7.13 | 6 MB | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-bun | server | bf16 | 57.5 | 57.4–57.5 (n=5) | — | 47 | 0.37 | — | 7.12 | 9 MB | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | mlx-lm | server | bf16 | 53.5 | 53.5–53.8 (n=5) | — | 220 | 0.94 | — | 7.55 | 21 MB | Joshs-MBP-2025 | 8b2b44b |
| fcdb12d740cd | optiq | server | mixed | 53.6 | 53.5–53.6 (n=5) | — | 220 | 0.79 | — | 7.53 | 11 MB | Joshs-MBP-2025 | 8b2b44b |

## attempted but failed

- `gemma-4-e4b-it-OptiQ-4bit/optiq/kv=config`: ValueError: [quantized_matmul] The shapes of the weight and scales are incompatible based on bits and group_size. w.shape() == (1,2,1,58,64) and scales.shape() 
- `gemma-4-26B-A4B-it-OptiQ-4bit/optiq/kv=config`: no content chunks received (curl exit 52)
