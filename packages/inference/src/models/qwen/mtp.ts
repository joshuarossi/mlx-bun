// Qwen MTP numerical graph. Request state, sampling and checkpoint retention
// belong to its callers; the cache supplies positions and attention storage.
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { disposing } from "../../layers/helpers";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { RMSNorm } from "../../layers/normalization";
import { type Cache } from "../../contracts/mlx/cache";
import { DenseLinear } from "../../layers/dense-linear";
import { compiledSwiglu } from "../../layers/swiglu";
import { Qwen3Attention } from "./qwen3_5";

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

/** The one MTP decoder block: fc-merge → attention → swiglu MLP → norm. */
export class MtpModule {
  readonly fc: MtpLinear;
  readonly preFcNormEmbedding: RMSNorm;
  readonly preFcNormHidden: RMSNorm;
  readonly attn: Qwen3Attention<MtpLinear>;
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
    // The target's attention block (qwen3_5.ts) with the companion's dense or quantized heads.
    this.attn = new Qwen3Attention<MtpLinear>(weights, config, "layers.0.self_attn",
      (w, path, c) => loadMtpLinear(w, path, c, resources));
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
