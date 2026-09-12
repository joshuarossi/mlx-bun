import { expect, test } from "bun:test";
import { ptr } from "bun:ffi";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { KvWriter, type StoredTensorView } from "../../src/storage/kv-writer";
import type { KvFileHeader } from "../../src/kv-store";

function header(shape: number[], bytes: number): KvFileHeader {
  return { formatVersion: 3, createdAt: 0, tokens: [1], caches: [{ kind: "ssm", offset: 1,
    tensors: [{ off: 0, bytes, shape, dtype: 1, hash: "0".repeat(16) }] }] };
}
function saved(path: string): { header: KvFileHeader; bytes: Uint8Array } {
  const file = readFileSync(path), view = new DataView(file.buffer, file.byteOffset, file.length);
  const length = view.getUint32(10, true), start = view.getUint32(14, true);
  const json = file.subarray(26, 26 + length);
  expect(view.getBigUint64(18, true)).toBe(BigInt(Bun.hash(json)));
  return { header: JSON.parse(json.toString()), bytes: file.subarray(start) };
}

test("CPU writer preserves contiguous, strided, reversed, broadcast, scalar and empty bytes", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-writer-"));
  const writer = new KvWriter(), source = Uint8Array.from({ length: 24 }, (_, i) => i);
  const pointer = ptr(source);
  const cases: Array<{ shape: number[]; strides: number[]; offset?: number; expected: number[] }> = [
    { shape: [2, 3], strides: [3, 1], expected: [0, 1, 2, 3, 4, 5] },
    { shape: [2, 3], strides: [6, 1], expected: [0, 1, 2, 6, 7, 8] },
    { shape: [3, 2], strides: [1, 3], expected: [0, 3, 1, 4, 2, 5] },
    { shape: [4], strides: [-1], offset: 3, expected: [3, 2, 1, 0] },
    { shape: [2, 3], strides: [0, 1], expected: [0, 1, 2, 0, 1, 2] },
    { shape: [], strides: [], offset: 5, expected: [5] },
    { shape: [0], strides: [1], expected: [] },
  ];
  try {
    for (const [i, c] of cases.entries()) {
      const path = join(dir, `${i}.mlxkv`);
      const tensor: StoredTensorView = { pointer: Number(pointer) + (c.offset ?? 0), shape: c.shape, strides: c.strides, itemSize: 1 };
      await writer.write({ path, header: header(c.shape, c.expected.length), tensors: [tensor] });
      const actual = saved(path);
      expect([...actual.bytes]).toEqual(c.expected);
      expect(actual.header.caches[0]!.tensors[0]!.hash).toBe(Bun.hash(actual.bytes).toString(16).padStart(16, "0"));
    }
    expect([...source]).toEqual(Array.from({ length: 24 }, (_, i) => i));
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("SSD writes complete while the calling thread is occupied", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-worker-progress-"));
  const source = new Uint8Array(8 * 1024 * 1024).fill(37), writer = new KvWriter();
  const tensor = { pointer: Number(ptr(source)), shape: [source.length], strides: [1], itemSize: 1 };
  try {
    // Start the worker before occupying the calling thread.
    await writer.write({ path: join(dir, "warm"), header: header(tensor.shape, source.length), tensors: [tensor] });
    const path = join(dir, "background");
    const done = writer.write({ path, header: header(tensor.shape, source.length), tensors: [tensor] });
    const deadline = performance.now() + 3_000;
    while (!existsSync(path) && performance.now() < deadline) { /* no event-loop yield */ }
    const completedWithoutYield = existsSync(path);
    await done;
    expect(completedWithoutYield).toBe(true);
    expect(saved(path).bytes).toEqual(source);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("write failure settles and the worker can write the next entry", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-worker-failure-"));
  const source = new Uint8Array([7]), writer = new KvWriter();
  const tensor = { pointer: Number(ptr(source)), shape: [1], strides: [1], itemSize: 1 };
  try {
    await expect(writer.write({ path: dir, header: header([1], 1), tensors: [tensor] })).rejects.toThrow();
    expect(existsSync(`${dir}.tmp`)).toBe(false);
    const path = join(dir, "ok");
    await writer.write({ path, header: header([1], 1), tensors: [tensor] });
    expect([...saved(path).bytes]).toEqual([...source]);
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

test("compiled executables embed the CPU writer without an external worker file", async () => {
  const dir = mkdtempSync(join(tmpdir(), "kv-writer-compiled-"));
  const entry = join(dir, "entry.ts"), binary = join(dir, "writer"), output = join(dir, "state.mlxkv");
  try {
    writeFileSync(entry, `
      import { ptr } from "bun:ffi";
      import { kvWriter } from ${JSON.stringify(new URL("../../src/storage/kv-writer.ts", import.meta.url).pathname)};
      const source = new Uint8Array([11, 22, 33]);
      await kvWriter.write({ path: process.argv[2], header: ${JSON.stringify(header([3], 3))},
        tensors: [{ pointer: Number(ptr(source)), shape: [3], strides: [1], itemSize: 1 }] });
      console.log(source.length);
    `);
    const build = Bun.spawn([process.execPath, "build", "--compile", entry, "--outfile", binary],
      { stdout: "pipe", stderr: "pipe" });
    const buildError = new Response(build.stderr).text();
    expect(await build.exited, await buildError).toBe(0);
    rmSync(entry);
    const child = Bun.spawn([binary, output], { cwd: dir, stdout: "pipe", stderr: "pipe" });
    const childError = new Response(child.stderr).text();
    expect(await child.exited, await childError).toBe(0);
    expect([...saved(output).bytes]).toEqual([11, 22, 33]);
  } finally { rmSync(dir, { recursive: true, force: true }); }
}, 30_000);
