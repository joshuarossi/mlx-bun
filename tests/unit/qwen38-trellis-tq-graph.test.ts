// Selection of the purpose-built Qwen3.8-27B packed-Trellis graph, model-free:
// the graph fingerprint covers the architecture and the COMPLETE per-tensor
// quantization table, so only the exact quant the file was built for selects it.

import { existsSync } from "node:fs";
import { expect, test } from "bun:test";
import { loadModelConfig, parseQuantization, type ModelConfig } from "../../src/config";
import {
  QWEN38_TRELLIS_TQ_FINGERPRINTS, qwen38TrellisTqAccepts, qwen38TrellisTqFingerprint,
} from "../../src/model/qwen38-27b-trellis-tq";
import { createRuntimeConfig, withRuntimeConfig } from "../../src/runtime-config";

const LAYERS = 4;
function config(overrides: Record<string, unknown> = {}, modelType = "qwen3_5"): ModelConfig {
  const trellis = (bits: number, axis: 0 | 1) => ({ bits, group_size: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis } });
  const raw: Record<string, unknown> = { bits: 4, group_size: 64, mode: "affine" };
  for (let layer = 0; layer < LAYERS; layer++) {
    raw[`language_model.model.layers.${layer}.mlp.gate_proj`] = trellis(3, 1);
    raw[`language_model.model.layers.${layer}.mlp.up_proj`] = trellis(3, 1);
    raw[`language_model.model.layers.${layer}.mlp.down_proj`] = trellis(3, 0);
  }
  Object.assign(raw, overrides);
  return {
    modelType,
    text: {
      hiddenSize: 64, intermediateSize: 256, numHiddenLayers: LAYERS, fullAttentionInterval: 4,
      numAttentionHeads: 4, numKeyValueHeads: 2, headDim: 16, linearNumKeyHeads: 2, linearNumValueHeads: 4,
      linearKeyHeadDim: 16, linearValueHeadDim: 16, linearConvKernelDim: 4, vocabSize: 1024, tieWordEmbeddings: false,
    },
    quantization: parseQuantization(raw),
  } as unknown as ModelConfig;
}

test("fingerprint is stable and moves when any one tensor's codec moves", () => {
  const base = qwen38TrellisTqFingerprint(config());
  expect(base).toMatch(/^[0-9a-f]{16}$/);
  expect(qwen38TrellisTqFingerprint(config())).toBe(base);
  const gate2 = { bits: 2, group_size: 256, mode: "trellis", trellis: { L: 12, code: "1mad", axis: 1 } };
  expect(qwen38TrellisTqFingerprint(config({ "language_model.model.layers.2.mlp.gate_proj": gate2 }))).not.toBe(base);
  expect(qwen38TrellisTqFingerprint(config({ "language_model.lm_head": { bits: 8, group_size: 64 } }))).not.toBe(base);
  // A tensor outside the language model is not part of this graph's identity.
  expect(qwen38TrellisTqFingerprint(config({ "vision_tower.blocks.0.attn.qkv": { bits: 8, group_size: 64 } }))).toBe(base);
});

test("only a listed fingerprint on a Qwen3.5 text model selects the graph; =0 is the control", () => {
  const candidate = config(), fingerprint = qwen38TrellisTqFingerprint(candidate);
  expect(qwen38TrellisTqAccepts(candidate)).toBe(false);
  const listed = QWEN38_TRELLIS_TQ_FINGERPRINTS as Set<string>;
  listed.add(fingerprint);
  try {
    expect(qwen38TrellisTqAccepts(candidate)).toBe(true);
    expect(qwen38TrellisTqAccepts(config({}, "gemma4"))).toBe(false);
    expect(withRuntimeConfig(createRuntimeConfig({ MLX_BUN_QWEN38_TQ_GRAPH: "0" }), () => qwen38TrellisTqAccepts(candidate))).toBe(false);
  } finally { listed.delete(fingerprint); }
});

const ARTIFACT = "/Volumes/MLX-Models/quant-candidates/qwen38-trellis-global-exit5-h39-q4b-v2";
test.skipIf(!existsSync(`${ARTIFACT}/config.json`))("the published q4b artifact selects the graph", async () => {
  const published = await loadModelConfig(ARTIFACT);
  expect(qwen38TrellisTqFingerprint(published)).toBe("cfa205c8f5af046a");
  expect(qwen38TrellisTqAccepts(published)).toBe(true);
});
