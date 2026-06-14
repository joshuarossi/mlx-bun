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

/** A single SFT training batch (v1: batch_size=1). `ids` is [B, L] flattened
 *  row-major with `lengths[i]` the true length of row i and `promptLens[i]`
 *  its prompt boundary. v1 has B=1 so there is exactly one row. */
export interface SftBatch {
  ids: number[][];
  promptLens: number[];
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

/** Iterate SFT batches. v1: batch_size=1 only. Examples are length-sorted
 *  (mlx-lm iterate_batches), then batches are shuffled with `seed` each
 *  epoch. Examples longer than `maxSeqLen` are right-truncated (preserving
 *  the prompt boundary clamp). `loop=false` yields one epoch then stops. */
export function* iterateSftBatches(
  examples: SftExample[],
  batchSize: number,
  maxSeqLen: number,
  seed: number,
  loop: boolean,
): Generator<SftBatch> {
  if (batchSize !== 1)
    throw new Error("iterateSftBatches: only batch_size=1 is supported in v1");
  if (examples.length === 0) throw new Error("iterateSftBatches: empty dataset");

  const order = [...examples.keys()].sort(
    (a, b) => examples[a]!.ids.length - examples[b]!.ids.length,
  );
  let rng = mulberry32(seed >>> 0);

  do {
    // Shuffle batch order each epoch (Fisher-Yates with the seeded rng).
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
      yield { ids: [ids], promptLens: [promptLen] };
    }
  } while (loop);
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

/** A single DPO batch (v1: batch_size=1). */
export interface DpoBatch {
  chosenIds: number[][];
  rejectedIds: number[][];
  chosenMask: number[][];
  rejectedMask: number[][];
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
  const promptIds = tok.encode(prompt);
  let fullIds = tok.encode(prompt + response);
  let promptLen: number;
  if (isPrefix(fullIds, promptIds)) {
    promptLen = promptIds.length;
  } else {
    promptLen = promptIds.length;
    const responseIds = tok.encode(response);
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
  return rows.map((r) => encodeDpoRow(r, tok, tmpl, maxLength));
}

/** Iterate DPO batches (v1: batch_size=1). Sequential epochs, reshuffled
 *  with `seed` each epoch (port of dpo.py _batch_at). */
export function* iterateDpoBatches(
  examples: DpoExample[],
  batchSize: number,
  seed: number,
  loop: boolean,
): Generator<DpoBatch> {
  if (batchSize !== 1)
    throw new Error("iterateDpoBatches: only batch_size=1 is supported in v1");
  if (examples.length === 0) throw new Error("iterateDpoBatches: empty dataset");

  const rng = mulberry32(seed >>> 0);
  const order = [...examples.keys()];
  do {
    for (let i = order.length - 1; i > 0; i--) {
      const j = Math.floor(rng() * (i + 1));
      [order[i], order[j]] = [order[j]!, order[i]!];
    }
    for (const idx of order) {
      const ex = examples[idx]!;
      yield {
        chosenIds: [ex.chosenIds],
        rejectedIds: [ex.rejectedIds],
        chosenMask: [ex.chosenMask],
        rejectedMask: [ex.rejectedMask],
      };
    }
  } while (loop);
}

// ---------------------------------------------------------------------------
// shared
// ---------------------------------------------------------------------------

/** Format probe for inspect-dataset: peek the first row's keys. */
export type DatasetFormat = "messages" | "prompt-completion" | "text" | "dpo" | "unknown";

export function probeFormat(row: Record<string, unknown>): DatasetFormat {
  if (typeof row.chosen === "string" && typeof row.rejected === "string") return "dpo";
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
