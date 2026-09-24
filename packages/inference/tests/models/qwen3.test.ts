import { generateText } from "../../examples/qwen3-generate";
import { forwardTokens } from "../../examples/qwen3-forward";
import { expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { Dtype, MlxArray, ops } from "@mlx-bun/mlx";
import { loadModelConfig, Weights } from "@mlx-bun/inference";
import { Qwen3Model } from "@mlx-bun/inference/models/qwen3";
import { generateSpeculative, TwoModelProvider } from "@mlx-bun/inference/generation/speculative";
import { forwardSequence, klPerToken, evalPpl } from "@mlx-bun/inference/scoring";
import { createInferenceEngine, createAutoregressiveMethod } from "@mlx-bun/inference/execution";
import { bindLegacyAutoregressiveModel } from "@mlx-bun/inference/generation/bindings/autoregressive";
import { generate } from "@mlx-bun/inference";
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
  // The examples use a tokenizer loaded from the same temporary checkpoint.
  await Bun.write(join(dir, "tokenizer.json"), JSON.stringify({
    version: "1.0", truncation: null, padding: null, normalizer: null,
    added_tokens: [], pre_tokenizer: { type: "WhitespaceSplit" }, decoder: null,
    model: { type: "WordLevel", vocab: { "[UNK]": 0, ...Object.fromEntries(
      Array.from({ length: 63 }, (_, i) => [`token${i + 1}`, i + 1])) }, unk_token: "[UNK]" },
    post_processor: null,
  }));
  await Bun.write(join(dir, "tokenizer_config.json"), JSON.stringify({ unk_token: "[UNK]", add_bos_token: false }));
  const json = JSON.stringify(tensors), header = Buffer.from(json.padEnd(Math.ceil(json.length / 8) * 8, " "));
  const size = Buffer.alloc(8); size.writeBigUInt64LE(BigInt(header.length));
  await Bun.write(join(dir, "model.safetensors"), Buffer.concat([size, header, ...chunks]));
  await Bun.write(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", hidden_size: 64, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 1, head_dim: 32, intermediate_size: 64, vocab_size: 64, eos_token_id: [], rms_norm_eps: 1e-6, max_position_embeddings: 128, tie_word_embeddings: true, quantization: { group_size: 64, bits: 4 } }));
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
        using scored = forwardSequence(model, ids);
        expect(Buffer.from(scored.rawBytes())).toEqual(Buffer.from(all.rawBytes()));
        expect(Array.from(klPerToken(scored, all))).toEqual([0, 0, 0]);
        const ppl = evalPpl(model, [new Int32Array([1, 2, 3, 4])], 1);
        expect(ppl.tokens).toBe(3);
        expect(Number.isFinite(ppl.ppl)).toBe(true);
        using selected = hidden.slice([0, 2, 0], [1, 3, 64]);
        using expected = model.logitsFromHidden(selected);
        expect(last.shape).toEqual([1, 1, 64]);
        expect(Buffer.from(last.rawBytes())).toEqual(Buffer.from(expected.rawBytes()));
        expect(() => graph.projectLogits(hidden, { type: "range", start: 3, end: 4 })).toThrow("selection");
        const tokens = model.generate([1, 2, 3], 4);
        expect(tokens).toHaveLength(4);
        expect(tokens.every(token => token >= 0 && token < 64)).toBe(true);
        expect(model.generate([1, 2, 3], 4)).toEqual(tokens);
        const generation = generate(model, [1, 2, 3], { temperature: 0, maxTokens: 4, eosTokenIds: [] });
        const streamed: number[] = [];
        for await (const value of generation) streamed.push(value.token);
        expect(streamed).toEqual(tokens);
        const example = await generateText(dir, "token1 token2 token3", 4);
        expect(example.tokens).toEqual(tokens);
        expect(example.text).toBe(tokens.map(token => token === 0 ? "[UNK]" : `token${token}`).join(" "));
        expect(example.stats).toMatchObject({ promptTokens: 3, generatedTokens: 4 });
        const forward = await forwardTokens(dir, [1, 2, 3]);
        expect([forward.token, forward.nextToken]).toEqual(tokens.slice(0, 2));
        expect(forward.offset).toBe(4);
        expect(forward.logits.length).toBe(64);
        expect(Array.from(forward.logits).every(Number.isFinite)).toBe(true);
        expect(generation.stats).toMatchObject({ promptTokens: 3, generatedTokens: 4 });
        const draft = await TwoModelProvider.load(dir, 64);
        try {
          const speculative: number[] = [];
          const stats = await generateSpeculative(model, draft, 2, [1, 2, 3],
            { temperature: 0, maxTokens: 4, eosTokenIds: [] }, token => { speculative.push(token); });
          expect(speculative).toEqual(tokens);
          expect(stats.generatedTokens).toBe(4);
          expect(stats.spec?.accepted).toBeGreaterThan(0);
        } finally { draft.dispose(); }
        const engine = createInferenceEngine({ async plan(prompt: number[]) {
          return { id: "caller-plan", outputTokenLimit: 4,
            method: createAutoregressiveMethod(bindLegacyAutoregressiveModel(model), prompt,
              { temperature: 0, maxTokens: 4, eosTokenIds: [] }) };
        } }, { timer: { after(ms, callback) { const id = setTimeout(callback, ms); return () => clearTimeout(id); } } });
        try {
          const session = await engine.open([1, 2, 3], { output: "collect" });
          const result = await session.result;
          expect(result.status).toBe("completed");
          if (result.status === "completed") expect(Array.from(result.output!)).toEqual(tokens);
        } finally { await engine.close(); }
      } finally { for (const cache of state) cache.dispose(); }
    } finally { weights.dispose(); }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});
