// Tokenizer: @huggingface/tokenizers (pure JS/TS — no native code, no
// WASM; embeds directly in `bun build --compile`). Decision spike result:
// see PLAN.md Phase 1 findings. Correctness contract: round-trip parity
// with the Python oracle's AutoTokenizer (goldens/tokenizer.json).

import { Tokenizer } from "@huggingface/tokenizers";

export interface LoadedTokenizer {
  encode(text: string): number[];
  decode(ids: number[], skipSpecialTokens?: boolean): string;
  readonly bosTokenId: number | null;
  readonly eosTokenId: number | null;
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
    encode: (text) => tok.encode(text).ids.map(Number),
    decode: (ids, skipSpecialTokens = false) =>
      // python's decode([]) === ""; the JS lib throws on empty input
      ids.length === 0 ? "" : tok.decode(ids, { skip_special_tokens: skipSpecialTokens }),
    bosTokenId: idOf("bos_token"),
    eosTokenId: idOf("eos_token"),
  };
}
