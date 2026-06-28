// mlx-bun memory — deterministic validation/repair of model-emitted chunk
// anchors (ported from lucien scripts/chunk-validation.ts, P5-T2).
//
// Same philosophy as the rest of the synthesis ledger: enforce the invariant in
// code, don't trust the model. The local e4b chunk adapter emits anchors that
// don't resolve a few percent of the time — the conversation uuid pasted where a
// message uuid belongs, or two adjacent message uuids spliced into a chimera.
// Left unvalidated those land in `chunks` and silently break pointer resolution
// (chunkText resolves a position range from each anchor's message). Repairs, in
// order:
//   - exact match                  → use as-is
//   - anchor == conversation uuid  → first message (start) / last (end)
//   - unique long-prefix match     → that message (handles chimera splices)
//   - otherwise                    → ChunkValidationError: fail the whole
//     conversation so it retries on the next run (the errored path)
// A trailing coverage gap (the model stopped before the final exchange) extends
// the latest-ending chunk to the last message it was shown.

export interface RawChunk {
  start_message_uuid: string;
  end_message_uuid: string;
  label: string;
}

export interface ChunkMessage {
  uuid: string;
}

export interface ValidationResult {
  chunks: RawChunk[];
  repairs: string[];
}

export class ChunkValidationError extends Error {}

// A chimera splice keeps one anchor's leading bytes intact; distinct uuids share
// at most a few hex chars by chance, so 8 (the first uuid group) is an
// unambiguous threshold. Below it we'd be guessing, so the conversation fails
// instead and retries on the next run.
const MIN_PREFIX = 8;

function commonPrefixLen(a: string, b: string): number {
  const n = Math.min(a.length, b.length);
  let i = 0;
  while (i < n && a[i] === b[i]) i++;
  return i;
}

function resolveAnchor(
  anchor: string,
  kind: "start" | "end",
  positions: Map<string, number>,
  messages: ChunkMessage[],
  conversationUuid: string,
  repairs: string[],
  label: string,
): number {
  const exact = positions.get(anchor);
  if (exact !== undefined) return exact;

  if (anchor === conversationUuid) {
    const pos = kind === "start" ? 0 : messages.length - 1;
    repairs.push(`"${label}": ${kind} anchor was the conversation uuid, snapped to message ${pos}`);
    return pos;
  }

  let best = -1;
  let bestLen = 0;
  let secondLen = 0;
  for (let i = 0; i < messages.length; i++) {
    const len = commonPrefixLen(anchor, messages[i]!.uuid);
    if (len > bestLen) {
      secondLen = bestLen;
      bestLen = len;
      best = i;
    } else if (len > secondLen) {
      secondLen = len;
    }
  }
  if (best !== -1 && bestLen >= MIN_PREFIX && bestLen > secondLen) {
    repairs.push(
      `"${label}": ${kind} anchor ${anchor.slice(0, 13)}… not found, ` +
        `prefix-matched (${bestLen} chars) to message ${best}`,
    );
    return best;
  }

  throw new ChunkValidationError(
    `chunk "${label}": ${kind} anchor "${anchor}" does not resolve to any ` +
      `message uuid (no exact match, not the conversation uuid, best prefix ` +
      `${bestLen} < ${MIN_PREFIX} or ambiguous)`,
  );
}

export function validateChunks(
  raw: RawChunk[],
  messages: ChunkMessage[],
  conversationUuid: string,
): ValidationResult {
  const repairs: string[] = [];

  if (messages.length === 0) return { chunks: [], repairs };

  const positions = new Map<string, number>();
  messages.forEach((m, i) => positions.set(m.uuid, i));

  const resolved: { start: number; end: number; label: string }[] = [];
  for (const chunk of raw) {
    const label = chunk.label ?? "(unlabeled)";
    let start = resolveAnchor(chunk.start_message_uuid, "start", positions, messages, conversationUuid, repairs, label);
    let end = resolveAnchor(chunk.end_message_uuid, "end", positions, messages, conversationUuid, repairs, label);
    if (start > end) {
      repairs.push(`"${label}": inverted range [${start}, ${end}], swapped`);
      [start, end] = [end, start];
    }
    resolved.push({ start, end, label });
  }

  // Trailing coverage: if the model stopped short of the final exchange, extend
  // the latest-ending chunk to the last message. Interior gaps are left alone
  // (often deliberately-skipped command noise); an empty chunk list is respected
  // (some conversations legitimately produce nothing).
  if (resolved.length > 0) {
    const last = messages.length - 1;
    let maxEnd = -1;
    let maxIdx = -1;
    resolved.forEach((c, i) => {
      if (c.end > maxEnd) {
        maxEnd = c.end;
        maxIdx = i;
      }
    });
    if (maxEnd < last) {
      repairs.push(
        `"${resolved[maxIdx]!.label}": trailing gap [${maxEnd + 1}, ${last}] uncovered, ` +
          `extended chunk end ${maxEnd} → ${last}`,
      );
      resolved[maxIdx]!.end = last;
    }
  }

  return {
    chunks: resolved.map((c) => ({
      start_message_uuid: messages[c.start]!.uuid,
      end_message_uuid: messages[c.end]!.uuid,
      label: c.label,
    })),
    repairs,
  };
}
