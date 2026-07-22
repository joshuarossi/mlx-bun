// Turn one bounded Colibri GLM-5.2 run and its macOS memory snapshots into
// deterministic, reviewable G0 evidence. This script only reads existing
// artifacts; it never launches Colibri or loads model weights.
//
//   bun scripts/colibri-g0-report.ts \
//     --log runs/colibri-g0/results-YYYYMMDD/cell.log \
//     --cache-state process-cold --boot-state not-boot-cold \
//     --classification-source "fresh process; direct-I/O run manifest X"

import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { basename, resolve } from "node:path";

type CacheState = "process-cold" | "warm-explicit-lru" | "unspecified";
type BootState = "boot-cold" | "not-boot-cold" | "unspecified";

export interface ColibriLogMetrics {
  backend: string;
  unified_memory_zero_copy: boolean;
  mtp_active: boolean;
  draft_tokens: number;
  ram_budget_gb: number;
  projected_peak_gb: number;
  context_tokens: number;
  cache_cap_per_layer: number;
  direct_io: boolean;
  mmap: boolean;
  pipe: boolean;
  dsa: string;
  model_load_seconds: number;
  resident_dense_mb: number;
  layers: number;
  experts: number;
  prompt_tokens: number;
  generation_limit: number;
  generated_tokens: number;
  ttft_ms: null;
  prefill_seconds: number;
  decode_seconds: number;
  decode_tokens_per_second: number;
  expert_hit_percent: number;
  pinned_hit_percent: number;
  lru_hit_percent: number;
  rss_reported_gb: number;
  expert_loads_per_token: number;
  expert_loads_per_layer: number;
  tokens_per_forward: number;
  decode_forwards: number;
  mtp_acceptance_percent: number;
  mtp_accepted: number;
  mtp_proposed: number;
  disk_misses_draft: number | null;
  disk_misses_absorb: number | null;
  disk_misses_verify_main: number | null;
  mtp_layer_loads: number | null;
  mtp_layer_gb: number | null;
  main_layer_loads: number | null;
  main_layer_gb: number | null;
  mtp_byte_percent: number | null;
  expert_fetch_gb: number;
  expert_read_service_seconds: number;
  expert_wait_seconds: number;
  resident_pinned_experts: number;
  resident_lru_experts: number;
  resident_expert_gb: number;
  metal_fallback_cpu_max_observed: number;
  wall_seconds: number;
  maximum_resident_set_bytes: number;
  process_swaps: number;
  peak_memory_footprint_bytes: number;
  token_ids: number[] | null;
}

export interface SystemSnapshot {
  page_size_bytes: number | null;
  total_memory_bytes: number | null;
  free_percent: number | null;
  values: Record<string, number>;
}

interface FileEvidence {
  path: string;
  sha256: string;
}

export interface CellSummary {
  schema_version: 1;
  capture_kind: "colibri_glm52_g0_cell_summary";
  cell_id: string;
  classification: { cache_state: CacheState; boot_state: BootState; evidence_source: string };
  completeness: {
    ttft: false;
    token_ids: boolean;
    disk_split: boolean;
    memory_pressure_pre_post: boolean;
    vm_stat_pre_post: boolean;
    swap_pre_post: boolean;
  };
  sources: Record<string, FileEvidence>;
  analyzer: FileEvidence;
  run: ColibriLogMetrics;
  system_memory: {
    memory_pressure_pre: SystemSnapshot | null;
    memory_pressure_post: SystemSnapshot | null;
    memory_pressure_post_minus_pre: Record<string, number> | null;
    vm_stat_pre: SystemSnapshot | null;
    vm_stat_post: SystemSnapshot | null;
    vm_stat_post_minus_pre: Record<string, number> | null;
    vm_stat_compressor_bytes_post_minus_pre: number | null;
    swap_used_mb_pre: number | null;
    swap_used_mb_post: number | null;
  };
}

export interface ColibriG0ReportOptions {
  log: string;
  jsonOut: string;
  markdownOut: string;
  cacheState: CacheState;
  bootState: BootState;
  classificationSource: string;
  memoryPressurePre?: string;
  memoryPressurePost?: string;
  vmStatPre?: string;
  vmStatPost?: string;
  swapPre?: string;
  swapPost?: string;
}

function requiredMatch(text: string, pattern: RegExp, label: string): RegExpMatchArray {
  const match = text.match(pattern);
  if (!match) throw new Error(`Colibri log is missing ${label}`);
  return match;
}

function numberAt(match: RegExpMatchArray, index: number, label: string): number {
  const value = Number(match[index]);
  if (!Number.isFinite(value)) throw new Error(`invalid ${label}: ${match[index]}`);
  return value;
}

function optionalNumberAt(match: RegExpMatchArray | null, index: number, label: string): number | null {
  return match ? numberAt(match, index, label) : null;
}

function flag(value: string): boolean {
  return value === "1";
}

export function parseColibriLog(text: string): ColibriLogMetrics {
  const backend = requiredMatch(text, /^\[METAL\] mode: (.+)$/m, "Metal backend marker");
  const mtp = requiredMatch(text, /^\[MTP\] (active|absent)(?:[^\n]*?)\(draft=(\d+)\)/m, "MTP marker");
  const budget = requiredMatch(text, /^\[RAM_GB=([\d.]+)\].*?projected peak ([\d.]+) GB\)/m, "RAM budget");
  const config = requiredMatch(
    text,
    /^\[PROF\] config: RAM_GB=([\d.]+) CTX=(\d+) \| expert cache cap (\d+)\/layer.*?DRAFT=(\d+) PIPE=(\d+) DIRECT=(\d+) MMAP=(\d+) IDOT=\d+ DSA=([^ ]+)/m,
    "profiler config",
  );
  const loaded = requiredMatch(
    text,
    /^loaded in ([\d.]+)s \| resident dense: ([\d.]+) MB \| layers=(\d+) experts=(\d+) \| MTP (ACTIVE|absent) \(draft=(\d+)\)$/m,
    "model load metrics",
  );
  const prompt = requiredMatch(
    text,
    /^prompt: (\d+) tokens \| generating up to (\d+).*?\| n-gram draft=(\d+)$/m,
    "prompt metrics",
  );
  const decode = requiredMatch(
    text,
    /^prefill (\d+) tokens in ([\d.]+)s \| decode (\d+) tokens in ([\d.]+)s \(([\d.]+) tok\/s\) \| expert hit rate ([\d.]+)% \(pin ([\d.]+)% \+ lru ([\d.]+)%\) \| RSS ([\d.]+) GB$/m,
    "final prefill/decode metrics",
  );
  const loads = requiredMatch(
    text,
    /^experts loaded\/token: ([\d.]+) \(per-layer ([\d.]+) across \d+;/m,
    "expert load metrics",
  );
  const speculation = requiredMatch(
    text,
    /^speculation: ([\d.]+) tokens\/forward \((\d+) forwards per (\d+) tokens\) \| MTP acceptance ([\d.]+)% \((\d+)\/(\d+)\)$/m,
    "speculation metrics",
  );
  const diskSplit = text.match(
    /^disk-load split: draft (\d+) \+ absorb (\d+) \+ verify\/main (\d+) misses \| MTP-layer (\d+) loads ([\d.]+) GB \| main-layers (\d+) loads ([\d.]+) GB \(MTP ([\d.]+)% of bytes\)$/m,
  );
  const io = requiredMatch(
    text,
    /^\[PROF\] expert I\/O: ([\d.]+) GB fetched .*?\| [\d.]+ loads\/token \| ([\d.]+)s read service \/ ([\d.]+)s felt wait$/m,
    "expert I/O metrics",
  );
  const resident = requiredMatch(
    text,
    /^\[PROF\] resident experts: (\d+) pinned \([\d.]+ GB\) \+ (\d+) in LRU \(([\d.]+) GB, cap (\d+)\/layer\)$/m,
    "resident expert metrics",
  );
  const wall = requiredMatch(text, /^\s*([\d.]+) real\s+[\d.]+ user\s+[\d.]+ sys$/m, "wall time");
  const maxRss = requiredMatch(text, /^\s*(\d+)\s+maximum resident set size$/m, "maximum resident set size");
  const swaps = requiredMatch(text, /^\s*(\d+)\s+swaps$/m, "process swap count");
  const footprint = requiredMatch(text, /^\s*(\d+)\s+peak memory footprint$/m, "peak memory footprint");
  const metalMatches = [...text.matchAll(/^METAL: blocchi GPU \d+ \| fallback CPU (\d+)/gm)];
  if (metalMatches.length === 0) throw new Error("Colibri log is missing Metal fallback metrics");
  const tokenMatch = text.match(/^\[TOKENS\] (\d+) generated:\s*(.*)$/m);
  const tokenIds = tokenMatch
    ? tokenMatch[2]!.trim().split(/\s+/).filter(Boolean).map((value) => Number(value))
    : null;
  if (tokenIds && tokenIds.length !== Number(tokenMatch![1])) {
    throw new Error(`token dump declares ${tokenMatch![1]} tokens but contains ${tokenIds.length}`);
  }
  if (tokenIds?.some((value) => !Number.isInteger(value))) throw new Error("token dump contains an invalid token ID");
  if (tokenIds && tokenIds.length !== numberAt(decode, 3, "generated tokens")) {
    throw new Error(`token dump has ${tokenIds.length} IDs but decode reports ${decode[3]} generated tokens`);
  }
  const declaredDrafts = [
    numberAt(mtp, 2, "MTP marker draft"),
    numberAt(config, 4, "config draft"),
    numberAt(loaded, 6, "loaded draft"),
    numberAt(prompt, 3, "prompt draft"),
  ];
  if (new Set(declaredDrafts).size !== 1) throw new Error(`inconsistent draft settings: ${declaredDrafts.join(", ")}`);
  if ((mtp[1] === "active") !== (loaded[5] === "ACTIVE")) throw new Error("inconsistent MTP activation markers");
  const generated = numberAt(decode, 3, "generated tokens");
  const accepted = numberAt(speculation, 5, "MTP accepted");
  const proposed = numberAt(speculation, 6, "MTP proposed");
  if (numberAt(decode, 1, "prefill token count") !== numberAt(prompt, 1, "prompt tokens")) {
    throw new Error("prefill token count does not match prompt token count");
  }
  if (numberAt(speculation, 3, "speculation generated tokens") !== generated) {
    throw new Error("speculation token total does not match generated token count");
  }
  if (accepted > proposed) throw new Error("MTP accepted count exceeds proposed count");
  const hit = numberAt(decode, 6, "expert hit percent");
  const hitParts = numberAt(decode, 7, "pinned hit percent") + numberAt(decode, 8, "LRU hit percent");
  if (Math.abs(hit - hitParts) > 0.11) throw new Error("expert hit total does not match pin + LRU hits");
  if (numberAt(budget, 1, "RAM budget") !== numberAt(config, 1, "config RAM budget")) {
    throw new Error("RAM budget does not match profiler config");
  }
  if (numberAt(config, 3, "config cache cap") !== numberAt(resident, 4, "resident cache cap")) {
    throw new Error("resident cache cap does not match profiler config");
  }
  if (mtp[1] === "absent") {
    if (declaredDrafts[0] !== 0 || accepted !== 0 || proposed !== 0) {
      throw new Error("MTP-off run reports draft or acceptance activity");
    }
    if (diskSplit && (Number(diskSplit[1]) !== 0 || Number(diskSplit[2]) !== 0 ||
        Number(diskSplit[4]) !== 0 || Number(diskSplit[5]) !== 0 || Number(diskSplit[8]) !== 0)) {
      throw new Error("MTP-off run reports MTP disk activity");
    }
  }

  return {
    backend: backend[1]!,
    unified_memory_zero_copy: backend[1]!.includes("unified-memory zero-copy"),
    mtp_active: mtp[1] === "active",
    draft_tokens: numberAt(mtp, 2, "draft tokens"),
    ram_budget_gb: numberAt(budget, 1, "RAM budget"),
    projected_peak_gb: numberAt(budget, 2, "projected peak"),
    context_tokens: numberAt(config, 2, "context tokens"),
    cache_cap_per_layer: numberAt(config, 3, "cache cap"),
    pipe: flag(config[5]!),
    direct_io: flag(config[6]!),
    mmap: flag(config[7]!),
    dsa: config[8]!,
    model_load_seconds: numberAt(loaded, 1, "model load seconds"),
    resident_dense_mb: numberAt(loaded, 2, "resident dense MB"),
    layers: numberAt(loaded, 3, "layer count"),
    experts: numberAt(loaded, 4, "expert count"),
    prompt_tokens: numberAt(prompt, 1, "prompt tokens"),
    generation_limit: numberAt(prompt, 2, "generation limit"),
    generated_tokens: generated,
    ttft_ms: null,
    prefill_seconds: numberAt(decode, 2, "prefill seconds"),
    decode_seconds: numberAt(decode, 4, "decode seconds"),
    decode_tokens_per_second: numberAt(decode, 5, "decode throughput"),
    expert_hit_percent: numberAt(decode, 6, "expert hit percent"),
    pinned_hit_percent: numberAt(decode, 7, "pinned hit percent"),
    lru_hit_percent: numberAt(decode, 8, "LRU hit percent"),
    rss_reported_gb: numberAt(decode, 9, "reported RSS"),
    expert_loads_per_token: numberAt(loads, 1, "expert loads/token"),
    expert_loads_per_layer: numberAt(loads, 2, "expert loads/layer"),
    tokens_per_forward: numberAt(speculation, 1, "tokens/forward"),
    decode_forwards: numberAt(speculation, 2, "decode forwards"),
    mtp_acceptance_percent: numberAt(speculation, 4, "MTP acceptance percent"),
    mtp_accepted: accepted,
    mtp_proposed: proposed,
    disk_misses_draft: optionalNumberAt(diskSplit, 1, "draft disk misses"),
    disk_misses_absorb: optionalNumberAt(diskSplit, 2, "absorb disk misses"),
    disk_misses_verify_main: optionalNumberAt(diskSplit, 3, "verify/main disk misses"),
    mtp_layer_loads: optionalNumberAt(diskSplit, 4, "MTP layer loads"),
    mtp_layer_gb: optionalNumberAt(diskSplit, 5, "MTP layer GB"),
    main_layer_loads: optionalNumberAt(diskSplit, 6, "main layer loads"),
    main_layer_gb: optionalNumberAt(diskSplit, 7, "main layer GB"),
    mtp_byte_percent: optionalNumberAt(diskSplit, 8, "MTP byte percent"),
    expert_fetch_gb: numberAt(io, 1, "expert fetch GB"),
    expert_read_service_seconds: numberAt(io, 2, "expert read service seconds"),
    expert_wait_seconds: numberAt(io, 3, "expert wait seconds"),
    resident_pinned_experts: numberAt(resident, 1, "resident pinned experts"),
    resident_lru_experts: numberAt(resident, 2, "resident LRU experts"),
    resident_expert_gb: numberAt(resident, 3, "resident expert GB"),
    metal_fallback_cpu_max_observed: Math.max(...metalMatches.map((match) => Number(match[1]))),
    wall_seconds: numberAt(wall, 1, "wall seconds"),
    maximum_resident_set_bytes: numberAt(maxRss, 1, "maximum resident set bytes"),
    process_swaps: numberAt(swaps, 1, "process swaps"),
    peak_memory_footprint_bytes: numberAt(footprint, 1, "peak memory footprint"),
    token_ids: tokenIds,
  };
}

function normalizeKey(key: string): string {
  return key.replaceAll('"', "").trim().toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
}

function parseKeyValues(text: string): Record<string, number> {
  const values: Record<string, number> = {};
  for (const line of text.split("\n")) {
    const match = line.match(/^\s*(.+?):\s*(-?[\d.]+)\.?\s*$/);
    if (match) values[normalizeKey(match[1]!)] = Number(match[2]);
  }
  return values;
}

export function parseMemoryPressure(text: string): SystemSnapshot {
  const header = text.match(/The system has (\d+) \(\d+ pages with a page size of (\d+)\)\./);
  const free = text.match(/System-wide memory free percentage:\s*([\d.]+)%/);
  if (!header || !free) throw new Error("malformed memory_pressure snapshot");
  const values = parseKeyValues(text);
  for (const key of ["swapins", "swapouts", "pages_decompressed", "pages_compressed", "pageins", "pageouts"]) {
    if (values[key] === undefined) throw new Error(`memory_pressure snapshot is missing ${key}`);
  }
  return {
    page_size_bytes: Number(header[2]),
    total_memory_bytes: Number(header[1]),
    free_percent: Number(free[1]),
    values,
  };
}

export function parseVmStat(text: string): SystemSnapshot {
  const pageSize = text.match(/page size of (\d+) bytes/);
  if (!pageSize) throw new Error("malformed vm_stat snapshot");
  const values = parseKeyValues(text);
  for (const key of ["decompressions", "compressions", "pageins", "pageouts", "swapins", "swapouts"]) {
    if (values[key] === undefined) throw new Error(`vm_stat snapshot is missing ${key}`);
  }
  return {
    page_size_bytes: Number(pageSize[1]),
    total_memory_bytes: null,
    free_percent: null,
    values,
  };
}

export function parseSwapUsedMb(text: string): number {
  const match = text.match(/used = ([\d.]+)M/);
  if (!match) throw new Error("malformed vm.swapusage snapshot");
  return Number(match[1]);
}

function subtractSnapshots(pre: SystemSnapshot | null, post: SystemSnapshot | null): Record<string, number> | null {
  if (!pre || !post) return null;
  const delta: Record<string, number> = {};
  for (const [key, postValue] of Object.entries(post.values)) {
    const preValue = pre.values[key];
    if (preValue !== undefined) delta[key] = postValue - preValue;
  }
  return delta;
}

interface LoadedEvidence {
  text: string;
  evidence: FileEvidence;
}

function loadEvidence(path: string, displayPath = basename(path)): LoadedEvidence {
  const bytes = readFileSync(path);
  return {
    text: bytes.toString("utf8"),
    evidence: { path: displayPath, sha256: createHash("sha256").update(bytes).digest("hex") },
  };
}

function requirePair(name: string, pre: string | undefined, post: string | undefined): void {
  if (Boolean(pre) !== Boolean(post)) throw new Error(`${name} requires both pre and post snapshots`);
}

function validateSnapshotPair(name: string, pre: SystemSnapshot | null, post: SystemSnapshot | null): void {
  if (!pre || !post) return;
  if (pre.page_size_bytes !== post.page_size_bytes) throw new Error(`${name} page sizes do not match`);
  if (pre.total_memory_bytes !== post.total_memory_bytes) throw new Error(`${name} total memory does not match`);
}

function validateCumulativeDelta(name: string, delta: Record<string, number> | null, keys: string[]): void {
  if (!delta) return;
  for (const key of keys) {
    if (delta[key] === undefined) throw new Error(`${name} delta is missing ${key}`);
    if (delta[key] < 0) throw new Error(`${name} cumulative counter decreased: ${key}`);
  }
}

function sidecar(log: string, suffix: string): string | undefined {
  const stem = log.endsWith(".log") ? log.slice(0, -4) : log;
  const path = `${stem}.${suffix}.txt`;
  return existsSync(path) ? path : undefined;
}

export function analyzeCell(options: ColibriG0ReportOptions): CellSummary {
  if (!options.classificationSource.trim()) throw new Error("classification evidence source is required");
  if (options.cacheState === "warm-explicit-lru") {
    throw new Error("a standalone Colibri log cannot prove warm explicit-LRU state; use colibri-g0-warm.ts");
  }
  requirePair("memory_pressure", options.memoryPressurePre, options.memoryPressurePost);
  requirePair("vm_stat", options.vmStatPre, options.vmStatPost);
  requirePair("vm.swapusage", options.swapPre, options.swapPost);
  const loaded: Record<string, LoadedEvidence> = { log: loadEvidence(options.log) };
  const sourcePaths: Record<string, string | undefined> = {
    memory_pressure_pre: options.memoryPressurePre,
    memory_pressure_post: options.memoryPressurePost,
    vm_stat_pre: options.vmStatPre,
    vm_stat_post: options.vmStatPost,
    swap_pre: options.swapPre,
    swap_post: options.swapPost,
  };
  for (const [name, path] of Object.entries(sourcePaths)) if (path) loaded[name] = loadEvidence(path);
  const mpPre = loaded.memory_pressure_pre ? parseMemoryPressure(loaded.memory_pressure_pre.text) : null;
  const mpPost = loaded.memory_pressure_post ? parseMemoryPressure(loaded.memory_pressure_post.text) : null;
  const vmPre = loaded.vm_stat_pre ? parseVmStat(loaded.vm_stat_pre.text) : null;
  const vmPost = loaded.vm_stat_post ? parseVmStat(loaded.vm_stat_post.text) : null;
  validateSnapshotPair("memory_pressure", mpPre, mpPost);
  validateSnapshotPair("vm_stat", vmPre, vmPost);
  const allPageSizes = [mpPre, mpPost, vmPre, vmPost].flatMap((snapshot) => snapshot?.page_size_bytes == null ? [] : [snapshot.page_size_bytes]);
  if (new Set(allPageSizes).size > 1) throw new Error("memory_pressure and vm_stat page sizes do not match");
  const vmDelta = subtractSnapshots(vmPre, vmPost);
  const mpDelta = subtractSnapshots(mpPre, mpPost);
  validateCumulativeDelta("memory_pressure", mpDelta,
    ["swapins", "swapouts", "pages_decompressed", "pages_compressed", "pageins", "pageouts"]);
  validateCumulativeDelta("vm_stat", vmDelta,
    ["decompressions", "compressions", "pageins", "pageouts", "swapins", "swapouts"]);
  const sources: Record<string, FileEvidence> = {};
  for (const [name, source] of Object.entries(loaded)) sources[name] = source.evidence;
  const analyzer = loadEvidence(import.meta.path, "scripts/colibri-g0-report.ts").evidence;
  const run = parseColibriLog(loaded.log!.text);

  return {
    schema_version: 1,
    capture_kind: "colibri_glm52_g0_cell_summary",
    cell_id: basename(options.log).replace(/\.log$/, ""),
    classification: {
      cache_state: options.cacheState,
      boot_state: options.bootState,
      evidence_source: options.classificationSource,
    },
    completeness: {
      ttft: false,
      token_ids: run.token_ids !== null,
      disk_split: run.main_layer_gb !== null,
      memory_pressure_pre_post: Boolean(mpPre && mpPost),
      vm_stat_pre_post: Boolean(vmPre && vmPost),
      swap_pre_post: Boolean(loaded.swap_pre && loaded.swap_post),
    },
    sources,
    analyzer,
    run,
    system_memory: {
      memory_pressure_pre: mpPre,
      memory_pressure_post: mpPost,
      memory_pressure_post_minus_pre: mpDelta,
      vm_stat_pre: vmPre,
      vm_stat_post: vmPost,
      vm_stat_post_minus_pre: vmDelta,
      vm_stat_compressor_bytes_post_minus_pre:
        vmDelta?.pages_occupied_by_compressor != null && vmPost?.page_size_bytes != null
          ? vmDelta.pages_occupied_by_compressor * vmPost.page_size_bytes
          : null,
      swap_used_mb_pre: loaded.swap_pre ? parseSwapUsedMb(loaded.swap_pre.text) : null,
      swap_used_mb_post: loaded.swap_post ? parseSwapUsedMb(loaded.swap_post.text) : null,
    },
  };
}

function gb(bytes: number): string {
  return (bytes / 1e9).toFixed(2);
}

function valueOrDash(value: number | null | undefined): string {
  return value == null ? "—" : String(value);
}

export function renderMarkdown(summary: CellSummary): string {
  const r = summary.run;
  const memory = summary.system_memory;
  const vmDelta = memory.vm_stat_post_minus_pre;
  const lines = [
    `# Colibri G0 cell — ${summary.cell_id}`,
    "",
    `- Cache state: **${summary.classification.cache_state}**; boot state: **${summary.classification.boot_state}**`,
    `- Classification evidence: ${summary.classification.evidence_source}`,
    `- Backend: ${r.backend}; Metal CPU fallback max observed: **${r.metal_fallback_cpu_max_observed}**`,
    `- Log SHA256: \`${summary.sources.log!.sha256}\``,
    "",
    "| metric | value |",
    "|---|---:|",
    `| MTP | ${r.mtp_active ? `on (draft=${r.draft_tokens})` : "off"} |`,
    `| prompt / generated tokens | ${r.prompt_tokens} / ${r.generated_tokens} |`,
    `| token IDs | ${r.token_ids ? `${r.token_ids.length} captured` : "not emitted by Colibri"} |`,
    "| TTFT | not captured by standalone Colibri log |",
    `| prefill | ${r.prefill_seconds.toFixed(2)} s |`,
    `| decode | ${r.decode_tokens_per_second.toFixed(2)} tok/s (${r.decode_seconds.toFixed(2)} s) |`,
    `| wall | ${r.wall_seconds.toFixed(2)} s |`,
    `| MTP acceptance | ${r.mtp_accepted}/${r.mtp_proposed} (${r.mtp_acceptance_percent.toFixed(1)}%) |`,
    `| tokens / forward | ${r.tokens_per_forward.toFixed(2)} (${r.decode_forwards} forwards) |`,
    `| expert hit | ${r.expert_hit_percent.toFixed(1)}% (pin ${r.pinned_hit_percent.toFixed(1)}% + LRU ${r.lru_hit_percent.toFixed(1)}%) |`,
    `| expert fetch | ${r.expert_fetch_gb.toFixed(3)} GB |`,
    `| layer-accounted expert read | ${r.main_layer_gb == null ? "—" : `main ${r.main_layer_gb.toFixed(2)} GB + MTP ${r.mtp_layer_gb!.toFixed(2)} GB`} |`,
    `| expert service / wait | ${r.expert_read_service_seconds.toFixed(1)} / ${r.expert_wait_seconds.toFixed(1)} s |`,
    `| maximum RSS | ${gb(r.maximum_resident_set_bytes)} GB |`,
    `| peak footprint | ${gb(r.peak_memory_footprint_bytes)} GB |`,
    `| process swaps | ${r.process_swaps} |`,
    `| system swap used pre / post | ${valueOrDash(memory.swap_used_mb_pre)} / ${valueOrDash(memory.swap_used_mb_post)} MB |`,
    `| vm_stat compressor pages post−pre | ${valueOrDash(vmDelta?.pages_occupied_by_compressor)} |`,
    `| vm_stat compressions post−pre | ${valueOrDash(vmDelta?.compressions)} |`,
    `| vm_stat decompressions post−pre | ${valueOrDash(vmDelta?.decompressions)} |`,
    "",
  ];
  return lines.join("\n");
}

function parseChoice<T extends string>(value: string, choices: readonly T[], flagName: string): T {
  if (!choices.includes(value as T)) throw new Error(`${flagName} must be one of: ${choices.join(", ")}`);
  return value as T;
}

function parseOptions(args: string[]): ColibriG0ReportOptions {
  const allowed = new Set([
    "--log", "--out-json", "--out-markdown", "--cache-state", "--boot-state", "--classification-source",
    "--memory-pressure-pre", "--memory-pressure-post", "--vm-stat-pre", "--vm-stat-post",
    "--swap-pre", "--swap-post",
  ]);
  const raw: Record<string, string> = {};
  for (let i = 0; i < args.length; i += 2) {
    const name = args[i];
    const value = args[i + 1];
    if (!name?.startsWith("--") || value === undefined) throw new Error(`invalid argument near ${name ?? "<end>"}`);
    if (!allowed.has(name)) throw new Error(`unknown argument: ${name}`);
    raw[name] = value;
  }
  if (!raw["--log"]) throw new Error("--log is required");
  if (!raw["--classification-source"]) throw new Error("--classification-source is required");
  const log = resolve(raw["--log"]);
  const stem = log.endsWith(".log") ? log.slice(0, -4) : log;
  const explicit = (name: string): string | undefined => raw[name] ? resolve(raw[name]) : undefined;
  return {
    log,
    jsonOut: resolve(raw["--out-json"] ?? `${stem}.summary.json`),
    markdownOut: resolve(raw["--out-markdown"] ?? `${stem}.summary.md`),
    cacheState: parseChoice(raw["--cache-state"] ?? "unspecified", ["process-cold", "warm-explicit-lru", "unspecified"] as const, "--cache-state"),
    bootState: parseChoice(raw["--boot-state"] ?? "unspecified", ["boot-cold", "not-boot-cold", "unspecified"] as const, "--boot-state"),
    classificationSource: raw["--classification-source"],
    memoryPressurePre: explicit("--memory-pressure-pre") ?? sidecar(log, "memory-pressure.pre"),
    memoryPressurePost: explicit("--memory-pressure-post") ?? sidecar(log, "memory-pressure.post"),
    vmStatPre: explicit("--vm-stat-pre") ?? sidecar(log, "vm-stat.pre"),
    vmStatPost: explicit("--vm-stat-post") ?? sidecar(log, "vm-stat.post"),
    swapPre: explicit("--swap-pre") ?? sidecar(log, "swap.pre"),
    swapPost: explicit("--swap-post") ?? sidecar(log, "swap.post"),
  };
}

if (import.meta.main) {
  const options = parseOptions(process.argv.slice(2));
  const summary = analyzeCell(options);
  await Promise.all([
    Bun.write(options.jsonOut, `${JSON.stringify(summary, null, 2)}\n`),
    Bun.write(options.markdownOut, renderMarkdown(summary)),
  ]);
  console.log(`wrote ${options.jsonOut}`);
  console.log(`wrote ${options.markdownOut}`);
}
