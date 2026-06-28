// mlx-bun memory — synthesis stage 2: SEGMENT (chunking).  (P5-T2)
//
// Segment each new/grown conversation into topic chunks with the local model.
// This is the segmentation track distilled from gold: the validated Gemma-4-e4b
// chunk SFT adapter (`e4b-chunk-300`, symlinked to `memory-chunk`) drives it via
// callLocal("chunk", …). The CHUNK_PROMPT below is ported from lucien's
// chunk-recent.ts; the editorial knobs (granularity, overlap, what to ignore)
// are NOT hard-coded here — they are inlined from the vault's Meta/ pages
// (Chunking.md + Topics_to_Ignore.md) so the policy is edit-in-the-vault.
//
// Chunks are stored as POINTERS, exactly like the Lucien bootstrap: a chunk is a
// [start,end] position range into its conversation's messages (id =
// chunkId(conv,start,end)); chunkText() reassembles the slice on demand. The
// model emits message UUIDs, which we resolve (with anchor repair, see
// chunk-validation.ts) back to positions before writing.
//
// Re-chunk only conversations whose updated_at > chunked_at (NULL chunked_at = a
// never-segmented conversation). Setting chunked_at after a successful run makes
// re-running a no-op. See docs/design/the-dreaming-master-plan.md → P5-T2.

import { MemoryStore, chunkId } from "./db";
import { callLocal, type LocalInput } from "./model";
import { loadMetaPolicy } from "./prompts";
import { validateChunks, ChunkValidationError, type ChunkMessage } from "./chunk-validation";
import type { SynthesisEvent } from "./pipeline";

// The EXACT system turn the `e4b-chunk-300` adapter was SFT'd with (the verbatim
// `messages[0].content` from chunk-data-le4000/train.jsonl). It MUST match training
// byte-for-byte: the e4b template emits a distinct `<|turn>system…<turn|>` block
// for it, and live inference previously dropped the whole system segment (decoded
// the chunk adapter off-distribution). The chunk SEGMENT call passes this as the
// system turn so the only trained adapter decodes on-distribution.
export const CHUNK_SYSTEM = `You are a precise conversation-segmentation engine, not a coding assistant and not a chat assistant. You receive ONE conversation transcript and return its topic segmentation.

Absolute output contract (overrides any conversational instinct):
- Your entire response MUST be a single JSON object, parseable by JSON.parse with no edits.
- No prose, no preamble, no explanation, no follow-up question, no markdown code fences, no tool calls. The first character you emit is "{" and the last is "}".
- Never ask for clarification or more data — the transcript in the message IS the data. If it has no meaningful content, return {"chunks": []}.
- Use only message UUIDs present in the provided transcript; never invent or alter a UUID.

Follow the segmentation rules and JSON schema in the message exactly.`;

// Ported verbatim-in-spirit from lucien scripts/chunk-recent.ts. The {{META_DOCS}}
// placeholder is filled at run time with the inlined Meta/ policy pages. This is
// the USER turn; CHUNK_SYSTEM above is the trained system turn.
export const CHUNK_PROMPT = `You will analyze ONE conversation between a user and an AI assistant. Identify ALL distinct topic chunks within it.

Use ONLY content from the conversation provided below; never copy any name, value, or example from these instructions into a label.

CRITICAL INSTRUCTIONS:
- Most substantive conversations contain MULTIPLE chunks, not one. Look hard for topic shifts.
- A topic shift happens when the user moves from one subject to a substantially different subject. Examples:
  - Discussing one feature, then asking about a different feature
  - Working through a problem, then pivoting to a related but distinct concern
  - Asking about topic X, then asking about topic Y
- Even within a single broad topic, you should identify sub-chunks for specific aspects.
- Short conversations (under 4 messages) with a single Q&A may legitimately be one chunk. Most longer conversations are multiple chunks.
- Chunks MAY overlap. When a message at a topic boundary is genuinely substantive to BOTH the topic that is ending and the one beginning, include it in BOTH chunks — it is the end_message_uuid of one and falls within the range of the next. Do this only for genuine dual-membership, never for connective filler.

POLICY — the user's editorial policy pages are reproduced IN FULL under META POLICY PAGES below. Do not read any files; everything you need is in this prompt. Two things there govern you:
  (1) Ignore rules — do NOT emit a chunk for any span whose subject falls under one; simply omit it.
  (2) Chunking style — the instructions above (how fine a chunk is, how aggressively to overlap vs. draw hard boundaries, when a whole conversation is one chunk) are DEFAULTS. If a Meta doc specifies different chunking-style preferences, follow it over those defaults.
- You MUST still segment the conversation into topic chunks in the output schema below — that is not optional and no Meta doc overrides it. This prompt defines WHAT to do (segment into chunks; this schema); the Meta docs define HOW (granularity, overlap aggressiveness, boundary hardness, what to ignore).

META POLICY PAGES:
{{META_DOCS}}

For each chunk, output:
- start_message_uuid: uuid of the first message in the chunk
- end_message_uuid: uuid of the last message in the chunk
- label: a specific, descriptive label. Aim for 4-10 words. It must name the concrete subject AND the facet discussed, drawn ENTIRELY from this conversation — never from these instructions.
  GOOD shape: "<specific subject> <facet discussed>" — the named topic plus the angle on it (e.g. a named subject followed by the specific decision, problem, or aspect covered).
  BAD shape: a vague catch-all that names no specific subject (e.g. "a technical discussion", "a Q&A", "a conversation about <topic>").

OUTPUT FORMAT:
Output ONLY a JSON object, nothing else. No markdown fences, no explanation, no preamble.

If the conversation has meaningful content:
{"chunks": [{"start_message_uuid": "...", "end_message_uuid": "...", "label": "..."}, ...]}

If the conversation has no meaningful content (all messages empty or pure noise):
{"chunks": []}

Here is the conversation:
`;

/** The Meta/ policy pages SEGMENT inlines (P1-T7 / B10). Order is stable. */
const META_POLICY_PAGES = ["Chunking", "Topics_to_Ignore"];

/** Wrap a rendered chunk prompt as the trained {system, user} input. */
export function chunkInput(prompt: string): LocalInput {
  return { system: CHUNK_SYSTEM, user: prompt };
}

export interface ChunkResult {
  /** Conversations eligible this run (NULL chunked_at or updated_at > chunked_at). */
  conversations: number;
  /** Of those, the ones sent to the model (non-empty + at least one assistant turn). */
  attempted: number;
  /** Conversations whose output parsed to valid JSON with in-range anchors. */
  valid: number;
  /** Conversations skipped as empty / no-assistant and marked complete. */
  skipped: number;
  /** Conversations whose output failed to parse/validate (not marked; retried next run). */
  errored: number;
  /** Total chunk-pointer rows written this run. */
  chunks: number;
}

/** Model-call seam for SEGMENT — same shape as the other stage seams. Defaults
 *  to `callLocal("chunk", …)` (the e4b-chunk-300 / `memory-chunk` adapter); tests
 *  inject a fake so the pipeline can be driven without a real model load. */
export type ChunkCall = (prompt: string, opts?: { maxTokens?: number }) => Promise<string>;

export interface ChunkOptions {
  /** Restrict to these conv ids (the smoke/eval path). Default: all eligible. */
  convs?: string[];
  /** Cap the number of conversations processed this run. */
  limit?: number;
  /** Generation budget per conversation. */
  maxTokens?: number;
  /** Override the model call (default `callLocal("chunk", …)`). Tests inject a fake. */
  call?: ChunkCall;
}

interface ConvRow {
  conv: string;
  title: string | null;
  updated_at: number;
  chunked_at: number | null;
}

interface MsgRow {
  position: number;
  role: string;
  uuid: string;
  text: string;
}

function emptyResult(): ChunkResult {
  return { conversations: 0, attempted: 0, valid: 0, skipped: 0, errored: 0, chunks: 0 };
}

/** Format a conversation the way the e4b chunk adapter was trained: a header line
 *  then each non-empty message as `[role] (uuid: …) text`, joined by `---`. */
export function formatConversation(title: string, conv: string, messages: MsgRow[]): string {
  const body = messages
    .map((m) => `[${m.role}] (uuid: ${m.uuid})\n${m.text}\n`)
    .join("\n---\n");
  return `Conversation: ${title || "(untitled)"} (uuid: ${conv})\n\n${body}`;
}

/** Best-effort JSON extraction from a model completion (ported from chunk-recent.ts). */
function extractJSON(response: string): { chunks?: unknown } {
  const trimmed = response.trim();
  try {
    return JSON.parse(trimmed);
  } catch {
    /* fall through */
  }
  const stripped = trimmed
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/i, "")
    .replace(/```\s*$/, "");
  try {
    return JSON.parse(stripped);
  } catch {
    /* fall through */
  }
  const firstBrace = response.indexOf("{");
  const lastBrace = response.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace > firstBrace) {
    try {
      return JSON.parse(response.slice(firstBrace, lastBrace + 1));
    } catch {
      /* fall through */
    }
  }
  throw new Error("could not extract valid JSON from response");
}

/** Select the conversations to (re)segment, honoring the watermark rule. */
function selectEligible(store: MemoryStore, opts: ChunkOptions): ConvRow[] {
  const rows = store.db
    .query(
      `SELECT conv, title, updated_at, chunked_at FROM conversations
         WHERE chunked_at IS NULL OR updated_at > chunked_at
         ORDER BY updated_at ASC`,
    )
    .all() as ConvRow[];
  let eligible = rows;
  if (opts.convs && opts.convs.length > 0) {
    const allow = new Set(opts.convs);
    eligible = eligible.filter((r) => allow.has(r.conv));
  }
  if (opts.limit !== undefined) eligible = eligible.slice(0, opts.limit);
  return eligible;
}

/**
 * Conversations → topic chunks (local model). For each eligible conversation,
 * render the CHUNK_PROMPT with inlined Meta policy, call the chunk adapter,
 * repair + validate the emitted anchors, and write pointer rows. Idempotent:
 * sets chunked_at on success so a re-run is a no-op.
 */
export async function chunkConversations(
  store: MemoryStore,
  opts: ChunkOptions = {},
  onEvent?: (e: SynthesisEvent) => void,
): Promise<ChunkResult> {
  const result = emptyResult();
  // Default seam renders the trained {system: CHUNK_SYSTEM, user: <prompt>} shape
  // so the chunk adapter decodes on-distribution. Tests inject a `call` that
  // ignores the role split (it pattern-matches the prompt string).
  const call: ChunkCall = opts.call ?? ((prompt, o) => callLocal("chunk", chunkInput(prompt), o));

  // Inline the Meta policy once per run — pages change only by hand-edit, so a
  // single bounded prefill per conversation (no agent loop) is all we need. LAZY:
  // loadMetaPolicy reads the (global) vault and THROWS on a missing page, so we
  // defer it until a conversation is actually sent to the model — a run with no
  // eligible/attempted conversations (the common pipeline no-op) never needs it.
  let promptHeadCache: string | undefined;
  const promptHead = (): string =>
    (promptHeadCache ??= CHUNK_PROMPT.replace("{{META_DOCS}}", loadMetaPolicy(META_POLICY_PAGES)));

  const eligible = selectEligible(store, opts);
  result.conversations = eligible.length;
  onEvent?.({
    type: "log",
    stage: "chunk",
    message: `segment: ${eligible.length} conversation(s) eligible`,
  });

  const msgQuery = store.db.query(
    "SELECT position, role, uuid, text FROM messages WHERE conv = ? ORDER BY position",
  );
  const delChunks = store.db.query("DELETE FROM chunks WHERE conv = ?");
  const insChunk = store.db.query(
    "INSERT OR IGNORE INTO chunks (id, conv, start, end, label) VALUES (?, ?, ?, ?, ?)",
  );
  const setChunkedAt = store.db.query("UPDATE conversations SET chunked_at = ? WHERE conv = ?");

  let i = 0;
  for (const c of eligible) {
    i++;
    const allMsgs = msgQuery.all(c.conv) as MsgRow[];
    const nonEmpty = allMsgs.filter((m) => m.text && m.text.trim());

    // Skip 1: fully empty conversation (likely deleted) — mark complete.
    if (nonEmpty.length === 0) {
      setChunkedAt.run(Date.now(), c.conv);
      result.skipped++;
      continue;
    }
    // Skip 2: no assistant turn — nothing to segment — mark complete.
    if (!nonEmpty.some((m) => m.role === "assistant")) {
      setChunkedAt.run(Date.now(), c.conv);
      result.skipped++;
      continue;
    }

    result.attempted++;
    const prompt = promptHead() + formatConversation(c.title ?? "", c.conv, nonEmpty);

    let response: string;
    try {
      response = await call(prompt, { maxTokens: opts.maxTokens ?? 2048 });
    } catch (err) {
      onEvent?.({ type: "log", stage: "chunk", message: `[${i}/${eligible.length}] ${c.conv}: model error: ${String(err)}` });
      result.errored++;
      continue;
    }

    try {
      const parsed = extractJSON(response);
      const rawChunks = Array.isArray(parsed.chunks) ? parsed.chunks : [];
      const anchorMsgs: ChunkMessage[] = nonEmpty.map((m) => ({ uuid: m.uuid }));
      const { chunks, repairs } = validateChunks(rawChunks as never, anchorMsgs, c.conv);
      for (const r of repairs) onEvent?.({ type: "log", stage: "chunk", message: `  repair: ${r}` });

      // Resolve validated uuid anchors back to mlx-bun positions and write pointers.
      const posByUuid = new Map<string, number>();
      for (const m of nonEmpty) posByUuid.set(m.uuid, m.position);

      const tx = store.db.transaction(() => {
        delChunks.run(c.conv); // re-chunk: drop the prior segmentation
        let wrote = 0;
        for (const ch of chunks) {
          const s = posByUuid.get(ch.start_message_uuid);
          const e = posByUuid.get(ch.end_message_uuid);
          if (s === undefined || e === undefined) continue; // unreachable post-validation
          const lo = Math.min(s, e);
          const hi = Math.max(s, e);
          const info = insChunk.run(chunkId(c.conv, lo, hi), c.conv, lo, hi, ch.label);
          wrote += info.changes;
        }
        setChunkedAt.run(Date.now(), c.conv);
        return wrote;
      });
      const wrote = tx();
      result.chunks += wrote;
      result.valid++;
      onEvent?.({ type: "log", stage: "chunk", message: `[${i}/${eligible.length}] ${c.conv}: ${chunks.length} chunk(s)` });
    } catch (err) {
      // Parse/validation failure: do NOT mark complete — it retries next run.
      const kind = err instanceof ChunkValidationError ? "validation" : "parse";
      onEvent?.({ type: "log", stage: "chunk", message: `[${i}/${eligible.length}] ${c.conv}: ${kind} error: ${String(err)}` });
      result.errored++;
    }
  }

  onEvent?.({
    type: "log",
    stage: "chunk",
    message: `segment done: ${result.attempted} attempted, ${result.valid} valid, ${result.skipped} skipped, ${result.errored} errored, ${result.chunks} chunks`,
  });
  return result;
}
