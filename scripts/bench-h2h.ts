// Phase 15 — head-to-head benchmark harness: mlx-bun vs mlx-lm vs optiq.
//
// ONE-SHOT (after a reboot, nothing else open):
//   ./benchmark.sh            (= bun scripts/bench-h2h.ts all)
//
// RESUMABLE: cells that already have a row (same stack/model/leg/kv,
// same commit, < 36 h old) are SKIPPED, so a re-run after a mid-matrix
// abort continues where it stopped instead of redoing leg (a) forever.
// --redo forces every cell fresh.
//
// APPLES-TO-APPLES pairs (each cell tagged kv=off|config in its row):
//   engine vs engine:  mlx-bun(bf16 KV)   vs mlx-lm(bf16 KV)
//   best   vs best  :  mlx-bun(kv_config) vs optiq(kv_config)
// optiq-direct = mlx-lm engine + optiq's install_mixed_kv patch
// (bench.ts --baseline --baseline-kv config).
//
// ORDER: models smallest→largest and the 26B (the swap generator) runs
// its cells LAST, so accumulated swap can't taint smaller models.
// Mid-run recheck threshold is 3 GB (post-load inactive swap is normal;
// the catastrophic regime was 6.4 GB churning) — the STARTING gate
// stays strict (512 MB).
//
// Individual legs: preflight | direct | server | client | table
// (see the command blocks below for flags).

import { checkMachine, machineStateJson } from "../src/preflight";
import { EvalDB, gitCommit } from "../src/evaldb";
import { Registry, type ModelRecord } from "../src/registry";
import { existsSync } from "node:fs";

const VENV = "/Users/joshrossi/Code/mlx-lm/.venv/bin";
const PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";
const RESUME_WINDOW_MS = 36 * 3600 * 1000;
const MIDRUN_SWAP_LIMIT_MB = 3072;

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

// --- preflight ------------------------------------------------------------

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
        ? "machine not clear — reboot, open nothing, re-run (finished cells will be skipped)."
        : "refusing to benchmark on an uncleared machine (override: --force, flagged in notes)",
    );
    process.exit(1);
  }
  return machineStateJson(state);
}

// --- resume ----------------------------------------------------------------

function hasRecentRow(
  stack: string, modelPath: string, notesLike: string, notesNotLike?: string,
): boolean {
  const row = db.db
    .query(
      "SELECT 1 FROM runs WHERE stack = ? AND model_path = ? AND notes LIKE ? " +
      (notesNotLike ? "AND notes NOT LIKE ? " : "") +
      "AND commit_sha = ? AND ts > ? LIMIT 1",
    )
    .get(
      ...(notesNotLike
        ? [stack, modelPath, notesLike, notesNotLike, commit, Date.now() - RESUME_WINDOW_MS]
        : [stack, modelPath, notesLike, commit, Date.now() - RESUME_WINDOW_MS]) as [string, string, string, string, number],
    );
  return !!row && !flag("redo");
}

// --- direct leg --------------------------------------------------------------

interface DirectCell {
  m: ModelRecord;
  /** mlx-bun | mlx-lm | optiq (optiq = mlx-lm engine + mixed-KV patch). */
  stack: "mlx-bun" | "mlx-lm" | "optiq";
  kv: "off" | "config";
}
const cellKey = (c: DirectCell) => `${c.m.repoId.split("/").at(-1)}/${c.stack}/kv=${c.kv}`;

async function directRun(c: DirectCell, tokens: number, promptTokens?: number): Promise<{
  prefillTps: number; decodeTps: number; peakGB: number; promptTokens: number;
}> {
  const args = ["bun", "scripts/bench.ts", "--model", c.m.repoId, "--tokens", String(tokens)];
  if (promptTokens) args.push("--prompt-tokens", String(promptTokens));
  if (c.stack === "mlx-bun") args.push("--kv", c.kv);
  else {
    args.push("--baseline");
    if (c.stack === "optiq") args.push("--baseline-kv", "config");
  }
  const proc = Bun.spawn(args, { stdout: "pipe", stderr: "pipe" });
  const [out, err, code] = await Promise.all([
    new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited,
  ]);
  if (code !== 0) throw new Error(`bench.ts failed for ${cellKey(c)}:\n${err.slice(-500)}`);
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

interface Agg { decode: number[]; prefill: number[]; peak: number[]; prompt: number }

async function directLeg(
  cells: DirectCell[], runs: number, machineState: string,
  o: { tokens: number; promptTokens?: number; forceNote?: boolean },
): Promise<void> {
  const ctxTag = o.promptTokens ? ` ctx~${o.promptTokens}` : "";
  const todo = cells.filter((c) => {
    const like = `h2h-direct%kv=${c.kv}${o.promptTokens ? " ctx=%" : " %"}`;
    const notLike = o.promptTokens ? undefined : "%ctx=%";
    if (hasRecentRow(c.stack, c.m.path, like, notLike)) {
      console.log(`  [skip] ${cellKey(c)}${ctxTag} — recent row exists (use --redo to rerun)`);
      return false;
    }
    return true;
  });
  if (todo.length === 0) return;

  const agg = new Map<string, Agg>();
  for (let r = 0; r <= runs; r++) {
    for (const c of todo) {
      const key = cellKey(c);
      const res = await directRun(c, o.tokens, o.promptTokens);
      if (r === 0) {
        console.log(`  [warmup] ${key}: ${res.decodeTps.toFixed(1)} tok/s (discarded)`);
        continue;
      }
      const a = agg.get(key) ?? { decode: [], prefill: [], peak: [], prompt: res.promptTokens };
      a.decode.push(res.decodeTps);
      a.prefill.push(res.prefillTps);
      a.peak.push(res.peakGB);
      agg.set(key, a);
      console.log(`  [run ${r}/${runs}] ${key}: ${res.decodeTps.toFixed(1)} tok/s decode`);
    }
  }
  for (const c of todo) {
    const key = cellKey(c);
    const a = agg.get(key)!;
    console.log(`  ${key}: decode ${fmt(a.decode)} | prefill ${fmt(a.prefill, 0)} | peak ${Math.max(...a.peak).toFixed(2)} GB`);
    db.record({
      modelPath: c.m.path, commitSha: commit, stack: c.stack,
      promptTokens: a.prompt, generatedTokens: o.tokens,
      prefillTps: median(a.prefill), decodeTps: median(a.decode),
      peakBytes: Math.round(Math.max(...a.peak) * 1e9),
      machineState,
      notes: `h2h-direct median-of-${runs} kv=${c.kv}${o.promptTokens ? ` ctx=${a.prompt}` : ""} ` +
        `decode[${list(a.decode)}]${o.forceNote ? " preflight-failed" : ""}`,
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

interface ServerCell {
  m: ModelRecord;
  stack: "mlx-bun" | "mlx-lm" | "optiq";
  /** off = bf16 KV (--no-kv-quant for ours; mlx-lm is always off);
   *  config = kv_config.json (our default; optiq --kv-config). */
  kv: "off" | "config";
}
const serverKey = (c: ServerCell) => `${c.m.repoId.split("/").at(-1)}/${c.stack}/kv=${c.kv}`;

interface ManagedServer { proc: ReturnType<typeof Bun.spawn>; base: string; readyMs: number }

async function startServer(c: ServerCell, port: number): Promise<ManagedServer> {
  let cmdline: string[];
  if (c.stack === "mlx-bun") {
    cmdline = ["bun", "scripts/serve.ts", "--model", c.m.path, "--port", String(port)];
    if (c.kv === "off") cmdline.push("--no-kv-quant");
  } else if (c.stack === "mlx-lm") {
    cmdline = [`${VENV}/mlx_lm.server`, "--model", c.m.path, "--port", String(port)];
  } else {
    cmdline = [`${VENV}/optiq`, "serve", "--model", c.m.path, "--port", String(port)];
    const kvCfg = `${c.m.path}/kv_config.json`;
    if (c.kv === "config" && existsSync(kvCfg)) cmdline.push("--kv-config", kvCfg);
  }
  const proc = Bun.spawn(cmdline, { stdout: "pipe", stderr: "pipe" });
  const base = `http://127.0.0.1:${port}/v1`;
  try {
    const readyMs = await waitReady(base, 360_000);
    return { proc, base, readyMs };
  } catch (e) {
    proc.kill();
    const err = await new Response(proc.stderr).text().catch(() => "");
    throw new Error(`${c.stack} server failed to start: ${(e as Error).message}\n${err.slice(-400)}`);
  }
}

/** Resident set of a pid in MB (cross-stack leak probe; RSS undercounts
 *  GPU memory, but GROWTH across requests is the leak signal). */
function rssMB(pid: number): number {
  const r = Bun.spawnSync(["ps", "-o", "rss=", "-p", String(pid)]);
  return r.exitCode === 0 ? Number(r.stdout.toString().trim()) / 1024 : -1;
}

async function stopServer(s: ManagedServer): Promise<void> {
  s.proc.kill();
  await Promise.race([s.proc.exited, Bun.sleep(5000)]);
  try { s.proc.kill(9); } catch {}
  await Bun.sleep(2000); // let the port + GPU memory settle
}

async function serverLeg(
  c: ServerCell, runs: number, tokens: number, machineState: string, forceNote = false,
): Promise<void> {
  const key = serverKey(c);
  if (hasRecentRow(c.stack, c.m.path, `h2h-server%kv=${c.kv}%`)) {
    console.log(`  [skip] ${key} — recent row exists (use --redo to rerun)`);
    return;
  }
  console.log(`  starting ${c.stack} server for ${c.m.repoId} (kv=${c.kv}) ...`);
  const srv = await startServer(c, 8970);
  try {
    console.log(`  ready in ${(srv.readyMs / 1000).toFixed(1)} s`);
    const warm = await serverRequest(srv.base, c.m.repoId, tokens);
    console.log(`  [warmup] ttft ${warm.ttftMs.toFixed(0)} ms, decode ${warm.decodeTps.toFixed(1)} tok/s (discarded)`);
    const rssAfterWarm = rssMB(srv.proc.pid);
    const ttfts: number[] = [];
    const decodes: number[] = [];
    let promptTokens = warm.promptTokens;
    for (let r = 1; r <= runs; r++) {
      const res = await serverRequest(srv.base, c.m.repoId, tokens);
      ttfts.push(res.ttftMs);
      decodes.push(res.decodeTps);
      if (res.promptTokens > 0) promptTokens = res.promptTokens;
      console.log(`  [run ${r}/${runs}] ${key}: ttft ${res.ttftMs.toFixed(0)} ms, decode ${res.decodeTps.toFixed(1)} tok/s`);
    }
    const rssFinal = rssMB(srv.proc.pid);
    const growthMB = rssAfterWarm > 0 && rssFinal > 0 ? rssFinal - rssAfterWarm : NaN;
    console.log(
      `  ${key}: ttft ${fmt(ttfts, 0)} ms | decode ${fmt(decodes)} tok/s | ` +
      `ready ${(srv.readyMs / 1000).toFixed(1)} s | rss growth ` +
      `${Number.isNaN(growthMB) ? "n/a" : `${growthMB.toFixed(0)} MB over ${runs} req`}`,
    );
    db.record({
      modelPath: c.m.path, commitSha: commit, stack: c.stack,
      promptTokens: Math.max(promptTokens, 0), generatedTokens: tokens,
      prefillTps: 0, decodeTps: median(decodes),
      peakBytes: rssFinal > 0 ? Math.round(rssFinal * 1024 * 1024) : 0,
      machineState,
      notes: `h2h-server median-of-${runs} kv=${c.kv} ttft_ms=${median(ttfts).toFixed(0)} ` +
        `ready_ms=${srv.readyMs.toFixed(0)} rss_growth_mb=${Number.isNaN(growthMB) ? "?" : growthMB.toFixed(0)} ` +
        `ttft[${list(ttfts, 0)}] decode[${list(decodes)}]` +
        `${forceNote ? " preflight-failed" : ""}`,
    });
  } finally {
    await stopServer(srv);
  }
}

// --- table ---------------------------------------------------------------

function renderTable(sinceTs: number): string {
  const raw = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'h2h-%' ORDER BY ts ASC")
    .all(sinceTs) as Record<string, any>[];
  // latest row wins per logical cell (re-runs and aborted passes leave
  // older rows in the DB — history stays queryable, table stays clean)
  const byCell = new Map<string, Record<string, any>>();
  for (const r of raw) {
    const notes = String(r.notes);
    const legT = notes.startsWith("h2h-server") ? "server" : notes.includes("ctx=") ? "ctx" : "direct";
    byCell.set(`${r.model_path}|${r.stack}|${legT}|${notes.match(/kv=(\w+)/)?.[1] ?? "?"}`, r);
  }
  const rows = [...byCell.values()].sort((a, b) =>
    String(a.model_path).localeCompare(String(b.model_path)) ||
    String(a.notes).localeCompare(String(b.notes)) ||
    String(a.stack).localeCompare(String(b.stack)),
  );
  const lines = [
    "| model | stack | leg | kv | decode tok/s | prefill tok/s | ttft ms | ready s | mem GB | rss growth |",
    "|---|---|---|---|---|---|---|---|---|---|",
  ];
  for (const r of rows) {
    const model = String(r.model_path).split("/").filter(Boolean).at(-1)!.slice(0, 12);
    const notes = String(r.notes);
    const leg = notes.startsWith("h2h-server") ? "server"
      : notes.includes("ctx=") ? "direct@8k" : "direct";
    const kv = notes.match(/kv=(\w+)/)?.[1] === "config" ? "mixed" : "bf16";
    const ttft = notes.match(/ttft_ms=(\d+)/)?.[1] ?? "—";
    const ready = notes.match(/ready_ms=(\d+)/)?.[1];
    const growth = notes.match(/rss_growth_mb=([\d.-]+)/)?.[1];
    lines.push(
      `| ${model} | ${r.stack} | ${leg} | ${kv} | ${Number(r.decode_tps).toFixed(1)} | ` +
      `${r.prefill_tps ? Number(r.prefill_tps).toFixed(0) : "—"} | ${ttft} | ` +
      `${ready ? (Number(ready) / 1000).toFixed(1) : "—"} | ` +
      `${r.peak_bytes ? (Number(r.peak_bytes) / 1e9).toFixed(2) : "—"} | ` +
      `${growth ? `${growth} MB` : "—"} |`,
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
  const models = resolveAll(opt("models", "e4b-it-OptiQ,12B,26B"));
  const kv = opt("kv", "config") as "off" | "config";
  const cells: DirectCell[] = models.flatMap((m) => [
    { m, stack: "mlx-bun" as const, kv },
    ...(flag("with-baseline") ? [{ m, stack: "mlx-lm" as const, kv: "off" as const }] : []),
  ]);
  await directLeg(cells, Number(opt("runs", "3")), machineState, {
    tokens: Number(opt("tokens", "256")),
    promptTokens: Number(opt("prompt-tokens", "0")) || undefined,
    forceNote: flag("force") && !checkMachine().ok,
  });
  process.exit(0);
}

if (cmd === "server") {
  const machineState = preflight(false);
  const forceNote = flag("force") && !checkMachine().ok;
  for (const m of resolveAll(opt("models", "e4b-it-OptiQ"))) {
    await serverLeg(
      { m, stack: "mlx-bun", kv: opt("kv", "config") as "off" | "config" },
      Number(opt("runs", "5")), Number(opt("tokens", "128")), machineState, forceNote,
    );
  }
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
    notes: `h2h-server median-of-${runs} kv=${opt("kv", "config")} ttft_ms=${median(ttfts).toFixed(0)} ` +
      `ttft[${list(ttfts, 0)}] decode[${list(decodes)}]`,
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
  const startedAt = Date.now();
  let machineState = preflight(true);
  const recheck = (label: string) => {
    const s = checkMachine({ maxSwapUsedMB: MIDRUN_SWAP_LIMIT_MB });
    if (!s.ok) {
      console.error(`\nmachine degraded after ${label}: ${s.problems.join("; ")}`);
      console.error("finished cells are recorded — reboot and re-run; they will be skipped.");
      console.log("\n" + renderTable(startedAt - RESUME_WINDOW_MS));
      process.exit(1);
    }
    machineState = machineStateJson(s);
  };

  const runs = Number(opt("runs", "3"));
  const serverRuns = Number(opt("server-runs", "5"));
  // smallest first; the 26B (swap generator) runs ALL its cells last
  const models = resolveAll(
    opt("models", flag("skip-26b") ? "e4b-it-OptiQ,12B" : "e4b-it-OptiQ,12B,26B"),
  ).sort((a, b) => a.sizeBytes - b.sizeBytes);

  for (const m of models) {
    const name = m.repoId.split("/").at(-1);
    const hasKvCfg = existsSync(`${m.path}/kv_config.json`);

    console.log(`\n=== ${name}: direct (engine pair bf16/bf16 + best pair mixed/mixed) ===`);
    const directCells: DirectCell[] = [
      { m, stack: "mlx-bun", kv: "off" },
      { m, stack: "mlx-lm", kv: "off" },
      ...(hasKvCfg
        ? [
            { m, stack: "mlx-bun" as const, kv: "config" as const },
            { m, stack: "optiq" as const, kv: "config" as const },
          ]
        : []),
    ];
    await directLeg(directCells, runs, machineState, { tokens: 256 });
    recheck(`${name} direct`);

    if (m.repoId.includes("12B")) {
      console.log(`\n=== ${name}: long-context @8k (mixed vs bf16, mlx-bun + optiq) ===`);
      await directLeg(
        [
          { m, stack: "mlx-bun", kv: "config" },
          { m, stack: "mlx-bun", kv: "off" },
          { m, stack: "optiq", kv: "config" },
          { m, stack: "mlx-lm", kv: "off" },
        ],
        Math.max(2, runs - 1), machineState, { tokens: 256, promptTokens: 8000 },
      );
      recheck(`${name} long-context`);
    }

    console.log(`\n=== ${name}: server-vs-server ===`);
    const serverCells: ServerCell[] = [
      { m, stack: "mlx-bun", kv: hasKvCfg ? "config" : "off" },
      { m, stack: "optiq", kv: hasKvCfg ? "config" : "off" },
      // stock mlx_lm.server can't load gemma4_unified — 26B only; pair it
      // with an mlx-bun bf16 row so that comparison is bf16-vs-bf16
      ...(m.modelType === "gemma4"
        ? [
            { m, stack: "mlx-lm" as const, kv: "off" as const },
            { m, stack: "mlx-bun" as const, kv: "off" as const },
          ]
        : []),
    ];
    for (const c of serverCells) {
      try {
        await serverLeg(c, serverRuns, 128, machineState);
      } catch (e) {
        console.error(`  ${serverKey(c)}: ${(e as Error).message.split("\n")[0]} — cell skipped`);
      }
      recheck(serverKey(c));
    }
  }

  const out = `benchmarks-h2h-${new Date().toISOString().slice(0, 10)}.md`;
  const table = renderTable(startedAt - RESUME_WINDOW_MS);
  console.log(`\n=== results (incl. resumed cells from this window) ===\n${table}`);
  await Bun.write(out, `# mlx-bun head-to-head (${new Date().toISOString().slice(0, 10)}, commit ${commit})\n\n${table}\n`);
  console.log(`\nwrote ${out} — this pass took ${(Date.now() - startedAt) / 60000 | 0} min`);
  process.exit(0);
}

console.error(`unknown command ${cmd} — see header for usage`);
process.exit(1);
