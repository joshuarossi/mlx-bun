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
}

export async function loadTokenizer(modelDir: string): Promise<LoadedTokenizer> {
  const [tokenizerJson, tokenizerConfig] = await Promise.all([
    Bun.file(`${modelDir}/tokenizer.json`).json(),
    Bun.file(`${modelDir}/tokenizer_config.json`).json(),
  ]);
  const tok = new Tokenizer(tokenizerJson, tokenizerConfig);

  const idOf = (key: string): number | null => {
    const t = tokenizerConfig[key];
    if (t == null) return null;
    const text = typeof t === "string" ? t : t.content;
    const enc = tok.encode(text, { add_special_tokens: false });
    return enc.ids.length === 1 ? Number(enc.ids[0]) : null;
  };

  return {
    encode: (text, addSpecialTokens = true) =>
      tok.encode(text, { add_special_tokens: addSpecialTokens }).ids.map(Number),
    decode: (ids, skipSpecialTokens = false) =>
      // python's decode([]) === ""; the JS lib throws on empty input
      ids.length === 0 ? "" : tok.decode(ids, { skip_special_tokens: skipSpecialTokens }),
    idToToken: (id) =>
      (tok as unknown as { id_to_token(id: number): string | undefined })
        .id_to_token(id) ?? tok.decode([id], { skip_special_tokens: false }),
    bosTokenId: idOf("bos_token"),
    eosTokenId: idOf("eos_token"),
    tokenizerJsonPath: `${modelDir}/tokenizer.json`,
  };
}
