// Phase 15 — head-to-head benchmark harness: mlx-bun vs mlx-lm vs optiq.
//
//   bun scripts/bench-h2h.ts preflight
//   bun scripts/bench-h2h.ts direct  [--models e4b,12B,26B] [--runs 3]
//                                    [--tokens 256] [--kv off|config|N]
//                                    [--prompt-tokens N] [--with-baseline]
//   bun scripts/bench-h2h.ts server  [--models e4b] [--runs 5] [--tokens 128]
//   bun scripts/bench-h2h.ts client  --target http://127.0.0.1:8080/v1
//                                    --stack mlx-lm|optiq --model-id <id>
//                                    [--runs 5] [--tokens 128]
//   bun scripts/bench-h2h.ts table   [--since <iso-date>]
//
// Method rules (PLAN Phase 15, non-negotiable, ENFORCED here):
// - preflight gates every leg: swap ≈ 0, free memory floor, no thermal
//   throttle, no big foreign processes. Numbers recorded with the state
//   snapshot either way; headline runs REFUSE when preflight fails
//   (--force records anyway, flagged "preflight-failed" in notes).
// - interleaved repetitions (model A,B,C then A,B,C — never AAA BBB),
//   median-of-N reported, min/max recorded in notes.
// - one discarded warmup per cell (page-in + kernel compilation).
// - direct-vs-direct and server-vs-server, never crossed.
// - Python servers are started by Josh (ground rule); `client` measures
//   them from here. `server` runs OUR server as a managed child.

import { checkMachine, machineStateJson } from "../src/preflight";
import { EvalDB, gitCommit } from "../src/evaldb";
import { Registry } from "../src/registry";

const argv = process.argv.slice(2);
const cmd = argv[0] ?? "preflight";
const opt = (name: string, dflt: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 ? argv[i + 1]! : dflt;
};
const flag = (name: string): boolean => argv.includes(`--${name}`);

const RUNS = Number(opt("runs", cmd === "direct" ? "3" : "5"));
const TOKENS = Number(opt("tokens", cmd === "direct" ? "256" : "128"));
const PROMPT_TOKENS = Number(opt("prompt-tokens", "0"));
const KV = opt("kv", "config");
const PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";

function median(xs: number[]): number {
  const s = [...xs].sort((a, b) => a - b);
  const m = s.length >> 1;
  return s.length % 2 ? s[m]! : (s[m - 1]! + s[m]!) / 2;
}
const fmt = (xs: number[]) =>
  `${median(xs).toFixed(1)} (min ${Math.min(...xs).toFixed(1)}, max ${Math.max(...xs).toFixed(1)}, n=${xs.length})`;

function preflightOrDie(): string {
  const state = checkMachine();
  for (const p of state.problems) console.error(`preflight: ${p}`);
  console.log(
    `machine: swap ${state.swapUsedMB.toFixed(0)} MB, free ${state.freePercent}%, ` +
    `cpu limit ${state.cpuSpeedLimit === -1 ? "n/a" : `${state.cpuSpeedLimit}%`}, ` +
    `${state.bigProcesses.length} big foreign process(es) → ${state.ok ? "OK" : "NOT CLEAR"}`,
  );
  if (!state.ok && !flag("force") && cmd !== "preflight") {
    console.error("refusing to benchmark on an uncleared machine (override: --force, flagged in notes)");
    process.exit(1);
  }
  return machineStateJson(state);
}

/** Run one fresh-process direct bench via scripts/bench.ts; parse its output. */
async function directRun(modelQuery: string, baseline: boolean): Promise<{
  prefillTps: number; decodeTps: number; peakGB: number; promptTokens: number;
}> {
  const args = ["bun", "scripts/bench.ts", "--model", modelQuery, "--tokens", String(TOKENS)];
  if (PROMPT_TOKENS > 0) args.push("--prompt-tokens", String(PROMPT_TOKENS));
  if (!baseline) args.push("--kv", KV);
  if (baseline) args.push("--baseline");
  const proc = Bun.spawn(args, { stdout: "pipe", stderr: "pipe" });
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited,
  ]);
  if (code !== 0) throw new Error(`bench.ts failed for ${modelQuery}:\n${err.slice(-500)}`);
  const prefill = out.match(/prompt: (\d+) tok @ ([\d.]+) tok\/s/);
  const decode = out.match(/decode: \d+ tok @ ([\d.]+) tok\/s/);
  const peak = out.match(/peak mem: ([\d.]+) GB/);
  if (!prefill || !decode || !peak) throw new Error(`could not parse bench output:\n${out.slice(-400)}`);
  return {
    promptTokens: Number(prefill[1]),
    prefillTps: Number(prefill[2]),
    decodeTps: Number(decode[1]),
    peakGB: Number(peak[1]),
  };
}

/** Measure an OpenAI-compatible server from the client side: TTFT (first
 *  content delta) + streamed decode tok/s (from usage + chunk timing). */
async function serverRun(base: string, modelId: string): Promise<{
  ttftMs: number; decodeTps: number; promptTokens: number; completionTokens: number;
}> {
  const t0 = performance.now();
  const res = await fetch(`${base}/chat/completions`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: modelId, stream: true, max_tokens: TOKENS, temperature: 0,
      stream_options: { include_usage: true },
      messages: [{ role: "user", content: PROMPT }],
    }),
  });
  if (!res.ok || !res.body) throw new Error(`server ${res.status}: ${await res.text()}`);
  let ttftMs = -1;
  let firstContentAt = -1;
  let lastChunkAt = -1;
  let usage: any = null;
  const decoder = new TextDecoder();
  let buf = "";
  for await (const chunk of res.body) {
    buf += decoder.decode(chunk, { stream: true });
    let nl: number;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl).trim();
      buf = buf.slice(nl + 1);
      if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
      let obj: any;
      try { obj = JSON.parse(line.slice(6)); } catch { continue; }
      const delta = obj.choices?.[0]?.delta;
      if (delta?.content && firstContentAt < 0) {
        firstContentAt = performance.now();
        ttftMs = firstContentAt - t0;
      }
      if (delta?.content) lastChunkAt = performance.now();
      if (obj.usage) usage = obj.usage;
    }
  }
  if (firstContentAt < 0) throw new Error("no content chunks received");
  const completionTokens = usage?.completion_tokens ?? -1;
  // decode rate over the streamed window (first content → last content);
  // excludes prefill by construction.
  const decodeTps =
    completionTokens > 1 ? ((completionTokens - 1) * 1000) / (lastChunkAt - firstContentAt) : 0;
  return { ttftMs, decodeTps, promptTokens: usage?.prompt_tokens ?? -1, completionTokens };
}

const db = new EvalDB();
const commit = gitCommit();

if (cmd === "preflight") {
  preflightOrDie();
  process.exit(checkMachine().ok ? 0 : 1);
}

if (cmd === "direct") {
  const machineState = preflightOrDie();
  const models = opt("models", "e4b,12B,26B").split(",");
  const withBaseline = flag("with-baseline");
  const reg = new Registry();
  if (reg.list().length === 0) await reg.scan();

  // interleaved: run r touches every (model, stack) cell before run r+1
  const cells = new Map<string, { decode: number[]; prefill: number[]; peak: number[]; prompt: number }>();
  const legs: { model: string; baseline: boolean }[] = models.flatMap((m) => [
    { model: m, baseline: false },
    ...(withBaseline ? [{ model: m, baseline: true }] : []),
  ]);
  for (let r = 0; r < RUNS + 1; r++) {
    for (const leg of legs) {
      const key = `${leg.model}/${leg.baseline ? "mlx-lm" : "mlx-bun"}`;
      const res = await directRun(leg.model, leg.baseline);
      if (r === 0) {
        console.log(`[warmup] ${key}: ${res.decodeTps.toFixed(1)} tok/s (discarded)`);
        continue;
      }
      const c = cells.get(key) ?? { decode: [], prefill: [], peak: [], prompt: res.promptTokens };
      c.decode.push(res.decodeTps);
      c.prefill.push(res.prefillTps);
      c.peak.push(res.peakGB);
      cells.set(key, c);
      console.log(`[run ${r}/${RUNS}] ${key}: ${res.decodeTps.toFixed(1)} tok/s decode`);
    }
  }
  for (const [key, c] of cells) {
    const [modelQuery, stack] = key.split("/") as [string, string];
    const m = reg.resolve(modelQuery);
    console.log(`${key}: decode ${fmt(c.decode)} | prefill ${fmt(c.prefill)} | peak ${Math.max(...c.peak).toFixed(2)} GB`);
    db.record({
      modelPath: m.path, commitSha: commit, stack,
      promptTokens: c.prompt, generatedTokens: TOKENS,
      prefillTps: median(c.prefill), decodeTps: median(c.decode),
      peakBytes: Math.round(Math.max(...c.peak) * 1e9),
      machineState,
      notes: `h2h-direct median-of-${RUNS} kv=${KV}${PROMPT_TOKENS ? ` ctx=${c.prompt}` : ""} ` +
        `decode[${c.decode.map((x) => x.toFixed(1)).join(",")}]` +
        `${flag("force") ? " preflight-failed" : ""}`,
    });
  }
  reg.close();
  process.exit(0);
}

if (cmd === "server" || cmd === "client") {
  const machineState = preflightOrDie();
  let base: string;
  let stack: string;
  let modelId: string;
  let serverProc: ReturnType<typeof Bun.spawn> | null = null;
  let modelPath = opt("target", "");

  if (cmd === "server") {
    // our server, managed child, fresh process
    const reg = new Registry();
    if (reg.list().length === 0) await reg.scan();
    const m = reg.resolve(opt("models", "e4b"));
    modelPath = m.path;
    modelId = m.repoId;
    stack = "mlx-bun";
    const port = 8980;
    serverProc = Bun.spawn(["bun", "scripts/serve.ts", "--model", m.path, "--port", String(port)], {
      stdout: "pipe", stderr: "pipe",
    });
    base = `http://127.0.0.1:${port}/v1`;
    const deadline = Date.now() + 120_000;
    while (Date.now() < deadline) {
      try { if ((await fetch(`${base}/models`)).ok) break; } catch {}
      await Bun.sleep(500);
    }
    reg.close();
  } else {
    base = opt("target", "");
    stack = opt("stack", "");
    modelId = opt("model-id", "");
    if (!base || !stack || !modelId) {
      console.error("client requires --target --stack --model-id");
      process.exit(1);
    }
  }

  try {
    const warm = await serverRun(base, modelId);
    console.log(`[warmup] ttft ${warm.ttftMs.toFixed(0)} ms, decode ${warm.decodeTps.toFixed(1)} tok/s (discarded)`);
    const ttfts: number[] = [];
    const decodes: number[] = [];
    let promptTokens = warm.promptTokens;
    for (let r = 1; r <= RUNS; r++) {
      const res = await serverRun(base, modelId);
      ttfts.push(res.ttftMs);
      decodes.push(res.decodeTps);
      promptTokens = res.promptTokens;
      console.log(`[run ${r}/${RUNS}] ttft ${res.ttftMs.toFixed(0)} ms, decode ${res.decodeTps.toFixed(1)} tok/s`);
    }
    console.log(`${stack} server: ttft ${fmt(ttfts)} ms | decode ${fmt(decodes)} tok/s`);
    db.record({
      modelPath: modelPath || modelId, commitSha: commit, stack,
      promptTokens, generatedTokens: TOKENS,
      prefillTps: 0, decodeTps: median(decodes),
      peakBytes: 0,
      machineState,
      notes: `h2h-server median-of-${RUNS} ttft_ms=${median(ttfts).toFixed(0)} ` +
        `ttft[${ttfts.map((x) => x.toFixed(0)).join(",")}] ` +
        `decode[${decodes.map((x) => x.toFixed(1)).join(",")}]` +
        `${flag("force") ? " preflight-failed" : ""}`,
    });
  } finally {
    serverProc?.kill();
  }
  process.exit(0);
}

if (cmd === "table") {
  const since = new Date(opt("since", new Date().toISOString().slice(0, 10))).getTime();
  const rows = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'h2h-%' ORDER BY model_path, stack, ts")
    .all(since) as Record<string, any>[];
  console.log("| model | stack | leg | decode tok/s | prefill tok/s | ttft ms | peak GB |");
  console.log("|---|---|---|---|---|---|---|");
  for (const r of rows) {
    const model = String(r.model_path).split("/").filter(Boolean).at(-1)!.slice(0, 24);
    const leg = String(r.notes).startsWith("h2h-server") ? "server" : "direct";
    const ttft = String(r.notes).match(/ttft_ms=(\d+)/)?.[1] ?? "—";
    console.log(
      `| ${model} | ${r.stack} | ${leg} | ${Number(r.decode_tps).toFixed(1)} | ` +
      `${r.prefill_tps ? Number(r.prefill_tps).toFixed(0) : "—"} | ${ttft} | ` +
      `${r.peak_bytes ? (Number(r.peak_bytes) / 1e9).toFixed(2) : "—"} |`,
    );
  }
  process.exit(0);
}

console.error(`unknown command ${cmd} — see header for usage`);
process.exit(1);
