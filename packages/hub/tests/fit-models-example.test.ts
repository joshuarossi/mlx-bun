import { expect, test } from "bun:test";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fitModels } from "../examples/fit-models";

/** A complete, tiny quantized checkpoint layout: enough for config parsing,
 *  registry scanning, and a fit estimate, with no tensor bytes that mean anything. */
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

test("the runnable example scans a cache, estimates fit, and releases the registry", async () => {
  const hub = syntheticHub();
  try {
    const machine = { name: "8GB", ramBytes: 8 * 2 ** 30, bandwidthGBs: 68 };
    const reports = await fitModels(hub, 128, machine);
    expect(reports).toHaveLength(1);
    expect(reports[0]!.repoId).toBe("example/tiny-qwen3-4bit");
    expect(reports[0]!.fits).toBe(true);
    expect(reports[0]!.maxSafeContext).toBeGreaterThanOrEqual(128);
  } finally {
    rmSync(hub, { recursive: true, force: true });
  }
});
