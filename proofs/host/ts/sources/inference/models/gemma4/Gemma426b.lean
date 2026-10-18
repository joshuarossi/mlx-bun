import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Gemma426b
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/gemma4-26b.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Written Gemma 4 26b graph. Layer order and every operation binding are literal.
import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { Cache } from "../../contracts/mlx/cache";
import type { MlxDeclaredGraph, MlxTokenPhases, MlxRowTable, MlxCapturingForward, MlxHeadForward, MlxPhaseForward, MlxKnownOperations, MlxLayerCapture, MlxPromptRange, MlxMixedRange, MlxPhaseGroup, MlxCacheLayer } from "../../contracts/mlx/graph";
import type { Vision, MediaSidecarProbes } from "../../contracts/mlx/media";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { RMSNorm } from "../../layers/normalization";
import { LoraState } from "../../layers/lora";
import { disposing } from "../../layers/helpers";
import { compiledLogitSoftcap } from "../../kernels/softcap";
import { logitSoftcap } from "../../kernels/logits";
import { ownResource, disposeResources } from "../../runtime/resources";
import { declareGraph } from "../capabilities";
import { GEMMA_GRAPH_FINGERPRINTS } from "./family";
import { CompiledDecode } from "./compiled-decode";
import { bindGemma4MediaInput, gemma4DraftTarget, gemma4MediaEncoders } from "./media";
import { type Gemma4Phase } from "./blocks";
import { SlidingAttention, FullAttention, FullKEqVAttention, SharedSlidingAttention, SharedFullAttention, GemmaLayerWeights, GemmaInputLayerWeights, GemmaMoeLayerWeights, GemmaDenseLayer, GemmaInputLayer, GemmaMoeLayer, CompiledGegluMLP, PlainGegluMLP, CompiledGeglu, SortedSwitchGLU, UnsortedSwitchGLU, FixedExperts } from "./written-blocks";
import { GemmaForwardScope, GemmaInputForwardScope, GemmaMixedScope, ownMixed, donorMixed, sharedMixed, denseLoraTargets, inputLoraTargets, weightBytes, GemmaBuildScope } from "./written-forward";
export const FINGERPRINT = GEMMA_GRAPH_FINGERPRINTS["26b"];

/** One decoder layer as the composition fixes it: its attention type; the layer
 *  whose cache it reads (itself when it owns one, else the last donor of its type,
 *  whose read it attends in the same forward); that cache's affine width and group
 *  under the composition's KV scheme (null: bf16); whether its keys are its values;
 *  whether it carries a layer scalar. */
export interface Gemma4Layer {
  readonly attention: "sliding" | "full";
  readonly cache: number;
  readonly kv: { readonly bits: number; readonly groupSize: number } | null;
  readonly kEqV: boolean;
  readonly layerScalar: boolean;
}

/** The artifact's layers and kv_config, from mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit@dbfd2a779b038b267bb20ff95dad717f42e4de16. */
export const LAYERS: readonly Gemma4Layer[] = Object.freeze([
  /*  0 */ { attention: "sliding", cache: 0, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  1 */ { attention: "sliding", cache: 1, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  2 */ { attention: "sliding", cache: 2, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  3 */ { attention: "sliding", cache: 3, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  4 */ { attention: "sliding", cache: 4, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  5 */ { attention: "full", cache: 5, kv: { bits: 8, groupSize: 64 }, kEqV: true, layerScalar: true },
  /*  6 */ { attention: "sliding", cache: 6, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  7 */ { attention: "sliding", cache: 7, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  8 */ { attention: "sliding", cache: 8, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  9 */ { attention: "sliding", cache: 9, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 10 */ { attention: "sliding", cache: 10, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 11 */ { attention: "full", cache: 11, kv: { bits: 8, groupSize: 64 }, kEqV: true, layerScalar: true },
  /* 12 */ { attention: "sliding", cache: 12, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 13 */ { attention: "sliding", cache: 13, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 14 */ { attention: "sliding", cache: 14, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 15 */ { attention: "sliding", cache: 15, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 16 */ { attention: "sliding", cache: 16, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 17 */ { attention: "full", cache: 17, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
  /* 18 */ { attention: "sliding", cache: 18, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 19 */ { attention: "sliding", cache: 19, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 20 */ { attention: "sliding", cache: 20, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 21 */ { attention: "sliding", cache: 21, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 22 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 23 */ { attention: "full", cache: 23, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
  /* 24 */ { attention: "sliding", cache: 24, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 25 */ { attention: "sliding", cache: 25, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 26 */ { attention: "sliding", cache: 26, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 27 */ { attention: "sliding", cache: 27, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 28 */ { attention: "sliding", cache: 28, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 29 */ { attention: "full", cache: 29, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
]);

/** Layers [0, CACHES) own a cache. */
const CACHES = 30;
const PREFIX = "language_model.model";
const FINAL_LOGIT_SOFTCAP = 30;

export const DECODE_ROWS = 8;
export const VERIFY_ROWS = 64;

export class Gemma4Moe implements MlxDeclaredGraph, MlxTokenPhases {
  readonly prefixBase = PREFIX;
  readonly loraState = new LoraState();
  readonly weightsBytes: number;
  readonly embed: QuantizedEmbedding;
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  readonly numDonors = CACHES;
  readonly perLayerWidth = 0;
  readonly graphCapabilities = declareGraph({ media: { input: "embeddings", video: false }, hiddenLayerTaps: true });
  makeCache!: () => Cache[];
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly layers: readonly GemmaMoeLayer[];
  readonly traceLayers: readonly GemmaDenseLayer[];
  readonly #constants: ReturnType<typeof ownResource<MlxArray[]>>;
  readonly #parts: readonly GemmaMoeLayerWeights[];
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];
  readonly decode: MlxRowTable<MlxCapturingForward>;
  readonly verify: MlxRowTable<MlxCapturingForward>;
  readonly appendKnown: MlxKnownOperations;
  readonly logits: MlxRowTable<MlxHeadForward>;
  readonly mixed: readonly MlxMixedRange[];
  readonly #l0: GemmaMoeLayer;
  readonly #t0: GemmaMoeLayer;
  readonly #l1: GemmaMoeLayer;
  readonly #t1: GemmaMoeLayer;
  readonly #l2: GemmaMoeLayer;
  readonly #t2: GemmaMoeLayer;
  readonly #l3: GemmaMoeLayer;
  readonly #t3: GemmaMoeLayer;
  readonly #l4: GemmaMoeLayer;
  readonly #t4: GemmaMoeLayer;
  readonly #l5: GemmaMoeLayer;
  readonly #t5: GemmaMoeLayer;
  readonly #l6: GemmaMoeLayer;
  readonly #t6: GemmaMoeLayer;
  readonly #l7: GemmaMoeLayer;
  readonly #t7: GemmaMoeLayer;
  readonly #l8: GemmaMoeLayer;
  readonly #t8: GemmaMoeLayer;
  readonly #l9: GemmaMoeLayer;
  readonly #t9: GemmaMoeLayer;
  readonly #l10: GemmaMoeLayer;
  readonly #t10: GemmaMoeLayer;
  readonly #l11: GemmaMoeLayer;
  readonly #t11: GemmaMoeLayer;
  readonly #l12: GemmaMoeLayer;
  readonly #t12: GemmaMoeLayer;
  readonly #l13: GemmaMoeLayer;
  readonly #t13: GemmaMoeLayer;
  readonly #l14: GemmaMoeLayer;
  readonly #t14: GemmaMoeLayer;
  readonly #l15: GemmaMoeLayer;
  readonly #t15: GemmaMoeLayer;
  readonly #l16: GemmaMoeLayer;
  readonly #t16: GemmaMoeLayer;
  readonly #l17: GemmaMoeLayer;
  readonly #t17: GemmaMoeLayer;
  readonly #l18: GemmaMoeLayer;
  readonly #t18: GemmaMoeLayer;
  readonly #l19: GemmaMoeLayer;
  readonly #t19: GemmaMoeLayer;
  readonly #l20: GemmaMoeLayer;
  readonly #t20: GemmaMoeLayer;
  readonly #l21: GemmaMoeLayer;
  readonly #t21: GemmaMoeLayer;
  readonly #l22: GemmaMoeLayer;
  readonly #t22: GemmaMoeLayer;
  readonly #l23: GemmaMoeLayer;
  readonly #t23: GemmaMoeLayer;
  readonly #l24: GemmaMoeLayer;
  readonly #t24: GemmaMoeLayer;
  readonly #l25: GemmaMoeLayer;
  readonly #t25: GemmaMoeLayer;
  readonly #l26: GemmaMoeLayer;
  readonly #t26: GemmaMoeLayer;
  readonly #l27: GemmaMoeLayer;
  readonly #t27: GemmaMoeLayer;
  readonly #l28: GemmaMoeLayer;
  readonly #t28: GemmaMoeLayer;
  readonly #l29: GemmaMoeLayer;
  readonly #t29: GemmaMoeLayer;
  constructor(weights: Weights, readonly config: ModelConfig) {
    using resources = new GemmaBuildScope();
    this.weightsBytes = weightBytes(weights);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.embed_tokens`, config);
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.norm.weight`), config.text.rmsNormEps);
    this.embedScale = Math.sqrt(config.text.hiddenSize);
    this.windowSize = config.text.slidingWindow;
    const p0 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.0`, new SlidingAttention(weights, config, `${PREFIX}.layers.0.self_attn`)));
    this.#l0 = new GemmaMoeLayer(p0, new CompiledGegluMLP(p0.mlp), new FixedExperts(new UnsortedSwitchGLU(p0.experts, new CompiledGeglu())));
    this.#t0 = new GemmaMoeLayer(p0, new CompiledGegluMLP(p0.mlp), new FixedExperts(new SortedSwitchGLU(p0.experts, new CompiledGeglu())));
    const p1 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.1`, new SlidingAttention(weights, config, `${PREFIX}.layers.1.self_attn`)));
    this.#l1 = new GemmaMoeLayer(p1, new CompiledGegluMLP(p1.mlp), new FixedExperts(new UnsortedSwitchGLU(p1.experts, new CompiledGeglu())));
    this.#t1 = new GemmaMoeLayer(p1, new CompiledGegluMLP(p1.mlp), new FixedExperts(new SortedSwitchGLU(p1.experts, new CompiledGeglu())));
    const p2 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.2`, new SlidingAttention(weights, config, `${PREFIX}.layers.2.self_attn`)));
    this.#l2 = new GemmaMoeLayer(p2, new CompiledGegluMLP(p2.mlp), new FixedExperts(new UnsortedSwitchGLU(p2.experts, new CompiledGeglu())));
    this.#t2 = new GemmaMoeLayer(p2, new CompiledGegluMLP(p2.mlp), new FixedExperts(new SortedSwitchGLU(p2.experts, new CompiledGeglu())));
    const p3 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.3`, new SlidingAttention(weights, config, `${PREFIX}.layers.3.self_attn`)));
    this.#l3 = new GemmaMoeLayer(p3, new CompiledGegluMLP(p3.mlp), new FixedExperts(new UnsortedSwitchGLU(p3.experts, new CompiledGeglu())));
    this.#t3 = new GemmaMoeLayer(p3, new CompiledGegluMLP(p3.mlp), new FixedExperts(new SortedSwitchGLU(p3.experts, new CompiledGeglu())));
    const p4 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.4`, new SlidingAttention(weights, config, `${PREFIX}.layers.4.self_attn`)));
    this.#l4 = new GemmaMoeLayer(p4, new CompiledGegluMLP(p4.mlp), new FixedExperts(new UnsortedSwitchGLU(p4.experts, new CompiledGeglu())));
    this.#t4 = new GemmaMoeLayer(p4, new CompiledGegluMLP(p4.mlp), new FixedExperts(new SortedSwitchGLU(p4.experts, new CompiledGeglu())));
    const p5 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.5`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.5.self_attn`)));
    this.#l5 = new GemmaMoeLayer(p5, new CompiledGegluMLP(p5.mlp), new FixedExperts(new UnsortedSwitchGLU(p5.experts, new CompiledGeglu())));
    this.#t5 = new GemmaMoeLayer(p5, new CompiledGegluMLP(p5.mlp), new FixedExperts(new SortedSwitchGLU(p5.experts, new CompiledGeglu())));
    const p6 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.6`, new SlidingAttention(weights, config, `${PREFIX}.layers.6.self_attn`)));
    this.#l6 = new GemmaMoeLayer(p6, new CompiledGegluMLP(p6.mlp), new FixedExperts(new UnsortedSwitchGLU(p6.experts, new CompiledGeglu())));
    this.#t6 = new GemmaMoeLayer(p6, new CompiledGegluMLP(p6.mlp), new FixedExperts(new SortedSwitchGLU(p6.experts, new CompiledGeglu())));
    const p7 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.7`, new SlidingAttention(weights, config, `${PREFIX}.layers.7.self_attn`)));
    this.#l7 = new GemmaMoeLayer(p7, new CompiledGegluMLP(p7.mlp), new FixedExperts(new UnsortedSwitchGLU(p7.experts, new CompiledGeglu())));
    this.#t7 = new GemmaMoeLayer(p7, new CompiledGegluMLP(p7.mlp), new FixedExperts(new SortedSwitchGLU(p7.experts, new CompiledGeglu())));
    const p8 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.8`, new SlidingAttention(weights, config, `${PREFIX}.layers.8.self_attn`)));
    this.#l8 = new GemmaMoeLayer(p8, new CompiledGegluMLP(p8.mlp), new FixedExperts(new UnsortedSwitchGLU(p8.experts, new CompiledGeglu())));
    this.#t8 = new GemmaMoeLayer(p8, new CompiledGegluMLP(p8.mlp), new FixedExperts(new SortedSwitchGLU(p8.experts, new CompiledGeglu())));
    const p9 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.9`, new SlidingAttention(weights, config, `${PREFIX}.layers.9.self_attn`)));
    this.#l9 = new GemmaMoeLayer(p9, new CompiledGegluMLP(p9.mlp), new FixedExperts(new UnsortedSwitchGLU(p9.experts, new CompiledGeglu())));
    this.#t9 = new GemmaMoeLayer(p9, new CompiledGegluMLP(p9.mlp), new FixedExperts(new SortedSwitchGLU(p9.experts, new CompiledGeglu())));
    const p10 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.10`, new SlidingAttention(weights, config, `${PREFIX}.layers.10.self_attn`)));
    this.#l10 = new GemmaMoeLayer(p10, new CompiledGegluMLP(p10.mlp), new FixedExperts(new UnsortedSwitchGLU(p10.experts, new CompiledGeglu())));
    this.#t10 = new GemmaMoeLayer(p10, new CompiledGegluMLP(p10.mlp), new FixedExperts(new SortedSwitchGLU(p10.experts, new CompiledGeglu())));
    const p11 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.11`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.11.self_attn`)));
    this.#l11 = new GemmaMoeLayer(p11, new CompiledGegluMLP(p11.mlp), new FixedExperts(new UnsortedSwitchGLU(p11.experts, new CompiledGeglu())));
    this.#t11 = new GemmaMoeLayer(p11, new CompiledGegluMLP(p11.mlp), new FixedExperts(new SortedSwitchGLU(p11.experts, new CompiledGeglu())));
    const p12 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.12`, new SlidingAttention(weights, config, `${PREFIX}.layers.12.self_attn`)));
    this.#l12 = new GemmaMoeLayer(p12, new CompiledGegluMLP(p12.mlp), new FixedExperts(new UnsortedSwitchGLU(p12.experts, new CompiledGeglu())));
    this.#t12 = new GemmaMoeLayer(p12, new CompiledGegluMLP(p12.mlp), new FixedExperts(new SortedSwitchGLU(p12.experts, new CompiledGeglu())));
    const p13 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.13`, new SlidingAttention(weights, config, `${PREFIX}.layers.13.self_attn`)));
    this.#l13 = new GemmaMoeLayer(p13, new CompiledGegluMLP(p13.mlp), new FixedExperts(new UnsortedSwitchGLU(p13.experts, new CompiledGeglu())));
    this.#t13 = new GemmaMoeLayer(p13, new CompiledGegluMLP(p13.mlp), new FixedExperts(new SortedSwitchGLU(p13.experts, new CompiledGeglu())));
    const p14 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.14`, new SlidingAttention(weights, config, `${PREFIX}.layers.14.self_attn`)));
    this.#l14 = new GemmaMoeLayer(p14, new CompiledGegluMLP(p14.mlp), new FixedExperts(new UnsortedSwitchGLU(p14.experts, new CompiledGeglu())));
    this.#t14 = new GemmaMoeLayer(p14, new CompiledGegluMLP(p14.mlp), new FixedExperts(new SortedSwitchGLU(p14.experts, new CompiledGeglu())));
    const p15 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.15`, new SlidingAttention(weights, config, `${PREFIX}.layers.15.self_attn`)));
    this.#l15 = new GemmaMoeLayer(p15, new CompiledGegluMLP(p15.mlp), new FixedExperts(new UnsortedSwitchGLU(p15.experts, new CompiledGeglu())));
    this.#t15 = new GemmaMoeLayer(p15, new CompiledGegluMLP(p15.mlp), new FixedExperts(new SortedSwitchGLU(p15.experts, new CompiledGeglu())));
    const p16 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.16`, new SlidingAttention(weights, config, `${PREFIX}.layers.16.self_attn`)));
    this.#l16 = new GemmaMoeLayer(p16, new CompiledGegluMLP(p16.mlp), new FixedExperts(new UnsortedSwitchGLU(p16.experts, new CompiledGeglu())));
    this.#t16 = new GemmaMoeLayer(p16, new CompiledGegluMLP(p16.mlp), new FixedExperts(new SortedSwitchGLU(p16.experts, new CompiledGeglu())));
    const p17 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.17`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.17.self_attn`)));
    this.#l17 = new GemmaMoeLayer(p17, new CompiledGegluMLP(p17.mlp), new FixedExperts(new UnsortedSwitchGLU(p17.experts, new CompiledGeglu())));
    this.#t17 = new GemmaMoeLayer(p17, new CompiledGegluMLP(p17.mlp), new FixedExperts(new SortedSwitchGLU(p17.experts, new CompiledGeglu())));
    const p18 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.18`, new SlidingAttention(weights, config, `${PREFIX}.layers.18.self_attn`)));
    this.#l18 = new GemmaMoeLayer(p18, new CompiledGegluMLP(p18.mlp), new FixedExperts(new UnsortedSwitchGLU(p18.experts, new CompiledGeglu())));
    this.#t18 = new GemmaMoeLayer(p18, new CompiledGegluMLP(p18.mlp), new FixedExperts(new SortedSwitchGLU(p18.experts, new CompiledGeglu())));
    const p19 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.19`, new SlidingAttention(weights, config, `${PREFIX}.layers.19.self_attn`)));
    this.#l19 = new GemmaMoeLayer(p19, new CompiledGegluMLP(p19.mlp), new FixedExperts(new UnsortedSwitchGLU(p19.experts, new CompiledGeglu())));
    this.#t19 = new GemmaMoeLayer(p19, new CompiledGegluMLP(p19.mlp), new FixedExperts(new SortedSwitchGLU(p19.experts, new CompiledGeglu())));
    const p20 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.20`, new SlidingAttention(weights, config, `${PREFIX}.layers.20.self_attn`)));
    this.#l20 = new GemmaMoeLayer(p20, new CompiledGegluMLP(p20.mlp), new FixedExperts(new UnsortedSwitchGLU(p20.experts, new CompiledGeglu())));
    this.#t20 = new GemmaMoeLayer(p20, new CompiledGegluMLP(p20.mlp), new FixedExperts(new SortedSwitchGLU(p20.experts, new CompiledGeglu())));
    const p21 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.21`, new SlidingAttention(weights, config, `${PREFIX}.layers.21.self_attn`)));
    this.#l21 = new GemmaMoeLayer(p21, new CompiledGegluMLP(p21.mlp), new FixedExperts(new UnsortedSwitchGLU(p21.experts, new CompiledGeglu())));
    this.#t21 = new GemmaMoeLayer(p21, new CompiledGegluMLP(p21.mlp), new FixedExperts(new SortedSwitchGLU(p21.experts, new CompiledGeglu())));
    const p22 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.22`, new SlidingAttention(weights, config, `${PREFIX}.layers.22.self_attn`)));
    this.#l22 = new GemmaMoeLayer(p22, new CompiledGegluMLP(p22.mlp), new FixedExperts(new UnsortedSwitchGLU(p22.experts, new CompiledGeglu())));
    this.#t22 = new GemmaMoeLayer(p22, new CompiledGegluMLP(p22.mlp), new FixedExperts(new SortedSwitchGLU(p22.experts, new CompiledGeglu())));
    const p23 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.23`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.23.self_attn`)));
    this.#l23 = new GemmaMoeLayer(p23, new CompiledGegluMLP(p23.mlp), new FixedExperts(new UnsortedSwitchGLU(p23.experts, new CompiledGeglu())));
    this.#t23 = new GemmaMoeLayer(p23, new CompiledGegluMLP(p23.mlp), new FixedExperts(new SortedSwitchGLU(p23.experts, new CompiledGeglu())));
    const p24 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.24`, new SlidingAttention(weights, config, `${PREFIX}.layers.24.self_attn`)));
    this.#l24 = new GemmaMoeLayer(p24, new CompiledGegluMLP(p24.mlp), new FixedExperts(new UnsortedSwitchGLU(p24.experts, new CompiledGeglu())));
    this.#t24 = new GemmaMoeLayer(p24, new CompiledGegluMLP(p24.mlp), new FixedExperts(new SortedSwitchGLU(p24.experts, new CompiledGeglu())));
    const p25 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.25`, new SlidingAttention(weights, config, `${PREFIX}.layers.25.self_attn`)));
    this.#l25 = new GemmaMoeLayer(p25, new CompiledGegluMLP(p25.mlp), new FixedExperts(new UnsortedSwitchGLU(p25.experts, new CompiledGeglu())));
    this.#t25 = new GemmaMoeLayer(p25, new CompiledGegluMLP(p25.mlp), new FixedExperts(new SortedSwitchGLU(p25.experts, new CompiledGeglu())));
    const p26 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.26`, new SlidingAttention(weights, config, `${PREFIX}.layers.26.self_attn`)));
    this.#l26 = new GemmaMoeLayer(p26, new CompiledGegluMLP(p26.mlp), new FixedExperts(new UnsortedSwitchGLU(p26.experts, new CompiledGeglu())));
    this.#t26 = new GemmaMoeLayer(p26, new CompiledGegluMLP(p26.mlp), new FixedExperts(new SortedSwitchGLU(p26.experts, new CompiledGeglu())));
    const p27 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.27`, new SlidingAttention(weights, config, `${PREFIX}.layers.27.self_attn`)));
    this.#l27 = new GemmaMoeLayer(p27, new CompiledGegluMLP(p27.mlp), new FixedExperts(new UnsortedSwitchGLU(p27.experts, new CompiledGeglu())));
    this.#t27 = new GemmaMoeLayer(p27, new CompiledGegluMLP(p27.mlp), new FixedExperts(new SortedSwitchGLU(p27.experts, new CompiledGeglu())));
    const p28 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.28`, new SlidingAttention(weights, config, `${PREFIX}.layers.28.self_attn`)));
    this.#l28 = new GemmaMoeLayer(p28, new CompiledGegluMLP(p28.mlp), new FixedExperts(new UnsortedSwitchGLU(p28.experts, new CompiledGeglu())));
    this.#t28 = new GemmaMoeLayer(p28, new CompiledGegluMLP(p28.mlp), new FixedExperts(new SortedSwitchGLU(p28.experts, new CompiledGeglu())));
    const p29 = resources.holdMoe(new GemmaMoeLayerWeights(weights, config, `${PREFIX}.layers.29`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.29.self_attn`)));
    this.#l29 = new GemmaMoeLayer(p29, new CompiledGegluMLP(p29.mlp), new FixedExperts(new UnsortedSwitchGLU(p29.experts, new CompiledGeglu())));
    this.#t29 = new GemmaMoeLayer(p29, new CompiledGegluMLP(p29.mlp), new FixedExperts(new SortedSwitchGLU(p29.experts, new CompiledGeglu())));
    this.layers = Object.freeze([this.#l0, this.#l1, this.#l2, this.#l3, this.#l4, this.#l5, this.#l6, this.#l7, this.#l8, this.#l9, this.#l10, this.#l11, this.#l12, this.#l13, this.#l14, this.#l15, this.#l16, this.#l17, this.#l18, this.#l19, this.#l20, this.#l21, this.#l22, this.#l23, this.#l24, this.#l25, this.#l26, this.#l27, this.#l28, this.#l29]);
    this.traceLayers = Object.freeze([]);
    this.#parts = Object.freeze([p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29]);
    this.#constants = resources.finish();
    this.cacheLayers = Object.freeze([
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "full", turboQuant: "deferred" },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "full", turboQuant: "deferred" },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "full", turboQuant: "deferred" },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "full", turboQuant: "deferred" },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "sliding", window: config.text.slidingWindow },
      { kind: "full", turboQuant: "deferred" },
    ]);
    this.prompt = Object.freeze([{ from: 1, to: 7, operation: this.#window }, { from: 8, to: Infinity, operation: this.#sortedWindow }]);
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    this.decode = Object.freeze({ 1: this.#decode, 2: this.#decode, 3: this.#decode, 4: this.#decode, 5: this.#decode, 6: this.#decode, 7: this.#decode, 8: this.#sortedDecode ,
      default: this.#sortedDecode,
    });
    this.verify = Object.freeze({ 1: this.#window, 2: this.#window, 3: this.#window, 4: this.#window, 5: this.#window, 6: this.#window, 7: this.#window, 8: this.#sortedWindow, 9: this.#sortedWindow, 10: this.#sortedWindow, 11: this.#sortedWindow, 12: this.#sortedWindow, 13: this.#sortedWindow, 14: this.#sortedWindow, 15: this.#sortedWindow, 16: this.#sortedWindow, 17: this.#sortedWindow, 18: this.#sortedWindow, 19: this.#sortedWindow, 20: this.#sortedWindow, 21: this.#sortedWindow, 22: this.#sortedWindow, 23: this.#sortedWindow, 24: this.#sortedWindow, 25: this.#sortedWindow, 26: this.#sortedWindow, 27: this.#sortedWindow, 28: this.#sortedWindow, 29: this.#sortedWindow, 30: this.#sortedWindow, 31: this.#sortedWindow, 32: this.#sortedWindow, 33: this.#sortedWindow, 34: this.#sortedWindow, 35: this.#sortedWindow, 36: this.#sortedWindow, 37: this.#sortedWindow, 38: this.#sortedWindow, 39: this.#sortedWindow, 40: this.#sortedWindow, 41: this.#sortedWindow, 42: this.#sortedWindow, 43: this.#sortedWindow, 44: this.#sortedWindow, 45: this.#sortedWindow, 46: this.#sortedWindow, 47: this.#sortedWindow, 48: this.#sortedWindow, 49: this.#sortedWindow, 50: this.#sortedWindow, 51: this.#sortedWindow, 52: this.#sortedWindow, 53: this.#sortedWindow, 54: this.#sortedWindow, 55: this.#sortedWindow, 56: this.#sortedWindow, 57: this.#sortedWindow, 58: this.#sortedWindow, 59: this.#sortedWindow, 60: this.#sortedWindow, 61: this.#sortedWindow, 62: this.#sortedWindow, 63: this.#sortedWindow, 64: this.#sortedWindow ,
      default: this.#sortedWindow,
    });
    this.appendKnown = [{ from: 1, to: 7, operation: this.#known }, { from: 8, to: Infinity, operation: this.#sortedKnown }];
    this.logits = Object.freeze({ 1: this.#head, 2: this.#head, 3: this.#head, 4: this.#head, 5: this.#head, 6: this.#head, 7: this.#head, 8: this.#head, 9: this.#head, 10: this.#head, 11: this.#head, 12: this.#head, 13: this.#head, 14: this.#head, 15: this.#head, 16: this.#head, 17: this.#head, 18: this.#head, 19: this.#head, 20: this.#head, 21: this.#head, 22: this.#head, 23: this.#head, 24: this.#head, 25: this.#head, 26: this.#head, 27: this.#head, 28: this.#head, 29: this.#head, 30: this.#head, 31: this.#head, 32: this.#head, 33: this.#head, 34: this.#head, 35: this.#head, 36: this.#head, 37: this.#head, 38: this.#head, 39: this.#head, 40: this.#head, 41: this.#head, 42: this.#head, 43: this.#head, 44: this.#head, 45: this.#head, 46: this.#head, 47: this.#head, 48: this.#head, 49: this.#head, 50: this.#head, 51: this.#head, 52: this.#head, 53: this.#head, 54: this.#head, 55: this.#head, 56: this.#head, 57: this.#head, 58: this.#head, 59: this.#head, 60: this.#head, 61: this.#head, 62: this.#head, 63: this.#head, 64: this.#head ,
      default: this.#head,
    });
    this.mixed = Object.freeze([{ from: 1, to: 7, operation: this.#mixed }, { from: 8, to: Infinity, operation: this.#sortedMixed }]);
  }
  readonly #window = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#windowHidden(this.#embedTokens(ids), caches, "window", ids, capture);
  #windowHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaForwardScope(hidden, capture, CACHES);
    scope.own(0, this.#l0.forward(scope.hidden, caches[0]!, phase, null));
    scope.own(1, this.#l1.forward(scope.hidden, caches[1]!, phase, null));
    scope.own(2, this.#l2.forward(scope.hidden, caches[2]!, phase, null));
    scope.own(3, this.#l3.forward(scope.hidden, caches[3]!, phase, null));
    scope.own(4, this.#l4.forward(scope.hidden, caches[4]!, phase, null));
    scope.own(5, this.#l5.forward(scope.hidden, caches[5]!, phase, null));
    scope.own(6, this.#l6.forward(scope.hidden, caches[6]!, phase, null));
    scope.own(7, this.#l7.forward(scope.hidden, caches[7]!, phase, null));
    scope.own(8, this.#l8.forward(scope.hidden, caches[8]!, phase, null));
    scope.own(9, this.#l9.forward(scope.hidden, caches[9]!, phase, null));
    scope.own(10, this.#l10.forward(scope.hidden, caches[10]!, phase, null));
    scope.own(11, this.#l11.forward(scope.hidden, caches[11]!, phase, null));
    scope.own(12, this.#l12.forward(scope.hidden, caches[12]!, phase, null));
    scope.own(13, this.#l13.forward(scope.hidden, caches[13]!, phase, null));
    scope.own(14, this.#l14.forward(scope.hidden, caches[14]!, phase, null));
    scope.own(15, this.#l15.forward(scope.hidden, caches[15]!, phase, null));
    scope.own(16, this.#l16.forward(scope.hidden, caches[16]!, phase, null));
    scope.own(17, this.#l17.forward(scope.hidden, caches[17]!, phase, null));
    scope.own(18, this.#l18.forward(scope.hidden, caches[18]!, phase, null));
    scope.own(19, this.#l19.forward(scope.hidden, caches[19]!, phase, null));
    scope.own(20, this.#l20.forward(scope.hidden, caches[20]!, phase, null));
    scope.own(21, this.#l21.forward(scope.hidden, caches[21]!, phase, null));
    scope.own(22, this.#l22.forward(scope.hidden, caches[22]!, phase, null));
    scope.own(23, this.#l23.forward(scope.hidden, caches[23]!, phase, null));
    scope.own(24, this.#l24.forward(scope.hidden, caches[24]!, phase, null));
    scope.own(25, this.#l25.forward(scope.hidden, caches[25]!, phase, null));
    scope.own(26, this.#l26.forward(scope.hidden, caches[26]!, phase, null));
    scope.own(27, this.#l27.forward(scope.hidden, caches[27]!, phase, null));
    scope.own(28, this.#l28.forward(scope.hidden, caches[28]!, phase, null));
    scope.own(29, this.#l29.forward(scope.hidden, caches[29]!, phase, null));
    return scope.finish(30, this.finalNorm.forward(scope.hidden));
  }
  readonly #decode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#decodeHidden(this.#embedTokens(ids), caches, "decode", ids, capture);
  #decodeHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaForwardScope(hidden, capture, CACHES);
    scope.own(0, this.#l0.forward(scope.hidden, caches[0]!, phase, null));
    scope.own(1, this.#l1.forward(scope.hidden, caches[1]!, phase, null));
    scope.own(2, this.#l2.forward(scope.hidden, caches[2]!, phase, null));
    scope.own(3, this.#l3.forward(scope.hidden, caches[3]!, phase, null));
    scope.own(4, this.#l4.forward(scope.hidden, caches[4]!, phase, null));
    scope.own(5, this.#l5.forward(scope.hidden, caches[5]!, phase, null));
    scope.own(6, this.#l6.forward(scope.hidden, caches[6]!, phase, null));
    scope.own(7, this.#l7.forward(scope.hidden, caches[7]!, phase, null));
    scope.own(8, this.#l8.forward(scope.hidden, caches[8]!, phase, null));
    scope.own(9, this.#l9.forward(scope.hidden, caches[9]!, phase, null));
    scope.own(10, this.#l10.forward(scope.hidden, caches[10]!, phase, null));
    scope.own(11, this.#l11.forward(scope.hidden, caches[11]!, phase, null));
    scope.own(12, this.#l12.forward(scope.hidden, caches[12]!, phase, null));
    scope.own(13, this.#l13.forward(scope.hidden, caches[13]!, phase, null));
    scope.own(14, this.#l14.forward(scope.hidden, caches[14]!, phase, null));
    scope.own(15, this.#l15.forward(scope.hidden, caches[15]!, phase, null));
    scope.own(16, this.#l16.forward(scope.hidden, caches[16]!, phase, null));
    scope.own(17, this.#l17.forward(scope.hidden, caches[17]!, phase, null));
    scope.own(18, this.#l18.forward(scope.hidden, caches[18]!, phase, null));
    scope.own(19, this.#l19.forward(scope.hidden, caches[19]!, phase, null));
    scope.own(20, this.#l20.forward(scope.hidden, caches[20]!, phase, null));
    scope.own(21, this.#l21.forward(scope.hidden, caches[21]!, phase, null));
    scope.own(22, this.#l22.forward(scope.hidden, caches[22]!, phase, null));
    scope.own(23, this.#l23.forward(scope.hidden, caches[23]!, phase, null));
    scope.own(24, this.#l24.forward(scope.hidden, caches[24]!, phase, null));
    scope.own(25, this.#l25.forward(scope.hidden, caches[25]!, phase, null));
    scope.own(26, this.#l26.forward(scope.hidden, caches[26]!, phase, null));
    scope.own(27, this.#l27.forward(scope.hidden, caches[27]!, phase, null));
    scope.own(28, this.#l28.forward(scope.hidden, caches[28]!, phase, null));
    scope.own(29, this.#l29.forward(scope.hidden, caches[29]!, phase, null));
    return scope.finish(30, this.finalNorm.forward(scope.hidden));
  }
  readonly #sortedWindow = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#sortedWindowHidden(this.#embedTokens(ids), caches, "window", ids, capture);
  #sortedWindowHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaForwardScope(hidden, capture, CACHES);
    scope.own(0, this.#t0.forward(scope.hidden, caches[0]!, phase, null));
    scope.own(1, this.#t1.forward(scope.hidden, caches[1]!, phase, null));
    scope.own(2, this.#t2.forward(scope.hidden, caches[2]!, phase, null));
    scope.own(3, this.#t3.forward(scope.hidden, caches[3]!, phase, null));
    scope.own(4, this.#t4.forward(scope.hidden, caches[4]!, phase, null));
    scope.own(5, this.#t5.forward(scope.hidden, caches[5]!, phase, null));
    scope.own(6, this.#t6.forward(scope.hidden, caches[6]!, phase, null));
    scope.own(7, this.#t7.forward(scope.hidden, caches[7]!, phase, null));
    scope.own(8, this.#t8.forward(scope.hidden, caches[8]!, phase, null));
    scope.own(9, this.#t9.forward(scope.hidden, caches[9]!, phase, null));
    scope.own(10, this.#t10.forward(scope.hidden, caches[10]!, phase, null));
    scope.own(11, this.#t11.forward(scope.hidden, caches[11]!, phase, null));
    scope.own(12, this.#t12.forward(scope.hidden, caches[12]!, phase, null));
    scope.own(13, this.#t13.forward(scope.hidden, caches[13]!, phase, null));
    scope.own(14, this.#t14.forward(scope.hidden, caches[14]!, phase, null));
    scope.own(15, this.#t15.forward(scope.hidden, caches[15]!, phase, null));
    scope.own(16, this.#t16.forward(scope.hidden, caches[16]!, phase, null));
    scope.own(17, this.#t17.forward(scope.hidden, caches[17]!, phase, null));
    scope.own(18, this.#t18.forward(scope.hidden, caches[18]!, phase, null));
    scope.own(19, this.#t19.forward(scope.hidden, caches[19]!, phase, null));
    scope.own(20, this.#t20.forward(scope.hidden, caches[20]!, phase, null));
    scope.own(21, this.#t21.forward(scope.hidden, caches[21]!, phase, null));
    scope.own(22, this.#t22.forward(scope.hidden, caches[22]!, phase, null));
    scope.own(23, this.#t23.forward(scope.hidden, caches[23]!, phase, null));
    scope.own(24, this.#t24.forward(scope.hidden, caches[24]!, phase, null));
    scope.own(25, this.#t25.forward(scope.hidden, caches[25]!, phase, null));
    scope.own(26, this.#t26.forward(scope.hidden, caches[26]!, phase, null));
    scope.own(27, this.#t27.forward(scope.hidden, caches[27]!, phase, null));
    scope.own(28, this.#t28.forward(scope.hidden, caches[28]!, phase, null));
    scope.own(29, this.#t29.forward(scope.hidden, caches[29]!, phase, null));
    return scope.finish(30, this.finalNorm.forward(scope.hidden));
  }
  readonly #sortedDecode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#sortedDecodeHidden(this.#embedTokens(ids), caches, "decode", ids, capture);
  #sortedDecodeHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaForwardScope(hidden, capture, CACHES);
    scope.own(0, this.#t0.forward(scope.hidden, caches[0]!, phase, null));
    scope.own(1, this.#t1.forward(scope.hidden, caches[1]!, phase, null));
    scope.own(2, this.#t2.forward(scope.hidden, caches[2]!, phase, null));
    scope.own(3, this.#t3.forward(scope.hidden, caches[3]!, phase, null));
    scope.own(4, this.#t4.forward(scope.hidden, caches[4]!, phase, null));
    scope.own(5, this.#t5.forward(scope.hidden, caches[5]!, phase, null));
    scope.own(6, this.#t6.forward(scope.hidden, caches[6]!, phase, null));
    scope.own(7, this.#t7.forward(scope.hidden, caches[7]!, phase, null));
    scope.own(8, this.#t8.forward(scope.hidden, caches[8]!, phase, null));
    scope.own(9, this.#t9.forward(scope.hidden, caches[9]!, phase, null));
    scope.own(10, this.#t10.forward(scope.hidden, caches[10]!, phase, null));
    scope.own(11, this.#t11.forward(scope.hidden, caches[11]!, phase, null));
    scope.own(12, this.#t12.forward(scope.hidden, caches[12]!, phase, null));
    scope.own(13, this.#t13.forward(scope.hidden, caches[13]!, phase, null));
    scope.own(14, this.#t14.forward(scope.hidden, caches[14]!, phase, null));
    scope.own(15, this.#t15.forward(scope.hidden, caches[15]!, phase, null));
    scope.own(16, this.#t16.forward(scope.hidden, caches[16]!, phase, null));
    scope.own(17, this.#t17.forward(scope.hidden, caches[17]!, phase, null));
    scope.own(18, this.#t18.forward(scope.hidden, caches[18]!, phase, null));
    scope.own(19, this.#t19.forward(scope.hidden, caches[19]!, phase, null));
    scope.own(20, this.#t20.forward(scope.hidden, caches[20]!, phase, null));
    scope.own(21, this.#t21.forward(scope.hidden, caches[21]!, phase, null));
    scope.own(22, this.#t22.forward(scope.hidden, caches[22]!, phase, null));
    scope.own(23, this.#t23.forward(scope.hidden, caches[23]!, phase, null));
    scope.own(24, this.#t24.forward(scope.hidden, caches[24]!, phase, null));
    scope.own(25, this.#t25.forward(scope.hidden, caches[25]!, phase, null));
    scope.own(26, this.#t26.forward(scope.hidden, caches[26]!, phase, null));
    scope.own(27, this.#t27.forward(scope.hidden, caches[27]!, phase, null));
    scope.own(28, this.#t28.forward(scope.hidden, caches[28]!, phase, null));
    scope.own(29, this.#t29.forward(scope.hidden, caches[29]!, phase, null));
    return scope.finish(30, this.finalNorm.forward(scope.hidden));
  }
  readonly #known = (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null);
  readonly #sortedKnown = (ids: MlxArray, caches: Cache[]) => this.#sortedWindow(ids, caches, null);
  readonly #head = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, compiledLogitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly traceLogits = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, logitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly #mixed = (work: Parameters<MlxMixedRange["operation"]>[0]): MlxArray[] => {
    using scope = new GemmaMixedScope(work, ids => this.#embedTokens(ids), CACHES);
    scope.layer(0, (x, group) => ownMixed(this.#l0.forwardAttn(x, group.cache[0]!, group.phase, null)), x => this.#l0.feedforward(x));
    scope.layer(1, (x, group) => ownMixed(this.#l1.forwardAttn(x, group.cache[1]!, group.phase, null)), x => this.#l1.feedforward(x));
    scope.layer(2, (x, group) => ownMixed(this.#l2.forwardAttn(x, group.cache[2]!, group.phase, null)), x => this.#l2.feedforward(x));
    scope.layer(3, (x, group) => ownMixed(this.#l3.forwardAttn(x, group.cache[3]!, group.phase, null)), x => this.#l3.feedforward(x));
    scope.layer(4, (x, group) => ownMixed(this.#l4.forwardAttn(x, group.cache[4]!, group.phase, null)), x => this.#l4.feedforward(x));
    scope.layer(5, (x, group) => ownMixed(this.#l5.forwardAttn(x, group.cache[5]!, group.phase, null)), x => this.#l5.feedforward(x));
    scope.layer(6, (x, group) => ownMixed(this.#l6.forwardAttn(x, group.cache[6]!, group.phase, null)), x => this.#l6.feedforward(x));
    scope.layer(7, (x, group) => ownMixed(this.#l7.forwardAttn(x, group.cache[7]!, group.phase, null)), x => this.#l7.feedforward(x));
    scope.layer(8, (x, group) => ownMixed(this.#l8.forwardAttn(x, group.cache[8]!, group.phase, null)), x => this.#l8.feedforward(x));
    scope.layer(9, (x, group) => ownMixed(this.#l9.forwardAttn(x, group.cache[9]!, group.phase, null)), x => this.#l9.feedforward(x));
    scope.layer(10, (x, group) => ownMixed(this.#l10.forwardAttn(x, group.cache[10]!, group.phase, null)), x => this.#l10.feedforward(x));
    scope.layer(11, (x, group) => ownMixed(this.#l11.forwardAttn(x, group.cache[11]!, group.phase, null)), x => this.#l11.feedforward(x));
    scope.layer(12, (x, group) => ownMixed(this.#l12.forwardAttn(x, group.cache[12]!, group.phase, null)), x => this.#l12.feedforward(x));
    scope.layer(13, (x, group) => ownMixed(this.#l13.forwardAttn(x, group.cache[13]!, group.phase, null)), x => this.#l13.feedforward(x));
    scope.layer(14, (x, group) => ownMixed(this.#l14.forwardAttn(x, group.cache[14]!, group.phase, null)), x => this.#l14.feedforward(x));
    scope.layer(15, (x, group) => ownMixed(this.#l15.forwardAttn(x, group.cache[15]!, group.phase, null)), x => this.#l15.feedforward(x));
    scope.layer(16, (x, group) => ownMixed(this.#l16.forwardAttn(x, group.cache[16]!, group.phase, null)), x => this.#l16.feedforward(x));
    scope.layer(17, (x, group) => ownMixed(this.#l17.forwardAttn(x, group.cache[17]!, group.phase, null)), x => this.#l17.feedforward(x));
    scope.layer(18, (x, group) => ownMixed(this.#l18.forwardAttn(x, group.cache[18]!, group.phase, null)), x => this.#l18.feedforward(x));
    scope.layer(19, (x, group) => ownMixed(this.#l19.forwardAttn(x, group.cache[19]!, group.phase, null)), x => this.#l19.feedforward(x));
    scope.layer(20, (x, group) => ownMixed(this.#l20.forwardAttn(x, group.cache[20]!, group.phase, null)), x => this.#l20.feedforward(x));
    scope.layer(21, (x, group) => ownMixed(this.#l21.forwardAttn(x, group.cache[21]!, group.phase, null)), x => this.#l21.feedforward(x));
    scope.layer(22, (x, group) => ownMixed(this.#l22.forwardAttn(x, group.cache[22]!, group.phase, null)), x => this.#l22.feedforward(x));
    scope.layer(23, (x, group) => ownMixed(this.#l23.forwardAttn(x, group.cache[23]!, group.phase, null)), x => this.#l23.feedforward(x));
    scope.layer(24, (x, group) => ownMixed(this.#l24.forwardAttn(x, group.cache[24]!, group.phase, null)), x => this.#l24.feedforward(x));
    scope.layer(25, (x, group) => ownMixed(this.#l25.forwardAttn(x, group.cache[25]!, group.phase, null)), x => this.#l25.feedforward(x));
    scope.layer(26, (x, group) => ownMixed(this.#l26.forwardAttn(x, group.cache[26]!, group.phase, null)), x => this.#l26.feedforward(x));
    scope.layer(27, (x, group) => ownMixed(this.#l27.forwardAttn(x, group.cache[27]!, group.phase, null)), x => this.#l27.feedforward(x));
    scope.layer(28, (x, group) => ownMixed(this.#l28.forwardAttn(x, group.cache[28]!, group.phase, null)), x => this.#l28.feedforward(x));
    scope.layer(29, (x, group) => ownMixed(this.#l29.forwardAttn(x, group.cache[29]!, group.phase, null)), x => this.#l29.feedforward(x));
    return scope.finish(30, this.finalNorm);
  };
  readonly #sortedMixed = (work: Parameters<MlxMixedRange["operation"]>[0]): MlxArray[] => {
    using scope = new GemmaMixedScope(work, ids => this.#embedTokens(ids), CACHES);
    scope.layer(0, (x, group) => ownMixed(this.#t0.forwardAttn(x, group.cache[0]!, group.phase, null)), x => this.#t0.feedforward(x));
    scope.layer(1, (x, group) => ownMixed(this.#t1.forwardAttn(x, group.cache[1]!, group.phase, null)), x => this.#t1.feedforward(x));
    scope.layer(2, (x, group) => ownMixed(this.#t2.forwardAttn(x, group.cache[2]!, group.phase, null)), x => this.#t2.feedforward(x));
    scope.layer(3, (x, group) => ownMixed(this.#t3.forwardAttn(x, group.cache[3]!, group.phase, null)), x => this.#t3.feedforward(x));
    scope.layer(4, (x, group) => ownMixed(this.#t4.forwardAttn(x, group.cache[4]!, group.phase, null)), x => this.#t4.feedforward(x));
    scope.layer(5, (x, group) => ownMixed(this.#t5.forwardAttn(x, group.cache[5]!, group.phase, null)), x => this.#t5.feedforward(x));
    scope.layer(6, (x, group) => ownMixed(this.#t6.forwardAttn(x, group.cache[6]!, group.phase, null)), x => this.#t6.feedforward(x));
    scope.layer(7, (x, group) => ownMixed(this.#t7.forwardAttn(x, group.cache[7]!, group.phase, null)), x => this.#t7.feedforward(x));
    scope.layer(8, (x, group) => ownMixed(this.#t8.forwardAttn(x, group.cache[8]!, group.phase, null)), x => this.#t8.feedforward(x));
    scope.layer(9, (x, group) => ownMixed(this.#t9.forwardAttn(x, group.cache[9]!, group.phase, null)), x => this.#t9.feedforward(x));
    scope.layer(10, (x, group) => ownMixed(this.#t10.forwardAttn(x, group.cache[10]!, group.phase, null)), x => this.#t10.feedforward(x));
    scope.layer(11, (x, group) => ownMixed(this.#t11.forwardAttn(x, group.cache[11]!, group.phase, null)), x => this.#t11.feedforward(x));
    scope.layer(12, (x, group) => ownMixed(this.#t12.forwardAttn(x, group.cache[12]!, group.phase, null)), x => this.#t12.feedforward(x));
    scope.layer(13, (x, group) => ownMixed(this.#t13.forwardAttn(x, group.cache[13]!, group.phase, null)), x => this.#t13.feedforward(x));
    scope.layer(14, (x, group) => ownMixed(this.#t14.forwardAttn(x, group.cache[14]!, group.phase, null)), x => this.#t14.feedforward(x));
    scope.layer(15, (x, group) => ownMixed(this.#t15.forwardAttn(x, group.cache[15]!, group.phase, null)), x => this.#t15.feedforward(x));
    scope.layer(16, (x, group) => ownMixed(this.#t16.forwardAttn(x, group.cache[16]!, group.phase, null)), x => this.#t16.feedforward(x));
    scope.layer(17, (x, group) => ownMixed(this.#t17.forwardAttn(x, group.cache[17]!, group.phase, null)), x => this.#t17.feedforward(x));
    scope.layer(18, (x, group) => ownMixed(this.#t18.forwardAttn(x, group.cache[18]!, group.phase, null)), x => this.#t18.feedforward(x));
    scope.layer(19, (x, group) => ownMixed(this.#t19.forwardAttn(x, group.cache[19]!, group.phase, null)), x => this.#t19.feedforward(x));
    scope.layer(20, (x, group) => ownMixed(this.#t20.forwardAttn(x, group.cache[20]!, group.phase, null)), x => this.#t20.feedforward(x));
    scope.layer(21, (x, group) => ownMixed(this.#t21.forwardAttn(x, group.cache[21]!, group.phase, null)), x => this.#t21.feedforward(x));
    scope.layer(22, (x, group) => ownMixed(this.#t22.forwardAttn(x, group.cache[22]!, group.phase, null)), x => this.#t22.feedforward(x));
    scope.layer(23, (x, group) => ownMixed(this.#t23.forwardAttn(x, group.cache[23]!, group.phase, null)), x => this.#t23.feedforward(x));
    scope.layer(24, (x, group) => ownMixed(this.#t24.forwardAttn(x, group.cache[24]!, group.phase, null)), x => this.#t24.feedforward(x));
    scope.layer(25, (x, group) => ownMixed(this.#t25.forwardAttn(x, group.cache[25]!, group.phase, null)), x => this.#t25.feedforward(x));
    scope.layer(26, (x, group) => ownMixed(this.#t26.forwardAttn(x, group.cache[26]!, group.phase, null)), x => this.#t26.feedforward(x));
    scope.layer(27, (x, group) => ownMixed(this.#t27.forwardAttn(x, group.cache[27]!, group.phase, null)), x => this.#t27.feedforward(x));
    scope.layer(28, (x, group) => ownMixed(this.#t28.forwardAttn(x, group.cache[28]!, group.phase, null)), x => this.#t28.feedforward(x));
    scope.layer(29, (x, group) => ownMixed(this.#t29.forwardAttn(x, group.cache[29]!, group.phase, null)), x => this.#t29.feedforward(x));
    return scope.finish(30, this.finalNorm);
  };
  #embedTokens(ids: MlxArray): MlxArray { const hidden = this.embed.encode(ids); return disposing(hidden, ops.mulScalar(hidden, this.embedScale)); }
  loraTargets() { return denseLoraTargets(this.#parts); }
  materializeGraphConstants(): void { ops.evalAll(this.#constants.borrow()); }
  dispose(): void { this.#constants.close(); }
  bindMediaInput(input: Vision) { return bindGemma4MediaInput(this, input); }
  mediaEncoders(modelDir: string, probes: MediaSidecarProbes) { return gemma4MediaEncoders(this, modelDir, probes); }
  draftTarget(caches: Cache[]) { return gemma4DraftTarget(this, caches); }
  logitsFromHidden(hidden: MlxArray): MlxArray { return this.#head(hidden); }
  readonly mixedSeparate = Object.freeze({
    decode: Object.freeze([{ from: 1, to: 7, operation: (group: MlxPhaseGroup) => this.#decode(group.ids, group.state, group.capture) }, { from: 8, to: Infinity, operation: (group: MlxPhaseGroup) => this.#sortedDecode(group.ids, group.state, group.capture) }]),
    window: Object.freeze([{ from: 1, to: 7, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }, { from: 8, to: Infinity, operation: (group: MlxPhaseGroup) => this.#sortedWindow(group.ids, group.state, group.capture) }]),
    verify: Object.freeze([{ from: 1, to: 7, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }, { from: 8, to: Infinity, operation: (group: MlxPhaseGroup) => this.#sortedWindow(group.ids, group.state, group.capture) }]),
  });
  readonly sequence = Object.freeze([{ from: 1, to: 7, operation: (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null) }, { from: 8, to: Infinity, operation: (ids: MlxArray, caches: Cache[]) => this.#sortedWindow(ids, caches, null) }]);

  readonly mediaPrefill = Object.freeze([{ from: 1, to: 7, operation: (embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null) => writtenMedia(this.embedScale, (hidden, cache, phase, tokens) => this.#windowHidden(hidden, cache, phase, tokens, null), embeds, caches, bidir, ids) }, { from: 8, to: Infinity, operation: (embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null) => writtenMedia(this.embedScale, (hidden, cache, phase, tokens) => this.#sortedWindowHidden(hidden, cache, phase, tokens, null), embeds, caches, bidir, ids) }]);
}
import { writtenMedia, writtenInputMedia } from "./written-input";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Gemma426b
