# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 4.96 4.32 4.03 } · 2026-07-06T15:00:50.253Z
commit: 6fc281d

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.
mixed-KV: perf = mlx-bun-mixed vs mlx-bun (same engine, scheme on/off);
correctness = script-driven optiq goldens. No optiq-mixed HTTP arm —
optiq serve's kv-quant is inert on this mlx-lm (lab/repro/
optiq-mixed-kv-inert), so that arm would just re-benchmark mlx-lm bf16.

## gemma-4-12B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-lm | 26.1 | 3719 | 397 (667) | 180 | 15725 | 181 | 25.0 | 400 | 89376 (0) | 32.9 | 9561 | 7.6 | 1.7 |

per-leg peak RSS MB (sampler max between leg boundaries; idle = right after ready):
- mlx-lm: idle 117 · warmup 9543 · parity 8933 · decode 8941 · ttft1k 8942 · ctx 8945 · restart 9561 · agg 8779 · peak 9561
- note: mlx-bun arms carry --ssd-cache; its write-behind transiently duplicates entry bytes host-side (ctx/restart legs read high — fix A7 pending in src)

