#!/usr/bin/env bun
// mlx-bun CLI: the appliance interface.
//
//   mlx-bun get <org/repo> [--revision main]   resumable verified download
//   mlx-bun scan                          index the HF cache
//   mlx-bun ls [--vision] [--max-size 10GB] [query]
//   mlx-bun fit <query> [--ctx 8192] [--skus]
//   mlx-bun serve [query] [--port 8080] [--memory-budget GB]
//   mlx-bun evals                         recent benchmark runs
//   mlx-bun harness pi [--base-url <url>] [--remove]   connect your own pi to the local server

import { Registry } from "./registry";
import { loadModelConfig } from "./config";
import { fit, skuMatrix, thisMachine } from "./fit";
import { EvalDB } from "./evaldb";
import pkg from "../package.json" with { type: "json" };
import { renderHelp } from "./tui";
import { isSupportedModelRecord } from "./model/support";
import { perfKernelEnabled } from "./model/fused-decode-kernel";
import type { JobEvent } from "./jobs/types";

const argv = process.argv.slice(2);
// The appliance path: naked `mlx-bun` (or only options, e.g.
// `mlx-bun --port 9000`) runs `serve` — first run downloads a model and
// opens the chat UI. `--help`/`--version` and explicit subcommands still win.
const HELP_VERSION_FLAGS = ["--help", "-h", "--version", "-v"];
const noSubcommand =
  !argv[0] || (argv[0].startsWith("-") && !HELP_VERSION_FLAGS.includes(argv[0]));
const cmd = noSubcommand ? "serve" : argv[0];

const OVERVIEW = `mlx-bun ${pkg.version} — local AI on Apple silicon. One binary, no Python.

Usage: mlx-bun [command] [options]   (no command = serve)

Commands:
  pi         Launch a pi coding-agent session on a local model (the appliance path)
  serve      Start the OpenAI/Anthropic-compatible server + status page
  get        Download a model from Hugging Face (resumable, verified)
  ls         List downloaded models
  gc         Reclaim superseded model snapshots + dead blobs from the HF cache
  fit        Will a model fit this machine? Memory + speed assessment
  scan       Re-index the Hugging Face cache
  harness    Connect your own pi install to the local mlx-bun server
  train      Fine-tune a LoRA adapter (SFT / DPO / ORPO) on your data
  train-watch Live dashboard for a training run (tails metrics.jsonl)
  fuse       Merge a LoRA adapter into the base weights (standalone model)
  convert    Quantize an HF model into a local MLX snapshot
  upload     Push a local model directory to the Hugging Face Hub
  perplexity Perplexity of a model over a local text/JSONL dataset
  memory     Set up + manage your local AI's personal wiki memory
  generate   One-shot raw text generation from a local model (no server)
  benchmark  Measure decode/prefill speed of OUR stack on this machine
  embed      Text embeddings from a local embedding model (Qwen3-Embedding)
  evals      Show recent benchmark runs (all stacks)
  help       Show help for a command (also: mlx-bun <command> --help)

Options:
  -h, --help     Show help
  -v, --version  Show version

Examples:
  mlx-bun                          # download (first run) + serve + open the chat UI
  mlx-bun pi                       # start (download if needed) and chat with an agent
  mlx-bun serve 12B                # serve the 12B; status page at http://localhost:8080/
  mlx-bun train e4b --data ./prefs # ORPO LoRA fine-tune on {prompt,chosen,rejected} data
  mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit`;

const SERVER_FLAGS = `Server options:
  --host <addr>             Interface to bind  [default: 127.0.0.1, loopback
                            only; use 0.0.0.0 to expose on your network]
  --port <n>                Listen port  [default: 8080]
  --memory-budget <GB>      Admission-control memory budget; requests that
                            cannot fit are rejected instead of crashing the
                            GPU  [default: machine RAM × 0.75, check-only]
  --prompt-cache <GB>       Prompt (KV) cache byte cap  [default: 2 GB;
                            --prompt-cache 0 disables the cache]
  --batch <n>               Max concurrent requests batched through the
                            mlx-lm-parity engine  [default: 1 = serial].
                            >1 opts the whole server into bf16 continuous
                            batching (= mlx-lm B=N); see --kv-quant.
                            --decode-concurrency is accepted as the
                            mlx_lm.server alias (semantics differ; see
                            docs/reference/server-config.md)
  --no-open                 Don't open the chat UI in your browser on start.
                            By default an interactive terminal opens
                            http://<host>:<port>/#/chat once the server is up.

Model & quality:
  --adapter <dir>           Mount a LoRA adapter at startup and use it as the
                            default for requests that don't select one (a
                            request's \`adapter\` field, incl. "none", wins).
                            --adapter-path is accepted as the mlx_lm.server
                            alias. Hot-swap via POST /v1/adapters unchanged.
  --kv-quant <mode>         KV cache quantization: config (per-layer
                            kv_config.json when the model ships one), off
                            (bf16), or 4 / 8 (uniform bits)
                            [default: config; bf16 under --batch N — the
                            batched engine is bf16-only, so an explicit
                            --kv-quant routes those requests to the serial path]
  --thinking <true|false>   Default for the chat template's enable_thinking
                            variable (CPM and other hybrid-reasoning models);
                            a request's chat_template_kwargs overrides it
                            [default: the model's own, false for CPM]
  --temperature <n>         Server-wide sampling defaults; a per-request field
  --top-p <n>               still overrides them, and the browser chat (which
  --top-k <n>               sends none) inherits them. --temp is accepted as
                            an alias for --temperature (mlx_lm.server compat;
                            NOTE mlx_lm.server defaults temperature to 0.0 —
                            pass --temp 0 for its unset-request behavior)
                            [default: the model's generation_config.json]
  --max-tokens <n>          Completion cap when a request omits max_tokens
                            (mlx_lm.server flag; its default is 512 there)
                            [default: 65536 chat / 512 raw completion]
  --hlg-sampling on|off     Piecewise tone-curve sampling (HLG): rolls off the
                            top, boosts the mids, gentles the tail. Gain folds
                            from --temperature. [default: off]
                            See docs/design/hlg-sampling.md
  --hlg-width <nats>        HLG mid-region half-width  [default: 4]
  --hlg-shoulder <nats>     HLG highlight rolloff scale  [default: 4]
  --hlg-toe <nats>          HLG shadow rolloff scale  [default: 6]
  --hlg-pivot-offset <nats> HLG pivot: nats below the top token  [default: 6]

Parity tier (sets the whole decode route; a per-fork flag below overrides):
  --l1                      Bit-for-bit IDENTICAL to mlx-lm (bf16 KV, unfused)
  --l2                      Bit-for-bit IDENTICAL to mlx-optiq (quantized KV +
                            fused prefill SDPA, stock unfused decode — the
                            optiq-golden composition; perf-kernel stays OFF)
  --l3                      Best performance, no bit-exact oracle (KL + test
                            gated; adds the envelope-gated perf kernel).
                            No tier given = the per-flag defaults below,
                            which equal --l3 today.

Performance levers (A/B levers; defaults are the measured winners):
  --compiled-decode on|off  Compiled decode graphs  [default: on]
  --perf-kernel on|off      Fused quantized-KV decode-SDPA Metal kernel —
                            NOT bit-exact, envelope-gated (an L3 lever; the
                            perf side of the compat A/B)  [default: on]
  --fused-decode on|off     Fused-decode experiment lever  [default: off]
  --fused-sdpa on|off       Fused SDPA path  [default: on]
  --force-wire              Wire weights into memory at load
  --expert-offload          MoE only: serve experts from a page-aligned file
                            mmap (built on first use) — keeps the model out of
                            memory pressure (phys_footprint ≈ active params),
                            bit-exact with the resident path`;

const HELP: Record<string, string> = {
  pi: `mlx-bun pi — drop into a coding-agent session on a local model

Usage: mlx-bun pi [options] [message...]

Runs the pi coding agent's own terminal UI in-process against the local
model — nothing to install, pi is built in. Reuses a healthy local
server when one is running; otherwise serves e4b by default (override
with --query) and starts a server for the session (the server ends with
the session). Fresh install: downloads a small starter model first so
you're chatting in minutes, then streams e4b in the background — it
becomes the default on the next run.

Model selection:
  -q, --query <q>      Model to serve when starting a server (registry query)

${SERVER_FLAGS}

Run modes:
  message...           Pre-fill the first turn (interactive)
  -p, --print [msg]    One-shot: print the reply and exit (also reads piped
                       stdin); add --json for the full event stream
  --mode json|rpc      Structured print (json) or JSONL RPC over stdio

Already use pi? Connect your own pi to this local model instead:
  mlx-bun harness pi`,

  serve: `mlx-bun serve — OpenAI/Anthropic-compatible server for a local model

Usage: mlx-bun serve [query] [options]

  [query]              Registry query (e.g. "12B", "e4b", a repo substring).
                       --query <q> is accepted for the positional. Omitted:
                       serves e4b (the default), else the largest downloaded
                       model that fits. Fresh install: downloads a small
                       starter model first, then e4b in the background
                       (default on next run).

${SERVER_FLAGS}

Endpoints: /v1/chat/completions, /v1/completions, /v1/messages, /v1/responses,
/v1/models, /v1/adapters, /health, /stats, /fit, /library, /downloads —
status page at /, browser chat at /chat`,

  get: `mlx-bun get — download a model from Hugging Face

Usage: mlx-bun get <org/repo | substring> [options]

  <org/repo>           Full repo id (e.g. mlx-community/gemma-4-12B-it-OptiQ-4bit)
  <substring>          No "/" = a registry query over already-downloaded repos
                       (e.g. \`mlx-bun get 12B\` re-gets/refreshes the match)

Options:
  --revision <rev>     Git revision  [default: main]

Resumable (Range requests against partial blobs) and verified (sha256
for LFS blobs). Re-running after an interruption continues where it
stopped. Uses HF_TOKEN / hf auth login credentials when present.
When upstream pushed a new revision, the previous snapshot stays on
disk — \`mlx-bun gc\` reclaims it.`,

  ls: `mlx-bun ls — list downloaded models

Usage: mlx-bun ls [query] [options]

One row per repo (the canonical revision: refs/main). The HF cache keeps
a snapshot dir per downloaded revision — superseded ones are hidden here
and reclaimed by \`mlx-bun gc\`.

Options:
  --vision             Only vision-capable models (SigLIP sidecar or the
                       unified encoder-free tower)
  --max-size <size>    Filter by weight size (e.g. 10GB, 800MB)
  --all-revisions      One row per cached snapshot (canonical marked *)`,

  gc: `mlx-bun gc — reclaim superseded snapshots + dead blobs

Usage: mlx-bun gc [options]

Every \`get\` that follows an upstream push creates a NEW
snapshots/<commit> dir; the old one (and any blobs only it references)
stays on disk forever. gc keeps the snapshots refs/* point at, deletes
the rest, then deletes blobs no surviving snapshot links to.

Without --yes it only prints what would be deleted (per-repo reclaim).

Options:
  --yes                Actually delete (destructive; default prints only)
  --dry-run            Print the plan and never delete, even with --yes
  --force              Also prune superseded snapshots that contain files
                       the canonical revision lacks (normally skipped with
                       a warning — deleting them loses the only copy)`,

  fit: `mlx-bun fit — will this model fit on this machine?

Usage: mlx-bun fit <query> [options]

Options:
  --ctx <tokens>       Context size to assess  [default: 8192]
  --skus               Also print the Apple silicon SKU matrix

Solves weights + KV growth + prefill transient against wired memory and
predicts decode speed from memory bandwidth.`,

  scan: `mlx-bun scan — re-index the Hugging Face cache

Usage: mlx-bun scan

Reads config.json + safetensors headers (never tensor bytes) for every
snapshot in ~/.cache/huggingface/hub and refreshes the model registry.`,

  harness: `mlx-bun harness pi — connect your own pi to the local model

Usage: mlx-bun harness pi [options]

For people who already use pi: this points your existing pi install at
the local mlx-bun server so you can run pi the way you already do, on a
local model. (To just chat now with no setup, use \`mlx-bun pi\` — the
built-in agent.)

Options:
  --base-url <url>     Server base URL  [default: http://localhost:8080/v1]
  --remove             Disconnect (delete the extension)

Installs a small discovery extension into ~/.pi/agent/extensions that
registers mlx-bun as a pi provider (models discovered live from
/v1/models at pi startup). One file, reversible with --remove; never
touches your existing pi config. Then: pi --provider mlx-bun`,

  benchmark: `mlx-bun benchmark — measure OUR stack on this machine

Usage: mlx-bun benchmark [query] [options]

Runs mlx-bun by itself (no other systems required) and records the
result to the eval DB. For quotable, cross-stack numbers use
./benchmark.sh from the repo — it preflight-gates on an idle machine
and runs the mlx-lm/optiq comparison legs.

  [query]              Model to benchmark (--query <q> is accepted for the
                       positional)  [default: auto-pick]

Options:
  --tokens <n>         Tokens to decode per run  [default: 256]
  --runs <n>           Runs (median reported)  [default: 3]
  --prompt-tokens <n>  Pad the prompt to ~n tokens (long-context decode)
  --kv-quant <mode>    config | off | 4 | 8  [default: off, the
                       historical baseline]

Performance levers (--compiled-decode, --perf-kernel, --fused-decode,
--fused-sdpa) apply to the run — A/B by running twice.`,

  embed: `mlx-bun embed — text embeddings from a local embedding model

Usage: mlx-bun embed [query] --text "…" [options]
       mlx-bun embed [query] "…"        (text as a positional)
       echo -e "line one\\nline two" | mlx-bun embed [query]

Embeds text with a local Qwen3-Embedding model (last-token pooled,
L2-normalized — bit-exact vs mlx-lm). One text per --text, or one per
line on stdin. Prints one JSON array (the vector) per input line.

  [query]              Embedding model (--query <q> is accepted for the
                       positional)  [default: the first downloaded
                       embedding model; errors with an mlx-bun get
                       suggestion when none is downloaded]

Options:
  --text "…"           Text to embed (omit to read lines from stdin)
  --instruct "…"       Query instruction (Qwen3-Embedding query format);
                       steers WHICH similarity axis the geometry reflects.
                       Omit for plain document embeddings.
  --json               Emit one OpenAI-style {object:"list",data:[…]} object
                       instead of bare vector arrays

For a server endpoint use \`mlx-bun serve <embedding-model>\` then
POST /v1/embeddings.`,

  generate: `mlx-bun generate — one-shot raw text generation (no server)

Usage: mlx-bun generate [query] --prompt "…" [options]
       mlx-bun generate [query] "…"          (prompt as a positional)

A direct one-shot entry point: load the model, generate, print, exit —
no server, no chat UI. By default the prompt is rendered through the
model's chat template; --raw feeds it verbatim.

  [query]              Model (registry query; --query is accepted for the
                       positional)  [default: auto-pick]

Options:
  --prompt "…"         The prompt (or pass it as the positional)
  --raw                Skip the chat template (verbatim prompt)
  --max-tokens <n>     Completion cap  [default: 256]
  --temperature <n>    Sampling temperature (--temp is accepted as an alias)
  --top-p <n>          Nucleus sampling
  --top-k <n>          Top-k sampling
  --seed <n>           Sampler seed (reproducible runs)

Decode-path levers mirror serve: --l1/--l2/--l3 and the per-fork flags
(--perf-kernel/--fused-sdpa/--compiled-decode/--fused-decode/--kv-quant).
The tier's KV scheme applies here too (--l2/--l3 = the model's kv_config,
same tokens as serve); with no tier/--kv-quant the KV cache stays bf16
(the bit-exact mlx-lm greedy path). mlx-lm compat = --l1.

Aliases: mlx-bun gen`,

  evals: `mlx-bun evals — recent benchmark runs

Usage: mlx-bun evals [options]

Options:
  --limit <n>          Rows to show  [default: 20]
  --raw                Full records as JSON lines (for scripts/jq)
  --clear              Archive the eval DB (timestamped backup) and start fresh

Table view: when, model, bench kind, KV mode, decode tok/s, TTFT,
peak memory, commit. Runs are written by ./benchmark.sh.`,

  train: `mlx-bun train — fine-tune a LoRA adapter on your data

Usage: mlx-bun train <model> --data <dir> [options]

  <model>              Model to fine-tune (query or snapshot path; auto-picks
                       the default model if omitted)

Data: <dir> must contain train.jsonl (+ optional valid.jsonl). Rows are
  {prompt, chosen, rejected} for dpo/orpo, or {messages|text} for sft.

Options:
  --data <dir>         Dataset dir with train.jsonl  (required)
  --method <m>         sft | dpo | orpo  [default: orpo]
  --adapter <dir>      Output adapter dir
                       [default: ~/.cache/mlx-bun/mlx-bun-finetunes/<method>-<model>]
  --iters <n>          Training iterations  [default: 100]
  --lr <f>             Learning rate  [default: orpo 1e-5 · dpo 5e-5 · sft 2e-4]
  --rank <n>           LoRA rank  [default: orpo 16 · else 8]
  --scale <f>          LoRA scale  [default: orpo 2.0 · else 1.0]
  --seq <n>            Max sequence length  [default: gemma 8192 · else 4096]
  --batch <n>          Batch size  [default: 1]
  --grad-accum <n>     Gradient accumulation steps (effective batch =
                       batch × grad-accum at batch-size-1 memory)  [default: 1]
  --grad-clip <f>      Gradient-norm clip (0 = off)  [default: 1.0]
  --seed <n>           Data-shuffle / init seed  [default: 0]
  --val-size <n>       Max validation examples per eval  [default: 256]
  --lambda <f>         ORPO odds-ratio weight  [default: 0.1]
  --sft-scope <s>      ORPO chosen-NLL scope: full (paper/TRL-faithful,
                       prompt+response) | response (pre-2026-07 runs,
                       bit-exact)  [default: full]
  --seg <n>            Layers per segment (segmented backward; orpo default 2)
  --save-every <n>     Crash-safe mountable checkpoint every n steps
  --resume <dir>       Warm-start LoRA weights from a checkpoint/adapter dir
  --no-flash           Disable the flash-CCE Metal head (use the MLX fused head)
  --no-prefix          Disable prefix-sharing (two-forward branches)
  --no-segment         Disable the segmented backward (hold all activations)
  --dry-run            Inspect the dataset + print the resolved plan, don't train

ORPO defaults run the full stack: the [M,vocab]-free flash-CCE head +
prefix-sharing + segmented backward (each falls back + logs if a row's
preconditions aren't met). Gemma/e4b sets its required training env flags
automatically. Adapters are mountable directly (mlx-bun serve --adapter).
Run long jobs detached from your own shell:  nohup mlx-bun train … &
Watch a run live from another tab:  mlx-bun train-watch <adapter-dir>`,

  "train-watch": `mlx-bun train-watch — live dashboard for a training run

Usage: mlx-bun train-watch [adapter-dir]

Tails <adapter-dir>/metrics.jsonl (written by mlx-bun train and the web
fine-tune tile) and renders a live loss/speed/memory dashboard. Point it
at the same --adapter directory the training run uses.

  [adapter-dir]        Adapter directory to watch; --adapter <dir> is
                       accepted for the positional
                       [default: ~/.cache/mlx-bun/mlx-bun-finetunes/orpo-cpm5]`,
  fuse: `mlx-bun fuse — merge a LoRA adapter into the base weights

Usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [options]

Folds the adapter's low-rank deltas into the base weights and writes a
standalone, loadable model snapshot (weights + config + tokenizer). A
quantized base keeps its exact quantization layout: fused modules are
dequantized, updated, and re-quantized with their own per-module spec.

  <model>              Base model (registry query or a snapshot path);
                       --model is accepted as the mlx_lm.fuse spelling

Options:
  --adapter <dir>      Adapter directory (adapters.safetensors +
                       adapter_config.json). --adapter-path is accepted
                       as the mlx_lm.fuse alias  [default: adapters]
  --save-path <dir>    Output model directory  [default: fused_model]

Not supported (mlx_lm.fuse flags we don't implement — the command exits
with an error rather than guessing): --de-quantize, --export-gguf,
--gguf-path, --upload-repo.

Serve the result:  mlx-bun serve <save-path>`,

  convert: `mlx-bun convert — quantize an HF model into a local MLX snapshot

Usage: mlx-bun convert --hf-path <repo-or-path> -q [options]
       mlx-bun convert <repo-or-path> -q [options]   (positional source)

Wraps mlx-bun's native quantize pipeline (the same engine as the web
/api/quantize). The source may be a local model directory, a downloaded
model (registry query), or a Hugging Face repo id — an un-downloaded
repo is fetched first (resumable, verified; can be many GB).

Options:
  --hf-path <src>      Source model: local path, downloaded model, or HF
                       repo id (--model and the bare positional are
                       accepted as aliases)
  --mlx-path <dir>     Output directory  [default: mlx_model; must not
                       already exist, matching mlx_lm.convert]
  -q, --quantize       Quantize the model (uniform affine)
  --q-bits <n>         Bits per weight: 4 or 8  [default: 4]
  --q-group-size <n>   Quantization group size: 32 or 64  [default: 64]
  --upload-repo <id>   Push the converted model to this Hugging Face repo
                       after converting (mlx_lm.convert parity; same engine
                       as \`mlx-bun upload\`, needs a write token)

Mixed precision (the mlx-bun differentiator — OptiQ sensitivity sweep +
knapsack per-layer bit allocation; implies quantization, no -q needed):
  --target-bpw <f>     Target bits-per-weight (e.g. 4.5). Runs
                       calibration → per-layer KL sensitivity → greedy
                       knapsack; writes per-module bits into config.json
  --candidate-bits <l> Comma list the knapsack may pick from [default: 4,8]
  --calibration-mix <m> "optiq" or a JSONL path  [default: optiq]
  --n-calibration <n>  Calibration samples  [default: 2]

Not supported (mlx_lm.convert flags we don't implement — the command
exits with an error rather than guessing): --dtype, -d/--dequantize,
--q-mode other than affine, and the mlx-lm --quant-predicate recipes
(use --target-bpw instead). Plain non-quantizing conversion is also not
supported: pass -q or --target-bpw.`,

  upload: `mlx-bun upload — push a local model directory to the Hugging Face Hub

Usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [options]

Native push-to-hub, no Python (src/hf-push.ts — the same engine as the
web UI's push buttons): creates the repo if needed (idempotent), uploads
weights via the git-LFS batch protocol, and commits. Flag names match
mlx_lm.upload.

Options:
  --path <dir>         Local model directory to upload  [default: mlx_model]
  --upload-repo <id>   Hub repo id, org/name or bare name  (required)
  --private            Create the repo as private (mlx-bun extension)

Auth: needs a Hugging Face WRITE token, resolved from ~/.mlx-bun/hf.json
(web UI Settings → Hugging Face), $HF_TOKEN, or ~/.cache/huggingface/token
(hf auth login). Errors before uploading anything if none is found.

Convert + push in one step:  mlx-bun convert … --upload-repo <org/repo>`,

  perplexity: `mlx-bun perplexity — perplexity over a local text/JSONL dataset

Usage: mlx-bun perplexity <model-query-or-path> --data-path <file> [options]

mlx_lm.perplexity methodology, exactly: samples are visited in a seeded
random order, tokenized, concatenated, and cut into NON-OVERLAPPING rows
of --sequence-length tokens; per batch the model scores rows[:, :-1]
against rows[:, 1:] in f32 (every position counts); reported as
ppl = exp(mean CE) ± the delta-method standard error. The one deliberate
difference: the data source is a LOCAL file (never a Hugging Face
dataset download).

  <model>              Model (registry query or snapshot path);
                       --model (mlx_lm spelling) and --query are accepted
                       for the positional

Options:
  --data-path <file>   .jsonl ({"text": …} rows) or plain .txt  (required)
  --sequence-length <n> Tokens per row  [default: 512]
  --num-samples <n>    Rows to score (-1 = all available)  [default: 256]
  --batch-size <n>     Rows per forward  [default: 8]
  --seed <n>           Sample-shuffle seed  [default: 123]`,

  memory: `mlx-bun memory — your local AI's personal wiki

Usage: mlx-bun memory <subcommand>

A local, durable memory for the assistant: a wiki of Markdown articles
(~/.mlx-bun/wiki) it reads to remember your projects, people, and history
across sessions. It's yours — git-tracked, editable in any tool (Obsidian
opens it as a vault), and it never leaves the machine. A read-only Reference/
folder symlinks mlx-bun's own docs into memory on day one. Once set up, it
loads automatically into every \`mlx-bun pi\` and \`mlx-bun serve\` session.

Subcommands:
  init, setup        Create the wiki + walk through setup (idempotent);
                     offers to import an existing vault and install the
                     nightly synthesis job
  status             Path, article count, git + schedule state
  open, browse [article]
                     Open the wiki, or a specific article, in Obsidian
                     (falls back to Finder / the default Markdown app)
  list               List article titles + read-only Reference docs
  search <query>     Search articles from the terminal
  toc <article>      Print an article's headings + anchors
  section <article> <anchor>
                     Print one article section
  links <article>    Show resolved outbound + inbound wikilinks
  read <article>     Print an article (stem, e.g. Archie_Project)
  synthesize         Run the FULL synthesis DAG now (--since, --model,
                     --dry-run); also: pipeline, all
  segment | extract | route | synthesize-stage
                     Run ONE decomposed stage worker (--limit N —
                     segment/extract/synthesize-stage only; --convs a,b).
                     Each pulls its eligible work from the DB by state, walks
                     oldest-conversation-first, persists, and exits — resumable,
                     and runnable as separate concurrent processes on slices.
  link               Deterministic cross-linking stage: inline-link first
                     mentions + rebuild ## See also (--limit N; no model)
  schedule           Install the nightly launchd job (--at HH:MM [03:00])
  unschedule         Remove the nightly launchd job

The read path is live: the assistant reads a wiki you set up by hand or
import during \`memory init\`. Ask the assistant to "open my memory" or run
\`mlx-bun memory open\` to browse it in Obsidian/Finder, or
\`mlx-bun memory open <article>\` to jump to a specific page. Synthesis
(conversations → articles) runs the full local pipeline via
\`mlx-bun memory synthesize\` (or per-stage: segment/extract/route/
synthesize-stage/link); the nightly job runs it on a schedule.`,
};

HELP.bench = HELP.benchmark!;
HELP.gen = HELP.generate!;
HELP.setup = HELP.memory!;

function printHelp(topic?: string): never {
  if (topic && HELP[topic]) console.log(renderHelp(HELP[topic]));
  else if (topic) {
    console.error(`unknown command: ${topic}\n`);
    console.log(renderHelp(OVERVIEW));
    process.exit(1);
  } else console.log(renderHelp(OVERVIEW));
  process.exit(0);
}

if (cmd === "--help" || cmd === "-h") printHelp();
if (cmd === "--version" || cmd === "-v" || cmd === "version") {
  console.log(`mlx-bun ${pkg.version}`);
  process.exit(0);
}
if (cmd === "help") printHelp(argv[1]);
// Per-command --help/-h — except `pi`, whose extra args pass through
// (use `mlx-bun help pi` for our help, `pi --help` for pi's).
if (cmd !== "pi" && (argv.includes("--help") || argv.includes("-h"))) printHelp(cmd);
if (cmd === "pi" && (argv[1] === "--help" || argv[1] === "-h") && argv.length === 2) printHelp("pi");

const flag = (name: string): boolean => argv.includes(`--${name}`);
const opt = (name: string, dflt: string | null = null): string | null => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 && argv[i + 1] ? argv[i + 1]! : dflt;
};
/** Single-dash value flag (e.g. -q), the short-alias counterpart to opt(). */
const optShort = (short: string, dflt: string | null = null): string | null => {
  const i = argv.indexOf(`-${short}`);
  return i > -1 && argv[i + 1] ? argv[i + 1]! : dflt;
};
const positional = (n: number): string | undefined =>
  argv.filter((a, i) => !a.startsWith("--") && (i === 0 || !argv[i - 1]!.startsWith("--"))).slice(1)[n];

const gb = (bytes: number) => `${(bytes / 2 ** 30).toFixed(2)} GB`;

/** First-run: fetch the MLX native runtime pack if no copy is resolvable
 *  (env / beside the binary / cache / homebrew). ~52 MB, resumable,
 *  sha256-verified. Must run BEFORE importing anything that dlopens
 *  (./server, ./generate — they load libmlxc at module scope). */
async function ensureNative(s?: import("./tui").Step): Promise<void> {
  const { nativeRuntimeDir, ensureNativeRuntime, NATIVE_PACK_VERSION } = await import("./native-pack");
  if (nativeRuntimeDir()) return;
  s?.update(`downloading the MLX native runtime (v${NATIVE_PACK_VERSION}, ~52 MB)`);
  await ensureNativeRuntime({
    onProgress: (received, total) => {
      const pct = total ? Math.floor((received / total) * 100) : 0;
      const line = `MLX native runtime  ${gb(received)} / ${gb(total)} (${pct}%)`;
      if (s) s.update(line); else process.stdout.write(`\r  ${line}   `);
    },
  });
  if (!s) process.stdout.write("\n");
}

/** AppleScript that focuses the first tab whose URL contains `match` in a
 *  literal-named browser, returning "ok"/"miss". The app name MUST be a literal
 *  (not a variable): AppleScript loads an app's scripting dictionary by literal
 *  name at COMPILE time, so `tell application someVar` can't resolve app-specific
 *  terms like `active tab index` (fails with -2740). Referencing an uninstalled
 *  app by literal name is also a compile error a `try` can't catch — hence we
 *  only ever run a browser's script when pgrep says it's running (= installed). */
function focusTabScript(app: string, kind: "chromium" | "safari", match: string): string {
  const m = JSON.stringify(match); // safe AppleScript string literal
  if (kind === "safari") {
    return `tell application "${app}"
      repeat with w in windows
        repeat with t in tabs of w
          if URL of t contains ${m} then
            set current tab of w to t
            activate
            return "ok"
          end if
        end repeat
      end repeat
    end tell
    return "miss"`;
  }
  return `tell application "${app}"
    repeat with w in windows
      set k to 0
      repeat with t in tabs of w
        set k to k + 1
        if URL of t contains ${m} then
          set active tab index of w to k
          set index of w to 1
          activate
          return "ok"
        end if
      end repeat
    end repeat
  end tell
  return "miss"`;
}

/** Open the chat UI, reusing an already-open tab on this host:port instead of
 *  spawning a duplicate. Each browser is scripted via its own literal-named
 *  AppleScript, run ONLY when pgrep confirms it's running (so the literal `tell`
 *  always compiles). Falls back to a plain `open` (new tab) when no running
 *  browser has the tab, for browsers we don't script (e.g. Firefox), or if
 *  AppleScript is blocked. Best-effort and fire-and-forget: any failure just
 *  means a fresh tab, so it never regresses the plain-open path. The first focus
 *  may trigger a one-time macOS "control your browser" permission prompt;
 *  declining it just falls back to opening a new tab. */
function openChatUi(url: string, hostPort: string): void {
  const browsers: Array<{ proc: string; kind: "chromium" | "safari" }> = [
    { proc: "Google Chrome", kind: "chromium" },
    { proc: "Arc", kind: "chromium" },
    { proc: "Brave Browser", kind: "chromium" },
    { proc: "Microsoft Edge", kind: "chromium" },
    { proc: "Safari", kind: "safari" },
  ];
  void (async () => {
    for (const b of browsers) {
      try {
        const running = Bun.spawn(["pgrep", "-x", b.proc], { stdout: "ignore", stderr: "ignore" });
        if ((await running.exited) !== 0) continue; // not running → skip (and don't compile its tell)
        const script = focusTabScript(b.proc, b.kind, hostPort);
        const p = Bun.spawn(["osascript", "-e", script], { stdout: "pipe", stderr: "ignore", timeout: 8000 });
        const out = await new Response(p.stdout).text();
        if ((await p.exited) === 0 && out.trim() === "ok") return; // focused an existing tab
      } catch { /* try the next browser */ }
    }
    try { Bun.spawn(["open", url], { stdout: "ignore", stderr: "ignore" }); } catch { /* best-effort */ }
  })();
}

/** Server/runtime flags shared by every mode that loads a model
 *  (serve, pi). Env levers are set here so they're in place before the
 *  generate/compiled-decode modules read them. */
/** Resolve the decode ROUTE: a tier alias (--l1/--l2/--l3) sets the whole route,
 *  and an explicit per-fork flag (--perf-kernel/--kv-quant/…) overrides the alias.
 *  The tier IS the intent; the forks are the escape hatch. Sets the decode env
 *  levers and returns the kv-quant mode. See docs/design/parity-tier-dag.md.
 *  Each tier is a GUARANTEE about which reference you reproduce bit-for-bit:
 *    --l1  bit-for-bit IDENTICAL to mlx-lm    — drop-in replacement for mlx-lm
 *    --l2  bit-for-bit IDENTICAL to mlx-optiq — drop-in replacement for mlx-optiq.
 *          The optiq-golden decode composition (scripts/regen-kvq-goldens.ts) is
 *          fused N-tiled SDPA for L>1 + STOCK unfused L=1 decode, so L2 = fused-sdpa
 *          ON, perf-kernel OFF. The perf kernel is an mlx-bun ORIGINAL Metal kernel,
 *          envelope-gated (≥56/64 teacher-forced argmax vs OUR OWN frozen compat
 *          trajectory, tests/perf-kernel-oracle.test.ts) — an L3 node, never the
 *          bare-L2 default. (Commit f1bf5cc put it in L2 claiming the goldens track
 *          it; they don't — reverted 2026-07-01 with the evidence above.)
 *    --l3  best performance, NO bit-exact guarantee — correct, but gated by KL +
 *          tests, because mlx-optiq has no analogy for what L3 does.
 *  L2 ⊂ L3 (L3 = L2 + perf kernel). L1 is a separate target (bf16, unfused). */
function applyDecodeRoute(): { kvQuant?: "off" | "config" | number } {
  const onOff = (name: string): boolean | null => {
    const v = opt(name); if (v == null) return null;
    if (v === "on" || v === "1" || v === "true") return true;
    if (v === "off" || v === "0" || v === "false") return false;
    console.error(`--${name} expects on|off (got "${v}")`); process.exit(1);
  };
  type Preset = { kv: "off" | "config"; perf: boolean; fusedSdpa: boolean; compiled: boolean; fusedDecode: boolean };
  const TIERS: Record<string, Preset> = {
    // A tier is the GUARANTEE; within it we default to the FAST kernel that still
    // holds it, and expose the slow one as an opt-in. compiled-decode is BIT-EXACT
    // with uncompiled (compiled-decode.test: on==off) → free speed, so it's ON in
    // EVERY tier (--compiled-decode off is the slow, same-tier opt-in). fused-sdpa
    // matches OPTIQ bit-for-bit (tier-a goldens, fused-sdpa.test) and is
    // quantized-KV only → it's the L2 bridge, a no-op on L1's bf16. perf-kernel is
    // NOT: it's an original flash-decoding kernel, envelope-gated against our own
    // frozen trajectory (perf-kernel-oracle.test) — bare --l2 must ship the
    // optiq-golden decode composition (stock unfused L=1), so perf-kernel is
    // L3/explicit-only (--perf-kernel on opts a tier into it by choice). This is
    // the decode-axis difference between L2 and L3; L3 also owns the no-oracle
    // FEATURES (HLG sampler, expert offload, batched mixed-precision).
    l1: { kv: "off",    perf: false, fusedSdpa: false, compiled: true, fusedDecode: false }, // = mlx-lm bit-for-bit (bf16)
    l2: { kv: "config", perf: false, fusedSdpa: true,  compiled: true, fusedDecode: false }, // = mlx-optiq bit-for-bit
    l3: { kv: "config", perf: true,  fusedSdpa: true,  compiled: true, fusedDecode: false }, // best perf (envelope-gated decode)
  };
  const tier = flag("l1") ? "l1" : flag("l2") ? "l2" : flag("l3") ? "l3" : null;
  const p = tier ? TIERS[tier]! : null;
  const pick = (name: string, base: boolean | undefined): boolean | null => {
    const ex = onOff(name); return ex !== null ? ex : (base ?? null); // explicit flag wins, else tier preset
  };
  const set = (env: string, val: boolean | null, invert = false) => {
    if (val !== null) process.env[env] = (invert ? !val : val) ? "1" : "0";
  };
  set("MLX_BUN_COMPILED_DECODE", pick("compiled-decode", p?.compiled));
  set("MLX_BUN_PERF_KERNEL", pick("perf-kernel", p?.perf));
  set("MLX_BUN_FUSED_DECODE", pick("fused-decode", p?.fusedDecode));
  set("MLX_BUN_NO_FUSED_SDPA", pick("fused-sdpa", p?.fusedSdpa), true); // inverted env
  const kv = opt("kv-quant"); // explicit --kv-quant overrides the tier
  if (kv === "off") return { kvQuant: "off" };
  if (kv === "config") return { kvQuant: "config" };
  if (kv) {
    const bits = Number(kv);
    if (![4, 8].includes(bits)) { console.error(`--kv-quant expects config|off|4|8 (got "${kv}")`); process.exit(1); }
    return { kvQuant: bits };
  }
  return p ? { kvQuant: p.kv } : {};
}

function serverRuntimeFlags(): { port: number; serverOptions: import("./server").ServerOptions } {
  const onOff = (name: string): boolean | null => {
    const v = opt(name);
    if (v === null) return null;
    if (v === "on" || v === "1" || v === "true") return true;
    if (v === "off" || v === "0" || v === "false") return false;
    console.error(`--${name} expects on|off (got "${v}")`);
    process.exit(1);
  };
  const route = applyDecodeRoute(); // --l1/--l2/--l3 tier alias, with per-fork flags overriding
  if (flag("force-wire")) process.env.MLX_BUN_FORCE_WIRE = "1";

  const serverOptions: import("./server").ServerOptions = {};
  const budgetGB = Number(opt("memory-budget", "0"));
  if (budgetGB > 0) serverOptions.memoryBudgetBytes = budgetGB * 1e9;
  const pcRaw = opt("prompt-cache"); // null if absent; an explicit value (incl. 0) wins → `--prompt-cache 0` DISABLES the cache
  if (pcRaw !== null) serverOptions.promptCacheBytes = Math.max(0, Number(pcRaw)) * 2 ** 30;
  // --batch N: max concurrent requests batched through the mlx-lm-parity
  // engine (N=1 = today's serial path). --decode-concurrency is accepted for
  // drop-in compatibility with mlx_lm.server, but the semantics differ: there
  // it caps per-BatchGenerator decode parallelism (default 32); in mlx-bun it
  // enables continuous batching with this cap (the default is the optimized
  // serial path).
  const batchRaw = opt("batch") ?? opt("decode-concurrency");
  if (batchRaw !== null) {
    const n = Number(batchRaw);
    if (!Number.isInteger(n) || n < 1) {
      console.error(`--batch expects an integer >= 1 (got "${batchRaw}")`);
      process.exit(1);
    }
    serverOptions.batch = n;
  }
  if (route.kvQuant !== undefined) serverOptions.kvQuant = route.kvQuant;
  // Bind loopback unless asked otherwise (mlx_lm.server parity); --host
  // 0.0.0.0 is the explicit opt-in for LAN exposure. The chat-UI open and
  // `mlx-bun pi` attach both go through localhost, so loopback-only is
  // transparent to them.
  serverOptions.hostname = opt("host", "127.0.0.1")!;
  // Server-wide default for the chat template's enable_thinking variable
  // (CPM/MiniCPM5 and other hybrid-reasoning models). Unset ⇒ the model's
  // own default (false for MiniCPM5). onOff accepts true|false|on|off|1|0.
  const thinking = onOff("thinking");
  if (thinking !== null) serverOptions.defaultThinking = thinking;
  // Server-wide sampling defaults. Unset ⇒ the model's generation_config.json
  // (MiniCPM5 ships 0.9 / 0.95 — its think recipe). A per-request field still
  // overrides these; the browser chat sends none, so this is its only lever.
  const numFlag = (name: string, lo: number, hi: number): number | null => {
    const v = opt(name);
    if (v === null) return null;
    const n = Number(v);
    if (!Number.isFinite(n) || n < lo || n > hi) {
      console.error(`--${name} expects a number in [${lo}, ${hi}] (got "${v}")`);
      process.exit(1);
    }
    return n;
  };
  // --temp is the mlx_lm.server spelling; explicit --temperature wins.
  const temp = numFlag("temperature", 0, 5) ?? numFlag("temp", 0, 5);
  if (temp !== null) serverOptions.defaultTemperature = temp;
  const topP = numFlag("top-p", 0, 1);
  if (topP !== null) serverOptions.defaultTopP = topP;
  const topK = numFlag("top-k", 0, 1_000_000);
  if (topK !== null) serverOptions.defaultTopK = topK;
  // mlx_lm.server's --max-tokens: the completion cap when a request omits
  // max_tokens. Our built-in default stays 65,536 (chat) / 512 (raw text
  // completion); `--max-tokens 512` reproduces mlx-lm's behavior exactly.
  const maxTok = numFlag("max-tokens", 1, 10_000_000);
  if (maxTok !== null) serverOptions.defaultMaxTokens = Math.floor(maxTok);
  // HLG sampling — piecewise tone curve on the logprobs (default off). Knobs in
  // nats; the mid gain folds from --temperature. docs/design/hlg-sampling.md.
  if (onOff("hlg-sampling") === true) {
    serverOptions.hlg = {
      enabled: true,
      width: numFlag("hlg-width", 0, 100) ?? 4,
      shoulder: numFlag("hlg-shoulder", 0, 100) ?? 4,
      toe: numFlag("hlg-toe", 0, 100) ?? 6,
      pivotOffset: numFlag("hlg-pivot-offset", 0, 100) ?? 6,
      pivot: "top",
    };
  }
  return { port: Number(opt("port", "8080")), serverOptions };
}

/** `--adapter <dir>` (alias `--adapter-path`, mlx_lm.server's spelling):
 *  mount a LoRA adapter at startup — the same machinery as POST /v1/adapters —
 *  and make it the default for requests that don't select one (a request's
 *  explicit `adapter`, including "none", still wins; hot-swap unchanged).
 *  This is the flag `mlx-bun train`'s completion message points at. Shared by
 *  `serve` and the `pi` session server. Exits on a bad adapter — better a
 *  loud startup failure than silently serving the base model. */
async function mountStartupAdapter(
  ctx: import("./server").ServerContext,
  serverOptions: import("./server").ServerOptions,
): Promise<void> {
  const adapterDir = opt("adapter") ?? opt("adapter-path");
  if (!adapterDir) return;
  const { step, style } = await import("./tui");
  const sAdp = step("mounting adapter");
  try {
    const adapterId = adapterDir.replace(/\/+$/, "").split("/").pop()!;
    const info = await ctx.adapters.mount(adapterId, adapterDir);
    serverOptions.defaultAdapter = info.id;
    sAdp.done(`adapter ${style.bold(info.id)} ${style.dim(`· ${info.mountedLayers} layers · default for requests (select others via \`adapter\`)`)}`);
  } catch (e) {
    sAdp.fail(`adapter mount failed: ${(e as Error).message}`);
    process.exit(1);
  }
}

/** One-line summary of the active runtime levers for the ready card. */
function runtimeSummary(o: import("./server").ServerOptions): string {
  const kv = o.kvQuant === "off" ? "off" : typeof o.kvQuant === "number" ? `kv${o.kvQuant}` : "config";
  const lever = (env: string, dflt: string) => process.env[env] ?? dflt;
  return `kv-quant ${kv} · compiled-decode ${lever("MLX_BUN_COMPILED_DECODE", "1") === "1" ? "on" : "off"}` +
    ` · perf-kernel ${perfKernelEnabled() ? "on" : "off"}` +
    (lever("MLX_BUN_FUSED_DECODE", "0") === "1" ? " · fused-decode on" : "") +
    (o.batch && o.batch > 1 ? ` · batch ${o.batch}` : "") +
    (o.defaultThinking !== undefined ? ` · thinking ${o.defaultThinking ? "on" : "off"}` : "") +
    (o.defaultTemperature !== undefined ? ` · temp ${o.defaultTemperature}` : "") +
    (o.defaultTopP !== undefined ? ` · top-p ${o.defaultTopP}` : "") +
    (o.defaultTopK !== undefined ? ` · top-k ${o.defaultTopK}` : "");
}

/** Shared model resolution: explicit query wins; otherwise e4b (the default
 *  model everywhere) if it's downloaded, else the largest supported model that
 *  fits this machine. Downloads the recommended model first on a fresh install. */
async function resolveModelAuto(query: string | null): Promise<{ m: import("./registry").ModelRecord; picked: boolean }> {
  const reg = new Registry();
  if (reg.list().length === 0) await reg.scan();
  if (query) return { m: reg.resolve(query), picked: false };
  const { recommendedRepoId } = await import("./fit");
  let candidates = reg.list().filter((r) => isSupportedModelRecord(r.modelType, r.repoId));
  if (candidates.length === 0) {
    // First run: starter-model flow (PRODUCT_ROADMAP / PLAN Phase 16).
    // Download the sub-GB starter first so the user is chatting quickly,
    // then stream the recommended Gemma for this Mac in the background —
    // it becomes the auto-pick next run.
    const starterRepo = "mlx-community/MiniCPM5-1B-OptiQ-4bit";
    const recRepo = recommendedRepoId();
    const { step, style } = await import("./tui");
    const { downloadModel } = await import("./download");
    const s = step(`downloading starter model ${starterRepo}`);
    await downloadModel(starterRepo, {
      onProgress: (file, received, total) => {
        const pct = total ? Math.floor((received / total) * 100) : 0;
        s.update(`starter model ${starterRepo} — ${file} ${gb(received)} / ${gb(total)} (${pct}%)`);
      },
    });
    s.done(`starter model ready ${style.dim(`· ${starterRepo}`)}`);
    await reg.scan();
    if (recRepo !== starterRepo) {
      console.log(`  ${style.dim(`downloading ${recRepo} (recommended for this Mac) in the background —`)}`);
      console.log(`  ${style.dim("it becomes the default next run · progress on the status page (/downloads) · resumable")}`);
      downloadModel(recRepo)
        .then(async () => {
          await new Registry().scan();
          console.log(`  ${style.dim(`background download complete: ${recRepo} (used on next run)`)}`);
        })
        .catch(() => { /* resumable — the next run continues it */ });
    }
    candidates = reg.list().filter((r) => isSupportedModelRecord(r.modelType, r.repoId));
  }
  // No query: e4b by default; otherwise the largest model that still leaves
  // the machine usable for other apps. Never auto-grab the 26B "dedicate the
  // machine" model on a small-RAM Mac — that's an explicit --query choice —
  // but allow it as a last resort if it's all the user has downloaded.
  const { DEFAULT_REPO_ID, COEXIST_FRACTION, chooseAutoModel, thisMachine } = await import("./fit");
  const machine = thisMachine();
  const fitsFull = new Map<string, boolean>();
  const fitsCoexist = new Map<string, boolean>();
  for (const r of candidates) {
    const config = await loadModelConfig(r.path);
    fitsFull.set(r.repoId, fit(config, r.sizeBytes, 8192, machine, undefined, r.expertsBytes).fits);
    fitsCoexist.set(
      r.repoId,
      fit(config, r.sizeBytes, 8192, machine, undefined, r.expertsBytes, machine.ramBytes * COEXIST_FRACTION).fits,
    );
  }
  const chosen = chooseAutoModel(
    candidates,
    DEFAULT_REPO_ID,
    (c) => fitsFull.get(c.repoId) ?? false,
    (c) => fitsCoexist.get(c.repoId) ?? false,
  );
  if (chosen) return { m: chosen, picked: true };
  console.error("no downloaded supported model fits this machine — pick one explicitly (mlx-bun ls)");
  process.exit(1);
}

function parseSize(s: string): number {
  const m = /^([\d.]+)\s*(GB|MB|G|M)?$/i.exec(s.trim());
  if (!m) throw new Error(`bad size: ${s}`);
  const mult = /^m/i.test(m[2] ?? "G") ? 2 ** 20 : 2 ** 30;
  return Number(m[1]) * mult;
}

switch (cmd) {
  case "get": {
    let repoId = positional(0);
    if (!repoId) {
      console.error("usage: mlx-bun get <org/repo | substring> [--revision main]");
      process.exit(1);
    }
    if (!repoId.includes("/")) {
      // No org/name — treat it as a registry query over already-downloaded
      // repos (re-get/refresh, e.g. `mlx-bun get 12B` after an upstream push).
      try {
        const regQ = new Registry();
        if (regQ.list().length === 0) await regQ.scan();
        repoId = regQ.resolve(repoId).repoId;
      } catch (e) {
        console.error((e as Error).message);
        console.error(`usage: mlx-bun get <org/repo> [--revision main] — or a substring of a downloaded repo (try \`mlx-bun ls ${repoId}\`)`);
        process.exit(1);
      }
    }
    const { downloadModel } = await import("./download");
    const { step, style } = await import("./tui");
    const { join: joinPath, basename } = await import("node:path");
    const { readdirSync, existsSync } = await import("node:fs");
    const { DEFAULT_HUB, planRepoGc } = await import("./registry");
    const repoDir = joinPath(DEFAULT_HUB, `models--${repoId.replaceAll("/", "--")}`);
    const priorSnapshots = existsSync(joinPath(repoDir, "snapshots"))
      ? readdirSync(joinPath(repoDir, "snapshots"))
      : [];
    const s = step(`downloading ${repoId}`);
    const snap = await downloadModel(repoId, {
      revision: opt("revision", "main")!,
      onProgress: (file, received, total) => {
        const pct = total ? Math.floor((received / total) * 100) : 0;
        s.update(`${style.bold(repoId)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${pct}%)`)}`);
      },
    });
    s.done(`${style.bold(repoId)} ${style.dim("downloaded · verified")}`);
    const sScan = step("updating registry");
    const reg = new Registry();
    await reg.scan();
    sScan.done(`registry updated ${style.dim(`· ${snap}`)}`);
    // Upstream pushed a new revision → this get created a NEW snapshots/<sha>
    // dir; the old one stays on disk (that's how ~25 GB of dead blobs pile
    // up). Say so, with what `gc` would get back.
    if (priorSnapshots.length > 0 && !priorSnapshots.includes(basename(snap))) {
      const plan = planRepoGc(repoDir);
      const note = plan.skippedSnapshots.length > 0
        ? " (a previous snapshot has files this revision lacks — gc will warn; --force to prune it)"
        : "";
      console.log(style.dim(
        `  previous revision kept on disk — \`mlx-bun gc\` reclaims ~${gb(plan.reclaimBytes)}${note}`,
      ));
    }
    break;
  }

  case "scan": {
    const { step } = await import("./tui");
    const s = step("scanning the Hugging Face cache");
    const reg = new Registry();
    const n = await reg.scan();
    s.done(`indexed ${n} model snapshot(s)`);
    break;
  }

  case "ls": {
    const reg = new Registry();
    if ((reg.list().length ?? 0) === 0) await reg.scan();
    const maxSize = opt("max-size");
    const allRevisions = flag("all-revisions");
    const lsFilter = {
      vision: flag("vision") ? true : undefined,
      maxBytes: maxSize ? parseSize(maxSize) : undefined,
      query: positional(0),
    };
    // One row per repo by default: the HF cache keeps a snapshots/<commit>
    // dir per downloaded revision, and re-getting after an upstream push
    // strands the old one — those are duplicates, not separate models.
    // --all-revisions shows the per-snapshot truth (canonical marked *).
    const models = allRevisions ? reg.list(lsFilter) : reg.listCanonical(lsFilter);
    if (models.length === 0) {
      console.log("no models match (try `mlx-bun scan`)");
      break;
    }
    const { visionCapable } = await import("./registry");
    const { supportTier } = await import("./model/support");
    const canonicalPaths = new Set(reg.listCanonical(lsFilter).map((m) => m.path));
    const capabilities = (m: (typeof models)[number]) => {
      const tier = supportTier(m.modelType, m.repoId);
      return [
        tier ? `supported (${tier})` : `unsupported (${m.modelType})`,
        visionCapable(m) ? "vision" : null,
        m.hasToolTemplate ? "tools" : null,
        m.hasKvConfig ? "kv-quant" : null,
      ].filter(Boolean).join(" · ");
    };
    const { table, style, h1 } = await import("./tui");
    h1("library");
    console.log();
    table(
      [
        { header: "model", paint: (c) => style.bold(c) },
        ...(allRevisions ? [{ header: "revision" }] : []),
        { header: "size", align: "right" as const },
        { header: "params", align: "right" as const },
        { header: "quant" },
        { header: "license", paint: (c: string) => style.dim(c) },
        { header: "capabilities", paint: (c: string) => style.dim(c) },
      ],
      models.map((m) => [
        m.repoId,
        ...(allRevisions
          ? [`${(m.path.split("/snapshots/")[1] ?? "").slice(0, 12)}${canonicalPaths.has(m.path) ? " *" : ""}`]
          : []),
        gb(m.sizeBytes),
        m.paramCount ? `${(m.paramCount / 1e9).toFixed(1)}B` : "?",
        m.quantBits ? `${m.quantBits}-bit g${m.quantGroupSize}` : "full",
        m.license ?? "?",
        capabilities(m),
      ]),
    );
    console.log();
    if (allRevisions) {
      console.log(style.dim(
        `  ${models.length} snapshot(s) · * = canonical (refs/main) · superseded snapshots: \`mlx-bun gc\``,
      ));
    } else {
      console.log(style.dim(`  ${models.length} model(s) · mlx-bun fit <query> for a memory assessment`));
    }
    break;
  }

  case "gc": {
    const { planGc, executeGc, DEFAULT_HUB } = await import("./registry");
    const { table, style, h1 } = await import("./tui");
    const force = flag("force");
    const plans = planGc(DEFAULT_HUB, { force }).filter(
      (p) => p.pruneSnapshots.length || p.skippedSnapshots.length || p.deadBlobs.length,
    );
    h1("gc — superseded snapshots + dead blobs");
    console.log();
    if (plans.length === 0) {
      console.log("  nothing to reclaim — every snapshot is referenced by refs/*");
      break;
    }
    table(
      [
        { header: "repo", paint: (c) => style.bold(c) },
        { header: "keep", align: "right" },
        { header: "prune", align: "right" },
        { header: "skip", align: "right" },
        { header: "reclaims", align: "right" },
      ],
      plans.map((p) => [
        p.repoId,
        String(p.keepSnapshots.length),
        String(p.pruneSnapshots.length),
        String(p.skippedSnapshots.length),
        gb(p.reclaimBytes),
      ]),
    );
    console.log();
    for (const p of plans) {
      for (const s of p.skippedSnapshots) {
        const rev = (s.path.split("/snapshots/")[1] ?? s.path).slice(0, 12);
        console.log(style.accent(
          `  WARNING ${p.repoId}@${rev}: superseded snapshot has files the canonical revision lacks — skipped.`,
        ));
        console.log(style.dim(`    only copy of: ${s.extraFiles.join(", ")}`));
        console.log(style.dim("    deleting it loses those files — rerun with --force if that's intended."));
      }
    }
    const totalReclaim = plans.reduce((a, p) => a + p.reclaimBytes, 0);
    const totalSnaps = plans.reduce((a, p) => a + p.pruneSnapshots.length, 0);
    const totalBlobs = plans.reduce((a, p) => a + p.deadBlobs.length, 0);
    console.log(
      `  total: ${totalSnaps} snapshot(s), ${totalBlobs} blob(s), ${style.bold(gb(totalReclaim))}`,
    );
    if (flag("dry-run") || !flag("yes")) {
      console.log(style.dim("  nothing deleted — rerun with --yes to delete (destructive)."));
      break;
    }
    const res = executeGc(plans);
    console.log(
      `  deleted ${res.snapshots} snapshot(s) + ${res.blobs} blob(s) — reclaimed ${style.bold(gb(res.reclaimedBytes))}`,
    );
    const reg = new Registry();
    await reg.scan(); // reap deleted snapshots from the registry
    break;
  }

  case "fit": {
    const query = positional(0);
    if (!query) { console.error("usage: mlx-bun fit <query> [--ctx N] [--skus]"); process.exit(1); }
    const reg = new Registry();
    if (reg.list().length === 0) await reg.scan();
    const m = reg.resolve(query);
    const config = await loadModelConfig(m.path);
    const ctx = Number(opt("ctx", "8192"));
    const r = fit(config, m.sizeBytes, ctx, thisMachine(), undefined, m.expertsBytes);
    const { box, table, style, h1, gradient } = await import("./tui");
    h1("will it fit?");
    console.log(`  ${style.bold(m.repoId)} ${style.dim(`@ ${ctx.toLocaleString()} context · this machine`)}`);
    console.log();
    const expertsNote = config.text.enableMoeBlock && m.expertsBytes > 0
      ? style.dim(`  (experts ${gb(m.expertsBytes)}; top ${config.text.topKExperts}/${config.text.numExperts} read per token)`)
      : "";
    box([
      `weights    ${gb(r.weightsBytes).padStart(9)}${expertsNote}`,
      ...(m.sidecarBytes > 0
        ? [style.dim(`  + vision sidecar ${gb(m.sidecarBytes)} (bf16, loads only for vision)`)] : []),
      `kv cache   ${gb(r.kvBytes).padStart(9)}`,
      `transient  ${gb(r.transientBytes).padStart(9)}`,
      `total      ${gb(r.totalBytes).padStart(9)} ${style.dim(`of ${gb(r.usableBytes)} usable`)}  ${r.fits ? style.green(style.bold("FITS")) : style.bold("DOES NOT FIT")}`,
      "",
      `max safe context   ${style.bold(r.maxSafeContext.toLocaleString())} tokens`,
      `predicted decode   ${gradient(`${r.predictedDecodeTps.toFixed(1)} tok/s`)}`,
    ]);
    if (flag("skus")) {
      h1("apple silicon matrix");
      console.log();
      table(
        [
          { header: "chip" }, { header: "ram", align: "right" },
          { header: "fits", paint: (c) => (c.includes("fits") ? style.green(c) : style.dim(c)) },
          { header: "max context", align: "right" }, { header: "decode", align: "right" },
        ],
        skuMatrix(config, m.sizeBytes, ctx, m.expertsBytes).map((row) => [
          row.sku, `${row.ramGB} GB`, row.fits ? "fits" : "—",
          row.fits ? row.maxContext.toLocaleString() : "—",
          row.fits ? `~${row.decodeTps.toFixed(0)} tok/s` : "—",
        ]),
      );
    }
    console.log();
    break;
  }

  case "serve": {
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    if (noSubcommand)
      console.log(style.dim("  no command given — starting the server · mlx-bun --help for all commands"));
    const rt = serverRuntimeFlags();
    // Friendly collision check before loading gigabytes of weights.
    {
      const { probeServer } = await import("./harness-pi");
      const running = await probeServer(`http://localhost:${rt.port}/v1`);
      if (running) {
        console.error(`port ${rt.port} is already serving ${running.map((m) => m.id).join(", ")}.`);
        console.error("reuse it (mlx-bun pi attaches automatically), stop it, or pick --port <other>.");
        console.error("NOTE: a second server is a second model in memory — check `mlx-bun fit` first.");
        process.exit(1);
      }
    }
    const { m, picked } = await resolveModelAuto(positional(0) ?? opt("query"));
    const sFit = step("assessing fit");
    const config = await loadModelConfig(m.path);
    const report = fit(config, m.sizeBytes, 8192, undefined, undefined, m.expertsBytes);
    sFit.done(`${style.bold(m.repoId)} ${style.dim(`· ${gb(m.sizeBytes)} · ~${report.predictedDecodeTps.toFixed(0)} tok/s predicted`)}${picked ? style.dim(" · auto-picked (override: mlx-bun serve <query>)") : ""}`);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");
    const { createServer, loadContext } = await import("./server");
    if (flag("expert-offload")) {
      if (m.expertsBytes === 0) {
        console.error(style.dim("--expert-offload ignored: this model has no experts (dense)"));
      } else {
        const sOff = step("expert offload");
        const { ensureOffloadFile } = await import("./expert-offload-build");
        const { activateExpertOffload } = await import("./expert-offload");
        // builds <model>/.mlx-bun-offload on first use (~one-time), then reuses
        const dir = await ensureOffloadFile(m.path, (msg) => sOff.update(msg));
        activateExpertOffload(dir);
        sOff.done(`experts mmap'd ${style.dim(dir)} ${style.dim("· phys_footprint ≈ core")}`);
      }
    }
    const sLoad = step("loading weights");
    const t0 = performance.now();
    const ctx = await loadContext(m.path, m.repoId, { memoryBudgetBytes: rt.serverOptions.memoryBudgetBytes });
    sLoad.done(`weights loaded ${style.dim(`in ${(performance.now() - t0).toFixed(0)} ms`)}`);
    await mountStartupAdapter(ctx, rt.serverOptions);
    const server = createServer(ctx, rt.port, { ...rt.serverOptions, owner: "serve" });
    const shownHost = rt.serverOptions.hostname ?? "localhost";
    console.log();
    box([
      `${style.green("●")} ${style.bold("serving")} ${m.repoId}`,
      "",
      `API   ${style.url(`http://${shownHost}:${server.port}/v1`)}  ${style.dim("(OpenAI · Anthropic · Responses)")}`,
      `App   ${style.url(`http://${shownHost}:${server.port}/`)}  ${style.dim("(chat · quantize · finetune · dataset · status)")}`,
      ...(rt.serverOptions.memoryBudgetBytes
        ? [`Mem   ${gb(rt.serverOptions.memoryBudgetBytes)} budget ${style.dim("(admission control on)")}`] : []),
      `Perf  ${style.dim(runtimeSummary(rt.serverOptions))}`,
      "",
      style.dim("agent session:  mlx-bun pi        stop:  Ctrl+C"),
    ]);
    // Open the chat UI for interactive runs (--no-open, or a non-TTY such as
    // a piped/headless/benchmark run, skips it). 0.0.0.0/:: bind → localhost
    // for the browser. Reuses an existing tab on this host:port when possible
    // (see openChatUi); the URL is printed above either way.
    if (!flag("no-open") && process.stdout.isTTY) {
      const browserHost = shownHost === "0.0.0.0" || shownHost === "::" ? "localhost" : shownHost;
      openChatUi(`http://${browserHost}:${server.port}/#/chat`, `${browserHost}:${server.port}`);
    }
    break;
  }

  case "gen":
  case "generate": {
    // RAW generate — a direct one-shot entry point (no server, no chat UI). The
    // three entry points (raw / OpenAI API / chat UI) differ only in how params
    // are POPULATED; here every param is explicit. Decode-path levers mirror
    // serve so you can pin the route (mlx-lm compat = --l1).
    // --l1/--l2/--l3 + per-fork overrides set the decode env levers; the
    // returned KV scheme is applied below so `generate --l2` runs the same
    // quantized-KV route (and produces the same tokens) as `serve --l2`.
    const route = applyDecodeRoute();

    const prompt = opt("prompt") ?? positional(1);
    if (!prompt) {
      console.error('usage: mlx-bun generate [query] --prompt "…" [--raw] [--max-tokens N]');
      console.error('       sampling:  --temperature N (alias --temp) --top-p N --top-k N --seed N');
      console.error('       decode path: --l1 (= mlx-lm compat) / --l2 / --l3, or per-fork flags');
      process.exit(1);
    }
    const { loadTaskModel, generateText } = await import("./eval/runner");
    const tm = await loadTaskModel(positional(0) ?? opt("query") ?? "");
    // Resolve the tier/--kv-quant KV scheme exactly the way serve does
    // (server.ts kvScheme): "config" = the model's kv_config.json (absent →
    // bf16, same silent fallback as serve), N = uniform bits from decode
    // start. Unset (no tier, no --kv-quant) keeps generate's historical
    // default: bf16 bit-exact greedy (generateText's parity path).
    const kvScheme =
      route.kvQuant === "off" ? {}
      : route.kvQuant === "config"
        ? (tm.config.kvQuant?.length ? { kvConfig: tm.config.kvQuant } : {})
      : typeof route.kvQuant === "number"
        ? { kvBits: route.kvQuant, quantizedKvStart: 0 }
      : undefined;
    const num = (n: string): number | undefined => { const v = opt(n); return v == null ? undefined : Number(v); };
    const text = await generateText(tm, prompt, {
      maxTokens: Number(opt("max-tokens", "256")),
      useChat: !flag("raw"),
      ...(kvScheme !== undefined ? { kvScheme } : {}),
      sampler: { temperature: num("temperature") ?? num("temp"), topP: num("top-p"), topK: num("top-k"), seed: num("seed") },
    });
    process.stdout.write(text.endsWith("\n") ? text : text + "\n");
    break;
  }

  case "embed": {
    // Raw text embeddings — one-shot, no server. Text from --text, or one per
    // line on stdin. Uses the same embedPooled path the parity test verifies.
    const { Weights } = await import("./weights");
    const { createModel } = await import("./model/factory");
    const { loadTokenizer } = await import("./tokenizer");
    const { embedMany, isEmbeddingModel } = await import("./embed");

    let texts: string[];
    const oneText = opt("text") ?? positional(1);
    if (oneText != null) {
      texts = [oneText];
    } else if (!process.stdin.isTTY) {
      texts = (await Bun.stdin.text()).split("\n").map((l) => l.trim()).filter((l) => l.length > 0);
    } else {
      texts = [];
    }
    if (texts.length === 0) {
      console.error('usage: mlx-bun embed [query] --text "…"   (or pipe text, one per line)');
      console.error('       --instruct "…"  query instruction · --json  OpenAI-style output');
      process.exit(1);
    }

    // Model resolution: an explicit query resolves normally; the no-query
    // path auto-picks the first DOWNLOADED embedding model (plain Qwen3 —
    // the record-level equivalent of isEmbeddingModel, which the factory
    // maps to Qwen3Model). Never the chat default, and never the fresh-
    // install starter download — a chat model can't embed, so downloading
    // one here only to fail the isEmbeddingModel check would be a trap.
    const embedQuery = positional(0) ?? opt("query");
    let m: import("./registry").ModelRecord;
    if (embedQuery) {
      ({ m } = await resolveModelAuto(embedQuery));
    } else {
      const reg = new Registry();
      if (reg.list().length === 0) await reg.scan();
      const embedder = reg.list().find((r) => r.modelType === "qwen3");
      if (!embedder) {
        console.error("no embedding model downloaded — try: mlx-bun get mlx-community/Qwen3-Embedding-4B-4bit-DWQ");
        process.exit(1);
      }
      m = embedder;
    }
    const config = await loadModelConfig(m.path);
    const model = createModel(await Weights.open(m.path), config);
    if (!isEmbeddingModel(model)) {
      console.error(`"${m.repoId}" is not an embedding model (need plain Qwen3, e.g. Qwen3-Embedding).`);
      process.exit(1);
    }
    const tok = await loadTokenizer(m.path);
    const results = embedMany(model, tok, texts, opt("instruct") ?? undefined);

    if (flag("json")) {
      let total = 0;
      const data = results.map((r, index) => { total += r.tokens; return { object: "embedding", index, embedding: Array.from(r.vector) }; });
      process.stdout.write(JSON.stringify({
        object: "list", data, model: m.repoId,
        usage: { prompt_tokens: total, total_tokens: total },
      }) + "\n");
    } else {
      for (const r of results) process.stdout.write(JSON.stringify(Array.from(r.vector)) + "\n");
    }
    break;
  }

  case "bench":
  case "benchmark": {
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    serverRuntimeFlags(); // env levers (--compiled-decode, --perf-kernel, ...) apply to the run
    const { m, picked } = await resolveModelAuto(positional(0) ?? opt("query"));
    const tokens = Number(opt("tokens", "256"));
    const runs = Number(opt("runs", "3"));
    const promptTokens = Number(opt("prompt-tokens", "0"));
    const kvMode = opt("kv-quant", "off")!;
    console.log(`  ${style.dim("measures THIS machine, OUR stack only — no other systems needed.")}`);
    console.log(`  ${style.dim("numbers on a loaded machine are not quotable; ./benchmark.sh is the preflight-gated harness.")}`);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");
    const sLoad = step(`loading ${m.repoId}${picked ? " (auto-picked)" : ""}`);
    const { Weights } = await import("./weights");
    const { createModel } = await import("./model/factory");
    const { generate } = await import("./generate");
    const { ChatTemplate } = await import("./chat-template");
    const { loadTokenizer } = await import("./tokenizer");
    const { peakMemory, resetPeakMemory } = await import("./mlx/ffi");
    const config = await loadModelConfig(m.path);
    const weights = await Weights.open(m.path);
    const model = createModel(weights, config);
    const tok = await loadTokenizer(m.path);
    const template = await ChatTemplate.load(m.path);
    sLoad.done(`${style.bold(m.repoId)} ${style.dim(`· ${gb(m.sizeBytes)}`)}`);

    let userMsg = "Write a detailed essay about the history of computing, starting with mechanical calculators.";
    if (promptTokens > 0) {
      const filler = "Background context: the history of computation spans mechanical " +
        "calculators, electromechanical relays, vacuum tubes, transistors, " +
        "integrated circuits, and modern accelerators. ";
      while (tok.encode(userMsg).length < promptTokens - 24) userMsg = filler + userMsg;
    }
    const rendered = template.render([{ role: "user", content: userMsg }]);
    const ids = tok.encode(rendered);
    const promptIds = ids[0] === ids[1] && ids[0] === tok.bosTokenId ? ids.slice(1) : ids;
    const kvOptions = kvMode === "config"
      ? (() => {
          if (!config.kvQuant?.length) { console.error("model has no kv_config.json (--kv-quant config)"); process.exit(1); }
          return { kvConfig: config.kvQuant };
        })()
      : kvMode !== "off" ? { kvBits: Number(kvMode), quantizedKvStart: 0 } : {};

    // Warmup materializes weights so prefill timing measures prefill,
    // not lazy page-in (same protocol as scripts/bench.ts).
    const sWarm = step("warmup");
    {
      const wCache = model.makeCache();
      const wGen = generate(model, promptIds.slice(0, Math.min(8, promptIds.length - 1)), {
        maxTokens: 1, temperature: 0, cache: wCache,
      });
      for await (const _ of wGen) { /* discard */ }
      for (const c of wCache) c.dispose();
    }
    resetPeakMemory();
    sWarm.done("warmup complete");

    const decodes: number[] = [];
    const prefills: number[] = [];
    let lastStats: { promptTokens: number; generatedTokens: number } = { promptTokens: 0, generatedTokens: 0 };
    for (let i = 0; i < runs; i++) {
      const sRun = step(`run ${i + 1}/${runs} · ${tokens} tokens`);
      const gen = generate(model, promptIds, { maxTokens: tokens, temperature: 0, ...kvOptions });
      for await (const _ of gen) { /* timing only */ }
      const s = gen.stats!;
      decodes.push(s.decodeTps);
      prefills.push(s.prefillTps);
      lastStats = s;
      sRun.done(`run ${i + 1}/${runs} ${style.dim("·")} ${style.green(style.bold(`${s.decodeTps.toFixed(1)} tok/s`))} ${style.dim(`decode · prefill ${s.prefillTps.toFixed(0)} tok/s`)}`);
    }
    const median = (a: number[]) => [...a].sort((x, y) => x - y)[Math.floor(a.length / 2)]!;
    const peak = peakMemory();

    const { EvalDB: DB, gitCommit } = await import("./evaldb");
    new DB().record({
      modelPath: m.path,
      commitSha: gitCommit() ?? undefined,
      promptTokens: lastStats.promptTokens, cachedTokens: 0,
      generatedTokens: lastStats.generatedTokens,
      prefillTps: median(prefills), decodeTps: median(decodes),
      peakBytes: peak,
      notes: `cli-bench median-of-${runs} ${tokens}tok kv=${kvMode}${promptTokens ? ` ctx=${lastStats.promptTokens}` : ""} decode[${decodes.map((d) => d.toFixed(1)).join(",")}]`,
    });
    console.log();
    box([
      `${style.green("●")} ${style.bold("benchmark complete")} ${style.dim(`· ${m.repoId}`)}`,
      "",
      `decode    ${style.green(style.bold(`${median(decodes).toFixed(1)} tok/s`))} ${style.dim(`median of ${runs} · [${decodes.map((d) => d.toFixed(1)).join(", ")}]`)}`,
      `prefill   ${style.bold(`${median(prefills).toFixed(0)} tok/s`)} ${style.dim(`· ${lastStats.promptTokens} prompt tokens`)}`,
      `peak mem  ${style.bold(gb(peak))} ${style.dim("(generation only)")}`,
      `levers    ${style.dim(runtimeSummary({ kvQuant: kvMode === "off" ? "off" : kvMode === "config" ? undefined : Number(kvMode) }))}`,
      "",
      style.dim("recorded to the eval DB — see mlx-bun evals"),
    ]);
    break;
  }

  case "evals": {
    if (flag("clear")) {
      // Eval rows are real data — archive, never destroy.
      const { DEFAULT_EVAL_DB } = await import("./evaldb");
      const { existsSync, renameSync } = await import("node:fs");
      if (!existsSync(DEFAULT_EVAL_DB)) { console.log("no eval DB to clear"); break; }
      const stamp = new Date().toISOString().replace(/[:.]/g, "-");
      const backup = DEFAULT_EVAL_DB.replace(/\.sqlite$/, `-${stamp}.sqlite`);
      renameSync(DEFAULT_EVAL_DB, backup);
      console.log(`eval DB archived to ${backup}`);
      console.log("fresh DB starts with the next mlx-bun benchmark run");
      break;
    }
    const db = new EvalDB();
    const limit = Number(opt("limit", "20"));
    const rows = db.recent(limit);
    if (flag("raw")) {
      for (const r of rows) console.log(JSON.stringify(r));
      break;
    }
    const { style } = await import("./tui");
    if (rows.length === 0) {
      console.log("no eval runs recorded yet — ./benchmark.sh writes them");
      break;
    }
    const ago = (ts: number) => {
      const s = (Date.now() - ts) / 1000;
      if (s < 90) return `${Math.round(s)}s ago`;
      if (s < 5400) return `${Math.round(s / 60)}m ago`;
      if (s < 129600) return `${Math.round(s / 3600)}h ago`;
      return `${Math.round(s / 86400)}d ago`;
    };
    const modelName = (p: string) =>
      /models--[^/]+--([^/]+)/.exec(p)?.[1] ?? p.split("/").at(-1) ?? p;
    const note = (r: Record<string, unknown>, key: string) =>
      new RegExp(`${key}=([\\w.]+)`).exec((r.notes as string) ?? "")?.[1] ?? "";
    const BENCH_LABELS: Record<string, string> = {
      "h2h-server": "server e2e",
      "h2h-direct": "direct decode",
      "bench.ts": "decode script",
      "cli-bench": "cli benchmark",
    };
    const table = rows.map((r) => ({
      when: ago(r.ts as number),
      model: modelName(r.model_path as string).replace(/-OptiQ-4bit$/, "").replace(/^gemma-4-/, "g4-"),
      bench: BENCH_LABELS[((r.notes as string) ?? "").split(" ")[0] ?? ""] ?? ((r.notes as string) ?? "").split(" ")[0] ?? "",
      kv: note(r, "kv"),
      stack: (r.stack as string) ?? "mlx-bun",
      prefill: (r.prefill_tps as number) > 0 ? `${(r.prefill_tps as number).toFixed(0)}` : "",
      decode: (r.decode_tps as number).toFixed(1),
      ttft: note(r, "ttft_ms") ? `${note(r, "ttft_ms")}ms` : "",
      peak: gb(r.peak_bytes as number),
      commit: (r.commit_sha as string) ?? "",
    }));
    type Row = (typeof table)[number];
    const cols: Array<[string, keyof Row, "left" | "right"]> = [
      ["WHEN", "when", "right"], ["STACK", "stack", "left"], ["MODEL", "model", "left"],
      ["BENCH", "bench", "left"], ["KV", "kv", "left"],
      ["PREFILL", "prefill", "right"], ["DECODE", "decode", "right"], ["TTFT", "ttft", "right"],
      ["PEAK", "peak", "right"], ["COMMIT", "commit", "left"],
    ];
    const widths = cols.map(([h, k]) => Math.max(h.length, ...table.map((t) => t[k].length)));
    console.log();
    console.log("  " + cols.map(([h], i) => style.dim(h.padEnd(widths[i]!))).join("  "));
    for (const t of table) {
      console.log("  " + cols.map(([, k, align], i) => {
        const cell = align === "right" ? t[k].padStart(widths[i]!) : t[k].padEnd(widths[i]!);
        if (k === "decode") return style.green(style.bold(cell));
        if (k === "model") return style.bold(cell);
        if (k === "stack") return cell.trimEnd() === "mlx-bun" ? style.accent(cell) : style.dim(cell);
        if (k === "commit" || k === "when") return style.dim(cell);
        return cell;
      }).join("  "));
    }
    console.log();
    console.log(style.dim("  STACK   engine that produced the number (mlx-bun = us; mlx-lm/optiq = Python references)"));
    console.log(style.dim("  BENCH   server e2e = full HTTP round-trip · direct decode = engine only, no server"));
    console.log(style.dim("          decode script / cli benchmark = single-stack decode measurement"));
    console.log(style.dim("  KV      KV-cache quantization (off = bf16, config = per-layer kv_config.json)"));
    console.log(style.dim("  PREFILL prompt ingestion tok/s (in-process benches) · DECODE generation tok/s"));
    console.log(style.dim("  TTFT    request → first token, incl. server overhead (server benches)"));
    console.log(style.dim("  PEAK    max memory during generation"));
    console.log();
    console.log(style.dim(`  ${rows.length} run(s) · --limit <n> for more · --raw for full records · mlx-bun benchmark to add a run`));
    break;
  }

  case "pi": {
    // mlx-bun consumes its own flags; the rest describe how the built-in
    // agent runs. `mlx-bun pi` always drives pi's own TUI in-process
    // (src/pi-terminal.ts) — pi is bundled, nothing to install. Users who
    // already run their own pi connect it with `mlx-bun harness pi`.
    const OURS_VAL = new Set([
      "--query", "-q", "--port", "--host", "--memory-budget", "--prompt-cache", "--kv-quant",
      "--batch", "--decode-concurrency", "--adapter", "--adapter-path",
      "--compiled-decode", "--perf-kernel", "--fused-decode", "--fused-sdpa", "--thinking",
      "--temperature", "--temp", "--top-p", "--top-k", "--max-tokens",
      "--hlg-sampling", "--hlg-width", "--hlg-shoulder", "--hlg-toe", "--hlg-pivot-offset",
    ]);
    const OURS_BOOL = new Set(["--force-wire", "--expert-offload", "--no-open", "--l1", "--l2", "--l3"]);
    const passthrough: string[] = [];
    for (let i = 1; i < argv.length; i++) {
      const a = argv[i]!;
      if (OURS_VAL.has(a)) { i++; continue; }
      if (OURS_BOOL.has(a)) continue;
      passthrough.push(a);
    }

    const { parsePiArgs } = await import("./pi-terminal");
    const stdinPiped = !process.stdin.isTTY;
    const parsed = parsePiArgs(passthrough, stdinPiped);

    // Headless machine-readable runs (`-p`, `--mode json`, `--mode rpc`) must
    // keep stdout pristine for the response/JSONL stream — route our bring-up
    // logging to stderr. Interactive keeps the pretty banner on stdout.
    const quiet = parsed.mode !== "interactive";
    const origStdoutWrite = process.stdout.write.bind(process.stdout);
    if (quiet) {
      (process.stdout as unknown as { write: typeof process.stderr.write }).write =
        process.stderr.write.bind(process.stderr);
    }
    const restoreStdout = () => {
      if (quiet) (process.stdout as unknown as { write: typeof origStdoutWrite }).write = origStdoutWrite;
    };

    const rt = serverRuntimeFlags();
    const port = rt.port;
    const baseUrl = `http://localhost:${port}/v1`;
    const { probeServer } = await import("./harness-pi");
    let models = await probeServer(baseUrl);
    let startedServer = false;
    if (models) {
      console.log(`reusing running server at ${baseUrl} (${models.map((m) => m.id).join(", ")})`);
      // Server-shaping flags can't apply to a server we didn't start —
      // drop them loudly rather than silently or fatally.
      const ignored = [...OURS_VAL, ...OURS_BOOL].filter((f) => f !== "--port" && argv.includes(f));
      if (ignored.length > 0) {
        const { style } = await import("./tui");
        console.log(style.dim(`  ignoring ${ignored.join(", ")} — the running server keeps its own configuration`));
        console.log(style.dim("  (stop it or use --port <other> to start a fresh server with these flags)"));
      }
      try {
        const stats = await (await fetch(`http://localhost:${port}/stats`)).json() as
          { server?: { owner?: string } };
        if (stats.server?.owner === "pi-session") {
          console.log("note: that server belongs to another `mlx-bun pi` session and ends when it does —");
          console.log("      run `mlx-bun serve` for a persistent server.");
        }
      } catch {}
    } else {
      const { banner, step, style } = await import("./tui");
      banner(pkg.version);
      const { m, picked } = await resolveModelAuto(opt("query") ?? optShort("q"));
      if (picked)
        console.log(`  ${style.dim(`auto-picked ${m.repoId} (largest supported model that fits; override with --query)`)}`);
      const sNative = step("native runtime");
      await ensureNative(sNative);
      sNative.done("native runtime ready");
      const { createServer, loadContext } = await import("./server");
      const sLoad = step(`loading ${m.repoId}`);
      const t0 = performance.now();
      const ctx = await loadContext(m.path, m.repoId, { memoryBudgetBytes: rt.serverOptions.memoryBudgetBytes });
      await mountStartupAdapter(ctx, rt.serverOptions);
      createServer(ctx, port, { ...rt.serverOptions, owner: "pi-session" });
      startedServer = true;
      sLoad.done(`serving ${style.bold(m.repoId)} ${style.dim(`at ${baseUrl} · ready in ${(performance.now() - t0).toFixed(0)} ms`)}`);
      models = await probeServer(baseUrl);
      if (!models) { restoreStdout(); console.error("server started but /v1/models probe failed"); process.exit(1); }
    }
    const exitNote = () => {
      // The server we started lives exactly as long as the pi session — any
      // exit tears it down. A standalone server belongs to `mlx-bun serve`
      // (which we reuse and never stop).
      if (startedServer && parsed.mode === "interactive")
        console.log("pi exited — shutting down (use `mlx-bun serve` for a persistent server)");
    };

    // pi's own TUI embedded in-process — nothing to install.
    const { runEmbeddedPi } = await import("./pi-terminal");
    let message = parsed.message;
    if (parsed.mode === "print" && stdinPiped) {
      const piped = (await Bun.stdin.text()).trim();
      if (piped) message = message ? `${message}\n\n${piped}` : piped;
    }
    if (parsed.mode === "interactive")
      console.log(`launching mlx-bun pi (model ${models[0]!.id}) — /help for commands, double-Ctrl+C to exit`);
    restoreStdout();
    const code = await runEmbeddedPi({
      baseUrl,
      modelLabel: models[0]!.id,
      contextWindow: models[0]!.contextWindow,
      reasoning: models[0]!.reasoning,
      mode: parsed.mode,
      printFormat: parsed.printFormat,
      initialMessage: message,
    });
    exitNote();
    process.exit(code);
  }

  case "harness": {
    const target = positional(0);
    if (target !== "pi") {
      console.error("usage: mlx-bun harness pi [--base-url <url>] [--remove]");
      process.exit(1);
    }
    const { detectPi, installPiExtension, removePiExtension, DEFAULT_BASE_URL } =
      await import("./harness-pi");
    if (flag("remove")) {
      console.log(removePiExtension() ? "mlx-bun provider extension removed" : "nothing to remove");
      break;
    }
    const pi = detectPi();
    if (!pi.found) {
      console.error("pi not found on PATH. Install it first:");
      console.error("  curl -fsSL https://pi.dev/install.sh | sh");
      console.error("then re-run: mlx-bun harness pi");
      process.exit(1);
    }
    const { step, box, style } = await import("./tui");
    const sPi = step("detecting pi");
    sPi.done(`pi ${style.dim(`${pi.binPath}${pi.version ? ` · v${pi.version}` : ""}`)}`);
    const baseUrl = opt("base-url", DEFAULT_BASE_URL)!;
    const sExt = step("installing provider extension");
    const result = await installPiExtension(baseUrl);
    sExt.done(`provider extension installed ${style.dim(`· ${result.path}`)}`);
    const sProbe = step("probing server");
    if (result.serverReachable) sProbe.done(`server live ${style.dim(`· ${result.bakedModels.join(", ")}`)}`);
    else sProbe.done(`server not running ${style.dim(`· models discovered when pi starts against ${baseUrl}`)}`);
    console.log();
    box([
      `${style.green("●")} ${style.bold("your pi is connected to mlx-bun")}`,
      "",
      `launch   ${style.accent("pi --provider mlx-bun")}`,
      `select   ${style.dim("/model inside pi · or scope cycling:")} ${style.accent('pi --models "mlx-bun/*"')}`,
      `undo     ${style.dim("mlx-bun harness pi --remove")}`,
    ]);
    break;
  }

  case "train": {
    const { banner, step, box, style } = await import("./tui");
    const query = positional(0) ?? opt("query");
    const dataDir = opt("data");
    if (!dataDir) {
      console.error("usage: mlx-bun train <model> --data <dir>   (see: mlx-bun help train)");
      process.exit(1);
    }
    if (!(await Bun.file(`${dataDir}/train.jsonl`).exists())) {
      console.error(`no train.jsonl in ${dataDir}`);
      process.exit(1);
    }
    const method = opt("method", "orpo")!;
    if (method !== "sft" && method !== "dpo" && method !== "orpo") {
      console.error(`--method must be sft | dpo | orpo (got "${method}")`);
      process.exit(1);
    }
    const isOrpo = method === "orpo";
    // ORPO chosen-NLL scope (trainer sftScope; job.ts sft_scope). "full" =
    // paper/TRL-faithful prompt+response CE (the default); "response" =
    // response-only, bit-exact to pre-2026-07 runs. Validated here so junk
    // fails fast, before any model resolution or weight loading.
    const sftScope = opt("sft-scope");
    if (sftScope !== null && sftScope !== "full" && sftScope !== "response") {
      console.error(`--sft-scope must be full | response (got "${sftScope}")`);
      process.exit(1);
    }
    // Validated numeric flag: default if absent, hard-exit on a non-number.
    const numFlag = (name: string, dflt: number): number => {
      const v = opt(name);
      if (v == null) return dflt;
      const n = Number(v);
      if (!Number.isFinite(n)) { console.error(`--${name} expects a number (got "${v}")`); process.exit(1); }
      return n;
    };

    banner(pkg.version);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");

    const { m, picked } = await resolveModelAuto(query);

    // Detect Gemma/e4b and set its required training env flags BEFORE the
    // trainer is imported (perfKernelEnabled / fused-gelu read them lazily at
    // forward time, so setting them here — like the launcher — takes effect).
    const isGemma = (await Bun.file(`${m.path}/config.json`).text()).toLowerCase().includes("gemma");
    if (isGemma) {
      process.env.MLX_BUN_PERF_KERNEL ??= "0";
      process.env.MLX_BUN_FUSED_GELU ??= "0";
    }

    const modelTag = isGemma ? "e4b" : "cpm5";
    const adapter = opt("adapter") ?? `${process.env.HOME}/.cache/mlx-bun/mlx-bun-finetunes/${method}-${modelTag}`;
    const iters = numFlag("iters", 100);
    const seq = numFlag("seq", isGemma ? 8192 : 4096);
    const seg = flag("no-segment") ? 0 : numFlag("seg", isOrpo ? 2 : 0);
    const saveEvery = numFlag("save-every", 0);
    const flashOn = !flag("no-flash");
    const prefixOn = !flag("no-prefix");
    const resume = opt("resume") ?? "";

    // Build the snake_case submit record — the exact shape the server hands to
    // the finetune job runner (src/train/job.ts parseConfig).
    const cfg: Record<string, unknown> = {
      model_dir: m.path,
      data_dir: dataDir,
      adapter_path: adapter,
      method,
      rank: numFlag("rank", isOrpo ? 16 : 8),
      scale: numFlag("scale", isOrpo ? 2.0 : 1.0),
      rank_scaling: "by_bits",
      num_layers: -1,
      iters,
      learning_rate: numFlag("lr", isOrpo ? 1e-5 : method === "dpo" ? 5e-5 : 2e-4),
      max_seq_length: seq,
      batch_size: numFlag("batch", 1),
      grad_accumulation_steps: numFlag("grad-accum", 1),
      seed: numFlag("seed", 0),
      steps_per_report: 1,
      steps_per_eval: saveEvery > 0 ? saveEvery : 1_000_000,
      save_checkpoints: saveEvery > 0,
      segment_size: seg,
      grad_clip_norm: numFlag("grad-clip", 1.0),
      val_max_examples: numFlag("val-size", 256),
      warm_start_adapter: resume,
      ...(sftScope ? { sft_scope: sftScope } : {}),
      ...(isOrpo ? {
        orpo_lambda: numFlag("lambda", 0.1),
        orpo_lr_schedule: "cosine",
        orpo_warmup_iters: Math.min(10, Math.floor(iters / 10)),
        orpo_chunk_size: 512,
        orpo_flash_ce: flashOn,
        orpo_fused_ce: !flashOn,
        orpo_prefix_shared: prefixOn,
      } : {}),
    };

    // Pre-flight: dataset counts + detected format (bail before loading the model).
    const { inspectDataset } = await import("./train/job");
    const ds = await inspectDataset(dataDir);
    if (!ds.ok) { console.error(`dataset: ${ds.error}`); process.exit(1); }

    const planLines = [
      `${style.green("●")} ${style.bold(`train ${method}`)} ${style.dim(`· ${m.repoId}${picked ? " (auto-picked)" : ""}${isGemma ? " · e4b env set" : ""}`)}`,
      "",
      `data       ${style.bold(`${ds.n_train} train`)}${ds.n_valid ? ` · ${ds.n_valid} valid` : ""} ${style.dim(`· format ${ds.format}`)}`,
      `loop       ${style.dim(`iters ${iters} · lr ${cfg.learning_rate} · rank ${cfg.rank} · scale ${cfg.scale} · seq ${seq} · batch ${cfg.batch_size}`)}`,
    ];
    if (isOrpo)
      planLines.push(
        `head       ${style.dim(flashOn ? "flash-CCE Metal ([M,vocab]-free)" : "MLX fused linear-CE")}`,
        `stack      ${style.dim(`prefix-share ${prefixOn ? "on" : "off"} · segmented ${seg > 0 ? `${seg}/seg` : "off"} · λ ${cfg.orpo_lambda}`)}`,
        `stability  ${style.dim(`grad-clip ${cfg.grad_clip_norm || "off"} · val-size ${cfg.val_max_examples}${(cfg.grad_accumulation_steps as number) > 1 ? ` · grad-accum ${cfg.grad_accumulation_steps} (eff batch ${(cfg.batch_size as number) * (cfg.grad_accumulation_steps as number)})` : ""}`)}`,
      );
    else planLines.push(`stack      ${style.dim(`segmented ${seg > 0 ? `${seg}/seg` : "off"}`)}`);
    if (resume) planLines.push(`warm-start ${style.dim(`from ${resume} (weights only)`)}`);
    if (saveEvery > 0) planLines.push(`checkpoint ${style.dim(`every ${saveEvery} steps`)}`);
    planLines.push("", `adapter    ${style.dim(adapter)}`);
    console.log();
    box(planLines);
    console.log();
    console.log(`  ${style.dim("watch live (other tab):")} ${style.accent(`mlx-bun train-watch ${adapter}`)}`);
    console.log();

    if (flag("dry-run")) { console.log(`  ${style.dim("dry run — not training.")}`); break; }

    // Run the finetune job runner IN-PROCESS (foreground), streaming metrics to
    // the terminal — the same runner the server drives via submitSubprocess.
    // Run long jobs detached from your own shell:  nohup mlx-bun train … &
    const { finetuneRunner } = await import("./train/job");
    const { peakMemory, resetPeakMemory } = await import("./mlx/ffi");
    const losses: number[] = [];
    const stepMs: number[] = [];
    let lastStepT = Date.now();
    resetPeakMemory();
    const emit = (e: JobEvent) => {
      if (e.type === "stage" && e.message) console.log(`  ${style.dim("·")} ${e.message}`);
      else if (e.type === "metric" && e.kind === "train") {
        const now = Date.now(); stepMs.push(now - lastStepT); lastStepT = now;
        losses.push(e.loss);
        const n = losses.length;
        if (n <= 3 || n % 10 === 0)
          console.log(`  step ${n}/${iters}: loss ${style.bold(e.loss.toFixed(4))} ${style.dim(`(${(stepMs[stepMs.length - 1]! / 1000).toFixed(1)}s/step · peak ${gb(peakMemory())})`)}`);
      }
    };
    try {
      await finetuneRunner(emit, cfg);
    } catch (err) {
      console.error(`\n  training failed: ${err instanceof Error ? err.message : String(err)}`);
      process.exit(1);
    }
    const finite = losses.every((l) => Number.isFinite(l));
    const sorted = stepMs.slice(1).sort((a, b) => a - b);
    const med = sorted[Math.floor(sorted.length / 2)] ?? stepMs[0] ?? 0;
    console.log();
    box([
      `${style.green("●")} ${style.bold("training complete")} ${style.dim(`· ${losses.length} steps`)}`,
      "",
      `loss       ${style.bold(`${losses[0]?.toFixed(4) ?? "—"} → ${losses[losses.length - 1]?.toFixed(4) ?? "—"}`)}${finite ? "" : "  (NON-FINITE!)"}`,
      `speed      ${style.dim(`${(med / 1000).toFixed(1)}s/step median · peak ${gb(peakMemory())}`)}`,
      "",
      `adapter    ${style.bold(adapter)}`,
      `serve it   ${style.accent(`mlx-bun serve ${m.repoId} --adapter ${adapter}`)}`,
    ]);
    break;
  }

  case "train-watch": {
    // Live mactop-style dashboard for a training run: tails <adapter>/metrics.jsonl.
    const dir = positional(0) ?? opt("adapter")
      ?? `${process.env.HOME}/.cache/mlx-bun/mlx-bun-finetunes/orpo-cpm5`;
    const { runWatch } = await import("./train/watch");
    await runWatch(dir);
    break;
  }

  case "fuse": {
    // mlx_lm.fuse counterpart over our native machinery (src/train/fuse.ts):
    // fold a LoRA adapter into the base weights → standalone snapshot.
    const unsupported = ["--de-quantize", "--dequantize", "--export-gguf", "--gguf-path", "--upload-repo"]
      .filter((f) => argv.includes(f));
    if (unsupported.length > 0) {
      console.error(`${unsupported.join(", ")}: not supported (see: mlx-bun help fuse)`);
      process.exit(1);
    }
    const modelArg = positional(0) ?? opt("model");
    if (!modelArg) {
      console.error("usage: mlx-bun fuse <model-query-or-path> --adapter <dir> [--save-path <dir>]");
      process.exit(1);
    }
    const adapterDir = opt("adapter") ?? opt("adapter-path") ?? "adapters";
    const savePath = opt("save-path") ?? "fused_model";
    const { existsSync } = await import("node:fs");
    if (!existsSync(adapterDir)) {
      console.error(`adapter dir not found: ${adapterDir}`);
      process.exit(1);
    }
    let modelDir = modelArg;
    if (!existsSync(`${modelArg}/config.json`)) {
      const reg = new Registry();
      if (reg.list().length === 0) await reg.scan();
      modelDir = reg.resolve(modelArg).path;
    }
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");
    const s = step(`fusing ${adapterDir} into ${modelDir}`);
    const { fuseAdapter } = await import("./train");
    try {
      const stats = await fuseAdapter(modelDir, adapterDir, savePath, (e) => s.update(e.message));
      s.done(`fused ${stats.fusedModules} module(s) ${style.dim(`· ${stats.totalTensors} tensors written`)}`);
      console.log();
      box([
        `${style.green("●")} ${style.bold("fuse complete")}`,
        "",
        `base      ${style.dim(modelDir)}`,
        `adapter   ${style.dim(adapterDir)}`,
        `model     ${style.bold(stats.outDir)}`,
        ...(stats.skippedAdapterTensors > 0
          ? [`skipped   ${style.dim(`${stats.skippedAdapterTensors} adapter tensor(s) with no matching base weight`)}`] : []),
        "",
        `serve it   ${style.accent(`mlx-bun serve ${stats.outDir}`)}`,
      ]);
    } catch (e) {
      s.fail(`fuse failed: ${e instanceof Error ? e.message : String(e)}`);
      process.exit(1);
    }
    break;
  }

  case "convert": {
    // mlx_lm.convert counterpart over our native quantize pipeline (the same
    // engine as the web /api/quantize): uniform affine 4/8-bit, or the OptiQ
    // mixed-precision path via --target-bpw.
    // --upload-repo (mlx_lm.convert parity): push the converted model to the
    // Hub afterwards, via the same engine as `mlx-bun upload`. The token is
    // resolved BEFORE any conversion work — failing after minutes of
    // quantizing because auth is missing would be cruel.
    const uploadRepo = ((): string | null => {
      if (!argv.includes("--upload-repo")) return null;
      const v = opt("upload-repo");
      if (!v || v.startsWith("-")) {
        console.error("--upload-repo expects a repo id (org/name)");
        process.exit(1);
      }
      return v;
    })();
    let uploadToken: string | null = null;
    if (uploadRepo) {
      const { getHfToken } = await import("./hf-push");
      uploadToken = getHfToken();
      if (!uploadToken) {
        console.error("--upload-repo needs a Hugging Face WRITE token and none was found —");
        console.error("run `hf auth login`, export HF_TOKEN, or save one in the web UI (Settings → Hugging Face).");
        process.exit(1);
      }
    }
    const unsupported = ["--dtype", "-d", "--dequantize", "--quant-predicate"]
      .filter((f) => argv.includes(f));
    if (unsupported.length > 0) {
      console.error(`${unsupported.join(", ")}: not supported (mixed precision: --target-bpw; see: mlx-bun help convert)`);
      process.exit(1);
    }
    const qMode = opt("q-mode", "affine")!;
    if (qMode !== "affine") {
      console.error(`--q-mode ${qMode}: only "affine" is supported`);
      process.exit(1);
    }
    const hfPath = opt("hf-path") ?? opt("model") ?? positional(0);
    if (!hfPath) {
      console.error("usage: mlx-bun convert --hf-path <repo-or-path> -q [--q-bits N] [--q-group-size N] [--mlx-path <dir>] [--target-bpw F]");
      process.exit(1);
    }
    const targetBpwRaw = opt("target-bpw");
    if (!argv.includes("-q") && !argv.includes("--quantize") && targetBpwRaw === null) {
      console.error("plain (non-quantizing) conversion is not supported yet — pass -q or --target-bpw");
      process.exit(1);
    }
    const targetBpw = targetBpwRaw !== null ? Number(targetBpwRaw) : undefined;
    if (targetBpwRaw !== null && (!Number.isFinite(targetBpw!) || targetBpw! <= 0)) {
      console.error(`--target-bpw expects a positive number (got "${targetBpwRaw}")`);
      process.exit(1);
    }
    const qBits = Number(opt("q-bits", "4"));
    if (qBits !== 4 && qBits !== 8) {
      console.error(`--q-bits must be 4 or 8 (got "${opt("q-bits")}")`);
      process.exit(1);
    }
    const qGroup = Number(opt("q-group-size", "64"));
    if (qGroup !== 32 && qGroup !== 64) {
      console.error(`--q-group-size must be 32 or 64 (got "${opt("q-group-size")}")`);
      process.exit(1);
    }
    const candidateBits = opt("candidate-bits")?.split(",").map((s) => Number(s.trim()));
    if (candidateBits && candidateBits.some((b) => !Number.isInteger(b) || b < 2 || b > 8)) {
      console.error(`--candidate-bits expects a comma list of integers in [2, 8] (got "${opt("candidate-bits")}")`);
      process.exit(1);
    }
    const mlxPath = opt("mlx-path", "mlx_model")!;
    const { existsSync } = await import("node:fs");
    if (existsSync(mlxPath)) {
      console.error(`Cannot save to the path ${mlxPath} as it already exists — delete it or pass a fresh --mlx-path.`);
      process.exit(1);
    }
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");
    // Resolve the source: local dir → itself; downloaded model → registry;
    // otherwise an HF repo id, downloaded first (the point of the verb).
    let srcDir = hfPath;
    if (!existsSync(`${hfPath}/config.json`)) {
      const reg = new Registry();
      if (reg.list().length === 0) await reg.scan();
      try {
        srcDir = reg.resolve(hfPath).path;
      } catch (e) {
        if (!/^[\w.-]+\/[\w.-]+$/.test(hfPath)) {
          console.error(e instanceof Error ? e.message : String(e));
          process.exit(1);
        }
        const { downloadModel } = await import("./download");
        const sDl = step(`downloading ${hfPath}`);
        srcDir = await downloadModel(hfPath, {
          onProgress: (file, received, total) => {
            const pct = total ? Math.floor((received / total) * 100) : 0;
            sDl.update(`${style.bold(hfPath)} ${style.dim(`· ${file} · ${gb(received)} / ${gb(total)} (${pct}%)`)}`);
          },
        });
        sDl.done(`${style.bold(hfPath)} ${style.dim("downloaded · verified")}`);
        await reg.scan();
      }
    }
    const sQ = step(
      targetBpw !== undefined
        ? `quantizing (mixed, target ${targetBpw} bpw — sensitivity sweep, ~minutes)`
        : `quantizing (${qBits}-bit, group ${qGroup})`,
    );
    const { quantizeModelDir } = await import("./quantize");
    try {
      const r = await quantizeModelDir(
        srcDir,
        mlxPath,
        {
          bits: qBits as 4 | 8,
          groupSize: qGroup as 32 | 64,
          mode: "affine",
          ...(targetBpw !== undefined ? { targetBpw } : {}),
          ...(candidateBits ? { candidateBits } : {}),
          ...(opt("calibration-mix") ? { calibrationMix: opt("calibration-mix")! } : {}),
          ...(opt("n-calibration") ? { nCalibration: Number(opt("n-calibration")) } : {}),
        },
        (e) => sQ.update(e.message),
      );
      sQ.done(`quantized ${r.nQuantized} module(s) ${style.dim(`· ${r.achievedBpw.toFixed(2)} bpw achieved`)}`);
      console.log();
      box([
        `${style.green("●")} ${style.bold("convert complete")}`,
        "",
        `source    ${style.dim(srcDir)}`,
        `model     ${style.bold(r.outDir)} ${style.dim(`· ${gb(r.write.totalSize)}`)}`,
        `quant     ${style.dim(targetBpw !== undefined ? `mixed ${r.achievedBpw.toFixed(2)} bpw (target ${targetBpw})` : `${qBits}-bit g${qGroup} affine`)}`,
        "",
        `serve it   ${style.accent(`mlx-bun serve ${r.outDir}`)}`,
      ]);
      if (uploadRepo) {
        const sUp = step(`uploading ${r.outDir} → ${uploadRepo}`);
        try {
          const { uploadFolder } = await import("./hf-push");
          const up = await uploadFolder(r.outDir, uploadRepo, {
            repoType: "model",
            token: uploadToken,
            commitMessage: "Upload with mlx-bun convert",
            onProgress: (file, sent, total) =>
              sUp.update(`${style.bold(uploadRepo)} ${style.dim(`· ${file} · ${gb(sent)} / ${gb(total)}`)}`),
          });
          sUp.done(`uploaded ${style.bold(up.url)}`);
        } catch (e) {
          sUp.fail(`upload failed: ${e instanceof Error ? e.message : String(e)}`);
          console.error(`the converted model is intact at ${r.outDir} — retry with: mlx-bun upload --path ${r.outDir} --upload-repo ${uploadRepo}`);
          process.exit(1);
        }
      }
    } catch (e) {
      sQ.fail(`convert failed: ${e instanceof Error ? e.message : String(e)}`);
      process.exit(1);
    }
    break;
  }

  case "upload": {
    // mlx_lm.upload counterpart (same flag names: --path, --upload-repo) over
    // our native push-to-hub (src/hf-push.ts — the exact engine the web
    // /api/{quantize,finetune,dataset}/push routes call). Model-free until
    // the network: everything before uploadFolder is arg + token validation.
    const dir = opt("path", "mlx_model")!; // mlx_lm.upload's --path default
    const repo = ((): string | null => {
      const v = opt("upload-repo");
      return v && !v.startsWith("-") ? v : null;
    })();
    if (!repo) {
      console.error("usage: mlx-bun upload --path <model-dir> --upload-repo <org/repo> [--private]");
      process.exit(1);
    }
    const { existsSync, statSync } = await import("node:fs");
    if (!existsSync(dir) || !statSync(dir).isDirectory()) {
      console.error(`not a directory: ${dir} (pass the model directory via --path)`);
      process.exit(1);
    }
    const { getHfToken, uploadFolder } = await import("./hf-push");
    const token = getHfToken();
    if (!token) {
      console.error("no Hugging Face token found — uploading needs a WRITE token from one of:");
      console.error("  hf auth login                  (~/.cache/huggingface/token)");
      console.error("  export HF_TOKEN=hf_…");
      console.error("  web UI Settings → Hugging Face (~/.mlx-bun/hf.json)");
      process.exit(1);
    }
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    const s = step(`uploading ${dir} → ${repo}`);
    try {
      const r = await uploadFolder(dir, repo, {
        repoType: "model",
        private: flag("private"),
        token,
        commitMessage: "Upload with mlx-bun",
        onProgress: (file, sent, total) =>
          s.update(`${style.bold(repo)} ${style.dim(`· ${file} · ${gb(sent)} / ${gb(total)}`)}`),
      });
      s.done(`uploaded ${style.bold(repo)}`);
      console.log();
      box([
        `${style.green("●")} ${style.bold("upload complete")}`,
        "",
        `source    ${style.dim(dir)}`,
        `repo      ${style.url(r.url)}${flag("private") ? style.dim(" · private") : ""}`,
        "",
        `get it back anywhere:  ${style.accent(`mlx-bun get ${repo}`)}`,
      ]);
    } catch (e) {
      s.fail(`upload failed: ${e instanceof Error ? e.message : String(e)}`);
      process.exit(1);
    }
    break;
  }

  case "perplexity": {
    // mlx_lm.perplexity counterpart (methodology reproduced exactly — see
    // src/eval/perplexity.ts) over a LOCAL dataset file; never downloads data.
    const modelArg = positional(0) ?? opt("model") ?? opt("query");
    const dataPath = opt("data-path");
    if (!modelArg || !dataPath) {
      console.error("usage: mlx-bun perplexity <model-query-or-path> --data-path <file.txt|file.jsonl> [--sequence-length 512] [--num-samples 256] [--batch-size 8] [--seed 123]");
      process.exit(1);
    }
    const { existsSync } = await import("node:fs");
    if (!existsSync(dataPath)) {
      console.error(`data file not found: ${dataPath} (a local .txt or .jsonl — HF datasets are not downloaded)`);
      process.exit(1);
    }
    const intFlag = (name: string, dflt: number, lo: number): number => {
      const v = Number(opt(name, String(dflt)));
      if (!Number.isInteger(v) || (v < lo && v !== -1)) {
        console.error(`--${name} expects an integer >= ${lo} (got "${opt(name)}")`);
        process.exit(1);
      }
      return v;
    };
    const seqLen = intFlag("sequence-length", 512, 2);
    const numSamples = intFlag("num-samples", 256, 1); // -1 = all
    const batchSize = intFlag("batch-size", 8, 1);
    const seed = intFlag("seed", 123, 0);
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    const sNative = step("native runtime");
    await ensureNative(sNative);
    sNative.done("native runtime ready");
    let modelDir = modelArg;
    if (!existsSync(`${modelArg}/config.json`)) {
      const reg = new Registry();
      if (reg.list().length === 0) await reg.scan();
      modelDir = reg.resolve(modelArg).path;
    }
    // Gemma/e4b: same forward env flags the trainer sets (full-sequence pass).
    if ((await Bun.file(`${modelDir}/config.json`).text()).toLowerCase().includes("gemma")) {
      process.env.MLX_BUN_PERF_KERNEL ??= "0";
      process.env.MLX_BUN_FUSED_GELU ??= "0";
    }
    const sLoad = step(`loading ${modelDir}`);
    const { Weights } = await import("./weights");
    const { createModel } = await import("./model/factory");
    const { loadTokenizer } = await import("./tokenizer");
    const { peakMemory, resetPeakMemory } = await import("./mlx/ffi");
    const config = await loadModelConfig(modelDir);
    const model = createModel(await Weights.open(modelDir), config);
    const tok = await loadTokenizer(modelDir);
    sLoad.done(`model loaded ${style.dim(`· ${modelDir}`)}`);

    const { parseSamples, packRows, evalPpl } = await import("./eval/perplexity");
    const sData = step(`tokenizing ${dataPath}`);
    const samples = parseSamples(await Bun.file(dataPath).text(), dataPath);
    const rows = packRows(
      samples.map((t) => tok.encode(t)),
      { sequenceLength: seqLen, numSamples, seed },
    );
    if (rows.length === 0) {
      sData.fail(`dataset too small: fewer than ${seqLen} tokens (need at least one full row)`);
      process.exit(1);
    }
    sData.done(`${rows.length} row(s) × ${seqLen} tokens ${style.dim(`· ${samples.length} sample(s), seed ${seed}`)}`);

    const sEval = step(`evaluating (batch ${batchSize})`);
    resetPeakMemory();
    const t0 = performance.now();
    const r = evalPpl(model, rows, batchSize, (done, total) =>
      sEval.update(`batch ${done}/${total}`));
    const seconds = (performance.now() - t0) / 1000;
    sEval.done(`evaluated ${r.tokens.toLocaleString()} tokens ${style.dim(`in ${seconds.toFixed(1)} s`)}`);
    console.log();
    box([
      `${style.green("●")} ${style.bold("perplexity")} ${style.dim(`· ${modelDir.split("/snapshots/")[0]?.split("/").at(-1) ?? modelDir}`)}`,
      "",
      `ppl        ${style.green(style.bold(r.ppl.toFixed(3)))} ${style.dim(`± ${r.standardError.toFixed(3)}`)}`,
      `mean CE    ${style.bold(r.meanLoss.toFixed(4))} ${style.dim("nats/token")}`,
      `tokens     ${style.bold(r.tokens.toLocaleString())} ${style.dim(`· ${r.rows} row(s) × ${seqLen}`)}`,
      `speed      ${style.dim(`${(r.tokens / seconds).toFixed(0)} tok/s · peak ${gb(peakMemory())}`)}`,
    ]);
    break;
  }

  // `setup` is a true alias for `memory` — same handler, same subcommands
  // (`mlx-bun setup init` == `mlx-bun memory init`; the handler reads the
  // subcommand from argv[1] onward, identical for both spellings).
  case "setup":
  case "memory": {
    const { style, box, step, banner } = await import("./tui");
    const {
      vaultRoot, vaultStatus, setupVault, importArticlesFrom, commitVault,
      listMemoryDocuments, readArticle, resolveArticlePath, searchArticles,
      parseToc, extractSection, getArticleLinks,
    } = await import("./memory/vault");
    const { installSchedule, removeSchedule, scheduleStatus, parseAt } = await import("./memory/schedule");
    const root = vaultRoot();
    const fmtAt = (a: { hour: number; minute: number }) => `${String(a.hour).padStart(2, "0")}:${String(a.minute).padStart(2, "0")}`;
    const openMemoryTarget = async (targetPath = root): Promise<"obsidian" | "fallback"> => {
      // For articles, Obsidian's URL handler opens the exact file inside the
      // vault. For the vault root, `open -a Obsidian <folder>` opens the folder
      // as a vault. Both fall back to macOS `open` if Obsidian is unavailable.
      if (targetPath !== root) {
        const uri = `obsidian://open?path=${encodeURIComponent(targetPath)}`;
        const byUri = Bun.spawn(["open", uri], { stdout: "ignore", stderr: "ignore" });
        if ((await byUri.exited) === 0) return "obsidian";
      } else {
        const byApp = Bun.spawn(["open", "-a", "Obsidian", root], { stdout: "ignore", stderr: "ignore" });
        if ((await byApp.exited) === 0) return "obsidian";
      }
      const fallback = Bun.spawn(["open", targetPath], { stdout: "ignore", stderr: "ignore" });
      await fallback.exited;
      return "fallback";
    };

    // Words after `memory`, minus flags: [subcommand, ...query].
    const words = argv.slice(1).filter((a) => !a.startsWith("-"));
    const sub = (words[0] ?? "status").toLowerCase();
    const rest = words.slice(1).join(" ").trim();

    // TTY-only line prompt; in a non-interactive shell returns the default so
    // the wizard degrades to a non-destructive no-op rather than hanging.
    const ask = async (q: string, dflt = ""): Promise<string> => {
      if (!process.stdin.isTTY) return dflt;
      const { createInterface } = await import("node:readline/promises");
      const rl = createInterface({ input: process.stdin, output: process.stdout });
      try {
        return ((await rl.question(q)).trim() || dflt);
      } finally {
        rl.close();
      }
    };
    const confirmYN = async (q: string, defaultYes: boolean): Promise<boolean> => {
      const a = (await ask(`${q} ${defaultYes ? "[Y/n]" : "[y/N]"} `)).toLowerCase();
      if (!a) return defaultYes;
      return a === "y" || a === "yes";
    };

    if (sub === "init" || sub === "setup") {
      banner(pkg.version);
      box([
        `${style.accent("●")} ${style.bold("Personal memory for your local AI")}`,
        "",
        "A wiki of Markdown articles your local assistant reads to remember",
        "your projects, people, and history across sessions. It's yours —",
        `git-tracked at ${style.dim(root)}, editable in any tool, and it`,
        "never leaves this machine.",
      ]);
      const sSetup = step("creating your wiki");
      const res = await setupVault(root);
      sSetup.done(res.alreadySetUp ? `already set up ${style.dim(`· ${root}`)}` : `wiki ready ${style.dim(`· ${root}`)}`);

      // Offer to seed from an existing vault (e.g. a lucien ~/Dreaming) so the
      // assistant has real content to read on day one, before synthesis exists.
      const { homedir } = await import("node:os");
      const { join } = await import("node:path");
      const { readdir } = await import("node:fs/promises");
      const seedRoot = await ask(
        `\n  Seed from an existing wiki? Enter its path, or blank to skip ${style.dim(`[${join(homedir(), "Dreaming")}]`)}: `,
        "",
      );
      if (seedRoot) {
        const srcArticles = join(seedRoot.replace(/^~(?=$|[/\\])/, homedir()), "articles");
        let count = 0;
        try { count = (await readdir(srcArticles)).filter((n) => n.endsWith(".md")).length; } catch { count = 0; }
        if (count === 0) {
          console.log(style.dim(`  no articles found under ${srcArticles} — skipping import`));
        } else if (await confirmYN(`  Import ${count} article(s) from ${srcArticles}?`, true)) {
          const sImp = step(`importing ${count} article(s)`);
          const imported = await importArticlesFrom(srcArticles, root);
          await commitVault(root, `Import ${imported.length} article(s) from ${seedRoot}`);
          sImp.done(`imported ${imported.length} article(s)`);
        }
      }

      // Offer to install the nightly synthesis job (a launchd agent). The job
      // runs the real synthesis DAG (`mlx-bun memory synthesize`) — create new
      // entity articles, then the editorial wikify sweep — so installing the
      // schedule keeps your wiki current automatically. Persistent action →
      // TTY-only, defaults to no.
      let scheduled: string | null = null;
      console.log(style.dim(
        "\n  Synthesis (turning your conversations into articles) runs as a nightly job;\n" +
        "  install it now so your wiki stays current automatically.",
      ));
      if (await confirmYN("  Install the nightly synthesis job (runs in the background)?", false)) {
        const atRaw = await ask(`    At what time? 24h HH:MM ${style.dim("[03:00]")}: `, "03:00");
        const sSched = step(`installing nightly job at ${fmtAt(parseAt(atRaw))}`);
        const r = await installSchedule({ at: atRaw });
        scheduled = fmtAt(r.at);
        sSched.done(
          r.loaded
            ? `nightly job installed ${style.dim(`· ${scheduled} · ${r.plistPath}`)}`
            : `plist written ${style.dim(`· ${r.plistPath} · launchctl load failed (load it manually)`)}`,
        );
      }

      const st = await vaultStatus(root);
      console.log();
      box([
        `${style.green("●")} ${style.bold("memory is set up")} ${style.dim(`· ${st.articleCount} article(s) · ${st.referenceCount} reference doc(s)`)}`,
        "",
        `chat now   ${style.accent("mlx-bun pi")} ${style.dim("— the assistant now reads your memory automatically")}`,
        `inspect    ${style.accent("mlx-bun memory status")} ${style.dim("·")} ${style.accent("mlx-bun memory search <q>")}`,
        `browse     ${style.dim(`open ${root} in Obsidian, or any editor`)}`,
        scheduled
          ? `nightly    ${style.green("scheduled")} ${style.dim(`· ${scheduled} daily · mlx-bun memory unschedule to undo`)}`
          : `nightly    ${style.dim("not scheduled · mlx-bun memory schedule to set it up")}`,
        "",
        style.dim("Synthesis (conversations → articles) runs the full DAG: create new entity"),
        style.dim("articles, then an editorial wikify sweep. Run it now: mlx-bun memory synthesize."),
      ]);
      break;
    }

    if (sub === "status") {
      const st = await vaultStatus(root);
      if (!st.exists) {
        console.log(`no memory wiki yet at ${style.dim(root)}`);
        console.log(`set one up:  ${style.accent("mlx-bun memory init")}`);
        break;
      }
      const sched = await scheduleStatus();
      console.log();
      box([
        `${style.bold("memory")} ${style.dim(`· ${root}`)}`,
        "",
        `articles   ${style.bold(String(st.articleCount))}`,
        `reference  ${style.bold(String(st.referenceCount))} ${style.dim("read-only docs")}`,
        `git        ${st.isGitRepo ? style.green("tracked") : style.dim("not a git repo")}`,
        `synthesis  ${style.green("available")} ${style.dim("· mlx-bun memory synthesize")}`,
        `nightly    ${
          sched.installed
            ? `${sched.loaded ? style.green("scheduled") : style.accent("installed (not loaded)")} ${style.dim(`· ${sched.plistPath}`)}`
            : style.dim("not scheduled · mlx-bun memory schedule")
        }`,
        st.recentArticles.length
          ? `recent    ${st.recentArticles.slice(0, 5).map((r) => r.article).join(", ")}`
          : `recent    ${style.dim("none")}`,
      ]);
      break;
    }

    if (sub === "open" || sub === "browse") {
      const st = await vaultStatus(root);
      if (!st.exists) {
        console.log(`no memory wiki yet at ${style.dim(root)}`);
        console.log(`set one up:  ${style.accent("mlx-bun memory init")}`);
        break;
      }
      let targetPath = root;
      let label = "memory";
      if (rest) {
        try {
          targetPath = await resolveArticlePath(root, rest);
          label = rest.endsWith(".md") ? rest.slice(0, -3) : rest;
        } catch (err) {
          console.error(err instanceof Error ? err.message : String(err));
          console.error(`try:  ${style.accent(`mlx-bun memory search ${rest}`)}`);
          process.exit(1);
        }
      }
      const where = await openMemoryTarget(targetPath);
      console.log(
        where === "obsidian"
          ? `opened ${label} in Obsidian: ${targetPath}`
          : `opened ${label}: ${targetPath}`,
      );
      break;
    }

    // Independent, chronological, resumable STAGE WORKERS. Each pulls its own
    // eligible work from the DB by state, processes a bounded batch, persists,
    // and exits — so a user can run the four as four separate processes on
    // different slices concurrently (GPU/memory allowing). `synthesize` (below)
    // remains the FULL DAG; these are its decomposed pieces.
    if (sub === "segment" || sub === "extract" || sub === "route" || sub === "synthesize-stage" || sub === "stage-synthesize") {
      const stages = await import("./memory/stages");
      const { MemoryStore } = await import("./memory/db");
      const limit = opt("limit") ? parseInt(opt("limit")!, 10) : undefined;
      const convsRaw = opt("convs");
      const convIds = convsRaw ? convsRaw.split(",").map((s) => s.trim()).filter(Boolean) : undefined;
      const onEvent = (e: import("./memory/pipeline").SynthesisEvent) => {
        if (e.type === "stage") console.log(`  ${style.dim("·")} ${e.message}`);
        else console.log(`  ${e.message}`);
      };
      const store = new MemoryStore();
      console.log();
      try {
        if (sub === "segment") {
          const r = await stages.runSegmentStage(store, { convIds, limit, onEvent });
          console.log(style.dim(`\n  segment: ${r.valid} segmented, ${r.chunks} chunks, ${r.skipped} skipped, ${r.errored} errored`));
        } else if (sub === "extract") {
          const r = await stages.runExtractStage(store, { convIds, limit, onEvent });
          console.log(style.dim(`\n  extract: ${r.extracted} chunk(s) extracted, ${r.remaining} still pending`));
        } else if (sub === "route") {
          const r = await stages.runRouteStage(store, { convIds, onEvent });
          console.log(style.dim(`\n  route: ${r.decisions.length} entities — ${r.createEligible} create-eligible, ${r.captured.length} captured`));
        } else {
          const r = await stages.runSynthesizeStage(store, { root, convIds, limit, onEvent });
          console.log(style.dim(`\n  synthesize: ${r.created.length} created, ${r.patched.length} patched, ${r.skippedByGate.length} gated`));
        }
      } finally {
        store.close();
      }
      break;
    }

    // CROSS-LINK — the dedicated edge-building stage. Deterministic + idempotent:
    // inline-link first mentions of other articles + rebuild each ## See also from
    // mentions + co-occurrence. No model required.
    if (sub === "link") {
      const { runLinkStage } = await import("./memory/crosslink");
      const { MemoryStore } = await import("./memory/db");
      const limit = opt("limit") ? parseInt(opt("limit")!, 10) : undefined;
      const store = new MemoryStore();
      console.log();
      try {
        const r = await runLinkStage(store, {
          root,
          limit,
          onEvent: (e) => console.log(e.type === "stage" ? `  ${style.dim("·")} ${e.message}` : `  ${e.message}`),
        });
        console.log(
          style.dim(
            `\n  link: ${r.linked.length} article(s) linked · ${r.mentionEdges} mention edge(s) · ${r.skippedByGate.length} gated`,
          ),
        );
      } finally {
        store.close();
      }
      break;
    }

    if (sub === "synthesize" || sub === "pipeline" || sub === "all") {
      const { runSynthesis } = await import("./memory/pipeline");
      const dryRun = flag("dry-run");
      console.log();
      const summary = await runSynthesis(
        { since: opt("since") ?? undefined, model: opt("model") ?? undefined, dryRun },
        (e) => {
          if (e.type === "stage") console.log(`  ${style.dim("·")} ${e.message}`);
          else console.log(`  ${e.message}`);
        },
      );
      console.log(style.dim(`\n  ${summary.note}`));
      break;
    }

    if (sub === "schedule") {
      const atRaw = opt("at") ?? "03:00";
      const r = await installSchedule({ at: atRaw });
      console.log();
      box([
        r.loaded
          ? `${style.green("●")} ${style.bold("nightly synthesis scheduled")} ${style.dim(`· ${fmtAt(r.at)} daily`)}`
          : `${style.accent("●")} ${style.bold("plist written, but launchctl load failed")}`,
        "",
        `plist      ${style.dim(r.plistPath)}`,
        `runs       ${style.dim("mlx-bun memory synthesize (full DAG: create + wikify sweep)")}`,
        `undo       ${style.accent("mlx-bun memory unschedule")}`,
      ]);
      break;
    }

    if (sub === "unschedule") {
      const removed = await removeSchedule();
      console.log(removed ? "nightly synthesis job removed" : "no nightly job was installed");
      break;
    }

    if (sub === "list") {
      const docs = await listMemoryDocuments(root);
      if (docs.length === 0) { console.log("no articles or reference docs yet"); break; }
      for (const s of docs) console.log(`  ${s}`);
      const refs = docs.filter((s) => s.startsWith("Reference/")).length;
      console.log(style.dim(`\n  ${docs.length - refs} article(s), ${refs} read-only reference doc(s)`));
      break;
    }

    if (sub === "search") {
      if (!rest) { console.error("usage: mlx-bun memory search <query>"); process.exit(1); }
      const { summaries, hits } = await searchArticles(root, rest, { limit: 12 });
      if (summaries.length === 0) { console.log(`no articles match "${rest}"`); break; }
      console.log();
      for (const s of summaries.slice(0, 15)) {
        const terms = s.matched_terms?.length ? style.dim(` [${s.matched_terms.join(", ")}]`) : "";
        console.log(`  ${style.bold(s.article)} ${style.dim(`· ${s.occurrences} hit(s)`)}${terms}`);
      }
      if (hits.length) {
        console.log(style.dim("\n  sample lines:"));
        for (const h of hits.slice(0, 6)) {
          const where = h.anchor ? `${h.article}#${h.anchor}` : h.article;
          console.log(`  ${style.dim(`${where}:${h.line}`)}  ${h.excerpt}`);
        }
      }
      console.log(style.dim(`\n  read one:  mlx-bun memory read ${summaries[0]!.article}`));
      break;
    }

    if (sub === "toc") {
      if (!rest) { console.error("usage: mlx-bun memory toc <article>"); process.exit(1); }
      try {
        const { content } = await readArticle(root, rest);
        const toc = parseToc(content);
        if (toc.length === 0) { console.log("no headings"); break; }
        for (const h of toc) console.log(`${"  ".repeat(Math.max(0, h.depth - 1))}- ${h.title}  ${style.dim(`#${h.anchor}`)}`);
      } catch (err) {
        console.error(err instanceof Error ? err.message : String(err));
        console.error(`try:  ${style.accent(`mlx-bun memory search ${rest}`)}`);
        process.exit(1);
      }
      break;
    }

    if (sub === "section") {
      const [article, anchorRaw] = words.slice(1);
      const anchor = anchorRaw?.replace(/^#/, "");
      if (!article || !anchor) { console.error("usage: mlx-bun memory section <article> <anchor>"); process.exit(1); }
      try {
        const { content } = await readArticle(root, article);
        const section = extractSection(content, anchor);
        if (!section) { console.error(`no section #${anchor} in ${article}`); console.error(`try:  ${style.accent(`mlx-bun memory toc ${article}`)}`); process.exit(1); }
        console.log(section);
      } catch (err) {
        console.error(err instanceof Error ? err.message : String(err));
        console.error(`try:  ${style.accent(`mlx-bun memory search ${article}`)}`);
        process.exit(1);
      }
      break;
    }

    if (sub === "links") {
      if (!rest) { console.error("usage: mlx-bun memory links <article>"); process.exit(1); }
      try {
        const { outbound, inbound } = await getArticleLinks(root, rest);
        console.log(`${style.bold("outbound")}:`);
        console.log(outbound.length ? outbound.map((s) => `  ${s}`).join("\n") : "  (none)");
        console.log(`\n${style.bold("inbound")}:`);
        console.log(inbound.length ? inbound.map((s) => `  ${s}`).join("\n") : "  (none)");
      } catch (err) {
        console.error(err instanceof Error ? err.message : String(err));
        console.error(`try:  ${style.accent(`mlx-bun memory search ${rest}`)}`);
        process.exit(1);
      }
      break;
    }

    if (sub === "read") {
      if (!rest) { console.error("usage: mlx-bun memory read <article>"); process.exit(1); }
      try {
        const { content } = await readArticle(root, rest);
        console.log(content);
      } catch (err) {
        console.error(err instanceof Error ? err.message : String(err));
        console.error(`try:  ${style.accent(`mlx-bun memory search ${rest}`)}`);
        process.exit(1);
      }
      break;
    }


    // Unknown subcommand: help on stdout, but a FAILURE exit — scripts and
    // launchd jobs must be able to detect typos (printHelp would exit 0).
    console.error(`unknown: mlx-bun memory ${sub}`);
    console.log(renderHelp(HELP.memory!));
    process.exit(1);
  }

  default:
    printHelp(cmd);
}
