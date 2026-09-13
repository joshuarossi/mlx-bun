import { expect, test } from "bun:test";
import { gpuStream } from "../../src/mlx/array";
import { activeMemory, clearCache, Dtype, synchronize } from "../../src/mlx/ffi";
import { arange } from "../../src/mlx/ops";

function liveBytes(): number {
  synchronize(gpuStream);
  clearCache();
  return activeMemory();
}

test("empty integer ranges do not require a host-buffer FFI pointer", () => {
  for (const [start, stop, step] of [[0, 0, 1], [10, 0, 1], [0, 10, -1]]) {
    using range = arange(start!, stop!, step!, Dtype.int32);
    range.eval();
    expect(range.shape).toEqual([0]);
    expect(range.dtype).toBe(Dtype.int32);
    expect(range.nbytes).toBe(0);
  }
});

test("large native position ranges survive JIT tier-up and preserve integer conversion boundaries", () => {
  for (let round = 0; round < 120; round++) {
    for (const [start, stop, step] of [
      [0, 65537 + round, 1], [0, 65536.25, 1],
      [2147413640, 2147483647, 1], [2147483640, 2147483657, 1],
      [-2147483655, -2147483630, 2], [-17, 31, 2], [19, -31, -3],
    ]) {
      using range = arange(start!, stop!, step!, Dtype.int32);
      const length = Math.max(0, Math.ceil((stop! - start!) / step!));
      expect(range.shape).toEqual([length]);
      const expected = Int32Array.from({ length }, (_, i) => start! + i * step!);
      expect(range.toIntTokens()).toEqual([...expected]);
    }
  }
}, 30_000);

test("growing long-context masks release old ranges while reusing the vocabulary range", () => {
  const vocabSize = 262144;
  { using vocab = arange(0, vocabSize, 1, Dtype.int32); vocab.eval(); }
  const baseline = liveBytes();
  // Each step changes the attention range, as a speculative decode round
  // does. The old process-lifetime cache retained over 75 MiB here even
  // though every caller disposed its array. No GC is needed for release.
  for (let i = 0; i < 256; i++) {
    using mask = arange(0, 77077 + 3 * i, 1, Dtype.int32);
    using vocab = arange(0, vocabSize, 1, Dtype.int32);
    mask.eval();
    vocab.eval();
  }
  expect(liveBytes() - baseline).toBeLessThan(16 * 1024 * 1024);
  const beforeHit = liveBytes();
  using vocab = arange(0, vocabSize, 1, Dtype.int32);
  vocab.eval();
  expect(liveBytes()).toBe(beforeHit);
});

test("evicting a range preserves outstanding lazy views and exact range values", () => {
  const length = 70001;
  using ascending = arange(-17, -17 + 2 * length, 2, Dtype.int32);
  using descending = arange(19, 19 - 3 * length, -3, Dtype.float32);
  // Leave both views unevaluated until their cache owners are evicted.
  for (let i = 0; i < 128; i++) {
    using mask = arange(0, 90000 + i, 1, Dtype.int32);
    mask.eval();
  }
  expect(ascending.dtype).toBe(Dtype.int32);
  expect(descending.dtype).toBe(Dtype.float32);
  expect(ascending.toIntTokens()).toEqual(Array.from({ length }, (_, i) => -17 + 2 * i));
  expect([...descending.toFloat32Host()]).toEqual(Array.from({ length }, (_, i) => 19 - 3 * i));
  using rebuilt = arange(-17, -17 + 2 * length, 2, Dtype.int32);
  expect(rebuilt.toIntTokens()).toEqual(ascending.toIntTokens());
});

test("a single oversized range is released when its caller disposes it", () => {
  const baseline = liveBytes();
  for (let i = 0; i < 3; i++) {
    using range = arange(i, i + 3 * 1024 * 1024, 1, Dtype.int32);
    range.eval();
  }
  expect(liveBytes() - baseline).toBeLessThan(1024 * 1024);
});
