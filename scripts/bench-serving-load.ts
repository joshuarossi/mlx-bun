// Phase 18 P1 — parallel-load benchmark. Drives CONCURRENT requests at an
// OpenAI-compatible /v1/chat/completions and measures how a server behaves
// under load: TTFT + end-to-end latency distributions, aggregate vs
// per-request throughput, error/timeout rate, and the saturation knee.
//
// This is a CLIENT — it never starts a server. Point --base-url at an
// already-running stack (you start it yourself):
//
//   mlx-bun:  bun scripts/serve.ts --model <id> --port 8080
//   mlx-lm:   <venv>/mlx_lm.server --model <path> --port 8091
//   optiq:    <venv>/optiq serve --model <path> --port 8092
//
// Because all three are OpenAI-compatible, the SAME tool compares stacks by
// just changing --base-url + --stack. The headline against today's mlx-bun
// (batch=1, serialized) is the BATCHING GAP: aggregate tok/s flattens while
// latency climbs — that flat-line knee is the business case for P2 (slots).
//
// Examples (start with cpm 0.84 GB + e4b 6 GB — concurrent KV caches leave
// headroom and they're the user-facing starter/recommended models):
//
//   # closed-loop concurrency sweep (1,2,4,8,12,16,20 in-flight)
//   bun scripts/bench-serving-load.ts --base-url http://localhost:8080/v1 \
//     --model gemma-4-e4b-it-OptiQ-4bit --mode closed --concurrency 1,2,4,8,12,16,20 \
//     --requests 40 --max-tokens 128
//
//   # open-loop arrival-rate sweep (32 requesters, each at 5/10/15 rpm, 60 s each)
//   bun scripts/bench-serving-load.ts --base-url http://localhost:8080/v1 \
//     --model gemma-4-e4b-it-OptiQ-4bit --mode open --requesters 32 \
//     --rpm 5,10,15 --duration 60 --max-tokens 128
//
//   # cross-stack: same flags, different --base-url + --stack (run 3×, compare md)
//   bun scripts/bench-serving-load.ts --base-url http://localhost:8091/v1 --stack mlx-lm  ...
//   bun scripts/bench-serving-load.ts --base-url http://localhost:8092/v1 --stack optiq ...
//
// Records one load_runs row per configuration point (src/evaldb.ts) and
// prints a markdown latency-vs-load table + the "max sustainable rpm at
// acceptable p95 TTFT" figure. Memory peaks (from /stats, if exposed) are
// meaningful on a non-pristine machine; throughput numbers are only
// headline-quotable when machine_state is clean (the standing rule).

import { EvalDB, gitCommit, type LoadRun } from "../src/evaldb";
import { checkMachine, machineStateJson } from "../src/preflight";

// ===========================================================================
// PURE LOGIC — percentiles, aggregation, knee detection. No I/O, no clock.
// Exported and unit-tested in bench-serving-load.test.ts (the only test this
// harness ships — everything below the line touches the network).
// ===========================================================================

/** One completed (or failed) request's measurements. */
export interface RequestResult {
  ok: boolean;
  /** Time to first token (ms from send to first content delta). */
  ttftMs: number;
  /** End-to-end latency (ms from send to last byte). */
  e2eMs: number;
  /** Generated (completion) tokens. */
  completionTokens: number;
  /** Per-stream decode rate: (completion-1) tokens over (e2e - ttft). */
  decodeTps: number;
  /** Wall-clock send time, ms (performance.now domain); for the window. */
  sentAt: number;
  /** Wall-clock finish time, ms; for the window + achieved rpm. */
  doneAt: number;
  error?: string;
}

/** Linear-interpolated percentile (p in [0,100]). Empty → 0. Matches the
 *  "nearest-rank with interpolation" convention used by most load tools, so
 *  a single sample returns that sample for any p. */
export function percentile(xs: number[], p: number): number {
  if (xs.length === 0) return 0;
  const s = [...xs].sort((a, b) => a - b);
  if (s.length === 1) return s[0]!;
  const rank = (p / 100) * (s.length - 1);
  const lo = Math.floor(rank);
  const hi = Math.ceil(rank);
  if (lo === hi) return s[lo]!;
  const frac = rank - lo;
  return s[lo]! * (1 - frac) + s[hi]! * frac;
}

/** Aggregated metrics for one configuration point (a concurrency level or an
 *  arrival-rate target). Pure function of the per-request results + the
 *  measured wall-clock window. */
export interface PointMetrics {
  requestsOk: number;
  requestsErr: number;
  durationS: number;
  ttftP50Ms: number;
  ttftP95Ms: number;
  e2eP50Ms: number;
  e2eP95Ms: number;
  e2eP99Ms: number;
  /** Generated tokens/s summed across streams over the window. */
  aggTps: number;
  /** Median per-stream decode tok/s. */
  perReqTps: number;
  /** Completed (ok) requests per minute over the window. */
  achievedRpm: number;
  /** Fraction of requests that errored or timed out. */
  errorRate: number;
}

/** Reduce a batch of results + the window wall time into point metrics.
 *  durationMs is the measured window (last doneAt − first sentAt is used if
 *  not supplied), the denominator for aggregate throughput and rpm. Latency
 *  percentiles use OK requests only; error rate counts everything. */
export function aggregate(results: RequestResult[], durationMs?: number): PointMetrics {
  const ok = results.filter((r) => r.ok);
  const err = results.length - ok.length;
  // Window: caller-supplied (open-loop fixed duration) or measured span.
  let windowMs = durationMs ?? 0;
  if (windowMs <= 0 && results.length > 0) {
    const first = Math.min(...results.map((r) => r.sentAt));
    const last = Math.max(...results.map((r) => r.doneAt));
    windowMs = Math.max(1, last - first);
  }
  windowMs = Math.max(1, windowMs);
  const ttft = ok.map((r) => r.ttftMs);
  const e2e = ok.map((r) => r.e2eMs);
  const totalGen = ok.reduce((a, r) => a + r.completionTokens, 0);
  return {
    requestsOk: ok.length,
    requestsErr: err,
    durationS: windowMs / 1000,
    ttftP50Ms: percentile(ttft, 50),
    ttftP95Ms: percentile(ttft, 95),
    e2eP50Ms: percentile(e2e, 50),
    e2eP95Ms: percentile(e2e, 95),
    e2eP99Ms: percentile(e2e, 99),
    aggTps: (totalGen * 1000) / windowMs,
    perReqTps: percentile(ok.map((r) => r.decodeTps), 50),
    achievedRpm: (ok.length * 60000) / windowMs,
    errorRate: results.length ? err / results.length : 0,
  };
}

/** A point on the sweep: its load level (concurrency / requesters) keyed for
 *  the curve, plus its metrics. */
export interface SweepPoint {
  /** x-axis value: in-flight concurrency (closed) or requesters (open). */
  load: number;
  metrics: PointMetrics;
}

/** Detect the saturation knee: the load level past which aggregate
 *  throughput stops climbing while latency keeps rising. Returns the load
 *  value of the LAST point before the curve flattens, or null if it never
 *  flattens (still scaling) or there are too few points.
 *
 *  The reference for "meaningful gain" is the single-stream throughput at the
 *  lightest load (`base.aggTps / base.load` ≈ one stream's tok/s) — a PHYSICAL
 *  baseline, not a relative-to-noise one. Ideal linear scaling would add ~one
 *  stream's worth of throughput per unit of concurrency; a batching server
 *  approximates that up to its slot count, then each extra unit buys
 *  `< flatFrac` of a stream → that's the plateau. A serialized batch=1 server
 *  buys ~nothing from the very first step (concurrency 1→2 already flat), so
 *  its knee is reported at the lightest load. */
export function detectKnee(points: SweepPoint[], flatFrac = 0.5): number | null {
  if (points.length < 3) return null;
  const sorted = [...points].sort((a, b) => a.load - b.load);
  const base = sorted[0]!;
  // Throughput one unit of load would add under ideal linear scaling
  // (single-stream rate). Guard against a zero/garbage base point.
  const perUnit = base.load > 0 ? base.metrics.aggTps / base.load : 0;
  if (perUnit <= 0) return base.load; // no throughput even at the lightest load
  for (let i = 1; i < sorted.length; i++) {
    const dLoad = sorted[i]!.load - sorted[i - 1]!.load;
    const gain = sorted[i]!.metrics.aggTps - sorted[i - 1]!.metrics.aggTps;
    const gainPerUnit = dLoad > 0 ? gain / dLoad : 0;
    const latUp = sorted[i]!.metrics.e2eP95Ms > sorted[i - 1]!.metrics.e2eP95Ms;
    // Each added unit of concurrency now buys < flatFrac of a stream's
    // throughput while latency still climbs → plateau. Report the load just
    // BEFORE it.
    if (gainPerUnit < flatFrac * perUnit && latUp) return sorted[i - 1]!.load;
  }
  return null; // every step still buys ≥ flatFrac of a stream: still scaling
}

/** Max sustainable load (rpm) holding p95 TTFT under a budget. Walks the
 *  sweep in increasing achieved-rpm order and returns the highest
 *  achieved_rpm whose p95 TTFT is still within budget AND whose error rate is
 *  acceptable. Null if even the lightest point violates the budget. */
export function maxSustainableRpm(
  points: SweepPoint[],
  p95TtftBudgetMs: number,
  maxErrorRate = 0.01,
): number | null {
  const ok = points
    .filter((p) => p.metrics.ttftP95Ms <= p95TtftBudgetMs && p.metrics.errorRate <= maxErrorRate)
    .map((p) => p.metrics.achievedRpm);
  return ok.length ? Math.max(...ok) : null;
}

// ===========================================================================
// I/O — request driver, runners, server probing. Skipped under the unit test
// (import.meta.main is false when imported by the test).
// ===========================================================================

interface Config {
  baseUrl: string;
  modelId: string;
  stack: string;
  mode: "closed" | "open";
  concurrency: number[]; // closed-loop sweep levels
  requesters: number; // open-loop requester count
  rpm: number[]; // open-loop per-requester arrival targets
  requests: number; // closed-loop requests per level
  durationS: number; // open-loop window per rpm target
  maxTokens: number;
  timeoutMs: number;
  prompts: string[];
  ttftBudgetMs: number; // for "max sustainable rpm"
  dbPath: string | undefined;
}

/** Small default prompt set — varied lengths so prefill isn't a constant, no
 *  network/file dependency. Cycled round-robin across requests. */
const DEFAULT_PROMPTS = [
  "In one paragraph, explain why unified memory matters for local LLM inference.",
  "List three tradeoffs between batched and serialized model serving.",
  "Write a short haiku about a GPU streaming weights from DRAM.",
  "Summarize the difference between time-to-first-token and end-to-end latency.",
  "What is the saturation knee in a throughput-vs-concurrency curve? Be brief.",
  "Give a concise definition of continuous batching in an inference server.",
];

const enc = new TextEncoder();
const decoder = new TextDecoder();

/** Issue one streaming chat-completion via curl and time it. curl (not fetch)
 *  for the same reason bench-h2h uses it: the python servers stream HTTP/1.0
 *  close-framed bodies that Bun's fetch treats as already-ended; curl handles
 *  both that and our HTTP/1.1 chunked framing, so ONE client times all three
 *  stacks identically. Per-request timeout via curl --max-time + an abort. */
async function oneRequest(
  cfg: Config,
  prompt: string,
  signal: AbortSignal,
): Promise<RequestResult> {
  const body = JSON.stringify({
    model: cfg.modelId,
    stream: true,
    max_tokens: cfg.maxTokens,
    temperature: 0,
    stream_options: { include_usage: true },
    messages: [{ role: "user", content: prompt }],
  });
  const sentAt = performance.now();
  const proc = Bun.spawn(
    [
      "curl", "-sN", "--max-time", String(Math.ceil(cfg.timeoutMs / 1000)),
      "--fail-with-body", `${cfg.baseUrl}/chat/completions`,
      "-H", "Content-Type: application/json",
      // optiq serve rejects non-sk-optiq- keys when auth is on; ours and
      // mlx_lm.server ignore the header.
      "-H", "Authorization: Bearer sk-optiq-local",
      "-d", body,
    ],
    { stdout: "pipe", stderr: "pipe" },
  );
  // Abort (Ctrl-C / over-window): kill the curl child so we don't hang.
  const onAbort = () => { try { proc.kill(); } catch {} };
  signal.addEventListener("abort", onAbort, { once: true });

  interface Usage { completion_tokens?: number; prompt_tokens?: number }
  interface SseChunk { choices?: { delta?: Record<string, unknown> }[]; usage?: Usage }
  let firstContentAt = -1;
  let contentChunks = 0;
  let usage: Usage | null = null;
  let buf = "";
  try {
    for await (const chunk of proc.stdout) {
      buf += decoder.decode(chunk, { stream: true });
      let nl: number;
      while ((nl = buf.indexOf("\n")) >= 0) {
        const line = buf.slice(0, nl).trim();
        buf = buf.slice(nl + 1);
        if (!line.startsWith("data: ") || line === "data: [DONE]") continue;
        let obj: SseChunk;
        try { obj = JSON.parse(line.slice(6)); } catch { continue; }
        const delta = obj.choices?.[0]?.delta;
        // optiq routes channel-thought into `reasoning`; ours streams it as
        // content. Any token-bearing field = a generated token.
        if (delta && (delta.content || delta.reasoning || delta.reasoning_content)) {
          contentChunks++;
          if (firstContentAt < 0) firstContentAt = performance.now();
        }
        if (obj.usage) usage = obj.usage;
      }
    }
  } catch {
    /* aborted mid-stream — fall through to the error path below */
  } finally {
    signal.removeEventListener("abort", onAbort);
  }
  const code = await proc.exited;
  const doneAt = performance.now();
  if (firstContentAt < 0 || signal.aborted) {
    const errTxt = await new Response(proc.stderr).text().catch(() => "");
    return {
      ok: false, ttftMs: 0, e2eMs: doneAt - sentAt, completionTokens: 0,
      decodeTps: 0, sentAt, doneAt,
      error: signal.aborted ? "aborted" : `no content (curl exit ${code}) ${errTxt.slice(0, 120)}`,
    };
  }
  const completionTokens = usage?.completion_tokens ?? contentChunks;
  const decodeTps =
    completionTokens > 1 ? ((completionTokens - 1) * 1000) / (doneAt - firstContentAt) : 0;
  return {
    ok: true, ttftMs: firstContentAt - sentAt, e2eMs: doneAt - sentAt,
    completionTokens, decodeTps, sentAt, doneAt,
  };
}

/** Closed-loop: keep exactly `level` requests in flight until `total` have
 *  completed (a fixed-depth worker pool). Measures the serialized ceiling
 *  against batch=1 and where a batching server scales. */
async function runClosedLoop(
  cfg: Config, level: number, total: number, signal: AbortSignal,
): Promise<RequestResult[]> {
  const results: RequestResult[] = [];
  let dispatched = 0;
  const worker = async () => {
    while (dispatched < total && !signal.aborted) {
      const i = dispatched++;
      const prompt = cfg.prompts[i % cfg.prompts.length]!;
      results.push(await oneRequest(cfg, prompt, signal));
    }
  };
  await Promise.all(Array.from({ length: level }, worker));
  return results;
}

/** Open-loop: `requesters` independent clients, each firing at `targetRpm`
 *  (Poisson-ish — fixed inter-arrival = 60/rpm s, jittered ±50%) for
 *  `durationS`. Requests that are still in flight at the window edge are
 *  awaited (they count toward latency) but the window is the fixed duration.
 *  This is the "32 requesters @ 10 rpm" regime from the spec. */
async function runOpenLoop(
  cfg: Config, requesters: number, targetRpm: number, durationS: number, signal: AbortSignal,
): Promise<{ results: RequestResult[]; windowMs: number }> {
  const results: RequestResult[] = [];
  const intervalMs = 60000 / targetRpm;
  const t0 = performance.now();
  const deadline = t0 + durationS * 1000;
  const inflight: Promise<void>[] = [];
  const requester = async (seed: number) => {
    let n = seed;
    // stagger requester starts across one interval so arrivals don't align
    await sleepAbortable(intervalMs * (seed / Math.max(1, requesters)), signal);
    while (performance.now() < deadline && !signal.aborted) {
      const prompt = cfg.prompts[n++ % cfg.prompts.length]!;
      const p = oneRequest(cfg, prompt, signal).then((r) => { results.push(r); });
      inflight.push(p);
      // jittered inter-arrival (±50%) so the load isn't lockstep-periodic
      const wait = intervalMs * (0.5 + Math.random());
      await sleepAbortable(wait, signal);
    }
  };
  await Promise.all(Array.from({ length: requesters }, (_, i) => requester(i)));
  await Promise.all(inflight); // drain requests that crossed the window edge
  return { results, windowMs: durationS * 1000 };
}

/** Sleep that resolves early on abort (no dangling timers on Ctrl-C). */
function sleepAbortable(ms: number, signal: AbortSignal): Promise<void> {
  if (ms <= 0 || signal.aborted) return Promise.resolve();
  return new Promise<void>((resolve) => {
    let t: ReturnType<typeof setTimeout>;
    const done = () => { clearTimeout(t); signal.removeEventListener("abort", done); resolve(); };
    t = setTimeout(done, ms);
    signal.addEventListener("abort", done, { once: true });
  });
}

/** Probe the server and confirm it's reachable + serving the model. Returns
 *  nothing on success; throws a CLEAR "start it yourself" error otherwise —
 *  this harness NEVER starts a server. */
async function probeServer(cfg: Config): Promise<void> {
  try {
    const r = await fetch(`${cfg.baseUrl}/models`, { signal: AbortSignal.timeout(3000) });
    if (!r.ok) throw new Error(`/models returned ${r.status}`);
  } catch (e) {
    throw new Error(
      `cannot reach a server at ${cfg.baseUrl} (${(e as Error).message}).\n` +
      `This harness does NOT start servers — start one yourself, e.g.:\n` +
      `  mlx-bun:  bun scripts/serve.ts --model <id> --port 8080\n` +
      `  mlx-lm:   <venv>/mlx_lm.server --model <path> --port 8091\n` +
      `  optiq:    <venv>/optiq serve --model <path> --port 8092\n` +
      `then re-run with --base-url pointed at it (default http://localhost:8080/v1).`,
    );
  }
}

/** Sample peak resident bytes from /stats if the server exposes a memory
 *  figure. mlx-bun's /stats has no live RSS field today, so this is
 *  best-effort: returns null when unavailable (the row stores null, not a
 *  fabricated number). The base URL ends in /v1, /stats is at the root. */
async function sampleMemory(baseUrl: string): Promise<number | null> {
  const root = baseUrl.replace(/\/v1\/?$/, "");
  try {
    const r = await fetch(`${root}/stats`, { signal: AbortSignal.timeout(2000) });
    if (!r.ok) return null;
    const s = (await r.json()) as Record<string, unknown>;
    // Accept any of the plausible shapes a stack might expose; null if none.
    const mem = s.memory as { peak_bytes?: number; resident_bytes?: number } | undefined;
    return mem?.peak_bytes ?? mem?.resident_bytes ?? null;
  } catch {
    return null;
  }
}

// --- markdown report --------------------------------------------------------

const ms = (x: number) => x.toFixed(0);
const tps = (x: number) => x.toFixed(1);

function renderMarkdown(cfg: Config, points: SweepPoint[], machine: string): string {
  const lines: string[] = [];
  const xLabel = cfg.mode === "closed" ? "in-flight" : "requesters@rpm";
  lines.push(`## Parallel-load — ${cfg.stack} · ${cfg.modelId}`);
  lines.push("");
  lines.push(`- base-url: \`${cfg.baseUrl}\`  ·  mode: **${cfg.mode}-loop**  ·  max_tokens: ${cfg.maxTokens}`);
  lines.push(`- machine: ${machine}`);
  lines.push("");
  lines.push(`| ${xLabel} | reqs ok/err | agg tok/s | per-req tok/s | TTFT p50/p95 (ms) | e2e p50/p95/p99 (ms) | rpm |`);
  lines.push("|---|---|---|---|---|---|---|");
  const sorted = [...points].sort((a, b) => a.load - b.load);
  for (const p of sorted) {
    const m = p.metrics;
    lines.push(
      `| ${p.load} | ${m.requestsOk}/${m.requestsErr} | ${tps(m.aggTps)} | ${tps(m.perReqTps)} ` +
      `| ${ms(m.ttftP50Ms)}/${ms(m.ttftP95Ms)} | ${ms(m.e2eP50Ms)}/${ms(m.e2eP95Ms)}/${ms(m.e2eP99Ms)} ` +
      `| ${m.achievedRpm.toFixed(1)} |`,
    );
  }
  lines.push("");
  const knee = detectKnee(sorted);
  lines.push(
    knee == null
      ? `**Saturation knee:** none detected — aggregate throughput still climbing at the top of the sweep (raise the range).`
      : `**Saturation knee:** ${xLabel} ≈ **${knee}** — past this, aggregate tok/s flattens while latency keeps climbing.`,
  );
  const sustain = maxSustainableRpm(sorted, cfg.ttftBudgetMs);
  lines.push(
    sustain == null
      ? `**Max sustainable rpm @ p95 TTFT ≤ ${cfg.ttftBudgetMs} ms:** none — even the lightest point exceeds the budget.`
      : `**Max sustainable rpm @ p95 TTFT ≤ ${cfg.ttftBudgetMs} ms:** **${sustain.toFixed(1)} rpm**.`,
  );
  lines.push("");
  return lines.join("\n");
}

// --- CLI --------------------------------------------------------------------

function parseArgs(argv: string[]): Config {
  const opt = (name: string, dflt: string): string => {
    const i = argv.indexOf(`--${name}`);
    return i > -1 && argv[i + 1] != null ? argv[i + 1]! : dflt;
  };
  const nums = (s: string): number[] =>
    s.split(",").map((x) => Number(x.trim())).filter((x) => Number.isFinite(x) && x > 0);
  const mode = (opt("mode", "closed") === "open" ? "open" : "closed") as "closed" | "open";
  return {
    baseUrl: opt("base-url", process.env.MLX_BUN_BASE_URL ?? "http://localhost:8080/v1").replace(/\/$/, ""),
    modelId: opt("model", process.env.MLX_BUN_MODEL ?? ""),
    stack: opt("stack", "mlx-bun"),
    mode,
    concurrency: nums(opt("concurrency", "1,2,4,8,12,16,20")),
    requesters: Number(opt("requesters", "32")),
    rpm: nums(opt("rpm", "5,10,15")),
    requests: Number(opt("requests", "40")),
    durationS: Number(opt("duration", "60")),
    maxTokens: Number(opt("max-tokens", "128")),
    timeoutMs: Number(opt("timeout", "120000")),
    prompts: DEFAULT_PROMPTS,
    ttftBudgetMs: Number(opt("ttft-budget", "2000")),
    dbPath: argv.includes("--no-db") ? undefined : (process.env.MLX_BUN_EVAL_DB || undefined),
  };
}

async function main() {
  const argv = process.argv.slice(2);
  const cfg = parseArgs(argv);
  if (!cfg.modelId) {
    console.error("error: --model <id> is required (the model the target server is serving).");
    console.error("       see the header of this file for example invocations.");
    process.exit(2);
  }

  // Clean Ctrl-C: abort all in-flight curls, report what we have, exit.
  const ac = new AbortController();
  let interrupted = false;
  const onSig = () => {
    if (interrupted) process.exit(130);
    interrupted = true;
    console.error("\ninterrupted — aborting in-flight requests…");
    ac.abort();
  };
  process.on("SIGINT", onSig);

  await probeServer(cfg); // throws a clear "start it yourself" message if down

  const machine = checkMachine();
  const machineLine =
    `swap ${machine.swapUsedMB.toFixed(0)} MB, free ${machine.freePercent}%, ` +
    `${machine.ok ? "OK" : "NOT CLEAR (throughput not headline-quotable)"}`;
  const machineJson = machineStateJson(machine);
  const commit = gitCommit();

  const db = cfg.dbPath === undefined && !argv.includes("--no-db")
    ? new EvalDB()
    : argv.includes("--no-db") ? null : new EvalDB(cfg.dbPath!);

  const points: SweepPoint[] = [];

  if (cfg.mode === "closed") {
    for (const level of cfg.concurrency) {
      if (ac.signal.aborted) break;
      process.stderr.write(`closed-loop: ${level} in-flight × ${cfg.requests} requests… `);
      const results = await runClosedLoop(cfg, level, cfg.requests, ac.signal);
      const m = aggregate(results); // measured-span window
      points.push({ load: level, metrics: m });
      const peak = await sampleMemory(cfg.baseUrl);
      record(db, cfg, "closed-loop", level, null, m, peak, commit, machineJson);
      process.stderr.write(
        `agg ${tps(m.aggTps)} tok/s, TTFT p95 ${ms(m.ttftP95Ms)} ms, ${m.requestsErr} err\n`,
      );
    }
  } else {
    for (const targetRpm of cfg.rpm) {
      if (ac.signal.aborted) break;
      process.stderr.write(
        `open-loop: ${cfg.requesters} requesters @ ${targetRpm} rpm for ${cfg.durationS} s… `,
      );
      const { results, windowMs } = await runOpenLoop(
        cfg, cfg.requesters, targetRpm, cfg.durationS, ac.signal,
      );
      const m = aggregate(results, windowMs);
      // x-axis for open-loop is the OFFERED load (requesters × target rpm).
      points.push({ load: cfg.requesters * targetRpm, metrics: m });
      const peak = await sampleMemory(cfg.baseUrl);
      record(db, cfg, "open-loop", cfg.requesters, targetRpm, m, peak, commit, machineJson);
      process.stderr.write(
        `achieved ${m.achievedRpm.toFixed(1)} rpm, agg ${tps(m.aggTps)} tok/s, ` +
        `TTFT p95 ${ms(m.ttftP95Ms)} ms, ${m.requestsErr} err\n`,
      );
    }
  }

  db?.close();
  process.removeListener("SIGINT", onSig);

  console.log("\n" + renderMarkdown(cfg, points, machineLine));
  if (db) console.log(`(recorded ${points.length} load_runs row(s) in the eval DB)`);
  if (interrupted) process.exit(130);
}

function record(
  db: EvalDB | null, cfg: Config, mode: LoadRun["mode"], concurrency: number,
  targetRpm: number | null, m: PointMetrics, peak: number | null,
  commit: string | null, machineJson: string,
): void {
  if (!db) return;
  db.recordLoad({
    modelId: cfg.modelId, baseUrl: cfg.baseUrl, stack: cfg.stack, commitSha: commit,
    mode, concurrency, targetRpm, maxTokens: cfg.maxTokens,
    requestsOk: m.requestsOk, requestsErr: m.requestsErr, durationS: m.durationS,
    ttftP50Ms: m.ttftP50Ms, ttftP95Ms: m.ttftP95Ms,
    e2eP50Ms: m.e2eP50Ms, e2eP95Ms: m.e2eP95Ms, e2eP99Ms: m.e2eP99Ms,
    aggTps: m.aggTps, perReqTps: m.perReqTps, achievedRpm: m.achievedRpm,
    peakBytes: peak, machineState: machineJson,
    notes: `bench-serving-load ${mode} ${cfg.stack} c=${concurrency}` +
      (targetRpm != null ? ` rpm=${targetRpm}` : ` reqs=${cfg.requests}`) +
      ` max_tokens=${cfg.maxTokens}`,
  });
}

if (import.meta.main) {
  await main();
}
