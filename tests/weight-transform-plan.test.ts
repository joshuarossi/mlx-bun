import { describe, expect, test } from "bun:test";
import type { ModelConfig } from "../src/config";
import {
  automaticRotationWeightTransform,
  llamaWeightTransform,
  qwen35WeightTransform,
  qwenMtpWeightTransform,
  withPreparedProbe,
  type ProbeSource,
} from "../src/quantize";

function modelConfig(modelType: string, numHiddenLayers = 1): ModelConfig {
  return {
    modelType,
    text: {
      hiddenSize: 128,
      headDim: 64,
      numHiddenLayers,
      numAttentionHeads: 2,
      numKeyValueHeads: 1,
    },
  } as ModelConfig;
}

const llamaNames = [
  "model.embed_tokens.weight",
  "model.norm.weight",
  "model.layers.0.input_layernorm.weight",
  "model.layers.0.post_attention_layernorm.weight",
  "model.layers.0.self_attn.q_proj.weight",
  "model.layers.0.self_attn.k_proj.weight",
  "model.layers.0.self_attn.v_proj.weight",
  "model.layers.0.self_attn.o_proj.weight",
  "model.layers.0.mlp.gate_proj.weight",
  "model.layers.0.mlp.up_proj.weight",
  "model.layers.0.mlp.down_proj.weight",
  "model.layers.0.self_attn.rotary_emb.inv_freq",
];

describe("WeightTransform plans (model-free)", () => {
  test("Llama emits every source once and makes the tied head explicit", () => {
    const transform = llamaWeightTransform({ seed: 42 });
    const plan = transform.plan(llamaNames, modelConfig("llama"));

    expect(plan.id).toBe("rotation.llama");
    expect(new Set(plan.outputNames).size).toBe(plan.outputNames.length);
    expect(plan.outputNames).toEqual([...llamaNames, "lm_head.weight"]);
    expect(plan.sourceByOutput.get("lm_head.weight")).toBe("model.embed_tokens.weight");
    expect(plan.untieWordEmbeddings).toBe(true);
  });

  test("Qwen trunk uses the same contract for its synthesized head", () => {
    const names = [
      "language_model.model.embed_tokens.weight",
      "language_model.model.norm.weight",
      "vision_tower.patch_embed.weight",
    ];
    const plan = qwen35WeightTransform({ seed: 7 }).plan(
      names,
      modelConfig("qwen3_5", 0),
    );

    expect(plan.id).toBe("rotation.qwen3_5");
    expect(plan.outputNames).toEqual([...names, "language_model.lm_head.weight"]);
    expect(plan.sourceByOutput.get("language_model.lm_head.weight"))
      .toBe("language_model.model.embed_tokens.weight");
    expect(plan.metadata.seed).toBe(7);
  });

  test("Qwen MTP and automatic selection produce the companion plan", () => {
    const names = [
      "fc.weight",
      "pre_fc_norm_embedding.weight",
      "pre_fc_norm_hidden.weight",
      "norm.weight",
    ];
    const explicit = qwenMtpWeightTransform(11).plan(names, modelConfig("qwen3_5", 0));
    const automatic = automaticRotationWeightTransform({ seed: 11 })
      .plan(names, modelConfig("qwen3_5", 0));

    expect(explicit.id).toBe("rotation.qwen3_5_mtp");
    expect(automatic.id).toBe(explicit.id);
    expect(automatic.outputNames).toEqual(names);
    expect(automatic.untieWordEmbeddings).toBe(false);
  });

  test("Llama rejects an incomplete fold corridor during pure planning", () => {
    expect(() => llamaWeightTransform({ seed: 1 }).plan(
      llamaNames.filter((name) => !name.endsWith("down_proj.weight")),
      modelConfig("llama"),
    )).toThrow("down_proj.weight");
  });
});

describe("ProbeSource lifecycle (model-free)", () => {
  test("uses the injected model directory and releases it on failure", async () => {
    const calls: string[] = [];
    const source: ProbeSource = {
      async prepare(srcDir) {
        calls.push(`prepare:${srcDir}`);
        return {
          modelDir: "/prepared/probe",
          dispose() { calls.push("dispose"); },
        };
      },
    };

    await expect(withPreparedProbe(
      source,
      "/source",
      { bits: 4, groupSize: 64 },
      async (modelDir) => {
        calls.push(`run:${modelDir}`);
        throw new Error("stop");
      },
    )).rejects.toThrow("stop");
    expect(calls).toEqual([
      "prepare:/source",
      "run:/prepared/probe",
      "dispose",
    ]);
  });
});
