import { afterEach, expect, test } from "bun:test";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { checkpointWords, packedRows } from "./checkpoint-words.ts";

const temporary: string[] = [];
afterEach(async () => {
  for (const directory of temporary.splice(0)) await rm(directory, { recursive: true });
});

async function fixture(offsets = [0, 8]) {
  const directory = await mkdtemp(join(tmpdir(), "mlx-proof-words-"));
  temporary.push(directory);
  const header = new TextEncoder().encode(JSON.stringify({ value: { dtype: "BF16", shape: [2, 2], data_offsets: offsets } }));
  const content = new Uint8Array(8 + header.length + 8);
  new DataView(content.buffer).setBigUint64(0, BigInt(header.length), true);
  content.set(header, 8);
  // Positive zero, negative zero, infinity, and a NaN payload must remain
  // raw words. Numerical acceptance belongs to the Lean certificate.
  content.set([0, 0, 0, 128, 128, 127, 193, 127], 8 + header.length);
  await Bun.write(join(directory, "part.safetensors"), content);
  await Bun.write(join(directory, "model.safetensors.index.json"), JSON.stringify({ weight_map: { value: "part.safetensors" } }));
  return checkpointWords(directory);
}

test("attachment preserves exact little-endian words without float conversion", async () => {
  const words = await fixture();
  expect(await words("value", "BF16", [2, 2])).toEqual([0, 0x8000, 0x7f80, 0x7fc1]);
});

test("attachment rejects dtype, shape, and payload length mismatches", async () => {
  const words = await fixture();
  await expect(words("value", "F16", [2, 2])).rejects.toThrow("Unexpected layout");
  await expect(words("value", "BF16", [4])).rejects.toThrow("Unexpected layout");
  const truncated = await fixture([0, 10]);
  await expect(truncated("value", "BF16", [2, 2])).rejects.toThrow("Unexpected layout");
});

test("packed chunks preserve first-word-low digit order and layer separation", () => {
  const { dictionary, chunks } = packedRows([
    Array.from({ length: 32 }, (_, i) => i % 2 ? 0x8000 : 0),
    Array.from({ length: 32 }, (_, i) => i % 2 ? 0 : 0x8000),
  ]);
  expect(dictionary).toEqual([0, 0x8000]);
  expect(chunks).toEqual(["  [\n    0xaaaaaaaa\n  ]", "  [\n    0x55555555\n  ]"]);
});

test("singleton dictionaries and incomplete chunks are handled explicitly", () => {
  expect(packedRows([Array(32).fill(0x3f80)]).chunks).toEqual(["  [\n    0x0\n  ]"]);
  expect(() => packedRows([[1, 2]])).toThrow("complete 32-word chunks");
  expect(() => packedRows([])).toThrow("Empty dictionary");
});
