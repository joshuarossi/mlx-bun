---
title: CLI reference
description: Every mlx-bun command — get, scan, ls, fit, serve, evals, and more.
---

Commands are shown as `mlx-bun <verb>`. From a clone the identical command is
`bun src/cli.ts <verb>`. Model arguments are **substring queries** against the
registry (`e4b`, `26B`, `12B-it`); a query matching more than one model errors
out and lists the candidates — just make it more specific.

## `serve` — run the server

Start the OpenAI/Anthropic-compatible server. Bare `mlx-bun` is an alias for
`mlx-bun serve`.

```sh
mlx-bun serve gemma --port 8080            # OpenAI-compatible server
mlx-bun serve gemma --memory-budget 18     # ...with admission control (GB)
mlx-bun serve e4b --no-open                # don't open the browser chat UI
```

Common flags (full list in [Server configuration](/reference/server-config/)):

| Flag | Effect |
|---|---|
| `--port <n>` | Listen port (default 8080) |
| `--memory-budget <GB>` | Reject loads/requests that can't fit the budget |
| `--no-open` | Don't auto-open the chat UI |
| `--no-kv-quant` / `--kv-bits <n>` | Control mixed-precision KV |
| `--adapter id=dir` | Mount a LoRA adapter at startup |

## `get` — download a model

Resumable, checksum-verified download into the standard Hugging Face cache.

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit
```

Downloads resume across interruption, every blob is sha-verified, and the layout
matches `huggingface_hub` exactly — an existing HF cache is picked up as-is.

## `scan` — index your cache

Index the models in your HF cache into the registry so `ls`, `serve`, and `fit`
can find them by substring.

```sh
mlx-bun scan
```

## `ls` — list models

```sh
mlx-bun ls                          # size, params, quant, capabilities
mlx-bun ls --vision --max-size 10GB # filter
```

## `fit` — memory contract

Deterministic memory assessment: does it fit, what's the max context, predicted
tok/s.

```sh
mlx-bun fit gemma --ctx 32768          # for this machine
mlx-bun fit gemma --ctx 8192 --skus    # across the Apple Silicon lineup
```

See [Choosing a model](/getting-started/models/) for how it computes.

## `evals` — recorded benchmark runs

```sh
mlx-bun evals
```

## `harness pi` — connect pi

Point your own [pi](https://pi.dev) install at the local server.

```sh
mlx-bun harness pi
```

## Benchmarks

The head-to-head matrix against mlx-lm/optiq is a script (reboot first for clean
numbers; it's preflight-gated and resumable, writing `benchmarks-h2h-<date>.md`):

```sh
./benchmark.sh
```
