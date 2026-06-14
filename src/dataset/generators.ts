// The 13 dataset generators, ported from optiq's dataset_templates.py
// `_gen_*` functions. Each is `async (inputs, emit, llm?) -> Row[]`.
//
// Row shapes (per output_format):
//   messages          → { messages: [{ role, content }, ...] }
//   prompt_completion → { prompt, completion }
//   dpo               → { prompt, chosen, rejected }
//   text              → { text }
// Rows may carry extra keys (metadata, tools) to mirror the Python output.

import type { Emit } from "../jobs/types";
import type { ChatMessage, LlmClient } from "./llm";

export type Row = Record<string, unknown>;

type Inputs = Record<string, unknown>;

/** Coerce a maybe-undefined input to a trimmed string. */
function str(v: unknown): string {
  if (v === undefined || v === null) return "";
  return typeof v === "string" ? v : String(v);
}

/** Coerce a maybe-undefined numeric input, falling back to `dflt`. */
function num(v: unknown, dflt: number): number {
  if (v === undefined || v === null || v === "") return dflt;
  const n = typeof v === "number" ? v : parseInt(String(v), 10);
  return Number.isFinite(n) ? n : dflt;
}

/** Split lines, trim, drop blanks (Python `splitlines()` + strip filter). */
function nonEmptyLines(v: unknown): string[] {
  return str(v)
    .split(/\r?\n/)
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

/** Require an llm client, with a clear message naming the template. */
function requireLlm(llm: LlmClient | undefined, template: string): LlmClient {
  if (!llm) {
    throw new Error(
      `template ${JSON.stringify(template)} is LLM-driven and requires a served ` +
        `model — pass an LlmClient (mlx-bun loopback /v1/chat/completions).`,
    );
  }
  return llm;
}

// ===========================================================================
// Non-LLM generators (full ports, well-tested)
// ===========================================================================

export async function genSftQa(inputs: Inputs): Promise<Row[]> {
  const text = str(inputs.pairs_text).trim();
  if (!text) return [];
  const rows: Row[] = [];
  // Split on blank lines; each block expected to contain Q: / A:.
  for (const block of text.split(/\n\s*\n/)) {
    const qMatch = block.match(/^[ \t]*Q[ \t]*:[ \t]*(.+)/im);
    // DOTALL for the answer: capture everything after `A:` to end of block.
    const aMatch = block.match(/^[ \t]*A[ \t]*:[ \t]*([\s\S]+)/im);
    if (qMatch && aMatch) {
      rows.push({
        messages: [
          { role: "user", content: qMatch[1]!.trim() },
          { role: "assistant", content: aMatch[1]!.trim() },
        ],
      });
    }
  }
  return rows;
}

/**
 * Minimal RFC-4180-ish CSV parser: handles quoted fields, embedded commas,
 * embedded newlines, and "" escaped quotes. No external dep. Returns a list
 * of records keyed by the header row.
 */
export function parseCsv(text: string): Record<string, string>[] {
  const rows: string[][] = [];
  let field = "";
  let record: string[] = [];
  let inQuotes = false;
  let i = 0;
  const n = text.length;

  const endField = () => {
    record.push(field);
    field = "";
  };
  const endRecord = () => {
    endField();
    rows.push(record);
    record = [];
  };

  while (i < n) {
    const ch = text[i]!;
    if (inQuotes) {
      if (ch === '"') {
        if (text[i + 1] === '"') {
          field += '"'; // escaped quote
          i += 2;
          continue;
        }
        inQuotes = false;
        i++;
        continue;
      }
      field += ch;
      i++;
      continue;
    }
    if (ch === '"') {
      inQuotes = true;
      i++;
      continue;
    }
    if (ch === ",") {
      endField();
      i++;
      continue;
    }
    if (ch === "\r") {
      // Treat \r\n and lone \r as record separators.
      endRecord();
      if (text[i + 1] === "\n") i += 2;
      else i++;
      continue;
    }
    if (ch === "\n") {
      endRecord();
      i++;
      continue;
    }
    field += ch;
    i++;
  }
  // Flush trailing field/record if there's pending content.
  if (field.length > 0 || record.length > 0) endRecord();

  if (rows.length === 0) return [];
  const header = rows[0]!.map((h) => h.trim());
  const out: Record<string, string>[] = [];
  for (let r = 1; r < rows.length; r++) {
    const cells = rows[r]!;
    // Skip fully-empty trailing rows (e.g. file ending in a newline).
    if (cells.length === 1 && cells[0] === "") continue;
    const obj: Record<string, string> = {};
    for (let c = 0; c < header.length; c++) {
      obj[header[c]!] = cells[c] ?? "";
    }
    out.push(obj);
  }
  return out;
}

export async function genDpoPairs(inputs: Inputs): Promise<Row[]> {
  const text = str(inputs.csv_text).trim();
  if (!text) return [];
  const rows: Row[] = [];
  for (const r of parseCsv(text)) {
    // Match Python: keep only rows where all three are truthy (non-empty).
    if (r.prompt && r.chosen && r.rejected) {
      rows.push({ prompt: r.prompt, chosen: r.chosen, rejected: r.rejected });
    }
  }
  return rows;
}

export async function genCodeCompletion(inputs: Inputs): Promise<Row[]> {
  const srcRaw = str(inputs.src_dir).trim();
  const maxPairs = num(inputs.max_pairs, 500);
  // Expand a leading ~ to the home dir (parity with Path.expanduser()).
  const src = srcRaw.startsWith("~")
    ? `${process.env.HOME ?? ""}${srcRaw.slice(1)}`
    : srcRaw;

  const { statSync } = await import("node:fs");
  let isDir = false;
  try {
    isDir = statSync(src).isDirectory();
  } catch {
    isDir = false;
  }
  if (!isDir) throw new Error(`src_dir not a directory: ${src}`);

  // Deterministic PRNG (mulberry32) so test splits are stable. We do NOT use
  // Math.random; the Python uses random.Random(42) — we mirror the intent
  // (seeded) rather than the exact sequence.
  let seed = 42 >>> 0;
  const randInt = (lo: number, hi: number): number => {
    // inclusive [lo, hi]
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    const u = ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    return lo + Math.floor(u * (hi - lo + 1));
  };

  const rows: Row[] = [];
  const glob = new Bun.Glob("**/*.py");
  // Sort the file list for determinism across filesystems.
  const files: string[] = [];
  for await (const rel of glob.scan({ cwd: src, onlyFiles: true })) {
    files.push(rel);
  }
  files.sort();

  for (const rel of files) {
    let text: string;
    try {
      text = await Bun.file(`${src}/${rel}`).text();
    } catch {
      continue;
    }
    // Split on def / class / async def boundaries (lookahead at line start).
    const chunks = text.split(/(?=^(?:def |class |async def ))/m);
    for (const raw of chunks) {
      const chunk = raw.trim();
      if (chunk.length < 30) continue;
      const lo = Math.floor(chunk.length / 4);
      const hi = Math.max(lo + 1, Math.floor((chunk.length * 3) / 4));
      const splitAt = randInt(lo, hi);
      rows.push({
        prompt: chunk.slice(0, splitAt),
        completion: chunk.slice(splitAt),
      });
      if (rows.length >= maxPairs) return rows;
    }
  }
  return rows;
}

export async function genFormatConversion(inputs: Inputs): Promise<Row[]> {
  const text = str(inputs.input_jsonl).trim();
  const userKey = str(inputs.user_key) || "input";
  const asstKey = str(inputs.assistant_key) || "output";
  const rows: Row[] = [];
  for (const rawLine of text.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line) continue;
    let obj: any;
    try {
      obj = JSON.parse(line);
    } catch {
      continue;
    }
    const u = obj?.[userKey];
    const a = obj?.[asstKey];
    if (u === undefined || u === null || a === undefined || a === null) continue;
    rows.push({
      messages: [
        { role: "user", content: String(u) },
        { role: "assistant", content: String(a) },
      ],
    });
  }
  return rows;
}

// ===========================================================================
// hf_dataset_import — pull a public HF dataset via the datasets-server REST
// API and shape it. Faithful port of optiq's `_gen_hf_dataset_import`, with
// the `datasets` library swapped for the datasets-server `/rows` endpoint
// (no Python, no `datasets` dep).
// ===========================================================================

/** A single datasets-server row envelope: `{ row_idx, row: {col: value} }`. */
export interface HfServerRow {
  row?: Record<string, unknown>;
  [k: string]: unknown;
}

/** Parsed + normalized options for the row→example transform. */
export interface HfImportOpts {
  textColumn: string;
  labelColumn: string | null;
  labelFilter: string | null;
  minChars: number; // 0 = no minimum
  maxRows: number; // 0 = no cap
  outputFormat: string; // "messages_user_only" | "prompt_completion" | "text"
}

/** Running tallies + accumulated rows, threaded through the transform. */
export interface HfTransformState {
  rows: Row[];
  kept: number;
  rejectedShort: number;
  rejectedFilter: number;
}

/** Fresh, zeroed transform state. */
export function newHfTransformState(): HfTransformState {
  return { rows: [], kept: 0, rejectedShort: 0, rejectedFilter: 0 };
}

/**
 * Python truthiness for a JSON-decoded value, mirroring `(x or "")` semantics.
 * Falsy: None/undefined, "", 0/0.0, False, NaN, empty array, empty object.
 */
function isPythonTruthy(v: unknown): boolean {
  if (v === undefined || v === null || v === false || v === "") return false;
  if (typeof v === "number") return v !== 0 && !Number.isNaN(v);
  if (Array.isArray(v)) return v.length > 0;
  if (typeof v === "object") return Object.keys(v as object).length > 0;
  return true;
}

/**
 * Pure row→example transform — exact port of the body of the optiq loop in
 * `_gen_hf_dataset_import`. Mutates `state` in place and returns it.
 *
 * Apply order (matching Python): (1) max_rows cap → return `false` (caller
 * should stop), (2) coerce text via `str()` + strip, (3) min_chars drop,
 * (4) label filter drop (`str(row[col]) !== filter`), (5) shape by format.
 *
 * @returns `true` if the caller should keep feeding rows, `false` once the
 *   `max_rows` cap is reached (the current row was NOT consumed).
 */
export function applyHfRow(
  envelope: HfServerRow,
  opts: HfImportOpts,
  state: HfTransformState,
): boolean {
  // Python: `if max_rows and kept >= max_rows: break` (checked before the row).
  if (opts.maxRows && state.kept >= opts.maxRows) return false;

  const row = envelope.row ?? {};
  const raw = row[opts.textColumn];
  // Python: `text = (row.get(text_column) or "")` then `str(...)` if not str.
  // `or ""` collapses Python-falsy values (None, "", 0, 0.0, False, [], {}) to "".
  let text: string;
  if (!isPythonTruthy(raw)) {
    text = "";
  } else if (typeof raw === "string") {
    text = raw;
  } else {
    text = String(raw);
  }
  text = text.trim();

  if (opts.minChars && text.length < opts.minChars) {
    state.rejectedShort++;
    return true;
  }
  if (opts.labelColumn && opts.labelFilter) {
    // Python: `str(row.get(label_column, ""))` — missing → "".
    const lv = row[opts.labelColumn];
    const labelStr = lv === undefined || lv === null ? "" : String(lv);
    if (labelStr !== opts.labelFilter) {
      state.rejectedFilter++;
      return true;
    }
  }

  if (opts.outputFormat === "messages_user_only") {
    state.rows.push({ messages: [{ role: "user", content: text }] });
  } else if (opts.outputFormat === "prompt_completion") {
    state.rows.push({ prompt: text, completion: "" });
  } else {
    // default: text
    state.rows.push({ text });
  }
  state.kept++;
  return true;
}

const HF_ROWS_ENDPOINT = "https://datasets-server.huggingface.co/rows";
const HF_SPLITS_ENDPOINT = "https://datasets-server.huggingface.co/splits";
const HF_PAGE = 100; // datasets-server caps `length` at 100 rows/request.

/** Bearer header for gated datasets when HF_TOKEN is set; else anonymous. */
function hfAuthHeaders(): Record<string, string> {
  const tok = process.env.HF_TOKEN;
  return tok ? { Authorization: `Bearer ${tok}` } : {};
}

/** Fetch JSON with a couple of retries on transient 429/5xx (and net errors). */
async function hfFetchJson(url: string): Promise<any> {
  const headers = hfAuthHeaders();
  let lastErr: unknown;
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const res = await fetch(url, { headers });
      if (res.ok) return await res.json();
      // Retry transient statuses; fail fast on 4xx (except 429).
      if (res.status === 429 || res.status >= 500) {
        lastErr = new Error(`HF datasets-server ${res.status} for ${url}`);
      } else {
        const body = await res.text().catch(() => "");
        throw new Error(
          `HF datasets-server ${res.status} for ${url}` + (body ? `: ${body.slice(0, 300)}` : ""),
        );
      }
    } catch (e) {
      lastErr = e;
    }
    // Backoff: 0.5s, 1s before the final attempt.
    if (attempt < 2) await new Promise((r) => setTimeout(r, 500 * (attempt + 1)));
  }
  throw lastErr instanceof Error ? lastErr : new Error(String(lastErr));
}

/** Resolve the default config for a dataset (first config of the split, or any). */
async function resolveDefaultConfig(hfId: string, split: string): Promise<string> {
  const url = `${HF_SPLITS_ENDPOINT}?dataset=${encodeURIComponent(hfId)}`;
  const data = await hfFetchJson(url);
  const splits: Array<{ config?: string; split?: string }> = Array.isArray(data?.splits)
    ? data.splits
    : [];
  // Prefer a config that actually has the requested split; else the first one.
  const match = splits.find((s) => s.split === split) ?? splits[0];
  return (match?.config ?? "default").trim() || "default";
}

export async function genHfDatasetImport(
  inputs: Inputs = {},
  emit: Emit = () => {},
): Promise<Row[]> {
  // ---- parse inputs (mirror optiq's `.strip() or default` coercions) ----
  const hfId = str(inputs.hf_id).trim();
  if (!hfId) return [];
  let config = str(inputs.config).trim() || null;
  const split = str(inputs.split).trim() || "train";
  const opts: HfImportOpts = {
    textColumn: str(inputs.text_column).trim() || "text",
    labelColumn: str(inputs.label_column).trim() || null,
    labelFilter: str(inputs.label_filter).trim() || null,
    maxRows: num(inputs.max_rows, 0),
    minChars: num(inputs.min_chars, 0),
    outputFormat: str(inputs.output_format).trim() || "text",
  };

  emit({
    type: "stage",
    stage: "loading",
    message: `Loading ${hfId} (${split})…`,
    progress: 0.05,
  });

  // Resolve the default config if the user didn't give one.
  if (!config) {
    config = await resolveDefaultConfig(hfId, split);
  }

  emit({
    type: "stage",
    stage: "filtering",
    message: `Loading rows from ${hfId} (${config}/${split})…`,
    progress: 0.2,
  });

  // ---- paginate /rows by offset, applying the transform per page ----
  const state = newHfTransformState();
  let offset = 0;
  let columnsChecked = false;
  outer: while (true) {
    const url =
      `${HF_ROWS_ENDPOINT}?dataset=${encodeURIComponent(hfId)}` +
      `&config=${encodeURIComponent(config)}` +
      `&split=${encodeURIComponent(split)}` +
      `&offset=${offset}&length=${HF_PAGE}`;
    const data = await hfFetchJson(url);
    const page: HfServerRow[] = Array.isArray(data?.rows) ? data.rows : [];
    if (page.length === 0) break;

    // Validate columns once (parity with optiq's column_names guard).
    if (!columnsChecked) {
      columnsChecked = true;
      const cols = new Set<string>(Object.keys(page[0]!.row ?? {}));
      if (!cols.has(opts.textColumn)) {
        throw new Error(
          `text_column=${JSON.stringify(opts.textColumn)} not in dataset. ` +
            `Available columns: ${JSON.stringify([...cols])}`,
        );
      }
      if (opts.labelColumn && !cols.has(opts.labelColumn)) {
        throw new Error(
          `label_column=${JSON.stringify(opts.labelColumn)} not in dataset. ` +
            `Available columns: ${JSON.stringify([...cols])}`,
        );
      }
    }

    for (const env of page) {
      const cont = applyHfRow(env, opts, state);
      if (!cont) break outer; // hit max_rows
      // Progress every 500 kept rows (mirror optiq's emit cadence).
      if (state.kept && state.kept % 500 === 0) {
        emit({
          type: "stage",
          stage: "filtering",
          message: `kept ${state.kept} rows…`,
          progress:
            0.2 + 0.7 * Math.min(1.0, state.kept / Math.max(1, opts.maxRows || state.kept)),
        });
      }
    }

    offset += page.length;
  }

  emit({
    type: "stage",
    stage: "writing",
    message: `kept ${state.kept}; dropped ${state.rejectedShort} short, ${state.rejectedFilter} filtered out`,
    progress: 0.95,
  });
  return state.rows;
}

// ===========================================================================
// LLM-driven generators (call the loopback server)
// ===========================================================================

export async function genStyleTransfer(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "style_transfer");
  const refs = str(inputs.reference_samples).trim();
  const raw = str(inputs.raw_text).trim();
  if (!(refs && raw)) return [];
  const paragraphs = raw
    .split("\n\n")
    .map((p) => p.trim())
    .filter((p) => p.length > 0);
  const rows: Row[] = [];
  for (let i = 0; i < paragraphs.length; i++) {
    const p = paragraphs[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.1 + 0.85 * (i / Math.max(paragraphs.length, 1)),
      message: `rewriting paragraph ${i + 1}/${paragraphs.length}`,
    });
    const prompt =
      "Rewrite the text below in the same style and tone as these reference samples.\n\n" +
      `REFERENCES:\n${refs}\n\nTEXT TO REWRITE:\n${p}\n\nREWRITTEN:`;
    const out = await client.chat([{ role: "user", content: prompt }], { maxTokens: 512 });
    rows.push({ prompt: p, completion: out });
  }
  return rows;
}

/**
 * Best-effort extract a list of K instructions from LLM output. Tries (in
 * order): strict JSON on the shortest balanced [...] span, comma-split of the
 * first [...] span, then numbered/bulleted lines. Port of
 * `_parse_instruction_list`.
 */
export function parseInstructionList(text: string, k: number): string[] {
  if (!text) return [];
  const s = text.trim();

  // Collect every balanced [ ... ] span.
  const spans: Array<[number, number]> = [];
  let depth = 0;
  let start = -1;
  for (let i = 0; i < s.length; i++) {
    const ch = s[i];
    if (ch === "[") {
      if (depth === 0) start = i;
      depth++;
    } else if (ch === "]") {
      depth--;
      if (depth === 0 && start >= 0) {
        spans.push([start, i + 1]);
        start = -1;
      }
    }
  }

  // Strict JSON on each balanced span (first that yields a non-empty list).
  for (const [si, ei] of spans) {
    try {
      const v = JSON.parse(s.slice(si, ei));
      if (Array.isArray(v)) {
        const items = v.map((x) => String(x).trim()).filter((x) => x.length > 0);
        if (items.length) return items.slice(0, k);
      }
    } catch {
      // fall through
    }
  }

  // First [ ... ] span, comma-split (handles unquoted strings).
  if (spans.length) {
    const [si, ei] = spans[0]!;
    const inner = s.slice(si + 1, ei - 1);
    const parts = inner
      .split(",")
      .map((p) => p.trim().replace(/^["']|["']$/g, ""))
      .filter((p) => p.length > 0);
    if (parts.length) return parts.slice(0, k);
  }

  // Numbered / bulleted lines.
  const out: string[] = [];
  for (const rawLine of s.split(/\r?\n/)) {
    let line = rawLine.trim();
    if (!line) continue;
    line = line.replace(/^(?:\d+[.)]|[-*])\s+/, "");
    if (line) out.push(line.replace(/^["']|["']$/g, ""));
  }
  return out.slice(0, k);
}

export async function genSelfInstruct(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "self_instruct");
  const seeds = nonEmptyLines(inputs.seeds);
  const k = num(inputs.variants_per_seed, 5);
  if (!seeds.length) return [];
  const rows: Row[] = [];
  for (let i = 0; i < seeds.length; i++) {
    const seed = seeds[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.1 + 0.85 * (i / Math.max(seeds.length, 1)),
      message: `seed ${i + 1}/${seeds.length}`,
    });
    const prompt =
      `Generate ${k} new instructions in the same spirit as the example. ` +
      "Return them as a JSON array of strings, no commentary. Example " +
      'output format: ["instruction one", "instruction two"]\n\n' +
      `Example: ${seed}\n\nArray:`;
    const out = await client.chat([{ role: "user", content: prompt }], { maxTokens: 512 });
    const variants = parseInstructionList(out, k);
    for (const v of variants.slice(0, k)) {
      rows.push({
        messages: [
          { role: "user", content: String(v) },
          { role: "assistant", content: "" }, // filled by a later pass
        ],
      });
    }
  }
  return rows;
}

export async function genPromptReconstruction(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "prompt_reconstruction");
  const raw = (str(inputs.target_text) || str(inputs.human_text)).trim();
  const style = str(inputs.style).trim() || "direct technical blog";
  const tone = str(inputs.tone).trim() || "analytical, clear";
  const preserve = str(inputs.preserve).trim() || "facts, names, numbers, URLs, citations";
  const avoid = str(inputs.avoid).trim() || "em dashes, generic transitions";
  if (!raw) return [];

  const paragraphs = raw
    .split(/\n\s*\n/)
    .map((p) => p.trim())
    .filter((p) => p.length > 0);

  // Cheap preservation extractors (mirror humanizer/extractors.py).
  const urlRe = /https?:\/\/[^\s)\]>]+/g;
  const pctRe = /\b\d+(?:\.\d+)?\s?%/g;
  const curRe = /(?:\$|€|£|¥|USD\s*|EUR\s*|GBP\s*)\s?[\d,]+(?:\.\d+)?(?:[KMBkmb])?/g;
  const dateRe = /\b(?:\d{4}-\d{2}-\d{2}|(?:19|20)\d{2}|(?:Q[1-4]|FY)\s?\d{2,4})\b/g;
  const codeRe = /`([^`\n]{1,80})`/g;
  const citeRe = /\[\d{1,4}\]|\[[A-Z][A-Za-z\-]+(?:\s+et\s+al\.?)?,?\s*\d{4}[a-z]?\]/g;

  const findAll = (re: RegExp, t: string): string[] => {
    const r = new RegExp(re.source, re.flags);
    return [...t.matchAll(r)].map((m) => m[0]);
  };
  const locksOf = (t: string) => ({
    urls: findAll(urlRe, t),
    percentages: findAll(pctRe, t),
    currencies: findAll(curRe, t),
    dates: findAll(dateRe, t),
    code: findAll(codeRe, t),
    citations: findAll(citeRe, t),
  });

  const rows: Row[] = [];
  for (let i = 0; i < paragraphs.length; i++) {
    const para = paragraphs[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / Math.max(paragraphs.length, 1)),
      message: `reconstruct ${i + 1}/${paragraphs.length}`,
    });

    // 1. infer prompt
    const inferPrompt =
      "Given the human-written text below, infer a realistic user prompt " +
      "that could have led an AI assistant to produce this kind of text. " +
      "Capture topic, intent, audience, and depth. Do NOT quote the text.\n\n" +
      `HUMAN TEXT:\n${para}\n\nPROMPT:`;
    let inferred = (
      await client.chat([{ role: "user", content: inferPrompt }], { maxTokens: 160 })
    ).trim();
    if (!inferred) inferred = "Write a piece on the topic implied by the chunk.";

    // 2. generate AI-ish draft
    const draftPrompt =
      "Answer the following user request in a polished but generic AI-assistant style. " +
      "Be coherent, use common AI transitions, slightly over-explain, keep similar length. " +
      "Do not introduce errors.\n\n" +
      `USER REQUEST:\n${inferred}\n\nSTYLE HINT:\n${style} / ${tone}\n\nANSWER:`;
    const draft = (
      await client.chat([{ role: "user", content: draftPrompt }], { maxTokens: 800 })
    ).trim();
    if (!draft) continue;

    const lk = locksOf(para);
    const sysPrompt =
      "You are a controlled rewrite model. Rewrite AI-generated drafts into " +
      "natural human-style prose while preserving meaning, facts, names, " +
      "numbers, citations, URLs, quotes, and formatting. Do not add unsupported " +
      "claims.";
    const userMsg =
      `STYLE:\n${style}\n\nTONE:\n${tone}\n\n` +
      `PRESERVE:\n${preserve}\n\nAVOID:\n${avoid}\n\n` +
      `USER PROMPT:\n${inferred}\n\nSOURCE AI DRAFT:\n${draft}\n\n` +
      "TASK:\nRewrite only the SOURCE AI DRAFT into natural human prose. " +
      "Do not introduce new facts.";
    rows.push({
      messages: [
        { role: "system", content: sysPrompt },
        { role: "user", content: userMsg },
        { role: "assistant", content: para },
      ],
      metadata: {
        inferred_prompt: inferred,
        source_ai_draft: draft,
        preservation_locks: lk,
        style,
        tone,
      },
    });
  }
  return rows;
}

/** Render a chat history as plain text for a one-shot followup prompt. */
function formatConvoForFollowup(convo: ChatMessage[]): string {
  const lines: string[] = [];
  for (const m of convo) {
    const role = m.role ?? "";
    const content = str(m.content).trim();
    if (!content || role === "system") continue;
    lines.push(`${role.toUpperCase()}:\n${content}\n`);
  }
  return lines.join("\n");
}

export async function genMultiTurnChat(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "multi_turn_chat");
  const seeds = nonEmptyLines(inputs.seeds);
  const turns = Math.max(2, num(inputs.turns, 4));
  const persona = str(inputs.persona).trim() || "You are a helpful, concise assistant.";
  const userPersona =
    str(inputs.user_persona).trim() || "a curious developer probing for specifics";
  if (!seeds.length) return [];

  const rows: Row[] = [];
  for (let i = 0; i < seeds.length; i++) {
    const seed = seeds[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / Math.max(seeds.length, 1)),
      message: `seed ${i + 1}/${seeds.length} (${turns} turns)`,
    });
    const convo: ChatMessage[] = [
      { role: "system", content: persona },
      { role: "user", content: seed },
    ];

    for (let t = 0; t < turns; t++) {
      const isUserTurn = t % 2 === 1;
      if (isUserTurn) {
        const followupPrompt =
          "Continue the conversation below by writing ONLY the next " +
          "user-turn message in character as " +
          userPersona +
          ". " +
          "Keep it short (one or two sentences), grounded in what " +
          "the assistant just said. Do not write the assistant's " +
          "next reply.\n\n" +
          formatConvoForFollowup(convo);
        const followup = (
          await client.chat([{ role: "user", content: followupPrompt }], { maxTokens: 160 })
        ).trim();
        if (!followup) break;
        convo.push({ role: "user", content: followup });
      } else {
        const reply = (await client.chat(convo, { maxTokens: 512 })).trim();
        if (!reply) break;
        convo.push({ role: "assistant", content: reply });
      }
    }
    rows.push({ messages: convo });
  }
  return rows;
}

export async function genToolUseTraces(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "tool_use_traces");
  let tools: unknown[];
  try {
    const parsed = JSON.parse(str(inputs.tools_json) || "[]");
    tools = Array.isArray(parsed) ? parsed : [];
  } catch {
    tools = [];
  }
  if (!tools.length) return [];
  const scenarios = nonEmptyLines(inputs.scenarios);
  const mocks = nonEmptyLines(inputs.mock_results);
  if (!scenarios.length || mocks.length !== scenarios.length) return [];

  const rows: Row[] = [];
  for (let i = 0; i < scenarios.length; i++) {
    const scenario = scenarios[i]!;
    const mock = mocks[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / scenarios.length),
      message: `scenario ${i + 1}/${scenarios.length}`,
    });

    // Turn 1: model picks a tool (structured tool_calls reply).
    const first = await client.chatRaw([{ role: "user", content: scenario }], {
      tools,
      maxTokens: 512,
    });
    const firstMsg = first?.choices?.[0]?.message ?? {};
    const toolCalls = firstMsg.tool_calls ?? [];
    if (!Array.isArray(toolCalls) || !toolCalls.length) continue; // no tool → skip

    const tc = toolCalls[0];
    const tcId = tc?.id || `call_${i}`;
    const toolName = tc?.function?.name ?? "";

    // Turn 2: feed back the mocked result, ask for the final answer.
    const messagesForFinal: ChatMessage[] = [
      { role: "user", content: scenario },
      { role: "assistant", content: firstMsg.content || "", tool_calls: toolCalls },
      { role: "tool", tool_call_id: tcId, name: toolName, content: mock },
    ];
    const final = (await client.chat(messagesForFinal, { maxTokens: 512 })).trim();
    if (!final) continue;

    rows.push({
      messages: [
        { role: "user", content: scenario },
        { role: "assistant", content: firstMsg.content || "", tool_calls: toolCalls },
        { role: "tool", tool_call_id: tcId, name: toolName, content: mock },
        { role: "assistant", content: final },
      ],
      tools,
    });
  }
  return rows;
}

export async function genRagQa(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "rag_qa");
  const docs = str(inputs.documents).trim();
  const qpc = Math.max(1, num(inputs.questions_per_chunk, 2));
  const minChars = Math.max(40, num(inputs.min_chunk_chars, 200));
  if (!docs) return [];

  // Split on blank lines, glue tiny fragments together until >= minChars.
  const rawChunks = docs
    .split(/\n\s*\n/)
    .map((c) => c.trim())
    .filter((c) => c.length > 0);
  const chunks: string[] = [];
  let buf = "";
  for (const c of rawChunks) {
    buf = buf ? `${buf}\n\n${c}`.trim() : c;
    if (buf.length >= minChars) {
      chunks.push(buf);
      buf = "";
    }
  }
  if (buf) {
    if (chunks.length) chunks[chunks.length - 1] = `${chunks[chunks.length - 1]}\n\n${buf}`.trim();
    else chunks.push(buf);
  }

  const rows: Row[] = [];
  for (let i = 0; i < chunks.length; i++) {
    const chunk = chunks[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / Math.max(chunks.length, 1)),
      message: `chunk ${i + 1}/${chunks.length} (${qpc} questions)`,
    });
    for (let j = 0; j < qpc; j++) {
      const qPrompt =
        "Write ONE concise, specific question whose answer is " +
        "stated directly in the passage below. Do not answer; only " +
        "write the question. Vary it from any other question you " +
        "would write for the same passage.\n\n" +
        `PASSAGE:\n${chunk}\n\nQUESTION (question number ${j + 1}):`;
      const q = (await client.chat([{ role: "user", content: qPrompt }], { maxTokens: 120 })).trim();
      if (!q) continue;
      const aPrompt =
        "Answer the question using ONLY information from the passage. " +
        "If the answer is not in the passage, reply exactly: " +
        '"The passage does not say." Be concise.\n\n' +
        `PASSAGE:\n${chunk}\n\nQUESTION:\n${q}\n\nANSWER:`;
      const a = (await client.chat([{ role: "user", content: aPrompt }], { maxTokens: 400 })).trim();
      if (!a) continue;
      rows.push({
        messages: [
          { role: "system", content: `Use only the following passage to answer.\n\n${chunk}` },
          { role: "user", content: q },
          { role: "assistant", content: a },
        ],
        metadata: { chunk_index: i, passage_chars: chunk.length },
      });
    }
  }
  return rows;
}

export async function genCotSynthesis(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "cot_synthesis");
  const qs = nonEmptyLines(inputs.questions);
  const category = str(inputs.category).trim() || "general reasoning";
  if (!qs.length) return [];

  const rows: Row[] = [];
  for (let i = 0; i < qs.length; i++) {
    const q = qs[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / qs.length),
      message: `question ${i + 1}/${qs.length}`,
    });
    const prompt =
      `You are solving a ${category} problem. Think step by step in ` +
      "a <think>...</think> block first, then write the final answer " +
      "after the closing </think> tag. Keep the final answer concise.\n\n" +
      `QUESTION:\n${q}\n\nRESPONSE:`;
    let out = (await client.chat([{ role: "user", content: prompt }], { maxTokens: 1024 })).trim();
    if (!out) continue;
    // Normalize: ensure the output has <think>...</think>.
    if (!out.includes("<think>")) {
      const paras = out.split("\n\n").filter((p) => p.trim());
      if (paras.length >= 2) {
        const trace = paras.slice(0, -1).join("\n\n");
        const ans = paras[paras.length - 1];
        out = `<think>\n${trace}\n</think>\n\n${ans}`;
      } else {
        out = `<think>\n${out}\n</think>\n\n${out}`;
      }
    }
    rows.push({
      messages: [
        { role: "user", content: q },
        { role: "assistant", content: out },
      ],
      metadata: { category },
    });
  }
  return rows;
}

/** Pull a ```python ... ``` block out of LLM output, or return whole text. */
export function extractPythonBlock(text: string): string {
  const m = text.match(/```(?:python|py)?\n([\s\S]*?)\n```/);
  return m ? m[1]!.trim() : text.trim();
}

export async function genVerifiedCode(
  inputs: Inputs,
  emit: Emit,
  llm?: LlmClient,
): Promise<Row[]> {
  const client = requireLlm(llm, "verified_code");
  const specs = nonEmptyLines(inputs.specs);
  const language = (str(inputs.language).trim() || "python").toLowerCase();
  if (!specs.length) return [];

  // Probe for python3 once; if absent, keep rows with verified=false (mirrors
  // optiq keeping unverified rows).
  let havePython = false;
  if (language === "python") {
    try {
      const probe = Bun.spawnSync(["python3", "--version"]);
      havePython = probe.exitCode === 0;
    } catch {
      havePython = false;
    }
  }

  const rows: Row[] = [];
  let nVerified = 0;
  let nTotal = 0;
  for (let i = 0; i < specs.length; i++) {
    const spec = specs[i]!;
    emit({
      type: "stage",
      stage: "generating",
      progress: 0.05 + 0.9 * (i / specs.length),
      message: `spec ${i + 1}/${specs.length} (${nVerified}/${nTotal} verified so far)`,
    });
    nTotal++;
    const prompt =
      "Write a Python function that satisfies the spec. Then write " +
      "three `assert` statements at module level that verify the " +
      "function. Output ONLY the code as a single fenced ```python " +
      "block, no commentary.\n\n" +
      `SPEC:\n${spec}\n\nCODE:`;
    const out = await client.chatRaw([{ role: "user", content: prompt }], {
      maxTokens: 1200,
      temperature: 0.2,
    });
    const outText = out?.choices?.[0]?.message?.content ?? "";
    const code = extractPythonBlock(outText);
    if (!code || code.length < 10) continue;

    let verified = false;
    let verifyError: string | null = null;
    if (language === "python" && havePython) {
      try {
        const proc = Bun.spawnSync(["python3", "-c", code], {
          stdout: "pipe",
          stderr: "pipe",
        });
        verified = proc.exitCode === 0;
        if (!verified) {
          const stderr = proc.stderr ? new TextDecoder().decode(proc.stderr) : "";
          const stdout = proc.stdout ? new TextDecoder().decode(proc.stdout) : "";
          verifyError = (stderr || stdout || "").slice(0, 400);
        }
      } catch (e) {
        verified = false;
        verifyError = String(e).slice(0, 400);
      }
    }
    if (verified) nVerified++;

    rows.push({
      messages: [
        { role: "user", content: spec },
        { role: "assistant", content: `\`\`\`python\n${code}\n\`\`\`` },
      ],
      metadata: { verified, language, verify_error: verifyError },
    });
  }
  emit({
    type: "stage",
    stage: "generating",
    progress: 0.96,
    message: `${nVerified}/${nTotal} specs verified (unverified rows kept with verified=false)`,
  });
  return rows;
}
