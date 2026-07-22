#!/usr/bin/env bun

import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync } from "node:fs";
import { basename, join, resolve } from "node:path";

type Mode = "off" | "on";
type JsonObject = Record<string, unknown>;

export interface MatrixReportOptions {
  root: string;
  prefix: string;
}

interface SourceFile {
  path: string;
  bytes: number;
  sha256: string;
}

interface Range {
  min: number;
  median: number;
  max: number;
}

interface VmStat {
  page_size_bytes: number;
  pages_stored_in_compressor: number;
  pages_occupied_by_compressor: number;
  decompressions: number;
  compressions: number;
  swapins: number;
  swapouts: number;
}

interface SwapUsage {
  total_mib: number;
  used_mib: number;
  free_mib: number;
}

interface MemoryPressure {
  total_bytes: number;
  free_percent: number;
}

const EXPECTED_PROTOCOL = [
  "READY", "STAT_READY", "TIERS", "PROMPT_1", "END_1", "STAT_1",
  "RESET", "END_RESET", "STAT_RESET", "PROMPT_2", "END_2", "STAT_2", "EOF",
];

const SIDE_CARS = [
  "memory-pressure.pre.txt", "memory-pressure.post.txt",
  "vm-stat.pre.txt", "vm-stat.post.txt",
  "swap.pre.txt", "swap.post.txt",
] as const;

const EXPECTED_COMMON_ENV: Record<string, string> = {
  AUTOPIN: "0",
  CACHE_ROUTE: "0",
  CAP_RAISE: "0",
  COLI_G0_TRACE: "1",
  COLI_METAL: "1",
  COLI_MMAP: "0",
  CTX: "128",
  DIRECT: "1",
  DISK_SPLIT: "1",
  EXPERT_BUDGET: "0",
  KVSAVE: "0",
  NGEN: "64",
  OMP_DYNAMIC: "FALSE",
  OMP_NUM_THREADS: "10",
  PILOT: "0",
  PILOT_REAL: "0",
  PILOT_TWO: "0",
  PIPE: "1",
  PIPE_WORKERS: "6",
  PROF: "1",
  RAM_GB: "18",
  REPIN: "0",
  SEED: "1",
  SERVE: "1",
  SERVE_BATCH: "0",
  SPEC_PIN: "1",
  TEMP: "0",
  TOKENS: "1",
};

const TTFT_TOLERANCE_S = 0.05;

function fail(message: string): never {
  throw new Error(`Colibri G0 matrix validation failed: ${message}`);
}

function object(value: unknown, label: string): JsonObject {
  if (value === null || typeof value !== "object" || Array.isArray(value)) fail(`${label} must be an object`);
  return value as JsonObject;
}

function array(value: unknown, label: string): unknown[] {
  if (!Array.isArray(value)) fail(`${label} must be an array`);
  return value;
}

function string(value: unknown, label: string): string {
  if (typeof value !== "string" || value.length === 0) fail(`${label} must be a non-empty string`);
  return value;
}

function number(value: unknown, label: string): number {
  if (typeof value !== "number" || !Number.isFinite(value)) fail(`${label} must be finite`);
  return value;
}

function integer(value: unknown, label: string): number {
  const parsed = number(value, label);
  if (!Number.isInteger(parsed)) fail(`${label} must be an integer`);
  return parsed;
}

function nonnegative(value: unknown, label: string): number {
  const parsed = number(value, label);
  if (parsed < 0) fail(`${label} must be nonnegative`);
  return parsed;
}

function positiveInteger(value: unknown, label: string): number {
  const parsed = integer(value, label);
  if (parsed <= 0) fail(`${label} must be positive`);
  return parsed;
}

function exact(value: unknown, expected: unknown, label: string): void {
  if (JSON.stringify(value) !== JSON.stringify(expected)) fail(`${label} is not ${JSON.stringify(expected)}`);
}

function sha256(bytes: Uint8Array): string {
  return createHash("sha256").update(bytes).digest("hex");
}

function sourceFile(path: string, displayPath = path): SourceFile {
  if (!existsSync(path) || !statSync(path).isFile()) fail(`missing source file ${path}`);
  const bytes = readFileSync(path);
  return { path: displayPath, bytes: bytes.byteLength, sha256: sha256(bytes) };
}

function readJson(path: string, label: string): JsonObject {
  let parsed: unknown;
  try {
    parsed = JSON.parse(readFileSync(path, "utf8"));
  } catch (error) {
    fail(`${label} is not valid JSON: ${error instanceof Error ? error.message : String(error)}`);
  }
  return object(parsed!, label);
}

function stable(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(stable);
  if (value !== null && typeof value === "object") {
    return Object.fromEntries(Object.entries(value as JsonObject).sort(([a], [b]) => a.localeCompare(b)).map(([key, item]) => [key, stable(item)]));
  }
  return value;
}

function stableJson(value: unknown): string {
  return `${JSON.stringify(stable(value), null, 2)}\n`;
}

function range(values: number[], label: string): Range {
  if (values.length !== 3 || values.some((value) => !Number.isFinite(value))) fail(`${label} requires exactly three finite values`);
  const sorted = [...values].sort((a, b) => a - b);
  return { min: sorted[0]!, median: sorted[1]!, max: sorted[2]! };
}

function parseMemoryPressure(text: string, label: string): MemoryPressure {
  const total = text.match(/The system has (\d+) \(/);
  const free = text.match(/System-wide memory free percentage:\s*(\d+(?:\.\d+)?)%/);
  if (!total || !free) fail(`${label} has an unknown memory_pressure format`);
  return { total_bytes: Number(total[1]), free_percent: Number(free[1]) };
}

function vmValue(text: string, name: string, label: string): number {
  const escaped = name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = text.match(new RegExp(`^${escaped}:\\s+(\\d+)\\.?$`, "m"));
  if (!match) fail(`${label} is missing ${name}`);
  return Number(match[1]);
}

function parseVmStat(text: string, label: string): VmStat {
  const page = text.match(/^Mach Virtual Memory Statistics: \(page size of (\d+) bytes\)$/m);
  if (!page) fail(`${label} is missing its page size`);
  return {
    page_size_bytes: Number(page[1]),
    pages_stored_in_compressor: vmValue(text, "Pages stored in compressor", label),
    pages_occupied_by_compressor: vmValue(text, "Pages occupied by compressor", label),
    decompressions: vmValue(text, "Decompressions", label),
    compressions: vmValue(text, "Compressions", label),
    swapins: vmValue(text, "Swapins", label),
    swapouts: vmValue(text, "Swapouts", label),
  };
}

function parseSwap(text: string, label: string): SwapUsage {
  const match = text.match(/vm\.swapusage: total = ([0-9.]+)([KMG])\s+used = ([0-9.]+)([KMG])\s+free = ([0-9.]+)([KMG])/);
  if (!match) fail(`${label} has an unknown vm.swapusage format`);
  const mib = (value: string, unit: string): number => Number(value) * ({ K: 1 / 1024, M: 1, G: 1024 }[unit] ?? fail(`${label} has an unknown unit`));
  return { total_mib: mib(match[1]!, match[2]!), used_mib: mib(match[3]!, match[4]!), free_mib: mib(match[5]!, match[6]!) };
}

function delta(after: number, before: number): number {
  return after - before;
}

function strippedSettings(env: JsonObject): JsonObject {
  return Object.fromEntries(Object.entries(env).filter(([key]) => !["MTP", "DRAFT", "STATS"].includes(key)).sort(([a], [b]) => a.localeCompare(b)));
}

function validateHash(value: unknown, label: string): string {
  const hash = string(value, label);
  if (!/^[0-9a-f]{64}$/.test(hash)) fail(`${label} is not a lowercase SHA-256 digest`);
  return hash;
}

interface LoadedRun {
  mode: Mode;
  repeat: number;
  directory: string;
  manifest: JsonObject;
  result: JsonObject;
  binary: SourceFile;
  analyzer: SourceFile;
  engineCommand: string[];
  launcherCommand: string[];
  modelPath: string;
  promptHash: string;
  request: JsonObject;
  settings: JsonObject;
  sourceFiles: Record<string, SourceFile>;
  responseHash: string;
  tokenIds: number[];
  process: {
    launcher_pid: number;
    engine_pid: number;
    maximum_resident_set_bytes: number;
    process_swaps: number;
    peak_memory_footprint_bytes: number;
  };
  turns: Array<{
    client_ttft_s: number;
    engine_ttft_s: number;
    client_minus_engine_ttft_s: number;
    elapsed_s: number;
    rate_tokens_per_second: number;
    cache_hit_percent: number;
    expert_fetched_gb: number;
    expert_read_service_seconds: number;
    expert_wait_seconds: number;
    pinned_hits: number;
    lru_hits: number;
    expert_load_misses: number;
    resident_pinned_experts: number;
    resident_lru_experts: number;
    resident_expert_gb: number;
    forwards: number;
    tokens_per_forward: number;
    mtp_raw_proposals: number;
    mtp_verified_proposals: number;
    mtp_accepted: number;
    mtp_rejected_or_discarded: number;
    acceptance_length_histogram: Record<string, number>;
  }>;
  sidecars: {
    memory_pressure: { pre: MemoryPressure; post: MemoryPressure; free_percent_delta: number };
    vm: { pre: VmStat; post: VmStat; delta: Record<string, number> };
    swap: { pre: SwapUsage; post: SwapUsage; used_mib_delta: number };
  };
}

function loadRun(root: string, prefix: string, mode: Mode, repeat: number): LoadedRun {
  const name = `${prefix}-mtp-${mode}-r${repeat}`;
  const directory = join(root, name);
  if (!existsSync(directory) || !statSync(directory).isDirectory()) fail(`missing run directory ${directory}`);
  const manifestPath = join(directory, "manifest.json");
  const resultPath = join(directory, "result.json");
  const manifest = readJson(manifestPath, `${name}/manifest.json`);
  const result = readJson(resultPath, `${name}/result.json`);
  exact(manifest.schema_version, 3, `${name} manifest schema_version`);
  exact(manifest.capture_kind, "colibri_glm52_same_process_warm_manifest", `${name} manifest capture_kind`);
  exact(manifest.mtp, mode, `${name} manifest MTP mode`);
  exact(result.schema_version, 3, `${name} result schema_version`);
  exact(result.capture_kind, "colibri_glm52_same_process_warm_pair", `${name} result capture_kind`);
  exact(result.complete, true, `${name} completeness`);
  exact(result.error, null, `${name} error`);
  exact(result.timed_out, false, `${name} timeout state`);
  exact(result.same_process, true, `${name} same_process proof`);
  exact(result.identical_prompt_frames, true, `${name} identical prompt proof`);
  exact(result.protocol_sequence, EXPECTED_PROTOCOL, `${name} protocol sequence`);

  const engineBinary = object(manifest.engine_binary, `${name} engine_binary`);
  const binaryPath = string(engineBinary.path, `${name} binary path`);
  const binary = sourceFile(binaryPath, binaryPath);
  if (binary.bytes !== positiveInteger(engineBinary.bytes, `${name} binary bytes`)) fail(`${name} binary byte count disagrees with the file`);
  if (binary.sha256 !== validateHash(engineBinary.sha256, `${name} binary sha256`)) fail(`${name} binary digest disagrees with the file`);
  const engineCommand = array(manifest.engine_command, `${name} engine command`).map((value, index) => string(value, `${name} engine command ${index}`));
  const launcherCommand = array(manifest.launcher_command, `${name} launcher command`).map((value, index) => string(value, `${name} launcher command ${index}`));
  exact(engineCommand, [binaryPath, "1", "4", "4"], `${name} exact engine command`);
  exact(launcherCommand, ["/usr/bin/time", "-l", ...engineCommand], `${name} exact launcher command`);

  const env = object(manifest.env_overrides, `${name} env_overrides`);
  const expectedDraft = mode === "on" ? "3" : "0";
  exact(env.MTP, mode === "on" ? "1" : "0", `${name} MTP environment`);
  exact(env.DRAFT, expectedDraft, `${name} DRAFT environment`);
  exact(env.TOKENS, "1", `${name} token tracing`);
  const statsPath = string(env.STATS, `${name} STATS path`);
  if (resolve(statsPath) !== resolve(`${directory}.stats`)) fail(`${name} STATS path does not name its companion file`);
  const modelPath = string(env.SNAP, `${name} model path`);
  if (!existsSync(modelPath) || !statSync(modelPath).isDirectory()) fail(`${name} model revision path is unavailable`);
  if (!/^[0-9a-f]{40}$/.test(basename(modelPath))) fail(`${name} model path does not end in an exact 40-hex revision`);
  exact(stable(env), stable({
    ...EXPECTED_COMMON_ENV,
    MTP: mode === "on" ? "1" : "0",
    DRAFT: expectedDraft,
    SNAP: modelPath,
    STATS: statsPath,
  }), `${name} exact G0 environment`);

  const prompt = object(manifest.prompt, `${name} prompt`);
  exact(prompt.file, "prompt.bin", `${name} prompt filename`);
  const promptFile = sourceFile(join(directory, "prompt.bin"), `${name}/prompt.bin`);
  if (promptFile.bytes !== positiveInteger(prompt.bytes, `${name} prompt bytes`)) fail(`${name} prompt byte count disagrees with the file`);
  const promptHash = validateHash(prompt.sha256, `${name} prompt sha256`);
  if (promptFile.sha256 !== promptHash) fail(`${name} prompt digest disagrees with the file`);

  const request = object(manifest.request, `${name} request`);
  exact(request, { max_tokens: 64, temperature: 0, top_p: 1 }, `${name} exact request`);

  const analysis = object(manifest.analysis, `${name} analysis`);
  exact(analysis.client_engine_tolerance_s, TTFT_TOLERANCE_S, `${name} TTFT tolerance`);
  const analyzerAnalysis = object(analysis.analyzer, `${name} analyzer analysis`);
  const analyzerPath = string(analyzerAnalysis.path, `${name} analyzer path`);
  const analyzer = sourceFile(resolve(analyzerPath), analyzerPath);
  if (analyzer.sha256 !== validateHash(analyzerAnalysis.sha256, `${name} analyzer sha256`)) fail(`${name} analyzer digest disagrees with the file`);
  const stderrAnalysis = object(analysis.stderr, `${name} stderr analysis`);
  exact(stderrAnalysis.path, "stderr.bin", `${name} analyzed stderr path`);

  const sourceFiles: Record<string, SourceFile> = {
    manifest: sourceFile(manifestPath, `${name}/manifest.json`),
    result: sourceFile(resultPath, `${name}/result.json`),
    prompt: promptFile,
    stdout: sourceFile(join(directory, "stdout.bin"), `${name}/stdout.bin`),
    stderr: sourceFile(join(directory, "stderr.bin"), `${name}/stderr.bin`),
    stats: sourceFile(`${directory}.stats`, `${name}.stats`),
  };
  if (sourceFiles.stderr!.sha256 !== validateHash(stderrAnalysis.sha256, `${name} analyzed stderr sha256`)) fail(`${name} stderr digest disagrees with analysis metadata`);

  const resultArtifacts = object(result.artifacts, `${name} result artifacts`);
  exact(resultArtifacts, { manifest: "manifest.json", stdout: "stdout.bin", stderr: "stderr.bin", prompt: "prompt.bin" }, `${name} result artifacts`);
  const turns = array(result.turns, `${name} turns`);
  if (turns.length !== 2) fail(`${name} must contain exactly two turns`);
  const loadedTurns: LoadedRun["turns"] = [];
  let responseHash = "";
  let tokenIds: number[] = [];
  for (let index = 0; index < 2; index++) {
    const label = `${name} turn ${index + 1}`;
    const turn = object(turns[index], label);
    exact(turn.cache_state, index === 0 ? "first-turn-in-process" : "warm-explicit-lru", `${label} cache state`);
    const responseName = `turn-${index + 1}.response.bin`;
    exact(turn.response_file, responseName, `${label} response filename`);
    const response = sourceFile(join(directory, responseName), `${name}/${responseName}`);
    sourceFiles[`turn_${index + 1}_response`] = response;
    if (response.bytes !== positiveInteger(turn.response_bytes, `${label} response bytes`)) fail(`${label} response bytes disagree with the file`);
    const turnResponseHash = validateHash(turn.response_sha256, `${label} response sha256`);
    if (response.sha256 !== turnResponseHash) fail(`${label} response digest disagrees with the file`);
    if (index === 0) responseHash = turnResponseHash;
    else if (turnResponseHash !== responseHash) fail(`${name} identical prompt frames produced different response hashes`);
    const stat = object(turn.stat, `${label} stat`);
    exact(stat.completion_tokens, 64, `${label} completion tokens`);
    exact(stat.prompt_tokens, 32, `${label} prompt tokens`);
    exact(stat.length_limited, true, `${label} length limit`);
    const trace = object(turn.engine_trace, `${label} engine trace`);
    exact(trace.produced, 64, `${label} produced tokens`);
    const ids = array(trace.token_ids, `${label} token ids`).map((value, idIndex) => integer(value, `${label} token id ${idIndex}`));
    if (ids.length !== 64) fail(`${label} must contain exactly 64 token IDs`);
    if (index === 0) tokenIds = ids;
    else exact(ids, tokenIds, `${name} turn token IDs`);
    const histogramObject = object(trace.acceptance_length_histogram, `${label} acceptance histogram`);
    const histogram = Object.fromEntries(Object.entries(histogramObject).map(([key, value]) => {
      if (!/^\d+$/.test(key)) fail(`${label} histogram key ${key} is not an acceptance length`);
      return [key, nonnegative(value, `${label} histogram ${key}`)];
    }));
    const raw = nonnegative(trace.mtp_raw_proposals, `${label} raw proposals`);
    const verified = nonnegative(trace.mtp_verified_proposals, `${label} verified proposals`);
    const accepted = nonnegative(trace.mtp_accepted, `${label} accepted proposals`);
    const rejected = nonnegative(trace.mtp_rejected_or_discarded, `${label} rejected proposals`);
    const verifyRows = positiveInteger(trace.verify_rows, `${label} verify rows`);
    if (raw !== accepted + rejected) fail(`${label} raw proposals do not partition into accepted and rejected/discarded`);
    if (verified > raw || accepted > verified) fail(`${label} MTP proposal counts are inconsistent`);
    if (mode === "on" && Object.values(histogram).reduce((sum, value) => sum + value, 0) !== verifyRows) fail(`${label} acceptance histogram does not sum to verify_rows`);
    if (mode === "off" && (raw !== 0 || verified !== 0 || accepted !== 0 || rejected !== 0 || Object.keys(histogram).length !== 0)) fail(`${label} contains MTP activity while MTP is off`);
    if (mode === "on" && (raw === 0 || Object.keys(histogram).length === 0)) fail(`${label} does not contain MTP activity while MTP is on`);
    const clientTtft = nonnegative(turn.client_ttft_s, `${label} client TTFT`);
    const engineTtft = nonnegative(trace.engine_prefill_to_first_s, `${label} engine TTFT`);
    const observedTtftDelta = number(trace.client_minus_engine_ttft_s, `${label} client-engine TTFT delta`);
    if (Math.abs(observedTtftDelta - (clientTtft - engineTtft)) > 1e-9) fail(`${label} client-engine TTFT delta is inconsistent`);
    if (Math.abs(observedTtftDelta) > TTFT_TOLERANCE_S) fail(`${label} client-engine TTFT delta exceeds ${TTFT_TOLERANCE_S}s`);
    loadedTurns.push({
      client_ttft_s: clientTtft,
      engine_ttft_s: engineTtft,
      client_minus_engine_ttft_s: observedTtftDelta,
      elapsed_s: nonnegative(trace.elapsed_s, `${label} elapsed`),
      rate_tokens_per_second: nonnegative(stat.tokens_per_second, `${label} rate`),
      cache_hit_percent: nonnegative(stat.cache_hit_percent, `${label} cache hit`),
      expert_fetched_gb: nonnegative(trace.expert_fetched_gb, `${label} expert fetched GB`),
      expert_read_service_seconds: nonnegative(trace.expert_read_service_seconds, `${label} expert read service seconds`),
      expert_wait_seconds: nonnegative(trace.expert_wait_seconds, `${label} expert wait seconds`),
      pinned_hits: nonnegative(trace.pinned_hits, `${label} pinned hits`),
      lru_hits: nonnegative(trace.lru_hits, `${label} LRU hits`),
      expert_load_misses: nonnegative(trace.expert_load_misses, `${label} expert load misses`),
      resident_pinned_experts: nonnegative(trace.resident_pinned_experts, `${label} resident pinned experts`),
      resident_lru_experts: nonnegative(trace.resident_lru_experts, `${label} resident LRU experts`),
      resident_expert_gb: nonnegative(trace.resident_expert_gb, `${label} resident expert GB`),
      forwards: positiveInteger(trace.forwards, `${label} forwards`),
      tokens_per_forward: nonnegative(trace.tokens_per_forward, `${label} tokens per forward`),
      mtp_raw_proposals: raw,
      mtp_verified_proposals: verified,
      mtp_accepted: accepted,
      mtp_rejected_or_discarded: rejected,
      acceptance_length_histogram: histogram,
    });
  }

  const process = object(result.process, `${name} process`);
  exact(process.exit_code, 0, `${name} exit code`);
  exact(process.signal_code, null, `${name} signal code`);
  const launcherPid = positiveInteger(process.launcher_pid, `${name} launcher PID`);
  const enginePid = positiveInteger(process.engine_pid, `${name} engine PID`);
  exact(result.process_pid, enginePid, `${name} process PID identity`);
  if (launcherPid === enginePid) fail(`${name} launcher and engine PIDs must be distinct`);
  const ready = object(result.ready, `${name} ready state`);
  exact(ready.observed_draft, mode === "on" ? 3 : 0, `${name} observed draft`);

  const sidecarFiles: Record<string, SourceFile> = {};
  for (const suffix of SIDE_CARS) sidecarFiles[suffix] = sourceFile(`${directory}.${suffix}`, `${name}.${suffix}`);
  Object.assign(sourceFiles, Object.fromEntries(Object.entries(sidecarFiles).map(([key, value]) => [`sidecar_${key.replaceAll(".", "_").replaceAll("-", "_")}`, value])));
  const readSidecar = (suffix: typeof SIDE_CARS[number]): string => readFileSync(`${directory}.${suffix}`, "utf8");
  const memoryPre = parseMemoryPressure(readSidecar("memory-pressure.pre.txt"), `${name} memory pre`);
  const memoryPost = parseMemoryPressure(readSidecar("memory-pressure.post.txt"), `${name} memory post`);
  if (memoryPre.total_bytes !== memoryPost.total_bytes) fail(`${name} system memory size changed between sidecars`);
  const vmPre = parseVmStat(readSidecar("vm-stat.pre.txt"), `${name} vm pre`);
  const vmPost = parseVmStat(readSidecar("vm-stat.post.txt"), `${name} vm post`);
  if (vmPre.page_size_bytes !== vmPost.page_size_bytes) fail(`${name} VM page size changed between sidecars`);
  const swapPre = parseSwap(readSidecar("swap.pre.txt"), `${name} swap pre`);
  const swapPost = parseSwap(readSidecar("swap.post.txt"), `${name} swap post`);
  if (swapPre.total_mib !== swapPost.total_mib) fail(`${name} swap capacity changed between sidecars`);

  return {
    mode, repeat, directory: name, manifest, result, binary, analyzer, engineCommand, launcherCommand, modelPath, promptHash, request,
    settings: strippedSettings(env), sourceFiles, responseHash, tokenIds,
    process: {
      launcher_pid: launcherPid,
      engine_pid: enginePid,
      maximum_resident_set_bytes: positiveInteger(process.maximum_resident_set_bytes, `${name} maximum resident set`),
      process_swaps: nonnegative(process.process_swaps, `${name} process swaps`),
      peak_memory_footprint_bytes: positiveInteger(process.peak_memory_footprint_bytes, `${name} peak footprint`),
    },
    turns: loadedTurns,
    sidecars: {
      memory_pressure: { pre: memoryPre, post: memoryPost, free_percent_delta: delta(memoryPost.free_percent, memoryPre.free_percent) },
      vm: {
        pre: vmPre, post: vmPost,
        delta: {
          pages_stored_in_compressor: delta(vmPost.pages_stored_in_compressor, vmPre.pages_stored_in_compressor),
          pages_occupied_by_compressor: delta(vmPost.pages_occupied_by_compressor, vmPre.pages_occupied_by_compressor),
          decompressions: delta(vmPost.decompressions, vmPre.decompressions),
          compressions: delta(vmPost.compressions, vmPre.compressions),
          swapins: delta(vmPost.swapins, vmPre.swapins),
          swapouts: delta(vmPost.swapouts, vmPre.swapouts),
        },
      },
      swap: { pre: swapPre, post: swapPost, used_mib_delta: delta(swapPost.used_mib, swapPre.used_mib) },
    },
  };
}

function metricRange(runs: LoadedRun[], turn: number, key: keyof LoadedRun["turns"][number], label: string): Range {
  return range(runs.map((run) => run.turns[turn]![key] as number), label);
}

function summarizeTurn(runs: LoadedRun[], turn: number, mode: Mode): JsonObject {
  const summary: JsonObject = {
    client_ttft_s: metricRange(runs, turn, "client_ttft_s", `${mode} turn ${turn + 1} client TTFT`),
    engine_ttft_s: metricRange(runs, turn, "engine_ttft_s", `${mode} turn ${turn + 1} engine TTFT`),
    client_minus_engine_ttft_s: metricRange(runs, turn, "client_minus_engine_ttft_s", `${mode} turn ${turn + 1} client-engine TTFT delta`),
    elapsed_s: metricRange(runs, turn, "elapsed_s", `${mode} turn ${turn + 1} elapsed`),
    rate_tokens_per_second: metricRange(runs, turn, "rate_tokens_per_second", `${mode} turn ${turn + 1} rate`),
    cache_hit_percent: metricRange(runs, turn, "cache_hit_percent", `${mode} turn ${turn + 1} hit`),
    expert_fetched_gb: metricRange(runs, turn, "expert_fetched_gb", `${mode} turn ${turn + 1} expert GB`),
    expert_read_service_seconds: metricRange(runs, turn, "expert_read_service_seconds", `${mode} turn ${turn + 1} read service`),
    expert_wait_seconds: metricRange(runs, turn, "expert_wait_seconds", `${mode} turn ${turn + 1} wait`),
    pinned_hits: metricRange(runs, turn, "pinned_hits", `${mode} turn ${turn + 1} pinned hits`),
    lru_hits: metricRange(runs, turn, "lru_hits", `${mode} turn ${turn + 1} LRU hits`),
    expert_load_misses: metricRange(runs, turn, "expert_load_misses", `${mode} turn ${turn + 1} expert load misses`),
    resident_pinned_experts: metricRange(runs, turn, "resident_pinned_experts", `${mode} turn ${turn + 1} resident pinned experts`),
    resident_lru_experts: metricRange(runs, turn, "resident_lru_experts", `${mode} turn ${turn + 1} resident LRU experts`),
    resident_expert_gb: metricRange(runs, turn, "resident_expert_gb", `${mode} turn ${turn + 1} resident expert GB`),
    forwards: metricRange(runs, turn, "forwards", `${mode} turn ${turn + 1} forwards`),
    tokens_per_forward: metricRange(runs, turn, "tokens_per_forward", `${mode} turn ${turn + 1} tokens/forward`),
    mtp_raw_proposals: metricRange(runs, turn, "mtp_raw_proposals", `${mode} turn ${turn + 1} raw proposals`),
    mtp_verified_proposals: metricRange(runs, turn, "mtp_verified_proposals", `${mode} turn ${turn + 1} verified proposals`),
    mtp_accepted: metricRange(runs, turn, "mtp_accepted", `${mode} turn ${turn + 1} accepted proposals`),
    mtp_rejected_or_discarded: metricRange(runs, turn, "mtp_rejected_or_discarded", `${mode} turn ${turn + 1} rejected proposals`),
  };
  const histogramKeys = [...new Set(runs.flatMap((run) => Object.keys(run.turns[turn]!.acceptance_length_histogram)))].sort((a, b) => Number(a) - Number(b));
  summary.acceptance_length_histogram = Object.fromEntries(histogramKeys.map((key) => [key, range(runs.map((run) => run.turns[turn]!.acceptance_length_histogram[key] ?? 0), `${mode} turn ${turn + 1} histogram ${key}`)]));
  return summary;
}

function publicRun(run: LoadedRun): JsonObject {
  return {
    repeat: run.repeat,
    directory: run.directory,
    source_files: run.sourceFiles,
    process: run.process,
    turns: run.turns,
    sidecars: run.sidecars,
  };
}

export function buildMatrixReport(options: MatrixReportOptions): JsonObject {
  const root = resolve(options.root);
  if (!existsSync(root) || !statSync(root).isDirectory()) fail(`root is not a directory: ${root}`);
  if (!options.prefix || options.prefix.includes("/") || options.prefix.includes("..")) fail("prefix must be one path-segment name");
  const runs = (["off", "on"] as const).flatMap((mode) => [1, 2, 3].map((repeat) => loadRun(root, options.prefix, mode, repeat)));
  const first = runs[0]!;
  for (const run of runs.slice(1)) {
    if (run.binary.sha256 !== first.binary.sha256 || run.binary.bytes !== first.binary.bytes || run.binary.path !== first.binary.path) fail(`${run.directory} does not use the shared exact binary`);
    if (run.analyzer.sha256 !== first.analyzer.sha256 || run.analyzer.bytes !== first.analyzer.bytes || run.analyzer.path !== first.analyzer.path) fail(`${run.directory} was not produced by the shared exact analyzer`);
    exact(run.engineCommand, first.engineCommand, `${run.directory} engine command parity`);
    exact(run.launcherCommand, first.launcherCommand, `${run.directory} launcher command parity`);
    if (run.modelPath !== first.modelPath) fail(`${run.directory} does not use the shared exact model revision path`);
    if (run.promptHash !== first.promptHash) fail(`${run.directory} does not use the shared prompt`);
    exact(run.request, first.request, `${run.directory} request parity`);
    exact(run.settings, first.settings, `${run.directory} settings parity excluding MTP/DRAFT/STATS`);
    if (run.responseHash !== first.responseHash) fail(`${run.directory} response hash differs across the matrix`);
    exact(run.tokenIds, first.tokenIds, `${run.directory} token IDs across the matrix`);
  }
  const pids = runs.map((run) => run.process.engine_pid);
  if (new Set(pids).size !== runs.length) fail("engine PIDs must be unique across all six processes");

  const modes = Object.fromEntries((["off", "on"] as const).map((mode) => {
    const selected = runs.filter((run) => run.mode === mode);
    return [mode, {
      runs: selected.map(publicRun),
      summary: {
        process: {
          maximum_resident_set_bytes: range(selected.map((run) => run.process.maximum_resident_set_bytes), `${mode} maximum resident set`),
          process_swaps: range(selected.map((run) => run.process.process_swaps), `${mode} process swaps`),
          peak_memory_footprint_bytes: range(selected.map((run) => run.process.peak_memory_footprint_bytes), `${mode} peak footprint`),
        },
        system_deltas: {
          memory_free_percent: range(selected.map((run) => run.sidecars.memory_pressure.free_percent_delta), `${mode} memory free delta`),
          swap_used_mib: range(selected.map((run) => run.sidecars.swap.used_mib_delta), `${mode} swap usage delta`),
          vm_swapins: range(selected.map((run) => run.sidecars.vm.delta.swapins!), `${mode} VM swapins`),
          vm_swapouts: range(selected.map((run) => run.sidecars.vm.delta.swapouts!), `${mode} VM swapouts`),
          compressions: range(selected.map((run) => run.sidecars.vm.delta.compressions!), `${mode} compressions`),
          decompressions: range(selected.map((run) => run.sidecars.vm.delta.decompressions!), `${mode} decompressions`),
          compressor_stored_pages: range(selected.map((run) => run.sidecars.vm.delta.pages_stored_in_compressor!), `${mode} compressor stored pages`),
          compressor_occupied_pages: range(selected.map((run) => run.sidecars.vm.delta.pages_occupied_by_compressor!), `${mode} compressor occupied pages`),
        },
        turns: [summarizeTurn(selected, 0, mode), summarizeTurn(selected, 1, mode)],
      },
    }];
  }));

  const scriptPath = resolve(import.meta.path);
  return {
    schema_version: 1,
    capture_kind: "colibri_glm52_g0_warm_matrix",
    matrix: { modes: ["off", "on"], repeats_per_mode: 3, turns_per_process: 2, total_processes: 6 },
    provenance: {
      root,
      prefix: options.prefix,
      reporter: sourceFile(scriptPath, "scripts/colibri-g0-matrix-report.ts"),
      warm_analyzer: first.analyzer,
      binary: first.binary,
      model_revision_path: first.modelPath,
      model_revision: basename(first.modelPath),
      prompt_sha256: first.promptHash,
      response_sha256: first.responseHash,
      token_ids_sha256: sha256(Buffer.from(first.tokenIds.join(","), "utf8")),
      request: first.request,
      common_settings_excluding_mtp_draft_stats: first.settings,
    },
    modes,
  };
}

function fmtRange(value: unknown, digits = 3): string {
  const item = object(value, "markdown range");
  return `${number(item.median, "median").toFixed(digits)} [${number(item.min, "min").toFixed(digits)}, ${number(item.max, "max").toFixed(digits)}]`;
}

export function renderMatrixMarkdown(report: JsonObject): string {
  const provenance = object(report.provenance, "provenance");
  const modes = object(report.modes, "modes");
  const lines = [
    "# Colibri GLM-5.2 G0 warm matrix",
    "",
    "All values are the median [minimum, maximum] across three complete processes. Each process ran the same 32-token prompt twice around RESET; RESET clears conversational KV but preserves the explicit expert LRU.",
    "",
    `- Binary SHA-256: \`${string(object(provenance.binary, "binary").sha256, "binary hash")}\``,
    `- Model revision: \`${string(provenance.model_revision, "model revision")}\``,
    `- Prompt SHA-256: \`${string(provenance.prompt_sha256, "prompt hash")}\``,
    `- Response SHA-256: \`${string(provenance.response_sha256, "response hash")}\``,
    `- Token-ID SHA-256: \`${string(provenance.token_ids_sha256, "token hash")}\``,
    "",
    "| Mode | Turn | Client TTFT (s) | Engine TTFT (s) | Client-engine delta (s) | Elapsed (s) | tok/s | Hit (%) | Expert GB | Forwards | tok/forward | MTP raw / verified / accepted / rejected |",
    "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
  ];
  for (const mode of ["off", "on"] as const) {
    const summary = object(object(modes[mode], `${mode} mode`).summary, `${mode} summary`);
    const turns = array(summary.turns, `${mode} turns`);
    for (let turn = 0; turn < 2; turn++) {
      const item = object(turns[turn], `${mode} turn ${turn + 1}`);
      const mtp = ["mtp_raw_proposals", "mtp_verified_proposals", "mtp_accepted", "mtp_rejected_or_discarded"].map((key) => fmtRange(item[key], 0)).join(" / ");
      lines.push(`| ${mode} | ${turn + 1} | ${fmtRange(item.client_ttft_s)} | ${fmtRange(item.engine_ttft_s)} | ${fmtRange(item.client_minus_engine_ttft_s, 6)} | ${fmtRange(item.elapsed_s)} | ${fmtRange(item.rate_tokens_per_second, 2)} | ${fmtRange(item.cache_hit_percent, 1)} | ${fmtRange(item.expert_fetched_gb)} | ${fmtRange(item.forwards, 0)} | ${fmtRange(item.tokens_per_forward, 2)} | ${mtp} |`);
    }
  }
  lines.push("", "## Expert I/O and residency", "", "| Mode | Turn | Read service (s) | Felt wait (s) | Pin hits | LRU hits | Load misses | Resident pinned | Resident LRU | Resident expert GB |", "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|");
  for (const mode of ["off", "on"] as const) {
    const summary = object(object(modes[mode], `${mode} mode`).summary, `${mode} summary`);
    const turns = array(summary.turns, `${mode} turns`);
    for (let turn = 0; turn < 2; turn++) {
      const item = object(turns[turn], `${mode} turn ${turn + 1}`);
      lines.push(`| ${mode} | ${turn + 1} | ${fmtRange(item.expert_read_service_seconds)} | ${fmtRange(item.expert_wait_seconds)} | ${fmtRange(item.pinned_hits, 0)} | ${fmtRange(item.lru_hits, 0)} | ${fmtRange(item.expert_load_misses, 0)} | ${fmtRange(item.resident_pinned_experts, 0)} | ${fmtRange(item.resident_lru_experts, 0)} | ${fmtRange(item.resident_expert_gb, 1)} |`);
    }
  }
  lines.push("", "## Memory and operating-system deltas", "", "| Mode | Peak footprint GiB | Process swaps | Swap used delta (MiB) | VM swapins | VM swapouts | Compressions | Decompressions |", "|---|---:|---:|---:|---:|---:|---:|---:|");
  for (const mode of ["off", "on"] as const) {
    const summary = object(object(object(modes[mode], `${mode} mode`).summary, `${mode} summary`), `${mode} summary`);
    const process = object(summary.process, `${mode} process`);
    const peak = object(process.peak_memory_footprint_bytes, `${mode} peak`);
    const peakGib = Object.fromEntries(Object.entries(peak).map(([key, value]) => [key, number(value, `${mode} peak ${key}`) / 2 ** 30]));
    const system = object(summary.system_deltas, `${mode} system deltas`);
    lines.push(`| ${mode} | ${fmtRange(peakGib)} | ${fmtRange(process.process_swaps, 0)} | ${fmtRange(system.swap_used_mib, 2)} | ${fmtRange(system.vm_swapins, 0)} | ${fmtRange(system.vm_swapouts, 0)} | ${fmtRange(system.compressions, 0)} | ${fmtRange(system.decompressions, 0)} |`);
  }
  lines.push("", "Every source manifest, result, prompt, response, stdout, stderr, stats file, and pre/post memory sidecar is byte-counted and SHA-256-addressed in the JSON report.", "");
  return lines.join("\n");
}

interface CliOptions extends MatrixReportOptions {
  json?: string;
  markdown?: string;
}

function parseCli(args: string[]): CliOptions {
  const values: Record<string, string> = {};
  for (let index = 0; index < args.length; index += 2) {
    const flag = args[index];
    const value = args[index + 1];
    if (!flag?.startsWith("--") || value === undefined) fail(`expected --name value, got ${flag ?? "end of arguments"}`);
    values[flag.slice(2)] = value;
  }
  const allowed = new Set(["root", "prefix", "json", "markdown"]);
  for (const key of Object.keys(values)) if (!allowed.has(key)) fail(`unknown option --${key}`);
  if (!values.root) fail("--root is required");
  if (!values.prefix) fail("--prefix is required");
  if (!values.json && !values.markdown) fail("at least one of --json or --markdown is required");
  return { root: values.root, prefix: values.prefix, json: values.json, markdown: values.markdown };
}

export async function main(args = process.argv.slice(2)): Promise<void> {
  const options = parseCli(args);
  const report = buildMatrixReport(options);
  const json = stableJson(report);
  const markdown = renderMatrixMarkdown(report);
  if (options.json) await Bun.write(resolve(options.json), json);
  if (options.markdown) await Bun.write(resolve(options.markdown), markdown);
  process.stdout.write(`validated six Colibri G0 warm processes (${options.prefix}); JSON SHA-256 ${sha256(Buffer.from(json))}\n`);
}

if (import.meta.main) {
  await main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
