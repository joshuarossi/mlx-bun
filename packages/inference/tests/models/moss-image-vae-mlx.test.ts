// New MLX dtype/ownership checks. Keep the historical CPU-oracle tests and
// their bounds intact; these do not replace those reports or acceptance work.
import { expect, test, spyOn } from "bun:test";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { WeightsView } from "../../src/artifacts/weights";
import { MossSilu } from "../../src/models/moss-image/layers";
import { Flux2Conv2d, Flux2LatentDenormalization, Flux2Pixels } from "../../src/models/moss-image/vae-layers";
import { Flux2VaeDecoder, parseFlux2VaeConfig } from "../../src/models/moss-image/vae";
import { Flux2VaeWeights, type Flux2VaeWeightSource } from "../../src/models/moss-image/vae-weights";

/** Tiny shard owner with the same raw-buffer retention as Weights. */
function sourceOf(entries: [string, string, MlxArray][], failName?: string) {
  let view: WeightsView | undefined;
  const cached = new Map<string, MlxArray>();
  const raw = new Map(entries.map(([name, file, tensor]) => [name, { file, tensor }]));
  const released: string[] = [];
  let disposals = 0;
  const source: Flux2VaeWeightSource = {
    tensorNames: entries.map(([name]) => name),
    setView(next) { view = next; },
    fileOf(name) { return raw.get(name)?.file; },
    tensor(name) {
      if (name === failName) throw new Error("injected tensor failure");
      const value = raw.get(name)!.tensor;
      if (!cached.has(name)) cached.set(name, view?.fixup?.(name, value) ?? value);
      return cached.get(name)!;
    },
    releaseShard(file) {
      released.push(file);
      for (const [name, entry] of raw) if (entry.file === file) {
        cached.get(name)?.dispose(); cached.delete(name);
        entry.tensor.dispose(); raw.delete(name);
      }
    },
    dispose() {
      disposals++;
      for (const array of cached.values()) array.dispose();
      for (const entry of raw.values()) entry.tensor.dispose();
      cached.clear(); raw.clear();
    },
  };
  return { source, released, get disposals() { return disposals; } };
}

test("VAE bf16 owners survive release of both cached casts and float32 shard sources", () => {
  const input = MlxArray.fromFloat32(new Float32Array([1, 1.25, -2]), [3]);
  const ignored = MlxArray.fromFloat32(new Float32Array([99]), [1]);
  const fixture = sourceOf([["bn.running_mean", "a", input], ["encoder.unused", "b", ignored]]);
  const owned = Flux2VaeWeights.from(fixture.source);
  try {
    expect(fixture.released).toEqual(["a"]);
    expect(fixture.disposals).toBe(1);
    expect(() => input.handle).toThrow("MlxArray used after dispose");
    expect(() => ignored.handle).toThrow("MlxArray used after dispose");
    expect(owned.tensors.size).toBe(1);
    expect(owned.tensor("bn.running_mean").dtype).toBe(Dtype.bfloat16);
    expect(Array.from(owned.tensor("bn.running_mean").toFloat32())).toEqual([1, 1.25, -2]);
  } finally { owned.dispose(); }
});

test("a failed cast-source read closes its shard and the whole consumed source", () => {
  const a = MlxArray.fromFloat32(new Float32Array([1]), [1]);
  const b = MlxArray.fromFloat32(new Float32Array([2]), [1]);
  const fixture = sourceOf([["bn.running_mean", "a", a], ["bn.running_var", "b", b]], "bn.running_var");
  const evaluated: MlxArray[] = [];
  const original = MlxArray.prototype.eval;
  const evaluation = spyOn(MlxArray.prototype, "eval").mockImplementation(function (this: MlxArray) {
    evaluated.push(this);
    return original.call(this);
  });
  try {
    expect(() => Flux2VaeWeights.from(fixture.source)).toThrow("injected tensor failure");
    expect(fixture.released).toEqual(["a", "b"]);
    expect(fixture.disposals).toBe(1);
    expect(evaluated).toHaveLength(1);
    expect(() => evaluated[0]!.handle).toThrow("MlxArray used after dispose");
  } finally { evaluation.mockRestore(); }
});

test("partial VAE construction frees its cast buffers, constructed layers and one compiled SiLU", () => {
  const entries: [string, string, MlxArray][] = [
    ["bn.running_mean", "a", MlxArray.fromFloat32(new Float32Array(128), [128])],
    ["bn.running_var", "a", MlxArray.fromFloat32(new Float32Array(128).fill(1), [128])],
    ["post_quant_conv.weight", "a", MlxArray.fromFloat32(new Float32Array(32 * 32), [32, 32, 1, 1])],
    ["post_quant_conv.bias", "a", MlxArray.fromFloat32(new Float32Array(32), [32])],
  ];
  const fixture = sourceOf(entries);
  const disposal = spyOn(MossSilu.prototype, "dispose");
  const convDisposal = spyOn(Flux2Conv2d.prototype, "dispose");
  const denormDisposal = spyOn(Flux2LatentDenormalization.prototype, "dispose");
  const detached: MlxArray[] = [];
  const original = MlxArray.prototype.eval;
  const evaluation = spyOn(MlxArray.prototype, "eval").mockImplementation(function (this: MlxArray) {
    detached.push(this);
    return original.call(this);
  });
  try {
    expect(() => new Flux2VaeDecoder(fixture.source, parseFlux2VaeConfig({}))).toThrow("missing VAE weight decoder.conv_in.weight");
    // Non-vacuous: precision conversion, denormalization and a convolution
    // were all constructed before the deliberately absent conv_in was read.
    expect(detached).toHaveLength(4);
    for (const buffer of detached) expect(() => buffer.handle).toThrow("MlxArray used after dispose");
    expect(convDisposal).toHaveBeenCalledTimes(1);
    expect(denormDisposal).toHaveBeenCalledTimes(1);
    expect(disposal).toHaveBeenCalledTimes(1);
    expect(fixture.released).toEqual(["a"]);
    expect(fixture.disposals).toBe(1);
  } finally {
    evaluation.mockRestore(); denormDisposal.mockRestore(); convDisposal.mockRestore(); disposal.mockRestore();
  }
});

test("VAE pixels borrow raw bf16 NHWC, normalize before widening, and return uint8", () => {
  // 5/256 produces 129 after bf16 normalization; widening first produces 130.
  using values = MlxArray.fromFloat32(new Float32Array([-2, -1, -0.5, -1 / 128, 0, 0.5, 1, 2, 5 / 256]), [1, 1, 3, 3]);
  using raw = values.astype(Dtype.bfloat16);
  const before = raw.rawBytes().slice();
  using pixels = new Flux2Pixels().forward(raw);
  expect(pixels.shape).toEqual([1, 1, 3, 3]);
  expect(pixels.dtype).toBe(Dtype.uint8);
  using stored = ops.contiguous(pixels);
  expect(Array.from(stored.rawBytes())).toEqual([0, 0, 64, 127, 128, 191, 255, 255, 129]);
  expect(raw.rawBytes()).toEqual(before);
  using ties = MlxArray.fromFloat32(new Float32Array([126.5, 127.5, 128.5]), [3]);
  using rounded = ops.round(ties);
  expect(Array.from(rounded.toFloat32())).toEqual([126, 128, 128]);
});
