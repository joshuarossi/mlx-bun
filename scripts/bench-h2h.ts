// Phase 15 — head-to-head benchmark harness: mlx-bun vs mlx-lm vs optiq.
//
// ONE-SHOT (after a reboot, nothing else open):
//   bun scripts/bench-h2h.ts all              # full matrix, ~45-60 min
//   bun scripts/bench-h2h.ts all --skip-26b   # faster pass
//
// Individual legs:
//   bun scripts/bench-h2h.ts preflight
//   bun scripts/bench-h2h.ts direct  [--models q1,q2] [--runs 3] [--tokens 256]
//                                    [--kv off|config|N] [--prompt-tokens N]
//                                    [--with-baseline]
//   bun scripts/bench-h2h.ts server  [--models q] [--runs 5] [--tokens 128]
//   bun scripts/bench-h2h.ts client  --target URL --stack mlx-lm|optiq
//                                    --model-id ID [--runs 5] [--tokens 128]
//   bun scripts/bench-h2h.ts table   [--since iso-date] [--out file.md]
//
// Method rules (PLAN Phase 15, ENFORCED):
// - preflight gates every leg (swap ≈ 0, free-memory floor, thermal, no
//   big foreign processes); `all` hard-aborts when not clear and
//   re-checks between model groups. --force (non-`all` legs only)
//   records rows flagged "preflight-failed".
// - interleaved repetitions, median-of-N (spread in notes), one
//   discarded warmup per cell, machine-state snapshot in every row.
// - direct-vs-direct and server-vs-server, never crossed.
// - stock mlx_lm.server cannot load gemma4_unified (e4b/12B) — its
//   server rows exist only for the 26B; optiq serves all three.
//   (Direct "mlx-lm" rows use bench.ts --baseline, which registers the
//   optiq model remapping — engine is stock mlx-lm generation.)

import { checkMachine, machineStateJson } from "../src/preflight";
import { EvalDB, gitCommit } from "../src/evaldb";
import { Registry, type ModelRecord } from "../src/registry";
import { existsSync } from "node:fs";

const VENV = "/Users/joshrossi/Code/mlx-lm/.venv/bin";
const PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";

const argv = process.argv.slice(2);
const cmd = argv[0] ?? "preflight";
const opt = (name: string, dflt: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i > -1 ? argv[i + 1]! : dflt;
};
const flag = (name: string): boolean => argv.includes(`--${name}`);

function median(xs: number[]): number {
  const s = [...xs].sort((a, b) => a - b);
  const m = s.length >> 1;
  return s.length % 2 ? s[m]! : (s[m - 1]! + s[m]!) / 2;
}
const fmt = (xs: number[], digits = 1) =>
  `${median(xs).toFixed(digits)} (min ${Math.min(...xs).toFixed(digits)}, max ${Math.max(...xs).toFixed(digits)}, n=${xs.length})`;
const list = (xs: number[], digits = 1) => xs.map((x) => x.toFixed(digits)).join(",");

const db = new EvalDB();
const commit = gitCommit();

// --- preflight -------------------------------------------------------------

function preflight(hard: boolean): string {
  const state = checkMachine();
  for (const p of state.problems) console.error(`preflight: ${p}`);
  console.log(
    `machine: swap ${state.swapUsedMB.toFixed(0)} MB, free ${state.freePercent}%, ` +
    `cpu limit ${state.cpuSpeedLimit === -1 ? "n/a" : `${state.cpuSpeedLimit}%`}, ` +
    `${state.bigProcesses.length} big foreign process(es) → ${state.ok ? "OK" : "NOT CLEAR"}`,
  );
  if (!state.ok && (hard || !flag("force"))) {
    console.error(
      hard
        ? "machine not clear — reboot, open nothing, re-run."
        : "refusing to benchmark on an uncleared machine (override: --force, flagged in notes)",
    );
    process.exit(1);
  }
  return machineStateJson(state);
}

// --- direct leg --------------------------------------------------------------

interface DirectOpts {
  baseline?: boolean;
  tokens: number;
  promptTokens?: number;
  kv?: string;
}

async function directRun(modelQuery: string, o: DirectOpts): Promise<{
  prefillTps: number; decodeTps: number; peakGB: number; promptTokens: number;
}> {
  const args = ["bun", "scripts/bench.ts", "--model", modelQuery, "--tokens", String(o.tokens)];
  if (o.promptTokens) args.push("--prompt-tokens", String(o.promptTokens));
  if (o.baseline) args.push("--baseline");
  else if (o.kv) args.push("--kv", o.kv);
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

interface Cell { decode: number[]; prefill: number[]; peak: number[]; prompt: number }

async function directLeg(
  models: ModelRecord[], runs: number, machineState: string,
  o: { tokens: number; promptTokens?: number; kv: string; withBaseline: boolean; forceNote?: boolean },
): Promise<void> {
  const cells = new Map<string, Cell>();
  const legs = models.flatMap((m) => [
    { m, baseline: false },
    ...(o.withBaseline ? [{ m, baseline: true }] : []),
  ]);
  for (let r = 0; r <= runs; r++) {
    for (const leg of legs) {
      const key = `${leg.m.repoId.split("/").at(-1)}/${leg.baseline ? "mlx-lm" : "mlx-bun"}`;
      const res = await directRun(leg.m.repoId, {
        baseline: leg.baseline, tokens: o.tokens, promptTokens: o.promptTokens, kv: o.kv,
      });
      if (r === 0) {
        console.log(`  [warmup] ${key}: ${res.decodeTps.toFixed(1)} tok/s (discarded)`);
        continue;
      }
      const c = cells.get(key) ?? { decode: [], prefill: [], peak: [], prompt: res.promptTokens };
      c.decode.push(res.decodeTps);
      c.prefill.push(res.prefillTps);
      c.peak.push(res.peakGB);
      cells.set(key, c);
      console.log(`  [run ${r}/${runs}] ${key}: ${res.decodeTps.toFixed(1)} tok/s decode`);
    }
  }
  for (const [key, c] of cells) {
    const stack = key.endsWith("mlx-lm") ? "mlx-lm" : "mlx-bun";
    const m = models.find((x) => key.startsWith(x.repoId.split("/").at(-1)!))!;
    console.log(`  ${key}: decode ${fmt(c.decode)} | prefill ${fmt(c.prefill, 0)} | peak ${Math.max(...c.peak).toFixed(2)} GB`);
    db.record({
      modelPath: m.path, commitSha: commit, stack,
      promptTokens: c.prompt, generatedTokens: o.tokens,
      prefillTps: median(c.prefill), decodeTps: median(c.decode),
      peakBytes: Math.round(Math.max(...c.peak) * 1e9),
      machineState,
      notes: `h2h-direct median-of-${runs} kv=${o.kv}${o.promptTokens ? ` ctx=${c.prompt}` : ""} ` +
        `decode[${list(c.decode)}]${o.forceNote ? " preflight-failed" : ""}`,
    });
  }
}

// --- server legs -------------------------------------------------------------

async function serverRequest(base: string, modelId: string, tokens: number): Promise<{
  ttftMs: number; decodeTps: number; promptTokens: number; completionTokens: number;
}> {
  const t0 = performance.now();
  const res = await fetch(`${base}/chat/completions`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: modelId, stream: true, max_tokens: tokens, temperature: 0,
      stream_options: { include_usage: true },
      messages: [{ role: "user", content: PROMPT }],
    }),
  });
  if (!res.ok || !res.body) throw new Error(`server ${res.status}: ${await res.text()}`);
  let firstContentAt = -1;
  let lastChunkAt = -1;
  let contentChunks = 0;
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
      if (delta?.content) {
        contentChunks++;
        if (firstContentAt < 0) firstContentAt = performance.now();
        lastChunkAt = performance.now();
      }
      if (obj.usage) usage = obj.usage;
    }
  }
  if (firstContentAt < 0) throw new Error("no content chunks received");
  // python servers may not honor stream_options — fall back to chunk count
  const completionTokens = usage?.completion_tokens ?? contentChunks;
  const decodeTps =
    completionTokens > 1 ? ((completionTokens - 1) * 1000) / (lastChunkAt - firstContentAt) : 0;
  return {
    ttftMs: firstContentAt - t0, decodeTps,
    promptTokens: usage?.prompt_tokens ?? -1, completionTokens,
  };
}

async function waitReady(base: string, timeoutMs: number): Promise<number> {
  const t0 = performance.now();
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try { if ((await fetch(`${base}/models`, { signal: AbortSignal.timeout(2000) })).ok) return performance.now() - t0; } catch {}
    await Bun.sleep(500);
  }
  throw new Error(`server at ${base} not ready after ${timeoutMs} ms`);
}

interface ManagedServer { proc: ReturnType<typeof Bun.spawn>; base: string; readyMs: number }

async function startServer(stack: string, m: ModelRecord, port: number): Promise<ManagedServer> {
  let cmdline: string[];
  if (stack === "mlx-bun") {
    cmdline = ["bun", "scripts/serve.ts", "--model", m.path, "--port", String(port)];
  } else if (stack === "mlx-lm") {
    cmdline = [`${VENV}/mlx_lm.server`, "--model", m.path, "--port", String(port)];
  } else {
    cmdline = [`${VENV}/optiq`, "serve", "--model", m.path, "--port", String(port)];
    const kvCfg = `${m.path}/kv_config.json`;
    if (existsSync(kvCfg)) cmdline.push("--kv-config", kvCfg);
  }
  const proc = Bun.spawn(cmdline, { stdout: "pipe", stderr: "pipe" });
  const base = `http://127.0.0.1:${port}/v1`;
  try {
    const readyMs = await waitReady(base, 360_000);
    return { proc, base, readyMs };
  } catch (e) {
    proc.kill();
    const err = await new Response(proc.stderr).text().catch(() => "");
    throw new Error(`${stack} server failed to start: ${(e as Error).message}\n${err.slice(-400)}`);
  }
}

async function stopServer(s: ManagedServer): Promise<void> {
  s.proc.kill();
  await Promise.race([s.proc.exited, Bun.sleep(5000)]);
  try { s.proc.kill(9); } catch {}
  await Bun.sleep(2000); // let the port + GPU memory settle
}

async function serverLeg(
  stack: string, m: ModelRecord, runs: number, tokens: number,
  machineState: string, forceNote = false,
): Promise<void> {
  const key = `${m.repoId.split("/").at(-1)}/${stack}`;
  console.log(`  starting ${stack} server for ${m.repoId} ...`);
  const srv = await startServer(stack, m, 8970);
  try {
    console.log(`  ready in ${(srv.readyMs / 1000).toFixed(1)} s`);
    const warm = await serverRequest(srv.base, m.repoId, tokens);
    console.log(`  [warmup] ttft ${warm.ttftMs.toFixed(0)} ms, decode ${warm.decodeTps.toFixed(1)} tok/s (discarded)`);
    const ttfts: number[] = [];
    const decodes: number[] = [];
    let promptTokens = warm.promptTokens;
    for (let r = 1; r <= runs; r++) {
      const res = await serverRequest(srv.base, m.repoId, tokens);
      ttfts.push(res.ttftMs);
      decodes.push(res.decodeTps);
      if (res.promptTokens > 0) promptTokens = res.promptTokens;
      console.log(`  [run ${r}/${runs}] ${key}: ttft ${res.ttftMs.toFixed(0)} ms, decode ${res.decodeTps.toFixed(1)} tok/s`);
    }
    console.log(`  ${key}: ttft ${fmt(ttfts, 0)} ms | decode ${fmt(decodes)} tok/s | ready ${(srv.readyMs / 1000).toFixed(1)} s`);
    db.record({
      modelPath: m.path, commitSha: commit, stack,
      promptTokens: Math.max(promptTokens, 0), generatedTokens: tokens,
      prefillTps: 0, decodeTps: median(decodes),
      peakBytes: 0,
      machineState,
      notes: `h2h-server median-of-${runs} ttft_ms=${median(ttfts).toFixed(0)} ` +
        `ready_ms=${srv.readyMs.toFixed(0)} ttft[${list(ttfts, 0)}] decode[${list(decodes)}]` +
        `${forceNote ? " preflight-failed" : ""}`,
    });
  } finally {
    await stopServer(srv);
  }
}

// --- table ---------------------------------------------------------------

function renderTable(sinceTs: number): string {
  const rows = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'h2h-%' ORDER BY model_path, notes, stack")
    .all(sinceTs) as Record<string, any>[];
  const lines = [
    "| model | stack | leg | decode tok/s | prefill tok/s | ttft ms | ready s | peak GB |",
    "|---|---|---|---|---|---|---|---|",
  ];
  for (const r of rows) {
    const model = String(r.model_path).split("/").filter(Boolean).at(-1)!.slice(0, 12);
    const notes = String(r.notes);
    const leg = notes.startsWith("h2h-server") ? "server"
      : notes.includes("ctx=") ? "direct@8k" : "direct";
    const ttft = notes.match(/ttft_ms=(\d+)/)?.[1] ?? "—";
    const ready = notes.match(/ready_ms=(\d+)/)?.[1];
    lines.push(
      `| ${model} | ${r.stack} | ${leg} | ${Number(r.decode_tps).toFixed(1)} | ` +
      `${r.prefill_tps ? Number(r.prefill_tps).toFixed(0) : "—"} | ${ttft} | ` +
      `${ready ? (Number(ready) / 1000).toFixed(1) : "—"} | ` +
      `${r.peak_bytes ? (Number(r.peak_bytes) / 1e9).toFixed(2) : "—"} |`,
    );
  }
  return lines.join("\n");
}

// --- commands --------------------------------------------------------------

if (cmd === "preflight") {
  preflight(false);
  process.exit(checkMachine().ok ? 0 : 1);
}

const reg = new Registry();
if (reg.list().length === 0) await reg.scan();
const resolveAll = (q: string): ModelRecord[] => q.split(",").map((s) => reg.resolve(s.trim()));

if (cmd === "direct") {
  const machineState = preflight(false);
  await directLeg(
    resolveAll(opt("models", "e4b-it-OptiQ,12B,26B")),
    Number(opt("runs", "3")), machineState,
    {
      tokens: Number(opt("tokens", "256")),
      promptTokens: Number(opt("prompt-tokens", "0")) || undefined,
      kv: opt("kv", "config"),
      withBaseline: flag("with-baseline"),
      forceNote: flag("force") && !checkMachine().ok,
    },
  );
  process.exit(0);
}

if (cmd === "server") {
  const machineState = preflight(false);
  const forceNote = flag("force") && !checkMachine().ok;
  for (const m of resolveAll(opt("models", "e4b-it-OptiQ")))
    await serverLeg("mlx-bun", m, Number(opt("runs", "5")), Number(opt("tokens", "128")), machineState, forceNote);
  process.exit(0);
}

if (cmd === "client") {
  const machineState = preflight(false);
  const base = opt("target", "");
  const stack = opt("stack", "");
  const modelId = opt("model-id", "");
  if (!base || !stack || !modelId) {
    console.error("client requires --target --stack --model-id");
    process.exit(1);
  }
  const runs = Number(opt("runs", "5"));
  const tokens = Number(opt("tokens", "128"));
  const warm = await serverRequest(base, modelId, tokens);
  console.log(`[warmup] ttft ${warm.ttftMs.toFixed(0)} ms (discarded)`);
  const ttfts: number[] = [];
  const decodes: number[] = [];
  for (let r = 1; r <= runs; r++) {
    const res = await serverRequest(base, modelId, tokens);
    ttfts.push(res.ttftMs);
    decodes.push(res.decodeTps);
    console.log(`[run ${r}/${runs}] ttft ${res.ttftMs.toFixed(0)} ms, decode ${res.decodeTps.toFixed(1)} tok/s`);
  }
  console.log(`${stack}: ttft ${fmt(ttfts, 0)} ms | decode ${fmt(decodes)} tok/s`);
  db.record({
    modelPath: modelId, commitSha: commit, stack,
    promptTokens: Math.max(warm.promptTokens, 0), generatedTokens: tokens,
    prefillTps: 0, decodeTps: median(decodes), peakBytes: 0, machineState,
    notes: `h2h-server median-of-${runs} ttft_ms=${median(ttfts).toFixed(0)} ` +
      `ttft[${list(ttfts, 0)}] decode[${list(decodes)}]` +
      `${flag("force") && !checkMachine().ok ? " preflight-failed" : ""}`,
  });
  process.exit(0);
}

if (cmd === "table") {
  const since = new Date(opt("since", new Date().toISOString().slice(0, 10))).getTime();
  const out = renderTable(since);
  console.log(out);
  const file = opt("out", "");
  if (file) {
    await Bun.write(file, `# mlx-bun head-to-head (${new Date().toISOString().slice(0, 10)})\n\n${out}\n`);
    console.log(`\nwrote ${file}`);
  }
  process.exit(0);
}

if (cmd === "all") {
  // THE one-shot matrix. Hard preflight; re-checked between groups.
  const startedAt = Date.now();
  let machineState = preflight(true);
  const recheck = (label: string) => {
    const s = checkMachine();
    if (!s.ok) {
      console.error(`\nmachine degraded after ${label}: ${s.problems.join("; ")}`);
      console.error("partial results are recorded; re-run after a reboot to finish.");
      console.log("\n" + renderTable(startedAt));
      process.exit(1);
    }
    machineState = machineStateJson(s);
  };

  const runs = Number(opt("runs", "3"));
  const serverRuns = Number(opt("server-runs", "5"));
  const models = resolveAll(
    opt("models", flag("skip-26b") ? "e4b-it-OptiQ,12B" : "e4b-it-OptiQ,12B,26B"),
  );

  console.log(`\n=== leg (a): direct engine, ${models.length} model(s) × {mlx-bun, mlx-lm} ===`);
  await directLeg(models, runs, machineState, {
    tokens: 256, kv: "config", withBaseline: true,
  });
  recheck("direct leg");

  console.log("\n=== leg (d): long-context @8k, 12B, kv config vs bf16 (mlx-bun) ===");
  const m12 = models.find((m) => m.repoId.includes("12B"));
  if (m12) {
    for (const kv of ["config", "off"]) {
      console.log(`  kv=${kv}:`);
      await directLeg([m12], Math.max(2, runs - 1), machineState, {
        tokens: 256, promptTokens: 8000, kv, withBaseline: false,
      });
    }
    recheck("long-context leg");
  }

  console.log("\n=== legs (b)+(c): server-vs-server (TTFT, streamed decode, ready time) ===");
  for (const m of models) {
    const stacks = ["mlx-bun", "optiq"];
    // stock mlx_lm.server can't load gemma4_unified (e4b/12B) — 26B only
    if (m.modelType === "gemma4") stacks.push("mlx-lm");
    for (const stack of stacks) {
      try {
        await serverLeg(stack, m, serverRuns, 128, machineState);
      } catch (e) {
        console.error(`  ${stack}/${m.repoId}: ${(e as Error).message.split("\n")[0]} — row skipped`);
      }
      recheck(`${stack} server (${m.repoId})`);
    }
  }

  const out = `benchmarks-h2h-${new Date().toISOString().slice(0, 10)}.md`;
  const table = renderTable(startedAt);
  console.log(`\n=== results ===\n${table}`);
  await Bun.write(out, `# mlx-bun head-to-head (${new Date().toISOString().slice(0, 10)}, commit ${commit})\n\n${table}\n`);
  console.log(`\nwrote ${out} — total ${(Date.now() - startedAt) / 60000 | 0} min`);
  process.exit(0);
}

console.error(`unknown command ${cmd} — see header for usage`);
process.exit(1);
