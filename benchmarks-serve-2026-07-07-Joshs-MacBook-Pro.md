# serve h2h — 2026-07-07

machine: Apple M1 Max · 32 GB · loadavg { 3.50 2.38 6.14 } · 2026-07-07T02:01:01.950Z
commit: 3d56676

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.
mixed-KV: perf = mlx-bun-mixed vs mlx-bun (same engine, scheme on/off);
correctness = script-driven optiq goldens. No optiq-mixed HTTP arm —
optiq serve's kv-quant is inert on this mlx-lm (lab/repro/
optiq-mixed-kv-inert), so that arm would just re-benchmark mlx-lm bf16.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun (unstable spread=1.32) | 237.1 | 243 | 26 (625) | 2585 | 15887 | 1712 | 113.9 | 28 | 157 (15886) | 454.1 | 1718 | 1.2 | 1.0 |
| mlx-bun-serial (stabilized top3of8) | 272.4 | 226 | 28 (627) | 2775 | 15816 | 1724 | 108.1 | 45 | 141 (15815) | 247.5 | 1558 | 0.9 | 0.8 |
| mlx-lm | 199.5 | 325 | 83 (624) | 1929 | 15921 | 1532 | 98.0 | 125 | 10600 (0) | 189.1 | 1216 | 3.1 | 3.0 |
| mlx-bun-mixed (unstable spread=2.02) | 184.1 | 266 | 29 (627) | 2361 | 15818 | 1023 | 106.9 | 27 | 126 (15817) | 410.5 | 1447 | 0.9 | 0.8 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 313 · warmup 313 · parity 1203 · decode 1246 · ttft1k 1249 · ctx 1259 · restart 1718 · agg 1212 · peak 1718
- mlx-bun-serial: idle 313 · warmup 1204 · parity 1212 · decode 1250 · ttft1k 1251 · ctx 1266 · restart 1558 · agg 1229 · peak 1558
- mlx-lm: idle 1148 · warmup 1152 · parity 1174 · decode 1174 · ttft1k 1175 · ctx 1190 · restart 1190 · agg 1216 · peak 1216
- mlx-bun-mixed: idle 308 · warmup 1200 · parity 1216 · decode 1245 · ttft1k 1248 · ctx 1284 · restart 1447 · agg 1240 · peak 1447
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✗** bf16 drop-in (vs mlx-lm) [completion-probe]: same prompt bits (prompt_tokens 7 both), diverged at char 249: …`numbers greater than ` vs …`numbers greater than`
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 7 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)

- kv-quant check ✓ — mlx-bun-mixed peak RSS 1447 MB vs mlx-bun 1718 MB (expect mixed < bf16)

## gemma-4-e4b

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 59.4 | 760 | 46 (659) | 869 | 15941 | 870 | 39.1 | 69 | 653 (15940) | 99.6 | 7452 | 2.4 | 1.2 |
| mlx-bun-serial | 60.2 | 753 | 41 (660) | 877 | 15902 | 869 | 38.1 | 55 | 616 (15901) | 59.8 | 7758 | 1.5 | 1.0 |
| mlx-lm | 53.1 | 974 | 256 (666) | 685 | 15761 | 878 | 43.1 | 312 | 19906 (0) | 72.4 | 7368 | 3.7 | 1.5 |
| mlx-bun-mixed | 49.1 | 766 | 46 (658) | 861 | 15941 | 795 | 41.2 | 59 | 628 (15940) | 97.1 | 7218 | 1.5 | 1.1 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 590 · warmup 5245 · parity 6491 · decode 6564 · ttft1k 6604 · ctx 6692 · restart 7452 · agg 6903 · peak 7452
- mlx-bun-serial: idle 591 · warmup 6875 · parity 6888 · decode 6955 · ttft1k 6975 · ctx 7075 · restart 7758 · agg 6911 · peak 7758
- mlx-lm: idle 1885 · warmup 7329 · parity 6715 · decode 6724 · ttft1k 6726 · ctx 6728 · restart 7368 · agg 6763 · peak 7368
- mlx-bun-mixed: idle 589 · warmup 6864 · parity 6886 · decode 6918 · ttft1k 6934 · ctx 6972 · restart 7218 · agg 6928 · peak 7218
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✓** bf16 drop-in (vs mlx-lm) [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ✓ — mlx-bun-mixed peak RSS 7218 MB vs mlx-bun 7452 MB (expect mixed < bf16)

## gemma-4-12B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 27.4 | 3465 | 81 (662) | 191 | 15872 | 187 | 24.5 | 153 | 1266 (15868) | 40.5 | 10627 | 2.6 | 1.2 |
| mlx-bun-serial | 28.5 | 3434 | 73 (663) | 193 | 15833 | 188 | 25.2 | 144 | 1217 (15829) | 28.6 | 10339 | 1.8 | 1.2 |
| mlx-lm | 26.9 | 3656 | 367 (665) | 183 | 15800 | 188 | 25.5 | 397 | 102775 (0) | 33.1 | 9587 | 6.7 | 1.7 |
| mlx-bun-mixed | 23.7 | 3524 | 86 (664) | 189 | 15796 | 172 | 21.5 | 214 | 662 (15792) | 39.1 | 10216 | 2.0 | 1.4 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 591 · warmup 8775 · parity 9069 · decode 9487 · ttft1k 9509 · ctx 9271 · restart 10627 · agg 9121 · peak 10627
- mlx-bun-serial: idle 586 · warmup 9059 · parity 9156 · decode 9569 · ttft1k 9656 · ctx 9691 · restart 10339 · agg 9161 · peak 10339
- mlx-lm: idle 117 · warmup 9488 · parity 8934 · decode 8942 · ttft1k 8944 · ctx 8952 · restart 9587 · agg 8992 · peak 9587
- mlx-bun-mixed: idle 590 · warmup 9065 · parity 9091 · decode 9198 · ttft1k 9222 · ctx 9276 · restart 10216 · agg 9124 · peak 10216
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✗** bf16 drop-in (vs mlx-lm) [completion-probe]: same prompt bits (prompt_tokens 6 both), diverged at char 24: …`111111111111111111111.1111.1111111111111` vs …`11111111111111111111..111.1.1.1.1...1...`
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ✓ — mlx-bun-mixed peak RSS 10216 MB vs mlx-bun 10627 MB (expect mixed < bf16)
