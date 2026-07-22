// Validate an archive-only Colibri ORACLE_DUMP capture and reduce its raw
// tensors to a compact, deterministic JSON artifact. This script never starts
// Colibri and never loads model weights.
//
// bun scripts/colibri-g0-oracle-report.ts \
//   --oracle-dir runs/colibri-g0/results-YYYYMMDD/numeric-oracle-r1 \
//   --out runs/colibri-g0/results-YYYYMMDD/numeric-oracle-r1.summary.json \
//   --source-label runs/colibri-g0/results-YYYYMMDD/numeric-oracle-r1 \
//   --colibri-pin <40-hex> --snapshot-revision <40-hex> \
//   --source-sha256 <64-hex> --patch-sha256 <64-hex> \
//   --binary-sha256 <64-hex> --tokenizer-sha256 <64-hex>

import { createHash } from "node:crypto";
import {
  closeSync, constants, fstatSync, fsyncSync, lstatSync, openSync, readFileSync,
  realpathSync, renameSync, unlinkSync, writeFileSync,
} from "node:fs";
import { basename, dirname, isAbsolute, posix, relative, resolve, sep } from "node:path";

const PREFIX_IDS = [
  154822, 154824, 154827, 7984, 264, 48520, 1140, 315,
  17054, 12454, 10245, 5109, 11, 448, 825, 2805,
  16134, 11646, 1283, 1817, 1372, 13, 3155, 537,
  2936, 1573, 17054, 3589, 13, 154828, 154841, 154842,
] as const;
const TEACHER_ID = 16;
const TOP_LOGITS = 128;

export interface OracleGeometry {
  hidden: number;
  q_lora: number;
  heads: number;
  q_head: number;
  comp: number;
  kv_lora: number;
  rope: number;
  experts: number;
  topk: 8;
  vocab: number;
}

export const GLM52_ORACLE_GEOMETRY: OracleGeometry = {
  hidden: 6144, q_lora: 2048, heads: 64, q_head: 256, comp: 576,
  kv_lora: 512, rope: 64, experts: 256, topk: 8, vocab: 154880,
};

type DType = "f32" | "i32";

export interface OracleProvenance {
  colibri_pin: string;
  snapshot_revision: string;
  source_sha256: string;
  patch_sha256: string;
  binary_sha256: string;
  tokenizer_sha256: string;
}

export interface OracleReportOptions {
  oracleDir: string;
  out: string;
  sourceLabel: string;
  provenance: OracleProvenance;
}

interface ManifestRecord {
  sequence: number;
  name: string;
  logicalName: string;
  phase: string;
  stage: string;
  dtype: DType;
  shape: number[];
  elements: number;
  bytes: number;
}

interface NumericSummary {
  source: string;
  dtype: DType;
  shape: number[];
  bytes: number;
  sha256: string;
  min: number;
  max: number;
  l2: number;
  finite_count: number;
  element_count: number;
  row_sum_min?: number;
  row_sum_max?: number;
}

interface LogitCandidate {
  token_id: number;
  value: number;
}

type RankedLogit = [token_id: number, value: number];

interface LogitRow {
  source: string;
  phase: string;
  stage: string;
  row: number;
  margin_top1_top2: number;
  top128: RankedLogit[];
}

export interface OracleSummary {
  schema_version: 1;
  capture_kind: "colibri_glm52_g0_numeric_oracle";
  source_label: string;
  provenance: OracleProvenance;
  analyzer: { source: "scripts/colibri-g0-oracle-report.ts"; sha256: string };
  geometry: OracleGeometry;
  manifest: { source: string; sha256: string; bytes: number; record_count: number };
  evidence: {
    teacher_forcing_prefix_ids: number[];
    teacher_decode_id: 16;
    main_next: { token_id: number; logit_argmax: number; margin_top1_top2: number };
    mtp_draft: { count: number; token_id: number; logit_argmax: number; margin_top1_top2: number };
  };
  files: NumericSummary[];
  logit_rows: LogitRow[];
}

function sha256(data: Uint8Array): string {
  return createHash("sha256").update(data).digest("hex");
}

function invariant(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function captureRoot(path: string): string {
  const stat = lstatSync(path);
  invariant(stat.isDirectory() && !stat.isSymbolicLink(), `oracle directory must be a real directory: ${path}`);
  return realpathSync(path);
}

function readRegularFileOnce(path: string, root: string, label: string): Buffer {
  const stat = lstatSync(path);
  invariant(stat.isFile() && !stat.isSymbolicLink(), `${label} must be a regular non-symlink file`);
  invariant(stat.nlink === 1, `${label} must not be a hard-linked file`);
  const real = realpathSync(path);
  const rel = relative(root, real);
  invariant(rel === "" || (!rel.startsWith(`..${sep}`) && rel !== ".." && !isAbsolute(rel)), `${label} escapes the oracle directory`);
  const fd = openSync(path, constants.O_RDONLY | (constants.O_NOFOLLOW ?? 0));
  try {
    const opened = fstatSync(fd);
    invariant(opened.isFile(), `${label} must remain a regular file while open`);
    invariant(opened.dev === stat.dev && opened.ino === stat.ino && opened.size === stat.size, `${label} changed while it was being opened`);
    return readFileSync(fd);
  } finally {
    closeSync(fd);
  }
}

export function writeOracleSummary(path: string, value: unknown): void {
  const parent = realpathSync(dirname(path));
  invariant(lstatSync(parent).isDirectory(), `output parent is not a directory: ${parent}`);
  const temp = resolve(parent, `.${basename(path)}.${process.pid}.tmp`);
  const fd = openSync(temp, constants.O_WRONLY | constants.O_CREAT | constants.O_EXCL | (constants.O_NOFOLLOW ?? 0), 0o644);
  try {
    writeFileSync(fd, `${JSON.stringify(value)}\n`);
    fsyncSync(fd);
  } catch (error) {
    closeSync(fd);
    unlinkSync(temp);
    throw error;
  }
  closeSync(fd);
  renameSync(temp, resolve(parent, basename(path)));
}

export function assertOutputOutsideCapture(path: string, oracleDir: string): void {
  const root = captureRoot(oracleDir);
  const parent = realpathSync(dirname(path));
  const target = resolve(parent, basename(path));
  const rel = relative(root, target);
  invariant(rel === ".." || rel.startsWith(`..${sep}`) || isAbsolute(rel), "--out must be outside the raw oracle directory");
}

function normalizeHash(value: string, flag: string, length: 40 | 64): string {
  invariant(new RegExp(`^[0-9a-fA-F]{${length}}$`).test(value), `${flag} must be ${length} hexadecimal characters`);
  return value.toLowerCase();
}

export function normalizeSourceLabel(value: string): string {
  invariant(value.length > 0, "--source-label must not be empty");
  invariant(!isAbsolute(value) && !value.startsWith("/"), "--source-label must be relative");
  invariant(!value.includes("\\"), "--source-label must use forward slashes");
  const normalized = posix.normalize(value).replace(/^\.\//, "").replace(/\/$/, "");
  invariant(normalized !== "." && normalized !== ".." && !normalized.startsWith("../"), "--source-label must stay within the repository");
  invariant(normalized === value.replace(/^\.\//, "").replace(/\/$/, ""), "--source-label must be normalized");
  return normalized;
}

function parseShape(text: string, line: number): { shape: number[]; elements: number } {
  invariant(/^\d+(?:x\d+){0,2}$/.test(text), `manifest line ${line}: invalid shape ${text}`);
  const shape = text.split("x").map(Number);
  let elements = 1;
  for (const dim of shape) {
    invariant(Number.isSafeInteger(dim) && dim > 0, `manifest line ${line}: dimensions must be positive safe integers`);
    elements *= dim;
    invariant(Number.isSafeInteger(elements), `manifest line ${line}: element count overflow`);
  }
  return { shape, elements };
}

export function parseOracleManifest(text: string): ManifestRecord[] {
  const lines = text.endsWith("\n") ? text.slice(0, -1).split("\n") : text.split("\n");
  invariant(lines[0] === "name\tdtype\tshape\tbytes", "manifest header must be exactly: name\\tdtype\\tshape\\tbytes");
  invariant(lines.length > 1, "manifest contains no payload records");
  const seen = new Set<string>();
  const records: ManifestRecord[] = [];
  const phaseOrder = new Map([["prefill", 0], ["mtp_absorb", 1], ["mtp_draft", 2], ["decode32", 3]]);
  let priorPhase = -1;
  for (let index = 1; index < lines.length; index++) {
    const lineNumber = index + 1;
    const fields = lines[index]!.split("\t");
    invariant(fields.length === 4, `manifest line ${lineNumber}: expected four tab-separated fields`);
    const [name, dtypeText, shapeText, bytesText] = fields as [string, string, string, string];
    const match = name.match(/^(\d{4})\.([a-z][a-z0-9_]*)\.([A-Za-z0-9_.]+)\.(f32|i32)$/);
    invariant(match, `manifest line ${lineNumber}: invalid payload name ${name}`);
    const sequence = Number(match[1]);
    invariant(sequence === index - 1, `manifest line ${lineNumber}: expected sequence ${(index - 1).toString().padStart(4, "0")}`);
    invariant(!seen.has(name), `manifest line ${lineNumber}: duplicate payload ${name}`);
    seen.add(name);
    const phase = match[2]!;
    const stage = match[3]!;
    const dtype = match[4] as DType;
    invariant(dtypeText === dtype, `manifest line ${lineNumber}: dtype does not match filename`);
    const phaseIndex = phaseOrder.get(phase);
    invariant(phaseIndex !== undefined, `manifest line ${lineNumber}: unknown phase ${phase}`);
    invariant(phaseIndex >= priorPhase, `manifest line ${lineNumber}: phase order regressed at ${phase}`);
    priorPhase = phaseIndex;
    const { shape, elements } = parseShape(shapeText, lineNumber);
    invariant(/^\d+$/.test(bytesText), `manifest line ${lineNumber}: invalid byte count`);
    const bytes = Number(bytesText);
    invariant(Number.isSafeInteger(bytes) && bytes === elements * 4, `manifest line ${lineNumber}: byte count ${bytesText} does not match ${elements} ${dtype} values`);
    records.push({ sequence, name, logicalName: `${phase}.${stage}.${dtype}`, phase, stage, dtype, shape, elements, bytes });
  }
  for (const phase of phaseOrder.keys()) invariant(records.some((record) => record.phase === phase), `manifest is missing phase ${phase}`);
  return records;
}

function readValue(buffer: Buffer, dtype: DType, index: number): number {
  return dtype === "f32" ? buffer.readFloatLE(index * 4) : buffer.readInt32LE(index * 4);
}

function worse(a: LogitCandidate, b: LogitCandidate): boolean {
  return a.value < b.value || (a.value === b.value && a.token_id > b.token_id);
}

function heapPushTop(heap: LogitCandidate[], candidate: LogitCandidate): void {
  if (heap.length < TOP_LOGITS) {
    heap.push(candidate);
    let i = heap.length - 1;
    while (i > 0) {
      const parent = (i - 1) >> 1;
      if (!worse(heap[i]!, heap[parent]!)) break;
      [heap[i], heap[parent]] = [heap[parent]!, heap[i]!];
      i = parent;
    }
    return;
  }
  if (!worse(heap[0]!, candidate)) return;
  heap[0] = candidate;
  let i = 0;
  while (true) {
    const left = i * 2 + 1;
    if (left >= heap.length) break;
    const right = left + 1;
    let child = right < heap.length && worse(heap[right]!, heap[left]!) ? right : left;
    if (!worse(heap[child]!, heap[i]!)) break;
    [heap[i], heap[child]] = [heap[child]!, heap[i]!];
    i = child;
  }
}

function sortedTop(heap: LogitCandidate[]): RankedLogit[] {
  return heap.sort((a, b) => b.value - a.value || a.token_id - b.token_id)
    .map((candidate) => [candidate.token_id, candidate.value]);
}

function isLogits(record: ManifestRecord): boolean {
  return record.dtype === "f32" && (record.stage === "main.logits" || record.stage === "mtp_draft.logits");
}

function validateExact(values: number[], expected: readonly number[], label: string): void {
  invariant(values.length === expected.length, `${label}: expected ${expected.length} values, got ${values.length}`);
  for (let i = 0; i < expected.length; i++) invariant(values[i] === expected[i], `${label}: mismatch at index ${i}`);
}

function analyzePayload(record: ManifestRecord, buffer: Buffer, source: string, geometry: OracleGeometry): { summary: NumericSummary; logits: LogitRow[]; values?: number[] } {
  invariant(buffer.byteLength === record.bytes, `${record.name}: payload has ${buffer.byteLength} bytes, manifest declares ${record.bytes}`);
  const collectValues = record.dtype === "i32" && (
    record.stage === "main.input_ids" || record.stage === "mtp_absorb.next_ids" ||
    record.stage === "main.next_id" || record.stage === "mtp_draft.draft_id" ||
    record.stage === "mtp_draft.count"
  );
  const values = collectValues ? [] as number[] : undefined;
  const logits = isLogits(record);
  invariant(!logits || record.shape.length === 2, `${record.name}: logits must be rank 2`);
  const rows = logits ? record.shape[0]! : 0;
  const cols = logits ? record.shape[1]! : 0;
  const heaps = logits ? Array.from({ length: rows }, () => [] as LogitCandidate[]) : [];
  let min = Infinity;
  let max = -Infinity;
  let finite = 0;
  let scale = 0;
  let ssq = 1;
  const rowSums = record.stage.endsWith(".moe.top_weights") ? Array(record.shape[0] ?? 0).fill(0) as number[] : undefined;
  const topIds = record.stage.endsWith(".moe.top_ids") ? Array.from({ length: record.shape[0] ?? 0 }, () => new Set<number>()) : undefined;
  if (topIds) invariant(record.dtype === "i32" && record.shape.length === 2 && record.shape[1] === geometry.topk, `${record.name}: top_ids must be i32 [rows,${geometry.topk}]`);
  if (rowSums) invariant(record.dtype === "f32" && record.shape.length === 2 && record.shape[1] === geometry.topk, `${record.name}: top_weights must be f32 [rows,${geometry.topk}]`);
  if (record.stage.endsWith(".moe.keff")) invariant(record.dtype === "i32" && record.shape.length === 1, `${record.name}: keff must be rank-1 i32`);

  for (let index = 0; index < record.elements; index++) {
    const value = readValue(buffer, record.dtype, index);
    invariant(Number.isFinite(value), `${record.name}: non-finite value at element ${index}`);
    finite++;
    if (value < min) min = value;
    if (value > max) max = value;
    const absolute = Math.abs(value);
    if (absolute !== 0) {
      if (scale < absolute) { ssq = 1 + ssq * (scale / absolute) ** 2; scale = absolute; }
      else ssq += (absolute / scale) ** 2;
    }
    values?.push(value);
    if (logits) heapPushTop(heaps[Math.floor(index / cols)]!, { token_id: index % cols, value });
    if (topIds) {
      invariant(value >= 0 && value < geometry.experts, `${record.name}: expert id ${value} is outside [0,${geometry.experts - 1}]`);
      const row = Math.floor(index / geometry.topk);
      invariant(!topIds[row]!.has(value), `${record.name}: duplicate expert id ${value} in row ${row}`);
      topIds[row]!.add(value);
    }
    if (rowSums) {
      invariant(value >= 0, `${record.name}: negative router weight at element ${index}`);
      rowSums[Math.floor(index / geometry.topk)]! += value;
    }
    if (record.stage.endsWith(".moe.keff")) invariant(value >= 1 && value <= 8, `${record.name}: keff ${value} is outside [1,8]`);
    if (record.stage.endsWith(".moe.sigmoid_scores")) invariant(value >= 0 && value <= 1, `${record.name}: sigmoid score ${value} is outside [0,1]`);
  }
  if (rowSums) {
    const lo = Math.min(...rowSums), hi = Math.max(...rowSums);
    invariant(lo >= 0.25 && hi <= 16, `${record.name}: router row sums ${lo}..${hi} are implausible`);
    invariant(hi - lo <= Math.max(1e-4, hi * 1e-3), `${record.name}: normalized router row sums are inconsistent (${lo}..${hi})`);
  }
  const logitRows = heaps.map((heap, row): LogitRow => {
    const top128 = sortedTop(heap);
    invariant(top128.length >= 2, `${record.name}: logits need at least two columns`);
    return { source, phase: record.phase, stage: record.stage, row, margin_top1_top2: top128[0]![1] - top128[1]![1], top128 };
  });
  const summary: NumericSummary = {
    source, dtype: record.dtype, shape: record.shape, bytes: record.bytes,
    sha256: sha256(buffer), min, max, l2: scale === 0 ? 0 : scale * Math.sqrt(ssq),
    finite_count: finite, element_count: record.elements,
  };
  if (rowSums) { summary.row_sum_min = Math.min(...rowSums); summary.row_sum_max = Math.max(...rowSums); }
  return { summary, logits: logitRows, values };
}

function oneRecord(records: ManifestRecord[], logicalName: string): ManifestRecord {
  const matches = records.filter((record) => record.logicalName === logicalName);
  invariant(matches.length === 1, `expected exactly one ${logicalName} record, got ${matches.length}`);
  return matches[0]!;
}

interface ExpectedRecord { logicalName: string; shape: number[] }

function expected(phase: string, stage: string, dtype: DType, shape: number[]): ExpectedRecord {
  return { logicalName: `${phase}.${stage}.${dtype}`, shape };
}

function expectedLayer(phase: string, layer: number, rows: number, sparse: boolean, geometry: OracleGeometry): ExpectedRecord[] {
  const prefix = `layer${layer}`;
  const result = [
    expected(phase, `${prefix}.residual.entry`, "f32", [rows, geometry.hidden]),
    expected(phase, `${prefix}.attn.norm`, "f32", [rows, geometry.hidden]),
    expected(phase, `${prefix}.attn.qr_norm`, "f32", [rows, geometry.q_lora]),
    expected(phase, `${prefix}.attn.q_roped`, "f32", [rows, geometry.heads, geometry.q_head]),
    expected(phase, `${prefix}.attn.comp_raw`, "f32", [rows, geometry.comp]),
    expected(phase, `${prefix}.kv.lc`, "f32", [rows, geometry.kv_lora]),
    expected(phase, `${prefix}.kv.rc`, "f32", [rows, geometry.rope]),
    expected(phase, `${prefix}.attn.output`, "f32", [rows, geometry.hidden]),
    expected(phase, `${prefix}.attn.post_residual`, "f32", [rows, geometry.hidden]),
    expected(phase, `${prefix}.ffn.norm`, "f32", [rows, geometry.hidden]),
  ];
  if (sparse) result.push(
    expected(phase, `${prefix}.moe.sigmoid_scores`, "f32", [rows, geometry.experts]),
    expected(phase, `${prefix}.moe.top_ids`, "i32", [rows, geometry.topk]),
    expected(phase, `${prefix}.moe.top_weights`, "f32", [rows, geometry.topk]),
    expected(phase, `${prefix}.moe.keff`, "i32", [rows]),
  );
  result.push(
    expected(phase, `${prefix}.ffn.output`, "f32", [rows, geometry.hidden]),
    expected(phase, `${prefix}.residual.final`, "f32", [rows, geometry.hidden]),
  );
  return result;
}

function expectedSchema(geometry: OracleGeometry): ExpectedRecord[] {
  return [
    expected("prefill", "main.input_ids", "i32", [32]),
    ...expectedLayer("prefill", 0, 32, false, geometry),
    ...expectedLayer("prefill", 3, 32, true, geometry),
    ...expectedLayer("prefill", 77, 32, true, geometry),
    expected("prefill", "main.h_all", "f32", [32, geometry.hidden]),
    expected("prefill", "main.logits", "f32", [32, geometry.vocab]),
    expected("prefill", "main.next_id", "i32", [1]),

    expected("mtp_absorb", "mtp_absorb.next_ids", "i32", [31]),
    expected("mtp_absorb", "mtp_absorb.eh_proj", "f32", [31, geometry.hidden]),
    ...expectedLayer("mtp_absorb", 78, 31, true, geometry),
    expected("mtp_absorb", "mtp_absorb.post_layer", "f32", [31, geometry.hidden]),

    expected("mtp_draft", "mtp_draft.emb_norm", "f32", [geometry.hidden]),
    expected("mtp_draft", "mtp_draft.hidden_norm", "f32", [geometry.hidden]),
    expected("mtp_draft", "mtp_draft.concat", "f32", [geometry.hidden * 2]),
    expected("mtp_draft", "mtp_draft.eh_proj", "f32", [geometry.hidden]),
    ...expectedLayer("mtp_draft", 78, 1, true, geometry),
    expected("mtp_draft", "mtp_draft.post_layer", "f32", [geometry.hidden]),
    expected("mtp_draft", "mtp_draft.head_norm", "f32", [geometry.hidden]),
    expected("mtp_draft", "mtp_draft.logits", "f32", [1, geometry.vocab]),
    expected("mtp_draft", "mtp_draft.draft_id", "i32", [1]),
    expected("mtp_draft", "mtp_draft.count", "i32", [1]),

    expected("decode32", "main.input_ids", "i32", [1]),
    ...expectedLayer("decode32", 0, 1, false, geometry),
    ...expectedLayer("decode32", 3, 1, true, geometry),
    ...expectedLayer("decode32", 77, 1, true, geometry),
    expected("decode32", "main.hidden_prenorm", "f32", [1, geometry.hidden]),
    expected("decode32", "main.head_norm", "f32", [geometry.hidden]),
    expected("decode32", "main.logits", "f32", [1, geometry.vocab]),
  ];
}

function validateExactSchema(records: ManifestRecord[], geometry: OracleGeometry): void {
  const schema = expectedSchema(geometry);
  invariant(records.length === schema.length, `expected ${schema.length} oracle records, got ${records.length}`);
  for (let index = 0; index < schema.length; index++) {
    const actual = records[index]!, wanted = schema[index]!;
    invariant(actual.logicalName === wanted.logicalName, `record ${index.toString().padStart(4, "0")}: expected ${wanted.logicalName}, got ${actual.logicalName}`);
    invariant(actual.shape.length === wanted.shape.length && actual.shape.every((dim, axis) => dim === wanted.shape[axis]), `${actual.name}: expected shape ${wanted.shape.join("x")}, got ${actual.shape.join("x")}`);
  }
}

function validateRouterRecordSets(records: ManifestRecord[]): void {
  const routeSuffixes = [".moe.top_ids", ".moe.top_weights", ".moe.keff"] as const;
  const routeRecords = records.filter((record) => routeSuffixes.some((suffix) => record.stage.endsWith(suffix)));
  const keys = new Set(routeRecords.map((record) => {
    const suffix = routeSuffixes.find((candidate) => record.stage.endsWith(candidate))!;
    return `${record.phase}.${record.stage.slice(0, -suffix.length)}`;
  }));
  for (const key of keys) {
    const separator = key.indexOf(".");
    const phase = key.slice(0, separator);
    const base = key.slice(separator + 1);
    const ids = oneRecord(records, `${phase}.${base}.moe.top_ids.i32`);
    const weights = oneRecord(records, `${phase}.${base}.moe.top_weights.f32`);
    const keff = oneRecord(records, `${phase}.${base}.moe.keff.i32`);
    invariant(ids.shape.length === 2 && ids.shape[1] === 8, `${ids.name}: expected [rows,8]`);
    invariant(weights.shape[0] === ids.shape[0] && weights.shape[1] === 8, `${weights.name}: shape must match ${ids.name}`);
    invariant(keff.shape.length === 1 && keff.shape[0] === ids.shape[0], `${keff.name}: row count must match ${ids.name}`);
  }
}

export function analyzeOracleCapture(options: OracleReportOptions, geometry: OracleGeometry = GLM52_ORACLE_GEOMETRY): OracleSummary {
  const sourceLabel = normalizeSourceLabel(options.sourceLabel);
  const provenance: OracleProvenance = {
    colibri_pin: normalizeHash(options.provenance.colibri_pin, "--colibri-pin", 40),
    snapshot_revision: normalizeHash(options.provenance.snapshot_revision, "--snapshot-revision", 40),
    source_sha256: normalizeHash(options.provenance.source_sha256, "--source-sha256", 64),
    patch_sha256: normalizeHash(options.provenance.patch_sha256, "--patch-sha256", 64),
    binary_sha256: normalizeHash(options.provenance.binary_sha256, "--binary-sha256", 64),
    tokenizer_sha256: normalizeHash(options.provenance.tokenizer_sha256, "--tokenizer-sha256", 64),
  };
  invariant(geometry.topk === 8 && geometry.vocab >= TOP_LOGITS, "oracle geometry requires topk=8 and vocab>=128");
  const root = captureRoot(options.oracleDir);
  const manifestPath = resolve(root, "manifest.tsv");
  const manifestBuffer = readRegularFileOnce(manifestPath, root, "manifest.tsv");
  const records = parseOracleManifest(manifestBuffer.toString("utf8"));
  validateExactSchema(records, geometry);
  validateRouterRecordSets(records);
  const summaries: NumericSummary[] = [];
  const logitRows: LogitRow[] = [];
  const smallValues = new Map<string, number[]>();
  for (const record of records) {
    const buffer = readRegularFileOnce(resolve(root, record.name), root, record.name);
    const source = `${sourceLabel}/${record.name}`;
    const analyzed = analyzePayload(record, buffer, source, geometry);
    summaries.push(analyzed.summary);
    logitRows.push(...analyzed.logits);
    if (analyzed.values) smallValues.set(record.logicalName, analyzed.values);
  }

  validateExact(smallValues.get("prefill.main.input_ids.i32") ?? [], PREFIX_IDS, "prefill input ids");
  validateExact(smallValues.get("mtp_absorb.mtp_absorb.next_ids.i32") ?? [], PREFIX_IDS.slice(1), "MTP absorb ids");
  validateExact(smallValues.get("decode32.main.input_ids.i32") ?? [], [TEACHER_ID], "teacher decode id");
  const mainNext = smallValues.get("prefill.main.next_id.i32")?.[0];
  const mtpCount = smallValues.get("mtp_draft.mtp_draft.count.i32")?.[0];
  const mtpDraft = smallValues.get("mtp_draft.mtp_draft.draft_id.i32")?.[0];
  invariant(mainNext !== undefined, "missing main next token evidence");
  invariant(mtpCount === 1, `MTP draft count must be 1, got ${mtpCount}`);
  invariant(mtpDraft !== undefined, "missing MTP draft token evidence");
  const prefillLast = logitRows.find((row) => row.phase === "prefill" && row.stage === "main.logits" && row.row === 31);
  const mtpRow = logitRows.find((row) => row.phase === "mtp_draft" && row.stage === "mtp_draft.logits" && row.row === 0);
  invariant(prefillLast, "prefill logits must contain row 31");
  invariant(mtpRow, "MTP draft logits must contain row 0");
  invariant(mainNext === prefillLast.top128[0]![0], `main.next_id ${mainNext} does not match prefill row-31 argmax ${prefillLast.top128[0]![0]}`);
  invariant(mtpDraft === mtpRow.top128[0]![0], `MTP draft id ${mtpDraft} does not match MTP argmax ${mtpRow.top128[0]![0]}`);

  const analyzerBuffer = readFileSync(import.meta.path);
  return {
    schema_version: 1,
    capture_kind: "colibri_glm52_g0_numeric_oracle",
    source_label: sourceLabel,
    provenance,
    analyzer: { source: "scripts/colibri-g0-oracle-report.ts", sha256: sha256(analyzerBuffer) },
    geometry,
    manifest: { source: `${sourceLabel}/manifest.tsv`, sha256: sha256(manifestBuffer), bytes: manifestBuffer.byteLength, record_count: records.length },
    evidence: {
      teacher_forcing_prefix_ids: [...PREFIX_IDS], teacher_decode_id: TEACHER_ID,
      main_next: { token_id: mainNext, logit_argmax: prefillLast.top128[0]![0], margin_top1_top2: prefillLast.margin_top1_top2 },
      mtp_draft: { count: mtpCount, token_id: mtpDraft, logit_argmax: mtpRow.top128[0]![0], margin_top1_top2: mtpRow.margin_top1_top2 },
    },
    files: summaries,
    logit_rows: logitRows,
  };
}

export function parseOracleReportOptions(args: string[]): OracleReportOptions {
  const flags = ["--oracle-dir", "--out", "--source-label", "--colibri-pin", "--snapshot-revision", "--source-sha256", "--patch-sha256", "--binary-sha256", "--tokenizer-sha256"] as const;
  const allowed = new Set<string>(flags);
  const raw = new Map<string, string>();
  for (let i = 0; i < args.length; i += 2) {
    const name = args[i], value = args[i + 1];
    invariant(name !== undefined && name.startsWith("--"), `invalid argument near ${name ?? "<end>"}`);
    invariant(value !== undefined, `invalid argument near ${name}`);
    invariant(allowed.has(name), `unknown argument: ${name}`);
    invariant(!raw.has(name), `duplicate argument: ${name}`);
    raw.set(name, value);
  }
  for (const flag of flags) invariant(raw.has(flag), `${flag} is required`);
  return {
    oracleDir: resolve(raw.get("--oracle-dir")!), out: resolve(raw.get("--out")!),
    sourceLabel: normalizeSourceLabel(raw.get("--source-label")!),
    provenance: {
      colibri_pin: normalizeHash(raw.get("--colibri-pin")!, "--colibri-pin", 40),
      snapshot_revision: normalizeHash(raw.get("--snapshot-revision")!, "--snapshot-revision", 40),
      source_sha256: normalizeHash(raw.get("--source-sha256")!, "--source-sha256", 64),
      patch_sha256: normalizeHash(raw.get("--patch-sha256")!, "--patch-sha256", 64),
      binary_sha256: normalizeHash(raw.get("--binary-sha256")!, "--binary-sha256", 64),
      tokenizer_sha256: normalizeHash(raw.get("--tokenizer-sha256")!, "--tokenizer-sha256", 64),
    },
  };
}

if (import.meta.main) {
  const options = parseOracleReportOptions(process.argv.slice(2));
  const summary = analyzeOracleCapture(options);
  assertOutputOutsideCapture(options.out, options.oracleDir);
  writeOracleSummary(options.out, summary);
  console.log(`wrote ${options.out}`);
}
