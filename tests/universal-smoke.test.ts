// Universal-dense structural smoke test — NO downloads, NO real weights.
// Builds tiny synthetic bf16 (dense, unquantized — the Phase-1.5 path)
// checkpoints on the fly for archs that exercise distinct descriptor
// branches, then runs load → weight audit → forward → greedy step:
//   llama      llama3-rope, tied head, inv_freq sanitize allowance
//   starcoder2 LayerNorm(+bias), additive bias on every projection, gelu MLP
//   phi3       fused qkv + gate_up (activation split), longrope, untied head
//   gemma2     manual softcap attention, sandwich norms, (1+w) norm,
//              embed scale, final logit softcap, array mask
// Plus the audit negative: an unexpected tensor must fail the LOAD.
//
// This is a structure/shape gate, not a parity gate — bit-exactness vs
// mlx-lm is tests/universal-parity.test.ts (opt-in, real checkpoints).

import { afterAll, describe, expect, test } from "bun:test";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { loadModelConfig } from "../src/config";
import { Weights } from "../src/weights";
import { createModel } from "../src/model/factory";
import { UniversalDenseModel } from "../src/model/universal/dense";
import { writeShardedSafetensors, type NamedTensor } from "../src/quantize/safetensors-writer";
import { MlxArray } from "../src/mlx/array";
import { Dtype } from "../src/mlx/ffi";

const dirs: string[] = [];
afterAll(() => {
  for (const d of dirs) rmSync(d, { recursive: true, force: true });
});

/** Deterministic small-valued bf16 tensor (LCG over the flat index). */
function t(name: string, shape: number[]): NamedTensor {
  const n = shape.reduce((a, b) => a * b, 1);
  const data = new Float32Array(n);
  let s = 0;
  for (const ch of name) s = (s * 31 + ch.charCodeAt(0)) >>> 0;
  for (let i = 0; i < n; i++) {
    s = (s * 1103515245 + 12345) >>> 0;
    data[i] = ((s % 2000) / 1000 - 1) * 0.05;
  }
  const f32 = MlxArray.fromFloat32(data, shape);
  const bf16 = f32.astype(Dtype.bfloat16);
  f32.dispose();
  return { name, array: bf16 };
}

async function makeCheckpoint(
  config: Record<string, unknown>, tensors: NamedTensor[],
): Promise<string> {
  const dir = mkdtempSync(join(tmpdir(), "mlx-bun-universal-smoke-"));
  dirs.push(dir);
  await Bun.write(`${dir}/config.json`, JSON.stringify(config));
  writeShardedSafetensors(dir, tensors);
  for (const { array } of tensors) array.dispose();
  return dir;
}

/** Common per-layer llama-ish attention + swiglu tensors. */
function llamaLayer(i: number, H: number, kv: number, hd: number, hidden: number, inter: number): NamedTensor[] {
  const p = `model.layers.${i}`;
  return [
    t(`${p}.self_attn.q_proj.weight`, [H * hd, hidden]),
    t(`${p}.self_attn.k_proj.weight`, [kv * hd, hidden]),
    t(`${p}.self_attn.v_proj.weight`, [kv * hd, hidden]),
    t(`${p}.self_attn.o_proj.weight`, [hidden, H * hd]),
    t(`${p}.mlp.gate_proj.weight`, [inter, hidden]),
    t(`${p}.mlp.up_proj.weight`, [inter, hidden]),
    t(`${p}.mlp.down_proj.weight`, [hidden, inter]),
    t(`${p}.input_layernorm.weight`, [hidden]),
    t(`${p}.post_attention_layernorm.weight`, [hidden]),
  ];
}

function expectHealthyForward(model: UniversalDenseModel, vocab: number): void {
  const cache = model.makeCache();
  try {
    const logits = model.forward([1, 2, 3], cache);
    expect(logits.shape).toEqual([1, 3, vocab]);
    const f = logits.toFloat32();
    logits.dispose();
    for (const v of f) expect(Number.isFinite(v)).toBe(true);
    // decode one more step through the cache
    const step = model.forward([4], cache);
    expect(step.shape).toEqual([1, 1, vocab]);
    step.dispose();
  } finally {
    for (const c of cache) c.dispose();
  }
}

describe("universal-dense synthetic smoke", () => {
  const hidden = 32, H = 4, kv = 2, hd = 8, inter = 64;

  test("llama: dense weights, llama3 rope, tied head, inv_freq allowance", async () => {
    const vocab = 96;
    const config = {
      model_type: "llama", hidden_size: hidden, num_hidden_layers: 2,
      num_attention_heads: H, num_key_value_heads: kv, head_dim: hd,
      intermediate_size: inter, rms_norm_eps: 1e-5, vocab_size: vocab,
      rope_theta: 500000, max_position_embeddings: 4096, tie_word_embeddings: true,
      rope_scaling: { rope_type: "llama3", factor: 32.0, low_freq_factor: 1.0,
        high_freq_factor: 4.0, original_max_position_embeddings: 8192 },
    };
    const tensors = [
      t("model.embed_tokens.weight", [vocab, hidden]),
      ...llamaLayer(0, H, kv, hd, hidden, inter),
      ...llamaLayer(1, H, kv, hd, hidden, inter),
      t("model.norm.weight", [hidden]),
      // sanitize allowance: mlx-lm drops this on load; audit must too
      t("model.layers.0.self_attn.rotary_emb.inv_freq", [hd / 2]),
    ];
    const dir = await makeCheckpoint(config, tensors);
    const model = createModel(await Weights.open(dir), await loadModelConfig(dir));
    expect(model).toBeInstanceOf(UniversalDenseModel);
    expectHealthyForward(model as UniversalDenseModel, vocab);
  });

  test("llama: an unexpected tensor fails the load (weight audit)", async () => {
    const vocab = 96;
    const config = {
      model_type: "llama", hidden_size: hidden, num_hidden_layers: 1,
      num_attention_heads: H, num_key_value_heads: kv, head_dim: hd,
      intermediate_size: inter, rms_norm_eps: 1e-5, vocab_size: vocab,
      rope_theta: 10000, tie_word_embeddings: true,
    };
    const tensors = [
      t("model.embed_tokens.weight", [vocab, hidden]),
      ...llamaLayer(0, H, kv, hd, hidden, inter),
      t("model.norm.weight", [hidden]),
      t("model.layers.0.mlp.mystery_proj.weight", [8, 8]),
    ];
    const dir = await makeCheckpoint(config, tensors);
    const weights = await Weights.open(dir);
    const config2 = await loadModelConfig(dir);
    expect(() => createModel(weights, config2)).toThrow(/mystery_proj/);
  });

  test("starcoder2: LayerNorm + all-bias projections + gelu MLP", async () => {
    const vocab = 80;
    const config = {
      model_type: "starcoder2", hidden_size: hidden, num_hidden_layers: 1,
      num_attention_heads: H, num_key_value_heads: kv,
      intermediate_size: inter, norm_epsilon: 1e-5, vocab_size: vocab,
      rope_theta: 100000, tie_word_embeddings: true,
    };
    const p = "model.layers.0";
    const scHd = hidden / H; // starcoder2: head_dim = hidden // heads
    const tensors = [
      t("model.embed_tokens.weight", [vocab, hidden]),
      t(`${p}.self_attn.q_proj.weight`, [H * scHd, hidden]), t(`${p}.self_attn.q_proj.bias`, [H * scHd]),
      t(`${p}.self_attn.k_proj.weight`, [kv * scHd, hidden]), t(`${p}.self_attn.k_proj.bias`, [kv * scHd]),
      t(`${p}.self_attn.v_proj.weight`, [kv * scHd, hidden]), t(`${p}.self_attn.v_proj.bias`, [kv * scHd]),
      t(`${p}.self_attn.o_proj.weight`, [hidden, H * scHd]), t(`${p}.self_attn.o_proj.bias`, [hidden]),
      t(`${p}.mlp.c_fc.weight`, [inter, hidden]), t(`${p}.mlp.c_fc.bias`, [inter]),
      t(`${p}.mlp.c_proj.weight`, [hidden, inter]), t(`${p}.mlp.c_proj.bias`, [hidden]),
      t(`${p}.input_layernorm.weight`, [hidden]), t(`${p}.input_layernorm.bias`, [hidden]),
      t(`${p}.post_attention_layernorm.weight`, [hidden]), t(`${p}.post_attention_layernorm.bias`, [hidden]),
      t("model.norm.weight", [hidden]), t("model.norm.bias", [hidden]),
    ];
    const dir = await makeCheckpoint(config, tensors);
    const model = createModel(await Weights.open(dir), await loadModelConfig(dir));
    expect(model).toBeInstanceOf(UniversalDenseModel);
    expectHealthyForward(model as UniversalDenseModel, vocab);
  });

  test("phi3: fused qkv/gate_up, longrope, untied head", async () => {
    const vocab = 80;
    const kvP = H; // phi3-mini style: kv == heads
    const pHd = hidden / H;
    const config = {
      model_type: "phi3", hidden_size: hidden, num_hidden_layers: 1,
      num_attention_heads: H, num_key_value_heads: kvP,
      intermediate_size: inter, rms_norm_eps: 1e-5, vocab_size: vocab,
      rope_theta: 10000, max_position_embeddings: 4096,
      original_max_position_embeddings: 2048,
      rope_scaling: {
        type: "longrope",
        long_factor: [1.0, 1.1, 1.2, 1.3],
        short_factor: [1.0, 1.0, 1.0, 1.0],
      },
    };
    const p = "model.layers.0";
    const opSize = H * pHd + 2 * (kvP * pHd);
    const tensors = [
      t("model.embed_tokens.weight", [vocab, hidden]),
      t(`${p}.self_attn.qkv_proj.weight`, [opSize, hidden]),
      t(`${p}.self_attn.o_proj.weight`, [hidden, H * pHd]),
      t(`${p}.mlp.gate_up_proj.weight`, [2 * inter, hidden]),
      t(`${p}.mlp.down_proj.weight`, [hidden, inter]),
      t(`${p}.input_layernorm.weight`, [hidden]),
      t(`${p}.post_attention_layernorm.weight`, [hidden]),
      t("model.norm.weight", [hidden]),
      t("lm_head.weight", [vocab, hidden]),
    ];
    const dir = await makeCheckpoint(config, tensors);
    const model = createModel(await Weights.open(dir), await loadModelConfig(dir));
    expect(model).toBeInstanceOf(UniversalDenseModel);
    expectHealthyForward(model as UniversalDenseModel, vocab);
  });

  test("gemma2: softcap manual attention, sandwich norms, embed scale", async () => {
    const vocab = 96;
    const config = {
      model_type: "gemma2", hidden_size: hidden, num_hidden_layers: 1,
      num_attention_heads: H, num_key_value_heads: kv, head_dim: hd,
      intermediate_size: inter, rms_norm_eps: 1e-6, vocab_size: vocab,
      rope_theta: 10000, query_pre_attn_scalar: 144.0,
      attn_logit_softcapping: 50.0, final_logit_softcapping: 30.0,
    };
    const p = "model.layers.0";
    const tensors = [
      t("model.embed_tokens.weight", [vocab, hidden]),
      t(`${p}.self_attn.q_proj.weight`, [H * hd, hidden]),
      t(`${p}.self_attn.k_proj.weight`, [kv * hd, hidden]),
      t(`${p}.self_attn.v_proj.weight`, [kv * hd, hidden]),
      t(`${p}.self_attn.o_proj.weight`, [hidden, H * hd]),
      t(`${p}.mlp.gate_proj.weight`, [inter, hidden]),
      t(`${p}.mlp.up_proj.weight`, [inter, hidden]),
      t(`${p}.mlp.down_proj.weight`, [hidden, inter]),
      t(`${p}.input_layernorm.weight`, [hidden]),
      t(`${p}.post_attention_layernorm.weight`, [hidden]),
      t(`${p}.pre_feedforward_layernorm.weight`, [hidden]),
      t(`${p}.post_feedforward_layernorm.weight`, [hidden]),
      t("model.norm.weight", [hidden]),
    ];
    const dir = await makeCheckpoint(config, tensors);
    const model = createModel(await Weights.open(dir), await loadModelConfig(dir));
    expect(model).toBeInstanceOf(UniversalDenseModel);
    expectHealthyForward(model as UniversalDenseModel, vocab);
    // final logit softcap: |logit| ≤ 30
    const m = model as UniversalDenseModel;
    const cache = m.makeCache();
    try {
      const logits = m.forward([1, 2], cache);
      for (const v of logits.toFloat32()) expect(Math.abs(v)).toBeLessThanOrEqual(30);
      logits.dispose();
    } finally {
      for (const c of cache) c.dispose();
    }
  });
});
