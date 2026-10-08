import { expect, test } from "bun:test";
import { MlxArray, gpuStream } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import { activeMemory, clearCache, synchronize } from "@mlx-bun/mlx/ffi";
import { SSMCache } from "../../src/state/ssm";
import { materializeCopy } from "@mlx-bun/mlx/materialize";

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
      // The slack is below one retained conv batch at B=8 (7 x 768 B leaked
      // rows), so a row that still pins its source buffers fails.
      expect(activeMemory() - baseline).toBeLessThanOrEqual(logicalBytes + 4_096);
      expect(saved.offset).toBe(99 + B);
      expect(saved.conv!.toFloat32Host()).toEqual(conv.slice((B - 1) * convRow));
      expect(saved.recurrent!.toFloat32Host()).toEqual(recurrent.slice((B - 1) * recurrentRow));
    } finally { source.dispose(); saved?.dispose(); synchronize(gpuStream); clearCache(); }
  }
});
