import { expect, test } from "bun:test";
import { tensorFingerprint } from "../../src/model/fingerprint";

test("component identity uses exact tensor bytes and layout, independent of map order", () => {
  const tensor = (value: number, shape = [1], dtype = 9) =>
    ({ shape, dtype, rawBytesView: () => new Uint8Array([value, 0]) });
  const original = tensorFingerprint([["a", tensor(1)], ["b", tensor(2)]]);
  expect(tensorFingerprint([["b", tensor(2)], ["a", tensor(1)]])).toBe(original);
  for (const entries of [
    [["a", tensor(3)], ["b", tensor(2)]],
    [["a", tensor(1, [1, 1])], ["b", tensor(2)]],
    [["a", tensor(1, [1], 10)], ["b", tensor(2)]],
    [["c", tensor(1)], ["b", tensor(2)]],
  ] as const) expect(tensorFingerprint(entries)).not.toBe(original);
});
