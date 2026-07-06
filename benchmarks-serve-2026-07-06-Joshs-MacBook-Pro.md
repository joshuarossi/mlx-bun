# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 3.34 3.63 3.52 } · 2026-07-06T04:15:23.682Z
commit: 5a05f43

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | agg×4 tok/s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 212.1 | 415 | 29 (627) | 1512 | 7941 | 1254 | 139.5 | 40 | 257.5 | 0.8 |
