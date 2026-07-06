# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 2.33 20.82 19.38 } · 2026-07-06T05:05:21.437Z
commit: 6fc281d

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 270.3 | 238 | 28 (627) | 2644 | 15819 | 1536 | 125.2 | 52 | 154 (15818) | 462.5 | 2077 | 1.2 | 1.0 |
| mlx-lm | 202.1 | 321 | 81 (624) | 1947 | 15919 | 1529 | 98.8 | 125 | 10423 (0) | 191.2 | 1215 | 8.7 | 8.5 |
| mlx-bun-mixed | 213.8 | 254 | 27 (627) | 2465 | 15818 | 1023 | 127.7 | 44 | 134 (15817) | 415.5 | 1591 | 0.9 | 0.8 |
| optiq-mixed | 202.1 | 326 | 84 (627) | 1927 | 15817 | 1540 | 98.6 | 128 | 10733 (0) | 193.2 | 1216 | 2.2 | 1.3 |

- **parity ✓ (engine)** bf16 drop-in (vs mlx-lm): identical with enable_thinking pinned on (prompt_tokens 27 both). Default renders differ BY DESIGN: our --thinking default is off for this model (documented), theirs follows the template.
- **parity ✗** mixed-KV (vs optiq): prompt_tokens 29 vs 27 (TEMPLATE DRIFT); diverged at char 0: …`Prime numbers are nu` vs …`We are asked: "List `

## gemma-4-e4b

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 62.1 | 1359 | 1346 (4) | 486 | 15941 | 799 | 45.2 | 20176 | 20139 (0) | 99.3 | 7606 | 2.1 | 1.0 |
| mlx-bun-serial | 61.9 | 1285 | 1286 (4) | 515 | 15903 | 807 | 44.0 | 19969 | 19939 (0) | 59.1 | 8357 | 1.4 | 1.0 |
| mlx-lm | 53.7 | 971 | 252 (666) | 687 | 15764 | 878 | 43.8 | 306 | 19885 (0) | 74.4 | 7381 | 3.6 | 1.5 |
| mlx-bun-mixed | 57.7 | 1372 | 1327 (4) | 481 | 15940 | 728 | 49.0 | 21935 | 22122 (0) | 96.3 | 7252 | 1.5 | 1.0 |
| optiq-mixed | 53.2 | 972 | 256 (665) | 685 | 15801 | 878 | 43.2 | 322 | 22748 (0) | 74.5 | 7351 | 6.1 | 1.2 |

- **parity ✗** bf16 drop-in (vs mlx-lm): prompt_tokens 25 vs 32 (TEMPLATE DRIFT); diverged at char 0: …`Here are the first e` vs …`
Here's a thinking p`
- **parity ✓** unified engine vs --batch 1 pin: 64 greedy tokens identical (prompt_tokens 25 both)
- **parity ✗** mixed-KV (vs optiq): prompt_tokens 25 vs 32 (TEMPLATE DRIFT); diverged at char 0: …`Here are the first e` vs …`
Here's a thinking p`

## gemma-4-12B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 29.7 | 3482 | 261 (664) | 190 | 15796 | 188 | 28.4 | 84378 | 84161 (0) | 40.5 | 11760 | 2.6 | 1.2 |
| mlx-bun-serial | 29.5 | 3429 | 81 (664) | 194 | 15798 | 187 | 28.3 | 409 | 83966 (0) | 27.7 | 11893 | 1.5 | 1.0 |
| mlx-bun-mixed | 28.7 | 3524 | 149 (663) | 188 | 15834 | 171 | 24.4 | 92557 | 92098 (0) | 38.6 | 10016 | 1.5 | 1.0 |
| optiq-mixed | 27.7 | 3637 | 360 (666) | 183 | 15761 | 189 | 26.3 | 394 | 87811 (0) | 34.2 | 9595 | 6.0 | 1.2 |

- **parity ✓** unified engine vs --batch 1 pin: 64 greedy tokens identical (prompt_tokens 29 both)
- **parity ✗** mixed-KV (vs optiq): prompt_tokens 29 vs 32 (TEMPLATE DRIFT); diverged at char 0: …`The first eight prim` vs …`
*   Task 1: List th`

## failures

- cpm5/mlx-bun-serial: The operation timed out.
- 12B/mlx-lm: The operation timed out.
