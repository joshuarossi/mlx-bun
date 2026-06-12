#!/usr/bin/env bun
// mlx-bun CLI: the appliance interface.
//
//   mlx-bun get <org/repo> [--revision main]   resumable verified download
//   mlx-bun scan                          index the HF cache
//   mlx-bun ls [--vision] [--max-size 10GB] [query]
//   mlx-bun fit <query> [--ctx 32768] [--skus]
//   mlx-bun serve [query] [--port 8090] [--memory-budget GB]
//   mlx-bun evals                         recent benchmark runs
//   mlx-bun harness pi [--base-url <url>] [--remove]   register as a pi provider

import { Registry } from "./registry";
import { loadModelConfig } from "./config";
import { fit, skuMatrix, thisMachine } from "./fit";
import { EvalDB } from "./evaldb";
import pkg from "../package.json" with { type: "json" };
import { renderHelp } from "./tui";

const argv = process.argv.slice(2);
const cmd = argv[0];

const OVERVIEW = `mlx-bun ${pkg.version} — local AI on Apple silicon. One binary, no Python.

Usage: mlx-bun <command> [options]

Commands:
  pi         Launch a pi coding-agent session on a local model (the appliance path)
  serve      Start the OpenAI/Anthropic-compatible server + status page
  get        Download a model from Hugging Face (resumable, verified)
  ls         List downloaded models
  fit        Will a model fit this machine? Memory + speed assessment
  scan       Re-index the Hugging Face cache
  harness    Configure external agent harnesses (pi) to use the local server
  benchmark  Measure decode/prefill speed of OUR stack on this machine
  evals      Show recent benchmark runs (all stacks)
  help       Show help for a command (also: mlx-bun <command> --help)

Options:
  -h, --help     Show help
  -v, --version  Show version

Examples:
  mlx-bun pi                       # start (download if needed) and chat with an agent
  mlx-bun serve 12B                # serve the 12B; status page at http://localhost:8090/
  mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit`;

const SERVER_FLAGS = `Server options:
  --host <addr>             Interface to bind  [default: all interfaces;
                            use 127.0.0.1 for loopback-only]
  --port <n>                Listen port  [default: 8090]
  --memory-budget <GB>      Admission-control memory budget; requests that
                            cannot fit are rejected instead of crashing the
                            GPU  [default: machine RAM × 0.75, check-only]
  --prompt-cache <GB>       Prompt (KV) cache byte cap  [default: 2 GB]

Model & quality:
  --kv-quant <mode>         KV cache quantization: config (per-layer
                            kv_config.json when the model ships one), off
                            (bf16), or 4 / 8 (uniform bits)  [default: config]

Performance levers (A/B levers; defaults are the measured winners):
  --compiled-decode on|off  Compiled decode graphs  [default: on]
  --perf-kernel on|off      Fused decode-SDPA Metal kernel  [default: off
                            until the clean-machine benchmark pass flips it]
  --fused-decode on|off     Fused-decode experiment lever  [default: off]
  --fused-sdpa on|off       Fused SDPA path  [default: on]
  --force-wire              Wire weights into memory at load`;

const HELP: Record<string, string> = {
  pi: `mlx-bun pi — drop into a pi coding-agent session on a local model

Usage: mlx-bun pi [options] [pi arguments...]

Reuses a healthy local server when one is running; otherwise picks the
largest supported model that fits this machine (downloading the
recommended model on a fresh install) and starts a server for the
session. The server it starts ends with the session.

Model selection:
  --query <q>          Model to serve when starting a server (registry query)

${SERVER_FLAGS}

All other arguments pass through to pi (user flags override ours):
  -p, --print <msg>    One-shot non-interactive run (ephemeral server)
  --mode json|rpc      Structured output / RPC mode (ephemeral server)
  -c, --continue       Continue the previous pi session
  @file message...     Files and initial messages

Requires pi: bun add -g @earendil-works/pi-coding-agent`,

  serve: `mlx-bun serve — OpenAI/Anthropic-compatible server for a local model

Usage: mlx-bun serve [query] [options]

  [query]              Registry query (e.g. "12B", "e4b", a repo substring).
                       Omitted: auto-picks the largest supported model that
                       fits this machine (downloads the recommended model on
                       a fresh install).

${SERVER_FLAGS}

Endpoints: /v1/chat/completions, /v1/messages, /v1/responses, /v1/models,
/v1/adapters, /stats, /fit, /library, /downloads — status page at /`,

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

  harness: `mlx-bun harness — wire external agent harnesses to the local server

Usage: mlx-bun harness pi [options]

Options:
  --base-url <url>     Server base URL  [default: http://localhost:8090/v1]
  --remove             Remove the registration

Installs a discovery extension into ~/.pi/agent/extensions that
registers the local server as a pi provider (models discovered live
from /v1/models). Reversible; never touches existing pi config.`,

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

Table view: when, model, bench kind, KV mode, decode tok/s, TTFT,
peak memory, commit. Runs are written by ./benchmark.sh.`,
};

HELP.bench = HELP.benchmark!;

function printHelp(topic?: string): never {
  if (topic && HELP[topic]) console.log(renderHelp(HELP[topic]));
  else if (topic) {
    console.error(`unknown command: ${topic}\n`);
    console.log(renderHelp(OVERVIEW));
    process.exit(1);
  } else console.log(renderHelp(OVERVIEW));
  process.exit(0);
}

if (!cmd || cmd === "--help" || cmd === "-h") printHelp();
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
  const kv = opt("kv-quant");
  if (kv === "off") serverOptions.kvQuant = "off";
  else if (kv && kv !== "config") {
    const bits = Number(kv);
    if (![4, 8].includes(bits)) { console.error(`--kv-quant expects config|off|4|8 (got "${kv}")`); process.exit(1); }
    serverOptions.kvQuant = bits;
  }
  const host = opt("host");
  if (host) serverOptions.hostname = host;
  return { port: Number(opt("port", "8090")), serverOptions };
}

/** One-line summary of the active runtime levers for the ready card. */
function runtimeSummary(o: import("./server").ServerOptions): string {
  const kv = o.kvQuant === "off" ? "off" : typeof o.kvQuant === "number" ? `kv${o.kvQuant}` : "config";
  const lever = (env: string, dflt: string) => process.env[env] ?? dflt;
  return `kv-quant ${kv} · compiled-decode ${lever("MLX_BUN_COMPILED_DECODE", "1") === "1" ? "on" : "off"}` +
    ` · perf-kernel ${lever("MLX_BUN_PERF_KERNEL", "0") === "1" ? "on" : "off"}` +
    (lever("MLX_BUN_FUSED_DECODE", "0") === "1" ? " · fused-decode on" : "");
}

/** Shared model resolution: explicit query wins; otherwise the largest
 *  supported (gemma4) model that fits this machine, downloading the
 *  recommended model first on a fresh install. */
async function resolveModelAuto(query: string | null): Promise<{ m: import("./registry").ModelRecord; picked: boolean }> {
  const reg = new Registry();
  if (reg.list().length === 0) await reg.scan();
  if (query) return { m: reg.resolve(query), picked: false };
  const { recommendedRepoId } = await import("./fit");
  let candidates = reg.list().filter((r) => r.modelType.startsWith("gemma4"));
  if (candidates.length === 0) {
    const repoId = recommendedRepoId();
    const { step } = await import("./tui");
    const s = step(`downloading ${repoId} (recommended for this Mac)`);
    const { downloadModel } = await import("./download");
    await downloadModel(repoId, {
      onProgress: (file, received, total) => {
        const pct = total ? Math.floor((received / total) * 100) : 0;
        s.update(`downloading ${repoId} — ${file} ${gb(received)} / ${gb(total)} (${pct}%)`);
      },
    });
    s.done(`downloaded ${repoId}`);
    await reg.scan();
    candidates = reg.list().filter((r) => r.modelType.startsWith("gemma4"));
  }
  candidates.sort((a, b) => b.sizeBytes - a.sizeBytes);
  for (const r of candidates) {
    const config = await loadModelConfig(r.path);
    if (fit(config, r.sizeBytes, 8192, undefined, undefined, r.expertsBytes).fits)
      return { m: r, picked: true };
  }
  console.error("no downloaded gemma4 model fits this machine — pick one explicitly (mlx-bun ls)");
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
          m.modelType.startsWith("gemma4") ? "supported" : `unsupported (${m.modelType})`,
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
    const rt = serverRuntimeFlags();
    // Friendly collision check before loading gigabytes of weights.
    {
      const { probeServer } = await import("./pi-launch");
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
      `Web   ${style.url(`http://${shownHost}:${server.port}/`)}  ${style.dim("(status · fit · library)")}`,
      ...(rt.serverOptions.memoryBudgetBytes
        ? [`Mem   ${gb(rt.serverOptions.memoryBudgetBytes)} budget ${style.dim("(admission control on)")}`] : []),
      `Perf  ${style.dim(runtimeSummary(rt.serverOptions))}`,
      "",
      style.dim("agent session:  mlx-bun pi        stop:  Ctrl+C"),
    ]);
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
    // Our flags are consumed; ALL other args pass through to pi verbatim
    // (-p, --mode rpc, --continue, @files, messages...). User flags are
    // appended after our defaults, so an explicit --model/--models wins.
    const OURS_VAL = new Set([
      "--query", "--port", "--host", "--memory-budget", "--prompt-cache", "--kv-quant",
      "--compiled-decode", "--perf-kernel", "--fused-decode", "--fused-sdpa",
    ]);
    const OURS_BOOL = new Set(["--force-wire"]);
    const passthrough: string[] = [];
    for (let i = 1; i < argv.length; i++) {
      if (OURS_VAL.has(argv[i]!)) { i++; continue; }
      if (OURS_BOOL.has(argv[i]!)) continue;
      passthrough.push(argv[i]!);
    }
    const { detectPi } = await import("./harness-pi");
    const pi = detectPi();
    if (!pi.found) {
      console.error("pi not found. Install it first:");
      console.error("  bun add -g @earendil-works/pi-coding-agent");
      process.exit(1);
    }
    const rt = serverRuntimeFlags();
    const port = rt.port;
    const baseUrl = `http://localhost:${port}/v1`;
    const { probeServer, buildPiInvocation, launchPi } = await import("./pi-launch");
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
      const { m, picked } = await resolveModelAuto(opt("query"));
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
      if (!models) { console.error("server started but /v1/models probe failed"); process.exit(1); }
    }
    console.log(`launching pi (model ${models[0]!.id}; Ctrl+P cycles local models, /model to switch)`);
    const code = await launchPi(buildPiInvocation(pi, baseUrl, models, passthrough));
    // The server we started lives exactly as long as the pi session —
    // exiting pi (clean, Ctrl+C, or headless -p) tears it down. A
    // standalone server belongs to `mlx-bun serve` (which we reuse and
    // never stop).
    if (startedServer) console.log("pi exited — shutting down (use `mlx-bun serve` for a persistent server)");
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
      console.error("  bun add -g @earendil-works/pi-coding-agent");
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
      `${style.green("●")} ${style.bold("pi is wired to mlx-bun")}`,
      "",
      `launch   ${style.accent("pi --provider mlx-bun")}`,
      `select   ${style.dim("/model inside pi · or scope cycling:")} ${style.accent('pi --models "mlx-bun/*"')}`,
      `undo     ${style.dim("mlx-bun harness pi --remove")}`,
    ]);
    break;
  }

  default:
    printHelp(cmd);
}
