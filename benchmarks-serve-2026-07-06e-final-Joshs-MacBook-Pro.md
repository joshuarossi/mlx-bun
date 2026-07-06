# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 3.41 4.14 3.53 } · 2026-07-06T20:10:54.664Z
commit: 4f9bad9

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
| mlx-bun (stabilized top3of6) | 258.3 | 243 | 27 (628) | 2585 | 15817 | 1674 | 111.7 | 27 | 133 (15816) | 450.6 | 1732 | 1.0 | 0.8 |
| mlx-bun-serial (unstable spread=1.15) | 243.5 | 238 | 29 (626) | 2630 | 15853 | 1690 | 116.2 | 37 | 129 (15852) | 247.3 | 1736 | 0.9 | 0.8 |
| mlx-lm (stabilized top3of6) | 196.7 | 326 | 81 (625) | 1915 | 15887 | 1509 | 98.9 | 117 | 9953 (0) | 190.7 | 1219 | 1.7 | 1.0 |
| mlx-bun-mixed (unstable spread=2.02) | 180.0 | 265 | 26 (626) | 2369 | 15850 | 1021 | 99.7 | 32 | 122 (15849) | 411.5 | 1483 | 0.9 | 0.8 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 311 · warmup 1193 · parity 1205 · decode 1239 · ttft1k 1244 · ctx 1265 · restart 1732 · agg 1220 · peak 1732
- mlx-bun-serial: idle 310 · warmup 1200 · parity 1206 · decode 1252 · ttft1k 1257 · ctx 1278 · restart 1736 · agg 1234 · peak 1736
- mlx-lm: idle 785 · warmup 1218 · parity 1179 · decode 1180 · ttft1k 1180 · ctx 1195 · restart 1200 · agg 1219 · peak 1219
- mlx-bun-mixed: idle 309 · warmup 309 · parity 1218 · decode 1245 · ttft1k 1249 · ctx 1284 · restart 1483 · agg 1233 · peak 1483
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✗** bf16 drop-in (vs mlx-lm) [completion-probe]: same prompt bits (prompt_tokens 7 both), diverged at char 249: …`numbers greater than ` vs …`numbers greater than`
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 7 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 27 both)

- kv-quant check ✓ — mlx-bun-mixed peak RSS 1483 MB vs mlx-bun 1732 MB (expect mixed < bf16)

## gemma-4-e4b

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 58.7 | 759 | 40 (659) | 869 | 15940 | 877 | 37.7 | 69 | 567 (15939) | 99.9 | 7790 | 1.4 | 1.0 |
| mlx-bun-serial | 59.9 | 759 | 39 (659) | 870 | 15942 | 874 | 34.1 | 57 | 540 (15941) | 60.0 | 7756 | 1.4 | 1.0 |
| mlx-lm | 51.1 | 972 | 253 (667) | 687 | 15726 | 833 | 43.8 | 305 | 20411 (0) | 71.9 | 7272 | 3.2 | 1.0 |
| mlx-bun-mixed | 49.1 | 780 | 62 (660) | 848 | 15905 | 783 | 40.6 | 61 | 549 (15904) | 96.7 | 7235 | 1.5 | 1.1 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 590 · warmup 590 · parity 6880 · decode 6949 · ttft1k 6972 · ctx 7037 · restart 7790 · agg 6901 · peak 7790
- mlx-bun-serial: idle 591 · warmup 591 · parity 6884 · decode 6950 · ttft1k 6976 · ctx 7087 · restart 7756 · agg 6910 · peak 7756
- mlx-lm: idle 307 · warmup 7271 · parity 6710 · decode 6710 · ttft1k 6720 · ctx 6725 · restart 7272 · agg 6754 · peak 7272
- mlx-bun-mixed: idle 588 · warmup 6871 · parity 6882 · decode 6914 · ttft1k 6926 · ctx 6965 · restart 7235 · agg 6928 · peak 7235
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✓** bf16 drop-in (vs mlx-lm) [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ✓ — mlx-bun-mixed peak RSS 7235 MB vs mlx-bun 7790 MB (expect mixed < bf16)

## gemma-4-12B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 26.4 | 3441 | 92 (663) | 193 | 15833 | 184 | 23.0 | 168 | 1126 (15829) | 37.2 | 10170 | 2.6 | 1.2 |
| mlx-bun-serial | 27.8 | 3433 | 77 (661) | 194 | 15871 | 183 | 22.7 | 155 | 1163 (15867) | 27.5 | 9682 | 1.8 | 1.2 |
| mlx-lm | 25.7 | 3663 | 360 (665) | 182 | 15798 | 186 | 26.5 | 394 | 88432 (0) | 30.0 | 9518 | 6.5 | 1.7 |
| mlx-bun-mixed | 23.0 | 3509 | 93 (663) | 189 | 15835 | 172 | 19.9 | 228 | 644 (15831) | 39.6 | 10291 | 2.1 | 1.4 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun: idle 588 · warmup 9025 · parity 9125 · decode 9561 · ttft1k 9617 · ctx 9655 · restart 10170 · agg 9117 · peak 10170
- mlx-bun-serial: idle 587 · warmup 9061 · parity 9159 · decode 9559 · ttft1k 9630 · ctx 9682 · restart 9104 · agg 9151 · peak 9682
- mlx-lm: idle 117 · warmup 9518 · parity 8941 · decode 8949 · ttft1k 8950 · ctx 8956 · restart 9505 · agg 8993 · peak 9518
- mlx-bun-mixed: idle 590 · warmup 8870 · parity 9088 · decode 9202 · ttft1k 9222 · ctx 9275 · restart 10291 · agg 9128 · peak 10291
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

- **parity ✗** bf16 drop-in (vs mlx-lm) [completion-probe]: same prompt bits (prompt_tokens 6 both), diverged at char 24: …`111111111111111111111.1111.1111111111111` vs …`11111111111111111111..111.1.1.1.1...1...`
- **parity ✓** bf16 drop-in (vs mlx-lm) [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)
- **parity ✓** unified engine vs --batch 1 pin [completion-probe]: 64 greedy tokens identical (prompt_tokens 6 both)
- **parity ✓** unified engine vs --batch 1 pin [chat-probe]: 64 greedy tokens identical (prompt_tokens 32 both)

- kv-quant check ⚠ — mlx-bun-mixed peak RSS 10291 MB vs mlx-bun 10170 MB (expect mixed < bf16 — SUSPECT SILENT BF16: quantization hooks may not be live on the measured path)
