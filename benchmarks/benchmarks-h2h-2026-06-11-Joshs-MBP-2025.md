# mlx-bun head-to-head (2026-06-11, commit f23ef4e)

Machine: **Joshs-MBP-2025** — Apple M4 Pro, 24 GB unified. One machine per file;
cross-machine comparisons go through the per-row machine column.

| model | stack | leg | kv | decode tok/s | spread | prefill tok/s | ttft ms | ready s | gen peak GB | rss GB | rss growth | machine | commit |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 5b1101065d20 | mlx-bun | direct | mixed | 25.0 | 25.0–25.1 (n=3) | 197 | — | — | 8.97 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-bun | direct | bf16 | 25.3 | 25.2–25.3 (n=3) | 200 | — | — | 8.99 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-lm | direct | bf16 | 25.8 | 25.8–26.0 (n=3) | 143 | — | — | 9.10 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | optiq | direct | mixed | 25.6 | 25.5–25.7 (n=3) | 140 | — | — | 9.00 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-bun | direct@8k | mixed | 23.0 | 23.0–23.0 (n=3) | 248 | — | — | 10.08 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-bun | direct@8k | bf16 | 23.3 | 23.2–23.3 (n=3) | 255 | — | — | 11.06 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-lm | direct@8k | bf16 | 24.4 | 24.4–24.4 (n=3) | 262 | — | — | 11.08 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | optiq | direct@8k | mixed | 23.2 | 23.2–23.2 (n=3) | 258 | — | — | 10.63 | — | — | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | mlx-bun | server | mixed | 25.2 | 25.2–25.2 (n=5) | — | 90 | 0.37 | — | 9.45 | 24 MB | Joshs-MBP-2025 | f23ef4e |
| 5b1101065d20 | optiq | server | mixed | 25.5 | 25.5–25.5 (n=5) | — | 331 | 1.00 | — | 9.88 | 16 MB | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-bun | direct | mixed | 53.5 | 53.3–53.9 (n=3) | 205 | — | — | 17.71 | — | — | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-bun | direct | bf16 | 54.5 | 54.4–54.9 (n=3) | 231 | — | — | 17.71 | — | — | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-lm | direct | bf16 | 56.1 | 55.9–56.2 (n=3) | 193 | — | — | 17.78 | — | — | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | optiq | direct | mixed | 55.4 | 54.9–55.5 (n=3) | 18 | — | — | 17.72 | — | — | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-bun | server | mixed | 54.0 | 53.9–54.4 (n=5) | — | 49 | 0.47 | — | 18.24 | 27 MB | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-bun | server | bf16 | 54.9 | 54.9–55.0 (n=5) | — | 47 | 0.47 | — | 18.20 | -4 MB | Joshs-MBP-2025 | f23ef4e |
| dbfd2a779b03 | mlx-lm | server | bf16 | 52.2 | 52.2–52.7 (n=5) | — | 224 | 0.76 | — | 5.16 | 57 MB | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-bun | direct | mixed | 52.7 | 52.7–52.8 (n=3) | 385 | — | — | 6.59 | — | — | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-bun | direct | bf16 | 54.2 | 54.2–54.3 (n=3) | 406 | — | — | 6.60 | — | — | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-lm | direct | bf16 | 56.7 | 56.6–56.8 (n=3) | 228 | — | — | 6.65 | — | — | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-bun | server | mixed | 53.1 | 53.0–53.4 (n=5) | — | 47 | 0.37 | — | 7.15 | 32 MB | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-bun | server | bf16 | 54.5 | 54.4–54.5 (n=5) | — | 45 | 0.36 | — | 7.12 | 19 MB | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | mlx-lm | server | bf16 | 53.5 | 53.5–53.5 (n=5) | — | 219 | 0.98 | — | 7.55 | 20 MB | Joshs-MBP-2025 | f23ef4e |
| fcdb12d740cd | optiq | server | mixed | 53.5 | 53.5–53.7 (n=5) | — | 222 | 0.79 | — | 7.53 | 10 MB | Joshs-MBP-2025 | f23ef4e |

## attempted but failed

- `gemma-4-e4b-it-OptiQ-4bit/optiq/kv=config`: ValueError: [quantized_matmul] The shapes of the weight and scales are incompatible based on bits and group_size. w.shape() == (1,2,1,269,128) and scales.shape(
- `gemma-4-26B-A4B-it-OptiQ-4bit/optiq/kv=config`: no content chunks received (curl exit 52)
