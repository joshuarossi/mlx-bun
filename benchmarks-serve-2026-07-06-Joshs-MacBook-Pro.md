# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 3.09 3.06 3.10 } · 2026-07-06T04:37:25.761Z
commit: e0ec46f

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | restart ctx ttft ms (cached) | agg×4 tok/s | peak RSS MB | cold start s | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 216.8 | 461 | 26 (627) | 1358 | 3989 | 1326 | 189.1 | 26 | 114 (3988) | 241.3 | 1452 | 1.2 | 1.0 |
| mlx-lm | 136.0 | 483 | 104 (623) | 1294 | 4020 | 1312 | 104.6 | 126 | 3172 (0) | 190.5 | 1212 | 2.1 | 1.2 |

- **parity ✓ (engine)** bf16 drop-in (vs mlx-lm): identical with enable_thinking pinned on (prompt_tokens 27 both). Default renders differ BY DESIGN: our --thinking default is off for this model (documented), theirs follows the template.
