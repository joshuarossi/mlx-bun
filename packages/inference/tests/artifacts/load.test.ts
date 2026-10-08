import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Weights } from "@mlx-bun/inference/artifacts";
import { ops } from "@mlx-bun/mlx";

test("native weight loading applies the graph's view and reopens released shards", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-weights-"));
  try {
    const header = Buffer.from(JSON.stringify({ stored: { dtype: "F32", shape: [2], data_offsets: [0, 8] } }).padEnd(80, " "));
    const length = Buffer.alloc(8);
    length.writeBigUInt64LE(BigInt(header.length));
    await Bun.write(join(dir, "model.safetensors"), Buffer.concat([length, header, Buffer.from(new Float32Array([2, 4]).buffer)]));
    const weights = await Weights.open(dir);
    try {
      weights.setView({ names: new Map([["canonical", "stored"]]), fixup: (_, x) => ops.mulScalar(x, 2) });
      expect(weights.tensorNames).toEqual(["canonical"]);
      expect(weights.has("stored")).toBe(false);
      expect([...weights.tensor("canonical").toFloat32()]).toEqual([4, 8]);
      expect(() => weights.setView({ names: new Map() })).toThrow("materialized");
      weights.releaseShard(weights.fileOf("canonical")!);
      expect([...weights.tensor("canonical").toFloat32()]).toEqual([4, 8]);
    } finally { weights.dispose(); }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
