// Training dataset loading + batching. Ports the SFT shape from
// mlx_lm/tuner/datasets.py (chat / completions / text) and the DPO shape
// from optiq/lora/dpo.py (_tokenize_pair, _make_batch).
//
// v1 is batch_size=1 (no padding needed): the batch carries a single
// example's ids as an Int32Array plus a prompt boundary. The batch shape
// is designed so a future B>1 pad path slots in without changing callers.

import type { LoadedTokenizer } from "../tokenizer";
import type { ChatTemplate, ChatMessage } from "../chat-template";

// ---------------------------------------------------------------------------
// SFT
// ---------------------------------------------------------------------------

/** One tokenized SFT example. `promptLen` marks where the response begins;
 *  loss is masked to positions in [promptLen, ids.length). */
export interface SftExample {
  ids: number[];
  promptLen: number;
}

/** A single SFT training batch. `ids` is `[B][L]` row-major, every row padded
 *  to the common batch length `L`. `promptLens[i]` is row i's prompt boundary
 *  (loss starts at that position) and `lengths[i]` is row i's true unpadded
 *  length — positions `>= lengths[i]` are padding and are excluded from both
 *  the loss mask and the attention mask. For B=1 every row's `lengths[i]`
 *  equals its `ids[i].length` (no padding), so the loss/forward paths are
 *  bit-identical to the pre-batch single-example trainer. */
export interface SftBatch {
  ids: number[][];
  promptLens: number[];
  /** Per-row true (unpadded) length; defaults to `ids[i].length` when absent
   *  (the B=1 no-padding case, kept for back-compat with single-row callers). */
  lengths?: number[];
}

/** Row i's valid length: explicit `lengths[i]` if present, else the row's full
 *  (unpadded) id count. Centralizes the back-compat default so loss/forward
 *  treat a length-less B=1 batch exactly as before. */
export function rowLength(batch: SftBatch, i: number): number {
  return batch.lengths?.[i] ?? batch.ids[i]!.length;
}

export type SftRowFormat = "messages" | "prompt-completion" | "text";

/** Detect a row's format from its keys. */
export function sftRowFormat(row: Record<string, unknown>): SftRowFormat {
  if (Array.isArray(row.messages)) return "messages";
  if (typeof row.prompt === "string" && typeof row.completion === "string")
    return "prompt-completion";
  if (typeof row.text === "string") return "text";
  throw new Error(
    `unrecognized SFT row: expected {messages}, {prompt,completion}, or {text}; got keys [${Object.keys(row).join(", ")}]`,
  );
}

/** Render+tokenize one SFT row to ids + a prompt boundary.
 *
 *  - messages: render full conversation (addGenerationPrompt:false); the
 *    prompt boundary is the render of all-but-last-turn with
 *    addGenerationPrompt:true (so the assistant's response is the unmasked
 *    region). Prefix-match fallback if the boundary render isn't a prefix.
 *  - prompt-completion: encode(prompt) is the boundary; full = prompt+completion.
 *  - text: bare text, promptLen=0 (no boundary — full-sequence loss). */
export function encodeSftRow(
  row: Record<string, unknown>,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
): SftExample {
  const fmt = sftRowFormat(row);

  if (fmt === "text") {
    const ids = tok.encode(row.text as string);
    return { ids, promptLen: 0 };
  }

  if (fmt === "prompt-completion") {
    const promptIds = tok.encode(row.prompt as string);
    const fullIds = tok.encode((row.prompt as string) + (row.completion as string));
    const promptLen = prefixBoundary(fullIds, promptIds);
    return { ids: fullIds, promptLen };
  }

  // messages
  const messages = row.messages as ChatMessage[];
  const fullText = tmpl.render(messages, { addGenerationPrompt: false });
  const fullIds = tok.encode(fullText);

  // Boundary: render conversation up to (but excluding) the last assistant
  // turn, with addGenerationPrompt:true so the rendered text ends exactly
  // where the assistant response would begin.
  const lastAssistantIdx = lastIndex(messages, (m) => m.role === "assistant");
  if (lastAssistantIdx <= 0) {
    // No assistant turn (or it's the first message) — nothing to mask.
    return { ids: fullIds, promptLen: 0 };
  }
  const promptMessages = messages.slice(0, lastAssistantIdx);
  const promptText = tmpl.render(promptMessages, { addGenerationPrompt: true });
  const promptIds = tok.encode(promptText);
  const promptLen = prefixBoundary(fullIds, promptIds);
  return { ids: fullIds, promptLen };
}

/** Locate the prompt/response boundary. If `promptIds` is a token prefix of
 *  `fullIds`, the boundary is its length; otherwise fall back to the longest
 *  common prefix (handles tokenizers that merge across the seam). Always
 *  clamped to < fullIds.length so at least one response token is supervised. */
function prefixBoundary(fullIds: number[], promptIds: number[]): number {
  let i = 0;
  const max = Math.min(promptIds.length, fullIds.length);
  while (i < max && fullIds[i] === promptIds[i]) i++;
  return Math.min(i, Math.max(0, fullIds.length - 1));
}

function lastIndex<T>(arr: T[], pred: (x: T) => boolean): number {
  for (let i = arr.length - 1; i >= 0; i--) if (pred(arr[i]!)) return i;
  return -1;
}

/** Load + tokenize an SFT split (train.jsonl / valid.jsonl). */
export async function loadSftDataset(
  path: string,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
): Promise<SftExample[]> {
  const rows = await readJsonl(path);
  return rows.map((r) => encodeSftRow(r, tok, tmpl));
}

/** mlx-lm iterate_batches pad granularity. Each batch is padded to
 *  `1 + PAD_TO * ceil(maxLenInBatch / PAD_TO)` (then capped at maxSeqLen). */
export const PAD_TO = 32;

/** Iterate SFT batches. Examples are length-sorted (mlx-lm iterate_batches),
 *  grouped into contiguous runs of `batchSize`, and the *batch order* is
 *  shuffled with `seed` each epoch. Examples longer than `maxSeqLen` are
 *  right-truncated (preserving the prompt-boundary clamp). `loop=false`
 *  yields one epoch then stops.
 *
 *  B=1: yields one example per step with NO padding and no pad-to rounding —
 *  bit-identical to the original single-example trainer.
 *
 *  B>1: faithful to mlx-lm. Sort ascending by length, take contiguous
 *  windows `idx[i : i+B]` for `i in 0, B, 2B, …` (the trailing remainder
 *  that does not fill a batch is dropped, matching mlx-lm's range bound),
 *  permute batch order, and pad every row to
 *  `min(1 + PAD_TO·ceil(max_len/PAD_TO), maxSeqLen)` with `padId`. Each row
 *  carries its true (truncated) length so the loss + attention masks ignore
 *  padding. `padId` defaults to 0 (mlx-lm SFT uses np.zeros); pass the eos id
 *  to pad with a real sentinel — the padded positions are masked out either
 *  way, so the choice does not change the loss. */
export function* iterateSftBatches(
  examples: SftExample[],
  batchSize: number,
  maxSeqLen: number,
  seed: number,
  loop: boolean,
  padId = 0,
): Generator<SftBatch> {
  if (batchSize < 1) throw new Error("iterateSftBatches: batchSize must be >= 1");
  if (examples.length === 0) throw new Error("iterateSftBatches: empty dataset");
  if (examples.length < batchSize)
    throw new Error(
      `iterateSftBatches: dataset has ${examples.length} examples but batchSize=${batchSize}`,
    );

  const order = [...examples.keys()].sort(
    (a, b) => examples[a]!.ids.length - examples[b]!.ids.length,
  );
  const rng = mulberry32(seed >>> 0);

  if (batchSize === 1) {
    // Original single-example path: shuffle EXAMPLE order (not batch order),
    // no padding, no pad-to rounding. Kept verbatim for bit-identical B=1.
    do {
      const shuffled = [...order];
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(rng() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j]!, shuffled[i]!];
      }
      for (const idx of shuffled) {
        const ex = examples[idx]!;
        let ids = ex.ids;
        let promptLen = ex.promptLen;
        if (ids.length > maxSeqLen) {
          ids = ids.slice(0, maxSeqLen);
          promptLen = Math.min(promptLen, Math.max(0, ids.length - 1));
        }
        yield { ids: [ids], promptLens: [promptLen], lengths: [ids.length] };
      }
    } while (loop);
    return;
  }

  // B>1: contiguous length-sorted windows; drop the trailing remainder.
  const batches: number[][] = [];
  for (let i = 0; i + batchSize <= order.length; i += batchSize)
    batches.push(order.slice(i, i + batchSize));

  do {
    const perm = [...batches.keys()];
    for (let i = perm.length - 1; i > 0; i--) {
      const j = Math.floor(rng() * (i + 1));
      [perm[i], perm[j]] = [perm[j]!, perm[i]!];
    }
    for (const bi of perm) yield padSftBatch(batches[bi]!.map((k) => examples[k]!), maxSeqLen, padId);
  } while (loop);
}

/** Pad a window of examples to a common length (mlx-lm pad-to rule) and
 *  collect prompt boundaries + true lengths. */
function padSftBatch(rows: SftExample[], maxSeqLen: number, padId: number): SftBatch {
  const lens = rows.map((r) => Math.min(r.ids.length, maxSeqLen));
  const maxLen = Math.max(...lens);
  const L = Math.min(1 + PAD_TO * Math.ceil(maxLen / PAD_TO), maxSeqLen);
  const ids: number[][] = [];
  const promptLens: number[] = [];
  const lengths: number[] = [];
  for (const r of rows) {
    const trueLen = Math.min(r.ids.length, L);
    let promptLen = r.promptLen;
    if (r.ids.length > L) promptLen = Math.min(promptLen, Math.max(0, L - 1));
    const row = new Array<number>(L).fill(padId);
    for (let t = 0; t < trueLen; t++) row[t] = r.ids[t]!;
    ids.push(row);
    promptLens.push(promptLen);
    lengths.push(trueLen);
  }
  return { ids, promptLens, lengths };
}

// ---------------------------------------------------------------------------
// DPO
// ---------------------------------------------------------------------------

/** One DPO preference triple → tokenized chosen/rejected with response masks. */
export interface DpoExample {
  chosenIds: number[];
  rejectedIds: number[];
  /** 1 at response positions, 0 over the prompt; length matches the ids. */
  chosenMask: number[];
  rejectedMask: number[];
}

/** A single DPO batch. Each branch is padded to the longest sequence of its
 *  kind within the batch (port of dpo.py _make_batch). The response masks are
 *  0 at both prompt AND pad positions, so per-sequence log-probs naturally
 *  ignore padding without a separate length array. For B=1 there is no padding
 *  and the masks/forward are bit-identical to the single-example trainer. */
export interface DpoBatch {
  chosenIds: number[][];
  rejectedIds: number[][];
  chosenMask: number[][];
  rejectedMask: number[][];
  /** Per-row true (unpadded) length of the chosen branch — drives the chosen
   *  attention mask. Absent ⇒ no padding (B=1), so `chosenIds[i].length`. */
  chosenLengths?: number[];
  /** Per-row true (unpadded) length of the rejected branch. */
  rejectedLengths?: number[];
}

/** Tokenize prompt+response, returning (ids, promptLen) — port of
 *  dpo.py _tokenize_pair, including the left-truncation that preserves the
 *  response when prompt+response exceeds maxLength. */
export function tokenizePair(
  prompt: string,
  response: string,
  tok: LoadedTokenizer,
  maxLength: number,
): { ids: number[]; promptLen: number } {
  // A chat template emits a literal BOS, and the tokenizer's post-processor
  // prepends one too → a duplicate leading BOS. Inference strips it
  // (server.ts: "template includes <bos>; tokenizer also prepends one"), so
  // training must match or it learns on a token stream the model never sees.
  // No-op for raw (untemplated) prompts, which carry a single BOS.
  const bos = tok.bosTokenId;
  const dedupeBos = (ids: number[]): number[] =>
    bos != null && ids.length >= 2 && ids[0] === bos && ids[1] === bos ? ids.slice(1) : ids;
  const promptIds = dedupeBos(tok.encode(prompt));
  let fullIds = dedupeBos(tok.encode(prompt + response));
  let promptLen: number;
  if (isPrefix(fullIds, promptIds)) {
    promptLen = promptIds.length;
  } else {
    promptLen = promptIds.length;
    const responseIds = tok.encode(response, false); // no extra BOS mid-stream
    fullIds = [...promptIds, ...responseIds];
  }
  if (fullIds.length > maxLength) {
    const excess = fullIds.length - maxLength;
    if (excess >= promptLen) {
      fullIds = fullIds.slice(fullIds.length - maxLength);
      promptLen = 0;
    } else {
      fullIds = fullIds.slice(excess);
      promptLen -= excess;
    }
  }
  return { ids: fullIds, promptLen };
}

/** Encode one DPO triple. `prompt` may be a string or chat messages. */
export function encodeDpoRow(
  row: Record<string, unknown>,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  maxLength: number,
): DpoExample {
  if (typeof row.chosen !== "string" || typeof row.rejected !== "string")
    throw new Error("DPO row must have string `chosen` and `rejected`");
  const promptStr = renderDpoPrompt(row.prompt, tmpl);
  const c = tokenizePair(promptStr, row.chosen, tok, maxLength);
  const r = tokenizePair(promptStr, row.rejected, tok, maxLength);
  return {
    chosenIds: c.ids,
    rejectedIds: r.ids,
    chosenMask: respMask(c.ids.length, c.promptLen),
    rejectedMask: respMask(r.ids.length, r.promptLen),
  };
}

function renderDpoPrompt(prompt: unknown, tmpl: ChatTemplate): string {
  if (typeof prompt === "string") return prompt;
  if (Array.isArray(prompt))
    return tmpl.render(prompt as ChatMessage[], { addGenerationPrompt: true, enableThinking: false });
  throw new Error("DPO row `prompt` must be a string or a list of chat messages");
}

function respMask(len: number, promptLen: number): number[] {
  const m = new Array<number>(len).fill(0);
  for (let i = promptLen; i < len; i++) m[i] = 1;
  return m;
}

/** Load + tokenize a DPO split. */
export async function loadDpoDataset(
  path: string,
  tok: LoadedTokenizer,
  tmpl: ChatTemplate,
  maxLength: number,
): Promise<DpoExample[]> {
  const rows = await readJsonl(path);
  const examples = rows.map((r) => encodeDpoRow(r, tok, tmpl, maxLength));
  // Prompt-masking guard (the classic ORPO/DPO footgun on long-prompt /
  // short-completion data): a collapsed prompt boundary (promptLen=0 → mask[0]
  // is 1) means the completion filled the entire window — the NLL/odds-ratio
  // would then be computed over non-completion tokens and the real signal gets
  // drowned. Normally the loss is completion-only (mask 0 over the prompt); this
  // only happens when a completion is itself ≥ max_seq_length. Surface it loudly.
  let unmasked = 0;
  for (const ex of examples) if (ex.chosenMask[0] === 1 || ex.rejectedMask[0] === 1) unmasked++;
  if (unmasked > 0)
    console.warn(
      `[dataset] WARNING: ${unmasked}/${examples.length} preference examples have NO prompt boundary ` +
      `(promptLen=0): the completion is ≥ max_seq_length (${maxLength}), so the loss would include ` +
      `non-completion tokens. Raise max_seq_length above the completion length so the prompt is masked.`,
    );
  return examples;
}

/** Row length of a DPO branch (port of _make_batch helpers). */
export function dpoChosenLength(batch: DpoBatch, i: number): number {
  return batch.chosenLengths?.[i] ?? batch.chosenIds[i]!.length;
}
export function dpoRejectedLength(batch: DpoBatch, i: number): number {
  return batch.rejectedLengths?.[i] ?? batch.rejectedIds[i]!.length;
}

/** Iterate DPO batches. Sequential examples grouped into runs of `batchSize`,
 *  example order reshuffled with `seed` each epoch (port of dpo.py _batch_at +
 *  _make_batch). The trailing remainder that does not fill a batch is dropped.
 *
 *  B=1: one example per step, no padding — bit-identical to the original.
 *
 *  B>1: each branch is padded to the longest of its kind in the batch with
 *  `padId` (chosen/rejected padded independently, exactly like _make_batch).
 *  Response masks are 0 at pad positions; per-row branch lengths are recorded
 *  so the batched attention masks exclude padded keys. `padId` defaults to 0
 *  (pad/eos resolved by the caller); padded scores are masked out regardless. */
export function* iterateDpoBatches(
  examples: DpoExample[],
  batchSize: number,
  seed: number,
  loop: boolean,
  padId = 0,
): Generator<DpoBatch> {
  if (batchSize < 1) throw new Error("iterateDpoBatches: batchSize must be >= 1");
  if (examples.length === 0) throw new Error("iterateDpoBatches: empty dataset");
  if (examples.length < batchSize)
    throw new Error(
      `iterateDpoBatches: dataset has ${examples.length} examples but batchSize=${batchSize}`,
    );

  const rng = mulberry32(seed >>> 0);
  const order = [...examples.keys()];
  do {
    for (let i = order.length - 1; i > 0; i--) {
      const j = Math.floor(rng() * (i + 1));
      [order[i], order[j]] = [order[j]!, order[i]!];
    }
    if (batchSize === 1) {
      for (const idx of order) {
        const ex = examples[idx]!;
        yield {
          chosenIds: [ex.chosenIds],
          rejectedIds: [ex.rejectedIds],
          chosenMask: [ex.chosenMask],
          rejectedMask: [ex.rejectedMask],
          chosenLengths: [ex.chosenIds.length],
          rejectedLengths: [ex.rejectedIds.length],
        };
      }
    } else {
      for (let i = 0; i + batchSize <= order.length; i += batchSize)
        yield makeDpoBatch(order.slice(i, i + batchSize).map((k) => examples[k]!), padId);
    }
  } while (loop);
}

/** Pad chosen/rejected branches each to their own batch-max length, masks 0 at
 *  pad positions (port of dpo.py _make_batch.pad). */
function makeDpoBatch(rows: DpoExample[], padId: number): DpoBatch {
  const Lc = Math.max(...rows.map((r) => r.chosenIds.length));
  const Lr = Math.max(...rows.map((r) => r.rejectedIds.length));
  const padRow = (src: number[], L: number, fill: number): number[] => {
    const out = new Array<number>(L).fill(fill);
    for (let t = 0; t < src.length; t++) out[t] = src[t]!;
    return out;
  };
  return {
    chosenIds: rows.map((r) => padRow(r.chosenIds, Lc, padId)),
    rejectedIds: rows.map((r) => padRow(r.rejectedIds, Lr, padId)),
    chosenMask: rows.map((r) => padRow(r.chosenMask, Lc, 0)),
    rejectedMask: rows.map((r) => padRow(r.rejectedMask, Lr, 0)),
    chosenLengths: rows.map((r) => r.chosenIds.length),
    rejectedLengths: rows.map((r) => r.rejectedIds.length),
  };
}

// ---------------------------------------------------------------------------
// shared
// ---------------------------------------------------------------------------

/** Format probe for inspect-dataset: peek the first row's keys. */
export type DatasetFormat = "messages" | "prompt-completion" | "text" | "dpo" | "preference" | "unknown";

export function probeFormat(row: Record<string, unknown>): DatasetFormat {
  if (typeof row.chosen === "string" && typeof row.rejected === "string") return "preference";
  try {
    return sftRowFormat(row);
  } catch {
    return "unknown";
  }
}

async function readJsonl(path: string): Promise<Record<string, unknown>[]> {
  const text = await Bun.file(path).text();
  const out: Record<string, unknown>[] = [];
  for (const line of text.split("\n")) {
    const t = line.trim();
    if (!t) continue;
    out.push(JSON.parse(t) as Record<string, unknown>);
  }
  return out;
}

function isPrefix(full: number[], prefix: number[]): boolean {
  if (prefix.length > full.length) return false;
  for (let i = 0; i < prefix.length; i++) if (full[i] !== prefix[i]) return false;
  return true;
}

/** Small deterministic PRNG (mulberry32) — seedable, no deps. */
function mulberry32(seed: number): () => number {
  let a = seed || 1;
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
