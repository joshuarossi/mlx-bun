# CLI reference

Every mlx-bun verb, from `src/cli.ts`. Commands are shown as
`mlx-bun <verb>`; from a clone the identical command is
`bun src/cli.ts <verb>`. `mlx-bun help <verb>` (or `mlx-bun <verb> --help`)
prints the full flag list for any command; `mlx-bun --version` (also `-v` or
`mlx-bun version`) prints the version.

**Model arguments are substring queries** against the registry (`e4b`,
`12B`, `qwen`, a repo substring); a query that matches more than one model
errors and lists the candidates. A directory containing `config.json` is
loaded directly wherever a model is accepted (`serve`, `pi`, `benchmark`,
`embed`, `fuse`, `convert`, `perplexity`).

**Bare `mlx-bun`** (no verb, or only options such as `mlx-bun --port 9000`)
runs `serve`. Explicit verbs and `--help`/`--version` still win.

**Unknown flags are ignored**, not rejected — `mlx-bun serve --kv-bits 4`
starts a server as if the flag were absent. The exceptions are `fuse` and
`convert`, which refuse the mlx-lm flags they don't implement (listed under
each verb).

## Verb index

| Verb | Does | mlx-lm counterpart |
|---|---|---|
| `serve` | OpenAI/Anthropic-compatible server + web app | `mlx_lm.server` |
| `pi` | built-in coding agent on a local model | — (`mlx_lm.chat` is the nearest) |
| `harness pi` | connect your own pi install to the local server | — |
| `generate` (`gen`) | one-shot generation, no server | `mlx_lm.generate` |
| `embed` | text embeddings, no server | — |
| `get` | download a model (resumable, verified) | `mlx_lm.manage` (partial) |
| `scan` | re-index the Hugging Face cache | `mlx_lm.manage --scan` |
| `ls` | list downloaded models | `mlx_lm.manage --scan` |
| `gc` | reclaim superseded snapshots + dead blobs | `mlx_lm.manage --delete` (different unit) |
| `fit` | will it fit? memory + speed assessment | — (`optiq latency`) |
| `train` | LoRA fine-tune (SFT / DPO / ORPO) | `mlx_lm.lora --train` |
| `train-watch` | live dashboard for a training run | — |
| `fuse` | merge an adapter into the base weights | `mlx_lm.fuse` |
| `convert` | quantize an HF model into a local MLX snapshot | `mlx_lm.convert` (+ `mlx_lm.dynamic_quant`, `optiq convert`) |
| `upload` | push a model directory to the Hub | `mlx_lm.upload` |
| `perplexity` | perplexity over a local dataset | `mlx_lm.perplexity` |
| `memory` (`setup`) | the assistant's personal wiki | — |
| `benchmark` (`bench`) | decode/prefill speed of our stack | `mlx_lm.benchmark` |
| `evals` | recorded benchmark runs | — |
| `help` | overview or per-verb help | — |

## Serving & agents

### `serve` — run the server

Start the OpenAI/Anthropic-compatible server plus the browser web app.

```sh
mlx-bun serve                       # default model
mlx-bun serve e4b                   # pick a model by substring
mlx-bun serve --model ./fused_model # explicit path (mlx_lm.server spelling)
mlx-bun serve e4b --no-open         # don't open the chat UI
mlx-bun serve GLM-5.2 --context-length 4096
```

`serve` takes the model as a positional, `--query <q>`, or `--model <path|query>`
(`--model` wins). The flag set below is **shared with `mlx-bun pi`**. Defaults,
semantics, and which combinations compose live in
**[server-config.md](server-config.md)** — this page only names them.

| Group | Flags |
|---|---|
| Network | `--host`, `--port`, `--no-open`, `--allow-private-media` |
| Memory & caches | `--memory-budget`, `--kv-budget`, `--prompt-cache`, `--ssd-cache`, `--ssd-cache-max`, `--ssd-cache-verify`, `--ssd-demote-idle`, `--generation-checkpoint` |
| Process model | `--isolate`, `--model-pool`, `--unix` (internal — the engine half of `--isolate`) |
| Scheduling | `--batch` (`--decode-concurrency` accepted as the mlx_lm.server alias) |
| KV cache | `--kv-quant`, `--paged-kv`, `--paged-kv-block-size` |
| Adapters | `--adapter` (`--adapter-path` alias) |
| Speculative decoding | `--draft-model`, `--draft-kind`, `--num-draft-tokens`, `--ngram-max`, `--ngram-min` |
| GLM-5.2 | `--mtp`, `--context-length` |
| Sampling defaults | `--temperature` (`--temp` alias), `--top-p`, `--top-k`, `--max-tokens`, `--thinking`, `--hlg-sampling`, `--hlg-width`, `--hlg-shoulder`, `--hlg-toe`, `--hlg-pivot-offset` |
| Parity tier | `--l1`, `--l2` (`--l3` errors — removed) |
| Kill switches | `--compiled-decode`, `--compiled-activations`, `--fused-sdpa`, `--force-wire`, `--expert-offload` |

Endpoints: `/v1/chat/completions`, `/v1/completions`, `/v1/messages`,
`/v1/responses`, `/v1/embeddings`, `/v1/models`, `/v1/adapters`, `/health`,
`/stats`, `/fit`, `/library`, `/downloads`; the web app at `/` (`/chat`,
`/status`, `/quantize`, `/finetune`, `/dataset` deep-link its views). Schemas
in [server-api.md](server-api.md).

### `pi` — built-in coding agent

Run the pi coding agent's terminal UI in-process against a local model —
pi is bundled, nothing to install. Reuses a healthy server on the chosen
port; otherwise starts one that lives exactly as long as the session.

```sh
mlx-bun pi                               # interactive session
mlx-bun pi fix the failing test          # pre-fill the first turn
mlx-bun pi -p "explain this repo"        # one-shot: print the reply and exit
mlx-bun pi -p --json "summarize README"  # one-shot with the full event stream
mlx-bun pi --mode rpc                    # JSONL RPC over stdio
mlx-bun pi -q qwen --port 8090           # model + server flags for the session server
git diff | mlx-bun pi -p "review this"   # piped stdin makes it one-shot too
```

| Flag | Meaning |
|---|---|
| `-q`, `--query <q>` | model to serve when starting a session server |
| `-p`, `--print [msg]` | one-shot print mode (also reads piped stdin) |
| `--json` | with `-p`: emit the full event stream as JSON |
| `--mode json\|rpc\|text` | `json` = print + JSON, `rpc` = JSONL RPC over stdio, `text` = print |
| `--verbose` | verbose agent logging |
| every `serve` flag | applies to the session server; ignored (with a note) when reusing a running one |

Other pi flags are dropped with a note — the full pi surface (`--continue`,
`--resume`, extensions, themes) lives in your own pi via `harness pi`.
`mlx-bun help pi` is our help; `mlx-bun pi --help` prints it only when it is
the sole argument.

### `harness pi` — connect your own pi

For people who already run [pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent):
writes one reversible extension, `~/.pi/agent/extensions/mlx-bun-provider.ts`,
that registers `mlx-bun` as a pi provider. Models are discovered live from
`/v1/models` at pi startup (the list baked at install time is the fallback
when the server is down), exposed under the stable id `mlx-bun/local`. It
never touches your existing pi config.

```sh
mlx-bun harness pi                                  # install; requires pi on PATH
mlx-bun harness pi --base-url http://127.0.0.1:8090/v1
mlx-bun harness pi --remove                         # delete the extension
pi --provider mlx-bun                               # then run pi as usual
pi --models "mlx-bun/*"                             # or scope cycling
```

#### LoRA adapters from pi: the adapter extension

`scripts/packaging/pi-extensions/mlx-bun-adapter.ts` ships with the repo and
adds an `/adapter` command to pi. Install by copying (or symlinking) it into
`~/.pi/agent/extensions/`, then `/reload` inside pi:

```sh
cp scripts/packaging/pi-extensions/mlx-bun-adapter.ts ~/.pi/agent/extensions/
MLX_BUN_URL=http://127.0.0.1:8080 pi --provider mlx-bun
```

| In pi | Effect |
|---|---|
| `/adapter` or `/adapter list` | list adapters on disk (`/v1/adapters/available`), which are loaded, and the active one |
| `/adapter <id>` | mount it if needed (`POST /v1/adapters`) and inject `adapter: <id>` into every request |
| `/adapter off` | back to the base model (no field sent) |

The extension reads the server URL from `MLX_BUN_URL` (its built-in fallback
is port 8090, so set it to match your server). Default is no adapter; the
mechanism is pi's `before_provider_request` hook, the same one the web chat's
adapter selector uses. Serving-side detail: [server-api.md](server-api.md#adapters-lora-hot-swap)
and [docs/design/web-chat-redesign.md](../design/web-chat-redesign.md).

### `generate` (alias `gen`) — one-shot generation

Load the model, generate, print, exit. The prompt is rendered through the
chat template unless `--raw`.

```sh
mlx-bun generate e4b "a haiku about metal shaders"
mlx-bun gen e4b --prompt "…" --max-tokens 512 --seed 42
mlx-bun generate qwen --raw --prompt "def fib(n):" --temperature 0
```

| Flag | Meaning |
|---|---|
| `[query]` / `--query <q>` | model (auto-picks when omitted) |
| `--prompt "…"` | the prompt (or pass it as the positional after the model) |
| `--raw` | skip the chat template |
| `--max-tokens <n>` | completion cap |
| `--temperature <n>` (`--temp` alias), `--top-p`, `--top-k`, `--seed` | sampling |
| `--l1` / `--l2`, `--kv-quant`, `--fused-sdpa`, `--compiled-decode`, `--compiled-activations` | decode route, same meaning as for `serve` |

### `embed` — text embeddings

Embeddings from a local Qwen3-Embedding model, no server. One JSON vector
per input line.

```sh
mlx-bun embed --text "hello world"
mlx-bun embed Qwen3-Embedding "hello world"
printf 'line one\nline two\n' | mlx-bun embed --json
mlx-bun embed --instruct "Retrieve passages that answer the question" --text "what is a KV cache?"
```

| Flag | Meaning |
|---|---|
| `[query]` / `--query <q>` | embedding model; omitted = the first downloaded embedding model (errors with a `get` suggestion when none) |
| `--text "…"` | text to embed (omit to read one text per stdin line) |
| `--instruct "…"` | Qwen3-Embedding query instruction; omit for plain document embeddings |
| `--json` | one OpenAI-style `{object:"list",data:[…]}` object instead of bare arrays |

Server equivalent: `mlx-bun serve <embedding-model>` then
[`POST /v1/embeddings`](server-api.md#post-v1embeddings-openai-embeddings-api).

## Models & disk

Full guide: [models.md](models.md).

### `get` — download a model

Resumable (Range requests against partial blobs), sha256-verified download
into the standard Hugging Face cache over plain HTTPS (no Xet). Complete
blobs and partial prefixes are credited before transfer, and the volume must
fit the remainder plus a 1 GiB reserve. Uses `HF_TOKEN` / `hf auth login`
credentials when present.

```sh
mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit
mlx-bun get 12B                          # no "/" = registry query; re-gets/refreshes the match
mlx-bun get mlx-community/MiniCPM5-1B-OptiQ-4bit --revision main
```

`--revision <rev>` selects a git revision. When upstream has pushed a new
revision the previous snapshot stays on disk — `get` says so and `gc`
reclaims it. GLM-5.2 specifics: [models.md](models.md#glm-52-on-a-32-gb-mac).

### `scan` — index your cache

Re-index the HF cache into the registry (config + safetensors headers, never
tensor bytes) so `ls`, `serve`, and `fit` resolve models by substring.

```sh
mlx-bun scan
```

### `ls` — list models

One row per repo (canonical revision, `refs/main`); superseded snapshots are
hidden.

```sh
mlx-bun ls                          # size, params, quant, license, capabilities
mlx-bun ls gemma                    # filter by substring
mlx-bun ls --vision --max-size 10GB # vision-capable, under 10 GB
mlx-bun ls --all-revisions          # one row per cached snapshot (canonical marked *)
```

### `gc` — reclaim disk

Delete superseded snapshots and the blobs only they reference. Prints the
plan by default.

```sh
mlx-bun gc              # dry run: what would be reclaimed
mlx-bun gc --yes        # delete
mlx-bun gc --yes --force  # also prune snapshots holding files the canonical revision lacks
```

`--dry-run` never deletes even with `--yes`. The same planner backs
[`GET /api/gc/plan` / `POST /api/gc/execute`](server-api.md#get-apigcplan--post-apigcexecute).

### `fit` — memory contract

Deterministic memory assessment: does it fit, max safe context, predicted
tok/s — from safetensors headers, the config's KV bytes/token, a calibrated
prefill transient, and the wired-memory ceiling.

```sh
mlx-bun fit gemma --ctx 32768          # this machine
mlx-bun fit gemma --ctx 8192 --skus    # across the Apple Silicon lineup
mlx-bun fit qwen --kv-quant 4          # bill a 4-bit-quantized KV cache
mlx-bun fit GLM-5.2                    # streamed-artifact plan (resident weights, expert slabs, KV, reserves)
```

| Flag | Meaning |
|---|---|
| `--ctx <tokens>` | context size to assess |
| `--kv-quant 4\|8\|config\|off` | bill the KV cache at the quantized bytes/element (`config` needs a model that ships `kv_config.json`; `turbo` is not accepted here) |
| `--skus` | also print the Apple silicon SKU matrix (not applicable to the streamed GLM-5.2 artifact) |

## Training & model creation

Full reference: [training.md](training.md); guided walkthrough:
[docs/reference/training.md](./training.md).

### `train` — LoRA fine-tune

SFT / DPO / ORPO on `<dir>/train.jsonl` (+ optional `valid.jsonl`). Rows are
`{prompt, chosen, rejected}` for dpo/orpo or `{messages|text}` for sft. Runs
in the foreground and saves a mountable adapter.

```sh
mlx-bun train e4b --data ./prefs                     # ORPO (default)
mlx-bun train e4b --data ./prefs --method sft
mlx-bun train e4b --data ./prefs --dry-run           # inspect data + resolved plan, don't train
mlx-bun train cpm5 --data ./prefs --iters 400 --save-every 50 --adapter ~/adapters/cpm5-orpo
nohup mlx-bun train e4b --data ./prefs &             # long runs: detach from your shell
```

| Flag | Meaning |
|---|---|
| `<model>` / `--query <q>` | model to fine-tune (auto-picks when omitted) |
| `--data <dir>` | dataset dir (required) |
| `--method sft\|dpo\|orpo` | objective |
| `--adapter <dir>` | output adapter dir (default under `~/.cache/mlx-bun/mlx-bun-finetunes/`) |
| `--iters`, `--lr`, `--rank`, `--scale`, `--seq`, `--batch`, `--grad-accum`, `--grad-clip`, `--seed`, `--val-size` | loop hyperparameters (method-dependent defaults: `mlx-bun help train`) |
| `--lambda <f>`, `--sft-scope full\|response` | ORPO odds-ratio weight and chosen-NLL scope |
| `--seg <n>`, `--no-segment` | segmented backward (layers per segment / off) |
| `--no-flash`, `--no-prefix` | disable the flash-CCE head / prefix-sharing |
| `--save-every <n>`, `--resume <dir>` | checkpoint cadence / warm-start LoRA weights |
| `--dry-run` | print the plan, don't train |

### `train-watch` — live training dashboard

Tails `<adapter-dir>/metrics.jsonl` (written by `train` and the web
fine-tune tile) and renders live loss / speed / memory.

```sh
mlx-bun train-watch ~/.cache/mlx-bun/mlx-bun-finetunes/orpo-e4b
mlx-bun train-watch --adapter ~/adapters/cpm5-orpo
```

### `fuse` — merge an adapter into the base

Folds LoRA deltas into the base weights and writes a standalone snapshot
(weights + config + tokenizer); a quantized base keeps its per-module
quantization layout. Flag names follow `mlx_lm.fuse`.

```sh
mlx-bun fuse e4b --adapter ./adapters --save-path ./fused_model
mlx-bun fuse --model ./base-snapshot --adapter-path ./adapters
mlx-bun serve ./fused_model
```

| Flag | Meaning |
|---|---|
| `<model>` / `--model` | base model (query or snapshot path) |
| `--adapter <dir>` (`--adapter-path` alias) | adapter directory (`adapters.safetensors` + `adapter_config.json`); default `adapters` |
| `--save-path <dir>` | output directory; default `fused_model` |

Refused with an error (mlx_lm.fuse flags not implemented): `--de-quantize`,
`--dequantize`, `--export-gguf`, `--gguf-path`, `--upload-repo`.

### `convert` — quantize a model

Quantize an HF model (local path, downloaded model, or repo id — an
un-downloaded repo is fetched first) into a local MLX snapshot: uniform
affine 4/8-bit, or mixed precision via `--target-bpw` (sensitivity sweep +
per-layer bit knapsack). Same engine as the web `/api/quantize`.

```sh
mlx-bun convert Qwen/Qwen3-4B -q                              # uniform 4-bit → ./mlx_model
mlx-bun convert --hf-path Qwen/Qwen3-4B -q --q-bits 8 --mlx-path ./qwen3-8bit
mlx-bun convert Qwen/Qwen3-4B --target-bpw 4.5                # mixed precision (implies -q)
mlx-bun convert ./qwen3.5-bf16 -q --rotate-weights            # fold the TurboQuant rotation, then quantize
mlx-bun convert Qwen/Qwen3-4B -q --upload-repo you/qwen3-4b-4bit
```

| Flag | Meaning |
|---|---|
| `--hf-path <src>` (`--model` or the bare positional) | source model |
| `--mlx-path <dir>` | output directory; must not already exist (mlx_lm.convert behavior) |
| `-q`, `--quantize`, `--q-bits 4\|8`, `--q-group-size 32\|64` | uniform affine quantization |
| `--target-bpw <f>`, `--candidate-bits <list>`, `--calibration-mix optiq\|<jsonl>`, `--n-calibration <n>` | mixed precision (writes per-module bits into `config.json`) |
| `--rotate-weights`, `--rotation-seed <n>` | fold the offline TurboQuant rotation first (auto-detects Llama / Qwen3.5 trunk / Qwen MTP; an MTP companion must use its trunk's seed); recipe recorded in `optiq_metadata.json` |
| `--upload-repo <id>` | push the result afterwards (token checked before any work starts) |

Refused with an error: `--dtype`, `-d`/`--dequantize`, `--quant-predicate`,
`--q-mode` other than `affine`, and plain non-quantizing conversion (pass `-q`
or `--target-bpw`).

### `upload` — push to the Hugging Face Hub

Native push-to-hub, no Python: creates the repo if needed, uploads via the
git-LFS batch protocol, commits. Flag names match `mlx_lm.upload`.

```sh
mlx-bun upload --path ./fused_model --upload-repo you/my-model
mlx-bun upload --path ./mlx_model --upload-repo you/my-model --private
```

Needs a WRITE token from `~/.mlx-bun/hf.json` (web UI Settings), `$HF_TOKEN`,
or `~/.cache/huggingface/token` (`hf auth login`); errors before uploading
anything when none is found. `--private` is an mlx-bun extension.

### `perplexity` — evaluate on your data

`mlx_lm.perplexity` methodology exactly (seeded sample order, concatenate,
non-overlapping rows, f32 CE at every position, delta-method standard
error) over a **local** `.jsonl` (`{"text": …}` rows) or `.txt` file — never
an HF dataset download.

```sh
mlx-bun perplexity e4b --data-path ./corpus.jsonl
mlx-bun perplexity ./fused_model --data-path ./corpus.txt --sequence-length 1024 --num-samples -1 --batch-size 4 --seed 7
```

Flags: `<model>` (`--model` / `--query` accepted), `--data-path <file>`
(required), `--sequence-length <n>`, `--num-samples <n>` (`-1` = all),
`--batch-size <n>`, `--seed <n>`.

## Memory

### `memory` (alias `setup`) — the personal wiki

A local, git-tracked Markdown wiki at `~/.mlx-bun/wiki` that loads into
every `mlx-bun pi` / `mlx-bun serve` session. Full guide:
[memory.md](memory.md). `mlx-bun memory` with no subcommand runs `status`.

```sh
mlx-bun memory init                       # create the wiki (idempotent); offers import + nightly job
mlx-bun memory status                     # path, article count, git + schedule state
mlx-bun memory open                       # open the vault in Obsidian (falls back to Finder)
mlx-bun memory open Archie_Project        # open one article
mlx-bun memory list                       # article titles + read-only Reference docs
mlx-bun memory search kv cache            # search from the terminal
mlx-bun memory read Archie_Project        # print an article (stem)
mlx-bun memory toc Archie_Project         # headings + anchors
mlx-bun memory section Archie_Project decisions   # one section by anchor
mlx-bun memory links Archie_Project       # outbound + inbound wikilinks
mlx-bun memory synthesize                 # conversations → articles, the full local DAG
mlx-bun memory synthesize --dry-run       # plan only, never writes the vault
mlx-bun memory segment --limit 20         # one stage worker (also: extract, route, synthesize-stage)
mlx-bun memory extract --convs a1b2,c3d4  # restrict a stage to specific conversations
mlx-bun memory link --limit 50            # deterministic cross-linking pass (no model)
mlx-bun memory schedule --at 03:00        # install the nightly launchd job
mlx-bun memory unschedule                 # remove it
```

| Subcommand | Aliases | Meaning |
|---|---|---|
| `init` | `setup` | create the wiki; offers to import an existing vault and install the nightly job (TTY prompts; non-interactive shells take the defaults) |
| `status` | | path, counts, git + schedule state |
| `open [article]` | `browse` | open the vault or one article |
| `list` | | article titles + `Reference/` docs |
| `search <query>` | | ranked article hits with sample lines |
| `read <article>` | | print an article |
| `toc <article>` | | headings + anchors |
| `section <article> <anchor>` | | print one section |
| `links <article>` | | resolved outbound + inbound wikilinks |
| `synthesize` | `pipeline`, `all` | run the full synthesis DAG; `--dry-run` plans without writing. `--since` and `--model` are parsed but the pipeline does not consume them yet (`src/memory/pipeline.ts` marks `model` reserved) |
| `segment` · `extract` · `route` · `synthesize-stage` | `stage-synthesize` | run one decomposed, resumable stage worker (`--limit <n>` except `route`; `--convs a,b`) |
| `link` | | inline-link first mentions + rebuild `## See also` (`--limit <n>`; no model) |
| `schedule` | | install the nightly launchd job (`--at HH:MM`) |
| `unschedule` | | remove it |

An unknown subcommand prints the help and exits non-zero, so launchd jobs
and scripts can detect typos.

## Measurement

### `benchmark` (alias `bench`) — measure our stack

Runs mlx-bun by itself (greedy decode, in-process) and records the median
to the eval DB.

```sh
mlx-bun bench e4b --tokens 256 --runs 3
mlx-bun bench --model ./fused_model --prompt-tokens 4096 --kv-quant turbo:k8v3
```

| Flag | Meaning |
|---|---|
| `[query]` / `--query` / `--model <path\|query>` | model (auto-picks when omitted) |
| `--tokens <n>` | tokens decoded per run |
| `--runs <n>` | runs (median reported) |
| `--prompt-tokens <n>` | pad the prompt to about n tokens (long-context decode) |
| `--kv-quant config\|off\|4\|8\|turbo[:k<bits>v<bits>]` | KV scheme for the run |
| `--compiled-decode`, `--compiled-activations`, `--fused-sdpa` | kill switches; A/B by running twice |

For **quotable, cross-stack** numbers use the preflight-gated harness from
the repo — it spawns the real CLI at its real defaults next to the mlx-lm
and optiq reference servers and writes a dated report:

```sh
bun scripts/bench-serve.ts all
bun scripts/bench-serve.ts all --models cpm5,e4b --arms mlx-bun,mlx-lm --out report.md
```

Curated results: [benchmarks.md](benchmarks.md).

### `evals` — recorded runs

```sh
mlx-bun evals                # table: when, stack, model, bench, KV, prefill, decode, TTFT, peak, commit
mlx-bun evals --limit 50
mlx-bun evals --raw          # JSON lines for scripts/jq
mlx-bun evals --clear        # archive the DB to a timestamped backup and start fresh
```

## mlx-lm compatibility

mlx-bun borrows mlx-lm's verb and flag vocabulary so scripts drop in with a
rename of the executable: `mlx_lm.<verb> …` becomes `mlx-bun <verb> …`.
There is no `mlx-bun.<verb>` dotted alias (the package installs one binary,
`mlx-bun`). Surface parity is not architecture parity: a verb run against an
unsupported architecture errors clearly rather than guessing.

### What maps to what

| mlx-lm | mlx-bun | Accepted mlx-lm spellings | Not accepted |
|---|---|---|---|
| `mlx_lm.server` | `serve` | `--model`, `--host`, `--port`, `--adapter-path`, `--temp`, `--top-p`, `--top-k`, `--max-tokens`, `--draft-model`, `--num-draft-tokens`, `--decode-concurrency` (semantics differ — [server-config.md](server-config.md)) | `--prompt-cache-size`/`--prompt-cache-bytes` (use `--prompt-cache`), `--min-p`, `--chat-template`, `--chat-template-args`, `--use-default-chat-template`, `--trust-remote-code`, `--log-level`, `--allowed-origins`, `--pipeline`, `--prefill-step-size`, `--prompt-concurrency` — silently ignored |
| `mlx_lm.generate` | `generate` | `--prompt`, `--max-tokens`, `--temp`, `--top-p`, `--top-k`, `--seed` | `--kv-bits`/`--kv-group-size`/`--quantized-kv-start` (use `--kv-quant`), `--min-p`, `--xtc-*`, `--prompt-cache-file`, `--max-kv-size`, `--adapter-path`, `--draft-model`, `--system-prompt`, `--ignore-chat-template` (use `--raw`), `--verbose` — silently ignored |
| `mlx_lm.chat` | `pi` / the web chat | — | no terminal REPL verb; `pi` is the agent, `serve` opens the chat UI |
| `mlx_lm.convert` | `convert` | `--hf-path`, `--mlx-path`, `-q`/`--quantize`, `--q-bits`, `--q-group-size`, `--q-mode affine`, `--upload-repo` | `--dtype`, `-d`/`--dequantize`, `--quant-predicate`, non-affine `--q-mode`, plain non-quantizing conversion — **refused** |
| `mlx_lm.fuse` | `fuse` | `--model`, `--adapter-path`, `--save-path` | `--de-quantize`, `--export-gguf`, `--gguf-path`, `--upload-repo` — **refused** |
| `mlx_lm.lora --train` | `train` | `--data`, `--iters`, `--seed` (same names); otherwise own names (`--method`, `--adapter`, `--lr`, `--rank`, `--seq`, `--batch`, `--grad-accum`, `--save-every`, `--resume`) | `--train`/`--test`, `--config` (YAML), `--fine-tune-type`, `--adapter-path`, `--learning-rate`, `--max-seq-length`, `--batch-size`, `--num-layers`, `--mask-prompt`, `--optimizer` — silently ignored |
| `mlx_lm.upload` | `upload` | `--path`, `--upload-repo` (+ `--private`) | — |
| `mlx_lm.perplexity` | `perplexity` | `--model`, `--sequence-length`, `--num-samples`, `--batch-size`, `--seed`; `--data-path` is a local file | HF dataset ids |
| `mlx_lm.benchmark` | `benchmark` | `--model` | `-p`/`--prompt-tokens` short form, `-g`/`--generation-tokens`, `-b`/`--batch-size`, `-n`/`--num-trials` (ours: `--prompt-tokens`, `--tokens`, `--runs`; one stream) |
| `mlx_lm.manage` | `get` / `scan` / `ls` / `gc` | — | `--scan`/`--delete`/`--pattern` flag forms; `gc` deletes superseded snapshots, not whole repos |
| `mlx_lm.dynamic_quant` | `convert --target-bpw` | — | the `dynamic_quant` verb name |

mlx-optiq's CLI (`optiq convert` / `serve` / `lora` / `benchmark` / `eval` /
`latency` / `kv-cache` / `lab`) maps onto the same verbs where the concept
exists: `optiq convert` → `convert --target-bpw`; `optiq serve --kv-config`
→ `serve --kv-quant config` (the `--l2` preset); `optiq latency` → `fit`;
`optiq lab` → the web app served by `serve`. `optiq eval` and `optiq
kv-cache` have no verb (below).

### mlx-lm entry points: covered / not covered

Against the console scripts the pinned oracle ships
(`mlx_lm-*.dist-info/entry_points.txt` in the oracle venv). The scoping
behind each "not covered" row is in
[docs/reference/cli.md](./cli.md).

| Entry point | Status | Where |
|---|---|---|
| `mlx_lm.server` | covered | `serve` (incl. `--draft-model` speculative decoding) |
| `mlx_lm.generate` | covered | `generate` |
| `mlx_lm.chat` | covered differently | `pi` (agent TUI) + web chat; no plain REPL |
| `mlx_lm.convert` | covered | `convert` (quantizing paths only) |
| `mlx_lm.dynamic_quant` | covered | `convert --target-bpw` (sensitivity scan + per-layer bits) |
| `mlx_lm.lora` | covered (train) | `train`; the `--test` evaluation mode is not covered |
| `mlx_lm.fuse` | covered | `fuse` (no dequantize / GGUF / upload) |
| `mlx_lm.upload` | covered | `upload` |
| `mlx_lm.perplexity` | covered | `perplexity` (local files only) |
| `mlx_lm.benchmark` | covered | `benchmark` (own flag names; `evals` views the DB) |
| `mlx_lm.manage` | covered | `get` / `scan` / `ls` / `gc` |
| `mlx_lm.cache_prompt` | not covered | no on-disk prompt-cache files; the server's prompt cache (+ `--ssd-cache`) is the equivalent for served traffic |
| `mlx_lm.evaluate` | not covered | no lm-evaluation-harness backend; `benchmark`/`evals`/`perplexity` are the native measurement, and the `/v1` API accepts external harnesses |
| `mlx_lm.awq` | not covered | activation-aware weight quantization |
| `mlx_lm.dwq` | not covered | distilled weight quantization |
| `mlx_lm.gptq` | not covered | Hessian-conditioned rounding |
| `mlx_lm.share` | not covered | distributed cache share |
| `mlx_lm` (umbrella `mlx_lm <verb>`) | covered | `mlx-bun <verb>` is the same shape |

Native verbs with no mlx-lm counterpart — `pi`, `harness pi`, `embed`,
`fit`, `train-watch`, `memory`, `evals` — are the surface that makes mlx-bun
more than a drop-in.
