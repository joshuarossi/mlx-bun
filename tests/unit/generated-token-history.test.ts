import { describe, expect, test } from "bun:test";
import { GeneratedTokenHistory } from "../../src/serve/generated-token-history";

// IDs 1,2 and ID 3 spell exactly the same bytes. The model can emit
// 1,2 even though the tokenizer's canonical encoding uses 3.
const pieces: Record<number, string> = { 1: "'));", 2: "\n", 3: "'));\n", 4: "tail", 5: "<think>", 6: "\uFFFD" };
const codec = {
  decode: (ids: number[]) => ids.map(id => pieces[id]!).join(""),
  encode(text: string, _special?: boolean): number[] {
    const ids: number[] = [];
    while (text.length) {
      const entry = [3, 1, 2, 4, 5, 6].find(id => text.startsWith(pieces[id]!));
      if (entry === undefined) throw Error(`unrecognized text: ${text}`);
      ids.push(entry); text = text.slice(pieces[entry]!.length);
    }
    return ids;
  },
};

describe("generated token provenance", () => {
  test("unchanged rendered history retains the exact generated IDs across a BPE merge", () => {
    const history = new GeneratedTokenHistory(codec);
    const generated = [5, 1, 2];
    history.remember(generated);
    const rendered = codec.decode([...generated, 4]);
    const canonical = codec.encode(rendered);
    expect(canonical).toEqual([5, 3, 4]);
    expect(history.resolve(rendered, canonical)).toEqual([5, 1, 2, 4]);
    expect(codec.decode(history.resolve(rendered, canonical))).toBe(rendered);
    generated[1] = 4; // provenance owns its IDs
    expect(history.resolve(rendered, canonical)).toEqual([5, 1, 2, 4]);
  });

  test("changed history and unrelated text keep canonical encoding", () => {
    const history = new GeneratedTokenHistory(codec);
    history.remember([5, 1, 2]);
    for (const ids of [[5, 4, 3, 4], [3, 4]]) {
      const text = codec.decode(ids);
      expect(history.resolve(text, ids)).toBe(ids);
    }
  });

  test("the longest matching checkpoint wins; canonical histories do not allocate another sequence", () => {
    const history = new GeneratedTokenHistory(codec);
    history.remember([5, 1, 2]);
    history.remember([5, 3, 4]);
    const ids = [5, 3, 4, 4];
    expect(history.resolve(codec.decode(ids), ids)).toBe(ids);
  });

  test("decoder normalization cannot silently alter the appended suffix", () => {
    const history = new GeneratedTokenHistory({ ...codec, encode: () => [2] });
    history.remember([5, 1, 2]);
    const ids = [5, 3, 4];
    expect(history.resolve(codec.decode(ids), ids)).toBe(ids);
  });

  test("retention is bounded and incomplete UTF-8 tails are not reusable boundaries", () => {
    const history = new GeneratedTokenHistory(codec, 100, 1);
    history.remember([5, 1, 2]);
    history.remember([4]);
    const ids = [5, 3, 4];
    expect(history.resolve(codec.decode(ids), ids)).toBe(ids);
    history.remember([5, 1, 2, 6]);
    const invalid = [5, 3, 6, 4];
    expect(history.resolve(codec.decode(invalid), invalid)).toBe(invalid);
    const tiny = new GeneratedTokenHistory(codec, 1);
    tiny.remember([5, 1, 2]);
    expect(tiny.resolve(codec.decode(ids), ids)).toBe(ids);
  });
});
