// The MOSS-Image DiT's blocks (the snapshot's pipeline_moss_image.py `_Block`,
// `_TextBlock`, `_TextProjection`), operation for operation in the reference's
// dtypes: bf16 activations, per-head RMS q/k norms, rotate-half RoPE over the
// four-axis coordinates, SDPA, and the SITU feed-forward.

import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import { tensorUsed, type WeightAudit } from "../../artifacts/weight-audit";
import type { Weights } from "../../artifacts/weights";
import { applyAxialRope, type AxialRopeTables } from "../../layers/axial-rope";
import { loadLinear, type AnyLinear } from "../../layers/loading";
import { RMSNorm } from "../../layers/normalization";
import type { CompiledSitu, PlainSitu } from "../../layers/situ";

/** The reference's `_RMSNorm` epsilon. */
const NORM_EPS = 1e-6;

/** What a block reads of the checkpoint: its tensors, quantization and the audit of consumed names. */
export interface BlockWeights {
  readonly weights: Weights;
  readonly config: ModelConfig;
  readonly audit: WeightAudit;
}

const norm = (source: BlockWeights, path: string) => new RMSNorm(tensorUsed(source.weights, source.audit, `${path}.weight`), NORM_EPS);
const linear = (source: BlockWeights, path: string): AnyLinear => loadLinear(source.weights, path, source.config, source.audit);

/** Free what a linear made of its borrowed weights (a dense layer's transposed view). */
export function disposeLinear(linear: AnyLinear): void {
  if ("dispose" in linear) linear.dispose();
}

/** Attention over `[1, N, dim]` q/k/v (consumed): per-head RMS norms on q and k,
 * RoPE on both, SDPA at `head_dim ** -0.5`, heads merged back. Owned result. */
function attend(q: MlxArray, k: MlxArray, v: MlxArray, qNorm: RMSNorm, kNorm: RMSNorm, rope: AxialRopeTables, heads: number): MlxArray {
  const [batch, length, dim] = q.shape as [number, number, number];
  const shape = [batch, length, heads, dim / heads];
  const heads4 = (x: MlxArray) => { const out = ops.reshape(x, shape); x.dispose(); return out; };
  using qh = heads4(q), kh = heads4(k), vh = heads4(v);
  using qn = qNorm.forward(qh), kn = kNorm.forward(kh);
  using qr = applyAxialRope(qn, rope), kr = applyAxialRope(kn, rope);
  using qt = ops.transposeAxes(qr, [0, 2, 1, 3]), kt = ops.transposeAxes(kr, [0, 2, 1, 3]), vt = ops.transposeAxes(vh, [0, 2, 1, 3]);
  using attended = ops.sdpa(qt, kt, vt, Math.pow(dim / heads, -0.5), "");
  using merged = ops.transposeAxes(attended, [0, 2, 1, 3]);
  return ops.reshape(merged, [batch, length, dim]);
}

/** `[.., 3 * dim]` split into three `[.., dim]` thirds. */
function thirds(x: MlxArray): [MlxArray, MlxArray, MlxArray] {
  const dim = x.shape.at(-1)! / 3;
  const [a, b, c] = ops.split(x, [dim, 2 * dim], -1);
  return [a!, b!, c!];
}

/** The modulation one forward shares across every joint block: shift, `1 + scale`
 * and gate for attention and for the feed-forward, each `[1, 1, dim]` bf16. */
export interface BlockModulation {
  readonly shiftA: MlxArray; readonly scaleA: MlxArray; readonly gateA: MlxArray;
  readonly shiftF: MlxArray; readonly scaleF: MlxArray; readonly gateF: MlxArray;
}

/** A joint image+text block (`_Block`): modulated attention and SITU feed-forward,
 * no projection biases. */
export class MossJointBlock {
  readonly norm1: RMSNorm; readonly norm2: RMSNorm;
  readonly qNorm: RMSNorm; readonly kNorm: RMSNorm;
  readonly q: AnyLinear; readonly k: AnyLinear; readonly v: AnyLinear; readonly o: AnyLinear;
  readonly upGate: AnyLinear; readonly down: AnyLinear;

  constructor(source: BlockWeights, prefix: string, readonly heads: number, readonly activation: PlainSitu | CompiledSitu) {
    this.norm1 = norm(source, `${prefix}.norm1`);
    this.norm2 = norm(source, `${prefix}.norm2`);
    this.qNorm = norm(source, `${prefix}.q_norm`);
    this.kNorm = norm(source, `${prefix}.k_norm`);
    this.q = linear(source, `${prefix}.proj.q`);
    this.k = linear(source, `${prefix}.proj.k`);
    this.v = linear(source, `${prefix}.proj.v`);
    this.o = linear(source, `${prefix}.proj.o`);
    this.upGate = linear(source, `${prefix}.proj.ffn_up_gate`);
    this.down = linear(source, `${prefix}.proj.ffn_down`);
  }

  /** `x` `[1, N, dim]` (borrowed) to an owned `[1, N, dim]`. */
  forward(x: MlxArray, rope: AxialRopeTables, mod: BlockModulation): MlxArray {
    using normed = this.norm1.forward(x);
    using scaled = ops.mul(normed, mod.scaleA);
    using y = ops.add(scaled, mod.shiftA);
    using attended = attend(this.q.forward(y), this.k.forward(y), this.v.forward(y), this.qNorm, this.kNorm, rope, this.heads);
    using projected = this.o.forward(attended);
    using gatedA = ops.mul(projected, mod.gateA);
    using h = ops.add(x, gatedA);
    using normed2 = this.norm2.forward(h);
    using scaled2 = ops.mul(normed2, mod.scaleF);
    using y2 = ops.add(scaled2, mod.shiftF);
    using upGate = this.upGate.forward(y2);
    const width = upGate.shape.at(-1)! / 2;
    const [hidden, gate] = ops.split(upGate, [width], -1);
    using activated = this.activation.forward(hidden!, gate!);
    using down = this.down.forward(activated);
    using gatedF = ops.mul(down, mod.gateF);
    return ops.add(h, gatedF);
  }

  dispose(): void {
    for (const linear of [this.q, this.k, this.v, this.o, this.upGate, this.down]) disposeLinear(linear);
  }
}

/** A text-refiner block (`_TextBlock`): unmodulated attention over the text
 * tokens and a SITU feed-forward with separate gate and up projections, all
 * with biases. */
export class MossTextBlock {
  readonly norm1: RMSNorm; readonly norm2: RMSNorm;
  readonly qNorm: RMSNorm; readonly kNorm: RMSNorm;
  readonly qkv: AnyLinear; readonly proj: AnyLinear;
  readonly gate: AnyLinear; readonly up: AnyLinear; readonly down: AnyLinear;

  constructor(source: BlockWeights, prefix: string, readonly heads: number, readonly activation: PlainSitu | CompiledSitu) {
    this.norm1 = norm(source, `${prefix}.norm1`);
    this.norm2 = norm(source, `${prefix}.norm2`);
    this.qNorm = norm(source, `${prefix}.q_norm`);
    this.kNorm = norm(source, `${prefix}.k_norm`);
    this.qkv = linear(source, `${prefix}.qkv`);
    this.proj = linear(source, `${prefix}.proj`);
    this.gate = linear(source, `${prefix}.ffn_gate`);
    this.up = linear(source, `${prefix}.ffn_up`);
    this.down = linear(source, `${prefix}.ffn_down`);
  }

  /** `x` `[1, L, dim]` (borrowed) to an owned `[1, L, dim]`. */
  forward(x: MlxArray, rope: AxialRopeTables): MlxArray {
    using normed = this.norm1.forward(x);
    using qkv = this.qkv.forward(normed);
    const [q, k, v] = thirds(qkv);
    using attended = attend(q, k, v, this.qNorm, this.kNorm, rope, this.heads);
    using projected = this.proj.forward(attended);
    using h = ops.add(x, projected);
    using normed2 = this.norm2.forward(h);
    using activated = this.activation.forward(this.up.forward(normed2), this.gate.forward(normed2));
    using down = this.down.forward(activated);
    return ops.add(h, down);
  }

  dispose(): void {
    for (const linear of [this.qkv, this.proj, this.gate, this.up, this.down]) disposeLinear(linear);
  }
}
