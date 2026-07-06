// Tokenizer: @huggingface/tokenizers (pure JS/TS — no native code, no
// WASM; embeds directly in `bun build --compile`). Decision spike result:
// see PLAN.md Phase 1 findings. Correctness contract: round-trip parity
// with the Python oracle's AutoTokenizer (goldens/tokenizer.json).

import { Tokenizer } from "@huggingface/tokenizers";

export interface LoadedTokenizer {
  /** Encode text → token ids. `addSpecialTokens` (default true) prepends the BOS;
   *  pass FALSE for chat-template output, which already emits the BOS as text (else
   *  you get a corrupting double-BOS `<s><s>…`). */
  encode(text: string, addSpecialTokens?: boolean): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
  /** Token id → raw vocab token string (mlx-lm's convert_ids_to_tokens —
   *  the undecoded piece, e.g. "▁Hello", used in logprobs responses).
   *  Falls back to decode() for ids outside the base vocab (added tokens). */
  idToToken(id: number): string;
  readonly bosTokenId: number | null;
  readonly eosTokenId: number | null;
  /** Absolute path to tokenizer.json (the model snapshot dir's copy). Set by
   *  loadTokenizer; read by src/grammar.ts to build the xgrammar TokenizerInfo
   *  (vocab extraction + vocab-type detection for constrained decoding). */
  readonly tokenizerJsonPath?: string;
  /** config.json vocab_size, may exceed the tokenizer vocab length when the
   *  embedding is padded to a power-of-two / 256. Read by src/grammar.ts to
   *  size the logit bitmask against the model's logit width, not the
   *  tokenizer's. Set by the server when it loads config; not set by the
   *  bare loadTokenizer() helper (callers that need it pass modelDir + config). */
  vocabSize?: number;
  /** mlx-lm streaming-detokenizer parity: true for ByteLevel-decoder (BPE)
   *  tokenizers, where mlx-lm's BPEStreamingDetokenizer drops ONE leading " "
   *  at the very start of a generated sequence (tokenizer_utils.py
   *  `_maybe_trim_space`: `elif not self.text: return current_text[1:]`).
   *  Our decode() delegates to @huggingface/tokenizers, whose ByteLevel
   *  decoder KEEPS that space — the serving StreamDecoder consults this flag
   *  to match mlx-lm's rendered bytes (e.g. MiniCPM5 /v1/completions:
   *  "2, 3, 5…" not " 2, 3, 5…"). SPM tokenizers need nothing: with a Strip
   *  decoder the strip already happens inside decode(); without one
   *  (gemma-4) mlx-lm uses trim_space=False and keeps the space too. */
  readonly trimsLeadingSpace?: boolean;
}

// Exact-input encode memo. Our pure-JS encode costs ~90 ms per 9.6k tokens
// (vs Rust tokenizers ~15 ms) and the serving hot paths re-encode BYTE-
// IDENTICAL text constantly: warm/ctx repeats re-render the same
// conversation, and regenerate flows resend it. A string-keyed LRU makes
// those free and is exact by construction (no BPE boundary reasoning).
// Bounded: keys are capped by count and total chars, so at most a few MB.
// Incremental suffix-encode for append-only conversations is the follow-on
// (needs token offsets + a verified cut); the native port is the endgame.
const ENCODE_MEMO_MAX_ENTRIES = 16;
const ENCODE_MEMO_MAX_CHARS = 1 << 21; // ~2M chars ≈ 4 MB of keys
class EncodeMemo {
  #map = new Map<string, number[]>(); // Map preserves insertion order → LRU
  #chars = 0;
  get(key: string): number[] | undefined {
    const hit = this.#map.get(key);
    if (!hit) return undefined;
    this.#map.delete(key); // bump recency
    this.#map.set(key, hit);
    return hit;
  }
  set(key: string, ids: number[]): void {
    if (this.#map.has(key)) { this.#chars -= key.length; this.#map.delete(key); }
    this.#map.set(key, ids);
    this.#chars += key.length;
    while (this.#map.size > ENCODE_MEMO_MAX_ENTRIES || this.#chars > ENCODE_MEMO_MAX_CHARS) {
      const oldest = this.#map.keys().next().value as string | undefined;
      if (oldest === undefined) break;
      this.#chars -= oldest.length;
      this.#map.delete(oldest);
    }
  }
}

export async function loadTokenizer(modelDir: string): Promise<LoadedTokenizer> {
  const [tokenizerJson, tokenizerConfig] = await Promise.all([
    Bun.file(`${modelDir}/tokenizer.json`).json(),
    Bun.file(`${modelDir}/tokenizer_config.json`).json(),
  ]);
  const tok = new Tokenizer(tokenizerJson, tokenizerConfig);
  const memo = new EncodeMemo();

  const idOf = (key: string): number | null => {
    const t = tokenizerConfig[key];
    if (t == null) return null;
    const text = typeof t === "string" ? t : t.content;
    const enc = tok.encode(text, { add_special_tokens: false });
    return enc.ids.length === 1 ? Number(enc.ids[0]) : null;
  };

  return {
    encode: (text, addSpecialTokens = true) => {
      // Memoize only substantial inputs: short prompts encode in <1 ms and
      // would churn the LRU.
      if (text.length < 4096)
        return tok.encode(text, { add_special_tokens: addSpecialTokens }).ids.map(Number);
      const key = `${addSpecialTokens ? "S" : "s"}|${text}`;
      const hit = memo.get(key);
      if (hit) return hit.slice();
      const ids = tok.encode(text, { add_special_tokens: addSpecialTokens }).ids.map(Number);
      memo.set(key, ids);
      return ids.slice();
    },
    decode: (ids, skipSpecialTokens = false) =>
      // python's decode([]) === ""; the JS lib throws on empty input
      ids.length === 0 ? "" : tok.decode(ids, { skip_special_tokens: skipSpecialTokens }),
    idToToken: (id) =>
      (tok as unknown as { id_to_token(id: number): string | undefined })
        .id_to_token(id) ?? tok.decode([id], { skip_special_tokens: false }),
    bosTokenId: idOf("bos_token"),
    eosTokenId: idOf("eos_token"),
    tokenizerJsonPath: `${modelDir}/tokenizer.json`,
    // mirror mlx-lm's `_is_bpe_decoder` (tokenizer_utils.py): top-level
    // decoder type "ByteLevel" selects the BPE streaming detokenizer, the
    // only class whose sequence-start space-trim our decode() lacks.
    trimsLeadingSpace:
      (tokenizerJson as { decoder?: { type?: string } }).decoder?.type === "ByteLevel",
  };
}
