// Lane registry — the in-process correlation channel between server.ts (which
// decides + knows the serving lane per request) and pi-web.ts (the WS bridge,
// same process, different module). Exists because the pi SDK's own usage
// parsing (parseChunkUsage in @earendil-works/pi-ai's openai-completions.js)
// hard-codes the OpenAI usage fields it reads (prompt_tokens/completion_tokens/
// prompt_tokens_details only) and drops any custom field — so a `lane` value
// riding on the HTTP usage payload never reaches the SDK's AssistantMessage.usage
// or the turn_end AgentSessionEvent. What DOES survive is `responseId` (set from
// the chat-completion response's `id` field, which our server always sets to
// `chatcmpl-<uuid>`), so this registry is keyed by that same id: server.ts
// records the lane the moment it decides one (before generation starts, so it's
// available even in flight), pi-web.ts looks it up via the turn's
// AssistantMessage.responseId once the turn ends.
//
// Bounded + self-expiring (a small LRU-ish cap, not a TTL timer) since this is
// a same-process debugging/telemetry aid, not a durable store — entries for
// long-dead requests must not leak memory over a long-running server.

export type Lane = "serial" | "serial+spec" | "batched";

const MAX_ENTRIES = 512;
const lanes = new Map<string, Lane>();

/** Record the lane a request (by its `chatcmpl-…`/`cmpl-…` id) was served on.
 *  Call once the lane is known — safe to call again if it refines (e.g.
 *  "serial" -> "serial+spec" once spec stats are available). */
export function recordLane(requestId: string, lane: Lane): void {
  lanes.delete(requestId); // re-insert at the end (Map preserves insertion order)
  lanes.set(requestId, lane);
  if (lanes.size > MAX_ENTRIES) {
    const oldest = lanes.keys().next().value;
    if (oldest !== undefined) lanes.delete(oldest);
  }
}

/** Look up the lane for a request id, if still resident. */
export function getLane(requestId: string): Lane | undefined {
  return lanes.get(requestId);
}

/** Test-only: drop everything. */
export function clearLaneRegistry(): void {
  lanes.clear();
}
