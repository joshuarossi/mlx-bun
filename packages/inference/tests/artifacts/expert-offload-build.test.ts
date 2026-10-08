import { afterEach, expect, test } from "bun:test";
import { mkdtempSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { buildOffloadFile, ensureOffloadFile } from "../../src/artifacts/expert-offload-build";

const roots: string[] = [];
afterEach(() => { for (const root of roots.splice(0)) rmSync(root, { recursive: true, force: true }); });

/** A single-file safetensors artifact written by hand: F32 tensors, no index. */
function model(tensors: Record<string, number[]>) {
  const dir = mkdtempSync(join(tmpdir(), "mlx-offload-")); roots.push(dir);
  const header: Record<string, unknown> = {};
  const chunks: Uint8Array[] = [];
  let offset = 0;
  for (const [name, values] of Object.entries(tensors)) {
    const bytes = new Uint8Array(Float32Array.from(values).buffer);
    header[name] = { dtype: "F32", shape: [values.length], data_offsets: [offset, offset + bytes.length] };
    chunks.push(bytes); offset += bytes.length;
  }
  const json = new TextEncoder().encode(JSON.stringify(header));
  const length = new Uint8Array(8); new DataView(length.buffer).setBigUint64(0, BigInt(json.length), true);
  writeFileSync(join(dir, "model.safetensors"), Buffer.concat([length, json, ...chunks]));
  return dir;
}

test("expert tensors pack page-aligned in layer order with a manifest the runtime can serve", async () => {
  const dir = model({
    "model.layers.1.mlp.experts.down": [5, 6, 7],
    "model.embed_tokens.weight": [9, 9],
    "model.layers.0.switch_glu.up": [1, 2, 3, 4],
  });
  const messages: string[] = [];
  const manifest = await buildOffloadFile(dir, join(dir, "offload"), message => messages.push(message));
  expect(manifest.page).toBe(16384);
  expect(manifest.model).toBe(dir);
  expect(manifest.tensors.map(entry => entry.name)).toEqual(["model.layers.0.switch_glu.up", "model.layers.1.mlp.experts.down"]);
  for (const entry of manifest.tensors) expect(entry.offset % 16384).toBe(0);
  expect(manifest.tensors.map(entry => [entry.length, entry.dtype, entry.shape])).toEqual([[16, "F32", [4]], [12, "F32", [3]]]);
  expect(manifest.totalBytes).toBe(16384 + 12);
  const bin = readFileSync(join(dir, "offload", "experts.bin"));
  expect(bin.length).toBe(manifest.totalBytes);
  expect(Array.from(new Float32Array(bin.buffer.slice(bin.byteOffset, bin.byteOffset + 16)))).toEqual([1, 2, 3, 4]);
  expect(Array.from(new Float32Array(bin.buffer.slice(bin.byteOffset + 16384, bin.byteOffset + 16384 + 12)))).toEqual([5, 6, 7]);
  expect(JSON.parse(readFileSync(join(dir, "offload", "manifest.json"), "utf8"))).toEqual(manifest);
  expect(messages.at(-1)).toContain("2 tensors, 2 layers");
});

test("ensureOffloadFile reuses a valid file for the same model and rebuilds a stale or foreign one", async () => {
  const dir = model({ "model.layers.0.mlp.experts.w": [1, 2] });
  const messages: string[] = [];
  const first = await ensureOffloadFile(dir, message => messages.push(message));
  expect(first).toBe(join(dir, ".mlx-bun-offload"));
  const built = statSync(join(first, "experts.bin")).mtimeMs;
  messages.length = 0;
  expect(await ensureOffloadFile(dir, message => messages.push(message))).toBe(first);
  expect(messages).toEqual([`reusing ${join(first, "experts.bin")}`]);
  expect(statSync(join(first, "experts.bin")).mtimeMs).toBe(built);
  writeFileSync(join(first, "experts.bin"), new Uint8Array(3));
  messages.length = 0;
  await ensureOffloadFile(dir, message => messages.push(message));
  expect(messages.some(message => message.startsWith("wrote"))).toBe(true);
  expect(statSync(join(first, "experts.bin")).size).toBe(8);
});

test("a dense model has nothing to offload", async () => {
  const dir = model({ "model.layers.0.mlp.down_proj": [1] });
  await expect(buildOffloadFile(dir, join(dir, "offload"))).rejects.toThrow("no expert tensors");
});
