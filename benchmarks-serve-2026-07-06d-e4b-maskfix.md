# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 4.48 3.73 3.24 } · 2026-07-06T20:08:12.639Z
commit: 4f9bad9

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.
mixed-KV: perf = mlx-bun-mixed vs mlx-bun (same engine, scheme on/off);
correctness = script-driven optiq goldens. No optiq-mixed HTTP arm —
optiq serve's kv-quant is inert on this mlx-lm (lab/repro/
optiq-mixed-kv-inert), so that arm would just re-benchmark mlx-lm bf16.

## gemma-4-e4b

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun-serial | 60.0 | 766 | 42 (660) | 862 | 15903 | 872 | 36.4 | 57 | 557 (15902) | 59.8 | 7698 | 2.2 | 1.3 |
| mlx-lm | 51.1 | 985 | 261 (666) | 676 | 15763 | 877 | 40.0 | 323 | 19921 (0) | 74.7 | 7285 | 3.8 | 1.5 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-bun-serial: idle 589 · warmup 5140 · parity 6873 · decode 6940 · ttft1k 6960 · ctx 7056 · restart 7698 · agg 6912 · peak 7698
- mlx-lm: idle 1416 · warmup 7285 · parity 6724 · decode 6726 · ttft1k 6726 · ctx 6731 · restart 7276 · agg 6757 · peak 7285
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

