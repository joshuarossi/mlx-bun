# CLI reference

Every mlx-bun verb. Commands are shown as `mlx-bun <verb>`; from a clone the
identical command is `bun src/cli.ts <verb>`. `mlx-bun help <verb>` (or
`mlx-bun <verb> --help`) prints the full flag list for any command.

Model arguments are **substring queries** against the registry (`e4b`, `26B`,
`12B-it`); a query matching more than one model errors out and lists the
candidates — just make it more specific.

Bare `mlx-bun` with no verb runs `serve` — the appliance path: first run
downloads a starter model, serves it, and opens the chat UI.

> Verbs marked **(v0.0.9)** ship in v0.0.9; everything else is in v0.0.8.

## Serving & chat

### `serve` — run the server

Start the OpenAI/Anthropic-compatible server plus the status page and browser
chat UI.

```sh
mlx-bun serve                              # default model, http://localhost:8080
mlx-bun serve e4b                          # pick a model by substring
mlx-bun serve gemma --memory-budget 18     # ...with admission control (GB)
mlx-bun serve e4b --no-open                # don't open the browser chat UI
```

Common flags (full list in [server-config.md](server-config.md)):

| Flag | Effect |
|---|---|
| `--host <addr>` | Interface to bind (default `127.0.0.1`, loopback only; `0.0.0.0` to expose) |
| `--port <n>` | Listen port (default 8080) |
| `--memory-budget <GB>` | Reject loads/requests that can't fit the budget |
| `--kv-quant config\|off\|4\|8` | KV cache quantization: per-layer `kv_config.json`, bf16, or uniform bits (default `config`) |
| `--adapter <dir>` | Mount a LoRA adapter at startup (`--adapter-path` accepted as the mlx_lm.server alias) |
| `--batch <n>` | Continuous-batched bf16 serving (default 1 = serial) |
| `--temperature` / `--top-p` / `--top-k` / `--max-tokens` | Server-wide sampling defaults (per-request fields still win) |
| `--l1` / `--l2` / `--l3` | Parity tier: bit-exact to mlx-lm / bit-exact to mlx-optiq / best performance |
| `--no-open` | Don't auto-open the chat UI |

Endpoints: `/v1/chat/completions`, `/v1/completions`, `/v1/messages`,
`/v1/responses`, `/v1/models`, `/v1/adapters`, `/health`, `/stats`, `/fit`,
`/library`, `/downloads` — status page at `/`, browser chat at `/chat`. Full
schemas in [server-api.md](server-api.md).

### `pi` — built-in coding agent

Run the pi coding agent's terminal UI in-process against a local model —
nothing to install. Reuses a healthy running server, otherwise starts one for
the session.

```sh
mlx-bun pi                          # interactive agent session
mlx-bun pi -p "explain this repo"   # one-shot: print the reply and exit
```

### `harness pi` — connect your own pi

For people who already use
[pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent): installs a small,
reversible discovery extension that registers the local server as a pi
provider.

```sh
mlx-bun harness pi              # then: pi --provider mlx-bun
mlx-bun harness pi --remove     # disconnect
```

### `generate` (alias `gen`) — one-shot generation

Load the model, generate, print, exit — no server. Renders through the chat
template by default; `--raw` feeds the prompt verbatim. Sampling and
decode-path levers mirror `serve` (`--temperature`, `--seed`, `--l1/--l2/--l3`,
`--kv-quant`, …).

```sh
mlx-bun generate gemma "a haiku about metal shaders"
mlx-bun gen e4b --prompt "…" --max-tokens 512 --seed 42
```

### `embed` — text embeddings **(v0.0.9)**

One-shot embeddings from a local Qwen3-Embedding model (last-token pooled,
L2-normalized — bit-exact vs mlx-lm). One JSON vector per input line.

```sh
mlx-bun embed --text "hello world"
echo -e "line one\nline two" | mlx-bun embed --json
```

For a server endpoint, `mlx-bun serve <embedding-model>` then
`POST /v1/embeddings`.

## Models & disk

Full guide: [models.md](models.md).

### `get` — download a model

Resumable, checksum-verified download into the standard Hugging Face cache
(plain HTTPS, no Xet — no 0% stalls).

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit
mlx-bun get 12B                  # no "/" = registry query; re-gets/refreshes the match
```

### `scan` — index your cache

Re-index the HF cache into the registry (config + safetensors headers only,
never tensor bytes) so `ls`, `serve`, and `fit` can find models by substring.

```sh
mlx-bun scan
```

### `ls` — list models

```sh
mlx-bun ls                          # size, params, quant, capabilities
mlx-bun ls --vision --max-size 10GB # filter
mlx-bun ls --all-revisions          # one row per cached snapshot
```

### `gc` — reclaim disk **(v0.0.9)**

Delete superseded snapshots and the blobs only they reference. Prints the plan
by default; `--yes` actually deletes.

```sh
mlx-bun gc          # dry-run: what would be reclaimed
mlx-bun gc --yes    # delete
```

### `fit` — memory contract

Deterministic memory assessment: does it fit, what's the max context, predicted
tok/s. Weights bytes from safetensors headers, KV bytes/token from the config,
calibrated prefill transient, wired-memory ceiling.

```sh
mlx-bun fit gemma --ctx 32768          # for this machine
mlx-bun fit gemma --ctx 8192 --skus    # across the Apple Silicon lineup
```

## Training & model creation

Full reference: [training.md](training.md); guided walkthrough:
[orpo-quickstart.md](orpo-quickstart.md).

### `train` — LoRA fine-tune

SFT / DPO / ORPO on your data, with the full memory stack (flash-CCE head,
prefix-sharing, segmented backward) on by default. Saves a mountable adapter.

```sh
mlx-bun train e4b --data ./prefs                     # ORPO (default) on {prompt,chosen,rejected}
mlx-bun train e4b --data ./prefs --method sft        # SFT on {messages|text}
mlx-bun train e4b --data ./prefs --dry-run           # inspect the plan, don't train
```

### `train-watch` — live training dashboard

Tails an adapter dir's `metrics.jsonl` and renders live loss / speed / memory.

```sh
mlx-bun train-watch ~/.cache/mlx-bun/mlx-bun-finetunes/orpo-e4b
```

### `fuse` — merge an adapter into the base **(v0.0.9)**

Folds LoRA deltas into the base weights and writes a standalone snapshot; a
quantized base keeps its exact quantization layout. Flag names match
`mlx_lm.fuse`.

```sh
mlx-bun fuse e4b --adapter ./adapters --save-path ./fused_model
mlx-bun serve ./fused_model
```

### `convert` — quantize a model **(v0.0.9)**

Quantize an HF model (local path, downloaded model, or repo id) into a local
MLX snapshot — uniform 4/8-bit, or mixed-precision via `--target-bpw`
(sensitivity sweep + per-layer bit knapsack). `--upload-repo` pushes the result.

```sh
mlx-bun convert Qwen/Qwen3-4B -q                      # uniform 4-bit
mlx-bun convert Qwen/Qwen3-4B --target-bpw 4.5        # mixed precision
```

### `upload` — push to the Hugging Face Hub **(v0.0.9)**

Native push-to-hub, no Python: creates the repo if needed, uploads via the
git-LFS batch protocol, commits. Flag names match `mlx_lm.upload`.

```sh
mlx-bun upload --path ./fused_model --upload-repo you/my-model
```

### `perplexity` — evaluate on your data **(v0.0.9)**

`mlx_lm.perplexity` methodology exactly, over a **local** `.jsonl`/`.txt` file.

```sh
mlx-bun perplexity e4b --data-path ./corpus.jsonl
```

## Memory

### `memory` — the personal wiki

A local, durable memory for the assistant: a git-tracked Markdown wiki at
`~/.mlx-bun/wiki` that loads into every `mlx-bun pi` / `mlx-bun serve` session.
Full guide: [memory.md](memory.md).

```sh
mlx-bun memory init              # create the wiki (idempotent); import + schedule
mlx-bun memory status            # path, article count, git + schedule state
mlx-bun memory open [article]    # open in Obsidian (falls back to Finder)
mlx-bun memory search <query>    # search articles from the terminal
mlx-bun memory synthesize        # conversations → cross-linked articles, all local
mlx-bun memory schedule --at 03:00
```

`setup` is an alias for `memory` **(v0.0.9)**.

## Measurement

### `benchmark` (alias `bench`) — measure our stack

Runs mlx-bun by itself on this machine and records to the eval DB.

```sh
mlx-bun bench e4b --tokens 256 --runs 3
```

For quotable **cross-stack** numbers use `./benchmark.sh` from the repo — it
preflight-gates on an idle machine and runs the mlx-lm/optiq comparison legs,
writing `benchmarks-h2h-<date>.md`.

### `evals` — recorded runs

```sh
mlx-bun evals                # table: when, model, KV mode, tok/s, TTFT, peak, commit
mlx-bun evals --raw          # JSON lines for scripts/jq
```

## Everything else

- `help [verb]` — overview, or per-verb help (same as `<verb> --help`).
- `--version` / `-v` — print the version.
