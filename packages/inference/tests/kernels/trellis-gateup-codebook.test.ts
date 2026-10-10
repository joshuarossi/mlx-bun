import { expect, test } from "bun:test";
import { Dtype, MlxArray, MetalKernel } from "@mlx-bun/mlx";
import { deviceArchitecture } from "@mlx-bun/mlx/ffi";
import { HEADER } from "../../src/kernels/trellis/codebook";
import { fusedGateUpSwiglu, gateUpCodebookEligible } from "../../src/kernels/trellis/gate-up";
import { scatterFloatCodebookEligible } from "../../src/kernels/trellis/scatter";
import type { TrellisGeometry } from "../../src/kernels/trellis/geometry";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime/config";

const geometry: TrellisGeometry = { k: 3, L: 12, T: 256, axis: 1,
  rows: 17408, cols: 5120, inFeatures: 5120, outFeatures: 17408 };
const config = (enabled: boolean) => createRuntimeConfig({ MLX_BUN_TRELLIS_GATEUP_CODEBOOK: enabled ? "1" : "0" });

test("gate/up codebook dispatch stays within its qualified numerical and hardware geometry", () => {
  const eligible = (g = geometry, m = 1, dtype = Dtype.bfloat16, variant = 13, architecture = "applegpu_g13s") =>
    gateUpCodebookEligible(g, m, dtype, variant, architecture);
  for (const k of [2, 3, 4]) expect(eligible({ ...geometry, k })).toBe(true);
  for (const variant of [0, 1, 2, 3, 4, 5, 6, 7, 12]) expect(eligible(geometry, 1, Dtype.bfloat16, variant)).toBe(false);
  for (const m of [2, 3, 4, 5]) expect(eligible(geometry, m)).toBe(false);
  expect(eligible(geometry, 1, Dtype.float32)).toBe(false);
  expect(eligible(geometry, 1, Dtype.bfloat16, 13, "applegpu_g16s")).toBe(false);
  for (const changed of [{ k: 5 }, { L: 13 }, { T: 128 }, { axis: 0 as const },
    { rows: 64, outFeatures: 64 }, { cols: 1024, inFeatures: 1024 }, { blockInterleave: 2 as const }])
    expect(eligible({ ...geometry, ...changed })).toBe(false);
});

test("threadgroup codebook preserves all 4096 unrefined float32 decoded values", () => {
  const kernel = new MetalKernel({ name: "test_trellis_gateup_codebook", inputNames: ["dummy"],
    outputNames: ["baseline", "cached"], header: HEADER, source: String.raw`
      threadgroup float table[4096];
      for (uint i = thread_position_in_threadgroup.x; i < 4096u; i += 512u)
        table[i] = trellis_unrefined_bits_y(trellis_y(i));
      threadgroup_barrier(metal::mem_flags::mem_threadgroup);
      const uint i = thread_position_in_grid.x;
      baseline[i] = trellis_unrefined_y(trellis_y(i));
      cached[i] = table[i];
    ` });
  using dummy = MlxArray.fromFloat32(new Float32Array([0]), [1]);
  try {
    const [inline, cached] = kernel.apply([dummy], { outputs: [
      { shape: [4096], dtype: Dtype.float32 }, { shape: [4096], dtype: Dtype.float32 }],
      grid: [4096, 1, 1], threadGroup: [512, 1, 1] });
    try { expect(Buffer.from(cached!.rawBytes()).equals(Buffer.from(inline!.rawBytes()))).toBe(true); }
    finally { inline!.dispose(); cached!.dispose(); }
  } finally { kernel.dispose(); }
});

test("down float codebook qualifies ordinary K2/K4 and interleaved K3 only on M1", () => {
  const down: TrellisGeometry = { ...geometry, axis: 0, inFeatures: 17408, outFeatures: 5120 };
  for (const k of [2, 3, 4]) {
    const g: TrellisGeometry = { ...down, k, blockInterleave: k === 3 ? 2 : undefined };
    expect(scatterFloatCodebookEligible(g, 1, Dtype.bfloat16, 13, "applegpu_g13s")).toBe(true);
    expect(scatterFloatCodebookEligible(g, 1, Dtype.bfloat16, 13, "applegpu_g16s")).toBe(false);
    expect(scatterFloatCodebookEligible(g, 2, Dtype.bfloat16, 13, "applegpu_g13s")).toBe(false);
    expect(scatterFloatCodebookEligible(g, 1, Dtype.float32, 13, "applegpu_g13s")).toBe(false);
    expect(scatterFloatCodebookEligible(g, 1, Dtype.bfloat16, 12, "applegpu_g13s")).toBe(false);
  }
  expect(scatterFloatCodebookEligible({ ...down, k: 3 }, 1, Dtype.bfloat16, 13, "applegpu_g13s")).toBe(false);
});

test("bit representation matches unrefined conversion for every possible Trellis y", () => {
  const kernel = new MetalKernel({ name: "test_trellis_bits_y", inputNames: ["dummy"],
    outputNames: ["baseline", "represented"], header: HEADER, source: String.raw`
      const uint i = thread_position_in_grid.x;
      const int y = int(i) - 510;
      baseline[i] = trellis_unrefined_y(y);
      represented[i] = trellis_unrefined_bits_y(y);
    ` });
  using dummy = MlxArray.fromFloat32(new Float32Array([0]), [1]);
  try {
    const [baseline, represented] = kernel.apply([dummy], { outputs: [
      { shape: [1021], dtype: Dtype.float32 }, { shape: [1021], dtype: Dtype.float32 }],
      grid: [1021, 1, 1], threadGroup: [128, 1, 1] });
    try { expect(Buffer.from(represented!.rawBytes()).equals(Buffer.from(baseline!.rawBytes()))).toBe(true); }
    finally { baseline!.dispose(); represented!.dispose(); }
  } finally { kernel.dispose(); }
});

test.skipIf(deviceArchitecture() !== "applegpu_g13s")("qualified fused gate/up preserves output bits with independent codes and varied scales", () => {
  for (const k of [2, 3, 4]) {
    const g = { ...geometry, k };
    let seed = 137;
    const makeCodes = () => {
      using signed = MlxArray.fromInt32(Int32Array.from({ length: g.rows * g.cols * k / 32 },
        () => seed = Math.imul(seed, 1664525) + 1013904223), [g.rows, g.cols * k / 32]);
      return signed.astype(Dtype.uint32);
    };
    using gcodes = makeCodes(), ucodes = makeCodes();
    using gs32 = MlxArray.fromFloat32(Float32Array.from({ length: g.rows }, (_, i) => (i % 257 + 1) / 1024), [g.rows]);
    using us32 = MlxArray.fromFloat32(Float32Array.from({ length: g.rows }, (_, i) => (i % 127 + 1) / 512), [g.rows]);
    using gscales = gs32.astype(Dtype.float16), uscales = us32.astype(Dtype.float16);
    const gate = { geometry: g, codes: gcodes, scales: gscales }, up = { geometry: g, codes: ucodes, scales: uscales };
    for (const magnitude of [0.03125, 2]) {
      using raw = MlxArray.fromFloat32(Float32Array.from({ length: g.cols }, (_, i) => Math.sin(i * 0.17) * magnitude), [1, 1, g.cols]);
      using x = raw.astype(Dtype.bfloat16);
      using baseline = withRuntimeConfig(config(false), () => fusedGateUpSwiglu(x, gate, up, 13));
      using candidate = withRuntimeConfig(config(true), () => fusedGateUpSwiglu(x, gate, up, 13));
      expect(candidate.shape).toEqual(baseline.shape);
      expect(Buffer.from(candidate.rawBytes()).equals(Buffer.from(baseline.rawBytes()))).toBe(true);
    }
  }
}, 60_000);
