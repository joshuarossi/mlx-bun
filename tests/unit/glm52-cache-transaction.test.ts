import { expect, test } from "bun:test";
import { MLACache } from "../../src/model/glm52-cache";
import { MlxArray } from "../../src/mlx/array";

for (const initial of [0, 1]) for (const dsa of [false, true]) for (const count of [1, 3])
  test(`compressed MLA rollback retains accepted rows (DSA=${dsa}, B=${count}, initial=${initial})`, () => {
    const make = () => new MLACache({ kvLoraRank: 3, ropeHeadDim: 2, maxTokens: 1000,
      ...(dsa ? { dsa: { headDim: 1 } } : { role: "mtp" as const }) });
    const rows = Array.from({ length: count }, make), batch = make();
    const history: number[][] = Array.from({ length: count }, (_, row) => Array.from({ length: row + initial }, (_, n) => row * 100 + n));
    const append = (cache: MLACache, ids: number[][]) => {
      const tensor = (dimension: number) => MlxArray.fromFloat32(Float32Array.from(ids.flatMap(tokens => tokens.flatMap(token =>
        Array.from({ length: dimension }, (_, feature) => token * 10 + feature)))), [ids.length, ids[0]!.length, dimension]);
      using latent = tensor(3), rope = tensor(2), index = dsa ? tensor(1) : null;
      cache.append(latent, rope, index);
    };
    const check = () => {
      expect(batch.rowOffsets).toEqual(history.map(tokens => tokens.length));
      expect(batch.offset).toBe(Math.max(...history.map(tokens => tokens.length)));
      expect(batch.leftPad).toEqual(history.map(tokens => batch.offset - tokens.length));
      for (let row = 0; row < count; row++) {
        const extracted = batch.extractRow(row);
        try {
          if (history[row]!.length === 0) {
            expect(extracted.offset).toBe(0); expect(extracted.state()).toEqual([]); continue;
          }
          for (const [plane, dimension] of [[extracted.latent!, 3], [extracted.rope!, 2],
            ...(dsa ? [[extracted.dsa!.data!, 1] as const] : [])] as const) {
            expect([...plane.toFloat32()]).toEqual(history[row]!.flatMap(token =>
              Array.from({ length: dimension }, (_, feature) => token * 10 + feature)));
          }
        } finally { extracted.dispose(); }
      }
    };
    try {
      for (const [row, cache] of rows.entries()) if (history[row]!.length) append(cache, [history[row]!]);
      batch.mergeRows(rows); check();
      for (let round = 0; round < 20; round++) {
        batch.specRoundBegin();
        const width = 4;
        const proposed = history.map((_, row) => Array.from({ length: width }, (_, position) => 1000 + round * 20 + row * 5 + position));
        append(batch, proposed);
        const accepted = history.map((_, row) => (round + row) % (width + 1));
        batch.specRoundRollback(accepted);
        for (let row = 0; row < count; row++) history[row]!.push(...proposed[row]!.slice(0, accepted[row]));
        check();
      }
      batch.specRoundBegin();
      append(batch, history.map((_, row) => [9000 + row]));
      for (let row = 0; row < count; row++) history[row]!.push(9000 + row);
      batch.specRoundCommit(); check();
      const snapshot = batch.extractRow(count - 1);
      try {
        batch.filterRows([count - 1]);
        expect(batch.state().map(array => [...array.toFloat32()])).toEqual(snapshot.state().map(array => [...array.toFloat32()]));
        expect(batch.rowOffsets).toEqual(snapshot.rowOffsets);
      } finally { snapshot.dispose(); }
    } finally { for (const cache of [...rows, batch]) cache.dispose(); }
  });

for (const dsa of [false, true]) test(`compressed MLA prefill padding preserves valid rows (DSA=${dsa})`, () => {
  const cache = new MLACache({ kvLoraRank: 2, ropeHeadDim: 1, ...(dsa ? { dsa: { headDim: 1 } } : {}) });
  const tensor = (width: number) => MlxArray.fromFloat32(Float32Array.from(
    [1, 2, 3, 99, 99, 4, 5, 6, 7, 8].flatMap(value => Array(width).fill(value))), [2, 5, width]);
  try {
    cache.preparePrefill({ lengths: [3, 5], rightPadding: [2, 0] });
    using latent = tensor(2), rope = tensor(1), index = dsa ? tensor(1) : null;
    cache.append(latent, rope, index);
    // Reordering before finalization must also reorder the valid endpoints.
    cache.filterRows([1, 0]); cache.finalizePrefill();
    expect(cache.rowOffsets).toEqual([5, 3]); expect(cache.leftPad).toEqual([0, 2]);
    for (const [row, expected] of [[0, [4, 5, 6, 7, 8]], [1, [1, 2, 3]]] as const) {
      const extracted = cache.extractRow(row);
      try {
        expect([...extracted.latent!.toFloat32()]).toEqual(expected.flatMap(v => [v, v]));
        expect([...extracted.rope!.toFloat32()]).toEqual([...expected]);
        if (dsa) expect([...extracted.dsa!.data!.toFloat32()]).toEqual([...expected]);
      } finally { extracted.dispose(); }
    }
  } finally { cache.dispose(); }
});

for (const populatedSibling of [false, true]) test(`empty DSA row survives filtering and subsequent append (sibling=${populatedSibling})`, () => {
  const make = () => new MLACache({ kvLoraRank: 2, ropeHeadDim: 1, dsa: { headDim: 1 } });
  const cold = make(), sibling = make(), batch = make();
  const append = (cache: MLACache, value: number) => {
    using latent = MlxArray.fromFloat32(Float32Array.from([value, value + 1]), [1, 1, 2]);
    using rope = MlxArray.fromFloat32(Float32Array.from([value + 2]), [1, 1, 1]);
    using index = MlxArray.fromFloat32(Float32Array.from([value + 3]), [1, 1, 1]);
    cache.append(latent, rope, index);
  };
  try {
    if (populatedSibling) append(sibling, 10);
    batch.mergeRows([cold, sibling]);
    batch.filterRows([0]);
    expect(batch.batchSize).toBe(1); expect(batch.offset).toBe(0);
    expect(batch.rowOffsets).toEqual([0]); expect(batch.leftPad).toEqual([0]);
    expect(batch.dsa!.batchSize).toBe(1); expect(batch.dsa!.offset).toBe(0);
    expect(batch.state().map(array => array.shape)).toEqual([[1, 0, 2], [1, 0, 1], [1, 0, 1]]);
    const empty = batch.extractRow(0);
    try { expect(empty.offset).toBe(0); expect(empty.state()).toEqual([]); }
    finally { empty.dispose(); }
    append(batch, 20);
    expect(batch.rowOffsets).toEqual([1]); expect(batch.dsa!.offset).toBe(1);
    expect(batch.state().map(array => [...array.toFloat32()])).toEqual([[20, 21], [22], [23]]);
    // Rejection can return this live membership to zero tokens too.
    const reset = make();
    try {
      reset.mergeRows([cold]); reset.specRoundBegin(); append(reset, 30);
      reset.specRoundRollback(0); reset.filterRows([0]); append(reset, 40);
      expect(reset.state().map(array => [...array.toFloat32()])).toEqual([[40, 41], [42], [43]]);
    } finally { reset.dispose(); }
  } finally { cold.dispose(); sibling.dispose(); batch.dispose(); }
});
