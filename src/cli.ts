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
  evals      Show recent benchmark runs
  help       Show help for a command (also: mlx-bun <command> --help)

Options:
  -h, --help     Show help
  -v, --version  Show version

Examples:
  mlx-bun pi                       # start (download if needed) and chat with an agent
  mlx-bun serve 12B                # serve the 12B; status page at http://localhost:8090/
  mlx-bun get mlx-community/gemma-4-12B-it-OptiQ-4bit`;

const HELP: Record<string, string> = {
  pi: `mlx-bun pi — drop into a pi coding-agent session on a local model

Usage: mlx-bun pi [options] [pi arguments...]

Reuses a healthy local server when one is running; otherwise picks the
largest supported model that fits this machine (downloading the
recommended model on a fresh install) and starts a server for the
session. The server it starts ends with the session.

Options (consumed by mlx-bun):
  --query <q>          Model to serve when starting a server (registry query)
  --port <n>           Server port to probe/start  [default: 8090]
  --memory-budget <GB> Memory budget for a started server (admission control)

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

Options:
  --port <n>           Listen port  [default: 8090]
  --memory-budget <GB> Enable admission control at this budget

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

  evals: `mlx-bun evals — recent benchmark runs

Usage: mlx-bun evals [options]

Options:
  --limit <n>          Rows to show  [default: 20]
  --raw                Full records as JSON lines (for scripts/jq)

Table view: when, model, bench kind, KV mode, decode tok/s, TTFT,
peak memory, commit. Runs are written by ./benchmark.sh.`,
};

function printHelp(topic?: string): never {
  if (topic && HELP[topic]) console.log(HELP[topic]);
  else if (topic) {
    console.error(`unknown command: ${topic}\n`);
    console.log(OVERVIEW);
    process.exit(1);
  } else console.log(OVERVIEW);
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
    let lastFile = "";
    const snap = await downloadModel(repoId, {
      revision: opt("revision", "main")!,
      onProgress: (file, received, total) => {
        const pct = total ? Math.floor((received / total) * 100) : 0;
        if (file !== lastFile) {
          if (lastFile) process.stdout.write("\n");
          lastFile = file;
        }
        process.stdout.write(`\r  ${file}  ${gb(received)} / ${gb(total)} (${pct}%)   `);
      },
    });
    if (lastFile) process.stdout.write("\n");
    console.log(`snapshot: ${snap}`);
    const reg = new Registry();
    await reg.scan();
    console.log("registry updated");
    break;
  }

  case "scan": {
    const reg = new Registry();
    const n = await reg.scan();
    console.log(`indexed ${n} model snapshot(s)`);
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
    for (const m of models) {
      const caps = [
        m.hasVisionSidecar ? "vision" : null,
        m.hasToolTemplate ? "tools" : null,
        m.hasKvConfig ? "kv-quant" : null,
      ].filter(Boolean).join(",");
      const quant = m.quantBits ? `${m.quantBits}-bit g${m.quantGroupSize}` : "full";
      const params = m.paramCount ? `${(m.paramCount / 1e9).toFixed(1)}B` : "?";
      console.log(
        `${m.repoId.padEnd(48)} ${gb(m.sizeBytes).padStart(9)}  ${params.padStart(6)}  ${quant.padEnd(12)} ${(m.license ?? "?").padEnd(12)} ${caps}`,
      );
    }
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
    console.log(`${m.repoId} @ ${ctx} context on ${thisMachine().name}:`);
    console.log(`  weights   ${gb(r.weightsBytes)}${
      config.text.enableMoeBlock && m.expertsBytes > 0
        ? ` (experts ${gb(m.expertsBytes)}; top ${config.text.topKExperts}/${config.text.numExperts} read per token)`
        : ""
    }`);
    if (m.sidecarBytes > 0)
      console.log(`  (+ vision sidecar ${gb(m.sidecarBytes)}, bf16 — loads only for vision requests)`);
    console.log(`  kv cache  ${gb(r.kvBytes)}`);
    console.log(`  transient ${gb(r.transientBytes)}`);
    console.log(`  total     ${gb(r.totalBytes)} of ${gb(r.usableBytes)} usable → ${r.fits ? "FITS" : "DOES NOT FIT"}`);
    console.log(`  max safe context: ${r.maxSafeContext} tokens`);
    console.log(`  predicted decode: ${r.predictedDecodeTps.toFixed(1)} tok/s`);
    if (flag("skus")) {
      console.log(`\nSKU matrix @ ${ctx} context:`);
      for (const row of skuMatrix(config, m.sizeBytes, ctx, m.expertsBytes)) {
        console.log(
          `  ${`${row.sku} ${row.ramGB}GB`.padEnd(16)} ${row.fits ? "fits" : "  — "}  ` +
          `max ctx ${String(row.maxContext).padStart(7)}  ~${row.decodeTps.toFixed(0)} tok/s`,
        );
      }
    }
    break;
  }

  case "serve": {
    const { banner, step, box, style } = await import("./tui");
    banner(pkg.version);
    // Friendly collision check before loading gigabytes of weights.
    const servePort = Number(opt("port", "8090"));
    {
      const { probeServer } = await import("./pi-launch");
      const running = await probeServer(`http://localhost:${servePort}/v1`);
      if (running) {
        console.error(`port ${servePort} is already serving ${running.map((m) => m.id).join(", ")}.`);
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
    const budgetGB = Number(opt("memory-budget", "0"));
    const memoryBudgetBytes = budgetGB > 0 ? budgetGB * 1e9 : undefined;
    const sLoad = step("loading weights");
    const t0 = performance.now();
    const ctx = await loadContext(m.path, m.repoId, { memoryBudgetBytes });
    const server = createServer(ctx, servePort, { memoryBudgetBytes, owner: "serve" });
    sLoad.done(`weights loaded ${style.dim(`in ${(performance.now() - t0).toFixed(0)} ms`)}`);
    console.log();
    box([
      `${style.green("●")} ${style.bold("serving")} ${m.repoId}`,
      "",
      `API   ${style.url(`http://localhost:${server.port}/v1`)}  ${style.dim("(OpenAI · Anthropic · Responses)")}`,
      `Web   ${style.url(`http://localhost:${server.port}/`)}  ${style.dim("(status · fit · library)")}`,
      ...(memoryBudgetBytes ? [`Mem   ${budgetGB} GB budget ${style.dim("(admission control on)")}`] : []),
      "",
      style.dim("agent session:  mlx-bun pi        stop:  Ctrl+C"),
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
    const table = rows.map((r) => ({
      when: ago(r.ts as number),
      model: modelName(r.model_path as string).replace(/-OptiQ-4bit$/, "").replace(/^gemma-4-/, "g4-"),
      bench: ((r.notes as string) ?? "").split(" ")[0] ?? "",
      kv: note(r, "kv"),
      decode: (r.decode_tps as number).toFixed(1),
      ttft: note(r, "ttft_ms") ? `${note(r, "ttft_ms")}ms` : "",
      peak: gb(r.peak_bytes as number),
      commit: (r.commit_sha as string) ?? "",
    }));
    type Row = (typeof table)[number];
    const cols: Array<[string, keyof Row, "left" | "right"]> = [
      ["WHEN", "when", "right"], ["MODEL", "model", "left"], ["BENCH", "bench", "left"],
      ["KV", "kv", "left"], ["TOK/S", "decode", "right"], ["TTFT", "ttft", "right"],
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
        if (k === "commit" || k === "when") return style.dim(cell);
        return cell;
      }).join("  "));
    }
    console.log();
    console.log(style.dim(`  ${rows.length} run(s) · --limit <n> for more · --raw for full records`));
    break;
  }

  case "pi": {
    // Our flags (--query/--port/--memory-budget) are consumed; ALL other
    // args pass through to pi verbatim (-p, --mode rpc, --continue,
    // @files, messages...). User flags are appended after our defaults,
    // so an explicit --model/--models wins over ours.
    const OURS = new Set(["--query", "--port", "--memory-budget"]);
    const passthrough: string[] = [];
    for (let i = 1; i < argv.length; i++) {
      if (OURS.has(argv[i]!)) { i++; continue; }
      passthrough.push(argv[i]!);
    }
    const { detectPi } = await import("./harness-pi");
    const pi = detectPi();
    if (!pi.found) {
      console.error("pi not found. Install it first:");
      console.error("  bun add -g @earendil-works/pi-coding-agent");
      process.exit(1);
    }
    const port = Number(opt("port", "8090"));
    const baseUrl = `http://localhost:${port}/v1`;
    const { probeServer, buildPiInvocation, launchPi } = await import("./pi-launch");
    let models = await probeServer(baseUrl);
    let startedServer = false;
    if (models) {
      console.log(`reusing running server at ${baseUrl} (${models.map((m) => m.id).join(", ")})`);
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
      const budgetGB = Number(opt("memory-budget", "0"));
      const memoryBudgetBytes = budgetGB > 0 ? budgetGB * 1e9 : undefined;
      const sLoad = step(`loading ${m.repoId}`);
      const t0 = performance.now();
      const ctx = await loadContext(m.path, m.repoId, { memoryBudgetBytes });
      createServer(ctx, port, { memoryBudgetBytes, owner: "pi-session" });
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
    console.log(`pi: ${pi.binPath}${pi.version ? ` (v${pi.version})` : ""}`);
    const baseUrl = opt("base-url", DEFAULT_BASE_URL)!;
    const result = await installPiExtension(baseUrl);
    console.log(`provider extension: ${result.path}`);
    if (result.serverReachable) {
      console.log(`server: ${baseUrl} — models: ${result.bakedModels.join(", ")}`);
    } else {
      console.log(`server: ${baseUrl} not reachable — models will be discovered when pi`);
      console.log("starts against a running server (start one with: mlx-bun serve <model>)");
    }
    console.log("launch:  pi --provider mlx-bun");
    console.log('select:  /model in pi, or scope Ctrl+P cycling: pi --models "mlx-bun/*"');
    break;
  }

  default:
    printHelp(cmd);
}
