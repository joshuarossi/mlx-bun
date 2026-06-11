// gen-model — emit a per-architecture specialization of the gemma4
// forward pass (optimization_plan.md Phase C). The output is a GENERATED
// file: branch-resolved per-layer helpers (transcribed op-for-op from
// DecoderLayer.forward + Attention.forward with this model's constants
// baked) plus an unrolled forwardLayers override. Layer loop, cache-type
// instanceof dispatch, donor/sharer indirection arrays, MoE/per-layer
// forks: all resolved at generation time from config.json + kv_config.json.
//
//   bun scripts/gen-model.ts <model-dir> <out-stem>
//   e.g. bun scripts/gen-model.ts ~/.cache/.../gemma-4-12B... gemma4-12b
//
// Regenerate, never hand-edit: a base-algorithm change is a regeneration.
// The generated class guards its cache signature per forward call and
// falls back to the monolith for anything it wasn't generated for
// (bf16 compat runs, vision bidir prefill) — opportunistic override,
// nothing ever broken.

import { loadModelConfig } from "../src/config";
import { configFingerprint } from "../src/model/fingerprint";

const [modelDir, outStem] = process.argv.slice(2);
if (!modelDir || !outStem) {
  console.error("usage: bun scripts/gen-model.ts <model-dir> <out-stem>");
  process.exit(1);
}

const config = await loadModelConfig(modelDir);
const t = config.text;
const fingerprint = configFingerprint(config);

// layer_scalar presence is a weights-layout fact: read the shard index
const indexFile = Bun.file(`${modelDir}/model.safetensors.index.json`);
let tensorNames: Set<string>;
if (await indexFile.exists()) {
  const idx = (await indexFile.json()) as { weight_map: Record<string, string> };
  tensorNames = new Set(Object.keys(idx.weight_map));
} else {
  tensorNames = new Set(); // single-shard models: assume no layer_scalar
}
const prefixBase = tensorNames.has("language_model.model.embed_tokens.weight")
  ? "language_model.model" : "model";

const kvByLayer = new Map<number, { groupSize: number; bits: number }>(
  (config.kvQuant ?? []).map((e) => [e.layerIdx, { groupSize: e.groupSize, bits: e.bits }]),
);

const numLayers = t.numHiddenLayers;
const numDonors = numLayers - t.numKvSharedLayers;
const hasMoe = t.enableMoeBlock;
const hasPerLayer = t.hiddenSizePerLayerInput > 0;

interface LayerSpec {
  idx: number;
  sliding: boolean;
  donor: boolean;
  /** donor this sharer consumes (last donor of its type) */
  donorIdx: number;
  /** quantized KV under the shipped kv_config (donors only) */
  quant: boolean;
  /** Phase D constants, folded into the generated dispatch site */
  gs: number;
  bits: number;
  kEqV: boolean;
  layerScalar: boolean;
  /** donor whose fetched KV at least one sharer consumes (export it) */
  exports: boolean;
}

const lastByType: Record<string, number> = {};
for (let i = 0; i < numDonors; i++) lastByType[t.layerTypes[i]!] = i;

const specs: LayerSpec[] = [];
for (let i = 0; i < numLayers; i++) {
  const sliding = t.layerTypes[i] === "sliding_attention";
  const donor = i < numDonors;
  const donorIdx = donor ? i : lastByType[t.layerTypes[i]!]!;
  const kv = donor ? kvByLayer.get(i) : kvByLayer.get(donorIdx);
  specs.push({
    idx: i,
    sliding,
    donor,
    donorIdx,
    quant: donor && kvByLayer.has(i),
    gs: kv?.groupSize ?? 0,
    bits: kv?.bits ?? 0,
    kEqV: t.attentionKEqV && !sliding,
    layerScalar: tensorNames.has(`${prefixBase}.layers.${i}.layer_scalar`),
    exports: false,
  });
}
for (const s of specs) if (!s.donor) specs[s.donorIdx]!.exports = true;

// --- per-layer helper emission ----------------------------------------------

/** One helper per distinct (donor/sharer, quant, kEqV, perLayer, moe,
 *  layerScalar, exports) combination present in this model. */
function helperName(s: LayerSpec): string {
  const quant = s.quant || (!s.donor && specs[s.donorIdx]!.quant);
  return [
    s.donor ? "donor" : "sharer",
    s.sliding ? "Slid" : "Full",
    quant ? `QuantG${s.gs}B${s.bits}` : "Plain",
    s.kEqV ? "KeqV" : "V",
    hasPerLayer ? "Pli" : "",
    hasMoe ? "Moe" : "",
    s.layerScalar ? "Scal" : "",
    s.donor && s.exports ? "Exp" : "",
  ].join("");
}

/** Phase D: the quantized SDPA dispatch with this layer's kv_config
 *  constants FOLDED — (bits, group_size) as literals, the static half of
 *  fusedSdpaSupported pre-resolved at generation time. Together with the
 *  nRep/headDim recorded at the site, every dispatch has a single known
 *  (bits, group_size, nRep, head_dim): the Phase E kernel precondition. */
function emitQuantSdpaDispatch(s: LayerSpec, kqExpr: string, vqExpr: string): string[] {
  const nKv = s.kEqV ? t.numGlobalKeyValueHeads : t.numKeyValueHeads;
  const nRep = t.numAttentionHeads / nKv;
  const headDim = s.sliding ? t.headDim : t.globalHeadDim;
  const staticOk =
    (s.bits === 4 || s.bits === 8) && (s.gs === 32 || s.gs === 64 || s.gs === 128);
  const lines: string[] = [];
  lines.push(`  // dispatch-site constants: bits=${s.bits} group_size=${s.gs} nRep=${nRep} head_dim=${headDim}`);
  if (staticOk) {
    // perf mode first (Phase E fused kernel, frozen-oracle-gated), then
    // the compat tiled/unfused dispatch
    lines.push(`  const attn = perfKernelEnabled() && mask.mode === "" && fusedDecodeKernelSupported(q, ${s.bits}, ${s.gs})`);
    lines.push(`    ? fusedDecodeSdpa(q, ${kqExpr}, ${vqExpr}, ${s.gs}, ${s.bits})`);
    lines.push(`    : (L > 1 || process.env.MLX_BUN_FUSED_DECODE === "1") && fusedSdpaRuntimeOk(q, mask)`);
    lines.push(`      ? quantizedSdpaTiled(q, ${kqExpr}, ${vqExpr}, 1.0, mask, ${s.gs}, ${s.bits})`);
    lines.push(`      : quantizedSdpaUnfused(q, ${kqExpr}, ${vqExpr}, 1.0, mask, ${s.gs}, ${s.bits});`);
  } else {
    lines.push(`  const attn = quantizedSdpaUnfused(q, ${kqExpr}, ${vqExpr}, 1.0, mask, ${s.gs}, ${s.bits});`);
  }
  return lines;
}

function emitHelper(s: LayerSpec): string {
  const name = helperName(s);
  const quant = s.quant || (!s.donor && specs[s.donorIdx]!.quant);
  const cacheTy = quant
    ? (s.sliding ? "RotatingQuantizedKVCache" : "QuantizedKVCache")
    : (s.sliding ? "RotatingKVCache" : "KVCache");
  // NOTE: sharer helpers take the donor's exported fetch instead of a cache.
  const sig = s.donor
    ? `(layer: DecoderLayer, x: MlxArray, mask: Mask, cache: ${cacheTy}${hasPerLayer ? ", pli: MlxArray" : ""})`
    : `(layer: DecoderLayer, x: MlxArray, mask: Mask, shared: SharedKv${hasPerLayer ? ", pli: MlxArray" : ""})`;
  const ret = s.donor && s.exports
    ? `{ h: MlxArray; shared: SharedKv }`
    : `MlxArray`;

  const lines: string[] = [];
  lines.push(`function ${name}${sig}: ${ret} {`);
  lines.push(`  const a = layer.attn;`);
  lines.push(`  const [B, L] = x.shape as [number, number, number];`);
  lines.push(`  let h = layer.inputNorm.forward(x);`);
  lines.push(`  let q = a.qProj.forward(h);`);
  lines.push(`  q = disposing(q, ops.reshape(q, [B, L, a.nHeads, a.headDim]));`);
  lines.push(`  q = disposing(q, a.qNorm.forward(q));`);
  if (s.donor) {
    lines.push(`  const offset = cache.offset;`);
    lines.push(`  let k = a.kProj!.forward(h);`);
    lines.push(`  k = disposing(k, ops.reshape(k, [B, L, a.nKvHeads, a.headDim]));`);
    if (!s.kEqV) {
      lines.push(`  let v = a.vProj!.forward(h);`);
      lines.push(`  v = disposing(v, ops.reshape(v, [B, L, a.nKvHeads, a.headDim]));`);
    }
    lines.push(`  const kNormed = a.kNorm!.forward(k);`);
    lines.push(`  const kT = ops.transposeAxes(kNormed, [0, 2, 1, 3]);`);
    lines.push(`  kNormed.dispose();`);
    lines.push(`  const kRoped = a.rope(kT, cache.ropeOffsetArr ?? offset);`);
    lines.push(`  kT.dispose();`);
    // attention_k_eq_v: V is the K projection through the UNscaled norm
    lines.push(`  const vNormed = a.vNorm!.forward(${s.kEqV ? "k" : "v"});`);
    lines.push(`  const vT = ops.transposeAxes(vNormed, [0, 2, 1, 3]);`);
    lines.push(`  vNormed.dispose();`);
    if (!s.kEqV) lines.push(`  v.dispose();`);
    lines.push(`  k.dispose();`);
    if (quant) {
      lines.push(`  const [kq, vq] = cache.updateAndFetchQuantized(kRoped, vT);`);
      lines.push(`  kRoped.dispose();`);
      lines.push(`  vT.dispose();`);
    } else {
      lines.push(`  const [keys, values] = cache.updateAndFetch(kRoped, vT);`);
      lines.push(`  kRoped.dispose();`);
      lines.push(`  vT.dispose();`);
    }
    lines.push(`  q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));`);
    lines.push(`  q = disposing(q, a.rope(q, cache.ropeOffsetArr ?? offset));`);
    if (quant) {
      lines.push(...emitQuantSdpaDispatch(s, "kq", "vq"));
    } else {
      lines.push(`  const attn = ops.sdpa(q, keys, values, 1.0, mask.mode, mask.arr);`);
    }
  } else {
    // sharer: consume the donor's fetched KV (offsets ride SharedKv)
    lines.push(`  q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));`);
    lines.push(`  q = disposing(q, a.rope(q, shared.offsetArr ?? shared.offset));`);
    if (quant) {
      lines.push(`  if (shared.kind !== "quant") throw new Error("generated sharer expected quant shared KV");`);
      lines.push(...emitQuantSdpaDispatch(s, "shared.keys", "shared.values"));
    } else {
      lines.push(`  if (shared.kind !== "plain") throw new Error("generated sharer expected plain shared KV");`);
      lines.push(`  const attn = ops.sdpa(q, shared.keys, shared.values, 1.0, mask.mode, mask.arr);`);
    }
  }
  lines.push(`  q.dispose();`);
  lines.push(`  const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);`);
  lines.push(`  attn.dispose();`);
  lines.push(`  const merged = ops.reshape(attnT, [B, L, -1]);`);
  lines.push(`  attnT.dispose();`);
  lines.push(`  const out = a.oProj.forward(merged);`);
  lines.push(`  merged.dispose();`);
  lines.push(`  h.dispose();`);
  lines.push(`  h = out;`);
  lines.push(`  h = disposing(h, layer.postAttnNorm.forward(h));`);
  lines.push(`  h = disposing(h, ops.add(x, h));`);
  lines.push(`  const residual = h;`);
  if (hasMoe) {
    lines.push(`  let h1 = layer.preFfNorm.forward(h);`);
    lines.push(`  h1 = disposing(h1, layer.mlp.forward(h1));`);
    lines.push(`  h1 = disposing(h1, layer.postFfNorm1!.forward(h1));`);
    lines.push(`  const { indices, weights: topKWeights } = layer.router!.forward(h);`);
    lines.push(`  let h2 = layer.preFfNorm2!.forward(h);`);
    lines.push(`  h2 = disposing(h2, layer.experts!.forward(h2, indices, topKWeights));`);
    lines.push(`  h2 = disposing(h2, layer.postFfNorm2!.forward(h2));`);
    lines.push(`  indices.dispose();`);
    lines.push(`  topKWeights.dispose();`);
    lines.push(`  let f = ops.add(h1, h2);`);
    lines.push(`  h1.dispose();`);
    lines.push(`  h2.dispose();`);
  } else {
    lines.push(`  let f = layer.preFfNorm.forward(h);`);
    lines.push(`  f = disposing(f, layer.mlp.forward(f));`);
  }
  lines.push(`  f = disposing(f, layer.postFfNorm.forward(f));`);
  lines.push(`  h = ops.add(residual, f);`);
  lines.push(`  residual.dispose();`);
  lines.push(`  f.dispose();`);
  if (hasPerLayer) {
    lines.push(`  const res2 = h;`);
    lines.push(`  let gate = layer.perLayerGate!.forward(h);`);
    lines.push(`  gate = disposing(gate, ops.geluApprox(gate));`);
    lines.push(`  gate = disposing(gate, ops.mul(gate, pli));`);
    lines.push(`  gate = disposing(gate, layer.perLayerProjection!.forward(gate));`);
    lines.push(`  gate = disposing(gate, layer.postPerLayerNorm!.forward(gate));`);
    lines.push(`  h = ops.add(res2, gate);`);
    lines.push(`  res2.dispose();`);
    lines.push(`  gate.dispose();`);
  }
  if (s.layerScalar) {
    lines.push(`  h = disposing(h, ops.mul(h, layer.layerScalar!));`);
  }
  if (s.donor && s.exports) {
    if (quant) {
      lines.push(`  const shared: SharedKv = { kind: "quant", keys: kq, values: vq, offset, groupSize: ${s.gs}, bits: ${s.bits}, offsetArr: cache.ropeOffsetArr };`);
    } else {
      lines.push(`  const shared: SharedKv = { kind: "plain", keys, values, offset, offsetArr: cache.ropeOffsetArr };`);
    }
    lines.push(`  return { h, shared };`);
  } else {
    if (s.donor && quant) {
      lines.push(`  for (const t of [kq, vq]) for (const c of [t.packed, t.scales, t.biases]) c.dispose();`);
    } else if (s.donor) {
      lines.push(`  keys.dispose();`);
      lines.push(`  values.dispose();`);
    }
    lines.push(`  return h;`);
  }
  lines.push(`}`);
  return lines.join("\n");
}

// --- forwardLayers emission ---------------------------------------------------

const firstSliding = specs.findIndex((s) => s.sliding && s.donor);
const firstFull = specs.findIndex((s) => !s.sliding && s.donor);

function cacheClass(s: LayerSpec): string {
  return s.quant
    ? (s.sliding ? "RotatingQuantizedKVCache" : "QuantizedKVCache")
    : (s.sliding ? "RotatingKVCache" : "KVCache");
}

const guardChecks = specs
  .filter((s) => s.donor)
  .map((s) => `cache[${s.idx}] instanceof ${cacheClass(s)}`)
  .join(" &&\n      ");

const bodyLines: string[] = [];
for (const s of specs) {
  const name = helperName(s);
  const pli = hasPerLayer
    ? `, perLayerSlice(perLayer, ${s.idx}, L, this.perLayerWidth)`
    : "";
  const mask = s.sliding ? "maskS" : "maskF";
  if (s.donor && s.exports) {
    bodyLines.push(`    const r${s.idx} = ${name}(this.layers[${s.idx}]!, h, ${mask}, cache[${s.idx}] as ${cacheClass(s)}${pli});`);
    bodyLines.push(`    h.dispose();`);
    bodyLines.push(`    h = r${s.idx}.h;`);
  } else if (s.donor) {
    bodyLines.push(`    next = ${name}(this.layers[${s.idx}]!, h, ${mask}, cache[${s.idx}] as ${cacheClass(s)}${pli});`);
    bodyLines.push(`    h.dispose();`);
    bodyLines.push(`    h = next;`);
  } else {
    bodyLines.push(`    next = ${name}(this.layers[${s.idx}]!, h, ${mask}, r${s.donorIdx}.shared${pli});`);
    bodyLines.push(`    h.dispose();`);
    bodyLines.push(`    h = next;`);
  }
}
// dispose exported donor KV after the pass (mirrors the monolith)
const exportDispose = specs
  .filter((s) => s.donor && s.exports)
  .map((s) => `    disposeSharedKv(r${s.idx}.shared);`)
  .join("\n");

const helperBodies = [...new Map(specs.map((s) => [helperName(s), s])).values()]
  .map(emitHelper)
  .join("\n\n");

const usesPlainPair = specs.some((s) => s.donor && !s.quant);
const usesQuantPair = specs.some((s) => s.quant);

const out = `// GENERATED by scripts/gen-model.ts — DO NOT EDIT (regenerate instead):
//   bun scripts/gen-model.ts <model-dir> ${outStem}
// source: ${modelDir.split("/").slice(-3).join("/")}
// fingerprint: ${fingerprint}
//
// Branch-resolved, unrolled forward pass for this architecture
// (optimization_plan.md Phase C). Bit-exactness vs the monolith is the
// generator's gate: tests/generated-parity.test.ts. The cache-signature
// guard falls back to the monolith for anything this file wasn't
// generated for (bf16 compat runs, vision bidir prefill).

import { MlxArray } from "../../mlx/array";
import * as ops from "../../mlx/ops";
import {
  disposing,
  fusedSdpaRuntimeOk,
  KVCache,
  QuantizedKVCache,
  quantizedSdpaTiled,
  quantizedSdpaUnfused,
  RotatingKVCache,
  RotatingQuantizedKVCache,
  type Cache,
  type Mask,
  type SharedKv,
} from "../gemma4-base";
import {
  fusedDecodeKernelSupported, fusedDecodeSdpa, perfKernelEnabled,
} from "../fused-decode-kernel";
import { Gemma4Model, type DecoderLayer } from "../gemma4";
${hasPerLayer ? `import { isCompiledTrace } from "../gemma4-base";\n` : ""}
export const FINGERPRINT = "${fingerprint}";

/** Forward passes served by the generated fast path (vs monolith
 *  fallback) — the parity gate asserts the fast path actually ran. */
export let generatedForwardUses = 0;

function disposeSharedKv(s: SharedKv): void {
  if (s.kind === "plain") {
    s.keys.dispose();
    s.values.dispose();
  } else {
    for (const t of [s.keys, s.values])
      for (const a of [t.packed, t.scales, t.biases]) a.dispose();
  }
}
${hasPerLayer ? `
/** Per-layer-input split with the layer index baked; DynamicSlice under
 *  a compiled-decode trace (mlx Slice lacks output_shapes), the exact
 *  monolith ops otherwise. */
function perLayerSlice(perLayer: MlxArray, i: number, L: number, width: number): MlxArray {
  let pls: MlxArray;
  if (isCompiledTrace()) {
    const start = ops.fromInt32([i], [1]);
    pls = ops.sliceDynamic(perLayer, start, [2], [1, L, 1, width]);
    start.dispose();
  } else {
    pls = perLayer.slice([0, 0, i, 0], [1, L, i + 1, width]);
  }
  const r = ops.reshape(pls, [1, L, width]);
  pls.dispose();
  return r;
}
` : ""}
${helperBodies}

export class GeneratedGemma4 extends Gemma4Model {
  /** Per-layer cache classes must match what this file was generated
   *  for; anything else runs the monolith path. */
  #matches(cache: Cache[]): boolean {
    return (
      cache.length === ${numDonors} &&
      ${guardChecks}
    );
  }

  protected override forwardLayers(
    h0: MlxArray, cache: Cache[], bidir: MlxArray | null, ids: MlxArray | null,
  ): MlxArray {
    if (bidir !== null${hasPerLayer ? " || ids === null" : ""} || !this.#matches(cache))
      return super.forwardLayers(h0, cache, bidir, ids);
    generatedForwardUses++;
    const L = h0.shape[1]!;
    const maskS = cache[${firstSliding}]!.makeMask(L, this.windowSize);
    const maskF = cache[${firstFull}]!.makeMask(L, null);
${hasPerLayer ? `    const perLayer = this.computePerLayerInputs(ids!, h0);\n` : ""}    let h = h0;
    let next: MlxArray;
${bodyLines.join("\n")}
${exportDispose}
${hasPerLayer ? `    perLayer.dispose();\n` : ""}    maskS.arr?.dispose();
    maskF.arr?.dispose();
    return disposing(h, this.finalNorm.forward(h));
  }
}
`;

// quiet unused-import lint for models that don't use a pair kind
void usesPlainPair;
void usesQuantPair;

const outPath = `${import.meta.dir}/../src/model/generated/${outStem}.ts`;
await Bun.write(outPath, out);
console.log(`wrote ${outPath} (fingerprint ${fingerprint}, ${numLayers} layers, ${numDonors} donors, moe=${hasMoe}, perLayer=${hasPerLayer})`);
