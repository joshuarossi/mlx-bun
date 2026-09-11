import { expect, test } from "bun:test";
import { createHash } from "node:crypto";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { RotatingQuantizedKVCache, disposeTriple } from "../../src/model/gemma4-base";
import { SpeculativeRotatingAffineLayout as RotatingAffineLayout } from "../../src/model/rotating-kv-layout";

const dimensions = 64, window = 8;
const data = (rows: readonly number[][]) => MlxArray.fromFloat32(Float32Array.from(rows.flatMap(tokens =>
  tokens.flatMap(token => Array.from({ length: dimensions }, (_, d) => Math.sin(token * 0.17 + d * 0.31))))),
  [rows.length, 1, rows[0]!.length, dimensions]);
const hash = (array: MlxArray) => {
  using contiguous = ops.contiguous(array);
  return createHash("sha256").update(contiguous.rawBytesView()).digest("hex");
};

test("affine ring rollback preserves encoded bytes across unequal acceptance, wrap and retirement", () => {
  for (const bits of [4, 8]) for (const initial of [[0, 0, 0], [0, 5, 7], [9, 15, 21]]) {
    const history = initial.map((n, row) => Array.from({ length: n }, (_, i) => row * 1000 + i));
    const cache = new RotatingAffineLayout(window, 64, bits);
    const sources = history.map(tokens => {
      const source = new RotatingQuantizedKVCache(window, 64, bits);
      if (tokens.length) {
        using input = data([tokens]);
        for (const plane of source.updateAndFetchQuantized(input, input)) disposeTriple(plane);
      }
      return source;
    });
    try { cache.mergeRows(sources); } finally { for (const source of sources) source.dispose(); }
    const verify = (value: RotatingAffineLayout) => {
      for (let row = 0; row < history.length; row++) {
        const extracted = value.extractRow(row) as RotatingQuantizedKVCache;
        try {
          expect(extracted.offset).toBe(history[row]!.length);
          if (!history[row]!.length) { expect(extracted.state().every(array => array.nbytes === 0)).toBe(true); continue; }
          using input = data([history[row]!.slice(-window)]);
          const expected = ops.quantize(input, 64, bits);
          try {
            expect(extracted.keys!.packed.shape[2]).toBe(Math.min(window, history[row]!.length));
            for (const field of ["packed", "scales", "biases"] as const) {
              expect(hash(extracted.keys![field])).toBe(hash(expected[field]));
              expect(hash(extracted.values![field])).toBe(hash(expected[field]));
            }
          } finally { disposeTriple(expected); }
        } finally { extracted.dispose(); }
      }
    };
    try {
      verify(cache);
      for (let step = 0; step < 16; step++) {
        const counts = [1 + step % 4, 1 + (step * 3) % 4, 1 + (step * 7 + 2) % 4];
        const block = history.map((row, index) => Array.from({ length: 4 }, (_, i) => index * 1000 + row.length + i));
        cache.specRoundBegin();
        using input = data(block);
        for (const plane of cache.quantizedAttention!.updateAndFetchQuantized(input, input)) disposeTriple(plane);
        cache.specRoundRollback(counts);
        for (let row = 0; row < history.length; row++) history[row]!.push(...block[row]!.slice(0, counts[row]!));
        verify(cache);
        const clone = new RotatingAffineLayout(window, 64, bits);
        try { clone.mergeRows([cache]); verify(clone); } finally { clone.dispose(); }
      }
      cache.filterRows([2, 0]); history.splice(0, 3, history[2]!, history[0]!); verify(cache);
    } finally { cache.dispose(); }
  }
});
