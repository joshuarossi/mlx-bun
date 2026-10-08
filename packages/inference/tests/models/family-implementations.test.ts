import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { homedir, tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../../src/artifacts/config";
import { MLX_MODEL_IMPLEMENTATIONS } from "../../src/models/factory";
import { MODEL_FAMILIES } from "../../src/models/families";
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
  "minicpm5": { model_type: "llama", ...text, hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2,
    head_dim: 128, vocab_size: 130560, tie_word_embeddings: false },
  "universal-dense": { model_type: "llama", ...text },
};

async function resolved(name: string, raw: Record<string, unknown>) {
  const dir = join(root, name);
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "config.json"), JSON.stringify(raw));
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
    // Speech models open through the transcription engine and Colibri through its planned runtime: neither is resident.
    expect(unavailable).toEqual(["whisper"]);
    expect(MODEL_FAMILIES.filter(family => family.loader !== "safetensors").map(family => family.graph)).toEqual(["glm5.2"]);
  });

  test("a generated Gemma specialization resolves to the implementation registered for it (skips when the snapshot is not downloaded)", async () => {
    const snapshots = join(homedir(), ".cache/huggingface/hub/models--mlx-community--gemma-4-e4b-it-OptiQ-4bit/snapshots");
    const revision = existsSync(snapshots) ? readdirSync(snapshots).find(entry => existsSync(join(snapshots, entry, "config.json"))) : undefined;
    if (!revision) return;
    const config = await loadModelConfig(join(snapshots, revision));
    const profile = resolveModelProfile(config);
    expect(profile.profile.execution.specialization).toBe("generated");
    expect(MLX_MODEL_IMPLEMENTATIONS.select(config, profile).id).toBe("gemma4-generated");
  });
});
