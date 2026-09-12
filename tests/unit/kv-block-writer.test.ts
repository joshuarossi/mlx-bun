import { expect, test } from "bun:test";
import { ptr } from "bun:ffi";
import { mkdtempSync, readFileSync, readdirSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { KvWriter } from "../../src/storage/kv-writer";
import type { KvFileHeader } from "../../src/kv-store";

function header(shape: number[]): KvFileHeader {
  return { formatVersion: 3, createdAt: 0, tokens: [1], caches: [{ kind: "kv", offset: shape[2]!, tensors: [
    { off: 0, bytes: shape.reduce((a, b) => a * b, 1), dtype: 1, shape, hash: "0".repeat(16) },
  ] }] };
}
function manifest(path: string): KvFileHeader & { dataStart: number } {
  const file = readFileSync(path), view = new DataView(file.buffer, file.byteOffset, file.byteLength);
  return { ...JSON.parse(file.subarray(26, 26 + view.getUint32(10, true)).toString()), dataStart: view.getUint32(14, true) };
}
test("growing heads reuse SSD blocks; packed and segmented bytes restore identically", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-blocks-")), writer = new KvWriter();
  const source = Uint8Array.from({ length: 128 }, (_, i) => i);
  try {
    for (const [name, tokens, segmented] of [["a", 4, true], ["b", 6, true], ["c", 6, false]] as const) {
      const path = join(dir, name + ".mlxkv"), shape = [1, 2, tokens, 4];
      await writer.write({ path, header: header(shape), tensors: [
        { pointer: Number(ptr(source)), shape, strides: [128, 64, 4, 1], itemSize: 1 },
      ], layout: "blocks", blockBytes: 16, segmented });
      const h = manifest(path), output = new Uint8Array(tokens * 8);
      const written = writer.lastMetrics;
      await writer.read({ path, header: h, pointers: [Number(ptr(output))], verify: true });
      expect([...output]).toEqual([...source.slice(0, tokens * 4), ...source.slice(64, 64 + tokens * 4)]);
      if (name === "b") expect(written?.reusedBytes).toBe(32);
      if (name === "c") expect(written?.reusedBytes).toBe(48);
    }
    expect(readdirSync(join(dir, "blocks")).length).toBe(4);
    expect(manifest(join(dir, "b.mlxkv")).caches).toEqual(manifest(join(dir, "c.mlxkv")).caches);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
