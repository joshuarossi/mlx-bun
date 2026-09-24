import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadTokenizer } from "@mlx-bun/inference/input";

test("loads Hugging Face tokenizer artifacts from a caller-supplied directory", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-tokenizer-"));
  try {
    await Bun.write(join(dir, "tokenizer.json"), JSON.stringify({
      version: "1.0", truncation: null, padding: null, normalizer: null,
      added_tokens: ["[UNK]", "[BOS]", "[EOS]"].map((content, id) => ({ id, content, single_word: false, lstrip: false, rstrip: false, normalized: false, special: true })),
      pre_tokenizer: { type: "WhitespaceSplit" }, decoder: null,
      model: { type: "WordLevel", vocab: { "[UNK]": 0, "[BOS]": 1, "[EOS]": 2, hello: 3, world: 4 }, unk_token: "[UNK]" },
      post_processor: { type: "TemplateProcessing", single: [{ SpecialToken: { id: "[BOS]", type_id: 0 } }, { Sequence: { id: "A", type_id: 0 } }], pair: [], special_tokens: { "[BOS]": { id: "[BOS]", ids: [1], tokens: ["[BOS]"] } } },
    }));
    await Bun.write(join(dir, "tokenizer_config.json"), JSON.stringify({ bos_token: "[BOS]", eos_token: "[EOS]", unk_token: "[UNK]" }));
    const tokenizer = await loadTokenizer(dir);
    expect(tokenizer.encode("hello world")).toEqual([1, 3, 4]);
    expect(tokenizer.encode("hello world", false)).toEqual([3, 4]);
    expect(tokenizer.decode([3, 4])).toBe("hello world");
    expect(tokenizer.decode([])).toBe("");
    expect(tokenizer.bosTokenId).toBe(1);
    expect(tokenizer.eosTokenId).toBe(2);
    expect(tokenizer.idToToken(4)).toBe("world");
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
