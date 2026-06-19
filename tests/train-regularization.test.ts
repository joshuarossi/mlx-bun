// Regularization knobs: LoRA+ (per-param LR in AdamW), rsLoRA (α/√rank scale),
// and recompute-safe LoRA-input dropout. Pure/weight-free except where noted.

import { describe, expect, test } from "bun:test";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import { AdamW } from "../src/train/optimizer";
import { buildTrainableLora } from "../src/train/lora-params";
import { loraInputDropout } from "../src/model/gemma4-base";
import type { RuntimeModel } from "../src/model/factory";

const f32 = (xs: number[]) => MlxArray.fromFloat32(new Float32Array(xs), [xs.length]);
const read = (a: MlxArray) => a.toFloat32();

describe("LoRA+ — AdamW per-param lrScale", () => {
  test("B param (lrScale 4) moves 4× the A param for the same grad/state", () => {
    // Two scalars-as-vectors; identical grads. lrScale=[1,4]. With wd=0, the
    // first AdamW step moves each by ±lr·lrScale (m̂/√v̂ = 1 at t=1).
    const pA = f32([1.0]), pB = f32([1.0]);
    const opt = new AdamW([pA, pB], { lr: 0.1, weightDecay: 0, lrScale: [1, 4] });
    opt.step([f32([1.0]), f32([1.0])]);
    opt.evalState();
    const dA = 1.0 - read(opt.getParam(0))[0]!;
    const dB = 1.0 - read(opt.getParam(1))[0]!;
    expect(dA).toBeCloseTo(0.1, 4); // lr·1
    expect(dB).toBeCloseTo(0.4, 4); // lr·4
    opt.dispose();
  });
});

// Stub model exposing loraTargets() with fake quant specs (enough for
// buildTrainableLora, which reads inFeatures/outFeatures + builds A/B).
function stubModel(): RuntimeModel {
  const mk = (inF: number, outF: number, bits: number) => ({
    inFeatures: inF, outFeatures: outF, spec: { bits, groupSize: 64 },
  });
  const map = new Map<string, any>([
    ["model.layers.0.self_attn.q_proj", mk(128, 128, 8)], // sensitive → high rank
    ["model.layers.0.self_attn.k_proj", mk(128, 128, 4)],
  ]);
  return { loraTargets: () => map, loraState: { active: [] } } as unknown as RuntimeModel;
}

describe("rsLoRA — α/√rank effective scale", () => {
  test("each target's lw.scale = α/√rank; off → α", () => {
    const model = stubModel();
    const ranks = new Map([
      ["model.layers.0.self_attn.q_proj", 16],
      ["model.layers.0.self_attn.k_proj", 8],
    ]);
    const off = buildTrainableLora(model, ranks, 20, 0, false);
    for (const t of off.targets) expect(t.lw.scale).toBeCloseTo(20, 6);

    const on = buildTrainableLora(model, ranks, 20, 0, true);
    const byPath = new Map(on.targets.map((t) => [t.modulePath, t.lw]));
    expect(byPath.get("model.layers.0.self_attn.q_proj")!.scale).toBeCloseTo(20 / Math.sqrt(16), 5); // 5.0
    expect(byPath.get("model.layers.0.self_attn.k_proj")!.scale).toBeCloseTo(20 / Math.sqrt(8), 5);
  });
});

describe("LoRA-input dropout — recompute-deterministic", () => {
  const x = MlxArray.fromFloat32(new Float32Array(4096).fill(1), [64, 64]);

  test("same (seed, id) reproduces the EXACT mask (recompute safety)", () => {
    const a = loraInputDropout(x, 0.3, 7, 2);
    const b = loraInputDropout(x, 0.3, 7, 2); // recompute with same key
    ops.evalAll([a, b]);
    const av = a.toFloat32(), bv = b.toFloat32();
    for (let i = 0; i < av.length; i++) expect(av[i]).toBe(bv[i]);
    a.dispose(); b.dispose();
  });

  test("different id (or seed) gives a different mask", () => {
    const a = loraInputDropout(x, 0.3, 7, 2);
    const b = loraInputDropout(x, 0.3, 7, 3); // different layer id
    ops.evalAll([a, b]);
    const av = a.toFloat32(), bv = b.toFloat32();
    let diff = 0;
    for (let i = 0; i < av.length; i++) if (av[i] !== bv[i]) diff++;
    expect(diff).toBeGreaterThan(0);
    a.dispose(); b.dispose();
  });

  test("inverted scaling: kept entries are x/(1-p), ~p fraction zeroed, mean≈preserved", () => {
    const p = 0.25;
    const d = loraInputDropout(x, p, 1, 0);
    ops.evalAll([d]);
    const v = d.toFloat32();
    const inv = 1 / (1 - p);
    let zeros = 0, mean = 0;
    for (const e of v) { if (e === 0) zeros++; else expect(e).toBeCloseTo(inv, 4); mean += e; }
    mean /= v.length;
    expect(zeros / v.length).toBeCloseTo(p, 1); // ~25% dropped
    expect(mean).toBeCloseTo(1.0, 1); // E[dropout(x)] ≈ x
    d.dispose();
  });
});
