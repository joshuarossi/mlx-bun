// Test support, not a test: the CPU half of a quantize job's output. Tensor
// bytes come from MLX's native saver in the real producer; here a minimal valid
// safetensors file stands in, named and laid out as the native writer names a
// single shard (`model.safetensors`: packed weight, scales, biases per
// quantized module). The config block, auxiliary files, metadata, and the
// atomic publish are the quantize library's own writers. Spawned stand-in
// children require this module by path.
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { writeAtomicDirectory } from "@mlx-bun/quantize/atomic-output";
import { buildQuantizationBlock, writeQuantizedConfig, type PerLayerEntry } from "@mlx-bun/quantize/config-writer";

const BYTES: Record<string, number> = { U32: 4, BF16: 2, F32: 4 };

/** A header-valid safetensors file with zeroed tensor data. */
export function writeSafetensors(path: string, tensors: Record<string, { dtype: string; shape: number[] }>): void {
  const header: Record<string, unknown> = { __metadata__: { format: "mlx" } };
  let offset = 0;
  for (const [name, { dtype, shape }] of Object.entries(tensors)) {
    const size = shape.reduce((a, b) => a * b, 1) * BYTES[dtype]!;
    header[name] = { dtype, shape, data_offsets: [offset, offset + size] };
    offset += size;
  }
  let json = JSON.stringify(header);
  while ((8 + json.length) % 8) json += " ";
  const length = Buffer.alloc(8);
  length.writeBigUInt64LE(BigInt(json.length));
  writeFileSync(path, Buffer.concat([length, Buffer.from(json), Buffer.alloc(offset)]));
}

/** The source checkpoint: a small supported qwen3 config, bf16 weights, and
 * the tokenizer and template files the loaders read. */
export function writeSourceModel(dir: string): void {
  mkdirSync(dir, { recursive: true });
  writeFileSync(join(dir, "config.json"), JSON.stringify({ model_type: "qwen3", architectures: ["Qwen3ForCausalLM"],
    hidden_size: 64, intermediate_size: 128, num_hidden_layers: 1, num_attention_heads: 2, num_key_value_heads: 2,
    head_dim: 32, vocab_size: 64, rms_norm_eps: 1e-6, tie_word_embeddings: false }));
  writeSafetensors(join(dir, "model.safetensors"), {
    "model.embed_tokens.weight": { dtype: "BF16", shape: [64, 64] },
    "model.layers.0.mlp.down_proj.weight": { dtype: "BF16", shape: [64, 128] },
    "lm_head.weight": { dtype: "BF16", shape: [64, 64] },
  });
  writeFileSync(join(dir, "tokenizer.json"), JSON.stringify({ version: "1.0", model: { type: "BPE", vocab: {}, merges: [] } }));
  writeFileSync(join(dir, "tokenizer_config.json"), JSON.stringify({ eos_token: "<|im_end|>" }));
  writeFileSync(join(dir, "chat_template.jinja"), "{% for m in messages %}{{ m.content }}{% endfor %}");
  writeFileSync(join(dir, "generation_config.json"), JSON.stringify({ temperature: 0.7 }));
}

/** What `quantizeModelDir` publishes for a uniform run, with its own config
 * writer and atomic directory owner; `lm_head` is recorded as a module a
 * quantize predicate left unquantized (`false`). */
export async function writeQuantizedArtifact(srcDir: string, outDir: string, bits: number, groupSize: number): Promise<void> {
  const config = await Bun.file(join(srcDir, "config.json")).json() as Record<string, unknown>;
  await writeAtomicDirectory(outDir, async staging => {
    const packed = (inputs: number) => inputs * bits / 32;
    writeSafetensors(join(staging, "model.safetensors"), {
      "model.embed_tokens.weight": { dtype: "U32", shape: [64, packed(64)] },
      "model.embed_tokens.scales": { dtype: "BF16", shape: [64, 64 / groupSize] },
      "model.embed_tokens.biases": { dtype: "BF16", shape: [64, 64 / groupSize] },
      "model.layers.0.mlp.down_proj.weight": { dtype: "U32", shape: [64, packed(128)] },
      "model.layers.0.mlp.down_proj.scales": { dtype: "BF16", shape: [64, 128 / groupSize] },
      "model.layers.0.mlp.down_proj.biases": { dtype: "BF16", shape: [64, 128 / groupSize] },
      "lm_head.weight": { dtype: "BF16", shape: [64, 64] },
    });
    const perLayer = new Map<string, PerLayerEntry>([
      ["model.embed_tokens", { bits, groupSize }], ["model.layers.0.mlp.down_proj", { bits, groupSize }], ["lm_head", false],
    ]);
    await writeQuantizedConfig(config, staging, buildQuantizationBlock({ bits, groupSize, mode: "affine" }, perLayer), {
      srcDir, optiq: { method: "uniform_affine", base_model: srcDir, bits, group_size: groupSize, achieved_bpw: bits + 0.5, per_layer_count: 2 },
    });
  });
}
