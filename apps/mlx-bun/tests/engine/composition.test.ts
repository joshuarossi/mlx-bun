// A loaded model records the composition its load resolved, and the serving
// binding prints it on /stats. The checkpoint is a complete one-layer 4-bit
// qwen3 with zeroed tensors: construction and binding read no values.
import { afterAll, beforeAll, expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { deviceArchitecture } from "@mlx-bun/mlx/ffi";
import { writeSafetensors, writeSourceModel } from "../quantized-artifact";

let dir: string;
beforeAll(() => {
  dir = mkdtempSync(join(tmpdir(), "mlx-app-composition-"));
  writeSourceModel(dir); // the chat template and generation config
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1,
    num_attention_heads: 2, num_key_value_heads: 2, head_dim: 32, intermediate_size: 64, vocab_size: 64, rms_norm_eps: 1e-6,
    max_position_embeddings: 128, tie_word_embeddings: true, quantization: { group_size: 64, bits: 4 } }));
  writeFileSync(join(dir, "tokenizer.json"), JSON.stringify({ version: "1.0", truncation: null, padding: null, normalizer: null,
    added_tokens: [], pre_tokenizer: { type: "WhitespaceSplit" }, decoder: null, post_processor: null,
    model: { type: "WordLevel", vocab: Object.fromEntries(Array.from({ length: 64 }, (_, i) => [i ? `token${i}` : "[UNK]", i])), unk_token: "[UNK]" } }));
  writeFileSync(join(dir, "tokenizer_config.json"), JSON.stringify({ unk_token: "[UNK]", add_bos_token: false }));
  const tensors: Parameters<typeof writeSafetensors>[1] = {};
  const quantized = (name: string, rows: number, cols: number) => Object.assign(tensors, {
    [`${name}.weight`]: { dtype: "U32", shape: [rows, cols / 8] },
    [`${name}.scales`]: { dtype: "BF16", shape: [rows, cols / 64] }, [`${name}.biases`]: { dtype: "BF16", shape: [rows, cols / 64] } });
  const layer = "model.layers.0";
  quantized("model.embed_tokens", 64, 64);
  for (const name of ["q_proj", "k_proj", "v_proj", "o_proj"]) quantized(`${layer}.self_attn.${name}`, 64, 64);
  for (const name of ["gate_proj", "up_proj", "down_proj"]) quantized(`${layer}.mlp.${name}`, 64, 64);
  for (const [name, width] of [["model.norm", 64], [`${layer}.input_layernorm`, 64], [`${layer}.post_attention_layernorm`, 64],
    [`${layer}.self_attn.q_norm`, 32], [`${layer}.self_attn.k_norm`, 32]] as const)
    tensors[`${name}.weight`] = { dtype: "BF16", shape: [width] };
  writeSafetensors(join(dir, "model.safetensors"), tensors);
});
afterAll(() => rmSync(dir, { recursive: true, force: true }));

test("a loaded model records the composition resolved before its graph was built, and /stats prints it", async () => {
  const { loadContext } = await import("../../src/engine/model-host");
  const { modelServingBinding } = await import("../../src/engine/model-serving");
  const context = await loadContext(dir, "tiny", { kv: { override: 8 }, maxRows: 3 });
  try {
    const aneBridge = context.composition!.aneBridge;
    expect(context.composition).toEqual({ device: deviceArchitecture(), aneBridge, kv: { kind: "affine", bits: 8, groupSize: 64 },
      draftDepth: 0, prefillChunkTokens: 2048, adapters: false, maxRows: 3 });
    expect(typeof aneBridge).toBe("boolean");
    const binding = await modelServingBinding(context);
    expect(binding.diagnostics()).toEqual({ composition: { device: deviceArchitecture(), ane_bridge: aneBridge,
      kv: { kind: "affine", bits: 8, group_size: 64 }, draft_depth: 0, prefill_chunk_tokens: 2048, adapters: false, max_rows: 3 } });
  } finally { context.dispose(); }
});

test("the loaded drafter settles the draft depth before the graph is built: its own default, or the flag", async () => {
  const { loadContext } = await import("../../src/engine/model-host");
  for (const [numDraftTokens, depth] of [[undefined, 10], [4, 4]] as const) {
    const context = await loadContext(dir, "tiny", { draftKind: "ngram", ...(numDraftTokens ? { numDraftTokens } : {}),
      kv: { override: 4, quantizedKvStart: 256 }, adapters: true });
    try {
      expect(context.draft?.numDraftTokens).toBe(depth);
      expect(context.composition).toMatchObject({ draftDepth: depth, adapters: true, maxRows: 8,
        kv: { kind: "affine", bits: 4, groupSize: 64, quantizedKvStart: 256 } });
    } finally { context.dispose(); }
  }
});
