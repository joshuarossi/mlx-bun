// Qwen3.5 checkpoint-generation normalization (src/model/qwen3_5-checkpoint.ts)
// against synthetic tensor-name fixtures for both generations. Model-free: the
// fixtures are header facts (name + shape) only, and the value fix-ups are
// exercised on hand-built arrays.
//
// The γ shift is the dangerous rule — a spurious +1.0 silently corrupts an old
// artifact — so the discriminator gets its own table: mlx-lm keys it on
// `mtp.` tensors OR an unsanitized conv1d, NEVER on the naming generation.

import { describe, expect, test } from "bun:test";
import {
  qwen35WeightsView,
  sanitizeQwen35Checkpoint,
  type CheckpointTensor,
} from "../../src/model/qwen3_5-checkpoint";
import { MlxArray } from "../../src/mlx/array";
import { Dtype } from "../../src/mlx/ffi";
import type { Weights } from "../../src/weights";

/** transformers-5.8 export: model.language_model.* + top-level lm_head +
 *  model.visual.* + in-repo mtp.* + HF-layout conv1d. */
function newGeneration(): CheckpointTensor[] {
  return [
    { name: "model.language_model.embed_tokens.weight", shape: [248320, 5120] },
    { name: "model.language_model.layers.0.input_layernorm.weight", shape: [5120] },
    { name: "model.language_model.layers.0.post_attention_layernorm.weight", shape: [5120] },
    { name: "model.language_model.layers.0.linear_attn.conv1d.weight", shape: [10240, 1, 4] },
    { name: "model.language_model.layers.0.linear_attn.norm.weight", shape: [128] },
    { name: "model.language_model.layers.0.linear_attn.A_log", shape: [48] },
    { name: "model.language_model.layers.3.self_attn.q_norm.weight", shape: [256] },
    { name: "model.language_model.layers.3.self_attn.k_norm.weight", shape: [256] },
    { name: "model.language_model.layers.3.self_attn.q_proj.weight", shape: [12288, 640] },
    { name: "model.language_model.norm.weight", shape: [5120] },
    { name: "lm_head.weight", shape: [248320, 640] },
    { name: "lm_head.scales", shape: [248320, 80] },
    { name: "model.visual.patch_embed.proj.weight", shape: [1152, 3, 2, 16, 16] },
    { name: "model.visual.merger.norm.weight", shape: [1152] },
    { name: "mtp.fc.weight", shape: [5120, 1280] },
    { name: "mtp.layers.0.input_layernorm.weight", shape: [5120] },
  ];
}

/** Pre-5.8 (mlx-lm-converted) artifact: already our canonical space. */
function oldGeneration(): CheckpointTensor[] {
  return [
    { name: "language_model.model.embed_tokens.weight", shape: [248320, 5120] },
    { name: "language_model.model.layers.0.input_layernorm.weight", shape: [5120] },
    { name: "language_model.model.layers.0.post_attention_layernorm.weight", shape: [5120] },
    { name: "language_model.model.layers.0.linear_attn.conv1d.weight", shape: [10240, 4, 1] },
    { name: "language_model.model.layers.0.linear_attn.norm.weight", shape: [128] },
    { name: "language_model.model.layers.3.self_attn.q_norm.weight", shape: [256] },
    { name: "language_model.model.layers.3.self_attn.k_norm.weight", shape: [256] },
    { name: "language_model.model.norm.weight", shape: [5120] },
    { name: "language_model.lm_head.weight", shape: [248320, 640] },
    { name: "vision_tower.patch_embed.proj.weight", shape: [1152, 2, 16, 16, 3] },
  ];
}

/** The only Weights surface qwen35WeightsView reads (header facts). */
function fakeWeights(tensors: CheckpointTensor[]): Weights {
  const byName = new Map(tensors.map((t) => [t.name, t]));
  return {
    tensorNames: tensors.map((t) => t.name),
    info: (name: string) => ({ name, shape: byName.get(name)!.shape as number[] }),
  } as unknown as Weights;
}

describe("qwen3.5 checkpoint naming", () => {
  test("5.8 names fold onto the graph's canonical space", () => {
    const { names } = sanitizeQwen35Checkpoint(newGeneration());
    expect(names.get("language_model.model.embed_tokens.weight"))
      .toBe("model.language_model.embed_tokens.weight");
    expect(names.get("language_model.model.layers.3.self_attn.q_proj.weight"))
      .toBe("model.language_model.layers.3.self_attn.q_proj.weight");
    expect(names.get("language_model.model.norm.weight"))
      .toBe("model.language_model.norm.weight");
    // Top-level lm_head is prefixed, not rewritten under model.
    expect(names.get("language_model.lm_head.weight")).toBe("lm_head.weight");
    expect(names.get("language_model.lm_head.scales")).toBe("lm_head.scales");
  });

  test("vision and mtp tensors are dropped, exactly as mlx-lm drops them", () => {
    const { names } = sanitizeQwen35Checkpoint(newGeneration());
    for (const n of [...names.keys()])
      expect(n.includes("visual") || n.includes("vision_tower") || n.includes("mtp."))
        .toBe(false);
    expect(names.size).toBe(12); // 16 fixtures − 2 visual − 2 mtp
    // …and no canonical name resolves back to a dropped source.
    for (const s of [...names.values()])
      expect(s.startsWith("mtp.") || s.startsWith("model.visual")).toBe(false);
  });

  test("a pre-5.8 artifact needs no view at all", () => {
    const plan = sanitizeQwen35Checkpoint(oldGeneration());
    expect(plan.identity).toBe(true);
    expect(plan.normShift.size).toBe(0);
    expect(plan.convMoveaxis.size).toBe(0);
    expect(qwen35WeightsView(fakeWeights(oldGeneration()))).toBeNull();
  });
});

describe("qwen3.5 γ−1 discriminator (mlx-lm TextModel.sanitize)", () => {
  test("5.8 artifact: mtp.* + unsanitized conv1d ⇒ shift the five norm families", () => {
    const { normShift, convMoveaxis } = sanitizeQwen35Checkpoint(newGeneration());
    expect([...normShift].sort()).toEqual([
      "language_model.model.layers.0.input_layernorm.weight",
      "language_model.model.layers.0.post_attention_layernorm.weight",
      "language_model.model.layers.3.self_attn.k_norm.weight",
      "language_model.model.layers.3.self_attn.q_norm.weight",
      "language_model.model.norm.weight",
    ]);
    // RMSNormGated's linear_attn.norm is NOT in the oracle's norm_keys.
    expect(normShift.has("language_model.model.layers.0.linear_attn.norm.weight"))
      .toBe(false);
    expect([...convMoveaxis])
      .toEqual(["language_model.model.layers.0.linear_attn.conv1d.weight"]);
  });

  test("the discriminator is mtp-or-conv, never the naming generation", () => {
    // Old naming, but mtp.* present ⇒ shift (mlx-lm keys on content).
    const oldWithMtp = [...oldGeneration(), { name: "mtp.fc.weight", shape: [5120, 1280] }];
    expect(sanitizeQwen35Checkpoint(oldWithMtp).normShift.size).toBe(5);

    // New naming, but already-sanitized conv1d and no mtp ⇒ NO shift.
    const newSanitized = newGeneration()
      .filter((t) => !t.name.startsWith("mtp."))
      .map((t) => t.name.endsWith("conv1d.weight")
        ? { name: t.name, shape: [10240, 4, 1] }
        : t);
    const plan = sanitizeQwen35Checkpoint(newSanitized);
    expect(plan.normShift.size).toBe(0);
    expect(plan.convMoveaxis.size).toBe(0);
    expect(plan.identity).toBe(false); // still needs the rename
  });

  test("only 1-D gains are shifted", () => {
    const withMatrixNorm = [
      ...newGeneration(),
      { name: "model.language_model.layers.9.input_layernorm.weight", shape: [4, 5120] },
    ];
    const { normShift } = sanitizeQwen35Checkpoint(withMatrixNorm);
    expect(normShift.has("language_model.model.layers.9.input_layernorm.weight"))
      .toBe(false);
  });
});

describe("qwen3.5 load-time value fix-ups", () => {
  const view = qwen35WeightsView(fakeWeights(newGeneration()))!;

  test("a view is installed for the 5.8 generation", () => {
    expect(view).not.toBeNull();
  });

  test("γ−1 gains gain 1.0, at the gain's own dtype", () => {
    const src = MlxArray.fromFloat32(new Float32Array([-0.5, 0, 0.25]), [3])
      .astype(Dtype.bfloat16);
    const out = view.fixup!(
      "language_model.model.layers.0.input_layernorm.weight", src,
    )!;
    expect(out.dtype).toBe(Dtype.bfloat16);
    expect([...out.toFloat32Host()]).toEqual([0.5, 1, 1.25]);
    src.dispose();
    out.dispose();
  });

  test("non-norm tensors are returned untouched", () => {
    const src = MlxArray.fromFloat32(new Float32Array([1, 2]), [2]);
    expect(view.fixup!("language_model.model.layers.0.linear_attn.A_log", src))
      .toBeNull();
    expect(view.fixup!("language_model.model.layers.0.linear_attn.norm.weight", src))
      .toBeNull();
    src.dispose();
  });

  test("HF conv1d [C,1,K] is moved to [C,K,1] without reordering taps", () => {
    // [2,1,3] → [2,3,1]: mlx-lm's v.moveaxis(2, 1).
    const src = MlxArray.fromFloat32(
      new Float32Array([1, 2, 3, 4, 5, 6]), [2, 1, 3],
    );
    const out = view.fixup!(
      "language_model.model.layers.0.linear_attn.conv1d.weight", src,
    )!;
    expect(out.shape).toEqual([2, 3, 1]);
    expect([...out.toFloat32Host()]).toEqual([1, 2, 3, 4, 5, 6]);
    src.dispose();
    out.dispose();
  });
});
