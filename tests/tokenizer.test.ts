// Tokenizer parity with the Python oracle (goldens/tokenizer.json):
// identical ids for every golden prompt, identical decode round-trip.

import { describe, expect, test } from "bun:test";
import { goldenAt } from "./goldens";
import { SNAPSHOT, snapshotAvailable } from "./paths";

const haveWeights = await snapshotAvailable();
const goldenFile = goldenAt("tokenizer.json");
const haveGoldens = await goldenFile.exists();

describe.skipIf(!haveWeights || !haveGoldens)("tokenizer oracle parity", async () => {
  if (!haveWeights || !haveGoldens) return;
  const golden = (await goldenFile.json()) as {
    cases: { text: string; ids: number[]; decoded: string }[];
    bos_token_id: number;
    eos_token_id: number;
  };

  const { loadTokenizer } = await import("../src/tokenizer");
  const tok = await loadTokenizer(SNAPSHOT);

  test("special token ids match", () => {
    expect(tok.bosTokenId).toBe(golden.bos_token_id);
    expect(tok.eosTokenId).toBe(golden.eos_token_id);
  });

  for (const c of golden.cases) {
    const label = c.text === "" ? "<empty>" : JSON.stringify(c.text.slice(0, 40));
    test(`encode parity: ${label}`, () => {
      expect(tok.encode(c.text)).toEqual(c.ids);
    });
    test(`decode parity: ${label}`, () => {
      expect(tok.decode(c.ids)).toBe(c.decoded);
    });
  }
});
