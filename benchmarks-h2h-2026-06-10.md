# mlx-bun head-to-head (2026-06-10, commit cc0c151)

| model | stack | leg | kv | decode tok/s | prefill tok/s | ttft ms | ready s | mem GB | rss growth |
|---|---|---|---|---|---|---|---|---|---|
| 5b1101065d20 | optiq | direct@8k | mixed | 25.6 | 134 | — | — | 9.84 | — |
| 5b1101065d20 | mlx-bun | direct@8k | mixed | 22.9 | 253 | — | — | 10.99 | — |
| 5b1101065d20 | mlx-lm | direct@8k | bf16 | 26.0 | 142 | — | — | 9.84 | — |
| 5b1101065d20 | mlx-bun | direct@8k | bf16 | 23.5 | 255 | — | — | 11.06 | — |
| 5b1101065d20 | mlx-bun | direct | mixed | 25.3 | 204 | — | — | 8.98 | — |
| 5b1101065d20 | optiq | direct | mixed | 25.5 | 140 | — | — | 9.84 | — |
| 5b1101065d20 | mlx-lm | direct | mixed | 25.9 | 144 | — | — | 9.84 | — |
| 5b1101065d20 | mlx-bun | direct | bf16 | 25.3 | 208 | — | — | 8.99 | — |
| 5b1101065d20 | mlx-lm | direct | bf16 | 25.9 | 140 | — | — | 9.84 | — |
| 5b1101065d20 | mlx-bun | server | mixed | 25.6 | — | 78 | 0.5 | 9.44 | 17 MB |
| dbfd2a779b03 | mlx-bun | direct | mixed | 54.4 | 245 | — | — | 17.71 | — |
| dbfd2a779b03 | optiq | direct | mixed | 55.0 | 191 | — | — | 20.22 | — |
| dbfd2a779b03 | mlx-lm | direct | mixed | 55.7 | 19 | — | — | 20.22 | — |
| dbfd2a779b03 | mlx-bun | direct | bf16 | 54.4 | 229 | — | — | 17.71 | — |
| dbfd2a779b03 | mlx-lm | direct | bf16 | 55.7 | 191 | — | — | 20.22 | — |
| dbfd2a779b03 | mlx-bun | server | mixed | 54.9 | — | 39 | 0.5 | 18.22 | 21 MB |
| dbfd2a779b03 | mlx-bun | server | bf16 | 55.1 | — | 38 | 0.5 | 18.22 | 20 MB |
| fcdb12d740cd | mlx-bun | direct | mixed | 54.0 | 399 | — | — | 6.60 | — |
| fcdb12d740cd | mlx-lm | direct | mixed | 56.6 | 362 | — | — | 18.24 | — |
| fcdb12d740cd | mlx-bun | direct | bf16 | 54.2 | 406 | — | — | 6.60 | — |
| fcdb12d740cd | mlx-lm | direct | bf16 | 56.6 | 390 | — | — | 18.24 | — |
| fcdb12d740cd | mlx-bun | server | bf16 | 37.3 | — | 53 | — | — | — |
| fcdb12d740cd | mlx-bun | server | mixed | 54.3 | — | 38 | 0.5 | 7.13 | 19 MB |
| fcdb12d740cd | mlx-bun | server | bf16 | 54.5 | — | 37 | 0.5 | 7.14 | 28 MB |
