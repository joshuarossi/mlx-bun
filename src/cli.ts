#!/usr/bin/env bun
// mlx-bun CLI: the appliance interface.
//
//   mlx-bun get <org/repo> [--revision main]   resumable verified download
//   mlx-bun scan                          index the HF cache
//   mlx-bun ls [--vision] [--max-size 10GB] [query]
//   mlx-bun fit <query> [--ctx 32768] [--skus]
//   mlx-bun serve [query] [--port 8090] [--memory-budget GB]
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
  fit        Will a model fit this machine? Memory + speed assessment
  scan       Re-index the Hugging Face cache
  harness    Connect your own pi install to the local mlx-bun server
  train      Fine-tune a LoRA adapter (SFT / DPO / ORPO) on your data
  memory     Set up + manage your local AI's personal wiki memory
  benchmark  Measure decode/prefill speed of OUR stack on this machine
  evals      Show recent benchmark runs (all stacks)
  help       Show help for a command (also: mlx-bun <command> --help)

Options:
  -h, --help     Show help
  -v, --version  Show version

Examples:
  mlx-bun                          # download (first run) + serve + open the chat UI
  mlx-bun pi                       # start (download if needed) and chat with an agent
  mlx-bun serve 12B                # serve the 12B; status page at http://localhost:8090/
  mlx-bun train e4b --data ./prefs # ORPO LoRA fine-tune on {prompt,chosen,rejected} data
  mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit`;

const SERVER_FLAGS = `Server options:
  --host <addr>             Interface to bind  [default: all interfaces;
                            use 127.0.0.1 for loopback-only]
  --port <n>                Listen port  [default: 8090]
  --memory-budget <GB>      Admission-control memory budget; requests that
                            cannot fit are rejected instead of crashing the
                            GPU  [default: machine RAM × 0.75, check-only]
  --prompt-cache <GB>       Prompt (KV) cache byte cap  [default: 2 GB]
  --batch <n>               Max concurrent requests batched through the
                            mlx-lm-parity engine  [default: 1 = serial].
                            >1 opts the whole server into bf16 continuous
                            batching (= mlx-lm B=N); see --kv-quant.
  --no-open                 Don't open the chat UI in your browser on start.
                            By default an interactive terminal opens
                            http://<host>:<port>/#/chat once the server is up.

Model & quality:
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
  --top-k <n>               sends none) inherits them
                            [default: the model's generation_config.json]
  --hlg-sampling on|off     Piecewise tone-curve sampling (HLG): rolls off the
                            top, boosts the mids, gentles the tail. Gain folds
                            from --temperature. [default: off]
                            See docs/design/hlg-sampling.md
  --hlg-width <nats>        HLG mid-region half-width  [default: 4]
  --hlg-shoulder <nats>     HLG highlight rolloff scale  [default: 4]
  --hlg-toe <nats>          HLG shadow rolloff scale  [default: 6]
  --hlg-pivot-offset <nats> HLG pivot: nats below the top token  [default: 6]

Performance levers (A/B levers; defaults are the measured winners):
  --compiled-decode on|off  Compiled decode graphs  [default: on]
  --perf-kernel on|off      Fused quantized-KV decode-SDPA Metal kernel
                            (perf side of the compat A/B)  [default: on]
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
                       Omitted: serves e4b (the default), else the largest
                       downloaded model that fits. Fresh install: downloads a
                       small starter model first, then e4b in the background
                       (default on next run).

${SERVER_FLAGS}

Endpoints: /v1/chat/completions, /v1/messages, /v1/responses, /v1/models,
/v1/adapters, /stats, /fit, /library, /downloads — status page at /,
browser chat at /chat`,

  get: `mlx-bun get — download a model from Hugging Face

Usage: mlx-bun get <org/repo> [options]

Options:
  --revision <rev>     Git revision  [default: main]

Resumable (Range requests against partial blobs) and verified (sha256
for LFS blobs). Re-running after an interruption continues where it
stopped. Uses HF_TOKEN / hf auth login credentials when present.`,

  ls: `mlx-bun ls — list downloaded models

Usage: mlx-bun ls [query] [options]

Options:
  --vision             Only models with a vision sidecar
  --max-size <size>    Filter by weight size (e.g. 10GB, 800MB)`,

  fit: `mlx-bun fit — will this model fit on this machine?

Usage: mlx-bun fit <query> [options]

Options:
  --ctx <tokens>       Context size to assess  [default: 32768]
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
  --base-url <url>     Server base URL  [default: http://localhost:8090/v1]
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

  [query]              Model to benchmark  [default: auto-pick]

Options:
  --tokens <n>         Tokens to decode per run  [default: 256]
  --runs <n>           Runs (median reported)  [default: 3]
  --prompt-tokens <n>  Pad the prompt to ~n tokens (long-context decode)
  --kv-quant <mode>    config | off | 4 | 8  [default: off, the
                       historical baseline]

Performance levers (--compiled-decode, --perf-kernel, --fused-decode,
--fused-sdpa) apply to the run — A/B by running twice.`,

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
  --lambda <f>         ORPO odds-ratio weight  [default: 0.1]
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
Run long jobs detached from your own shell:  nohup mlx-bun train … &`,
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
  synthesize         Run the synthesis pipeline now (--since, --model,
                     --dry-run). STUBBED — a no-op until M1 lands.
  schedule           Install the nightly launchd job (--at HH:MM [03:00])
  unschedule         Remove the nightly launchd job

The read path is live: the assistant reads a wiki you set up by hand or
import during \`memory init\`. Ask the assistant to "open my memory" or run
\`mlx-bun memory open\` to browse it in Obsidian/Finder, or
\`mlx-bun memory open <article>\` to jump to a specific page. Synthesis
(conversations → articles) is stubbed; scheduling is real, so the nightly
job is wired and ready and starts producing articles the moment synthesis
lands.`,
};

HELP.bench = HELP.benchmark!;
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
function serverRuntimeFlags(): { port: number; serverOptions: import("./server").ServerOptions } {
  const onOff = (name: string): boolean | null => {
    const v = opt(name);
    if (v === null) return null;
    if (v === "on" || v === "1" || v === "true") return true;
    if (v === "off" || v === "0" || v === "false") return false;
    console.error(`--${name} expects on|off (got "${v}")`);
    process.exit(1);
  };
  const cd = onOff("compiled-decode");
  if (cd !== null) process.env.MLX_BUN_COMPILED_DECODE = cd ? "1" : "0";
  const pk = onOff("perf-kernel");
  if (pk !== null) process.env.MLX_BUN_PERF_KERNEL = pk ? "1" : "0";
  const fd = onOff("fused-decode");
  if (fd !== null) process.env.MLX_BUN_FUSED_DECODE = fd ? "1" : "0";
  const fs = onOff("fused-sdpa");
  if (fs !== null) process.env.MLX_BUN_NO_FUSED_SDPA = fs ? "0" : "1"; // inverted env
  if (flag("force-wire")) process.env.MLX_BUN_FORCE_WIRE = "1";

  const serverOptions: import("./server").ServerOptions = {};
  const budgetGB = Number(opt("memory-budget", "0"));
  if (budgetGB > 0) serverOptions.memoryBudgetBytes = budgetGB * 1e9;
  const pcGB = Number(opt("prompt-cache", "0"));
  if (pcGB > 0) serverOptions.promptCacheBytes = pcGB * 2 ** 30;
  // --batch N: max concurrent requests batched through the mlx-lm-parity
  // engine (N=1 = today's serial path). --decode-concurrency is accepted as
  // an mlx_lm.server-compatible alias (drop-in).
  const batchRaw = opt("batch") ?? opt("decode-concurrency");
  if (batchRaw !== null) {
    const n = Number(batchRaw);
    if (!Number.isInteger(n) || n < 1) {
      console.error(`--batch expects an integer >= 1 (got "${batchRaw}")`);
      process.exit(1);
    }
    serverOptions.batch = n;
  }
  const kv = opt("kv-quant");
  if (kv === "off") serverOptions.kvQuant = "off";
  else if (kv === "config") serverOptions.kvQuant = "config";
  else if (kv) {
    const bits = Number(kv);
    if (![4, 8].includes(bits)) { console.error(`--kv-quant expects config|off|4|8 (got "${kv}")`); process.exit(1); }
    serverOptions.kvQuant = bits;
  }
  const host = opt("host");
  if (host) serverOptions.hostname = host;
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
  const temp = numFlag("temperature", 0, 5);
  if (temp !== null) serverOptions.defaultTemperature = temp;
  const topP = numFlag("top-p", 0, 1);
  if (topP !== null) serverOptions.defaultTopP = topP;
  const topK = numFlag("top-k", 0, 1_000_000);
  if (topK !== null) serverOptions.defaultTopK = topK;
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
  return { port: Number(opt("port", "8090")), serverOptions };
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
    const repoId = positional(0);
    if (!repoId || !repoId.includes("/")) {
      console.error("usage: mlx-bun get <org/repo> [--revision main]");
      process.exit(1);
    }
    const { downloadModel } = await import("./download");
    const { step, style } = await import("./tui");
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
    const models = reg.list({
      vision: flag("vision") ? true : undefined,
      maxBytes: maxSize ? parseSize(maxSize) : undefined,
      query: positional(0),
    });
    if (models.length === 0) {
      console.log("no models match (try `mlx-bun scan`)");
      break;
    }
    const { table, style, h1 } = await import("./tui");
    h1("library");
    console.log();
    table(
      [
        { header: "model", paint: (c) => style.bold(c) },
        { header: "size", align: "right" },
        { header: "params", align: "right" },
        { header: "quant" },
        { header: "license", paint: (c) => style.dim(c) },
        { header: "capabilities", paint: (c) => style.dim(c) },
      ],
      models.map((m) => [
        m.repoId,
        gb(m.sizeBytes),
        m.paramCount ? `${(m.paramCount / 1e9).toFixed(1)}B` : "?",
        m.quantBits ? `${m.quantBits}-bit g${m.quantGroupSize}` : "full",
        m.license ?? "?",
        [
          isSupportedModelRecord(m.modelType, m.repoId) ? "supported" : `unsupported (${m.modelType})`,
          m.hasVisionSidecar ? "vision" : null,
          m.hasToolTemplate ? "tools" : null,
          m.hasKvConfig ? "kv-quant" : null,
        ].filter(Boolean).join(" · "),
      ]),
    );
    console.log();
    console.log(style.dim(`  ${models.length} model(s) · mlx-bun fit <query> for a memory assessment`));
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
    const server = createServer(ctx, rt.port, { ...rt.serverOptions, owner: "serve" });
    sLoad.done(`weights loaded ${style.dim(`in ${(performance.now() - t0).toFixed(0)} ms`)}`);
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
      "--compiled-decode", "--perf-kernel", "--fused-decode", "--fused-sdpa", "--thinking",
      "--temperature", "--top-p", "--top-k",
    ]);
    const OURS_BOOL = new Set(["--force-wire", "--expert-offload"]);
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
      // itself is a no-op today (synthesis is stubbed), but installing the
      // schedule now means it starts producing articles the moment M1 lands —
      // no reconfiguration. Persistent action → TTY-only, defaults to no.
      let scheduled: string | null = null;
      console.log(style.dim(
        "\n  Synthesis (turning your conversations into articles) isn't implemented yet,\n" +
        "  but you can install the nightly job now so it runs automatically once it is.",
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
        style.dim("Synthesis (conversations → articles) is stubbed for now; the scheduled"),
        style.dim("job no-ops until it lands. Add or import articles to read meanwhile."),
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
        `synthesis  ${style.dim("stubbed (M1) — not implemented yet")}`,
        `last run   ${style.dim("not available yet")}`,
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

    if (sub === "synthesize") {
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
        `runs       ${style.dim("mlx-bun memory synthesize (a no-op until synthesis lands)")}`,
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


    console.error(`unknown: mlx-bun memory ${sub}`);
    printHelp("memory");
    break;
  }

  default:
    printHelp(cmd);
}
