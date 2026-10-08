import { expect, test } from "bun:test";
import { mkdirSync, mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { listedSupportTier } from "@mlx-bun/inference/models/support";
import { openModelRegistry } from "../src/home";

const llama = { model_type: "llama", hidden_size: 64, num_hidden_layers: 2, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32,
  vocab_size: 64, intermediate_size: 64, rms_norm_eps: 1e-6, rope_theta: 1e6, max_position_embeddings: 128, tie_word_embeddings: true, eos_token_id: 1 };
/** MiniCPM5 is a llama-typed 1B checkpoint that only its dimensions identify. */
const miniCpm5 = { ...llama, hidden_size: 1536, num_hidden_layers: 24, num_attention_heads: 16, num_key_value_heads: 2, head_dim: 128,
  vocab_size: 130560, tie_word_embeddings: false };

test("a MiniCPM5 model lists as targeted and a plain Llama as generic, whatever the directory is called", async () => {
  const root = mkdtempSync(join(tmpdir(), "mlx-model-index-"));
  try {
    for (const [name, config] of [["my-local-copy", miniCpm5], ["plain", llama], ["assistant", { ...llama, model_type: "gemma4_assistant" }]] as const) {
      mkdirSync(join(root, "models", name), { recursive: true });
      writeFileSync(join(root, "models", name, "config.json"), JSON.stringify(config));
      writeFileSync(join(root, "models", name, "model.safetensors"), new Uint8Array(16));
    }
    const registry = openModelRegistry(root);
    try {
      await registry.scan(join(root, "no-hub"));
      const tiers = Object.fromEntries(registry.list().map(model => [model.repoId, model.supportTier]));
      expect(tiers).toEqual({ "my-local-copy": "targeted", plain: "generic", assistant: undefined });
      const [miniCpm, plain] = ["my-local-copy", "plain"].map(name => registry.list().find(model => model.repoId === name)!);
      expect([listedSupportTier(miniCpm!), listedSupportTier(plain!)]).toEqual(["targeted", "generic"]);
    } finally { registry.close(); }
  } finally { rmSync(root, { recursive: true, force: true }); }
});
