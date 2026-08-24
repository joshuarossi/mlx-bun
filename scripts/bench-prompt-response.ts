// Prompt-to-response attribution benchmark. Each cell owns a real server,
// sends traced HTTP requests, and stores the raw cross-stack trace records.
//
//   bun scripts/bench-prompt-response.ts \
//     --models cpm5,e4b,12B,qwen27b,qwencompact \
//     --arms mlx-bun,mlx-bun-serial,mlx-lm
//
// Defaults implement PLAN.md P2R4: seven short and three long observations
// for miss/full/partial cache states. Use --quick only for harness smoke tests.

import { existsSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const ROOT = new URL("..", import.meta.url).pathname.replace(/\/$/, "");
const CLI = `${ROOT}/src/cli.ts`;
const ORACLE = `${ROOT}/scripts/oracle-p2r-serve.py`;
const PY = `${process.env.HOME}/Code/mlx-lm/.venv/bin/python`;
const HF = `${process.env.HOME}/.cache/huggingface/hub`;
const TRACE_PREFIX = "[p2r] ";
const PORT = 18971;
const READY_TIMEOUT_MS = 600_000;
const REQUEST_TIMEOUT_MS = 900_000;

const argv = process.argv.slice(2);
const opt = (name: string, fallback: string): string => {
  const i = argv.indexOf(`--${name}`);
  return i >= 0 ? argv[i + 1]! : fallback;
};
const flag = (name: string): boolean => argv.includes(`--${name}`);

const USAGE = `Prompt-to-response attribution benchmark

Usage:
  bun scripts/bench-prompt-response.ts [options]

Options:
  --models <csv>       cpm5,e4b,12B,qwen27b,qwencompact
  --arms <csv>         mlx-bun,mlx-bun-serial,mlx-lm
  --contexts <csv>     nominal prompt-token targets
  --scenarios <csv>    miss-full,partial,decode64
  --short-runs <n>     repetitions at <=1024 tokens (default 7)
  --long-runs <n>      repetitions above 1024 tokens (default 3)
  --full-runs <n>      repetitions that include decode64 by default
  --attribution        insert diagnostic MLX synchronization barriers
  --overhead           run only the tracing observer A/B check
  --quick              one-run 128/1024 smoke matrix
  --out <path>         Markdown report path
  --raw <path>         JSONL trace path
  --note <text>        provenance note embedded in the report
  --help               print this help without starting a benchmark`;

function snapshotOf(repo: string, preferred?: string): string {
  const base = `${HF}/${repo}/snapshots`;
  if (preferred && existsSync(`${base}/${preferred}/config.json`))
    return `${base}/${preferred}`;
  try {
    const entries = [...new Bun.Glob("*").scanSync({ cwd: base, onlyFiles: false })];
    const found = entries.find((entry) => existsSync(`${base}/${entry}/config.json`));
    return `${base}/${found ?? "missing"}`;
  } catch {
    return `${base}/missing`;
  }
}

interface ModelSpec {
  label: string;
  path: string;
  oracleNeedsOptiq?: boolean;
  maxContext?: number;
}

const MODELS: Record<string, ModelSpec> = {
  cpm5: {
    label: "MiniCPM5-1B",
    path: snapshotOf(
      "models--mlx-community--MiniCPM5-1B-OptiQ-4bit",
      "664aabaed233c653f82716d8dc822234d0091f78",
    ),
  },
  e4b: {
    label: "gemma-4-e4b",
    path: snapshotOf("models--mlx-community--gemma-4-e4b-it-OptiQ-4bit"),
  },
  "12B": {
    label: "gemma-4-12B",
    path: snapshotOf(
      "models--mlx-community--gemma-4-12B-it-OptiQ-4bit",
      "5b1101065d2094c8f12aa87fee80e0afa5b292b7",
    ),
    oracleNeedsOptiq: true,
  },
  qwen27b: {
    label: "Qwen3.8-27B winner (4/8-bit)",
    path: snapshotOf("models--mjriii--Qwen3.8-27B"),
  },
  qwencompact: {
    label: "Qwen3.8-27B compact TQ (13 GB)",
    path: snapshotOf("models--mjriii--Qwen3.8-27B-TQ"),
  },
};

type Arm = "mlx-bun" | "mlx-bun-serial" | "mlx-lm";
type CacheState = "miss" | "full" | "partial";
type Scenario = "miss-full" | "partial" | "decode64";

interface TraceEvent {
  phase: string;
  startMs: number;
  durationMs: number;
  attributes?: Record<string, string | number | boolean | null>;
}

interface TraceRecord {
  version: number;
  traceId: string;
  requestId: string;
  route: string;
  clock: string;
  outcome: string;
  totalMs: number;
  events: TraceEvent[];
}

interface Sample {
  timestamp: string;
  model: string;
  modelLabel: string;
  arm: Arm;
  cacheState: CacheState;
  targetTokens: number;
  promptTokens: number;
  completionTokens: number;
  maxTokens: number;
  run: number;
  clientTtftMs: number;
  clientTotalMs: number;
  trace: TraceRecord;
}

function commandFor(arm: Arm, model: ModelSpec, port: number): string[] {
  if (arm === "mlx-bun" || arm === "mlx-bun-serial") {
    const promptCache = opt("bun-prompt-cache", "");
    return [
      "bun", CLI, "serve", "--model", model.path, "--port", String(port), "--no-open",
      ...(arm === "mlx-bun-serial" ? ["--batch", "1"] : []),
      ...(promptCache ? ["--prompt-cache", promptCache] : []),
    ];
  }
  return [
    PY, ORACLE,
    ...(model.oracleNeedsOptiq ? ["--optiq-serve"] : []),
    "--model", model.path, "--port", String(port),
  ];
}

function fillerPrompt(targetTokens: number, nonce: string): string {
  const paragraph =
    "The history of computation spans mechanical calculators, vacuum tubes, " +
    "transistors, integrated circuits, compilers, databases, networks, and " +
    "modern accelerators used for machine learning on unified memory systems. ";
  let out = `Unique measurement ${nonce}. `;
  // Deliberately approximate. The result records usage.prompt_tokens and the
  // cross-arm gate rejects unequal counts; labels never pretend the target is exact.
  while (out.length < targetTokens * 5.9) out += paragraph;
  return out + "\nThe main topic is";
}

const median = (values: number[]): number => {
  const xs = [...values].sort((a, b) => a - b);
  if (!xs.length) return 0;
  const mid = xs.length >> 1;
  return xs.length % 2 ? xs[mid]! : (xs[mid - 1]! + xs[mid]!) / 2;
};

function phaseDuration(trace: TraceRecord, phase: string): number {
  return trace.events
    .filter((event) => event.phase === phase)
    .reduce((sum, event) => sum + event.durationMs, 0);
}

function phaseStart(trace: TraceRecord, phase: string): number {
  return trace.events.find((event) => event.phase === phase)?.startMs ?? 0;
}

function firstResponseStart(trace: TraceRecord): number {
  const first = trace.events.find((event) => event.phase === "response.first_write");
  if (first) return first.startMs;
  return phaseStart(trace, "response.final_write");
}

class TraceCollector {
  readonly records = new Map<string, TraceRecord>();
  readonly waiters = new Map<string, (record: TraceRecord) => void>();
  readonly stderrTail: string[] = [];
  #buffer = "";

  pump(stream: ReadableStream<Uint8Array>): void {
    void (async () => {
      const reader = stream.getReader();
      const decoder = new TextDecoder();
      for (;;) {
        const { done, value } = await reader.read();
        if (done) break;
        this.#buffer += decoder.decode(value, { stream: true });
        let newline: number;
        while ((newline = this.#buffer.indexOf("\n")) >= 0) {
          const line = this.#buffer.slice(0, newline);
          this.#buffer = this.#buffer.slice(newline + 1);
          this.#accept(line);
        }
      }
    })();
  }

  #accept(line: string): void {
    if (line.startsWith(TRACE_PREFIX)) {
      try {
        const record = JSON.parse(line.slice(TRACE_PREFIX.length)) as TraceRecord;
        this.records.set(record.traceId, record);
        this.waiters.get(record.traceId)?.(record);
        this.waiters.delete(record.traceId);
        return;
      } catch { /* retain malformed trace in stderr tail */ }
    }
    if (line.trim()) {
      this.stderrTail.push(line);
      if (this.stderrTail.length > 40) this.stderrTail.shift();
    }
  }

  async wait(traceId: string, timeoutMs = 10_000): Promise<TraceRecord> {
    const existing = this.records.get(traceId);
    if (existing) return existing;
    return await new Promise<TraceRecord>((resolve, reject) => {
      const timer = setTimeout(() => {
        this.waiters.delete(traceId);
        reject(new Error(`trace ${traceId} not emitted`));
      }, timeoutMs);
      this.waiters.set(traceId, (record) => {
        clearTimeout(timer);
        resolve(record);
      });
    });
  }
}

async function waitReady(base: string): Promise<void> {
  const started = performance.now();
  while (performance.now() - started < READY_TIMEOUT_MS) {
    try {
      const response = await fetch(`${base}/v1/models`, {
        signal: AbortSignal.timeout(2_000),
      });
      if (response.ok) return;
    } catch { /* still loading */ }
    await Bun.sleep(250);
  }
  throw new Error("server did not become ready");
}

interface RequestResult {
  promptTokens: number;
  completionTokens: number;
  ttftMs: number;
  totalMs: number;
}

type ChatMessage = { role: "user" | "assistant"; content: string };

async function tracedRequest(
  base: string,
  modelId: string,
  content: string | ChatMessage[],
  maxTokens: number,
  traceId: string,
  rawCompletion = false,
): Promise<RequestResult> {
  if (rawCompletion && typeof content !== "string")
    throw new Error("raw completion benchmark requires a string prompt");
  const started = performance.now();
  const response = await fetch(`${base}${rawCompletion ? "/v1/completions" : "/v1/chat/completions"}`, {
    method: "POST",
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    headers: {
      "content-type": "application/json",
      "x-mlx-bun-trace-id": traceId,
    },
    body: JSON.stringify(rawCompletion
      ? {
          model: modelId, prompt: content, stream: true,
          max_tokens: maxTokens, temperature: 0,
          stream_options: { include_usage: true },
        }
      : {
          model: modelId, stream: true, max_tokens: maxTokens, temperature: 0,
          messages: typeof content === "string" ? [{ role: "user", content }] : content,
          chat_template_kwargs: { enable_thinking: false },
          stream_options: { include_usage: true },
        }),
  });
  if (!response.ok)
    throw new Error(`HTTP ${response.status}: ${(await response.text()).slice(0, 500)}`);
  const reader = response.body!.getReader();
  const decoder = new TextDecoder();
  let buffer = "";
  let first = 0;
  let promptTokens = 0;
  let completionTokens = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });
    let newline: number;
    while ((newline = buffer.indexOf("\n")) >= 0) {
      const line = buffer.slice(0, newline).trim();
      buffer = buffer.slice(newline + 1);
      if (!line.startsWith("data:")) continue;
      const payload = line.slice(5).trim();
      if (payload === "[DONE]") continue;
      let event: {
        choices?: Array<{
          text?: string;
          delta?: { content?: string; reasoning?: string; reasoning_content?: string };
        }>;
        usage?: { prompt_tokens?: number; completion_tokens?: number };
      };
      try { event = JSON.parse(payload); } catch { continue; }
      const delta = event.choices?.[0]?.delta;
      const semantic = (event.choices?.[0]?.text ?? "") + (delta?.content ?? "") +
        (delta?.reasoning ?? delta?.reasoning_content ?? "");
      if (semantic && first === 0) first = performance.now();
      if (event.usage) {
        promptTokens = event.usage.prompt_tokens ?? promptTokens;
        completionTokens = event.usage.completion_tokens ?? completionTokens;
      }
    }
  }
  const ended = performance.now();
  if (first === 0) first = ended;
  return {
    promptTokens,
    completionTokens,
    ttftMs: first - started,
    totalMs: ended - started,
  };
}

async function stopProcess(proc: ReturnType<typeof Bun.spawn>): Promise<void> {
  try { proc.kill("SIGINT"); } catch { return; }
  const graceful = Promise.race([proc.exited, Bun.sleep(5_000).then(() => null)]);
  await graceful;
  try { proc.kill("SIGKILL"); } catch { /* already exited */ }
  await proc.exited.catch(() => 0);
}

async function runOverheadLeg(enabled: boolean, order: number): Promise<RequestResult[]> {
  const model = MODELS.cpm5!;
  const collector = new TraceCollector();
  const proc = Bun.spawn(commandFor("mlx-bun", model, PORT), {
    cwd: ROOT,
    stdout: "ignore",
    stderr: "pipe",
    env: { ...process.env, MLX_BUN_P2R_TRACE: enabled ? "1" : "0" },
  });
  collector.pump(proc.stderr);
  const base = `http://127.0.0.1:${PORT}`;
  const results: RequestResult[] = [];
  try {
    await waitReady(base);
    const warmId = `overhead-${order}-${enabled}-warm`;
    await tracedRequest(base, model.path, "Warm up.", 64, warmId);
    if (enabled) await collector.wait(warmId);
    for (let run = 0; run < 7; run++) {
      const traceId = `overhead-${order}-${enabled}-${run}`;
      results.push(await tracedRequest(
        base,
        model.path,
        fillerPrompt(1024, `overhead-${order}-${run}`),
        64,
        traceId,
      ));
      if (enabled) await collector.wait(traceId);
    }
    return results;
  } finally {
    await stopProcess(proc);
    await Bun.sleep(1_000);
  }
}

async function runOverhead(): Promise<void> {
  const off: RequestResult[] = [];
  const on: RequestResult[] = [];
  // Reverse the process order on the second pass to avoid assigning thermal
  // or page-cache order to the observer.
  for (const [order, sequence] of [[0, [false, true]], [1, [true, false]]] as const) {
    for (const enabled of sequence) {
      console.log(`overhead pass ${order + 1}: trace ${enabled ? "on" : "off"}`);
      (enabled ? on : off).push(...await runOverheadLeg(enabled, order));
    }
  }
  const ttftOff = median(off.map((r) => r.ttftMs));
  const ttftOn = median(on.map((r) => r.ttftMs));
  const totalOff = median(off.map((r) => r.totalMs));
  const totalOn = median(on.map((r) => r.totalMs));
  const delta = (a: number, b: number) => ((b / a - 1) * 100);
  console.log(`trace overhead (n=${off.length} each):`);
  console.log(`  TTFT ${ttftOff.toFixed(2)} -> ${ttftOn.toFixed(2)} ms (${delta(ttftOff, ttftOn).toFixed(2)}%)`);
  console.log(`  total ${totalOff.toFixed(2)} -> ${totalOn.toFixed(2)} ms (${delta(totalOff, totalOn).toFixed(2)}%)`);
  if (Math.abs(delta(ttftOff, ttftOn)) > 2 || Math.abs(delta(totalOff, totalOn)) > 2)
    process.exitCode = 1;
}

async function runObservation(
  modelKey: string,
  model: ModelSpec,
  arm: Arm,
  targetTokens: number,
  run: number,
  scenario: Scenario,
  samples: Sample[],
): Promise<void> {
  const collector = new TraceCollector();
  const command = commandFor(arm, model, PORT);
  const proc = Bun.spawn(command, {
    cwd: ROOT,
    stdout: "ignore",
    stderr: "pipe",
    env: {
      ...process.env,
      MLX_BUN_P2R_TRACE: "1",
      ...(flag("attribution") ? { MLX_BUN_P2R_SYNC: "1" } : {}),
    },
  });
  collector.pump(proc.stderr);
  const base = `http://127.0.0.1:${PORT}`;
  try {
    await waitReady(base);
    console.log(`  ready pid=${proc.pid}`);
    // Warm weights and generated decode graphs, but do not retain a prefix
    // that any measured prompt can match (all measurements nonce at token 0).
    const warmId = `${modelKey}-${arm}-${scenario}-warm-${crypto.randomUUID()}`;
    await tracedRequest(
      base, model.path, "Warm up.", Number(opt("warmup-tokens", "2")), warmId, true,
    );
    await collector.wait(warmId);

    // Identical text for every arm. Random per-arm nonces silently turn the
    // cross-stack prompt-token gate into a comparison of different inputs.
    const nonce = `p2r-${modelKey}-${targetTokens}-${run}`;
    const basePrompt = fillerPrompt(targetTokens, nonce);
    const partialBase = fillerPrompt(
      Math.max(32, Math.floor(targetTokens / 2)),
      `${nonce}-partial-base`,
    );
    let requests: Array<[CacheState | "prime", string, number, boolean]>;
    if (scenario === "miss-full") {
      requests = [
        ["miss", basePrompt, 1, true],
        // Generation needs a strict-prefix cache. Extending the just-primed
        // miss prompt by a few tokens is the portable full-hit definition,
        // including hybrid Qwen caches that cannot trim an equal-length hit.
        ["full", `${basePrompt} continued`, 1, true],
      ];
    } else if (scenario === "partial") {
      requests = [
        // Partial-hit measurement gets its own half-length cold prime.
        ["prime", partialBase, 1, false],
        ["partial", `${partialBase}\n${fillerPrompt(
          Math.max(32, Math.ceil(targetTokens / 2)),
          `${nonce}-partial-tail`,
        )}`, 1, true],
      ];
    } else {
      requests = [
        ["miss", fillerPrompt(targetTokens, `${nonce}-decode64`), 64, true],
      ];
    }
    for (const [cacheState, prompt, maxTokens, record] of requests) {
      const traceId = [modelKey, arm, targetTokens, run, cacheState, maxTokens, crypto.randomUUID()].join("-");
      const client = await tracedRequest(base, model.path, prompt, maxTokens, traceId, true);
      const trace = await collector.wait(traceId);
      if (!record) continue;
      samples.push({
        timestamp: new Date().toISOString(),
        model: modelKey,
        modelLabel: model.label,
        arm,
        cacheState: cacheState as CacheState,
        targetTokens,
        promptTokens: client.promptTokens,
        completionTokens: client.completionTokens,
        maxTokens,
        run,
        clientTtftMs: client.ttftMs,
        clientTotalMs: client.totalMs,
        trace,
      });
      console.log(
        `  ${targetTokens}/${cacheState}/${maxTokens} run ${run + 1}: ` +
        `${client.promptTokens} tok, client ${client.ttftMs.toFixed(1)} ms, ` +
        `server first ${firstResponseStart(trace).toFixed(1)} ms`,
      );
    }
  } catch (error) {
    throw new Error(`${(error as Error).message}\nstderr:\n${collector.stderrTail.join("\n")}`);
  } finally {
    await stopProcess(proc);
    await Bun.sleep(1_500);
  }
}

function validateMatchedCounts(samples: Sample[]): string[] {
  const errors: string[] = [];
  const groups = new Map<string, Sample[]>();
  for (const sample of samples) {
    const key = [sample.model, sample.targetTokens, sample.run, sample.cacheState, sample.maxTokens].join("/");
    const group = groups.get(key) ?? [];
    group.push(sample);
    groups.set(key, group);
  }
  for (const [key, group] of groups) {
    const counts = new Set(group.map((sample) => sample.promptTokens));
    if (counts.size > 1)
      errors.push(`${key}: prompt_tokens differ (${group.map((s) => `${s.arm}=${s.promptTokens}`).join(", ")})`);
  }
  return errors;
}

function renderReport(
  samples: Sample[],
  machine: string,
  countErrors: string[],
  benchmarkNote: string,
): string {
  const lines = [
    `# Prompt-to-response attribution — ${new Date().toISOString().slice(0, 10)}`,
    "",
    `machine: ${machine}`,
    `commit: ${Bun.spawnSync(["git", "rev-parse", "--short", "HEAD"]).stdout.toString().trim()}`,
    `toolchain: Bun ${Bun.version}; oracle ${PY}`,
    ...(benchmarkNote ? [`note: ${benchmarkNote}`] : []),
    "",
    "All rows are medians from real streamed HTTP requests after model warmup. `prefill` and `token 0` are additive; `server first` is the handler-to-first-write wall clock. `client remainder` is client TTFT minus that server clock and includes dispatch plus localhost delivery. Chunk spans are children of prefill and are not added again.",
    "",
  ];
  const keys = [...new Set(samples.map((s) => `${s.model}/${s.arm}`))];
  for (const key of keys) {
    const [model, arm] = key.split("/") as [string, Arm];
    const allCell = samples.filter((s) => s.model === model && s.arm === arm);
    const cell = allCell.filter((s) => s.maxTokens === 1);
    const decode = allCell.filter((s) => s.maxTokens > 1);
    lines.push(`## ${allCell[0]?.modelLabel ?? model} — ${arm}`, "");
    if (cell.length) {
      lines.push("| cache | target | measured tok | cached tok | n | client TTFT ms | prompt prep | queue | cache | batch setup | chunk work | prefill gaps | prefill wall | token 0 | server first | client remainder | prefill tok/s |", "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|");
      for (const target of [...new Set(cell.map((s) => s.targetTokens))]) {
        for (const state of ["miss", "full", "partial"] as const) {
          const rows = cell.filter((s) => s.targetTokens === target && s.cacheState === state);
          if (!rows.length) continue;
          const med = (f: (sample: Sample) => number) => median(rows.map(f));
          const prompt = med((s) => phaseDuration(s.trace, "request.prompt_prepare"));
          const queue = med((s) => phaseDuration(s.trace, "engine.admission_wait"));
          const cache = med((s) => phaseDuration(s.trace, "cache.lookup_restore"));
          const setup = med((s) => phaseDuration(s.trace, "prefill.batch_setup"));
          const chunks = med((s) => phaseDuration(s.trace, "prefill.chunk"));
          const prefill = med((s) => phaseDuration(s.trace, "prefill.total"));
          const token0 = med((s) => phaseDuration(s.trace, "token_zero.total"));
          const serverFirst = med((s) => firstResponseStart(s.trace));
          const client = med((s) => s.clientTtftMs);
          const tokens = med((s) => s.promptTokens);
          const cached = med((s) => {
            const event = s.trace.events.find((e) => e.phase === "prefill.total");
            return Number(event?.attributes?.cachedTokens ?? 0);
          });
          lines.push(`| ${state} | ${target} | ${tokens.toFixed(0)} | ${cached.toFixed(0)} | ${rows.length} | ${client.toFixed(1)} | ${prompt.toFixed(1)} | ${queue.toFixed(1)} | ${cache.toFixed(1)} | ${setup.toFixed(1)} | ${chunks.toFixed(1)} | ${Math.max(0, prefill - setup - chunks).toFixed(1)} | ${prefill.toFixed(1)} | ${token0.toFixed(1)} | ${serverFirst.toFixed(1)} | ${(client - serverFirst).toFixed(1)} | ${prefill > 0 ? ((tokens - cached) / prefill * 1000).toFixed(1) : "—"} |`);
        }
      }
      lines.push("");
    }
    if (decode.length) {
      lines.push("| decode target | measured prompt tok | completion tok | n | client TTFT ms | client total ms | prefill wall | token 0 | post-first decode ms | steady decode tok/s |", "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|");
      for (const target of [...new Set(decode.map((s) => s.targetTokens))]) {
        const rows = decode.filter((s) => s.targetTokens === target);
        const med = (f: (sample: Sample) => number) => median(rows.map(f));
        const decodeMs = med((s) => s.clientTotalMs - s.clientTtftMs);
        const decodeTps = med((s) => {
          const duration = s.clientTotalMs - s.clientTtftMs;
          return duration > 0 ? Math.max(0, s.completionTokens - 1) / duration * 1000 : 0;
        });
        lines.push(`| ${target} | ${med((s) => s.promptTokens).toFixed(0)} | ${med((s) => s.completionTokens).toFixed(0)} | ${rows.length} | ${med((s) => s.clientTtftMs).toFixed(1)} | ${med((s) => s.clientTotalMs).toFixed(1)} | ${med((s) => phaseDuration(s.trace, "prefill.total")).toFixed(1)} | ${med((s) => phaseDuration(s.trace, "token_zero.total")).toFixed(1)} | ${decodeMs.toFixed(1)} | ${decodeTps.toFixed(1)} |`);
      }
      lines.push("");
    }
  }
  if (countErrors.length) {
    lines.push("## Invalid cross-arm comparisons", "", ...countErrors.map((error) => `- ${error}`), "");
  }
  lines.push("## Trace contract notes", "");
  lines.push("- mlx-lm body parsing occurs before its request object reaches the wrapped handler, so `request.body_parse` is unavailable there and is excluded from cross-stack additive comparisons.");
  lines.push("- Product-mode spans preserve normal asynchronous execution. Container spans (`completion.total`) and per-chunk child spans overlap their named parent and are never summed into the additive row.");
  return lines.join("\n") + "\n";
}

async function main(): Promise<void> {
  if (flag("help") || flag("h")) {
    console.log(USAGE);
    return;
  }
  if (flag("overhead")) {
    await runOverhead();
    return;
  }
  const quick = flag("quick");
  const contexts = opt("contexts", quick ? "128,1024" : "128,256,1024,4096,16384")
    .split(",").map(Number).filter((n) => n > 0);
  const shortRuns = Number(opt("short-runs", quick ? "1" : "7"));
  const longRuns = Number(opt("long-runs", quick ? "1" : "3"));
  const fullRuns = Number(opt("full-runs", quick ? "0" : "1"));
  const selectedScenarios = opt("scenarios", "")
    .split(",").filter(Boolean) as Scenario[];
  const modelKeys = opt("models", "cpm5,e4b,12B,qwen27b,qwencompact").split(",");
  const arms = opt("arms", "mlx-bun,mlx-bun-serial,mlx-lm").split(",") as Arm[];
  const out = opt("out", `${ROOT}/reports/prompt-response-${new Date().toISOString().slice(0, 10)}.md`);
  const raw = opt("raw", out.replace(/\.md$/, ".jsonl"));
  const benchmarkNote = opt("note", "");
  const machine = `${Bun.spawnSync(["sysctl", "-n", "machdep.cpu.brand_string"]).stdout.toString().trim()} · ` +
    `${(Number(Bun.spawnSync(["sysctl", "-n", "hw.memsize"]).stdout.toString().trim()) / 2 ** 30).toFixed(0)} GB`;
  const samples: Sample[] = [];
  const failures: string[] = [];
  for (let modelIndex = 0; modelIndex < modelKeys.length; modelIndex++) {
    const modelKey = modelKeys[modelIndex]!;
    const model = MODELS[modelKey];
    if (!model || !existsSync(`${model.path}/config.json`)) {
      failures.push(`${modelKey}: model missing at ${model?.path ?? "unknown"}`);
      continue;
    }
    const eligibleContexts = contexts.filter((n) => n <= (model.maxContext ?? Infinity));
    for (let contextIndex = 0; contextIndex < eligibleContexts.length; contextIndex++) {
      const context = eligibleContexts[contextIndex]!;
      const runs = context <= 1024 ? shortRuns : longRuns;
      for (let run = 0; run < runs; run++) {
        // Rotate the first stack on every repetition. Each observation owns a
        // fresh warm-loaded process so retained prompt caches, hybrid SSM state,
        // allocator pools, and arm order cannot bias later samples.
        const offset = (modelIndex + contextIndex + run) % arms.length;
        const runArms = [...arms.slice(offset), ...arms.slice(0, offset)];
        const scenarios: Scenario[] = selectedScenarios.length
          ? selectedScenarios
          : [
              "miss-full",
              "partial",
              ...(run < fullRuns ? ["decode64" as const] : []),
            ];
        for (const scenario of scenarios) {
          for (const arm of runArms) {
            console.log(
              `=== ${modelKey}/${arm}@${context} run ${run + 1}/${runs} ${scenario} ===`,
            );
            try {
              // Each cache scenario owns a process. At 16k, retaining the
              // unrelated miss/full and partial caches together can exceed the
              // oracle's memory budget before the measured request begins.
              await runObservation(
                modelKey, model, arm, context, run, scenario, samples,
              );
            } catch (error) {
              const message = `${modelKey}/${arm}@${context}/run-${run + 1}/${scenario}: ${(error as Error).message}`;
              console.error(message);
              failures.push(message);
            }
            mkdirSync(dirname(raw), { recursive: true });
            await Bun.write(raw, samples.map((sample) => JSON.stringify(sample)).join("\n") + (samples.length ? "\n" : ""));
          }
        }
      }
    }
  }
  const countErrors = validateMatchedCounts(samples);
  mkdirSync(dirname(out), { recursive: true });
  await Bun.write(out, renderReport(samples, machine, countErrors, benchmarkNote));
  console.log(`raw: ${raw}`);
  console.log(`report: ${out}`);
  if (countErrors.length) console.error(`prompt-token parity failures: ${countErrors.length}`);
  if (failures.length) {
    console.error(`cell failures:\n${failures.join("\n")}`);
    process.exitCode = 1;
  }
}

await main();
