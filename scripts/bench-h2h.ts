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
import { ORACLE_VENV } from "../tests/paths";
import { existsSync } from "node:fs";
import { hostname, totalmem } from "node:os";

const VENV = `${ORACLE_VENV}/bin`;
const PROMPT = "Write a detailed essay about the history of computing, starting with mechanical calculators.";
const RESUME_WINDOW_MS = 36 * 3600 * 1000;
// RAM-relative: 12.5% of unified memory (3 GB on the 24 GB reference
// machine), floor 2 GB — absolute thresholds don't transfer across Macs.
const MIDRUN_SWAP_LIMIT_MB = Math.max(2048, Math.round(totalmem() / 2 ** 20 / 8));
const HOST = hostname().replace(/\.local$/, "");
const CHIP = (() => {
  const r = Bun.spawnSync(["sysctl", "-n", "machdep.cpu.brand_string"]);
  return r.exitCode === 0 ? r.stdout.toString().trim() : "unknown chip";
})();

// Toolchain provenance for the report: Bun (drives ours) plus the oracle
// interpreter and the package versions that actually govern logit parity
// (mlx / mlx-lm / mlx-optiq). The Python minor is a free variable now —
// recording it makes a 3.13-vs-3.14 decode delta attributable instead of
// mysterious. Degrades gracefully if the oracle venv is unavailable.
const TOOLCHAIN = (() => {
  const r = Bun.spawnSync([`${VENV}/python`, "-c",
    "import sys\n" +
    "from importlib.metadata import version, PackageNotFoundError\n" +
    "def v(n):\n" +
    " try: return version(n)\n" +
    " except PackageNotFoundError: return '?'\n" +
    "print(f\"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro} \"\n" +
    "      f\"(mlx {v('mlx')}, mlx-lm {v('mlx-lm')}, mlx-optiq {v('mlx-optiq')})\")"]);
  const oracle = r.exitCode === 0 ? r.stdout.toString().trim() : "unavailable";
  return { bun: Bun.version, oracle };
})();
const toolchainLine =
  `Toolchain: Bun **${TOOLCHAIN.bun}**, oracle Python **${TOOLCHAIN.oracle}**.`;

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
/** Attempted-and-failed cells — rendered as a footer in the results md
 *  so holes in the matrix are self-documenting (vs "not in the matrix"). */
const failures: { cell: string; error: string }[] = [];

/** Cells dropped because of a KNOWN, non-deterministic upstream bug (not a
 *  regression on our side) — rendered as a distinct footer so a flaky
 *  third-party crash doesn't read as "mlx-bun broke the matrix". */
const knownIssues: { cell: string; error: string }[] = [];

/** optiq's KV-sharing SDPA shim (optiq/runtime/kv/rotating.py) recovers a
 *  shared layer's quant bits from a registry keyed by Python id(); under
 *  e4b's KV sharing (42 layers → 24 caches) id() reuse after its gc.collect()
 *  intermittently returns the wrong cache, so quantized_matmul gets bits that
 *  don't match the tuple. Config-independent (reproduced with mixed, uniform-4,
 *  uniform-8, and globals-bf16), ~50% per run, and only on the optiq stack —
 *  so we retry, and only footnote it if every attempt crashes. 12B is 1:1
 *  (no sharing) and never hits it. */
function isTransientOptiqKvCrash(msg: string): boolean {
  return /quantized_matmul.*shapes of the weight and scales are incompatible/s.test(msg);
}
/** Re-spawn attempts for a transient optiq crash before giving up a cell. */
const OPTIQ_RETRIES = 8;

/** Footer line for a failed cell. Harness errors wrap child output
 *  after our context line ("bench.ts failed for <cell>:\n<stderr
 *  tail>"), so the LAST non-empty line is the child's actual error —
 *  e.g. python's exception line — not our wrapper (the Phase 15
 *  full-matrix harness nit). Single-line errors are their own last
 *  line, so this is a strict improvement. */
function failureLine(msg: string): string {
  const lines = msg.split("\n").map((l) => l.trim()).filter(Boolean);
  // Prefer the actual error line. A Bun uncaught throw ends with the crash
  // banner ("Bun v1.3.14 (macOS arm64)") after the stack, so the LAST line
  // is useless — find the "error:"/"Error:" line, else the last line that
  // isn't the banner or a stack frame.
  const err = [...lines].reverse().find((l) => /^error:/i.test(l) || /\bError:/.test(l));
  if (err) return err.slice(0, 160);
  const meaningful = [...lines].reverse().find((l) => !/^Bun v\d/.test(l) && !/^at\s/.test(l));
  return (meaningful ?? lines[lines.length - 1] ?? msg).slice(0, 160);
}

// --- preflight ------------------------------------------------------------

function preflight(hard: boolean): string {
  const state = checkMachine();
  for (const p of state.problems) console.error(`preflight: ${p}`);
  console.log(
    `machine: swap ${state.swapUsedMB.toFixed(0)} MB, free ${state.freePercent}%, ` +
    `cpu limit ${state.cpuSpeedLimit === -1 ? "n/a" : `${state.cpuSpeedLimit}%`}, ` +
    `gpu ceiling ${state.gpuWiredLimitMB ? `${state.gpuWiredLimitMB} MB (raised)` : "default"}, load ${state.loadAvg1m.toFixed(1)}, ` +
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

// NOT commit-pinned: harness-only fixes between passes must not force
// finished cells to rerun (the recorded sha says what measured them).
function hasRecentRow(
  stack: string, modelPath: string, notesLike: string, notesNotLike?: string,
): boolean {
  const row = db.db
    .query(
      "SELECT 1 FROM runs WHERE stack = ? AND model_path = ? AND notes LIKE ? " +
      (notesNotLike ? "AND notes NOT LIKE ? " : "") +
      "AND ts > ? LIMIT 1",
    )
    .get(
      ...(notesNotLike
        ? [stack, modelPath, notesLike, notesNotLike, Date.now() - RESUME_WINDOW_MS]
        : [stack, modelPath, notesLike, Date.now() - RESUME_WINDOW_MS]) as [string, string, string, number],
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
  // optiq crashes ~half the time on KV-sharing models (see isTransientOptiqKvCrash).
  // Re-spawn on that specific error so one unlucky run doesn't sink the cell.
  const maxAttempts = c.stack === "optiq" ? OPTIQ_RETRIES + 1 : 1;
  let out = "", err = "", code = 0;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const proc = Bun.spawn(args, { stdout: "pipe", stderr: "pipe" });
    [out, err, code] = await Promise.all([
      new Response(proc.stdout).text(), new Response(proc.stderr).text(), proc.exited,
    ]);
    if (code === 0) break;
    if (attempt < maxAttempts && isTransientOptiqKvCrash(err)) {
      console.log(`  [retry ${attempt}/${maxAttempts - 1}] ${cellKey(c)}: transient optiq KV crash, re-spawning`);
      continue;
    }
    break;
  }
  if (code !== 0) throw new Error(`bench.ts failed for ${cellKey(c)}:\n${err.slice(-500)}`);
  const prefill = out.match(/prompt: (\d+) tok @ ([\d.]+) tok\/s/);
  const decode = out.match(/decode: \d+ tok @ ([\d.]+) tok\/s/);
  const peak = out.match(/peak mem: ([\d.]+) GB/);
  if (!prefill || !decode || !peak) throw new Error(`could not parse bench output:\n${out.slice(-400)}`);
  // Context sanity: a long-context cell whose child actually ran a short
  // prompt must FAIL, not record — the original Phase 15 matrix's @8k
  // python rows silently measured ctx=31 (the --prompt-tokens plumbing
  // didn't reach the baseline path) and fabricated a −10% decode-gap
  // headline. A failed cell lands in the failure footer instead.
  if (promptTokens && Number(prefill[1]) < 0.9 * promptTokens)
    throw new Error(
      `context sanity failed for ${cellKey(c)}: requested ~${promptTokens} prompt tokens, ` +
      `child measured ${prefill[1]} — refusing to record a mislabeled long-context row`,
    );
  return {
    promptTokens: Number(prefill[1]),
    prefillTps: Number(prefill[2]),
    decodeTps: Number(decode[1]),
    peakGB: Number(peak[1]),
  };
}

interface Agg { samples: { decode: number; prefill: number; peak: number }[]; prompt: number }

// --- run-stability policy ---------------------------------------------------
// Interference on a personal machine is ONE-SIDED: a background process can
// only make a run slower, never faster. So when a cell's runs disagree, the
// consistent FAST cluster is the machine's true capability and the slow runs
// are contamination. The 2026-07-05 pass proved the failure mode: a slow
// window (07:39–08:17) flipped mid-round, our mixed@16k median caught
// [15.1,15.1,24.6] while optiq caught [13.6,23.5,23.5] — the report printed
// a fabricated 0.64× regression that the previous night's pass (1.05×)
// refutes. Policy: if a cell's runs spread past SPREAD_TOL, run extra rounds
// until the top-3 runs agree within STABLE_TOL (record median of that
// cluster, tagged `stabilized`); if they never converge, record the median
// of everything tagged `unstable` — rendered ~ and the pair verdict withheld.
const STABLE_TOL = 1.05;
const MAX_EXTRA_ROUNDS = 3;

const decodes = (a: Agg) => a.samples.map((s) => s.decode);
const top3 = (a: Agg) =>
  [...a.samples].sort((x, y) => y.decode - x.decode).slice(0, Math.min(3, a.samples.length));
const spreadOf = (xs: number[]) => Math.max(...xs) / Math.min(...xs);
const top3Stable = (a: Agg) => spreadOf(top3(a).map((s) => s.decode)) <= STABLE_TOL;
const needsRetry = (a: Agg) =>
  a.samples.length > 1 && spreadOf(decodes(a)) > SPREAD_TOL && !top3Stable(a);

/** Which samples represent the machine, and the note tag that says how. */
function robustPick(a: Agg): { picked: Agg["samples"]; tag: string } {
  if (a.samples.length <= 1 || spreadOf(decodes(a)) <= SPREAD_TOL)
    return { picked: a.samples, tag: "" };
  if (top3Stable(a))
    return { picked: top3(a), tag: ` stabilized used-top3of${a.samples.length}` };
  return { picked: a.samples, tag: ` unstable spread=${spreadOf(decodes(a)).toFixed(2)}` };
}

async function directLeg(
  cells: DirectCell[], runs: number, machineState: string,
  o: { tokens: number; promptTokens?: number; forceNote?: boolean },
): Promise<void> {
  const ctxTag = o.promptTokens ? ` ctxreq=${o.promptTokens}` : "";
  const todo = cells.filter((c) => {
    // resume keys on the REQUESTED context length, so an 8k row can
    // never satisfy (and silently skip) a future 32k cell
    const like = `h2h-direct%kv=${c.kv}${o.promptTokens ? ` ctxreq=${o.promptTokens} ` : " "}%`;
    const notLike = o.promptTokens ? undefined : "%ctxreq=%";
    if (hasRecentRow(c.stack, c.m.path, like, notLike)) {
      console.log(`  [skip] ${cellKey(c)}${ctxTag} — recent row exists (use --redo to rerun)`);
      return false;
    }
    return true;
  });
  if (todo.length === 0) return;

  const agg = new Map<string, Agg>();
  const failed = new Set<string>();
  for (let r = 0; r <= runs; r++) {
    for (const c of todo) {
      const key = cellKey(c);
      if (failed.has(key)) continue;
      let res;
      try {
        res = await directRun(c, o.tokens, o.promptTokens);
      } catch (e) {
        // Drop the cell but finish the rest of the matrix; no row is
        // recorded, so the resumable harness retries it next invocation.
        failed.add(key);
        agg.delete(key);
        const msg = (e as Error).message;
        const bucket = c.stack === "optiq" && isTransientOptiqKvCrash(msg) ? knownIssues : failures;
        console.error(`  [${bucket === knownIssues ? "SKIP" : "FAIL"}] ${key}: ${msg}`);
        bucket.push({ cell: `${key}${ctxTag}`, error: failureLine(msg) });
        continue;
      }
      if (r === 0) {
        console.log(`  [warmup] ${key}: ${res.decodeTps.toFixed(1)} tok/s (discarded)`);
        continue;
      }
      const a = agg.get(key) ?? { samples: [], prompt: res.promptTokens };
      a.samples.push({ decode: res.decodeTps, prefill: res.prefillTps, peak: res.peakGB });
      agg.set(key, a);
      console.log(`  [run ${r}/${runs}] ${key}: ${res.decodeTps.toFixed(1)} tok/s decode`);
    }
  }

  // Stability retries (see run-stability policy above): only cells whose
  // runs disagree re-run, interleaved, so a mid-pass machine-state flip gets
  // a chance to resolve into a consistent fast cluster instead of shipping a
  // mixed-state median as a headline.
  for (let extra = 1; extra <= MAX_EXTRA_ROUNDS; extra++) {
    const shaky = todo.filter((c) => {
      const a = agg.get(cellKey(c));
      return !failed.has(cellKey(c)) && a && needsRetry(a);
    });
    if (shaky.length === 0) break;
    for (const c of shaky) {
      const key = cellKey(c);
      try {
        const res = await directRun(c, o.tokens, o.promptTokens);
        agg.get(key)!.samples.push({ decode: res.decodeTps, prefill: res.prefillTps, peak: res.peakGB });
        console.log(`  [stability retry ${extra}/${MAX_EXTRA_ROUNDS}] ${key}: ${res.decodeTps.toFixed(1)} tok/s decode`);
      } catch (e) {
        // keep what we have — the cell records from its existing runs
        console.error(`  [stability retry ${extra}] ${key} failed: ${failureLine((e as Error).message)}`);
        break;
      }
    }
  }

  for (const c of todo) {
    const key = cellKey(c);
    if (failed.has(key)) continue;
    const a = agg.get(key)!;
    const { picked, tag } = robustPick(a);
    const dec = picked.map((s) => s.decode);
    const pre = picked.map((s) => s.prefill);
    console.log(
      `  ${key}: decode ${fmt(dec)} | prefill ${fmt(pre, 0)} | ` +
      `peak ${Math.max(...a.samples.map((s) => s.peak)).toFixed(2)} GB${tag ? ` [${tag.trim()}]` : ""}`,
    );
    db.record({
      modelPath: c.m.path, commitSha: commit, stack: c.stack,
      promptTokens: a.prompt, generatedTokens: o.tokens,
      prefillTps: median(pre), decodeTps: median(dec),
      // peak stays max over ALL runs — a contaminated run's peak is still a
      // real high-water mark of the allocation pattern, not a speed artifact
      peakBytes: Math.round(Math.max(...a.samples.map((s) => s.peak)) * 1e9),
      machineState,
      notes: `h2h-direct median-of-${runs} kv=${c.kv}` +
        `${o.promptTokens ? ` ctxreq=${o.promptTokens} ctx=${a.prompt}` : ""} ` +
        `decode[${list(decodes(a))}]${tag}${o.forceNote ? " preflight-failed" : ""}`,
    });
  }
}

// --- server legs -------------------------------------------------------------

// SSE client = curl piped into this process, for EVERY stack: the python
// servers (BaseHTTPServer) stream HTTP/1.0 close-framed bodies that Bun's
// fetch treats as already-ended ("no content chunks received"); curl
// handles both that and our HTTP/1.1 chunked framing. One client, one
// timing path, all three stacks — the spawn cost (~5 ms) is a constant
// shared by every row and TTFT is server-dominated anyway.
async function serverRequest(base: string, modelId: string, tokens: number): Promise<{
  ttftMs: number; decodeTps: number; promptTokens: number; completionTokens: number;
  /** false = usage absent, token count fell back to SSE chunk counting —
   *  underestimates if a stack coalesces tokens per delta; flagged in
   *  the row so the number carries its own caveat. */
  usedUsage: boolean;
}> {
  const body = JSON.stringify({
    model: modelId, stream: true, max_tokens: tokens, temperature: 0,
    stream_options: { include_usage: true },
    messages: [{ role: "user", content: PROMPT }],
  });
  const t0 = performance.now();
  const proc = Bun.spawn(
    [
      "curl", "-sN", "--max-time", "600", "--fail-with-body",
      `${base}/chat/completions`,
      "-H", "Content-Type: application/json",
      // optiq serve rejects non-sk-optiq- keys when auth is enforced;
      // ours and mlx_lm.server ignore the header.
      "-H", "Authorization: Bearer sk-optiq-local",
      "-d", body,
    ],
    { stdout: "pipe", stderr: "pipe" },
  );
  let firstContentAt = -1;
  let lastChunkAt = -1;
  let contentChunks = 0;
  let usage: any = null;
  const decoder = new TextDecoder();
  let buf = "";
  for await (const chunk of proc.stdout) {
    buf += decoder.decode(chunk, { stream: true });
    let nl: number;
    while ((nl = buf.indexOf("\n")) >= 0) {
      const line = buf.slice(0, nl).trim();
      buf = buf.slice(nl + 1);
      if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
      let obj: any;
      try { obj = JSON.parse(line.slice(6)); } catch { continue; }
      const delta = obj.choices?.[0]?.delta;
      // optiq serve routes channel-thought tokens into a `reasoning`
      // delta (our server streams them as content) — any token-bearing
      // field counts: a generated token is a generated token.
      if (delta?.content || delta?.reasoning || delta?.reasoning_content) {
        contentChunks++;
        if (firstContentAt < 0) firstContentAt = performance.now();
        lastChunkAt = performance.now();
      }
      if (obj.usage) usage = obj.usage;
    }
  }
  const code = await proc.exited;
  if (firstContentAt < 0) {
    const err = await new Response(proc.stderr).text().catch(() => "");
    throw new Error(`no content chunks received (curl exit ${code}) ${err.slice(0, 200)}`);
  }
  const completionTokens = usage?.completion_tokens ?? contentChunks;
  const decodeTps =
    completionTokens > 1 ? ((completionTokens - 1) * 1000) / (lastChunkAt - firstContentAt) : 0;
  return {
    ttftMs: firstContentAt - t0, decodeTps,
    promptTokens: usage?.prompt_tokens ?? -1, completionTokens,
    usedUsage: usage?.completion_tokens != null,
  };
}

async function waitReady(base: string, timeoutMs: number): Promise<number> {
  // 50 ms poll: every server here binds in well under 500 ms, so a
  // coarser interval turns the ready column into a constant (the old
  // "everything reads 0.5 s" artifact). Resolution is ±50 ms.
  const t0 = performance.now();
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try { if ((await fetch(`${base}/models`, { signal: AbortSignal.timeout(2000) })).ok) return performance.now() - t0; } catch {}
    await Bun.sleep(50);
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
    // explicit either way — the serve default flipped to bf16 (naked = L1,
    // 2026-07-05), so kv=config cells must ASK for the mixed scheme
    cmdline.push(c.kv === "off" ? "--no-kv-quant" : "--kv-config");
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
    let anyChunkFallback = !warm.usedUsage;
    for (let r = 1; r <= runs; r++) {
      const res = await serverRequest(srv.base, c.m.repoId, tokens);
      ttfts.push(res.ttftMs);
      decodes.push(res.decodeTps);
      if (res.promptTokens > 0) promptTokens = res.promptTokens;
      if (!res.usedUsage) anyChunkFallback = true;
      console.log(
        `  [run ${r}/${runs}] ${key}: ttft ${res.ttftMs.toFixed(0)} ms, ` +
        `decode ${res.decodeTps.toFixed(1)} tok/s (tok=${res.usedUsage ? "usage" : "chunks"})`,
      );
    }
    // Same stability policy as the direct leg (see run-stability policy):
    // the server is already up, so extra requests are nearly free.
    for (let extra = 1; extra <= MAX_EXTRA_ROUNDS &&
         spreadOf(decodes) > SPREAD_TOL &&
         spreadOf([...decodes].sort((a, b) => b - a).slice(0, 3)) > STABLE_TOL; extra++) {
      const res = await serverRequest(srv.base, c.m.repoId, tokens);
      ttfts.push(res.ttftMs);
      decodes.push(res.decodeTps);
      console.log(`  [stability retry ${extra}/${MAX_EXTRA_ROUNDS}] ${key}: decode ${res.decodeTps.toFixed(1)} tok/s`);
    }
    const allDecodes = [...decodes];
    let stabilityTag = "";
    if (decodes.length > 1 && spreadOf(decodes) > SPREAD_TOL) {
      const fast3 = [...decodes].sort((a, b) => b - a).slice(0, 3);
      if (spreadOf(fast3) <= STABLE_TOL) {
        stabilityTag = ` stabilized used-top3of${decodes.length}`;
        decodes.length = 0;
        decodes.push(...fast3);
      } else {
        stabilityTag = ` unstable spread=${spreadOf(decodes).toFixed(2)}`;
      }
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
        `tok=${anyChunkFallback ? "chunks" : "usage"} ` +
        `ttft[${list(ttfts, 0)}] decode[${list(allDecodes)}]${stabilityTag}` +
        `${forceNote ? " preflight-failed" : ""}`,
    });
  } finally {
    await stopServer(srv);
  }
}

// --- table ---------------------------------------------------------------

// host alone is ambiguous — Josh's MacBooks share the hostname, so a row
// must carry chip + RAM to be attributable to a machine.
function machineOf(r: Record<string, any>): string {
  try {
    const ms = JSON.parse(String(r.machine_state ?? "{}"));
    const host = ms.host ?? "?";
    if (!ms.chip) return host;
    const chip = String(ms.chip).replace(/^Apple /, "");
    return ms.ram_gb ? `${host} (${chip}, ${ms.ram_gb}GB)` : `${host} (${chip})`;
  } catch { return "?"; }
}

/** Human model name from a hub snapshot path: the snapshot BASENAME is a
 *  content hash (unreadable in a report) — recover the repo name from the
 *  `models--<org>--<name>` hub segment; fall back to the basename for
 *  non-hub paths. */
function modelNameOf(modelPath: string): string {
  const hub = modelPath.match(/models--[^/]+--([^/]+)/);
  if (hub) return hub[1]!;
  return modelPath.split("/").filter(Boolean).at(-1) ?? modelPath;
}

// leg label: server | direct | direct@<N>k (from the REQUESTED context
// length, so 8k and 32k rows are distinct cells and labels)
function legOf(notes: string): string {
  if (notes.startsWith("h2h-server")) return "server";
  const req = notes.match(/ctxreq=(\d+)/)?.[1];
  if (req) return `direct@${Math.round(Number(req) / 1000)}k`;
  return notes.includes("ctx=") ? "direct@8k" : "direct"; // legacy rows
}

interface Cell {
  modelPath: string; model: string; stack: string; leg: string; kv: "off" | "config";
  decode: number; spread: string; prefill: number; ttft?: string; ready?: string;
  mem: number; growth?: string; tokSrc?: string; machine: string; commit: string; dirty: boolean;
  /** Run spread exceeded SPREAD_TOL and retries never converged (or the row
   *  predates retries and its recorded run list is wide) — the recorded
   *  median mixes machine states, so a pair verdict from it is withheld. */
  unstable: boolean;
}

/** A cell whose recorded runs span more than this ratio (max/min) mixed two
 *  machine states — the 2026-07-05 pass proved medians from such runs
 *  fabricate regressions (mixed@16k read 0.64× vs optiq from a mid-pass
 *  slow window; the previous night's clean pass read 1.05×). */
const SPREAD_TOL = 1.15;

function parseCell(r: Record<string, any>): Cell {
  const notes = String(r.notes);
  const decodeRuns = (notes.match(/decode\[([\d.,]+)\]/)?.[1] ?? "")
    .split(",").map(Number).filter((x) => !Number.isNaN(x));
  // mlx-lm has no mixed-KV mode: normalize so early mislabeled rows dedupe
  const kv = (r.stack === "mlx-lm" ? "off" : notes.match(/ kv=(\w+)/)?.[1] ?? "off") as "off" | "config";
  // explicit tag from the retry logic wins; legacy rows (no tag) are judged
  // by their recorded run list so old wide medians don't render as clean
  const unstable = / unstable/.test(notes) ||
    (!/ stabilized/.test(notes) && decodeRuns.length > 1 &&
      Math.max(...decodeRuns) / Math.min(...decodeRuns) > SPREAD_TOL);
  return {
    modelPath: String(r.model_path),
    model: modelNameOf(String(r.model_path)),
    stack: String(r.stack), leg: legOf(notes), kv,
    decode: Number(r.decode_tps),
    spread: decodeRuns.length > 1
      ? `${Math.min(...decodeRuns).toFixed(1)}–${Math.max(...decodeRuns).toFixed(1)} (n=${decodeRuns.length})`
      : "—",
    prefill: r.prefill_tps ? Number(r.prefill_tps) : 0,
    ttft: notes.match(/ttft_ms=(\d+)/)?.[1],
    ready: notes.match(/ready_ms=(\d+)/)?.[1],
    mem: r.peak_bytes ? Number(r.peak_bytes) / 1e9 : 0,
    growth: notes.match(/rss_growth_mb=([\d.-]+)/)?.[1],
    tokSrc: notes.match(/tok=(\w+)/)?.[1],
    machine: machineOf(r), commit: String(r.commit_sha ?? "?"),
    dirty: / preflight-failed/.test(notes),
    unstable,
  };
}

/** A vs B paired comparison (sections 1 & 2): our row beside the reference's,
 *  same (model, arena), with the decode speedup. Returns [] if no pairs. */
function pairSection(
  cells: Map<string, Cell>, otherStack: string, ourKv: "off" | "config", otherKv: "off" | "config",
): string[] {
  const keys = new Set<string>();
  for (const c of cells.values()) keys.add(`${c.modelPath}|${c.leg}`);
  const lines: string[] = [
    `| model | arena | mlx-bun tok/s | ${otherStack} tok/s | speedup | mlx-bun prefill | ${otherStack} prefill | machine |`,
    "|---|---|---|---|---|---|---|---|",
  ];
  let any = false;
  for (const k of [...keys].sort()) {
    const [mp, leg] = k.split("|") as [string, string];
    const ours = cells.get(`${mp}|${leg}|mlx-bun|${ourKv}`);
    const other = cells.get(`${mp}|${leg}|${otherStack}|${otherKv}`);
    if (!ours || !other) continue;
    any = true;
    // a pair with an unstable side gets NO speedup verdict — a median that
    // mixed machine states beside one that didn't reads as a regression/win
    // that a re-run erases. The ~-tagged cells say which side to re-run.
    const shaky = ours.unstable || other.unstable;
    const speedup = shaky ? "—~" : other.decode > 0 ? (ours.decode / other.decode).toFixed(2) + "×" : "—";
    const dag = (c: Cell) =>
      (c.tokSrc === "chunks" ? "†" : "") + (c.dirty ? "‡" : "") + (c.unstable ? "~" : "");
    const pf = (c: Cell) => (c.prefill ? c.prefill.toFixed(0) : "—");
    lines.push(
      `| ${ours.model} | ${leg} | ${ours.decode.toFixed(1)}${dag(ours)} | ` +
      `${other.decode.toFixed(1)}${dag(other)} | ${speedup} | ${pf(ours)} | ${pf(other)} | ${ours.machine} |`,
    );
  }
  return any ? lines : [];
}

// The report is sectioned by the THREE comparisons the benchmark exists to
// make (see header), then a raw appendix of every cell. The parity TREE
// (mlx-lm → optiq → mlx-bun) governs the bit-parity requirement of
// comparisons 1 & 2; the numbers here are speed, parity is asserted by tests.
function renderTable(sinceTs: number): string {
  const raw = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'h2h-%' ORDER BY ts ASC")
    .all(sinceTs) as Record<string, any>[];
  // latest row wins per logical cell (re-runs/aborted passes leave older rows)
  const cells = new Map<string, Cell>();
  for (const r of raw) {
    if (!/ kv=\w+/.test(String(r.notes))) continue; // skip pre-format smoke rows
    const c = parseCell(r);
    cells.set(`${c.modelPath}|${c.leg}|${c.stack}|${c.kv}`, c);
  }

  const out: string[] = [];

  // --- Comparison 1: vs mlx-lm (bf16 KV; mlx-lm has no mixed-KV mode) -------
  out.push(
    "## Comparison 1 — mlx-bun vs mlx-lm (bf16 KV) — requirement: bit parity",
    "",
    "Parity (per-step logits + greedy tokens vs the mlx-lm oracle): `bun scripts/parity-check.ts` / `tests/parity.test.ts`. Numbers below are speed only.",
    "",
  );
  const s1 = pairSection(cells, "mlx-lm", "off", "off");
  out.push(...(s1.length ? s1 : ["_no mlx-bun/mlx-lm bf16 pairs in this window._"]), "");

  // --- Comparison 2: vs optiq (mixed kv_config) ----------------------------
  out.push(
    "## Comparison 2 — mlx-bun vs optiq (mixed kv_config) — requirement: bit parity",
    "",
    "Mixed-KV bit parity is verified against the DIRECT optiq mixed-KV golden (`tests/mixed-kv-parity.test.ts`, per-step logits bit-exact) plus ours-fast vs ours-monolith (`tests/generated-parity.test.ts`). Numbers below are speed only.",
    "",
  );
  const s2 = pairSection(cells, "optiq", "config", "config");
  out.push(...(s2.length ? s2 : ["_no mlx-bun/optiq mixed pairs in this window._"]), "");

  // --- Comparison 3: our perf vs our compat (KL + scores) ------------------
  const cvp = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'bench-compat-vs-perf%' ORDER BY ts ASC")
    .all(sinceTs) as Record<string, any>[];
  out.push(
    "## Comparison 3 — mlx-bun perf vs compat (same engine) — requirement: low KL + similar scores",
    "",
  );
  const arms = new Map<string, { compat?: Record<string, any>; perf?: Record<string, any> }>();
  const klRows = new Map<string, Record<string, any>>();
  for (const r of cvp) {
    const notes = String(r.notes);
    if (notes.startsWith("bench-compat-vs-perf-kl")) { klRows.set(String(r.model_path), r); continue; }
    const m = notes.match(/arm=(\w+) ctx=(\d+)/);
    if (!m) continue;
    const key = `${modelNameOf(String(r.model_path))}|${m[2]}`;
    const e = arms.get(key) ?? {};
    (e as any)[m[1]!] = r;
    arms.set(key, e);
  }
  if (arms.size) {
    out.push(
      "| model | ctx | compat tok/s | perf tok/s | perf/compat | compat peak GB | perf peak GB |",
      "|---|---|---|---|---|---|---|",
    );
    for (const [key, e] of [...arms.entries()].sort()) {
      const [model, ctx] = key.split("|") as [string, string];
      if (!e.compat || !e.perf) continue;
      const cd = Number(e.compat.decode_tps), pd = Number(e.perf.decode_tps);
      const ratio = cd > 0 ? (pd / cd).toFixed(2) + "×" : "—";
      out.push(
        `| ${model} | ${ctx} | ${cd.toFixed(1)} | ${pd.toFixed(1)} | ${ratio} | ` +
        `${(Number(e.compat.peak_bytes) / 1e9).toFixed(2)} | ${(Number(e.perf.peak_bytes) / 1e9).toFixed(2)} |`,
      );
    }
    out.push("");
  }
  if (klRows.size) {
    out.push("Quality (perf logits vs compat logits, teacher-forced; machine-independent):", "");
    for (const [mp, r] of [...klRows.entries()].sort()) {
      const n = String(r.notes);
      const mean = n.match(/klMeanNats=([\d.eE+-]+)/)?.[1] ?? "?";
      const max = n.match(/klMaxNats=([\d.eE+-]+)/)?.[1] ?? "?";
      const tm = n.match(/tokenMatchPct=([\d.]+)/)?.[1] ?? "?";
      const v = n.match(/verdict=(\w+)/)?.[1] ?? "?";
      const steps = n.match(/steps=(\d+)/)?.[1] ?? "?";
      const model = modelNameOf(mp);
      out.push(`- \`${model}\`: KL mean ${mean} / max ${max} nats over ${steps} steps, greedy token-match ${tm}% → **${v}**`);
    }
    out.push("");
  }
  if (!arms.size && !klRows.size)
    out.push("_no perf-vs-compat rows in this window — run `bun scripts/bench-compat-vs-perf.ts`._", "");

  // --- Comparison 0: L1 kernel matrix (faithful default ± each kernel) -----
  // benchmark.sh runs bench-faithful-matrix.ts between the h2h legs; its
  // rows must land HERE or the "one report" claim is false (the 2026-07-05
  // pass buried the its-levers-earn-nothing finding in stdout).
  const fm = db.db
    .query("SELECT * FROM runs WHERE ts >= ? AND notes LIKE 'bench-faithful-matrix%' ORDER BY ts ASC")
    .all(sinceTs) as Record<string, any>[];
  const fmCells = new Map<string, Record<string, any>>(); // latest wins
  for (const r of fm) {
    const m = String(r.notes).match(/model=(\S+) kv=(\S+) baseline=(\d) cell=(.+)$/);
    if (m) fmCells.set(`${m[1]}|${m[2]}|${m[4]}`, r);
  }
  if (fmCells.size) {
    out.push(
      "## Comparison 0 — L1 kernel matrix (faithful default ± each kernel, vs mlx-lm per kv scheme)",
      "",
    );
    const byModel = new Map<string, { key: string; r: Record<string, any> }[]>();
    for (const [key, r] of fmCells) {
      const model = key.split("|")[0]!;
      (byModel.get(model) ?? byModel.set(model, []).get(model)!).push({ key, r });
    }
    for (const [model, rows] of [...byModel.entries()].sort()) {
      out.push(`**${model}**`, "", "| config | kv | decode tok/s | vs mlx-lm | prefill tok/s | peak GB |", "|---|---|---|---|---|---|");
      for (const { key, r } of rows) {
        const [, kv, cell] = key.split("|") as [string, string, string];
        const isBaseline = / baseline=1 /.test(String(r.notes));
        const oracle = rows.find(({ key: k, r: or }) =>
          k.split("|")[1] === kv && / baseline=1 /.test(String(or.notes)))?.r;
        const ratio = !isBaseline && oracle && Number(oracle.decode_tps) > 0
          ? `${(Number(r.decode_tps) / Number(oracle.decode_tps)).toFixed(2)}×` : "—";
        out.push(
          `| ${cell} | ${kv === "off" ? "bf16" : `q${kv}`} | ${Number(r.decode_tps).toFixed(1)} | ${ratio} | ` +
          `${Number(r.prefill_tps).toFixed(0)} | ${(Number(r.peak_bytes) / 1e9).toFixed(2)} |`,
        );
      }
      out.push("");
    }
  }

  // --- Lever A/Bs (paired, in-process — the flag-default evidence) ---------
  const LEVERS: { bench: string; off: string; on: string }[] = [
    { bench: "bench-perf-kernel", off: "compat", on: "kernel" },
    { bench: "bench-fused-decode", off: "stock", on: "tiled" },
    { bench: "bench-compiled-decode", off: "uncompiled", on: "compiled" },
    { bench: "bench-fused-prefill", off: "off", on: "on" },
  ];
  const abRows: string[] = [];
  for (const lv of LEVERS) {
    const rows = db.db
      .query(`SELECT * FROM runs WHERE ts >= ? AND notes LIKE '${lv.bench} %' ORDER BY ts ASC`)
      .all(sinceTs) as Record<string, any>[];
    // latest wins per (model, ctx, kv, arm)
    const byArm = new Map<string, Record<string, any>>();
    for (const r of rows) {
      const n = String(r.notes);
      if (/ SMOKE/.test(n)) continue;
      const arm = n.match(/(?:decode-arm|fused)=(\w+)/)?.[1];
      const ctx = n.match(/ctx=(\d+)/)?.[1];
      const kv = n.match(/kv=?(\S+)/)?.[1];
      if (!arm || !ctx) continue;
      byArm.set(`${String(r.model_path)}|${ctx}|${kv}|${arm}`, r);
    }
    const pairs = new Set<string>();
    for (const k of byArm.keys()) pairs.add(k.split("|").slice(0, 3).join("|"));
    for (const p of [...pairs].sort()) {
      const off = byArm.get(`${p}|${lv.off}`);
      const on = byArm.get(`${p}|${lv.on}`);
      if (!off || !on) continue;
      const [mp, ctx, kv] = p.split("|") as [string, string, string];
      const dOff = Number(off.decode_tps), dOn = Number(on.decode_tps);
      const pOff = Number(off.prefill_tps), pOn = Number(on.prefill_tps);
      const dr = dOff > 0 ? `${(dOn / dOff).toFixed(2)}×` : "—";
      const pr = pOff > 0 && pOn > 0 ? `${(pOn / pOff).toFixed(2)}×` : "—";
      abRows.push(
        `| ${lv.bench.replace("bench-", "")} | ${modelNameOf(mp)} | ${ctx} | ${kv} | ` +
        `${dOff.toFixed(1)} | ${dOn.toFixed(1)} | ${dr} | ${pr} |`,
      );
    }
  }
  if (abRows.length) {
    out.push(
      "## Lever A/Bs (paired, in-process) — what each optional kernel buys",
      "",
      "Ratios are machine-noise-robust (arms alternate in one process); >1.00× = lever ON wins.",
      "",
      "| lever | model | ctx | kv | off tok/s | on tok/s | decode on/off | prefill on/off |",
      "|---|---|---|---|---|---|---|---|",
      ...abRows,
      "",
    );
  }

  // --- raw appendix --------------------------------------------------------
  out.push(
    "## All raw cells (every recorded h2h row, latest-wins)",
    "",
    "mem is two instruments: direct = Metal generation peak; server = process RSS after the session (undercounts GPU).",
    "",
    "| model | stack | leg | kv | decode tok/s | spread | prefill tok/s | ttft ms | ready s | gen peak GB | rss GB | rss growth | machine | commit |",
    "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|",
  );
  const sorted = [...cells.values()].sort((a, b) =>
    a.modelPath.localeCompare(b.modelPath) || a.leg.localeCompare(b.leg) || a.stack.localeCompare(b.stack));
  for (const c of sorted) {
    const isServer = c.leg === "server";
    const kvLabel = c.stack !== "mlx-lm" && c.kv === "config" ? "mixed" : "bf16";
    const mem = c.mem ? c.mem.toFixed(2) : "";
    out.push(
      `| ${c.model} | ${c.stack} | ${c.leg} | ${kvLabel} | ` +
      `${c.decode.toFixed(1)}${c.tokSrc === "chunks" ? "†" : ""}${c.dirty ? "‡" : ""}${c.unstable ? "~" : ""} | ${c.spread} | ` +
      `${c.prefill ? c.prefill.toFixed(0) : "—"} | ${c.ttft ?? "—"} | ` +
      `${c.ready ? (Number(c.ready) / 1000).toFixed(2) : "—"} | ` +
      `${!isServer && mem ? mem : "—"} | ${isServer && mem ? mem : "—"} | ` +
      `${c.growth ? `${c.growth} MB` : "—"} | ${c.machine} | ${c.commit} |`,
    );
  }

  const footer: string[] = [];
  if (sorted.some((c) => c.tokSrc === "chunks"))
    footer.push("† decode rate from SSE chunk counting (server sent no usage) — underestimates if tokens coalesce per delta.");
  if (sorted.some((c) => c.dirty))
    footer.push("‡ measured on a machine that failed preflight (`--force`) — absolute tok/s is indicative, not quotable; ratios and KL are still valid.");
  if (sorted.some((c) => c.unstable))
    footer.push(
      `~ UNSTABLE: run spread > ${((SPREAD_TOL - 1) * 100).toFixed(0)}% and retries never converged on a ` +
      "consistent fast cluster — the median mixes machine states. Re-run this cell (`--redo`) before " +
      "quoting it; pair verdicts touching it are withheld. (Preflight ‡ does NOT predict this — the " +
      "2026-07-05 pass was preflight-clean yet had a 40-min slow window; spread is the direct signal.)",
    );
  footer.push("Comparison 2 bit parity: direct optiq mixed-KV golden verified by `tests/mixed-kv-parity.test.ts` (producer: `scripts/regen-mixed-kv-goldens.ts` — bf16 prefill → per-layer quantize → stock unfused decode, logits bit-exact). Numbers above are the speed pairing on top of that verdict.");
  if (footer.length) out.push("", ...footer);
  if (failures.length) {
    out.push("", "## attempted but failed", "");
    for (const f of failures) out.push(`- \`${f.cell}\`: ${f.error}`);
  }
  if (knownIssues.length) {
    out.push("", "## skipped — known upstream optiq bug", "",
      `optiq's KV-sharing SDPA shim recovers a shared layer's quant bits from a`,
      `Python \`id()\`-keyed registry; under KV sharing \`id()\` reuse intermittently`,
      `returns the wrong cache, so \`quantized_matmul\` gets mismatched bits (~50% of`,
      `runs, config-independent). Retried ${OPTIQ_RETRIES}× before skipping. Not an mlx-bun regression.`,
      "");
    for (const f of knownIssues) out.push(`- \`${f.cell}\`: ${f.error}`);
  }
  return out.join("\n");
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
  const models = resolveAll(opt("models", "cpm,e4b-it-OptiQ,12B,26B"));
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

// One header for BOTH writers ("all" and "table --out") — benchmark.sh's
// final `table --out` re-render used to drop the machine line, so the
// shipped report said only a hostname that both of Josh's MacBooks share.
function reportDoc(table: string): string {
  const ramGB = Math.round(totalmem() / 2 ** 30);
  return `# mlx-bun head-to-head (${new Date().toISOString().slice(0, 10)}, commit ${commit})\n\n` +
    `Machine: **${HOST}** — ${CHIP}, ${ramGB} GB unified. One machine per file;\n` +
    `cross-machine comparisons go through the per-row machine column.\n\n` +
    `${toolchainLine}\n\n${table}\n`;
}

if (cmd === "table") {
  const since = new Date(opt("since", new Date().toISOString().slice(0, 10))).getTime();
  const out = renderTable(since);
  console.log(out);
  const file = opt("out", "");
  if (file) {
    await Bun.write(file, reportDoc(out));
    console.log(`\nwrote ${file}`);
  }
  process.exit(0);
}

if (cmd === "all") {
  const startedAt = Date.now();
  // --force (benchmark.sh default): the clean-machine gate WARNS instead of
  // refusing. Comparisons 1&2 are bit parity (machine-independent) and #3 is
  // paired/KL (noise cancels), so a dirty machine still yields valid verdicts
  // — only the absolute tok/s headline wants a clean box. Rows measured dirty
  // are tagged `preflight-failed` (‡ in the report) so they carry the caveat.
  const forced = flag("force");
  let machineState = preflight(!forced);
  // sticky: once dirty (start or any recheck), every later row is flagged.
  let degraded = !checkMachine().ok;
  const recheck = (label: string) => {
    const s = checkMachine({ maxSwapUsedMB: MIDRUN_SWAP_LIMIT_MB });
    if (!s.ok) {
      console.error(`\nmachine degraded after ${label}: ${s.problems.join("; ")}`);
      degraded = true;
      if (!forced) {
        console.error("finished cells are recorded — reboot and re-run; they will be skipped.");
        console.log("\n" + renderTable(startedAt - RESUME_WINDOW_MS));
        process.exit(1);
      }
      console.error("--force: continuing on a degraded machine (rows tagged preflight-failed).");
    }
    machineState = machineStateJson(s);
  };
  const forceNote = () => forced && degraded;

  const runs = Number(opt("runs", "3"));
  const serverRuns = Number(opt("server-runs", "5"));
  // smallest first; the 26B (swap generator) runs ALL its cells last. 26B is
  // skipped by default (slow + not interesting right now) — `--with-26b` adds it.
  const models = resolveAll(
    opt("models", flag("with-26b") ? "cpm,e4b-it-OptiQ,12B,26B" : "cpm,e4b-it-OptiQ,12B"),
  ).sort((a, b) => a.sizeBytes - b.sizeBytes);

  for (const m of models) {
    const name = m.repoId.split("/").at(-1);
    // a model whose weights exceed ~75% of unified memory cannot serve
    // here — skip its cells rather than OOM-crashing the matrix
    if (m.sizeBytes > totalmem() * 0.75) {
      console.log(`\n=== ${name}: SKIPPED — ${(m.sizeBytes / 2 ** 30).toFixed(1)} GB weights vs ` +
        `${Math.round(totalmem() / 2 ** 30)} GB RAM (no fit on this machine)`);
      continue;
    }
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
    await directLeg(directCells, runs, machineState, { tokens: 256, forceNote: forceNote() });
    recheck(`${name} direct`);

    if (m.repoId.includes("12B")) {
      console.log(`\n=== ${name}: long-context @16k (mixed vs bf16, mlx-bun + optiq) ===`);
      await directLeg(
        [
          { m, stack: "mlx-bun", kv: "config" },
          { m, stack: "mlx-bun", kv: "off" },
          { m, stack: "optiq", kv: "config" },
          { m, stack: "mlx-lm", kv: "off" },
        ],
        // full depth: this leg carries the headline regression finding —
        // median-of-2 was too thin for the most-quoted number
        runs, machineState, { tokens: 256, promptTokens: 16000, forceNote: forceNote() },
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
      // optiq can hit the same transient KV-sharing crash here; retry, then
      // footnote only if the signature matches (a different optiq server
      // failure — e.g. curl-52 — stays a real fail, not a "known issue").
      const attempts = c.stack === "optiq" ? OPTIQ_RETRIES + 1 : 1;
      let lastErr: Error | null = null;
      for (let attempt = 1; attempt <= attempts; attempt++) {
        try {
          await serverLeg(c, serverRuns, 128, machineState, forceNote());
          lastErr = null;
          break;
        } catch (e) {
          lastErr = e as Error;
          if (attempt < attempts && isTransientOptiqKvCrash(lastErr.message)) {
            console.log(`  [retry ${attempt}/${attempts - 1}] ${serverKey(c)}: transient optiq KV crash, re-running`);
            continue;
          }
          break;
        }
      }
      if (lastErr) {
        const line = failureLine(lastErr.message);
        const bucket = c.stack === "optiq" && isTransientOptiqKvCrash(lastErr.message) ? knownIssues : failures;
        console.error(`  ${serverKey(c)}: ${line} — cell ${bucket === knownIssues ? "footnoted (known optiq bug)" : "skipped"}`);
        bucket.push({ cell: serverKey(c), error: line });
      }
      recheck(serverKey(c));
    }
  }

  const out = `benchmarks-h2h-${new Date().toISOString().slice(0, 10)}-${HOST}.md`;
  const table = renderTable(startedAt - RESUME_WINDOW_MS);
  console.log(`\n=== results (incl. resumed cells from this window) ===\n${table}`);
  await Bun.write(out, reportDoc(table));
  console.log(`\nwrote ${out} — this pass took ${(Date.now() - startedAt) / 60000 | 0} min`);
  process.exit(0);
}

console.error(`unknown command ${cmd} — see header for usage`);
process.exit(1);
