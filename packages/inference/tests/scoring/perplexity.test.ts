// Perplexity dataset packing (main's tests/parity/cli-tools.test.ts units): sample
// parsing and the seeded, non-overlapping fixed-length rows. No model.
import { expect, test } from "bun:test";
import { packRows, parseSamples } from "../../src/scoring/perplexity";

test("parseSamples: jsonl text rows, plain text, bad rows", () => {
  expect(parseSamples('{"text":"a"}\n\n{"text":"b"}\n', "d.jsonl")).toEqual(["a", "b"]);
  expect(parseSamples("whole file", "d.txt")).toEqual(["whole file"]);
  expect(parseSamples("", "d.txt")).toEqual([]);
  expect(() => parseSamples('{"messages":[]}', "d.jsonl")).toThrow('{"text"');
  expect(() => parseSamples("not json", "d.jsonl")).toThrow("not valid JSON");
});

test("packRows: non-overlapping fixed rows, sample cap, deterministic seed", () => {
  const samples = Array.from({ length: 10 }, (_, s) => Array.from({ length: 7 }, (_, i) => s * 100 + i));
  const opts = { sequenceLength: 4, numSamples: 5, seed: 123 };
  const rows = packRows(samples, opts), plain = (r: Int32Array[]) => r.map(row => [...row]);
  expect(rows.length).toBe(5);
  for (const r of rows) expect(r.length).toBe(4);
  expect(plain(packRows(samples, opts))).toEqual(plain(rows));
  expect(plain(packRows(samples, { ...opts, seed: 7 }))).not.toEqual(plain(rows));
  // Consecutive cuts of one concatenated stream of whole shuffled samples.
  const flat = rows.flatMap(r => [...r]);
  expect(new Set(flat).size).toBe(flat.length);
  expect(flat.slice(0, 7).every((t, i) => t === flat[0]! + i)).toBe(true);
  // -1 keeps every full row: 70 tokens → 17 rows of 4; too few tokens → none.
  expect(packRows(samples, { ...opts, numSamples: -1 }).length).toBe(17);
  expect(packRows([[1, 2, 3]], opts)).toEqual([]);
});
