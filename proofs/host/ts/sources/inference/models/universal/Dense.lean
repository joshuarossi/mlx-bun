import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Universal.Dense
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/universal/dense.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import { WeightAudit } from "../../artifacts/weight-audit";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype, deviceArchitecture } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxCacheLayer, MlxSequenceRange, MlxRowTable, MlxCapturingForward, MlxDeclaredGraph, MlxHeadForward, MlxPromptRange, MlxTokenPhases } from "../../contracts/mlx/graph";
import type { GraphDeclaration } from "../../contracts/portable/graph";
import { logitSoftcap } from "../../kernels/logits";
import { qualifiedRepresentations, tiledTrellisPrefillEligible, splitKTrellisPrefillEligible } from "../../kernels/trellis/index";
import { disposing } from "../../layers/helpers";
import { LoraState } from "../../layers/lora";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { TrellisLinear } from "../../layers/trellis-linear";
import { TrellisTiledPrompt, TrellisSplitKPrompt, type RowProjection } from "../../layers/trellis-prompt";
import { NoRope, UniversalRope } from "../../layers/rope";
import { loadEmbedding, loadLayerNorm, loadLinear, loadRmsNorm, type AnyEmbedding, type AnyLinear, type AnyNorm } from "../../layers/loading";
import { cleanupFailure } from "../../runtime/resources";
import { ORDINARY_VERIFICATION, declareGraph } from "../capabilities";
import { DEFAULT_PHASE_ROWS, rowTableFrom, type ReadPhase } from "../graph";
import { cacheRead, type AttentionReadStrategy } from "../qwen/blocks";
import { genericArgsFor, universalCacheWindows, universalMaskRecipe, type UniversalArgs } from "./archs";
import { UniversalLayer, softcapRead, buildRope, stockProjection, packedProjection, expandedProjection, projectionFacts, normType } from "./blocks";
export { UniversalAttention, UniversalLayer, UniversalMLP, type SwigluFn } from "./blocks";

export class UniversalDenseModel implements MlxDeclaredGraph, MlxTokenPhases {
  readonly config: ModelConfig;
  readonly args: UniversalArgs;
  readonly weightsBytes: number;
  readonly prefixBase = "model";
  readonly loraState = new LoraState();
  readonly embed: AnyEmbedding;
  readonly layers: UniversalLayer[];
  readonly finalNorm: AnyNorm;
  readonly lmHead: AnyLinear | null;
  readonly sharedRope: UniversalRope;
  readonly ropes: UniversalRope[];
  /** Whether every attention layer, as bound, reads encoded (affine) KV views. */
  readonly encodedKvAttention: boolean;
  readonly #views: readonly {from:number;to:number;layers:readonly UniversalLayer[];head:MlxHeadForward}[];
  readonly sequenceLogits: readonly import("../../contracts/mlx/graph").MlxHeadRange[];
  logitsFromHidden?: MlxHeadForward;

  /** A graph whose attention softcaps its scores verifies ordinary rounds only
   * (its layers read dense K/V through the softcapped read). */
  get graphCapabilities(): GraphDeclaration {
    return declareGraph(this.encodedKvAttention === false ? { speculation: ORDINARY_VERIFICATION } : {});
  }
  // Cache layout and each layer's read come from the same descriptor facts,
  // bound at construction; later edits to `args` cannot make them disagree.
  readonly #cacheWindows: readonly (number | null)[];

  constructor(weights: Weights, config: ModelConfig, args?: UniversalArgs, maxPhaseRows = DEFAULT_PHASE_ROWS, device = deviceArchitecture()) {
    const representations = qualifiedRepresentations(device);
    const a = args ?? genericArgsFor(config);
    if (!a)
      throw new Error(`UniversalDenseModel: no descriptor for model_type ${config.modelType}`);
    this.config = config;
    this.args = a;
    this.#cacheWindows = universalCacheWindows(a);
    // Each layer's read: the cache's own read, or the softcapped read over plain
    // KV with the layer group's window (gemma2: create_attention_mask(...,
    // return_array=True) materializes the causal mask). The cache's own read
    // builds the mask the cache answers for its query count, so array masks
    // without a score softcap have no read here.
    const recipe = universalMaskRecipe(a);
    const softcap = a.attnLogitSoftcap;
    if (softcap === null && recipe.array)
      throw new Error(`UniversalDenseModel: ${a.modelType} asks for array masks without a score softcap; ` +
        "the composed attention reads take the cache's own mask (state/softcap-attention.ts reads array masks)");
    const reads = (layer: number): AttentionReadStrategy => softcap === null ? cacheRead
      : softcapRead(softcap, recipe.slidingLayers[layer] ? recipe.window : null, recipe.array);
    this.weightsBytes = [...weights.shards.files.values()]
      .reduce((acc, f) => acc + f.mmap.size, 0);

    const audit = new WeightAudit();
    this.embed = loadEmbedding(weights, "model.embed_tokens", config, audit);
    // One rope instance shared by every rope-bearing layer (identical
    // params ⇒ identical table); NoPE layers (smollm3) get the no-op.
    this.sharedRope = buildRope(a);
    const noRope = new NoRope();
    this.ropes = Array.from({ length: a.numHiddenLayers }, (_, i) =>
      a.noRopeLayers && a.noRopeLayers[i] === 0 ? noRope : this.sharedRope,
    );
    this.layers = Array.from(
      { length: a.numHiddenLayers },
      (_, i) => new UniversalLayer(weights, config, `model.layers.${i}`, a, this.ropes[i]!, audit, reads(i), representations),
    );
    this.encodedKvAttention = this.layers.every(layer => layer.attn.softcap === null);
    this.finalNorm = a.norm === "layernorm"
      ? loadLayerNorm(weights, "model.norm", a.normEps, audit)
      : loadRmsNorm(weights, "model.norm", a.normEps, a.norm === "rmsnorm_plus_one", audit);
    this.lmHead = a.tieWordEmbeddings
      ? null
      : loadLinear(weights, "lm_head", config, audit, representations);

    // Load-time weight audit: unconsumed tensors (outside the arch's
    // sanitize drops) are a LOAD ERROR, never a silently-wrong model.
    audit.finish(weights, a.dropWeightPatterns);

    using probeIds=ops.zeros([1,1],Dtype.int32), probeEmbedding=this.#embed(probeIds);
    const facts=projectionFacts(this.layers,probeEmbedding.dtype,a.hiddenSize);
    const finalType=normType(this.finalNorm,facts.output,a.hiddenSize);
    if (this.lmHead) facts.types.set(this.lmHead,finalType);
    const narrow=(base:AnyLinear):RowProjection=>base instanceof TrellisLinear ? packedProjection(base) : stockProjection(base);
    const five=(base:AnyLinear):RowProjection=> {
      if (!(base instanceof TrellisLinear)) return stockProjection(base);
      const dtype=facts.types.get(base)!;
      return tiledTrellisPrefillEligible(base.geometry,5,dtype,representations.widePrefill) ? new TrellisTiledPrompt(base)
        : splitKTrellisPrefillEligible(base.geometry,5,dtype) ? new TrellisSplitKPrompt(base) : expandedProjection(base);
    };
    const nine=(base:AnyLinear):RowProjection=>base instanceof TrellisLinear
      ? tiledTrellisPrefillEligible(base.geometry,9,facts.types.get(base)!,representations.widePrefill) ? new TrellisTiledPrompt(base) : expandedProjection(base)
      : stockProjection(base);
    const sixteen=(base:AnyLinear):RowProjection=>base instanceof TrellisLinear
      ? tiledTrellisPrefillEligible(base.geometry,16,facts.types.get(base)!,representations.widePrefill) ? new TrellisTiledPrompt(base) : expandedProjection(base)
      : stockProjection(base);
    const expanded=(base:AnyLinear):RowProjection=>base instanceof TrellisLinear ? expandedProjection(base) : stockProjection(base);
    const bind=(from:number,to:number,project:(base:AnyLinear)=>RowProjection)=> {
      // Views inherit the owning block's norms, rope, audit-derived facts and
      // adapter carriers. Only projection call ports are replaced.
      const layers=this.layers.map(base=> {
        const attn=Object.assign(Object.create(base.attn),{qProj:base.attn.qProj && project(base.attn.qProj),kProj:base.attn.kProj && project(base.attn.kProj),
          vProj:base.attn.vProj && project(base.attn.vProj),qkvProj:base.attn.qkvProj && project(base.attn.qkvProj),oProj:project(base.attn.oProj)});
        const mlp=Object.assign(Object.create(base.mlp),{gate:base.mlp.gate && project(base.mlp.gate),up:base.mlp.up && project(base.mlp.up),
          gateUp:base.mlp.gateUp && project(base.mlp.gateUp),down:project(base.mlp.down)});
        return Object.assign(Object.create(base),{attn,mlp}) as UniversalLayer;
      });
      const head=this.lmHead ? project(this.lmHead) : null;
      return {from,to,layers,head:(hidden:MlxArray)=>this.#finishLogits(hidden,head)};
    };
    this.#views=[bind(1,4,narrow),bind(5,8,five),bind(9,15,nine),bind(16,32,sixteen),bind(33,Infinity,expanded)];
    if (!(this.lmHead instanceof TrellisLinear)) this.logitsFromHidden=this.#views[0]!.head;
    const head=(view:{head:MlxHeadForward}):MlxHeadForward=>this.logitsFromHidden
      ? hidden=>this.logitsFromHidden!(hidden) : view.head;
    this.prompt=this.#views.map(view=>({from:view.from,to:view.to,operation:(ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"window",view.layers)}));
    this.multiSequencePrompt=this.prompt;
    this.promptChunk=this.prompt;
    this.multiSequencePromptChunk=this.multiSequencePrompt;
    this.appendKnown=this.#views.map(view=>({from:view.from,to:view.to,operation:(ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"window",view.layers)}));
    const expandedView=this.#views.at(-1)!;
    const decodeExpanded:MlxCapturingForward=(ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"decode",expandedView.layers);
    const verifyExpanded:MlxCapturingForward=(ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"window",expandedView.layers);
    // Admission caps do not remove the component's distinct 1–32 row forms.
    this.decode=Object.freeze({...rowTableFrom<MlxCapturingForward>(rows=>{
      const view=this.#views.find(view=>rows>=view.from && rows<=view.to)!;
      return (ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"decode",view.layers);
    },Math.max(32,maxPhaseRows)),default:decodeExpanded});
    this.verify=Object.freeze({...rowTableFrom<MlxCapturingForward>(rows=>{
      const view=this.#views.find(view=>rows>=view.from && rows<=view.to)!;
      return (ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"window",view.layers);
    },Math.max(32,maxPhaseRows)),default:verifyExpanded});
    this.logits=Object.freeze({...rowTableFrom(rows=>head(this.#views.find(view=>rows>=view.from && rows<=view.to)!),Math.max(32,maxPhaseRows)),default:head(expandedView)});
    this.sequence=this.#views.map(view=>({from:view.from,to:view.to,operation:(ids,cache)=>this.forwardLayers(this.#embed(ids),cache,"window",view.layers)}));
    this.sequenceLogits=this.#views.map(view=>({from:view.from,to:view.to,operation:head(view)}));

    this.cacheLayers = this.#cacheWindows.map(window=>window ? {kind:"sliding" as const,window}:{kind:"full" as const,turboQuant:"dense" as const});
  }

  /** LoRA hot-swap targets — quantized linears only (dense checkpoints
   *  serve without adapter support at Tier-0), read at load. */
  loraTargets(): Map<string, QuantizedLinear | TrellisLinear> {
    const out = new Map<string, QuantizedLinear | TrellisLinear>();
    const put = (path: string, lin: QuantizedLinear | TrellisLinear | null) => {
      if (lin) out.set(path, lin);
    };
    for (let i = 0; i < this.layers.length; i++) {
      const { attn, mlp } = this.layers[i]!;
      const p = `model.layers.${i}`;
      put(`${p}.self_attn.q_proj`, attn.adapters.q);
      put(`${p}.self_attn.k_proj`, attn.adapters.k);
      put(`${p}.self_attn.v_proj`, attn.adapters.v);
      put(`${p}.self_attn.qkv_proj`, attn.adapters.qkv);
      put(`${p}.self_attn.o_proj`, attn.adapters.o);
      put(`${p}.mlp.gate_proj`, mlp.adapters.gate);
      put(`${p}.mlp.up_proj`, mlp.adapters.up);
      put(`${p}.mlp.gate_up_proj`, mlp.adapters.gateUp);
      put(`${p}.mlp.down_proj`, mlp.adapters.down);
    }
    return out;
  }

  /** Releases the rope frequency table it built (a scaled rope's); the weights are its owner's. */
  dispose(): void { this.sharedRope.dispose(); }

  /** One cache per layer (a ring on a sliding layer with a window), sharing
   * one mask memo. The full-attention caches' TurboQuant read is dense
   * (`denseTurboQuantKernels`): the read decodes keys and values first (the
   * softcapped read attends the decoded window). */
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly sequence: readonly MlxSequenceRange[];


  /** One whole chunk of a prompt; rows are sequences times the chunk size. The GPU is this graph's one unit. */
  readonly prompt: readonly MlxPromptRange[];
  readonly multiSequencePrompt: readonly MlxPromptRange[];
  readonly promptChunk: readonly MlxPromptRange[];
  readonly multiSequencePromptChunk: readonly MlxPromptRange[];

  /** Known tokens: this graph declares no committed spans, so they read as a window. */
  readonly appendKnown: import("../../contracts/mlx/graph").MlxKnownOperations;

  /** Each row count names its fixed output head. */
  readonly logits: MlxRowTable<MlxHeadForward>;

  /** One new token per sequence: `ids` [sequences, 1]. */
  readonly decode: MlxRowTable<MlxCapturingForward>;

  /** A speculative window of depth + 1 positions per sequence. This graph
   * declares no hidden-layer taps, so `capture` is always null. */
  readonly verify: MlxRowTable<MlxCapturingForward>;

  /** Token embeddings, scaled where the descriptor scales them (owned). */
  #embed(ids: MlxArray): MlxArray {
    const h = this.embed.encode(ids);
    return this.args.embedMultiplier !== null ? disposing(h, ops.mulScalar(h, this.args.embedMultiplier)) : h;
  }

  /** The decoder over `h0` (consumed), every block reading its cache for
   *  `phase`. This call owns h0 and each intermediate hidden state, and
   *  releases them on failure as on success; an execution failure stays the
   *  primary error. */
  protected forwardLayers(h0: MlxArray, cache: Cache[], phase: ReadPhase, layers: readonly UniversalLayer[] = this.layers): MlxArray {
    let cur = h0;
    try {
      for (let i = 0; i < this.layers.length; i++) {
        const next = layers[i]!.forward(cur, cache[i]!, phase);
        const done = cur;
        cur = next;
        done.dispose();
      }
    } catch (error) {
      return cleanupFailure(error, () => cur.dispose());
    }
    let out: MlxArray;
    try { out = this.finalNorm.forward(cur); }
    catch (error) { return cleanupFailure(error, () => cur.dispose()); }
    try { cur.dispose(); }
    catch (error) { return cleanupFailure(error, () => out.dispose()); }
    return out;
  }

  #finishLogits(h: MlxArray, head: RowProjection | null): MlxArray {
    let logits = head ? head.forward(h) : this.embed.asLinear(h);
    if (this.args.finalLogitSoftcap !== null)
      logits = disposing(logits, logitSoftcap(logits, this.args.finalLogitSoftcap));
    if (this.args.logitsDivisor !== null) {
      const d = ops.scalarLike(this.args.logitsDivisor, logits);
      logits = disposing(logits, ops.div(logits, d));
      d.dispose();
    }
    return logits;
  }
}
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Universal.Dense
