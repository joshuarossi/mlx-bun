// FastConformer math adapted from mlx-audio 0.4.6 (MIT), conformer.py and
// attention.py. The layers bind their operations at construction.
import { CompiledFunction } from "@mlx-bun/mlx/compile";
import { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { Phonon2Weights } from "../artifacts/phonon2";
import { RelativePositionKernel } from "../kernels/relative-position";
import { FiveValueLinear } from "./five-value-linear";
import { DenseLinear } from "./dense-linear";
import { LayerNorm } from "./layer-norm";

function packed(w: Phonon2Weights, name: string): FiveValueLinear {
  const p = w.fiveValue(name);
  try {
    return new FiveValueLinear(p.base, p.residual, p.lo, p.delta);
  } finally {
    for (const a of Object.values(p)) a.dispose();
  }
}
function norm(w: Phonon2Weights, name: string): LayerNorm {
  return new LayerNorm(
    w.tensor(name + ".weight"),
    w.tensor(name + ".bias"),
    1e-5,
  );
}
function dense(w: Phonon2Weights, name: string): DenseLinear {
  return new DenseLinear(w.tensor(name + ".weight"), w.tensor(name + ".bias"));
}

export class PhononSubsampling {
  readonly #convs: {
    w: MlxArray;
    b: MlxArray;
    stride: [number, number];
    groups: number;
    padding: [number, number];
    relu: boolean;
  }[];
  readonly #out: DenseLinear;
  constructor(w: Phonon2Weights) {
    this.#convs = [0, 2, 3, 5, 6].map((i) => {
      const p = `encoder.subsampling.layers.${i}`,
        depth = i === 2 || i === 5,
        point = i === 3 || i === 6;
      return {
        w: w.tensor(p + ".weight", [0, 2, 3, 1]),
        b: w.tensor(p + ".bias"),
        stride: point ? [1, 1] : [2, 2],
        groups: depth ? 256 : 1,
        padding: point ? [0, 0] : [1, 1],
        relu: i === 0 || point,
      };
    });
    this.#out = dense(w, "encoder.subsampling.linear");
  }
  forward(mel: MlxArray): MlxArray {
    let x = ops.expandDims(mel, -1);
    try {
      for (const c of this.#convs) {
        using conv = ops.conv2d(x, c.w, c.stride, c.padding, [1, 1], c.groups);
        const next = ops.add(conv, c.b);
        x.dispose();
        x = next;
        if (c.relu) {
          using zero = ops.scalarLike(0, x);
          const act = ops.maximum(x, zero);
          x.dispose();
          x = act;
        }
      }
      // NeMo flattens channel before frequency, despite NHWC convolution.
      using ordered = ops.transposeAxes(x, [0, 1, 3, 2]);
      using flat = ops.reshape(ordered, [
        1,
        x.shape[1]!,
        x.shape[2]! * x.shape[3]!,
      ]);
      return this.#out.forward(flat);
    } finally {
      x.dispose();
    }
  }
  dispose(): void {
    this.#out.wT.dispose();
  }
}
class PhononFeedForward {
  readonly #norm: LayerNorm;
  readonly #up: FiveValueLinear;
  readonly #down: FiveValueLinear;
  constructor(w: Phonon2Weights, p: string, number: number) {
    try {
      this.#norm = norm(w, `${p}.norm_feed_forward${number}`);
      this.#up = packed(w, `${p}.feed_forward${number}.linear1`);
      this.#down = packed(w, `${p}.feed_forward${number}.linear2`);
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  get weightBytes(): number {
    return this.#up.weightBytes + this.#down.weightBytes;
  }
  forward(x: MlxArray): MlxArray {
    using n = this.#norm.forward(x);
    using up = this.#up.forward(n);
    using act = ops.silu(up);
    using down = this.#down.forward(act);
    using half = ops.scalarLike(0.5, down);
    using scaled = ops.mul(down, half);
    return ops.add(x, scaled);
  }
  dispose(): void {
    this.#up?.dispose();
    this.#down?.dispose();
  }
}
class PhononRelativeAttention {
  readonly #norm: LayerNorm;
  readonly #q: FiveValueLinear;
  readonly #k: FiveValueLinear;
  readonly #v: FiveValueLinear;
  readonly #out: FiveValueLinear;
  readonly #pos: FiveValueLinear;
  readonly #u: MlxArray;
  readonly #biasV: MlxArray;
  constructor(w: Phonon2Weights, p: string) {
    try {
      this.#norm = norm(w, p + ".norm_self_att");
      this.#q = packed(w, p + ".self_attn.q_proj");
      this.#k = packed(w, p + ".self_attn.k_proj");
      this.#v = packed(w, p + ".self_attn.v_proj");
      this.#out = packed(w, p + ".self_attn.o_proj");
      this.#pos = packed(w, p + ".self_attn.relative_k_proj");
      this.#u = w.tensor(p + ".self_attn.bias_u");
      this.#biasV = w.tensor(p + ".self_attn.bias_v");
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  get weightBytes(): number {
    return [this.#q, this.#k, this.#v, this.#out, this.#pos].reduce(
      (n, p) => n + p.weightBytes,
      0,
    );
  }
  forward(x: MlxArray, positions: MlxArray): MlxArray {
    const t = x.shape[1]!,
      posLen = positions.shape[1]!;
    using n = this.#norm.forward(x);
    using q = this.#q.forward(n);
    using k = this.#k.forward(n);
    using v = this.#v.forward(n);
    using p = this.#pos.forward(positions);
    using qr = ops.reshape(q, [1, t, 8, 128]);
    using qu = ops.add(qr, this.#u);
    using qv = ops.add(qr, this.#biasV);
    using qut = ops.transposeAxes(qu, [0, 2, 1, 3]);
    using qvt = ops.transposeAxes(qv, [0, 2, 1, 3]);
    using kr = ops.reshape(k, [1, t, 8, 128]);
    using kt = ops.transposeAxes(kr, [0, 2, 1, 3]);
    using vr = ops.reshape(v, [1, t, 8, 128]);
    using vt = ops.transposeAxes(vr, [0, 2, 1, 3]);
    using pr = ops.reshape(p, [1, posLen, 8, 128]);
    using pt = ops.transposeAxes(pr, [0, 2, 3, 1]);
    using bd = ops.matmul(qvt, pt);
    using padded = ops.pad(bd, [
      [0, 0],
      [0, 0],
      [0, 0],
      [1, 0],
    ]);
    using reshaped = ops.reshape(padded, [1, 8, posLen + 1, t]);
    using shifted = reshaped.slice([0, 0, 1, 0], [1, 8, posLen + 1, t]);
    using restored = ops.reshape(shifted, [1, 8, t, posLen]);
    using trimmed = restored.slice([0, 0, 0, 0], [1, 8, t, t]);
    using scale = ops.scalarLike(128 ** -0.5, trimmed);
    using bias = ops.mul(trimmed, scale);
    using attended = ops.sdpa(qut, kt, vt, 128 ** -0.5, "array", bias);
    using transposed = ops.transposeAxes(attended, [0, 2, 1, 3]);
    using flat = ops.reshape(transposed, [1, t, 1024]);
    using projected = this.#out.forward(flat);
    return ops.add(x, projected);
  }
  dispose(): void {
    for (const p of [this.#q, this.#k, this.#v, this.#out, this.#pos])
      p?.dispose();
  }
}
class PhononConvolution {
  readonly #norm: LayerNorm;
  readonly #up: FiveValueLinear;
  readonly #down: FiveValueLinear;
  readonly #conv: MlxArray;
  readonly #mean: MlxArray;
  readonly #var: MlxArray;
  readonly #gain: MlxArray;
  readonly #bias: MlxArray;
  constructor(w: Phonon2Weights, p: string) {
    try {
      this.#norm = norm(w, p + ".norm_conv");
      this.#up = packed(w, p + ".conv.pointwise_conv1");
      this.#down = packed(w, p + ".conv.pointwise_conv2");
      this.#conv = w.tensor(p + ".conv.depthwise_conv.weight", [0, 2, 1]);
      this.#mean = w.tensor(p + ".conv.norm.running_mean");
      this.#var = w.tensor(p + ".conv.norm.running_var");
      this.#gain = w.tensor(p + ".conv.norm.weight");
      this.#bias = w.tensor(p + ".conv.norm.bias");
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  get weightBytes(): number {
    return this.#up.weightBytes + this.#down.weightBytes;
  }
  forward(x: MlxArray): MlxArray {
    const t = x.shape[1]!;
    using n = this.#norm.forward(x);
    using up = this.#up.forward(n);
    using a = up.slice([0, 0, 0], [1, t, 1024]);
    using b = up.slice([0, 0, 1024], [1, t, 2048]);
    using gate = ops.sigmoid(b);
    using glu = ops.mul(a, gate);
    using conv = ops.conv1d(glu, this.#conv, 1, 4, 1, 1024);
    using eps = ops.scalarLike(1e-5, this.#var);
    using v = ops.add(this.#var, eps);
    using inv = ops.rsqrt(v);
    using centered = ops.sub(conv, this.#mean);
    using scaled = ops.mul(centered, inv);
    using weighted = ops.mul(scaled, this.#gain);
    using normed = ops.add(weighted, this.#bias);
    using act = ops.silu(normed);
    using down = this.#down.forward(act);
    return ops.add(x, down);
  }
  dispose(): void {
    this.#up?.dispose();
    this.#down?.dispose();
  }
}
/** One FastConformer block. Every input is borrowed and every output owned. */
export class PhononConformerBlock {
  readonly #ff1: PhononFeedForward;
  readonly #attention: PhononRelativeAttention;
  readonly #conv: PhononConvolution;
  readonly #ff2: PhononFeedForward;
  readonly #norm: LayerNorm;
  readonly #compiled: CompiledFunction;
  constructor(w: Phonon2Weights, index: number) {
    try {
      const p = `encoder.layers.${index}`;
      this.#ff1 = new PhononFeedForward(w, p, 1);
      this.#attention = new PhononRelativeAttention(w, p);
      this.#conv = new PhononConvolution(w, p);
      this.#ff2 = new PhononFeedForward(w, p, 2);
      this.#norm = norm(w, p + ".norm_out");
      this.#compiled = new CompiledFunction(
        ([x, pos]) => [this.#forward(x!, pos!)],
        false,
      );
    } catch (error) {
      this.dispose();
      throw error;
    }
  }
  get weightBytes(): number {
    return (
      this.#ff1.weightBytes +
      this.#attention.weightBytes +
      this.#conv.weightBytes +
      this.#ff2.weightBytes
    );
  }
  forward(x: MlxArray, positions: MlxArray): MlxArray {
    return this.#compiled.apply([x, positions])[0]!;
  }
  #forward(x: MlxArray, positions: MlxArray): MlxArray {
    using ff = this.#ff1.forward(x);
    using attn = this.#attention.forward(ff, positions);
    using conv = this.#conv.forward(attn);
    using ff2 = this.#ff2.forward(conv);
    return this.#norm.forward(ff2);
  }
  dispose(): void {
    this.#compiled?.dispose();
    this.#ff1?.dispose();
    this.#attention?.dispose();
    this.#conv?.dispose();
    this.#ff2?.dispose();
  }
}

/** Owns the frequency constants and Metal position kernel. */
export class PhononRelativePositions {
  readonly #kernel = new RelativePositionKernel();
  readonly #frequencies = MlxArray.fromFloat32(
    Float32Array.from({ length: 512 }, (_, j) =>
      Math.exp(Math.fround(2 * j * -(Math.log(10000) / 1024))),
    ),
    [512],
  );
  forward(length: number): MlxArray {
    return this.#kernel.apply(this.#frequencies, length);
  }
  dispose(): void {
    this.#frequencies.dispose();
    this.#kernel.dispose();
  }
}
