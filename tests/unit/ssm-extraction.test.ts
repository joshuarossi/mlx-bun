import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { activeMemory, clearCache, synchronize } from "../../src/mlx/ffi";
import { SSMCache } from "../../src/model/qwen3-delta";
import { materializeCopy } from "../../src/mlx/materialize";

test("retaining a recurrent row releases unrelated batch storage and preserves every value", () => {
  // Account for the compact-copy helper's process-lifetime scalar before the
  // allocation baseline. Native allocator pages may round the two row buffers.
  { using a = MlxArray.fromFloat32(new Float32Array([1]), [1]);
    using b = materializeCopy(a); ops.evalAll([b]); }
  synchronize(gpuStream); clearCache();
  for (const B of [1, 2, 4, 8]) {
    const source = new SSMCache(); let saved: SSMCache | undefined;
    const convRow = 3 * 64, recurrentRow = 2 * 256 * 256;
    const values = (perRow: number) => Float32Array.from({ length: B * perRow }, (_, i) =>
      Math.floor(i / perRow) + (i % 127) / 128);
    const conv = values(convRow), recurrent = values(recurrentRow);
    const baseline = activeMemory();
    try {
      source.conv = MlxArray.fromFloat32(conv, [B, 3, 64]);
      source.recurrent = MlxArray.fromFloat32(recurrent, [B, 2, 256, 256]);
      source.offsets = Array.from({ length: B }, (_, i) => 100 + i); source.offset = 99 + B;
      ops.evalAll(source.state());
      saved = source.extractRow(B - 1); ops.evalAll(saved.state()); synchronize(gpuStream);
      source.dispose(); clearCache();
      const logicalBytes = saved.state().reduce((bytes, a) => bytes + a.nbytes, 0);
      expect(activeMemory() - baseline).toBeLessThanOrEqual(logicalBytes + 16_384);
      expect(saved.offset).toBe(99 + B);
      expect(saved.conv!.toFloat32Host()).toEqual(conv.slice((B - 1) * convRow));
      expect(saved.recurrent!.toFloat32Host()).toEqual(recurrent.slice((B - 1) * recurrentRow));
    } finally { source.dispose(); saved?.dispose(); synchronize(gpuStream); clearCache(); }
  }
});
