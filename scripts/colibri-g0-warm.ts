// Bounded, same-process Colibri warm-cell harness. It launches one supplied
// SERVE=1 engine, sends the same exact PROMPT frame twice with a RESET between
// turns, records client-observed TTFT, then closes stdin so the engine exits.
// It never chooses or downloads a model: --binary and --model are mandatory.

import { createHash } from "node:crypto";
import { existsSync, mkdirSync, readFileSync, readdirSync, statSync } from "node:fs";
import { basename, join, resolve } from "node:path";

const READY = new TextEncoder().encode("\x01\x01READY\x01\x01\n");
const END = new TextEncoder().encode("\x01\x01END\x01\x01\n");
const encoder = new TextEncoder();

export type MtpMode = "on" | "off";

export interface WarmHarnessOptions {
  binary: string;
  model: string;
  prompt: Uint8Array;
  promptSource: string;
  out: string;
  mtp: MtpMode;
  maxTokens: number;
  temperature: number;
  topP: number;
  timeoutSeconds: number;
  cacheCap: number;
  expertBits: number;
  denseBits: number;
  extraEnv: Record<string, string>;
}

interface Stat {
  completion_tokens: number;
  tokens_per_second: number;
  cache_hit_percent: number;
  rss_gb: number;
  prompt_tokens: number | null;
  length_limited: boolean | null;
  extra: Record<string, string>;
}

interface Tiers {
  vram_experts: number;
  ram_experts: number;
  disk_experts: number;
  vram_gb: number;
  ram_gb: number;
}

export interface EngineTurnTrace {
  engine_prefill_to_first_s: number;
  elapsed_s: number;
  produced: number;
  token_ids: number[] | null;
  verify_rows: number;
  mtp_raw_proposals: number;
  mtp_verified_proposals: number;
  mtp_accepted: number;
  mtp_rejected_or_discarded: number;
  mtp_rejection_events: number;
  acceptance_length_histogram: Record<string, number>;
  verify_seconds: number;
  forwards: number;
  tokens_per_forward: number;
  expert_fetched_gb: number;
  expert_read_service_seconds: number;
  expert_wait_seconds: number;
  pinned_hits: number;
  lru_hits: number;
  expert_load_misses: number;
  resident_pinned_experts: number;
  resident_lru_experts: number;
  resident_expert_gb: number;
  client_minus_engine_ttft_s: number;
}

export interface TurnResult {
  cache_state: "first-turn-in-process" | "warm-explicit-lru";
  client_ttft_s: number;
  response_bytes: number;
  response_sha256: string;
  response_file: string;
  stat: Stat;
  engine_trace: EngineTurnTrace;
}

export interface WarmHarnessResult {
  schema_version: 3;
  capture_kind: "colibri_glm52_same_process_warm_pair";
  complete: boolean;
  error: string | null;
  timed_out: boolean;
  process: {
    exit_code: number;
    signal_code: string | null;
    launcher_pid: number | null;
    engine_pid: number | null;
    maximum_resident_set_bytes: number | null;
    process_swaps: number | null;
    peak_memory_footprint_bytes: number | null;
  };
  same_process: true;
  process_pid: number | null;
  protocol_sequence: string[];
  ready: { preamble_bytes: number; observed_draft: number; stat: Stat; tiers: Tiers } | null;
  turns: TurnResult[];
  reset_stat: Stat | null;
  identical_prompt_frames: true;
  artifacts: { manifest: string; stdout: string; stderr: string; prompt: string };
}

interface WarmManifest {
  schema_version: number;
  capture_kind: string;
  engine_command: string[];
  launcher_command?: string[];
  engine_binary?: { path: string; bytes: number; sha256: string };
  env_overrides: Record<string, string>;
  inherited_environment: boolean;
  mtp: MtpMode;
  prompt: { file: string; bytes: number; sha256: string; source: string };
  request: { max_tokens: number; temperature: number; top_p: number };
  timeout_seconds: number;
  protocol: string;
  analysis?: {
    analyzer: { path: string; sha256: string };
    stderr: { path: string; sha256: string };
    ttft_boundary: string;
    client_engine_tolerance_s: number;
  };
}

const TTFT_BOUNDARY = "client: PROMPT frame flush to first stdout response byte; engine: after frame parsing/tokenization, immediately before prefill to first token callback";
const CLIENT_ENGINE_TTFT_TOLERANCE_S = 0.05;

function sha256(bytes: Uint8Array | ArrayBuffer): string {
  const view = bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
  return createHash("sha256").update(view).digest("hex");
}

function parseProcessUsage(stderr: string): Pick<WarmHarnessResult["process"],
  "maximum_resident_set_bytes" | "process_swaps" | "peak_memory_footprint_bytes"> {
  const integer = (pattern: RegExp): number | null => {
    const match = stderr.match(pattern);
    return match ? Number(match[1]) : null;
  };
  return {
    maximum_resident_set_bytes: integer(/^\s*(\d+)\s+maximum resident set size$/m),
    process_swaps: integer(/^\s*(\d+)\s+swaps$/m),
    peak_memory_footprint_bytes: integer(/^\s*(\d+)\s+peak memory footprint$/m),
  };
}

function childPid(launcherPid: number): number | null {
  const result = Bun.spawnSync(["/usr/bin/pgrep", "-P", String(launcherPid)], {
    stdout: "pipe",
    stderr: "pipe",
  });
  if (result.exitCode !== 0) return null;
  const candidates = new TextDecoder().decode(result.stdout).trim().split(/\s+/).filter(Boolean).map(Number);
  return candidates.length === 1 && Number.isInteger(candidates[0]) ? candidates[0]! : null;
}

function concat(left: Uint8Array, right: Uint8Array): Uint8Array {
  const result = new Uint8Array(left.length + right.length);
  result.set(left);
  result.set(right, left.length);
  return result;
}

function indexOfBytes(haystack: Uint8Array, needle: Uint8Array): number {
  outer: for (let i = 0; i <= haystack.length - needle.length; i++) {
    for (let j = 0; j < needle.length; j++) if (haystack[i + j] !== needle[j]) continue outer;
    return i;
  }
  return -1;
}

class ProtocolReader {
  private readonly reader: { read(): Promise<{ done: boolean; value?: Uint8Array }> };
  private buffer: Uint8Array<ArrayBufferLike> = new Uint8Array();
  readonly rawChunks: Uint8Array<ArrayBufferLike>[] = [];

  constructor(stream: { getReader(): { read(): Promise<{ done: boolean; value?: Uint8Array }> } }) {
    this.reader = stream.getReader();
  }

  get bufferedBytes(): number {
    return this.buffer.length;
  }

  private async readMore(onFirstByte?: () => void): Promise<void> {
    const { value, done } = await this.reader.read();
    if (done || !value) throw new Error("Colibri stdout closed during protocol exchange");
    const copy = new Uint8Array(value);
    this.rawChunks.push(copy);
    if (copy.length > 0) onFirstByte?.();
    this.buffer = concat(this.buffer, copy);
  }

  async readUntil(sentinel: Uint8Array, onFirstByte?: () => void): Promise<Uint8Array> {
    let observed = false;
    const observe = (): void => {
      if (!observed) {
        observed = true;
        onFirstByte?.();
      }
    };
    if (this.buffer.length > 0) observe();
    while (true) {
      const index = indexOfBytes(this.buffer, sentinel);
      if (index >= 0) {
        const result = this.buffer.slice(0, index);
        this.buffer = this.buffer.slice(index + sentinel.length);
        return result;
      }
      await this.readMore(observe);
    }
  }

  async readLine(): Promise<string> {
    const newline = encoder.encode("\n");
    const bytes = await this.readUntil(newline);
    if (bytes.length > 1 << 20) throw new Error("Colibri protocol line exceeds 1 MiB");
    return new TextDecoder().decode(bytes).replace(/\r$/, "");
  }

  async drain(): Promise<void> {
    if (this.buffer.length > 0) this.buffer = new Uint8Array();
    while (true) {
      const { value, done } = await this.reader.read();
      if (done) return;
      if (value) this.rawChunks.push(value.slice());
    }
  }

  raw(): Uint8Array {
    return this.rawChunks.reduce((all, chunk) => concat(all, chunk), new Uint8Array());
  }
}

function parseNumber(value: string | undefined, label: string): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new Error(`invalid ${label}: ${value}`);
  return parsed;
}

export function parseStat(line: string): Stat {
  const fields = line.trim().split(/\s+/);
  if (fields.length < 5 || fields[0] !== "STAT") throw new Error(`invalid Colibri STAT: ${line}`);
  const extra: Record<string, string> = {};
  for (const field of fields.slice(7)) {
    const split = field.indexOf("=");
    if (split > 0) extra[field.slice(0, split)] = field.slice(split + 1);
  }
  return {
    completion_tokens: parseNumber(fields[1], "STAT completion tokens"),
    tokens_per_second: parseNumber(fields[2], "STAT tokens/second"),
    cache_hit_percent: parseNumber(fields[3], "STAT cache hit"),
    rss_gb: parseNumber(fields[4], "STAT RSS"),
    prompt_tokens: fields[5] === undefined ? null : parseNumber(fields[5], "STAT prompt tokens"),
    length_limited: fields[6] === undefined ? null : Boolean(parseNumber(fields[6], "STAT length-limited")),
    extra,
  };
}

export function parseTiers(line: string): Tiers {
  const fields = line.trim().split(/\s+/);
  if (fields.length !== 6 || fields[0] !== "TIERS") throw new Error(`invalid Colibri TIERS: ${line}`);
  return {
    vram_experts: parseNumber(fields[1], "TIERS VRAM experts"),
    ram_experts: parseNumber(fields[2], "TIERS RAM experts"),
    disk_experts: parseNumber(fields[3], "TIERS disk experts"),
    vram_gb: parseNumber(fields[4], "TIERS VRAM GB"),
    ram_gb: parseNumber(fields[5], "TIERS RAM GB"),
  };
}

interface VerifyTraceRow {
  fw: number;
  src: number;
  mtp: number;
  proposedRaw: number;
  proposed: number;
  accepted: number;
  tokens: number;
  forwardSeconds: number;
}

interface MutableEngineTrace {
  beginMono?: number;
  firstMono?: number;
  firstTtft?: number;
  elapsed?: number;
  produced?: number;
  tokenIds?: number[];
  rows: VerifyTraceRow[];
  forwards?: number;
  tokensPerForward?: number;
  expertFetchedGb?: number;
  expertReadServiceSeconds?: number;
  expertWaitSeconds?: number;
  pinnedHits?: number;
  lruHits?: number;
  expertLoadMisses?: number;
  residentPinnedExperts?: number;
  residentLruExperts?: number;
  residentExpertGb?: number;
}

function traceFor(map: Map<number, MutableEngineTrace>, turn: number): MutableEngineTrace {
  let trace = map.get(turn);
  if (!trace) {
    trace = { rows: [] };
    map.set(turn, trace);
  }
  return trace;
}

function requiredTraceNumber(value: number | undefined, turn: number, label: string): number {
  if (value === undefined || !Number.isFinite(value)) throw new Error(`trace turn ${turn} is missing ${label}`);
  return value;
}

export function parseEngineTrace(
  text: string,
  turns: ReadonlyArray<{ client_ttft_s: number; stat: { completion_tokens: number } }>,
  mtpMode: MtpMode,
): EngineTurnTrace[] {
  const traces = new Map<number, MutableEngineTrace>();
  let profilerTurn: number | null = null;
  for (const line of text.split(/\r?\n/)) {
    let match = line.match(/^\[G0_TRACE\] BEGIN turn=(\d+) mono_s=([\d.]+)$/);
    if (match) {
      const turn = parseNumber(match[1], "trace BEGIN turn");
      const trace = traceFor(traces, turn);
      if (trace.beginMono !== undefined) throw new Error(`duplicate trace BEGIN for turn ${turn}`);
      trace.beginMono = parseNumber(match[2], "trace BEGIN mono_s");
      profilerTurn = turn;
      continue;
    }
    match = line.match(/^\[G0_TRACE\] FIRST turn=(\d+) token=\d+ mono_s=([\d.]+) ttft_s=([\d.]+)$/);
    if (match) {
      const turn = parseNumber(match[1], "trace FIRST turn");
      const trace = traceFor(traces, turn);
      if (trace.firstMono !== undefined) throw new Error(`duplicate trace FIRST for turn ${turn}`);
      trace.firstMono = parseNumber(match[2], "trace FIRST mono_s");
      trace.firstTtft = parseNumber(match[3], "trace FIRST ttft_s");
      continue;
    }
    match = line.match(
      /^\[G0_TRACE\] VERIFY turn=(\d+) fw=(\d+) src=(\d+) mtp=(\d+) proposed_raw=(\d+) proposed=(\d+) accepted=(\d+) tokens=(\d+) forward_s=([\d.]+) mono_s=[\d.]+$/,
    );
    if (match) {
      const turn = parseNumber(match[1], "trace VERIFY turn");
      traceFor(traces, turn).rows.push({
        fw: parseNumber(match[2], "trace VERIFY fw"),
        src: parseNumber(match[3], "trace VERIFY src"),
        mtp: parseNumber(match[4], "trace VERIFY mtp"),
        proposedRaw: parseNumber(match[5], "trace VERIFY proposed_raw"),
        proposed: parseNumber(match[6], "trace VERIFY proposed"),
        accepted: parseNumber(match[7], "trace VERIFY accepted"),
        tokens: parseNumber(match[8], "trace VERIFY tokens"),
        forwardSeconds: parseNumber(match[9], "trace VERIFY forward_s"),
      });
      continue;
    }
    match = line.match(/^\[G0_TRACE\] END turn=(\d+) produced=(\d+) elapsed_s=([\d.]+)$/);
    if (match) {
      const turn = parseNumber(match[1], "trace END turn");
      const trace = traceFor(traces, turn);
      if (trace.elapsed !== undefined) throw new Error(`duplicate trace END for turn ${turn}`);
      trace.produced = parseNumber(match[2], "trace END produced");
      trace.elapsed = parseNumber(match[3], "trace END elapsed_s");
      profilerTurn = turn;
      continue;
    }
    match = line.match(/^\[G0_TRACE\] TOKENS turn=(\d+) count=(\d+) ids=(.*)$/);
    if (match) {
      const turn = parseNumber(match[1], "trace TOKENS turn");
      const trace = traceFor(traces, turn);
      if (trace.tokenIds !== undefined) throw new Error(`duplicate token dump for turn ${turn}`);
      const declared = parseNumber(match[2], "trace TOKENS count");
      const ids = match[3] === "" ? [] : match[3]!.split(",").map((value) => parseNumber(value, "trace token id"));
      if (ids.length !== declared) throw new Error(`token dump for turn ${turn} declares ${declared} ids but contains ${ids.length}`);
      trace.tokenIds = ids;
      continue;
    }
    match = line.match(/^\[PROF\] decode forwards: (\d+) \| .* \| ([\d.]+) tok\/forward$/);
    if (match && profilerTurn !== null) {
      const trace = traceFor(traces, profilerTurn);
      if (trace.forwards !== undefined) throw new Error(`duplicate profiler forwards for turn ${profilerTurn}`);
      trace.forwards = parseNumber(match[1], "profiler forwards");
      trace.tokensPerForward = parseNumber(match[2], "profiler tokens/forward");
      continue;
    }
    match = line.match(
      /^\[PROF\] expert I\/O: ([\d.]+) GB fetched .*?\| hit [\d.]+% \((\d+) pin \+ (\d+) lru \/ (\d+) load\).*?\| [\d.]+ loads\/token \| ([\d.]+)s read service \/ ([\d.]+)s felt wait$/,
    );
    if (match && profilerTurn !== null) {
      const trace = traceFor(traces, profilerTurn);
      trace.expertFetchedGb = parseNumber(match[1], "profiler expert fetched GB");
      trace.pinnedHits = parseNumber(match[2], "profiler pinned hits");
      trace.lruHits = parseNumber(match[3], "profiler LRU hits");
      trace.expertLoadMisses = parseNumber(match[4], "profiler expert load misses");
      trace.expertReadServiceSeconds = parseNumber(match[5], "profiler read service seconds");
      trace.expertWaitSeconds = parseNumber(match[6], "profiler felt wait seconds");
      continue;
    }
    match = line.match(
      /^\[PROF\] resident experts: (\d+) pinned \(([\d.]+) GB\) \+ (\d+) in LRU \(([\d.]+) GB, cap \d+\/layer\)$/,
    );
    if (match && profilerTurn !== null) {
      const trace = traceFor(traces, profilerTurn);
      trace.residentPinnedExperts = parseNumber(match[1], "profiler resident pinned experts");
      trace.residentLruExperts = parseNumber(match[3], "profiler resident LRU experts");
      trace.residentExpertGb = parseNumber(match[2], "profiler resident pinned GB")
        + parseNumber(match[4], "profiler resident LRU GB");
    }
  }

  if (traces.size !== turns.length) {
    throw new Error(`engine trace has ${traces.size} turns but result has ${turns.length}`);
  }
  return turns.map((turnResult, index) => {
    const turn = index + 1;
    const trace = traces.get(turn);
    if (!trace) throw new Error(`engine trace is missing turn ${turn}`);
    const beginMono = requiredTraceNumber(trace.beginMono, turn, "BEGIN");
    const firstMono = requiredTraceNumber(trace.firstMono, turn, "FIRST");
    const engineTtft = requiredTraceNumber(trace.firstTtft, turn, "FIRST ttft_s");
    const elapsed = requiredTraceNumber(trace.elapsed, turn, "END elapsed_s");
    const produced = requiredTraceNumber(trace.produced, turn, "END produced");
    const forwards = requiredTraceNumber(trace.forwards, turn, "profiler forwards");
    const tokensPerForward = requiredTraceNumber(trace.tokensPerForward, turn, "profiler tokens/forward");
    if (Math.abs((firstMono - beginMono) - engineTtft) > 0.00001) {
      throw new Error(`trace turn ${turn} FIRST ttft disagrees with monotonic timestamps`);
    }
    if (produced !== turnResult.stat.completion_tokens) {
      throw new Error(`trace turn ${turn} produced ${produced} tokens but STAT reports ${turnResult.stat.completion_tokens}`);
    }
    if (trace.tokenIds !== undefined && trace.tokenIds.length !== produced) {
      throw new Error(`trace turn ${turn} has ${trace.tokenIds.length} token ids but END reports ${produced}`);
    }
    trace.rows.forEach((row, rowIndex) => {
      if (row.fw !== rowIndex + 1) throw new Error(`trace turn ${turn} has non-contiguous VERIFY forwards`);
      if (row.proposed > row.proposedRaw || row.accepted > row.proposed || row.tokens !== 1 + row.accepted) {
        throw new Error(`trace turn ${turn} has an invalid VERIFY row at forward ${row.fw}`);
      }
      if (row.mtp !== 0 && row.mtp !== 1) throw new Error(`trace turn ${turn} has invalid mtp=${row.mtp}`);
    });
    if (forwards !== trace.rows.length) {
      throw new Error(`trace turn ${turn} has ${trace.rows.length} VERIFY rows but profiler reports ${forwards} forwards`);
    }
    if (forwards > 0 && Math.abs(produced / forwards - tokensPerForward) > 0.011) {
      throw new Error(`trace turn ${turn} tokens/forward disagrees with produced/forwards`);
    }
    const clientMinusEngine = turnResult.client_ttft_s - engineTtft;
    if (Math.abs(clientMinusEngine) > CLIENT_ENGINE_TTFT_TOLERANCE_S) {
      throw new Error(
        `trace turn ${turn} client and engine TTFT differ by ${clientMinusEngine.toFixed(6)}s `
        + `(allowed ${CLIENT_ENGINE_TTFT_TOLERANCE_S}s; ${TTFT_BOUNDARY})`,
      );
    }
    const mtpRows = trace.rows.filter((row) => row.mtp === 1 && row.src === 2 && row.proposed > 0);
    const rawProposals = mtpRows.reduce((sum, row) => sum + row.proposedRaw, 0);
    const verifiedProposals = mtpRows.reduce((sum, row) => sum + row.proposed, 0);
    const accepted = mtpRows.reduce((sum, row) => sum + row.accepted, 0);
    if (mtpMode === "off") {
      const hasMtpActivity = trace.rows.some((row) => row.mtp !== 0 || row.proposedRaw !== 0 || row.proposed !== 0 || row.accepted !== 0);
      if (hasMtpActivity || rawProposals !== 0 || verifiedProposals !== 0 || accepted !== 0) {
        throw new Error(`MTP-off trace turn ${turn} contains MTP proposal activity`);
      }
    } else if (trace.rows.some((row) => row.mtp !== 1)) {
      throw new Error(`MTP-on trace turn ${turn} contains a non-MTP VERIFY row`);
    }
    const histogram: Record<string, number> = {};
    for (const row of mtpRows) {
      const key = String(row.accepted);
      histogram[key] = (histogram[key] ?? 0) + 1;
    }
    return {
      engine_prefill_to_first_s: engineTtft,
      elapsed_s: elapsed,
      produced,
      token_ids: trace.tokenIds ?? null,
      verify_rows: trace.rows.length,
      mtp_raw_proposals: rawProposals,
      mtp_verified_proposals: verifiedProposals,
      mtp_accepted: accepted,
      mtp_rejected_or_discarded: rawProposals - accepted,
      mtp_rejection_events: mtpRows.filter((row) => row.accepted < row.proposed).length,
      acceptance_length_histogram: histogram,
      verify_seconds: trace.rows.reduce((sum, row) => sum + row.forwardSeconds, 0),
      forwards,
      tokens_per_forward: tokensPerForward,
      expert_fetched_gb: requiredTraceNumber(trace.expertFetchedGb, turn, "profiler expert fetched GB"),
      expert_read_service_seconds: requiredTraceNumber(trace.expertReadServiceSeconds, turn, "profiler read service seconds"),
      expert_wait_seconds: requiredTraceNumber(trace.expertWaitSeconds, turn, "profiler wait seconds"),
      pinned_hits: requiredTraceNumber(trace.pinnedHits, turn, "profiler pinned hits"),
      lru_hits: requiredTraceNumber(trace.lruHits, turn, "profiler LRU hits"),
      expert_load_misses: requiredTraceNumber(trace.expertLoadMisses, turn, "profiler expert load misses"),
      resident_pinned_experts: requiredTraceNumber(trace.residentPinnedExperts, turn, "resident pinned experts"),
      resident_lru_experts: requiredTraceNumber(trace.residentLruExperts, turn, "resident LRU experts"),
      resident_expert_gb: requiredTraceNumber(trace.residentExpertGb, turn, "resident expert GB"),
      client_minus_engine_ttft_s: clientMinusEngine,
    };
  });
}

function promptFrame(options: WarmHarnessOptions): Uint8Array {
  const header = encoder.encode(
    `\x02PROMPT ${options.prompt.length} ${options.maxTokens} ${options.temperature} ${options.topP}\n`,
  );
  return concat(concat(header, options.prompt), encoder.encode("\n"));
}

function cleanEnvironment(extra: Record<string, string>): Record<string, string> {
  const env: Record<string, string> = {};
  for (const [key, value] of Object.entries(process.env)) if (value !== undefined) env[key] = value;
  Object.assign(env, extra);
  return env;
}

function prepareOut(path: string): void {
  if (existsSync(path) && readdirSync(path).length > 0) throw new Error(`--out must be empty: ${path}`);
  mkdirSync(path, { recursive: true });
}

export async function runWarmHarness(options: WarmHarnessOptions): Promise<WarmHarnessResult> {
  if (options.prompt.length < 1) throw new Error("prompt must not be empty");
  if (options.prompt.includes(0)) throw new Error("prompt must not contain NUL bytes");
  prepareOut(options.out);
  const frame = promptFrame(options);
  const command = [options.binary, String(options.cacheCap), String(options.expertBits), String(options.denseBits)];
  const launcherCommand = ["/usr/bin/time", "-l", ...command];
  const binaryStat = statSync(options.binary);
  if (!binaryStat.isFile()) throw new Error(`--binary must be a regular file: ${options.binary}`);
  const envOverrides = {
    ...options.extraEnv,
    MTP: options.mtp === "on" ? "1" : "0",
    TOKENS: "1",
    SNAP: options.model,
    SERVE: "1",
    SERVE_BATCH: "0",
    DRAFT: options.mtp === "on" ? "3" : "0",
    NGEN: String(options.maxTokens),
  };
  const manifest: WarmManifest = {
    schema_version: 3,
    capture_kind: "colibri_glm52_same_process_warm_manifest",
    engine_command: command,
    launcher_command: launcherCommand,
    engine_binary: { path: options.binary, bytes: binaryStat.size, sha256: sha256(readFileSync(options.binary)) },
    env_overrides: envOverrides,
    inherited_environment: true,
    mtp: options.mtp,
    prompt: { file: "prompt.bin", bytes: options.prompt.length, sha256: sha256(options.prompt), source: options.promptSource },
    request: { max_tokens: options.maxTokens, temperature: options.temperature, top_p: options.topP },
    timeout_seconds: options.timeoutSeconds,
    protocol: "single process: READY+STAT+TIERS, PROMPT+END+STAT, RESET+END+STAT, identical PROMPT+END+STAT, EOF",
  };
  await Promise.all([
    Bun.write(join(options.out, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`),
    Bun.write(join(options.out, "prompt.bin"), options.prompt),
  ]);

  const proc = Bun.spawn(launcherCommand, {
    stdin: "pipe",
    stdout: "pipe",
    stderr: "pipe",
    env: cleanEnvironment(envOverrides),
  });
  const protocol = new ProtocolReader(proc.stdout);
  const stderrPromise = new Response(proc.stderr).bytes();
  let timedOut = false;
  let error: string | null = null;
  let ready: WarmHarnessResult["ready"] = null;
  let resetStat: Stat | null = null;
  let enginePid: number | null = null;
  const turns: Array<Omit<TurnResult, "engine_trace">> = [];
  const protocolSequence: string[] = [];
  const timeout = setTimeout(() => {
    timedOut = true;
    try { proc.kill(9); } catch { /* already exited */ }
  }, options.timeoutSeconds * 1000);

  const runTurn = async (index: number): Promise<void> => {
    if (protocol.bufferedBytes !== 0) throw new Error("unexpected buffered stdout before PROMPT");
    proc.stdin.write(frame);
    await proc.stdin.flush();
    const flushed = process.hrtime.bigint();
    let firstByte: bigint | null = null;
    const response = await protocol.readUntil(END, () => { firstByte ??= process.hrtime.bigint(); });
    const stat = parseStat(await protocol.readLine());
    if (firstByte === null) throw new Error("PROMPT completed without a response byte");
    const responseFile = `turn-${index}.response.bin`;
    await Bun.write(join(options.out, responseFile), response);
    turns.push({
      cache_state: index === 1 ? "first-turn-in-process" : "warm-explicit-lru",
      client_ttft_s: Number(firstByte - flushed) / 1e9,
      response_bytes: response.length,
      response_sha256: sha256(response),
      response_file: responseFile,
      stat,
    });
    protocolSequence.push(`PROMPT_${index}`, `END_${index}`, `STAT_${index}`);
  };

  try {
    const preamble = await protocol.readUntil(READY);
    protocolSequence.push("READY");
    enginePid = childPid(proc.pid);
    const preambleText = new TextDecoder().decode(preamble);
    const draftMatch = preambleText.match(/MTP (?:ACTIVE|absent).*?\(draft=(\d+)\)/);
    if (!draftMatch) throw new Error("Colibri preamble is missing the observed MTP draft setting");
    const observedDraft = Number(draftMatch[1]);
    const expectedDraft = options.mtp === "on" ? 3 : 0;
    if (observedDraft !== expectedDraft) {
      throw new Error(`requested MTP ${options.mtp} but Colibri reported draft=${observedDraft}`);
    }
    const readyStat = parseStat(await protocol.readLine());
    if (readyStat.completion_tokens !== 0) throw new Error("READY STAT reports generated tokens");
    protocolSequence.push("STAT_READY");
    const tiers = parseTiers(await protocol.readLine());
    protocolSequence.push("TIERS");
    ready = { preamble_bytes: preamble.length, observed_draft: observedDraft, stat: readyStat, tiers };
    await runTurn(1);
    proc.stdin.write("\x02RESET\n");
    await proc.stdin.flush();
    const resetPayload = await protocol.readUntil(END);
    if (resetPayload.length !== 0) throw new Error(`RESET returned ${resetPayload.length} unexpected bytes`);
    protocolSequence.push("RESET", "END_RESET");
    resetStat = parseStat(await protocol.readLine());
    if (resetStat.completion_tokens !== 0) throw new Error("RESET STAT reports generated tokens");
    protocolSequence.push("STAT_RESET");
    await runTurn(2);
    if (turns[0]!.stat.prompt_tokens !== turns[1]!.stat.prompt_tokens) {
      throw new Error("identical prompt frames produced different prompt token counts");
    }
    await proc.stdin.end();
    protocolSequence.push("EOF");
  } catch (caught) {
    error = caught instanceof Error ? caught.message : String(caught);
    try { await proc.stdin.end(); } catch { /* broken pipe */ }
    try { proc.kill(9); } catch { /* already exited */ }
  }

  const exitCode = await proc.exited;
  clearTimeout(timeout);
  try { await protocol.drain(); } catch { /* EOF already observed */ }
  const stderr = await stderrPromise;
  const stdout = protocol.raw();
  await Promise.all([
    Bun.write(join(options.out, "stdout.bin"), stdout),
    Bun.write(join(options.out, "stderr.bin"), stderr),
  ]);
  const stderrText = new TextDecoder().decode(stderr);
  const engineTraces = parseEngineTrace(stderrText, turns, options.mtp);
  if (engineTraces.some((trace) => trace.token_ids === null)) {
    throw new Error("warm harness requested TOKENS=1 but the engine omitted a token-id dump");
  }
  const processUsage = parseProcessUsage(stderrText);
  const analyzedTurns: TurnResult[] = turns.map((turn, index) => ({ ...turn, engine_trace: engineTraces[index]! }));
  const result: WarmHarnessResult = {
    schema_version: 3,
    capture_kind: "colibri_glm52_same_process_warm_pair",
    complete: error === null && !timedOut && exitCode === 0 && analyzedTurns.length === 2,
    error: timedOut ? `timeout after ${options.timeoutSeconds}s` : error,
    timed_out: timedOut,
    process: {
      exit_code: exitCode,
      signal_code: proc.signalCode ?? null,
      launcher_pid: proc.pid,
      engine_pid: enginePid,
      ...processUsage,
    },
    same_process: true,
    process_pid: enginePid,
    protocol_sequence: protocolSequence,
    ready,
    turns: analyzedTurns,
    reset_stat: resetStat,
    identical_prompt_frames: true,
    artifacts: { manifest: "manifest.json", stdout: "stdout.bin", stderr: "stderr.bin", prompt: "prompt.bin" },
  };
  manifest.analysis = {
    analyzer: { path: "scripts/colibri-g0-warm.ts", sha256: sha256(readFileSync(import.meta.path)) },
    stderr: { path: "stderr.bin", sha256: sha256(stderr) },
    ttft_boundary: TTFT_BOUNDARY,
    client_engine_tolerance_s: CLIENT_ENGINE_TTFT_TOLERANCE_S,
  };
  await Promise.all([
    Bun.write(join(options.out, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`),
    Bun.write(join(options.out, "result.json"), `${JSON.stringify(result, null, 2)}\n`),
  ]);
  if (!result.complete) throw new Error(`warm harness incomplete: ${result.error ?? `process exit ${exitCode}`}`);
  return result;
}

type ExistingTurnResult = Omit<TurnResult, "cache_state" | "engine_trace"> & {
  cache_state?: TurnResult["cache_state"];
  engine_trace?: EngineTurnTrace;
};

type ExistingWarmHarnessResult = Omit<
  WarmHarnessResult,
  "schema_version" | "same_process" | "process_pid" | "ready" | "turns"
> & {
  schema_version: number;
  same_process?: true;
  process_pid?: number | null;
  ready: (Omit<NonNullable<WarmHarnessResult["ready"]>, "observed_draft"> & { observed_draft?: number }) | null;
  turns: ExistingTurnResult[];
};

function readJson<T>(path: string): T {
  return JSON.parse(readFileSync(path, "utf8")) as T;
}

export async function analyzeExistingWarmRun(path: string): Promise<WarmHarnessResult> {
  const out = resolve(path);
  const manifestPath = join(out, "manifest.json");
  const resultPath = join(out, "result.json");
  const stderrPath = join(out, "stderr.bin");
  const manifest = readJson<WarmManifest>(manifestPath);
  const existing = readJson<ExistingWarmHarnessResult>(resultPath);
  if (manifest.mtp !== "on" && manifest.mtp !== "off") throw new Error("existing manifest has invalid MTP mode");
  if (!existing.complete || existing.turns.length !== 2) throw new Error("existing warm result is not a complete two-turn pair");
  const expectedProtocol = [
    "READY", "STAT_READY", "TIERS", "PROMPT_1", "END_1", "STAT_1",
    "RESET", "END_RESET", "STAT_RESET", "PROMPT_2", "END_2", "STAT_2", "EOF",
  ];
  if (JSON.stringify(existing.protocol_sequence) !== JSON.stringify(expectedProtocol)) {
    throw new Error("existing warm result does not prove the bounded PROMPT/RESET/PROMPT/EOF sequence");
  }
  const prompt = readFileSync(join(out, manifest.prompt.file));
  if (prompt.length !== manifest.prompt.bytes || sha256(prompt) !== manifest.prompt.sha256) {
    throw new Error("existing prompt artifact disagrees with manifest");
  }
  for (const [index, turn] of existing.turns.entries()) {
    const response = readFileSync(join(out, turn.response_file));
    if (response.length !== turn.response_bytes || sha256(response) !== turn.response_sha256) {
      throw new Error(`existing turn ${index + 1} response artifact disagrees with result`);
    }
  }
  const expectedDraft = manifest.mtp === "on" ? 3 : 0;
  if (manifest.env_overrides.DRAFT !== String(expectedDraft)) throw new Error("existing manifest DRAFT disagrees with MTP mode");
  if (existing.ready?.observed_draft !== undefined && existing.ready.observed_draft !== expectedDraft) {
    throw new Error("existing ready draft disagrees with MTP mode");
  }
  const baseTurns = existing.turns.map((turn, index): Omit<TurnResult, "engine_trace"> => {
    const { engine_trace: _oldTrace, ...withoutTrace } = turn;
    return {
      ...withoutTrace,
      cache_state: index === 0 ? "first-turn-in-process" : "warm-explicit-lru",
    };
  });
  const stderr = readFileSync(stderrPath);
  const stderrText = new TextDecoder().decode(stderr);
  const traces = parseEngineTrace(stderrText, baseTurns, manifest.mtp);
  const usage = parseProcessUsage(stderrText);
  const existingProcess = existing.process as ExistingWarmHarnessResult["process"] & Partial<WarmHarnessResult["process"]>;
  const result: WarmHarnessResult = {
    ...existing,
    schema_version: 3,
    process: {
      exit_code: existingProcess.exit_code,
      signal_code: existingProcess.signal_code,
      launcher_pid: existingProcess.launcher_pid ?? null,
      engine_pid: existingProcess.engine_pid ?? existing.process_pid ?? null,
      maximum_resident_set_bytes: existingProcess.maximum_resident_set_bytes ?? usage.maximum_resident_set_bytes,
      process_swaps: existingProcess.process_swaps ?? usage.process_swaps,
      peak_memory_footprint_bytes: existingProcess.peak_memory_footprint_bytes ?? usage.peak_memory_footprint_bytes,
    },
    same_process: true,
    process_pid: existing.process_pid ?? null,
    ready: existing.ready ? { ...existing.ready, observed_draft: expectedDraft } : null,
    turns: baseTurns.map((turn, index) => ({ ...turn, engine_trace: traces[index]! })),
  };
  manifest.schema_version = 3;
  const binaryPath = manifest.engine_command[0];
  if (!manifest.engine_binary && binaryPath && existsSync(binaryPath)) {
    const binaryStat = statSync(binaryPath);
    if (binaryStat.isFile()) {
      manifest.engine_binary = { path: binaryPath, bytes: binaryStat.size, sha256: sha256(readFileSync(binaryPath)) };
    }
  }
  manifest.analysis = {
    analyzer: { path: "scripts/colibri-g0-warm.ts", sha256: sha256(readFileSync(import.meta.path)) },
    stderr: { path: "stderr.bin", sha256: sha256(stderr) },
    ttft_boundary: TTFT_BOUNDARY,
    client_engine_tolerance_s: CLIENT_ENGINE_TTFT_TOLERANCE_S,
  };
  await Promise.all([
    Bun.write(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`),
    Bun.write(resultPath, `${JSON.stringify(result, null, 2)}\n`),
  ]);
  return result;
}

function positiveInt(value: string | undefined, flag: string): number {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 1) throw new Error(`${flag} must be a positive integer`);
  return parsed;
}

function finiteNumber(value: string | undefined, flag: string): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new Error(`${flag} must be a number`);
  return parsed;
}

function parseOptions(args: string[]): WarmHarnessOptions {
  const values: Record<string, string> = {};
  const envValues: string[] = [];
  const allowed = new Set([
    "--binary", "--model", "--prompt", "--prompt-file", "--out", "--mtp", "--max-tokens",
    "--temperature", "--top-p", "--timeout-seconds", "--cache-cap", "--expert-bits", "--dense-bits", "--env",
  ]);
  for (let i = 0; i < args.length; i += 2) {
    const name = args[i];
    const value = args[i + 1];
    if (!name || !allowed.has(name) || value === undefined) throw new Error(`invalid argument near ${name ?? "<end>"}`);
    if (name === "--env") envValues.push(value);
    else if (values[name] !== undefined) throw new Error(`duplicate argument: ${name}`);
    else values[name] = value;
  }
  for (const required of ["--binary", "--model", "--out", "--mtp"]) {
    if (!values[required]) throw new Error(`${required} is required`);
  }
  if (Boolean(values["--prompt"]) === Boolean(values["--prompt-file"])) {
    throw new Error("exactly one of --prompt or --prompt-file is required");
  }
  if (values["--mtp"] !== "on" && values["--mtp"] !== "off") throw new Error("--mtp must be on or off");
  const extraEnv: Record<string, string> = {};
  const reserved = new Set(["MTP", "TOKENS", "SNAP", "SERVE", "SERVE_BATCH", "DRAFT", "NGEN"]);
  for (const assignment of envValues) {
    const split = assignment.indexOf("=");
    const key = split > 0 ? assignment.slice(0, split) : "";
    const value = split > 0 ? assignment.slice(split + 1) : "";
    if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(key)) throw new Error(`invalid --env assignment: ${assignment}`);
    if (reserved.has(key)) throw new Error(`--env may not override ${key}`);
    extraEnv[key] = value;
  }
  const promptFile = values["--prompt-file"] ? resolve(values["--prompt-file"]) : null;
  const prompt = promptFile ? readFileSync(promptFile) : encoder.encode(values["--prompt"]!);
  const temperature = finiteNumber(values["--temperature"] ?? "0", "--temperature");
  const topP = finiteNumber(values["--top-p"] ?? "1", "--top-p");
  if (temperature < 0 || temperature > 2) throw new Error("--temperature must be between 0 and 2");
  if (topP <= 0 || topP > 1) throw new Error("--top-p must be greater than 0 and at most 1");
  return {
    binary: resolve(values["--binary"]!),
    model: resolve(values["--model"]!),
    prompt,
    promptSource: promptFile ? basename(promptFile) : "inline --prompt",
    out: resolve(values["--out"]!),
    mtp: values["--mtp"] as MtpMode,
    maxTokens: positiveInt(values["--max-tokens"] ?? "64", "--max-tokens"),
    temperature,
    topP,
    timeoutSeconds: positiveInt(values["--timeout-seconds"] ?? "1800", "--timeout-seconds"),
    cacheCap: positiveInt(values["--cache-cap"] ?? "1", "--cache-cap"),
    expertBits: positiveInt(values["--expert-bits"] ?? "4", "--expert-bits"),
    denseBits: positiveInt(values["--dense-bits"] ?? "4", "--dense-bits"),
    extraEnv,
  };
}

if (import.meta.main) {
  const args = process.argv.slice(2);
  if (args[0] === "--analyze-existing") {
    if (args.length !== 2) throw new Error("--analyze-existing requires exactly one evidence directory");
    const out = resolve(args[1]!);
    const result = await analyzeExistingWarmRun(out);
    console.log(`reanalyzed bounded warm pair in ${out}`);
    console.log(`turn engine TTFT: ${result.turns.map((turn) => turn.engine_trace.engine_prefill_to_first_s.toFixed(6)).join("s, ")}s`);
  } else {
    const options = parseOptions(args);
    const result = await runWarmHarness(options);
    console.log(`wrote bounded warm pair to ${options.out}`);
    console.log(`turn TTFT: ${result.turns.map((turn) => turn.client_ttft_s.toFixed(6)).join("s, ")}s`);
  }
}
