# CLI reference

Every mlx-bun verb. Commands are shown as `mlx-bun <verb>`; from a clone the
identical command is `bun src/cli.ts <verb>`. `mlx-bun help <verb>` (or
`mlx-bun <verb> --help`) prints the full flag list for any command.

Model arguments are **substring queries** against the registry (`e4b`, `26B`,
`12B-it`); a query matching more than one model errors out and lists the
candidates — just make it more specific.

Bare `mlx-bun` with no verb runs `serve` — the appliance path: first run
downloads a starter model, serves it, and opens the chat UI.

> All verbs below ship in current releases; the release notes in
> `docs/planning/` record when each verb first appeared.

## Serving & chat

### `serve` — run the server

Start the OpenAI/Anthropic-compatible server plus the browser web app (chat,
status, and model tools).

```sh
mlx-bun serve                              # default model, http://localhost:8080
mlx-bun serve e4b                          # pick a model by substring
mlx-bun serve gemma --memory-budget 18     # ...with admission control (GB)
mlx-bun serve e4b --no-open                # don't open the browser chat UI
mlx-bun serve GLM-5.2 --context-length 4096 # bounded Colibri runtime, native MTP
```

Common flags (full list in [server-config.md](server-config.md)):

| Flag | Effect |
|---|---|
| `--host <addr>` | Interface to bind (default `127.0.0.1`, loopback only; `0.0.0.0` to expose) |
| `--port <n>` | Listen port (default 8080) |
| `--memory-budget <GB>` | Reject loads/requests that can't fit the budget |
| `--kv-budget <GB>` | Aggregate KV budget across concurrent batch rows: over-budget joiners queue until rows finish; a request over the budget alone is rejected (off unless set) |
| `--prompt-cache <GB>` | RAM prefix-KV cache, byte-capped LRU (default 8; `0` disables). Non-consuming prefix sharing: a hit clones instead of consuming the donor entry |
| `--isolate` | Run the inference engine as a crash-isolated child process on a unix socket; this process becomes a pure reverse-proxy (instant under GPU load, auto-respawns on engine crash) — default off ([runtime-isolation.md](../design/runtime-isolation.md)) |
| `--model-pool <n>` | With `--isolate`: cap on resident per-model engine children (default 1); over the cap the LRU engine drains its cache to the SSD tier and exits, respawning on demand |
| `--ssd-cache <dir>` | SSD cold tier under the prompt cache: idle/evicted prefix-KV spills to disk and restores on reattach, surviving restarts (default off — [ssd-kv-cold-tier.md](../design/ssd-kv-cold-tier.md)) |
| `--ssd-cache-max <GB>` | SSD tier byte cap, oldest-mtime evicted first (default 32; `--ssd-cache` only) |
| `--ssd-cache-verify` | Verify every tensor hash on restore, not just the header (integrity paranoia; roughly doubles restore reads; `--ssd-cache` only) |
| `--ssd-demote-idle <sec>` | Idle prompt-cache entries spill to the SSD tier and free GPU memory after this long (default 300 with `--ssd-cache`; `0` disables) |
| `--kv-quant config\|off\|4\|8\|turbo[:k<bits>v<bits>]` | KV cache quantization: per-layer `kv_config.json`, bf16, uniform bits, or TurboQuant (rotation-based, default `k8v3` — [turboquant-kv.md](../design/turboquant-kv.md); full-attention layers only, solo-only/serial) (default `off` — quantized KV trades 5–20% decode speed for memory headroom, so it's opt-in) |
| `--paged-kv` | OPTIONAL vLLM-style paged KV cache (block pool + gather before the stock SDPA; env `MLX_BUN_PAGED_KV=1`) — bit-exact with the plain path, default off. v1: serial only (pins `--batch 1` unless `--batch` is given; refuses `--batch N>1`, `--kv-quant`, `--draft-model`), Gemma4-family, bf16; bypasses the prompt cache and runs uncompiled decode. Expect a small decode cost at batch=1 — v1 ships the abstraction for batched/CoW follow-ups ([paged-kv-cache.md](../design/paged-kv-cache.md)) |
| `--paged-kv-block-size <n>` | Tokens per KV block (default 256 = the plain cache's growth step; `--paged-kv` only) |
| `--adapter <dir>` | Mount a LoRA adapter at startup (`--adapter-path` accepted as the mlx_lm.server alias) |
| `--draft-model <path\|query>` | Speculative decoding: a drafter proposes, the main model verifies — exact results, faster decode when drafts land. The artifact's kind is auto-detected: a full same-tokenizer model (mlx_lm.server parity), a Gemma `-assistant` KV-borrowing drafter, a DSpark checkpoint trained here, or one of DeepSeek's released DSpark drafters (DeepSpec `Gemma4DSparkModel`, e.g. `dspark_gemma4_12b_block7`). Serial lane only: with `--batch N` a mounted draft routes every request serial |
| `--draft-kind <kind>` | Override draft-artifact detection: `two-model` \| `assistant` \| `dspark` \| `deepspec` \| `mtp` \| `ngram` (default: auto). `mtp` is a NATIVE multi-token-prediction head split from the target's own release (e.g. `mlx-community/Qwen3.8-27B-MTP-bf16`; auto-detected from a `*_mtp` `model_type`) — it binds the target's embeddings/lm-head and taps its pre-final-norm hiddens, and the serve loop rolls the target's recurrent DeltaNet caches back across rejected drafts via bit-exact snapshot/replay. `ngram` is MODEL-FREE prompt lookup — no `--draft-model` (mounting one alongside it is refused): drafts are copied from the request's own prompt+generation whenever its trailing tokens have occurred earlier in that stream, verified by the target like any other draft, so results stay exact at any temperature. Zero weights, zero memory; best on agentic/RAG/code-edit traffic that re-emits spans already in context (prior art: prompt-lookup decoding / vLLM's `ngram` proposer) |
| `--num-draft-tokens <n>` | Drafts per verify round (default 3; `ngram` defaults to 10 — drafting is free; a DSpark draft pins to its trained block width) |
| `--ngram-max <k>` / `--ngram-min <k>` | Prompt-lookup match-window bounds, `--draft-kind ngram` only: the longest/shortest trailing k-gram searched (defaults 3 / 1, the reference values) |
| `--mtp on\|off` | GLM-5.2 checkpoint-native MTP (default on). Native MTP uses the exact serial verify lane; `off` enables ordinary continuous batching (batched per-row MTP is post-release) |
| `--context-length <n>` | GLM-5.2 context reserved by the header-only resource equation (default 4096) |
| `--batch <n>` | Continuous-batched serving cap, mlx-lm B=N parity (default 8; `--batch 1` pins the serial path) |
| `--temperature` / `--top-p` / `--top-k` / `--max-tokens` | Server-wide sampling defaults (per-request fields still win; GLM-5.2 defaults to the planned 128 generated tokens) |
| `--l1` / `--l2` | Parity tier alias: bit-exact to mlx-lm / bit-exact to mlx-optiq. **No tier = `--l1`** (the default since 2026-07-05 — output-changing levers are opt-in until they beat the L1 baseline in a paired A/B). Each expands to per-fork flags (`--compiled-decode`, `--compiled-activations`, `--fused-sdpa`, `--kv-quant`); a fork flag overrides one. `--l3` was removed 2026-07-05 and now errors (the Lab replaces it — [unified-engine-frontier-plan.md](../design/unified-engine-frontier-plan.md)). See [server-config.md](server-config.md#fidelity-tiers-and-the-decode-route---l1----l2). |
| `--allow-private-media` | Let `image_url`/`audio_url` parts fetch from private/loopback/link-local hosts (blocked by default — SSRF guard; the 10 s timeout and 64 MB cap on remote media apply either way) |
| `--no-open` | Don't auto-open the chat UI |

Endpoints: `/v1/chat/completions`, `/v1/completions`, `/v1/messages`,
`/v1/responses`, `/v1/models`, `/v1/adapters`, `/health`, `/stats`, `/fit`,
`/library`, `/downloads` — web app at `/` (lands on chat); `/chat`, `/status`,
`/quantize`, `/finetune`, `/dataset` deep-link its views. Full
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
decode-path levers mirror `serve` (`--temperature`, `--seed`, `--l1/--l2`,
`--kv-quant`, …).

```sh
mlx-bun generate gemma "a haiku about metal shaders"
mlx-bun gen e4b --prompt "…" --max-tokens 512 --seed 42
mlx-bun generate GLM-5.2 --prompt "Explain DSA" --max-tokens 128
```

### `embed` — text embeddings

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
(plain HTTPS, no Xet — no 0% stalls). Before payload transfer, the downloader
credits complete blobs and partial prefixes, then requires enough free space
for the exact remainder plus a fixed 1 GiB reserve.

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit
mlx-bun get 12B                  # no "/" = registry query; re-gets/refreshes the match
mlx-bun get mateogrgic/GLM-5.2-colibri-int4-with-int8-mtp \
  --revision 3cc8db99b1b13fc79325d987ba3c1c430766b3b8
```

The GLM artifact is roughly 357 GiB; select `HF_HUB_CACHE` on a sufficiently
large fast volume before starting. Rerunning the same command resumes verified
`.incomplete` prefixes. See the [32 GB GLM quickstart](models.md#glm-52-on-a-32-gb-mac).

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

### `gc` — reclaim disk

Delete superseded snapshots and the blobs only they reference. Prints the plan
by default; `--yes` actually deletes. Same planner (`src/registry.ts`
`planGc`/`executeGc`) also backs `GET /api/gc/plan` / `POST /api/gc/execute`
on a running `serve` — see [server-api.md](server-api.md#get-apigcplan--post-apigcexecute).

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

The direct Colibri GLM-5.2 artifact is handled by its streamed-runtime
contract, not by the generic resident-weights estimator. `fit GLM-5.2`
defaults to the supported 4,096-token / 128-generation-token plan and reports
the artifact's disk footprint separately from resident weights, the main and
MTP expert slabs, KV, reserves, and the 25 GiB process ceiling. Its throughput
line is the measured warm quality-preserving result; the direct Colibri oracle
and the 2 tok/s aspiration are labeled separately. `--skus` explains that the
generic resident-model matrix does not apply to this streamed artifact.

```sh
mlx-bun fit GLM-5.2
mlx-bun fit GLM-5.2 --ctx 4096
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

### `fuse` — merge an adapter into the base

Folds LoRA deltas into the base weights and writes a standalone snapshot; a
quantized base keeps its exact quantization layout. Flag names match
`mlx_lm.fuse`.

```sh
mlx-bun fuse e4b --adapter ./adapters --save-path ./fused_model
mlx-bun serve ./fused_model
```

### `convert` — quantize a model

Quantize an HF model (local path, downloaded model, or repo id) into a local
MLX snapshot — uniform 4/8-bit, or mixed-precision via `--target-bpw`
(sensitivity sweep + per-layer bit knapsack). `--upload-repo` pushes the result.

```sh
mlx-bun convert Qwen/Qwen3-4B -q                      # uniform 4-bit
mlx-bun convert Qwen/Qwen3-4B --target-bpw 4.5        # mixed precision
```

### `upload` — push to the Hugging Face Hub

Native push-to-hub, no Python: creates the repo if needed, uploads via the
git-LFS batch protocol, commits. Flag names match `mlx_lm.upload`.

```sh
mlx-bun upload --path ./fused_model --upload-repo you/my-model
```

### `perplexity` — evaluate on your data

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

`setup` is an alias for `memory`.

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
