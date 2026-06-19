// UltraFeedback (binarized) → mlx-bun preference rows. The binarized schema
// (HuggingFaceH4/ultrafeedback_binarized) gives each row a `prompt` plus
// `chosen` / `rejected` as message lists; ORPO wants {prompt, chosen, rejected}
// where chosen/rejected are the assistant response *strings*. Pure transform so
// it is unit-testable without downloading the dataset.

export interface PreferenceRow {
  prompt: string;
  chosen: string;
  rejected: string;
}

type Msg = { role?: string; content?: string };

/** Last assistant message content in a binarized message list (the response). */
function lastAssistant(messages: unknown): string | null {
  if (!Array.isArray(messages)) return null;
  for (let i = messages.length - 1; i >= 0; i--) {
    const m = messages[i] as Msg;
    if (m && m.role === "assistant" && typeof m.content === "string" && m.content.trim())
      return m.content;
  }
  return null;
}

/** Convert one binarized UltraFeedback row → a preference row, or null if it is
 *  unusable (missing fields, or chosen == rejected so there is no signal). */
export function toPreferenceRow(row: Record<string, unknown>): PreferenceRow | null {
  const prompt = typeof row.prompt === "string" ? row.prompt : null;
  const chosen = lastAssistant(row.chosen);
  const rejected = lastAssistant(row.rejected);
  if (!prompt || !chosen || !rejected) return null;
  if (chosen.trim() === rejected.trim()) return null;
  return { prompt, chosen, rejected };
}

/** Rough token estimate (≈4 chars/token) for a cheap length pre-filter before
 *  tokenization — keeps the curated set within a target context without loading
 *  a tokenizer. */
export function approxTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

/** Filter + convert a stream of binarized rows. Drops unusable rows and ones
 *  whose prompt+chosen or prompt+rejected approx-exceeds `maxApproxTokens`. */
export function curate(
  rows: Record<string, unknown>[],
  maxApproxTokens = 2048,
): PreferenceRow[] {
  const out: PreferenceRow[] = [];
  for (const row of rows) {
    const p = toPreferenceRow(row);
    if (!p) continue;
    const base = approxTokens(p.prompt);
    if (base + approxTokens(p.chosen) > maxApproxTokens) continue;
    if (base + approxTokens(p.rejected) > maxApproxTokens) continue;
    out.push(p);
  }
  return out;
}
