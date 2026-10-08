import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { listModels } from "../examples/list-models";

/** A complete, tiny quantized checkpoint layout: enough for registry scanning,
 *  with no tensor bytes that mean anything. */
function syntheticHub(): string {
  const hub = mkdtempSync(join(tmpdir(), "mlx-bun-hub-example-"));
  const snapshot = join(hub, "models--example--tiny-qwen3-4bit", "snapshots", "0123abc");
  mkdirSync(snapshot, { recursive: true });
  writeFileSync(join(snapshot, "config.json"), JSON.stringify({
    model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2,
    num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64,
    rms_norm_eps: 1e-6, max_position_embeddings: 128, tie_word_embeddings: true,
    quantization: { group_size: 64, bits: 4 },
  }));
  writeFileSync(join(snapshot, "model.safetensors"), new Uint8Array(4096));
  writeFileSync(join(snapshot, "model.safetensors.index.json"), JSON.stringify({
    metadata: { total_parameters: 4096 }, weight_map: {},
  }));
  return hub;
}

test("the runnable example scans a cache, lists its models, and releases the registry", async () => {
  const hub = syntheticHub();
  try {
    expect(await listModels(hub)).toEqual([{
      repoId: "example/tiny-qwen3-4bit", modelType: "qwen3", weightsBytes: 4096, expertsBytes: 0,
      vision: false, audio: false,
    }]);
  } finally {
    rmSync(hub, { recursive: true, force: true });
  }
});
