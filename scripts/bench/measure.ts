// Real servers, real HTTP: main's measurement session (scripts/bench-serve.ts
// at 02d723a), with its phases, samples, prompts, budgets and retry policy,
// driving an explicit command instead of a hardcoded CLI path. Each server
// runs as a supervised process group: terminated, killed if needed, joined.
import { spawn, type ChildProcess } from "node:child_process";
import { createHash } from "node:crypto";
import { appendFileSync, existsSync, realpathSync } from "node:fs";
import type { Phase } from "./plan";
import { fileSha } from "./plan";

// ---- phase budgets (main B1) -------------------------------------------------
export const FIXED_BUDGET_MS = 120_000;
export const CTX_MIN_BUDGET_MS = 180_000;
const BUDGET_SAFETY = 4;
const NO_MEASUREMENT_BUDGET_MS = 600_000;
const DRAIN_PROBE_BUDGET_MS = 30_000;
const STDERR_TAIL_LINES = 30;

/** tokens/tps scaled budget with a floor; generous when the rate is unknown. */
export function scaledBudgetMs(tokens: number, tps: number, minMs: number, safety = BUDGET_SAFETY): number {
  if (!(tps > 0) || !(tokens > 0)) return Math.max(minMs, NO_MEASUREMENT_BUDGET_MS);
  return Math.max(minMs, (tokens / tps) * 1000 * safety);
}

/** Paired arms receive identical requests; a retry gets its own nonce. */
export function workloadNonce(seed: string, phase: string, attempt: number, index: number): string {
  return createHash("sha256").update(JSON.stringify([seed, phase, attempt, index])).digest("hex").slice(0, 12);
}

export const median = (xs: number[]): number => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? (s.length % 2 ? s[s.length >> 1]! : (s[(s.length >> 1) - 1]! + s[s.length >> 1]!) / 2) : 0;
};
export const spreadOf = (xs: number[]): number => xs.length < 2 ? 1 : Math.max(...xs) / Math.min(...xs);
/** Main's stability guard on one arm's own decode samples: max/min within the limit. */
export const decodeStable = (samples: number[], limit: number): boolean =>
  samples.length > 0 && samples.every(v => v > 0) && spreadOf(samples) <= limit;

/** Sized in characters; the actual length is recorded from usage.prompt_tokens,
 * so every stack receives the identical string even if tokenizers differ. */
export function fillerPrompt(targetTokens: number, nonce: string, charsPerTok = 3.6): string {
  const para = "Background context: the history of computation spans mechanical calculators, " +
    "vacuum tubes, transistors, integrated circuits, and modern GPU-accelerated systems " +
    "used for machine learning workloads on unified-memory architectures. ";
  let s = `Session ${nonce}. `;
  while (s.length < targetTokens * charsPerTok) s += para;
  return s + " In one short sentence, what is this text about?";
}
export function aggregateBenchmarkPrompt(contextTarget: number, index: number, nonce: string): string {
  const task = `Agent ${index} ${nonce}: write a detailed essay about computers.`;
  return contextTarget ? `${fillerPrompt(contextTarget, nonce)}\n${task}` : task;
}

// ---- HTTP measurement primitives ----------------------------------------------
export interface ReqResult {
  textSha256?: string;
  ttftMs: number; headersMs: number; firstByteMs: number; firstEventMs: number;
  outputEventTimesMs: number[]; toolCallChunks: number; doneSeen: boolean;
  /** Observed content-stream interval; SSE chunks need not be single tokens. */
  decodeTps: number; wallMs: number; endToEndTps: number; contentChunks: number;
  finishReason: string | null; promptTokens: number; cachedTokens: number; genTokens: number;
  usedUsage: boolean; usage?: Readonly<Record<string, unknown>>; text: string;
}
export interface ReqOpts { apiKey?: string; modelId?: string; bodyExtra?: Record<string, unknown>; timeoutMs?: number;
  /** Aborts the request together with its budget (sibling failure, parent interrupt). */
  signal?: AbortSignal }

export function measureChatRequest(base: string, content: string, maxTokens: number, o: ReqOpts = {}): Promise<ReqResult> {
  return measureStreamRequest(base, "chat/completions", {
    messages: [{ role: "user", content }], chat_template_kwargs: { enable_thinking: true },
  }, maxTokens, o);
}
export function measureCompletionRequest(base: string, prompt: string, maxTokens: number, o: ReqOpts = {}): Promise<ReqResult> {
  return measureStreamRequest(base, "completions", { prompt }, maxTokens, o);
}

/** One streamed request. Token counts come from usage only (a chunk can carry
 * several tokens). The budget covers headers and the whole body; an aborted
 * or failed stream cancels its reader so the connection is released. */
export async function measureStreamRequest(base: string, route: "chat/completions" | "completions",
  input: Record<string, unknown>, maxTokens: number, o: ReqOpts): Promise<ReqResult> {
  const t0 = performance.now();
  const budget = AbortSignal.timeout(o.timeoutMs ?? FIXED_BUDGET_MS);
  const signal = o.signal ? AbortSignal.any([budget, o.signal]) : budget;
  const r = await fetch(`${base}/v1/${route}`, {
    method: "POST", signal,
    headers: { "content-type": "application/json", ...(o.apiKey ? { authorization: `Bearer ${o.apiKey}` } : {}) },
    body: JSON.stringify({
      model: o.modelId ?? "bench", stream: true, max_tokens: maxTokens, temperature: 0,
      ...input, stream_options: { include_usage: true }, ...(o.bodyExtra ?? {}),
    }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const headersMs = performance.now() - t0;
  const reader = r.body!.getReader(), dec = new TextDecoder();
  let buf = "", tFirst = 0, tLast = 0, chunkTokens = 0, toolCallChunks = 0, firstByteMs = 0, firstEventMs = 0, doneSeen = false;
  const outputEventTimesMs: number[] = [];
  let text = "", finishReason: string | null = null;
  interface Usage extends Record<string, unknown> {
    prompt_tokens?: number; completion_tokens?: number; prompt_tokens_details?: { cached_tokens?: number };
  }
  let usage: Usage | null = null;
  const parseLine = (line: string) => {
    if (!line.startsWith("data:")) return;
    const now = performance.now();
    if (!firstEventMs) firstEventMs = now - t0;
    const payload = line.slice(5).trim();
    if (payload === "[DONE]") { doneSeen = true; return; }
    let j: { choices?: Array<{ text?: string; delta?: { content?: string; reasoning?: string; reasoning_content?: string;
      tool_calls?: Array<{ function?: { name?: string; arguments?: string } }> }; finish_reason?: string | null }>;
      usage?: Usage | null; error?: unknown };
    try { j = JSON.parse(payload); } catch { throw new Error(`malformed SSE JSON: ${payload.slice(0, 120)}`); }
    if (j.error) throw new Error(`SSE error: ${JSON.stringify(j.error).slice(0, 300)}`);
    if (j.choices?.[0]?.finish_reason) finishReason = j.choices[0].finish_reason;
    const delta = j.choices?.[0]?.delta;
    const piece = route === "completions" ? (j.choices?.[0]?.text ?? "") :
      (delta?.content ?? "") + (delta?.reasoning ?? delta?.reasoning_content ?? "");
    const toolOutput = delta?.tool_calls?.some(call => call.function?.name || call.function?.arguments);
    if (piece || toolOutput) {
      if (!tFirst) tFirst = now;
      tLast = now;
      outputEventTimesMs.push(now - t0);
      if (piece) chunkTokens++;
      if (toolOutput) toolCallChunks++;
      text += piece;
    }
    if (j.usage && typeof j.usage.completion_tokens === "number") usage = j.usage;
  };
  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) { buf += dec.decode(); if (buf.trim()) parseLine(buf.trim()); break; }
      if (value.byteLength && !firstByteMs) firstByteMs = performance.now() - t0;
      buf += dec.decode(value, { stream: true });
      for (let nl; (nl = buf.indexOf("\n")) >= 0;) { const line = buf.slice(0, nl).trim(); buf = buf.slice(nl + 1); parseLine(line); }
    }
  } catch (error) { await reader.cancel(error).catch(() => {}); throw error; }
  finally { reader.releaseLock(); }
  const wallMs = performance.now() - t0;
  const finalUsage = usage as Usage | null;
  if (!finalUsage || !Number.isInteger(finalUsage.completion_tokens) || finalUsage.completion_tokens! < 0 ||
      !Number.isInteger(finalUsage.prompt_tokens) || finalUsage.prompt_tokens! < 0)
    throw new Error("missing/invalid token usage; SSE chunk counts cannot measure token throughput");
  if (!doneSeen || !finishReason) throw new Error("incomplete SSE response: finish reason and [DONE] are required");
  if (!tFirst) throw new Error(`no output; TTFT undefined (completion_tokens=${finalUsage.completion_tokens}, finish_reason=${finishReason})`);
  const genTokens = finalUsage.completion_tokens!, dt = tLast - tFirst;
  return {
    ttftMs: tFirst - t0, headersMs, firstByteMs, firstEventMs, outputEventTimesMs, toolCallChunks, doneSeen,
    decodeTps: genTokens > 1 && dt > 0 ? ((genTokens - 1) * 1000) / dt : 0,
    wallMs, endToEndTps: genTokens * 1000 / wallMs, contentChunks: chunkTokens, finishReason,
    promptTokens: finalUsage.prompt_tokens!, cachedTokens: finalUsage.prompt_tokens_details?.cached_tokens ?? 0, genTokens,
    usedUsage: true, usage: finalUsage, text, textSha256: createHash("sha256").update(text).digest("hex"),
  };
}

export interface ProbeOut { text: string; promptTokens: number; completionTokens: number; finishReason: string; raw?: unknown }
/** Raw /v1/completions probe: no chat template, so prompt_tokens inequality is
 * tokenizer drift. The response is kept and must carry real output before any verdict. */
export async function completionProbe(base: string, prompt: string, o: ReqOpts): Promise<ProbeOut> {
  const r = await fetch(`${base}/v1/completions`, {
    method: "POST", signal: AbortSignal.timeout(o.timeoutMs ?? FIXED_BUDGET_MS),
    headers: { "content-type": "application/json", ...(o.apiKey ? { authorization: `Bearer ${o.apiKey}` } : {}) },
    body: JSON.stringify({ model: o.modelId ?? "bench", prompt, max_tokens: 64, temperature: 0, stream: false, ...(o.bodyExtra ?? {}) }),
  });
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${(await r.text()).slice(0, 300)}`);
  const raw = await r.json() as { choices?: Array<{ text?: unknown; finish_reason?: unknown }>;
    usage?: { prompt_tokens?: unknown; completion_tokens?: unknown } };
  const choice = raw.choices?.[0];
  const positive = (n: unknown): n is number => Number.isSafeInteger(n) && (n as number) > 0;
  if (!Array.isArray(raw.choices) || raw.choices.length !== 1 || typeof choice?.text !== "string" || !choice.text ||
      typeof choice.finish_reason !== "string" || !positive(raw.usage?.prompt_tokens) || !positive(raw.usage?.completion_tokens))
    throw new Error(`invalid completion probe response: ${JSON.stringify(raw).slice(0, 300)}`);
  return { text: choice.text, promptTokens: raw.usage.prompt_tokens, completionTokens: raw.usage.completion_tokens,
    finishReason: choice.finish_reason, raw };
}

export async function waitReady(base: string, apiKey: string | undefined, timeoutMs: number, assertAlive?: () => void,
  signal?: AbortSignal): Promise<number> {
  const t0 = performance.now();
  while (performance.now() - t0 < timeoutMs) {
    signal?.throwIfAborted();
    assertAlive?.();
    try {
      const r = await fetch(`${base}/v1/models`, { headers: apiKey ? { authorization: `Bearer ${apiKey}` } : {},
        signal: AbortSignal.timeout(2000) });
      if (r.ok) return performance.now() - t0;
    } catch { /* not up yet */ }
    await Bun.sleep(200);
  }
  throw new Error(`server not ready after ${timeoutMs} ms`);
}

/** prompt_tokens equality is the hard precondition: unequal counts mean the
 * stacks rendered different prompts, so a text comparison would be meaningless. */
export function probeVerdict(probe: "completion" | "chat", label: string,
  a: ProbeOut | null | undefined, b: ProbeOut | null | undefined): { ok: boolean | null; line: string } {
  const tag = `${label} [${probe}-probe]`;
  if (!a || !b) return { ok: null, line: `- **parity ?** ${tag}: probe missing on ${!a && !b ? "both arms" : !a ? "first arm" : "second arm"}` };
  if (a.promptTokens !== b.promptTokens) {
    const kind = probe === "completion" ? "TOKENIZER DRIFT" : "TEMPLATE/TOKENIZER DRIFT";
    return { ok: false, line: `- **parity ✗** ${tag}: ${kind} (${a.promptTokens} vs ${b.promptTokens}) — parity not attempted` };
  }
  if (!(a.promptTokens > 0)) return { ok: null, line: `- **parity ?** ${tag}: prompt token counts unverified` };
  if (!a.text || !b.text) return { ok: null, line: `- **parity ?** ${tag}: empty output cannot establish parity` };
  if (a.text === b.text && (a.completionTokens !== b.completionTokens || a.finishReason !== b.finishReason))
    return { ok: false, line: `- **parity ✗** ${tag}: equal text but completion tokens ${a.completionTokens}/${b.completionTokens}, finish ${a.finishReason}/${b.finishReason}` };
  if (a.text === b.text)
    return { ok: true, line: `- **parity ✓** ${tag}: observed greedy text identical (prompt_tokens ${a.promptTokens} both); token-ID/logit oracle still required` };
  let i = 0;
  while (i < Math.min(a.text.length, b.text.length) && a.text[i] === b.text[i]) i++;
  return { ok: false, line: `- **parity ✗** ${tag}: equal prompt token counts (${a.promptTokens}), diverged at char ${i}: ` +
    `…\`${a.text.slice(Math.max(0, i - 20), i + 20)}\` vs …\`${b.text.slice(Math.max(0, i - 20), i + 20)}\`` };
}

// ---- supervised server processes ----------------------------------------------
export class UnjoinedServerError extends Error {
  constructor(readonly pid: number, readonly stop: StopResult) {
    super(`server pid ${pid} was not joined after ${stop.actions.join(", ") || "stop"}; the campaign must stop`);
    this.name = "UnjoinedServerError";
  }
}
export interface StopResult { joined: boolean; actions: string[]; exitCode: number | null; signal: string | null }
export class ServerProcess {
  static readonly live = new Set<ServerProcess>();
  readonly exited: Promise<void>;
  readonly stderrDone: Promise<void>;
  #child: ChildProcess;
  constructor(readonly argv: string[], env: Record<string, string>, tail: string[], logPath: string, cwd?: string) {
    // Started inside its sandbox, so relative outputs never land in a source tree.
    this.#child = spawn(argv[0]!, argv.slice(1), { env, cwd, stdio: ["ignore", "ignore", "pipe"], detached: true });
    this.exited = new Promise(resolve => this.#child.once("exit", () => resolve()));
    this.stderrDone = new Promise(resolve => {
      let buffer = "";
      this.#child.stderr!.on("data", (chunk: Buffer) => {
        appendFileSync(logPath, chunk);
        buffer += chunk.toString();
        for (let nl; (nl = buffer.indexOf("\n")) >= 0;) {
          const line = buffer.slice(0, nl); buffer = buffer.slice(nl + 1);
          if (line.trim()) { tail.push(line); if (tail.length > STDERR_TAIL_LINES) tail.shift(); }
        }
      });
      this.#child.stderr!.once("close", () => resolve());
    });
    this.#child.once("error", error => { tail.push(`spawn error: ${error.message}`); });
    ServerProcess.live.add(this);
  }
  get pid(): number { return this.#child.pid ?? -1; }
  get exitCode(): number | null { return this.#child.exitCode; }
  get signalCode(): string | null { return this.#child.signalCode; }
  get running(): boolean { return this.#child.exitCode === null && this.#child.signalCode === null && this.pid > 0; }
  /** Any member of the owned process group still alive (the leader or a descendant). */
  get groupAlive(): boolean {
    if (this.pid <= 0) return false;
    try { process.kill(-this.pid, 0); return true; } catch { return false; }
  }
  /** TERM the whole group, KILL after the grace period, and confirm the join:
   * the leader has exited and no descendant remains in its group. */
  async stop(graceMs = 5_000, killWaitMs = 15_000): Promise<StopResult> {
    const actions: string[] = [];
    const gone = () => !this.running && !this.groupAlive;
    const wait = async (ms: number) => {
      for (const end = performance.now() + ms; performance.now() < end; await Bun.sleep(50)) if (gone()) return true;
      return gone();
    };
    if (!gone()) {
      for (const [sig, ms] of [["SIGTERM", graceMs], ["SIGKILL", killWaitMs]] as const) {
        try { process.kill(-this.pid, sig); actions.push(sig); } catch { /* group already gone */ }
        if (await wait(ms)) break;
      }
    }
    const joined = gone();
    if (joined) { await Promise.race([this.stderrDone, Bun.sleep(2_000)]); ServerProcess.live.delete(this); }
    return { joined, actions, exitCode: this.exitCode, signal: this.signalCode };
  }
}

/** MLX libraries a running process actually mapped (lsof), each with its hash.
 * Null when the loaded set cannot be observed: provenance is then incomplete. */
export function loadedMlxLibraries(pid: number, pinnedNames: readonly string[] = []): { path: string; sha256: string }[] | null {
  const listed = Bun.spawnSync(["lsof", "-p", String(pid), "-Fn"]);
  if (listed.exitCode !== 0) return null;
  const names = new Set(pinnedNames);
  const paths = [...new Set(listed.stdout.toString().split("\n").filter(line => line.startsWith("n"))
    .map(line => line.slice(1)).filter(path => /\/(libmlxc|libmlx|libjaccl)\.(dylib|so)$|\/mlx\.metallib$/.test(path) ||
      names.has(path.slice(path.lastIndexOf("/") + 1))))].sort();
  return paths.length ? paths.map(path => ({ path: existsSync(path) ? realpathSync(path) : path,
    sha256: existsSync(path) ? fileSha(path) : "unreadable" })) : null;
}

// ---- the per-cell session -------------------------------------------------------
export interface CellSpec {
  key: string;
  model: { id: string; path: string };
  /** Complete argv: the tree's or reference's command plus serve arguments. */
  command: string[];
  env: Record<string, string>;
  port: number;
  apiKey?: string;
  /** Tree servers expose a durability boundary before the restart phase. */
  flushBeforeRestart: boolean;
  logPath: string;
  /** Pinned runtime file names to look for among the process's mapped files. */
  pinnedLibraries?: readonly string[];
  /** Working directory: the cell's sandbox, outside every source tree. */
  cwd?: string;
}
export interface Workload {
  seed: string; decodeTokens: number; contextTokens: number; decodeRuns: number; ttftRuns: number;
  aggregateStreams: number; aggregateTokens: number; aggregateContext: number; aggregateStaggerMs: number;
  spreadLimit: number; withContext: boolean;
}
export interface PhaseFailure { phase: string; error: string; recovered: boolean; stderrTail: string[] }
export interface RawRequest {
  cell: string; phase: string; attempt: number; index: number;
  /** Milliseconds since the cell started: when the request was sent and when it settled. */
  startedMs?: number; settledMs?: number;
  request: { content: string; maxTokens: number; bodyExtra: Record<string, unknown> };
  requestSha256: string; result?: ReqResult; error?: string; stderrTail?: string[];
  processAtFailure?: { pid: number; exitCode: number | null; signal: string | null };
}
export interface RestartDurability {
  durable: boolean; flushMs: number; pendingSnapshots: number; pendingSpills: number; droppedSpills: number;
  failedSpills: number; longestDurablePrefixTokens: number; entries: number;
}
export interface CellResult {
  key: string; readyMs: number; idleRssMB: number;
  parity: { completion: ProbeOut; chat: ProbeOut } | null;
  peakRssMB: number; rssByLeg: Array<[string, number]>;
  coldStartMs: number | null;
  restart: null | { readyMs: number; ctxTtftMs: number; cachedTokens: number; durability: RestartDurability | null };
  decodeTps: number[] | null; decodeSpread: number | null; decodeStable: boolean | null;
  ttft: null | { coldMs: number[]; prefill1kTps: number[]; warmMs: number; warmCachedTokens: number };
  ctx: null | { promptTokens: number; prefillTps: number; ttftMs: number; decodeTps: number[]; cachedRepeatTtftMs: number };
  agg: null | { tps: number; perStream: number; wallMs: number; arrivalMs: number[]; ttftMs: number[]; promptTokens: number[]; cachedTokens: number[] };
  phaseFailures: PhaseFailure[];
  /** Phases that produced a measurement (possibly after one retry). */
  measured: Phase[];
  /** The MLX libraries the server process actually loaded, observed after warmup. */
  loadedLibraries: { path: string; sha256: string }[] | null;
  processes: Array<{ pid: number } & StopResult>;
}

export async function runCell(spec: CellSpec, workload: Workload, raw: RawRequest[],
  options: { readyTimeoutMs?: number; settleMs?: number; signal?: AbortSignal } = {}): Promise<CellResult> {
  const readyTimeoutMs = options.readyTimeoutMs ?? 600_000;
  const { apiKey } = spec, modelId = spec.model.path, base = `http://127.0.0.1:${spec.port}`;
  let activePhase = "startup", phaseAttempt = 0, phaseRequest = 0;
  const nonce = (index = 0) => workloadNonce(workload.seed, activePhase, phaseAttempt, index);
  const stderrTail: string[] = [];
  const processes: CellResult["processes"] = [];
  let proc = new ServerProcess(spec.command, spec.env, stderrTail, spec.logPath, spec.cwd);
  const cellStart = performance.now();
  /** A request's identity is claimed when it is scheduled, never when a delayed start runs. */
  const claim = () => ({ phase: activePhase, attempt: phaseAttempt, index: phaseRequest++ });
  const timedRequest = async (content: string, maxTokens: number, o: ReqOpts = {}, slot = claim()): Promise<ReqResult> => {
    // Every request also ends with the parent's interrupt.
    if (options.signal) o = { ...o, signal: o.signal ? AbortSignal.any([o.signal, options.signal]) : options.signal };
    const request = { content, maxTokens, bodyExtra: { temperature: 0, chat_template_kwargs: { enable_thinking: true }, ...o.bodyExtra } };
    const sample: RawRequest = { cell: spec.key, ...slot, startedMs: performance.now() - cellStart, request,
      requestSha256: createHash("sha256").update(JSON.stringify(request)).digest("hex") };
    raw.push(sample); // failed requests and retries are retained too
    try { sample.result = await measureChatRequest(base, content, maxTokens, o); return sample.result; }
    catch (e) {
      sample.error = String(e); sample.stderrTail = [...stderrTail];
      sample.processAtFailure = { pid: proc.pid, exitCode: proc.exitCode, signal: proc.signalCode };
      throw e;
    } finally { sample.settledMs = performance.now() - cellStart; }
  };
  const assertAlive = () => {
    if (!proc.running) throw new Error(`server exited before ready: code=${proc.exitCode} signal=${proc.signalCode}; ${stderrTail.join("\n").slice(-2000)}`);
  };
  const sampleRss = (): number => {
    const r = Bun.spawnSync(["ps", "-o", "rss=", "-p", String(proc.pid)]);
    return r.exitCode === 0 ? Number(r.stdout.toString().trim()) / 1024 : 0;
  };
  // The periodic sampler never blocks the event loop that timestamps the streams
  // (a synchronous ps call would delay observed token times by tens of ms).
  const sampleRssAsync = async (): Promise<number> => {
    const ps = Bun.spawn(["ps", "-o", "rss=", "-p", String(proc.pid)], { stdout: "pipe", stderr: "ignore" });
    const [text, code] = await Promise.all([new Response(ps.stdout).text(), ps.exited]);
    return code === 0 ? Number(text.trim()) / 1024 : 0;
  };
  let peakRssMB = 0, legPeakMB = 0, sampling = false;
  const rssByLeg: Array<[string, number]> = [];
  const rssTimer = setInterval(() => {
    if (sampling) return;
    sampling = true;
    void sampleRssAsync().then(mb => { if (mb > peakRssMB) peakRssMB = mb; if (mb > legPeakMB) legPeakMB = mb; })
      .finally(() => { sampling = false; });
  }, 500);
  const markLeg = (name: string) => { rssByLeg.push([name, legPeakMB]); legPeakMB = sampleRss(); };
  const phaseFailures: PhaseFailure[] = [], measured: Phase[] = [];
  let respawnUsed = false, serverDeclaredDead = false;
  /** A server that cannot be joined is fatal: the campaign must not start another cell. */
  const stopProc = async (graceMs = 5_000) => {
    const result = await proc.stop(graceMs);
    processes.push({ pid: proc.pid, ...result });
    if (!result.joined) throw new UnjoinedServerError(proc.pid, result);
    return result;
  };
  const drainProbe = async () => {
    try { await measureChatRequest(base, "ok", 1, { apiKey, modelId, timeoutMs: DRAIN_PROBE_BUDGET_MS }); return true; } catch { return false; }
  };
  /** Main's policy: on failure, drain-probe; alive → retry the phase once as a
   * unit; dead → respawn once per cell, then retry. A phase that still fails is
   * recorded with its stderr tail; measured phases survive. */
  const runPhase = async <T>(name: Phase, fn: () => Promise<T>): Promise<T | null> => {
    activePhase = name; phaseAttempt = 0; phaseRequest = 0;
    const errStr = (e: unknown) => `${(e as Error).name}: ${(e as Error).message}`.slice(0, 300);
    const record = (msg: string) => { phaseFailures.push({ phase: name, error: msg.slice(0, 500), recovered: false, stderrTail: [...stderrTail] }); };
    const interrupted = () => { record("interrupted by the parent"); return new Error(`interrupted during ${name}`); };
    if (options.signal?.aborted) throw interrupted();
    if (serverDeclaredDead) { record("skipped — server dead, respawn already used"); return null; }
    try { const value = await fn(); measured.push(name); return value; } catch (e1) {
      // An unjoined server is fatal; an interrupted run never retries or respawns.
      if (e1 instanceof UnjoinedServerError) throw e1;
      if (options.signal?.aborted) throw interrupted();
      const firstFailureStderr = [...stderrTail];
      if (!(await drainProbe())) {
        if (respawnUsed) { serverDeclaredDead = true; record(`${errStr(e1)} — server unresponsive, respawn already used`); return null; }
        respawnUsed = true;
        try {
          await stopProc();
          await Bun.sleep(1000);
          proc = new ServerProcess(spec.command, spec.env, stderrTail, spec.logPath, spec.cwd);
          await waitReady(base, apiKey, readyTimeoutMs, assertAlive, options.signal);
        } catch (e2) {
          if (e2 instanceof UnjoinedServerError) throw e2;
          record(`${errStr(e1)} — respawn failed: ${errStr(e2)}`); return null;
        }
      }
      phaseAttempt = 1; phaseRequest = 0;
      try {
        const value = await fn();
        phaseFailures.push({ phase: name, error: `${errStr(e1)}; recovered on retry. Compare only matching attempts and request hashes.`,
          recovered: true, stderrTail: firstFailureStderr });
        measured.push(name);
        return value;
      } catch (e2) {
        if (e2 instanceof UnjoinedServerError) throw e2;
        record(`${errStr(e1)} — retry: ${errStr(e2)}`); return null;
      }
    }
  };

  let failure: unknown;
  try {
    const readyMs = await waitReady(base, apiKey, readyTimeoutMs, assertAlive, options.signal);
    const idleRssMB = sampleRss();
    legPeakMB = idleRssMB;
    const coldStartMs = await runPhase("warmup", async () =>
      readyMs + (await timedRequest("Warmup: say hello.", 32, { apiKey, modelId, timeoutMs: 600_000 })).ttftMs);
    markLeg("warmup");
    // Lazily loading stacks have mapped their libraries by now.
    const loadedLibraries = loadedMlxLibraries(proc.pid, spec.pinnedLibraries);
    const parity = await runPhase("parity", async () => {
      const completion = await completionProbe(base, "The first eight prime numbers are", { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS });
      const chat = await timedRequest("List the first eight prime numbers, then briefly explain what makes a number prime.", 64,
        { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS, bodyExtra: { chat_template_kwargs: { enable_thinking: true } } });
      return { completion, chat: { text: chat.text, promptTokens: chat.promptTokens, completionTokens: chat.genTokens,
        finishReason: chat.finishReason ?? "" } };
    });
    markLeg("parity");
    // Fixed-count decode sampling; slow samples are retained, never dropped.
    const decode = await runPhase("decode", async () => {
      const tps: number[] = [];
      for (let i = 0; i < workload.decodeRuns; i++)
        tps.push((await timedRequest(`Run ${nonce(i)}: write a detailed essay about the history of computing.`,
          workload.decodeTokens, { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS })).decodeTps);
      return tps;
    });
    markLeg("decode");
    const decodeMedianTps = decode ? median(decode) : 0;
    // Cold ~1k TTFT (nonce-busted) then the exact repeat, as one phase.
    const ttft = await runPhase("ttft1k", async () => {
      const coldMs: number[] = [], prefill1kTps: number[] = [];
      let lastColdPrompt = "";
      for (let i = 0; i < workload.ttftRuns; i++) {
        lastColdPrompt = fillerPrompt(1024, nonce(i));
        const res = await timedRequest(lastColdPrompt, 8, { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS });
        coldMs.push(res.ttftMs);
        if (res.promptTokens > 0) prefill1kTps.push((res.promptTokens * 1000) / res.ttftMs);
      }
      const warm = await timedRequest(lastColdPrompt, 8, { apiKey, modelId, timeoutMs: FIXED_BUDGET_MS });
      return { coldMs, prefill1kTps, warmMs: warm.ttftMs, warmCachedTokens: warm.cachedTokens };
    });
    markLeg("ttft1k");
    // One long prefill, decode sampled on 64 tokens, two cached repeats.
    let ctxPrompt = "";
    const ctx = workload.withContext ? await runPhase("ctx", async () => {
      ctxPrompt = fillerPrompt(workload.contextTokens, nonce());
      const cold = await timedRequest(ctxPrompt, 64, { apiKey, modelId,
        timeoutMs: scaledBudgetMs(workload.contextTokens, ttft ? median(ttft.prefill1kTps) : 0, CTX_MIN_BUDGET_MS, 6) });
      const prefillTps = cold.promptTokens > 0 ? (cold.promptTokens * 1000) / cold.ttftMs : 0;
      const repBudget = scaledBudgetMs(cold.promptTokens || workload.contextTokens, prefillTps, CTX_MIN_BUDGET_MS);
      const decodeTps = [cold.decodeTps];
      let cachedRepeatTtftMs = -1;
      for (let i = 0; i < 2; i++) {
        const rep = await timedRequest(ctxPrompt, 64, { apiKey, modelId, timeoutMs: repBudget });
        decodeTps.push(rep.decodeTps); cachedRepeatTtftMs = rep.ttftMs;
      }
      return { promptTokens: cold.promptTokens, prefillTps, ttftMs: cold.ttftMs, decodeTps, cachedRepeatTtftMs };
    }) : null;
    markLeg("ctx");
    // Restart: flush durably (tree servers), stop and join, respawn, resend the long prompt.
    const restart = ctx ? await runPhase("restart", async () => {
      let durability: RestartDurability | null = null;
      if (spec.flushBeforeRestart) {
        const flushStarted = performance.now();
        const response = await fetch(`${base}/admin/cache/flush`, { method: "POST", signal: AbortSignal.timeout(600_000) });
        const flush = await response.json() as Record<string, unknown>;
        if (!response.ok || !flush.durable) throw new Error(`cache durability flush failed: ${JSON.stringify(flush).slice(0, 300)}`);
        const n = (key: string) => typeof flush[key] === "number" ? flush[key] as number : -1;
        durability = { durable: true, flushMs: performance.now() - flushStarted, pendingSnapshots: n("pendingSnapshots"),
          pendingSpills: n("pendingSpills"), droppedSpills: n("droppedSpills"), failedSpills: n("failedSpills"),
          longestDurablePrefixTokens: n("longest_durable_prefix_tokens"), entries: n("entries") };
      }
      await stopProc(spec.flushBeforeRestart ? 180_000 : 5_000);
      await Bun.sleep(1000);
      proc = new ServerProcess(spec.command, spec.env, stderrTail, spec.logPath, spec.cwd);
      const readyMs2 = await waitReady(base, apiKey, readyTimeoutMs, assertAlive, options.signal);
      const after = await timedRequest(ctxPrompt, 8, { apiKey, modelId,
        timeoutMs: scaledBudgetMs(ctx.promptTokens, ctx.prefillTps, CTX_MIN_BUDGET_MS) });
      return { readyMs: readyMs2, ctxTtftMs: after.ttftMs, cachedTokens: after.cachedTokens, durability };
    }) : null;
    markLeg("restart");
    // Four concurrent generations; budget is the serial worst case at the measured rate.
    const agg = await runPhase("agg", async () => {
      const budget = scaledBudgetMs(workload.aggregateTokens * workload.aggregateStreams, decodeMedianTps, FIXED_BUDGET_MS) +
        (workload.aggregateContext ? scaledBudgetMs(workload.aggregateContext * workload.aggregateStreams,
          ttft ? median(ttft.prefill1kTps) : 0, CTX_MIN_BUDGET_MS, 6) : 0);
      const prompts = Array.from({ length: workload.aggregateStreams }, (_, i) => aggregateBenchmarkPrompt(workload.aggregateContext, i, nonce(i)));
      const arrivalMs: number[] = [], t0 = performance.now();
      // One failure aborts its siblings (delayed starts never begin), and every
      // request settles before the phase fails, so a retry never overlaps it.
      const siblings = new AbortController();
      const settled = await Promise.allSettled(prompts.map(async (prompt, i) => {
        const slot = claim();
        if (i && workload.aggregateStaggerMs) await Bun.sleep(i * workload.aggregateStaggerMs);
        siblings.signal.throwIfAborted();
        options.signal?.throwIfAborted();
        arrivalMs[i] = performance.now() - t0;
        try { return await timedRequest(prompt, workload.aggregateTokens, { apiKey, modelId, timeoutMs: budget, signal: siblings.signal }, slot); }
        catch (error) { siblings.abort(error); throw error; }
      }));
      const rejected = settled.find(outcome => outcome.status === "rejected");
      if (rejected) throw (rejected as PromiseRejectedResult).reason;
      const rs = settled.map(outcome => (outcome as PromiseFulfilledResult<ReqResult>).value);
      const wallS = (performance.now() - t0) / 1000;
      return { tps: rs.reduce((a, r) => a + r.genTokens, 0) / wallS, perStream: rs.reduce((a, r) => a + r.decodeTps, 0) / rs.length,
        wallMs: wallS * 1000, arrivalMs, ttftMs: rs.map(r => r.ttftMs), promptTokens: rs.map(r => r.promptTokens),
        cachedTokens: rs.map(r => r.cachedTokens) };
    });
    markLeg("agg");
    const decodeSpread = decode ? spreadOf(decode) : null;
    return { key: spec.key, readyMs, idleRssMB, coldStartMs, restart, parity, peakRssMB, rssByLeg,
      decodeTps: decode, decodeSpread, decodeStable: decode ? decodeStable(decode, workload.spreadLimit) : null,
      ttft, ctx, agg, phaseFailures, measured, loadedLibraries, processes };
  } catch (error) { failure = error; throw error; }
  finally {
    clearInterval(rssTimer);
    let unjoined: unknown;
    try { await stopProc(); } catch (error) { unjoined = error; }
    // A cell that fails still reports whether its servers were joined.
    const evidence = { processes, stderrTail: [...stderrTail] };
    if (failure && typeof failure === "object") Object.assign(failure, evidence);
    // An unjoined server outranks any other outcome; the original failure stays attached.
    if (unjoined) { Object.assign(unjoined as object, evidence, failure ? { cause: failure } : {}); throw unjoined; }
    await Bun.sleep(options.settleMs ?? 1500); // port and GPU memory settle
  }
}

/** Stop every live server: the parent's signal path and final cleanup. */
export async function stopAll(): Promise<StopResult[]> {
  return Promise.all([...ServerProcess.live].map(server => server.stop()));
}
