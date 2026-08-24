import { afterEach, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "../../src/mlx/array";
import * as ops from "../../src/mlx/ops";
import { ColibriGlm52Weights } from "../../src/model/glm52-weights";

const dirs: string[] = [];

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true });
});

function writeTinyShard(
  tensors: Array<{
    name: string;
    dtype: "U8" | "F32";
    shape: number[];
    bytes: Uint8Array;
  }>,
): string {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-weights-"));
  dirs.push(dir);
  writeShard(dir, "out-00000.safetensors", tensors);
  return dir;
}

function writeShard(
  dir: string,
  filename: string,
  tensors: Array<{
    name: string;
    dtype: "U8" | "F32";
    shape: number[];
    bytes: Uint8Array;
  }>,
): string {
  const header: Record<string, unknown> = {};
  let offset = 0;
  for (const tensor of tensors) {
    header[tensor.name] = {
      dtype: tensor.dtype,
      shape: tensor.shape,
      data_offsets: [offset, offset + tensor.bytes.byteLength],
    };
    offset += tensor.bytes.byteLength;
  }
  const encoded = new TextEncoder().encode(JSON.stringify(header));
  const file = new Uint8Array(8 + encoded.byteLength + offset);
  new DataView(file.buffer).setBigUint64(0, BigInt(encoded.byteLength), true);
  file.set(encoded, 8);
  let cursor = 8 + encoded.byteLength;
  for (const tensor of tensors) {
    file.set(tensor.bytes, cursor);
    cursor += tensor.bytes.byteLength;
  }
  const path = join(dir, filename);
  writeFileSync(path, file);
  return path;
}

function f32Bytes(values: number[]): Uint8Array {
  return new Uint8Array(new Float32Array(values).buffer);
}

function expectClose(actual: Float32Array, expected: number[]): void {
  expect(actual.length).toBe(expected.length);
  for (let index = 0; index < expected.length; index++)
    expect(actual[index]!).toBeCloseTo(expected[index]!, 6);
}

function packQ4(rows: number[][]): Uint8Array {
  const out: number[] = [];
  for (const row of rows) {
    for (let index = 0; index < row.length; index += 2)
      out.push((row[index]! + 8) | ((row[index + 1]! + 8) << 4));
  }
  return new Uint8Array(out);
}

describe("direct Colibri GLM-5.2 MLX weights", () => {
  test("opens only shards selected by tensor ownership", () => {
    const dir = mkdtempSync(join(tmpdir(), "mlx-bun-glm52-weights-selected-"));
    dirs.push(dir);
    const first = writeShard(dir, "out-00000.safetensors", [
      { name: "first", dtype: "F32", shape: [1], bytes: f32Bytes([3]) },
    ]);
    writeShard(dir, "out-00001.safetensors", [
      { name: "second", dtype: "F32", shape: [1], bytes: f32Bytes([7]) },
    ]);
    const weights = ColibriGlm52Weights.openSelected(dir, ["first"]);
    try {
      expect(weights.mappedShardCount).toBe(1);
      expect(weights.mappedShardBytes).toBe(statSync(first).size);
      expect(weights.tensor("first").toFloat32()[0]).toBe(3);
      expect(() => weights.tensor("second")).toThrow(/shard .* is not open/);
    } finally {
      weights.dispose();
    }
  });

  test("dequantizes per-row int4 and signed int8 from U8 payloads", () => {
    const q4 = "q4.weight";
    const q8 = "q8.weight";
    const q4Rows = [
      Array.from({ length: 32 }, (_, index) => index % 16 - 8),
      Array.from({ length: 32 }, (_, index) => 7 - index % 16),
    ];
    const dir = writeTinyShard([
      { name: q4, dtype: "U8", shape: [32], bytes: packQ4(q4Rows) },
      { name: `${q4}.qs`, dtype: "F32", shape: [2], bytes: f32Bytes([0.5, 2]) },
      // Signed rows [-128,-1,0,127] and [1,-2,3,-4].
      { name: q8, dtype: "U8", shape: [8], bytes: new Uint8Array([128, 255, 0, 127, 1, 254, 3, 252]) },
      { name: `${q8}.qs`, dtype: "F32", shape: [2], bytes: f32Bytes([0.25, 0.5]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    try {
      const got4 = weights.dequantized(q4, 2, 32);
      const got8 = weights.dequantized(q8, 2, 4);
      try {
        expectClose(got4.toFloat32(), [
          ...q4Rows[0]!.map((value) => value * 0.5),
          ...q4Rows[1]!.map((value) => value * 2),
        ]);
        expectClose(got8.toFloat32(), [-32, -0.25, 0, 31.75, 0.5, -1, 1.5, -2]);
      } finally {
        got4.dispose();
        got8.dispose();
      }
    } finally {
      weights.dispose();
    }
  });

  test("linear follows output-major dequantize-to-f32 MAC", () => {
    const name = "linear.weight";
    const dir = writeTinyShard([
      // Rows [1,2,-1,0], [-2,1,0,3], scale 1.0.
      { name, dtype: "U8", shape: [8], bytes: new Uint8Array([1, 2, 255, 0, 254, 1, 0, 3]) },
      { name: `${name}.qs`, dtype: "F32", shape: [2], bytes: f32Bytes([1, 1]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    const input = MlxArray.fromFloat32(new Float32Array([2, -1, 3, 4]), [1, 4]);
    try {
      const output = weights.linear(input, name, 2, 4);
      try {
        expectClose(output.toFloat32(), [-3, 7]);
      } finally {
        output.dispose();
      }
    } finally {
      input.dispose();
      weights.dispose();
    }
  });

  test("affine Q4 linear matches dequantize-to-f32 MAC", () => {
    const name = "linear-q4.weight";
    const rows = [
      Array.from({ length: 32 }, (_, index) => index % 16 - 8),
      Array.from({ length: 32 }, (_, index) => 7 - index % 16),
    ];
    const dir = writeTinyShard([
      { name, dtype: "U8", shape: [32], bytes: packQ4(rows) },
      { name: `${name}.qs`, dtype: "F32", shape: [2], bytes: f32Bytes([0.5, 2]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    const input = MlxArray.fromFloat32(
      Float32Array.from({ length: 32 }, (_, index) => index / 32 - 0.5),
      [1, 32],
    );
    try {
      const reference = weights.linear(input, name, 2, 32);
      const quantized = weights.linearQ4(input, name, 2, 32);
      try {
        expectClose(quantized.toFloat32(), [...reference.toFloat32()]);
      } finally {
        reference.dispose();
        quantized.dispose();
      }
    } finally {
      input.dispose();
      weights.dispose();
    }
  });

  test("reference embedding gathers the requested dequantized rows", () => {
    const name = "embed.weight";
    const dir = writeTinyShard([
      {
        name,
        dtype: "U8",
        shape: [12],
        bytes: new Uint8Array([
          1, 2, 3, 4,
          255, 0, 2, 254,
          4, 3, 2, 1,
        ]),
      },
      { name: `${name}.qs`, dtype: "F32", shape: [3], bytes: f32Bytes([1, 0.5, 2]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    const ids = ops.fromInt32([2, 0], [1, 2]);
    try {
      const output = weights.embedding(ids, name, 3, 4);
      try {
        expect(output.shape).toEqual([1, 2, 4]);
        expectClose(output.toFloat32(), [8, 6, 4, 2, 1, 2, 3, 4]);
      } finally {
        output.dispose();
      }
    } finally {
      ids.dispose();
      weights.dispose();
    }
  });

  test("bounded embedding gathers rows before signed-int8 dequantization", () => {
    const name = "embed.weight";
    const dir = writeTinyShard([
      {
        name,
        dtype: "U8",
        shape: [12],
        bytes: new Uint8Array([
          1, 2, 3, 4,
          255, 0, 2, 254,
          4, 3, 2, 1,
        ]),
      },
      { name: `${name}.qs`, dtype: "F32", shape: [3], bytes: f32Bytes([1, 0.5, 2]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    const ids = ops.fromInt32([2, 0], [1, 2]);
    try {
      const output = weights.embeddingRows(ids, name, 3, 4);
      try {
        expect(output.shape).toEqual([1, 2, 4]);
        expectClose(output.toFloat32(), [8, 6, 4, 2, 1, 2, 3, 4]);
      } finally {
        output.dispose();
      }
    } finally {
      ids.dispose();
      weights.dispose();
    }
  });

  test("tiled signed-int8 linear matches the reference linear", () => {
    const name = "linear.weight";
    const dir = writeTinyShard([
      {
        name,
        dtype: "U8",
        shape: [12],
        bytes: new Uint8Array([
          1, 2, 255, 0,
          254, 1, 0, 3,
          4, 3, 2, 1,
        ]),
      },
      { name: `${name}.qs`, dtype: "F32", shape: [3], bytes: f32Bytes([1, 1, 0.5]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    const input = MlxArray.fromFloat32(
      new Float32Array([2, -1, 3, 4, 1, 0, -1, 2]),
      [1, 2, 4],
    );
    try {
      const reference = weights.linear(input, name, 3, 4);
      const tiled = weights.linearInt8Tiled(input, name, 3, 4, 1);
      try {
        expect(tiled.shape).toEqual([1, 2, 3]);
        expectClose(tiled.toFloat32(), [...reference.toFloat32()]);
      } finally {
        reference.dispose();
        tiled.dispose();
      }
    } finally {
      input.dispose();
      weights.dispose();
    }
  });

  test("dequantizes grouped int4 at the exact input-group boundary", () => {
    const name = "grouped.weight";
    const row = Array.from({ length: 64 }, (_, index) => index % 16 - 8);
    const dir = writeTinyShard([
      { name, dtype: "U8", shape: [32], bytes: packQ4([row]) },
      { name: `${name}.qs`, dtype: "F32", shape: [2], bytes: f32Bytes([0.25, 2]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    try {
      expect(weights.quantized(name, 1, 64).groupSize).toBe(32);
      const got = weights.dequantized(name, 1, 64);
      try {
        expectClose(got.toFloat32(), row.map((value, index) =>
          value * (index < 32 ? 0.25 : 2)));
      } finally {
        got.dispose();
      }
    } finally {
      weights.dispose();
    }
  });

  test("expands a whole-row Q4 scale over supported MLX groups", () => {
    const name = "per-row-wide.weight";
    const row = Array.from({ length: 64 }, (_, index) => index % 16 - 8);
    const dir = writeTinyShard([
      { name, dtype: "U8", shape: [32], bytes: packQ4([row]) },
      { name: `${name}.qs`, dtype: "F32", shape: [1], bytes: f32Bytes([0.25]) },
    ]);
    const weights = ColibriGlm52Weights.open(dir);
    try {
      expect(weights.quantized(name, 1, 64).groupSize).toBeNull();
      const got = weights.dequantized(name, 1, 64);
      try {
        expectClose(got.toFloat32(), row.map((value) => value * 0.25));
      } finally {
        got.dispose();
      }
    } finally {
      weights.dispose();
    }
  });
});
