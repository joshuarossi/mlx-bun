import { afterAll, describe, expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/artifacts/config";
import { resolveComposition } from "../../src/models/composition";
import { MLX_GRAPH_TABLES, MLX_MODEL_IMPLEMENTATIONS } from "../../src/models/factory";
import { MODEL_FAMILIES } from "../../src/models/families";
import { GEMMA_GRAPHS } from "../../src/models/gemma4/graphs";
import { Gemma4Model } from "../../src/models/gemma4/model";
import { implementationIdFor } from "../../src/models/implementation";
import { resolveModelProfile } from "../../src/models/profile";

const root = mkdtempSync(join(tmpdir(), "mlx-family-implementations-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const text = { hidden_size: 64, num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, vocab_size: 64,
  intermediate_size: 64, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128, tie_word_embeddings: true, eos_token_id: 1 };
const linear = { linear_num_value_heads: 4, linear_num_key_heads: 2, linear_key_head_dim: 16, linear_value_head_dim: 16,
  linear_conv_kernel_dim: 4, full_attention_interval: 2, layer_types: ["linear_attention", "full_attention"] };
/** One config per family, keyed by graph. */
const CONFIGS: Record<string, Record<string, unknown>> = {
  "gemma4": { model_type: "gemma4", ...text, layer_types: ["sliding_attention", "full_attention"], sliding_window: 16 },
  "diffusion-gemma": { model_type: "diffusion_gemma", canvas_length: 32, eos_token_id: 1 },
  "qwen3.5": { model_type: "qwen3_5_text", ...text, ...linear },
  "qwen3": { model_type: "qwen3", ...text },
  "qwen3-moe": { model_type: "qwen3_moe", ...text, num_experts: 4, num_experts_per_tok: 2, moe_intermediate_size: 32 },
  "whisper": { model_type: "whisper", n_audio_ctx: 1500 },
  "moss-image": { _class_name: "MOSSImagePipeline", transformer: ["pipeline_moss_image", "MOSSImageTransformer"] },
  "minicpm5": { model_type: "llama", ...text, hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2,
    head_dim: 128, vocab_size: 130560, tie_word_embeddings: false },
  "universal-dense": { model_type: "llama", ...text },
};

async function resolved(name: string, raw: Record<string, unknown>) {
  const dir = join(root, name);
  mkdirSync(dir, { recursive: true });
  // A diffusers pipeline snapshot is identified by its model_index.json, not a config.json.
  writeFileSync(join(dir, "_class_name" in raw ? "model_index.json" : "config.json"), JSON.stringify(raw));
  const config = await loadModelConfig(dir);
  return { config, resolved: resolveModelProfile(config) };
}

describe("family implementations", () => {
  test("every resident family resolves to the native implementation registered under its graph, with the family's own loader and loop", async () => {
    const unavailable: string[] = [];
    for (const family of MODEL_FAMILIES) {
      if (family.loader !== "safetensors") continue;
      const { config, resolved: profile } = await resolved(family.graph, CONFIGS[family.graph]!);
      expect(profile.profile.execution.graph).toBe(family.graph);
      try {
        const implementation = MLX_MODEL_IMPLEMENTATIONS.select(config, profile);
        expect([implementation.id, implementation.graph, implementation.loader, implementation.loop])
          .toEqual([implementationIdFor(profile.profile.execution), family.graph, family.loader, family.loop]);
      } catch (error) {
        expect((error as Error).message).toContain("requires unavailable implementation");
        unavailable.push(family.graph);
      }
    }
    // Speech models open through the transcription engine, image pipelines through openImagePipeline and Colibri through
    // its planned runtime: none is resident.
    expect(unavailable).toEqual(["whisper", "moss-image"]);
    expect(MODEL_FAMILIES.filter(family => family.loader !== "safetensors").map(family => family.graph)).toEqual(["glm5.2"]);
  });

  test("written Gemma graphs retain the family profile and expose direct constructors", async () => {
    for (const entry of GEMMA_GRAPHS) {
      const module = await import(`../../src/models/gemma4/${entry.id}`);
      const Graph = module.Gemma4E4b ?? module.Gemma4TwelveB ?? module.Gemma4Moe;
      const raw = { model_type: "gemma4", ...text, num_hidden_layers: module.LAYERS.length,
        layer_types: module.LAYERS.map((layer: { attention: string }) => layer.attention === "sliding" ? "sliding_attention" : "full_attention"), sliding_window: 16 };
      const { config, resolved: profile } = await resolved(entry.id, raw);
      expect({ id: profile.profile.id, specialization: profile.profile.execution.specialization })
        .toEqual({ id: "gemma4-dedicated", specialization: "dedicated" });
      expect(profile.profile.requiredCapabilities).toEqual(["safetensors", "autoregressive", "gemma4-graph"]);
      expect(MLX_MODEL_IMPLEMENTATIONS.select(config, profile).id).toBe("gemma4");
      const table = MLX_GRAPH_TABLES.gemma4!;
      expect(table.explicit(entry.id).id).toBe(entry.id);
      expect(table.explicit(entry.id).serves).toBe(entry.serves);
      expect(table.select(config, resolveComposition(config))).toBe(table.generic);
      expect(Object.getOwnPropertyDescriptor(Gemma4Model.prototype, "trainable")?.get).toBeDefined();
      expect("trainable" in Graph.prototype).toBe(false);
      expect(Graph.length).toBe(2);
    }
  });
});
