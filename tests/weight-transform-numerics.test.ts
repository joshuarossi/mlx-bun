import { afterAll, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import type { ModelConfig } from "../src/config";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";
import * as ops from "../src/mlx/ops";
import {
  llamaWeightTransform,
  writeShardedSafetensors,
  type NamedTensor,
} from "../src/quantize";
import { Weights } from "../src/weights";

const root = mkdtempSync(join(tmpdir(), "mlx-bun-weight-transform-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

function bf16(name: string, values: number[], shape: number[]): NamedTensor {
  const f32 = MlxArray.fromFloat32(Float32Array.from(values), shape);
  const array = f32.astype(Dtype.bfloat16);
  f32.dispose();
  return { name, array };
}

function matrix(rows: number, columns: number, row0: number[]): number[] {
  return [...row0, ...new Array((rows - 1) * columns).fill(0)];
}

function expectClose(actual: Float32Array, expected: number[]): void {
  expect(actual.length).toBe(expected.length);
  for (let i = 0; i < expected.length; i++)
    expect(actual[i]!).toBeCloseTo(expected[i]!, 2);
}

describe("WeightTransform numerical contract", () => {
  test("Llama fold matches a worked R1/R2 example through the public interface", async () => {
    const dir = join(root, "llama-worked-example");
    mkdirSync(dir);
    const layer = "model.layers.0";
    const tensors = [
      bf16("model.embed_tokens.weight", [2, 0, 0, 0, 0, 0, 0, 0], [2, 4]),
      bf16("model.norm.weight", [3, 1, 1, 1], [4]),
      bf16(`${layer}.input_layernorm.weight`, [2, 3, 4, 5], [4]),
      bf16(`${layer}.post_attention_layernorm.weight`, [1, 1, 1, 1], [4]),
      bf16(`${layer}.self_attn.q_proj.weight`, matrix(4, 4, [1, 0, 0, 0]), [4, 4]),
      bf16(`${layer}.self_attn.k_proj.weight`, matrix(2, 4, [2, 0, 0, 0]), [2, 4]),
      bf16(`${layer}.self_attn.v_proj.weight`, matrix(2, 4, [1, 0, 0, 0]), [2, 4]),
      bf16(`${layer}.self_attn.o_proj.weight`, matrix(4, 4, [4, 0, 0, 0]), [4, 4]),
      bf16(`${layer}.mlp.gate_proj.weight`, matrix(4, 4, [1, 0, 0, 0]), [4, 4]),
      bf16(`${layer}.mlp.up_proj.weight`, matrix(4, 4, [1, 0, 0, 0]), [4, 4]),
      bf16(`${layer}.mlp.down_proj.weight`, matrix(4, 4, [4, 0, 0, 0]), [4, 4]),
    ];
    writeShardedSafetensors(dir, tensors);
    for (const tensor of tensors) tensor.array.dispose();

    const weights = await Weights.open(dir);
    const config = {
      modelType: "llama",
      text: {
        hiddenSize: 4,
        headDim: 2,
        numHiddenLayers: 1,
        numAttentionHeads: 2,
        numKeyValueHeads: 1,
      },
    } as ModelConfig;
    // For seed 96 the documented splitmix sign schedule yields +1 for all
    // four R1 lanes and both R2 lanes. The expected values below are the
    // independent normalized Sylvester-Hadamard result.
    const transform = llamaWeightTransform({ seed: 96 });
    const plan = transform.plan(weights.tensorNames, config);
    const context = transform.createContext(weights, plan);
    const apply = (name: string): Float32Array => {
      const sourceName = plan.sourceByOutput.get(name);
      if (!sourceName) throw new Error(`test plan has no source for ${name}`);
      const output = context.apply(name, weights.tensor(sourceName));
      const contiguous = ops.contiguous(output);
      try {
        return contiguous.toFloat32();
      } finally {
        contiguous.dispose();
        output.dispose();
      }
    };

    try {
      expectClose(apply("model.embed_tokens.weight"), [1, 1, 1, 1, 0, 0, 0, 0]);
      expectClose(apply("lm_head.weight"), [3, 3, 3, 3, 0, 0, 0, 0]);
      expectClose(apply("model.norm.weight"), [1, 1, 1, 1]);
      expectClose(apply(`${layer}.input_layernorm.weight`), [1, 1, 1, 1]);
      expectClose(apply(`${layer}.self_attn.q_proj.weight`), [
        1, 1, 1, 1,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
      ]);
      expectClose(apply(`${layer}.self_attn.v_proj.weight`), [
        Math.SQRT1_2, Math.SQRT1_2, Math.SQRT1_2, Math.SQRT1_2,
        Math.SQRT1_2, Math.SQRT1_2, Math.SQRT1_2, Math.SQRT1_2,
      ]);
      expectClose(apply(`${layer}.self_attn.o_proj.weight`), [
        Math.SQRT2, Math.SQRT2, 0, 0,
        Math.SQRT2, Math.SQRT2, 0, 0,
        Math.SQRT2, Math.SQRT2, 0, 0,
        Math.SQRT2, Math.SQRT2, 0, 0,
      ]);
      expectClose(apply(`${layer}.mlp.down_proj.weight`), [
        2, 0, 0, 0,
        2, 0, 0, 0,
        2, 0, 0, 0,
        2, 0, 0, 0,
      ]);
    } finally {
      context.dispose();
      weights.dispose();
    }
  });
});
