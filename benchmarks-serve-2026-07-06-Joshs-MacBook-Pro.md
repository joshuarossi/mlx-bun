# serve h2h — 2026-07-06

machine: Apple M1 Max · 32 GB · loadavg { 3.48 3.17 3.16 } · 2026-07-06T04:31:23.191Z
commit: dd365ec

All numbers over HTTP against REAL servers at their real defaults
(mlx-bun arm = the actual CLI). ttft cold = nonce-busted ~1k prompt;
warm = exact repeat (each stack's own prompt cache). ctx figures from
ONE measured prefill (usage.prompt_tokens), decode sampled on 64 tok.

## MiniCPM5-1B

| arm | decode tok/s | ttft cold ms | ttft warm ms (cached) | prefill@1k tok/s | ctx tok | prefill@ctx tok/s | decode@ctx tok/s | ctx repeat ttft ms | agg×4 tok/s | peak RSS MB | ready s |
|---|---|---|---|---|---|---|---|---|---|---|---|
| mlx-bun | 218.0 | 505 | 26 (626) | 1246 | — | — | — | — | 270.3 | 1216 | 0.8 |
| mlx-lm (unstable spread=1.25) | 158.2 | 463 | 99 (626) | 1353 | — | — | — | — | 211.8 | 1213 | 1.4 |

- **parity ✓ (engine)** bf16 drop-in (vs mlx-lm): identical with enable_thinking pinned on (prompt_tokens 27 both). Default renders differ BY DESIGN: our --thinking default is off for this model (documented), theirs follows the template.
