import { afterAll, describe, expect, test } from "bun:test";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray, cpuStream } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import { Weights, createModel, generate, loadModelConfig } from "@mlx-bun/inference";
import { writeShardedSafetensors, type NamedTensor } from "@mlx-bun/inference/artifacts";
import { TRELLIS_L, TRELLIS_T, lut1mad, unpackDecodeHost } from "../src/trellis";
import { quantizeTrellisModelDir } from "../src/trellis-quantizer";

// End to end on a synthetic Qwen3.5-layout checkpoint: fold, encode, write,
// then load the artifact through the inference package. Real weights are not needed.

const root = mkdtempSync(join(tmpdir(), "mlx-bun-trellis-quantizer-"));
afterAll(() => rmSync(root, { recursive: true, force: true }));

const H = 256, I = 512, V = 512;
const LM = "model.language_model.";
const layerTypes = ["linear_attention", "full_attention"];

function values(count: number, seed: number, std: number, mean = 0): Float32Array {
  const out = new Float32Array(count);
  let s = seed >>> 0;
  const u = () => { s = (Math.imul(s, 1664525) + 1013904223) >>> 0; return (s + 1) / 4294967297; };
  for (let i = 0; i < count; i += 2) {
    const r = Math.sqrt(-2 * Math.log(u())), t = 2 * Math.PI * u();
    out[i] = mean + std * r * Math.cos(t);
    if (i + 1 < count) out[i + 1] = mean + std * r * Math.sin(t);
  }
  return out;
}

function checkpoint(name: string, h = H): { dir: string; tensors: Map<string, Float32Array> } {
  const tensors = new Map<string, Float32Array>(), shapes = new Map<string, number[]>();
  let seed = 100;
  const add = (n: string, shape: number[], std: number, mean = 0) => {
    tensors.set(n, values(shape.reduce((a, b) => a * b, 1), seed++, std, mean)); shapes.set(n, shape);
  };
  const w = (n: string, r: number, c: number) => add(n, [r, c], 0.05);
  const block = (P: string, linear: boolean) => {
    add(`${P}.input_layernorm.weight`, [h], 0.1); add(`${P}.post_attention_layernorm.weight`, [h], 0.1);
    if (linear) {
      add(`${P}.linear_attn.A_log`, [2], 0.1, 0.5); add(`${P}.linear_attn.dt_bias`, [2], 0.1, 1);
      add(`${P}.linear_attn.conv1d.weight`, [256, 1, 4], 0.2);
      w(`${P}.linear_attn.in_proj_a.weight`, 2, h); w(`${P}.linear_attn.in_proj_b.weight`, 2, h);
      w(`${P}.linear_attn.in_proj_qkv.weight`, 256, h); w(`${P}.linear_attn.in_proj_z.weight`, 128, h);
      add(`${P}.linear_attn.norm.weight`, [64], 0.05, 1); w(`${P}.linear_attn.out_proj.weight`, h, 128);
    } else {
      w(`${P}.self_attn.q_proj.weight`, 256, h); w(`${P}.self_attn.k_proj.weight`, 64, h);
      w(`${P}.self_attn.v_proj.weight`, 64, h); w(`${P}.self_attn.o_proj.weight`, h, 128);
      add(`${P}.self_attn.q_norm.weight`, [64], 0.1); add(`${P}.self_attn.k_norm.weight`, [64], 0.1);
    }
    w(`${P}.mlp.gate_proj.weight`, I, h); w(`${P}.mlp.up_proj.weight`, I, h); w(`${P}.mlp.down_proj.weight`, h, I);
  };
  w(`${LM}embed_tokens.weight`, V, h); add(`${LM}norm.weight`, [h], 0.1); w("lm_head.weight", V, h);
  layerTypes.forEach((type, i) => block(`${LM}layers.${i}`, type === "linear_attention"));
  w("model.visual.merger.linear_fc2.weight", h, 128); add("model.visual.merger.linear_fc2.bias", [h], 0.1);
  w("model.visual.blocks.0.attn.qkv.weight", 192, 128);
  w("mtp.fc.weight", h, 2 * h); add("mtp.pre_fc_norm_embedding.weight", [h], 0.1); add("mtp.pre_fc_norm_hidden.weight", [h], 0.1);
  add("mtp.norm.weight", [h], 0.1); block("mtp.layers.0", false);

  const dir = join(root, name);
  mkdirSync(dir);
  const named: NamedTensor[] = [...tensors].map(([n, data]) => {
    const f32 = MlxArray.fromFloat32(data, shapes.get(n)!), array = f32.astype(Dtype.bfloat16, cpuStream);
    f32.dispose();
    return { name: n, array };
  });
  writeShardedSafetensors(dir, named, { shardBytes: 1_000_000 });
  for (const { array } of named) array.dispose();
  const text = { attn_output_gate: true, full_attention_interval: 2, head_dim: 64, hidden_act: "silu", hidden_size: h, intermediate_size: I,
    layer_types: layerTypes, linear_conv_kernel_dim: 4, linear_key_head_dim: 64, linear_num_key_heads: 1, linear_num_value_heads: 2,
    linear_value_head_dim: 64, max_position_embeddings: 512, model_type: "qwen3_5_text", num_attention_heads: 2, num_hidden_layers: 2,
    num_key_value_heads: 1, partial_rotary_factor: 0.25, rms_norm_eps: 1e-6, tie_word_embeddings: false, vocab_size: V, eos_token_id: 3,
    rope_parameters: { mrope_interleaved: true, mrope_section: [2, 1, 1], partial_rotary_factor: 0.25, rope_theta: 10000000, rope_type: "default" } };
  writeFileSync(join(dir, "config.json"), JSON.stringify({ architectures: ["Qwen3_5ForConditionalGeneration"], model_type: "qwen3_5",
    tie_word_embeddings: false, text_config: text, vision_config: { depth: 1, hidden_size: 128, out_hidden_size: h, model_type: "qwen3_5" } }));
  writeFileSync(join(dir, "tokenizer.json"), "{}");
  return { dir, tensors };
}

const source = checkpoint("source");
const configOf = (dir: string) => JSON.parse(readFileSync(join(dir, "config.json"), "utf8")) as { quantization: Record<string, any> };
const weightBytes = (dir: string) => readdirSync(dir).filter(f => f.endsWith(".safetensors")).sort()
  .map(f => new Bun.CryptoHasher("sha256").update(readFileSync(join(dir, f))).digest("hex"));

async function tensorsOf(dir: string) {
  const weights = await Weights.open(dir);
  return {
    names: weights.tensorNames,
    shape: (n: string) => weights.tensor(n).shape,
    dtype: (n: string) => weights.tensor(n).dtype,
    floats: (n: string) => { using f = weights.tensor(n).astype(Dtype.float32, cpuStream); return f.toFloat32(); },
    words: (n: string) => { const raw = weights.tensor(n).rawBytes(); return new Uint32Array(raw.buffer, raw.byteOffset, raw.byteLength / 4).slice(); },
    close: () => weights.dispose(),
  };
}

const base = join(root, "base");
const trellisModules = [0, 1].flatMap(i => ["gate_proj", "up_proj", "down_proj"].map(m => `${LM}layers.${i}.mlp.${m}`));

describe("packed-Trellis quantization of a synthetic Qwen3.5-layout checkpoint", () => {
  test("every MLP tensor is packed, everything else keeps its tier, and the config records both key spaces", async () => {
    const progress: string[] = [];
    const result = await quantizeTrellisModelDir(source.dir, base, {}, e => progress.push(e.stage));
    expect(result).toMatchObject({ outDir: base, nTrellis: 6, reused: 0, ldlq: null });
    expect(progress[0]).toBe("loading");
    expect(progress.at(-1)).toBe("done");
    expect(readdirSync(root).filter(n => n.startsWith(".base.tmp-"))).toEqual([]);

    const { quantization } = configOf(base);
    expect(quantization).toMatchObject({ bits: 3, group_size: 64, mode: "affine" });
    for (const module of trellisModules) {
      const axis = module.endsWith("down_proj") ? 0 : 1;
      const entry = { bits: 3, group_size: TRELLIS_T, mode: "trellis", trellis: { L: TRELLIS_L, code: "1mad", axis } };
      expect(quantization[module]).toEqual(entry);
      expect(quantization[module.replace(LM, "language_model.model.")]).toEqual(entry);
    }
    expect(quantization["lm_head"]).toEqual({ bits: 4, group_size: 64 });
    expect(quantization[`${LM}layers.1.self_attn.q_proj`]).toEqual({ bits: 4, group_size: 64 });
    expect(quantization[`${LM}layers.0.linear_attn.in_proj_qkv`]).toEqual({ bits: 4, group_size: 64 });
    expect(quantization["model.visual.blocks.0.attn.qkv"]).toBe(false);
    expect(quantization["mtp.fc"]).toBeUndefined(); // base tier

    const out = await tensorsOf(base);
    try {
      const gate = `${LM}layers.0.mlp.gate_proj`, down = `${LM}layers.1.mlp.down_proj`;
      expect(out.shape(`${gate}.weight`)).toEqual([I, (H * 3) / 32]);
      expect(out.dtype(`${gate}.weight`)).toBe(Dtype.uint32);
      expect(out.shape(`${gate}.scales`)).toEqual([I]);
      expect(out.dtype(`${gate}.scales`)).toBe(Dtype.float16);
      expect(out.shape(`${down}.weight`)).toEqual([I, (H * 3) / 32]); // axis 0 stores the transpose
      expect(out.names.includes(`${gate}.biases`)).toBe(false);
      expect(out.dtype(`${LM}layers.1.self_attn.q_proj.weight`)).toBe(Dtype.uint32);
      expect(out.names.includes(`${LM}layers.1.self_attn.q_proj.biases`)).toBe(true);
      // Folded γ is written as zeros (the loader adds 1); untouched tensors pass through.
      for (const n of [`${LM}norm.weight`, `${LM}layers.0.input_layernorm.weight`, `${LM}layers.1.post_attention_layernorm.weight`, "mtp.norm.weight"])
        expect(out.floats(n).every(v => v === 0)).toBe(true);
      expect(out.floats("model.visual.blocks.0.attn.qkv.weight")).toEqual(new Float32Array(source.tensors.get("model.visual.blocks.0.attn.qkv.weight")!.map(v => bf16(v))));

      // The fold is an orthogonal rotation of γ-scaled weights, so ‖W'‖_F = ‖W ⊙ (stored+1)‖_F
      // regardless of the seed; the decoded packed tensor must land within quantization error of it.
      const gamma = source.tensors.get(`${LM}layers.0.post_attention_layernorm.weight`)!.map(v => 1 + bf16(v));
      const original = source.tensors.get(`${gate}.weight`)!;
      let expected = 0;
      for (let r = 0; r < I; r++) for (let c = 0; c < H; c++) expected += (bf16(original[r * H + c]!) * gamma[c]!) ** 2;
      const decoded = unpackDecodeHost(out.words(`${gate}.weight`), out.floats(`${gate}.scales`), I, H, 3, TRELLIS_T, lut1mad(TRELLIS_L));
      let actual = 0;
      for (const v of decoded) actual += v * v;
      expect(Math.sqrt(actual / expected)).toBeGreaterThan(0.95);
      expect(Math.sqrt(actual / expected)).toBeLessThan(1.05);
    } finally { out.close(); }
    const meta = JSON.parse(readFileSync(join(base, "optiq_metadata.json"), "utf8"));
    expect(meta.trellis).toMatchObject({ L: 12, block: 256, k: 3, modules: 6, tail_biting: true, ldlq: null, k_map: null, reused_from: null });
    expect(meta.affine_modules).toBe(result.nAffine);
    expect(JSON.parse(readFileSync(join(base, "turboquant_fold.json"), "utf8"))).toMatchObject({ seed: 42, r1: true, r2: false, hiddenSize: H });
    expect(existsSync(join(base, "tokenizer.json"))).toBe(true);
  });

  test("the same inputs produce the same bytes; the rotation seed changes them", async () => {
    const again = join(root, "again"), reseeded = join(root, "reseeded");
    await quantizeTrellisModelDir(source.dir, again);
    await quantizeTrellisModelDir(source.dir, reseeded, { seed: 7 });
    expect(weightBytes(again)).toEqual(weightBytes(base));
    expect(readFileSync(join(again, "config.json"))).toEqual(readFileSync(join(base, "config.json")));
    expect(weightBytes(reseeded)).not.toEqual(weightBytes(base));
  });

  test("reuse copies unchanged-geometry tensors byte for byte and encodes only what changed", async () => {
    const kmapPath = join(root, "kmap.json");
    writeFileSync(kmapPath, JSON.stringify({ budgets: { "3.00": {
      kmap: Object.fromEntries(trellisModules.map(m => [m.replace(LM, "model."), m.endsWith("layers.0.mlp.up_proj") ? 2 : 3])),
      affine_map: { "model.layers.0.linear_attn.out_proj": 8 } } } }));
    const variant = join(root, "variant");
    const result = await quantizeTrellisModelDir(source.dir, variant, { kMap: { path: kmapPath }, reuse: [base] });
    expect(result.reused).toBe(5); // all but the one tensor whose k changed
    const { quantization } = configOf(variant);
    expect(quantization[`${LM}layers.0.mlp.up_proj`]).toMatchObject({ bits: 2, mode: "trellis" });
    expect(quantization[`${LM}layers.0.linear_attn.out_proj`]).toEqual({ bits: 8, group_size: 64 });
    const a = await tensorsOf(base), b = await tensorsOf(variant);
    try {
      for (const m of trellisModules.filter(m => !m.endsWith("layers.0.mlp.up_proj")))
        for (const part of ["weight", "scales"]) expect(b.words(`${m}.${part}`)).toEqual(a.words(`${m}.${part}`));
      expect(b.shape(`${LM}layers.0.mlp.up_proj.weight`)).toEqual([I, (H * 2) / 32]);
    } finally { a.close(); b.close(); }
    const meta = JSON.parse(readFileSync(join(variant, "optiq_metadata.json"), "utf8"));
    expect(meta.trellis.k).toBe("mixed (see k_map)");
    expect(meta.trellis.k_map.modules_by_k).toEqual({ k2: 1, k3: 5 });
    expect(meta.trellis.reused_from).toEqual({ tensors: 5, sources: { [base]: 5 } });
  });

  test("Hessian factors switch a tensor to BlockLDLQ; a missing factor stays unweighted and is counted", async () => {
    const hessians = join(root, "hessians");
    mkdirSync(hessians);
    // A zero factor has no feedback, so its codes must equal the unweighted encoding of the same tensor.
    using zeros = MlxArray.fromFloat32(new Float32Array(H * H), [H, H]);
    const tmp = join(root, "factor-src");
    mkdirSync(tmp);
    writeShardedSafetensors(tmp, [{ name: "L", array: zeros }], { shardBytes: 1_000_000 });
    const shard = readdirSync(tmp).find(f => f.endsWith(".safetensors"))!;
    writeFileSync(join(hessians, "layer-000-mlp.safetensors"), readFileSync(join(tmp, shard)));
    writeFileSync(join(hessians, "state.json"), JSON.stringify({ calibration: { corpus: "synthetic" } }));
    const weighted = join(root, "weighted");
    const result = await quantizeTrellisModelDir(source.dir, weighted, { ldlq: hessians });
    expect(result.ldlq).toEqual({ applied: 2, guardTrips: 0, missingFactors: 4, trippedTensors: [] }); // layer 0 gate+up
    const a = await tensorsOf(base), b = await tensorsOf(weighted);
    try {
      for (const m of trellisModules) for (const part of ["weight", "scales"])
        expect(b.words(`${m}.${part}`), `${m}.${part}`).toEqual(a.words(`${m}.${part}`));
    } finally { a.close(); b.close(); }
    const meta = JSON.parse(readFileSync(join(weighted, "optiq_metadata.json"), "utf8"));
    expect(meta.trellis.ldlq).toMatchObject({ hessians, applied: 2, guard_trips: 0, missing_L: 4, calibration: { corpus: "synthetic" } });
  });

  test("down_proj along the input dim, a layer limit, and interleaving change the layout exactly as declared", async () => {
    const shaped = join(root, "shaped");
    const result = await quantizeTrellisModelDir(source.dir, shaped, { downAxis: "in", layers: 1 });
    expect(result.nTrellis).toBe(3);
    const { quantization } = configOf(shaped);
    expect(quantization[`${LM}layers.0.mlp.down_proj`]).toMatchObject({ trellis: { axis: 1 } });
    expect(quantization[`${LM}layers.1.mlp.gate_proj`]).toBeUndefined(); // 3-bit base tier, not trellis
    const out = await tensorsOf(shaped);
    try {
      expect(out.shape(`${LM}layers.0.mlp.down_proj.weight`)).toEqual([H, (I * 3) / 32]);
      expect(out.names.includes(`${LM}layers.1.mlp.gate_proj.biases`)).toBe(true);
    } finally { out.close(); }

    // axis-0 k=3 codes with whole 48-word groups (a coded dim of 512) interleave into [words/48, rows, 48]; gate/up never do
    const wide = checkpoint("wide-source", 512), plain = join(root, "wide-plain"), interleaved = join(root, "wide-interleaved");
    await quantizeTrellisModelDir(wide.dir, plain, { layers: 1 });
    expect((await quantizeTrellisModelDir(wide.dir, interleaved, { layers: 1, interleave: true })).nTrellis).toBe(3);
    const a = await tensorsOf(plain), b = await tensorsOf(interleaved);
    try {
      const down = `${LM}layers.0.mlp.down_proj.weight`, gate = `${LM}layers.0.mlp.gate_proj.weight`;
      expect(a.shape(down)).toEqual([I, 48]);
      expect(b.shape(down)).toEqual([1, I, 48]);
      const rowMajor = a.words(down), grouped = b.words(down);
      expect(grouped).toEqual(rowMajor); // one group per row: the layouts hold the same words
      expect(b.words(gate)).toEqual(a.words(gate));
      expect(b.shape(gate)).toEqual(a.shape(gate));
    } finally { a.close(); b.close(); }
  });

  test("refusals: a quantized source, a missing trunk tensor, an occupied output, bad options", async () => {
    const quantized = checkpoint("quantized-source");
    const config = JSON.parse(readFileSync(join(quantized.dir, "config.json"), "utf8"));
    writeFileSync(join(quantized.dir, "config.json"), JSON.stringify({ ...config, quantization: { bits: 4, group_size: 64 } }));
    await expect(quantizeTrellisModelDir(quantized.dir, join(root, "never-1"))).rejects.toThrow("already quantized");
    expect(existsSync(join(root, "never-1"))).toBe(false);

    await expect(quantizeTrellisModelDir(source.dir, base)).rejects.toThrow("output directory already exists");
    await expect(quantizeTrellisModelDir(source.dir, join(root, "never-2"), { bits: 9 })).rejects.toThrow("trellis bits must be an integer in [1, 8]");
    await expect(quantizeTrellisModelDir(source.dir, join(root, "never-3"), { kMap: { path: join(root, "kmap.json"), budget: "9.99" } })).rejects.toThrow('no budgets["9.99"].kmap');
    expect(readdirSync(root).filter(n => n.startsWith(".never-"))).toEqual([]);
  });

  test("the artifact loads in the inference package and greedy-decodes deterministically", async () => {
    const config = await loadModelConfig(base);
    const weights = await Weights.open(base);
    try {
      const graph = createModel(weights, config);
      const run = async () => {
        const tokens: number[] = [];
        for await (const { token } of generate(graph, [5, 17, 99, 250], { maxTokens: 4, temperature: 0, eosTokenIds: [] })) tokens.push(token);
        return tokens;
      };
      const first = await run();
      expect(first).toHaveLength(4);
      expect(first.every(t => Number.isInteger(t) && t >= 0 && t < V)).toBe(true);
      expect(await run()).toEqual(first);
    } finally { weights.dispose(); }
  });
});

/** bf16 round-to-nearest-even of a float32 value. */
function bf16(x: number): number {
  const view = new DataView(new ArrayBuffer(4));
  view.setFloat32(0, x);
  const bits = view.getUint32(0);
  view.setUint32(0, ((bits + 0x7fff + ((bits >>> 16) & 1)) & 0xffff0000) >>> 0);
  return view.getFloat32(0);
}
