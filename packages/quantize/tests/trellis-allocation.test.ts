import { expect, test } from "bun:test";
import { mlxLmPath, parseKMap, treatmentFor, trellisBpw, type TreatmentPolicy } from "../src/trellis-allocation";
import { planQwen35HfFold } from "../src/qwen35-hf-fold";

const LM = "model.language_model.";
const layer = (i: number, mod: string) => `${LM}layers.${i}.${mod}`;

test("a k-map document maps its tensor names into the language-model prefix and validates every k", () => {
  const doc = { budgets: { "3.00": { kmap: { "model.layers.0.mlp.gate_proj": 2, "model.layers.3.mlp.down_proj": 4 },
    affine_map: { "model.layers.1.self_attn.q_proj": 8 } } } };
  const parsed = parseKMap(doc, "3.00");
  expect([...parsed.k]).toEqual([[layer(0, "mlp.gate_proj"), 2], [layer(3, "mlp.down_proj"), 4]]);
  expect([...parsed.affineBits]).toEqual([[layer(1, "self_attn.q_proj"), 8]]);
  expect(() => parseKMap(doc, "2.50", "kmap.json")).toThrow('kmap.json: no budgets["2.50"].kmap (have 3.00)');
  expect(() => parseKMap({}, "3.00")).toThrow('no budgets["3.00"].kmap (have )');
  for (const bad of [0, 9, 2.5]) expect(() => parseKMap({ budgets: { b: { kmap: { "model.layers.0.mlp.up_proj": bad } } } }, "b")).toThrow(`bad k=${bad}`);
});

test("treatments: MLP tensors are trellis-coded along the rotated axis, everything else keeps its affine tier", () => {
  const policy: TreatmentPolicy = { bits: 3, downAxis: "out" };
  expect(treatmentFor(layer(2, "mlp.gate_proj"), policy)).toEqual({ kind: "trellis", axis: 1, k: 3 });
  expect(treatmentFor(layer(2, "mlp.up_proj"), policy)).toEqual({ kind: "trellis", axis: 1, k: 3 });
  expect(treatmentFor(layer(2, "mlp.down_proj"), policy)).toEqual({ kind: "trellis", axis: 0, k: 3 });
  expect(treatmentFor(layer(2, "mlp.down_proj"), { ...policy, downAxis: "in" })).toEqual({ kind: "trellis", axis: 1, k: 3 });
  expect(treatmentFor(layer(2, "self_attn.q_proj"), policy)).toEqual({ kind: "affine", bits: 4 });
  expect(treatmentFor(layer(2, "linear_attn.out_proj"), policy)).toEqual({ kind: "affine", bits: 4 });
  expect(treatmentFor("lm_head", policy)).toEqual({ kind: "affine", bits: 4 });
  expect(treatmentFor(`${LM}embed_tokens`, policy)).toEqual({ kind: "affine", bits: 4 });
  expect(treatmentFor("mtp.fc", policy)).toEqual({ kind: "affine", bits: 3 });
  expect(treatmentFor("mtp.layers.0.mlp.gate_proj", policy)).toEqual({ kind: "affine", bits: 3 });
  expect(treatmentFor("model.visual.merger.linear_fc2", policy)).toEqual({ kind: "bf16" });
  expect(treatmentFor(layer(2, "mlp.gate_proj"), { ...policy, bits: 2 })).toEqual({ kind: "trellis", axis: 1, k: 2 });
});

test("a layer limit leaves later MLPs on the 3-bit base tier; a k-map supplies per-tensor bits and affine overrides", () => {
  const kMap = parseKMap({ budgets: { b: { kmap: { "model.layers.0.mlp.gate_proj": 2 }, affine_map: { "model.layers.0.linear_attn.out_proj": 8 } } } }, "b");
  const policy: TreatmentPolicy = { bits: 3, downAxis: "out", layers: 1, kMap };
  expect(treatmentFor(layer(0, "mlp.gate_proj"), policy)).toEqual({ kind: "trellis", axis: 1, k: 2 });
  expect(treatmentFor(layer(0, "linear_attn.out_proj"), policy)).toEqual({ kind: "affine", bits: 8 });
  expect(treatmentFor(layer(0, "self_attn.o_proj"), policy)).toEqual({ kind: "affine", bits: 4 });
  // out of scope: no k-map entry needed and the base tier applies
  expect(treatmentFor(layer(1, "mlp.gate_proj"), policy)).toEqual({ kind: "affine", bits: 3 });
  expect(treatmentFor(layer(1, "mlp.down_proj"), policy)).toEqual({ kind: "affine", bits: 3 });
  // in scope without an entry is an error, never a silent default
  expect(() => treatmentFor(layer(0, "mlp.up_proj"), policy)).toThrow(`no entry for in-scope trellis tensor ${layer(0, "mlp.up_proj")}`);
});

test("coded cost is k bits plus one fp16 scale per coded row; module paths map into mlx-lm's key space", () => {
  expect(trellisBpw(256, 3)).toBe(3 + 16 / 256);
  expect(trellisBpw(5120, 2)).toBeCloseTo(2.003125, 12);
  expect(mlxLmPath(layer(4, "mlp.up_proj"))).toBe("language_model.model.layers.4.mlp.up_proj");
  expect(mlxLmPath("lm_head")).toBe("language_model.lm_head");
  expect(mlxLmPath("mtp.fc")).toBeNull();
  expect(mlxLmPath("model.visual.merger.linear_fc2")).toBeNull();
});

// --- fold plan --------------------------------------------------------------
function source(names: Record<string, number[]>) {
  return { tensorNames: Object.keys(names), has: (n: string) => n in names, info: (n: string) => ({ shape: names[n]! }) };
}
function trunk(layers: string[], extra: Record<string, number[]> = {}) {
  const t: Record<string, number[]> = { [`${LM}embed_tokens.weight`]: [8, 4], [`${LM}norm.weight`]: [4], "lm_head.weight": [8, 4], ...extra };
  layers.forEach((type, i) => {
    t[layer(i, "input_layernorm.weight")] = [4]; t[layer(i, "post_attention_layernorm.weight")] = [4];
    for (const m of ["mlp.gate_proj", "mlp.up_proj", "mlp.down_proj"]) t[layer(i, `${m}.weight`)] = [4, 4];
    if (type === "linear_attention") {
      for (const m of ["in_proj_qkv", "in_proj_z", "in_proj_b", "in_proj_a", "out_proj"]) t[layer(i, `linear_attn.${m}.weight`)] = [4, 4];
      t[layer(i, "linear_attn.norm.weight")] = [4]; t[layer(i, "linear_attn.conv1d.weight")] = [4, 1, 4];
    } else {
      for (const m of ["q_proj", "k_proj", "v_proj", "o_proj"]) t[layer(i, `self_attn.${m}.weight`)] = [4, 4];
      t[layer(i, "self_attn.q_norm.weight")] = [4]; t[layer(i, "self_attn.k_norm.weight")] = [4];
    }
  });
  return t;
}

test("the fold plan folds readers with their preceding γ and writers on the output dim, per layer type", () => {
  const types = ["linear_attention", "full_attention"];
  const plan = planQwen35HfFold(source(trunk(types)), { numHiddenLayers: 2, layerTypes: types });
  expect(plan.ops.get(`${LM}embed_tokens.weight`)).toEqual({ kind: "input" });
  expect(plan.ops.get("lm_head.weight")).toEqual({ kind: "input", gamma: `${LM}norm.weight` });
  expect(plan.ops.get(layer(0, "linear_attn.in_proj_qkv.weight"))).toEqual({ kind: "input", gamma: layer(0, "input_layernorm.weight") });
  expect(plan.ops.get(layer(0, "linear_attn.out_proj.weight"))).toEqual({ kind: "output" });
  expect(plan.ops.get(layer(1, "self_attn.k_proj.weight"))).toEqual({ kind: "input", gamma: layer(1, "input_layernorm.weight") });
  expect(plan.ops.get(layer(1, "self_attn.o_proj.weight"))).toEqual({ kind: "output" });
  expect(plan.ops.get(layer(1, "mlp.up_proj.weight"))).toEqual({ kind: "input", gamma: layer(1, "post_attention_layernorm.weight") });
  expect(plan.ops.get(layer(1, "mlp.down_proj.weight"))).toEqual({ kind: "output" });
  expect(plan.ops.has(layer(0, "self_attn.q_proj.weight"))).toBe(false);
  expect(plan.gammaNames).toEqual([`${LM}norm.weight`, layer(0, "input_layernorm.weight"), layer(0, "post_attention_layernorm.weight"),
    layer(1, "input_layernorm.weight"), layer(1, "post_attention_layernorm.weight")]);
  expect(new Set(plan.gammaNames)).toEqual(plan.zeroNorms);
});

test("the vision merger and the MTP companion are folded when present and absent otherwise", () => {
  const types = ["full_attention"];
  const bare = planQwen35HfFold(source(trunk(types)), { numHiddenLayers: 1, layerTypes: types });
  expect([...bare.ops.keys()].some(n => n.startsWith("mtp.") || n.includes("visual"))).toBe(false);
  const extra: Record<string, number[]> = {
    "model.visual.merger.linear_fc2.weight": [4, 6], "model.visual.merger.linear_fc2.bias": [4],
    "mtp.fc.weight": [4, 8], "mtp.pre_fc_norm_embedding.weight": [4], "mtp.pre_fc_norm_hidden.weight": [4], "mtp.norm.weight": [4],
  };
  for (const [n, shape] of Object.entries(trunk(types))) if (n.includes("layers.0.")) extra[n.replace("model.language_model.layers.0.", "mtp.layers.0.")] = shape;
  const full = planQwen35HfFold(source(trunk(types, extra)), { numHiddenLayers: 1, layerTypes: types });
  expect(full.ops.get("model.visual.merger.linear_fc2.weight")).toEqual({ kind: "output" });
  expect(full.ops.get("model.visual.merger.linear_fc2.bias")).toEqual({ kind: "bias" });
  expect(full.ops.get("mtp.fc.weight")).toEqual({ kind: "mtp-fc", gammaEmbed: "mtp.pre_fc_norm_embedding.weight", gammaHidden: "mtp.pre_fc_norm_hidden.weight" });
  expect(full.ops.get("mtp.layers.0.mlp.down_proj.weight")).toEqual({ kind: "output" });
  expect(full.zeroNorms.has("mtp.norm.weight")).toBe(true);
  expect(full.gammaNames).not.toContain("mtp.norm.weight");
});

test("a plan refuses a missing trunk tensor and any unplanned 2-D trunk tensor", () => {
  const types = ["full_attention"], arch = { numHiddenLayers: 1, layerTypes: types };
  const missing = trunk(types); delete missing[layer(0, "mlp.up_proj.weight")];
  expect(() => planQwen35HfFold(source(missing), arch)).toThrow(`missing source tensor ${layer(0, "mlp.up_proj.weight")}`);
  const noGamma = trunk(types); delete noGamma[`${LM}norm.weight`];
  expect(() => planQwen35HfFold(source(noGamma), arch)).toThrow("missing");
  expect(() => planQwen35HfFold(source(trunk(types, { [layer(0, "mlp.router.weight")]: [4, 4] })), arch)).toThrow("unplanned 2-D trunk tensors");
});
