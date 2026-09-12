/** Token provenance for rendered multi-turn prompts. A generated BPE token
 * sequence need not equal encode(decode(ids)). Preserve the sequence that
 * produced the saved inference state when its rendered text is unchanged.
 * This stores only text and IDs; KV ownership and persistence live elsewhere. */
export interface PromptTokenHistory {
  remember(tokens: readonly number[]): void;
  resolve(rendered: string, canonical: number[]): number[];
}

interface TokenCodec {
  encode(text: string, addSpecialTokens?: boolean): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
}

export class GeneratedTokenHistory implements PromptTokenHistory {
  readonly #entries = new Map<string, number[]>();
  #chars = 0;
  constructor(readonly codec: TokenCodec, readonly maxChars = 2 ** 21, readonly maxEntries = 16) {}

  remember(tokens: readonly number[]): void {
    if (!tokens.length) return;
    const ids = [...tokens], text = this.codec.decode(ids, false);
    // An unfinished UTF-8 token is not a text boundary. A later checkpoint
    // can supply a complete prefix instead.
    if (!text.length || text.endsWith("\uFFFD") || text.length > this.maxChars) return;
    if (this.#entries.delete(text)) this.#chars -= text.length;
    this.#entries.set(text, ids); this.#chars += text.length;
    while (this.#entries.size > this.maxEntries || this.#chars > this.maxChars) {
      const oldest = this.#entries.keys().next().value!;
      this.#entries.delete(oldest); this.#chars -= oldest.length;
    }
  }

  resolve(rendered: string, canonical: number[]): number[] {
    let best: { text: string; ids: number[] } | undefined;
    for (const [text, ids] of this.#entries) {
      if (text.length >= rendered.length || (best && text.length <= best.text.length)) continue;
      if (rendered.startsWith(text)) best = { text, ids };
    }
    if (!best) return canonical;
    // Normal canonical output keeps the existing tokenizer fast path.
    if (best.ids.every((id, i) => canonical[i] === id)) return canonical;
    const ids = [...best.ids, ...this.codec.encode(rendered.slice(best.text.length), false)];
    // Decoder cleanup/normalization (e.g. SentencePiece's leading-space
    // rules) can make a standalone suffix unsafe to append.
    return this.codec.decode(ids, false) === rendered ? ids : canonical;
  }
}
