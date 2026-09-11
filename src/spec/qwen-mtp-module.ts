// Qwen MTP numerical graph. Request state, sampling and checkpoint retention
// belong to its callers; the cache supplies positions and attention storage.
import type { MlxArray } from "../mlx/array";
import * as ops from "../mlx/ops";
import type { ModelConfig } from "../config";
import type { Weights } from "../weights";
import { disposing, QuantizedLinear, RMSNorm, type Cache, type Mask } from "../model/gemma4-base";
import { DenseLinear } from "../model/universal/modules";
import { compiledSwiglu } from "../model/qwen3_5";

type MtpLinear = DenseLinear | QuantizedLinear;

/** Projection tensors belong to Weights; dense transpose views belong to
 *  the provider's resource stack. Quantized heads keep no dense copy. */
function loadMtpLinear(
  weights: Weights, path: string, config: ModelConfig, resources: DisposableStack,
): MtpLinear {
  if (weights.has(`${path}.scales`)) return QuantizedLinear.load(weights, path, config);
  const layer = new DenseLinear(weights.tensor(`${path}.weight`), null);
  resources.use(layer.wT);
  return layer;
}

/** Qwen3Attention.forward with the companion's dense or quantized projections.
 *  Attention operations follow src/model/qwen3_5.ts verbatim. */
class MtpAttention {
  readonly qProj: MtpLinear;
  readonly kProj: MtpLinear;
  readonly vProj: MtpLinear;
  readonly oProj: MtpLinear;
  readonly qNorm: RMSNorm;
  readonly kNorm: RMSNorm;
  readonly nHeads: number;
  readonly nKvHeads: number;
  readonly headDim: number;
  readonly scale: number;
  readonly ropeDims: number;
  readonly ropeBase: number;

  constructor(weights: Weights, config: ModelConfig, prefix: string, resources: DisposableStack) {
    const t = config.text;
    this.nHeads = t.numAttentionHeads;
    this.nKvHeads = t.numKeyValueHeads;
    this.headDim = t.headDim;
    this.scale = Math.pow(this.headDim, -0.5);
    this.ropeDims = Math.trunc(this.headDim * t.partialRotaryFactor);
    this.ropeBase = t.ropeParameters.full_attention?.ropeTheta ?? 10000;
    this.qProj = loadMtpLinear(weights, `${prefix}.q_proj`, config, resources);
    this.kProj = loadMtpLinear(weights, `${prefix}.k_proj`, config, resources);
    this.vProj = loadMtpLinear(weights, `${prefix}.v_proj`, config, resources);
    this.oProj = loadMtpLinear(weights, `${prefix}.o_proj`, config, resources);
    this.qNorm = new RMSNorm(weights.tensor(`${prefix}.q_norm.weight`), t.rmsNormEps);
    this.kNorm = new RMSNorm(weights.tensor(`${prefix}.k_norm.weight`), t.rmsNormEps);
  }

  forward(x: MlxArray, mask: Mask, cache: Cache): MlxArray {
    const [B, L] = x.shape as [number, number, number];
    const qp = this.qProj.forward(x);
    const qpr = disposing(qp, ops.reshape(qp, [B, L, this.nHeads, this.headDim * 2]));
    const [qHeads, gateHeads] = ops.split(qpr, [this.headDim], -1) as [MlxArray, MlxArray];
    qpr.dispose();
    const gate = disposing(gateHeads, ops.reshape(gateHeads, [B, L, this.nHeads * this.headDim]));

    let k = this.kProj.forward(x);
    let v = this.vProj.forward(x);

    let q = this.qNorm.forward(qHeads);
    qHeads.dispose();
    q = disposing(q, ops.transposeAxes(q, [0, 2, 1, 3]));
    k = disposing(k, ops.reshape(k, [B, L, this.nKvHeads, this.headDim]));
    k = disposing(k, this.kNorm.forward(k));
    k = disposing(k, ops.transposeAxes(k, [0, 2, 1, 3]));
    v = disposing(v, ops.reshape(v, [B, L, this.nKvHeads, this.headDim]));
    v = disposing(v, ops.transposeAxes(v, [0, 2, 1, 3]));

    const offsets = cache.ropeOffsetArr;
    q = disposing(q, offsets
      ? ops.ropeDynamic(q, this.ropeDims, this.ropeBase, offsets, null)
      : ops.rope(q, this.ropeDims, this.ropeBase, cache.offset, null));
    k = disposing(k, offsets
      ? ops.ropeDynamic(k, this.ropeDims, this.ropeBase, offsets, null)
      : ops.rope(k, this.ropeDims, this.ropeBase, cache.offset, null));

    const [keys, values] = cache.updateAndFetch(k, v);
    k.dispose();
    v.dispose();
    const attn = ops.sdpa(q, keys, values, this.scale, mask.mode, mask.arr);
    keys.dispose();
    values.dispose();
    q.dispose();

    const attnT = ops.transposeAxes(attn, [0, 2, 1, 3]);
    attn.dispose();
    const merged = ops.reshape(attnT, [B, L, -1]);
    attnT.dispose();
    const sig = ops.sigmoid(gate);
    gate.dispose();
    const gated = ops.mul(merged, sig);
    merged.dispose();
    sig.dispose();
    const out = this.oProj.forward(gated);
    gated.dispose();
    return out;
  }
}

/** The one MTP decoder block: fc-merge → attention → swiglu MLP → norm. */
export class MtpModule {
  readonly fc: MtpLinear;
  readonly preFcNormEmbedding: RMSNorm;
  readonly preFcNormHidden: RMSNorm;
  readonly attn: MtpAttention;
  readonly mlpGate: MtpLinear;
  readonly mlpUp: MtpLinear;
  readonly mlpDown: MtpLinear;
  readonly inputNorm: RMSNorm;
  readonly postAttnNorm: RMSNorm;
  readonly finalNorm: RMSNorm;

  constructor(weights: Weights, config: ModelConfig, resources: DisposableStack) {
    const eps = config.text.rmsNormEps;
    this.fc = loadMtpLinear(weights, "fc", config, resources);
    this.preFcNormEmbedding = new RMSNorm(weights.tensor("pre_fc_norm_embedding.weight"), eps);
    this.preFcNormHidden = new RMSNorm(weights.tensor("pre_fc_norm_hidden.weight"), eps);
    this.attn = new MtpAttention(weights, config, "layers.0.self_attn", resources);
    this.mlpGate = loadMtpLinear(weights, "layers.0.mlp.gate_proj", config, resources);
    this.mlpUp = loadMtpLinear(weights, "layers.0.mlp.up_proj", config, resources);
    this.mlpDown = loadMtpLinear(weights, "layers.0.mlp.down_proj", config, resources);
    this.inputNorm = new RMSNorm(weights.tensor("layers.0.input_layernorm.weight"), eps);
    this.postAttnNorm = new RMSNorm(weights.tensor("layers.0.post_attention_layernorm.weight"), eps);
    this.finalNorm = new RMSNorm(weights.tensor("norm.weight"), eps);
  }

  /** One block forward over [B,S,·]: token embeddings ([B,S,H], target
   *  embed_tokens output) paired with hiddens ([B,S,H], target pre-final-norm
   *  or the module's own chained output). Appends S rows to `cache`; returns
   *  the module output [B,S,H] (post final norm — what the target lm_head
   *  consumes AND what chains into the next step's `hidden`). */
  forward(tokenEmbeds: MlxArray, hiddens: MlxArray, cache: Cache): MlxArray {
    const embNorm = this.preFcNormEmbedding.forward(tokenEmbeds);
    const hidNorm = this.preFcNormHidden.forward(hiddens);
    const joined = ops.concatAxis([embNorm, hidNorm], 2);
    embNorm.dispose();
    hidNorm.dispose();
    const x = this.fc.forward(joined);
    joined.dispose();

    // Decoder layer (Qwen3Layer.forward shape).
    const L = x.shape[1]!;
    const mask = cache.makeMask(L, null);
    const xn = this.inputNorm.forward(x);
    const r = this.attn.forward(xn, mask, cache);
    xn.dispose();
    mask.arr?.dispose();
    const h = ops.add(x, r);
    x.dispose();
    r.dispose();
    const hn = this.postAttnNorm.forward(h);
    const g = this.mlpGate.forward(hn);
    const u = this.mlpUp.forward(hn);
    hn.dispose();
    const act = compiledSwiglu(g, u);
    g.dispose(); u.dispose();
    const m = this.mlpDown.forward(act);
    act.dispose();
    const out = ops.add(h, m);
    h.dispose();
    m.dispose();
    return disposing(out, this.finalNorm.forward(out));
  }
}
