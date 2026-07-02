---
title: Drop-in for mlx-lm
description: Stop mlx_lm.server, start mlx-bun serve — the same clients, curl commands, and defaults keep working.
---

:::note[Version]
The full drop-in surface described here ships in **v0.0.9**. On v0.0.8 the
core chat-completions path already works; the raw-completions endpoint,
`/health`, logprobs, sampler-field parity, and the `fuse`/`convert`/
`perplexity`/`upload` verbs are v0.0.9.
:::

If you run [`mlx_lm.server`](https://github.com/ml-explore/mlx-lm) today, you
can stop it and start `mlx-bun serve` — same port, same host, same endpoints,
same request fields. Your existing curl commands and client configs keep
working, and the logits are **bit-exact** to mlx-lm's on the supported models
(that's the project's [correctness oracle](/about/correctness/)).

```sh
# before
mlx_lm.server --model mlx-community/Llama-3.2-1B-Instruct-4bit

# after — same clients, no Python
mlx-bun serve Llama-3.2-1B
```

## What matches

| Surface | Parity |
|---|---|
| `POST /v1/chat/completions` | Streaming + non-streaming, same fields |
| `POST /v1/completions` | Raw text completion, stream + non-stream |
| `GET /health` | Byte-exact body |
| `GET /v1/models` | Lists your downloaded models (+ `/v1/models/<id>`) |
| Defaults | Port **8080**, loopback-only host (`--host 0.0.0.0` = LAN opt-in) |
| Sampling fields | `min_p`, `xtc_probability`/`xtc_threshold`, `logit_bias`, `presence_penalty`/`frequency_penalty` (+ `*_context_size` windows) — L1-faithful ports of mlx-lm's `sample_utils.py` |
| `logprobs` / `top_logprobs` | mlx-lm's exact semantics: same distribution, same response shape, same `[0,11]` validation |
| Flags | `--temp` alias, `--max-tokens`, `--adapter <dir>` (`--adapter-path` accepted), `--decode-concurrency` accepted as an alias for `--batch` |

Under the `--l1` tier the decode route is **bit-for-bit identical** to mlx-lm
(bf16 KV, unfused) — not "compatible," identical logits.

## Tool parity beyond the server

The mlx-lm workflow tools have native counterparts (v0.0.9), flag names
matching the Python spellings:

- `mlx-bun fuse` — fold a LoRA adapter into the base weights (mlx-lm math;
  untouched modules bit-identical).
- `mlx-bun convert` — quantize an HF model, including mixed-precision
  `--target-bpw` (the mlx-bun differentiator).
- `mlx-bun perplexity` — `mlx_lm.perplexity` methodology exactly, over a local
  file.
- `mlx-bun upload` — native push-to-hub, no Python.

See the [CLI reference](/reference/cli/) for each.

## Deliberately not ported

Honest gaps, so you can decide before switching:

- `role_mapping` — unreachable in practice; every supported model ships a chat
  template.
- `mlx_lm.cache_prompt` and `mlx_lm.evaluate` — not yet (an lm-eval shim is
  planned).
- `--draft-model` speculative decoding.
- awq / dwq / gptq quantization modes (`convert` supports affine + the
  mixed-precision `--target-bpw` path).

Each unported flag **errors out explicitly** rather than silently guessing.

## What you gain

Beyond compatibility: one signed binary with no Python or venv, [2–5× faster
server startup and TTFT](/about/benchmarks/), the Anthropic Messages and
OpenAI Responses protocols on the same port, a byte-capped prompt cache,
LoRA hot-swap, and [memory admission control](/guides/http-api/).
