import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";

const VALUES = new Float32Array([
  0,
  -0,
  1,
  -1.5,
  Math.PI,
  -123.75,
  2 ** -20,
  65504,
  Infinity,
  -Infinity,
]);

describe("MlxArray host float readback", () => {
  for (const dtype of [Dtype.float32, Dtype.float16, Dtype.bfloat16]) {
    test(`${dtype} matches MLX float32 cast exactly`, () => {
      const source = MlxArray.fromFloat32(VALUES, [VALUES.length]);
      const array = dtype === Dtype.float32 ? source : source.astype(dtype);
      const expected = array.toFloat32();
      const actual = array.toFloat32Host();

      expect([...actual]).toEqual([...expected]);

      if (array !== source) array.dispose();
      source.dispose();
    });
  }

  test("rejects non-floating dtypes instead of silently queueing a cast", () => {
    const bytes = new Uint8Array(new Uint32Array([1, 7, 123_456]).buffer);
    const array = MlxArray.fromBytesCopy(bytes, [3], Dtype.uint32);
    expect(array.toIntTokens()).toEqual([1, 7, 123_456]);
    expect(() => array.toFloat32Host()).toThrow("unsupported dtype uint32");
    array.dispose();
  });
});
