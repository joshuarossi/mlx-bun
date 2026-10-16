import { expect, test } from "bun:test";
const native = test.skipIf(process.env.MLX_BUN_TEST_NATIVE !== "1");
native(
  "Metal palette expansion and fp16 projections match MLX across row counts",
  async () => {
    const [{ MlxArray }, { Dtype }, ops, { FiveValueLinear }] =
      await Promise.all([
        import("@mlx-bun/mlx/array"),
        import("@mlx-bun/mlx/ffi"),
        import("@mlx-bun/mlx/ops"),
        import("../src/layers/five-value-linear"),
      ]);
    const width = 128,
      out = 8,
      a = new Uint32Array((out * width) / 16),
      b = new Uint32Array(a.length),
      dense = new Float32Array(out * width);
    for (let n = 0; n < out; n++)
      for (let k = 0; k < width; k++) {
        const code = (n + k) % 3,
          high = k % 4 === 0,
          offset = (n * width) / 16 + (k >>> 4),
          shift = (k % 16) * 2;
        a[offset]! |= code << shift;
        b[offset]! |= (high ? code : 1) << shift;
        dense[n * width + k] = (code - 1) * (high ? 0.75 : 0.25);
      }
    using pa = MlxArray.fromBytesCopy(
      new Uint8Array(a.buffer),
      [out, width / 16],
      Dtype.uint32,
    );
    using pb = MlxArray.fromBytesCopy(
      new Uint8Array(b.buffer),
      [out, width / 16],
      Dtype.uint32,
    );
    using lo = MlxArray.fromFloat32(new Float32Array(out).fill(0.25), [out]);
    using delta = MlxArray.fromFloat32(new Float32Array(out).fill(0.5), [out]);
    const layer = new FiveValueLinear(pa, pb, lo, delta);
    try {
      for (const dtype of [Dtype.float32, Dtype.bfloat16])
        for (const rows of [1, 3, 17]) {
          using values = MlxArray.fromFloat32(
            Float32Array.from({ length: rows * width }, (_, i) =>
              Math.sin(i * 0.2),
            ),
            [rows, width],
          );
          using x = values.astype(dtype);
          using weight = MlxArray.fromFloat32(dense, [out, width]);
          using w = weight.astype(Dtype.float16);
          using wt = ops.transposeAxes(w, [1, 0]);
          using actual = layer.forward(x);
          using hx = x.astype(Dtype.float16);
          using hy = ops.matmul(hx, wt);
          using expected = hy.astype(dtype);
          const got = actual.toFloat32(),
            ref = expected.toFloat32();
          for (let i = 0; i < got.length; i++) expect(got[i]).toBe(ref[i]);
        }
    } finally {
      layer.dispose();
    }
  },
);
native("Metal LSTM gate recurrence matches MLX operations", async () => {
  const [{ MlxArray }, { Dtype }, ops, { LstmCell }] = await Promise.all([
    import("@mlx-bun/mlx/array"),
    import("@mlx-bun/mlx/ffi"),
    import("@mlx-bun/mlx/ops"),
    import("../src/layers/lstm-cell"),
  ]);
  const width = 64;
  for (const dtype of [Dtype.float32, Dtype.bfloat16]) {
    using w0 = MlxArray.fromFloat32(
      Float32Array.from(
        { length: 4 * width * width },
        (_, i) => Math.sin(i) * 0.02,
      ),
      [4 * width, width],
    );
    using w = w0.astype(dtype);
    using b0 = MlxArray.fromFloat32(
      Float32Array.from({ length: 4 * width }, (_, i) => Math.cos(i) * 0.1),
      [4 * width],
    );
    using b = b0.astype(dtype);
    using x0 = MlxArray.fromFloat32(
      Float32Array.from({ length: width }, (_, i) => Math.sin(i)),
      [1, width],
    );
    using x = x0.astype(dtype);
    const cell = new LstmCell(w, w, b);
    try {
      const [h, c] = cell.forward(x, x, x);
      try {
        using wt = ops.transposeAxes(w, [1, 0]);
        using a = ops.addmm(b, x, wt);
        using gates = ops.addmm(a, x, wt);
        using gi = gates.slice([0, 0], [1, width]);
        using gf = gates.slice([0, width], [1, 2 * width]);
        using gg = gates.slice([0, 2 * width], [1, 3 * width]);
        using go = gates.slice([0, 3 * width], [1, 4 * width]);
        using i = ops.sigmoid(gi);
        using f = ops.sigmoid(gf);
        using g = ops.tanh(gg);
        using o = ops.sigmoid(go);
        using keep = ops.mul(f, x);
        using add = ops.mul(i, g);
        using ec = ops.add(keep, add);
        using t = ops.tanh(ec);
        using eh = ops.mul(o, t);
        for (const [actual, expected] of [
          [h, eh],
          [c, ec],
        ]) {
          const got = actual!.toFloat32(),
            ref = expected!.toFloat32();
          for (let n = 0; n < got.length; n++)
            expect(Math.abs(got[n]! - ref[n]!)).toBeLessThan(
              dtype === Dtype.float32 ? 1e-6 : 0.004,
            );
        }
      } finally {
        h.dispose();
        c.dispose();
      }
    } finally {
      cell.dispose();
    }
  }
});

native(
  "Metal TDT commit preserves blanks, caps zero duration and masks the tail",
  async () => {
    const [{ MlxArray }, { Dtype }, ops, { TdtCommitKernel }] =
      await Promise.all([
        import("@mlx-bun/mlx/array"),
        import("@mlx-bun/mlx/ffi"),
        import("@mlx-bun/mlx/ops"),
        import("../src/kernels/tdt-commit"),
      ]);
    const kernel = new TdtCommitKernel();
    const int = (v: number[]) =>
      MlxArray.fromInt32(new Int32Array(v), [v.length]);
    try {
      for (const dtype of [Dtype.float32, Dtype.bfloat16]) {
        using raw = MlxArray.fromFloat32(
          new Float32Array(640).fill(1),
          [1, 640],
        );
        using old = raw.astype(dtype);
        using fresh = ops.zeros([1, 640], dtype);
        using limit = int([10]);
        for (const { token, duration, control, expected, emitted } of [
          {
            token: 7,
            duration: 2,
            control: [3, 5, 0, 3],
            expected: [5, 7, 0, 5],
            emitted: true,
          },
          {
            token: 8192,
            duration: 1,
            control: [3, 5, 0, 3],
            expected: [4, 5, 0, 4],
            emitted: false,
          },
          {
            token: 8192,
            duration: 0,
            control: [3, 5, 9, 3],
            expected: [4, 5, 0, 4],
            emitted: false,
          },
          {
            token: 7,
            duration: 0,
            control: [3, 5, 9, 3],
            expected: [4, 7, 0, 4],
            emitted: true,
          },
          {
            token: 7,
            duration: 4,
            control: [9, 5, 0, 9],
            expected: [13, 7, 0, 9],
            emitted: true,
          },
          {
            token: 7,
            duration: 4,
            control: [13, 5, 0, 9],
            expected: [13, 5, 0, 9],
            emitted: false,
          },
        ]) {
          using pred = int([token]);
          using dur = int([duration]);
          using ctrl = int(control);
          const outputs = kernel.apply([
            pred,
            dur,
            ctrl,
            limit,
            old,
            old,
            old,
            old,
            fresh,
            fresh,
            fresh,
            fresh,
          ]);
          try {
            expect([...outputs[4]!.toIntTokens()]).toEqual(expected);
            expect([...outputs[5]!.toIntTokens()]).toEqual([
              emitted ? token : -1,
              control[0]!,
              duration,
            ]);
            for (const a of outputs.slice(0, 4))
              expect([...a.toFloat32()]).toEqual(
                new Array(640).fill(emitted ? 0 : 1),
              );
          } finally {
            for (const a of outputs) a.dispose();
          }
        }
      }
    } finally {
      kernel.dispose();
    }
  },
);
