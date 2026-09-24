import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { loadModelConfig, Weights } from "@mlx-bun/inference/artifacts";
import { Qwen3Model } from "@mlx-bun/inference/models/qwen3";
import { bindMlxGraph } from "@mlx-bun/inference/models/graph";

/** A tiny checkpoint generated in memory; no model download or stored fixture. */
async function checkpoint(dir: string): Promise<void> {
  const tensors: Record<string, unknown> = {}, chunks: Uint8Array[] = [];
  let offset = 0, sequence = 0;
  const tensor = (name: string, value: MlxArray, dtype: string) => {
    const bytes = value.rawBytes();
    tensors[name] = { dtype, shape: value.shape, data_offsets: [offset, offset + bytes.length] };
    chunks.push(bytes); offset += bytes.length;
  };
  const matrix = (name: string, rows: number, cols: number) => {
    const seed = ++sequence;
    using source = MlxArray.fromFloat32(Float32Array.from({ length: rows * cols }, (_, i) => Math.sin(i * 0.17 + seed) * 0.1), [rows, cols]);
    using value = source.astype(Dtype.bfloat16);
    const q = ops.quantize(value, 64, 4);
    try { tensor(name + ".weight", q.packed, "U32"); tensor(name + ".scales", q.scales, "BF16"); tensor(name + ".biases", q.biases, "BF16"); }
    finally { q.packed.dispose(); q.scales.dispose(); q.biases.dispose(); }
  };
  matrix("model.embed_tokens", 64, 64);
  const layer = "model.layers.0";
  for (const [name, rows] of [["q_proj", 64], ["k_proj", 32], ["v_proj", 32], ["o_proj", 64]] as const)
    matrix(`${layer}.self_attn.${name}`, rows, 64);
  for (const name of ["gate_proj", "up_proj", "down_proj"]) matrix(`${layer}.mlp.${name}`, 64, 64);
  for (const [name, width] of [["model.norm", 64], [`${layer}.input_layernorm`, 64], [`${layer}.post_attention_layernorm`, 64], [`${layer}.self_attn.q_norm`, 32], [`${layer}.self_attn.k_norm`, 32]] as const) {
    using raw = MlxArray.fromFloat32(new Float32Array(width).fill(1), [width]);
    using value = raw.astype(Dtype.bfloat16); tensor(name + ".weight", value, "BF16");
  }
  const json = JSON.stringify(tensors), header = Buffer.from(json.padEnd(Math.ceil(json.length / 8) * 8, " "));
  const size = Buffer.alloc(8); size.writeBigUInt64LE(BigInt(header.length));
  await Bun.write(join(dir, "model.safetensors"), Buffer.concat([size, header, ...chunks]));
  await Bun.write(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64, rms_norm_eps: 1e-6, max_position_embeddings: 128, tie_word_embeddings: true, quantization: { group_size: 64, bits: 4 } }));
}

test("a caller loads a graph, owns its state, selects logits and generates directly", async () => {
  const dir = mkdtempSync(join(tmpdir(), "mlx-qwen3-"));
  try {
    await checkpoint(dir);
    const config = await loadModelConfig(dir), weights = await Weights.open(dir);
    try {
      const model = new Qwen3Model(weights, config), state = model.makeCache();
      try {
        const graph = bindMlxGraph(model, { id: "tiny-qwen3", artifact: "synthetic", stateAbi: "kv" });
        using ids = ops.fromInt32([1, 2, 3], [1, 3]);
        using hidden = await graph.forwardHidden(ids, state);
        expect(hidden.shape).toEqual([1, 3, 64]);
        expect(state[0]!.offset).toBe(3);
        using all = graph.projectLogits(hidden, { type: "all" });
        using last = graph.projectLogits(hidden, { type: "last" });
        expect(all.shape).toEqual([1, 3, 64]);
        using selected = hidden.slice([0, 2, 0], [1, 3, 64]);
        using expected = model.logitsFromHidden(selected);
        expect(last.shape).toEqual([1, 1, 64]);
        expect(Buffer.from(last.rawBytes())).toEqual(Buffer.from(expected.rawBytes()));
        expect(() => graph.projectLogits(hidden, { type: "range", start: 3, end: 4 })).toThrow("selection");
        const tokens = model.generate([1, 2, 3], 4);
        expect(tokens).toHaveLength(4);
        expect(tokens.every(token => token >= 0 && token < 64)).toBe(true);
        expect(model.generate([1, 2, 3], 4)).toEqual(tokens);
      } finally { for (const cache of state) cache.dispose(); }
    } finally { weights.dispose(); }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
