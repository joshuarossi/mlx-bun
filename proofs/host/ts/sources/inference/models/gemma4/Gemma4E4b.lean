import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Gemma4E4b
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/gemma4-e4b.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Written Gemma 4 e4b graph. Layer order and every operation binding are literal.
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
import { SlidingAttention, FullAttention, FullKEqVAttention, SharedSlidingAttention, SharedFullAttention, GemmaLayerWeights, GemmaInputLayerWeights, GemmaMoeLayerWeights, GemmaDenseLayer, GemmaInputLayer, GemmaMoeLayer, CompiledGegluMLP, PlainGegluMLP, CompiledGeglu, SortedSwitchGLU, UnsortedSwitchGLU, FixedExperts, FixedPerLayerInputs, TracePerLayerInputs } from "./written-blocks";
import { GemmaForwardScope, GemmaInputForwardScope, GemmaMixedScope, ownMixed, donorMixed, sharedMixed, denseLoraTargets, inputLoraTargets, weightBytes, GemmaBuildScope } from "./written-forward";
export const FINGERPRINT = GEMMA_GRAPH_FINGERPRINTS["e4b"];

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

/** The artifact's layers and kv_config, from mlx-community/gemma-4-e4b-it-OptiQ-4bit@98d7dc6a93ae05583e8a10018c8099459b58aeeb. */
export const LAYERS: readonly Gemma4Layer[] = Object.freeze([
  /*  0 */ { attention: "sliding", cache: 0, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  1 */ { attention: "sliding", cache: 1, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  2 */ { attention: "sliding", cache: 2, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  3 */ { attention: "sliding", cache: 3, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  4 */ { attention: "sliding", cache: 4, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  5 */ { attention: "full", cache: 5, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  6 */ { attention: "sliding", cache: 6, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  7 */ { attention: "sliding", cache: 7, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  8 */ { attention: "sliding", cache: 8, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  9 */ { attention: "sliding", cache: 9, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 10 */ { attention: "sliding", cache: 10, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 11 */ { attention: "full", cache: 11, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 12 */ { attention: "sliding", cache: 12, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 13 */ { attention: "sliding", cache: 13, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 14 */ { attention: "sliding", cache: 14, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 15 */ { attention: "sliding", cache: 15, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 16 */ { attention: "sliding", cache: 16, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 17 */ { attention: "full", cache: 17, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 18 */ { attention: "sliding", cache: 18, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 19 */ { attention: "sliding", cache: 19, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 20 */ { attention: "sliding", cache: 20, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 21 */ { attention: "sliding", cache: 21, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 22 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 23 */ { attention: "full", cache: 23, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 24 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 25 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 26 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 27 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 28 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 29 */ { attention: "full", cache: 23, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 30 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 31 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 32 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 33 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 34 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 35 */ { attention: "full", cache: 23, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 36 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 37 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 38 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 39 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 40 */ { attention: "sliding", cache: 22, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 41 */ { attention: "full", cache: 23, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
]);

/** Layers [0, CACHES) own a cache. */
const CACHES = 24;
/** The donors whose read later layers attend. */
const PREFIX = "language_model.model";
const FINAL_LOGIT_SOFTCAP = 30;

export const DECODE_ROWS = 8;
export const VERIFY_ROWS = 64;

export class Gemma4E4b implements MlxDeclaredGraph, MlxTokenPhases {
  readonly prefixBase = PREFIX;
  readonly loraState = new LoraState();
  readonly weightsBytes: number;
  readonly embed: QuantizedEmbedding;
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  readonly numDonors = CACHES;
  readonly perLayerWidth: number;
  readonly graphCapabilities = declareGraph({ media: { input: "embeddings", video: false }, hiddenLayerTaps: true, compiledDecode: true });
  makeCache!: () => Cache[];
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly layers: readonly GemmaInputLayer[];
  readonly traceLayers: readonly GemmaInputLayer[];
  readonly #constants: ReturnType<typeof ownResource<MlxArray[]>>;
  readonly #parts: readonly GemmaInputLayerWeights[];
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];
  readonly decode: MlxRowTable<MlxCapturingForward>;
  readonly verify: MlxRowTable<MlxCapturingForward>;
  readonly appendKnown: MlxKnownOperations;
  readonly logits: MlxRowTable<MlxHeadForward>;
  readonly mixed: readonly MlxMixedRange[];
  readonly #inputs: FixedPerLayerInputs;
  readonly #traceInputs: TracePerLayerInputs;
  readonly #l0: GemmaInputLayer;
  readonly #t0: GemmaInputLayer;
  readonly #l1: GemmaInputLayer;
  readonly #t1: GemmaInputLayer;
  readonly #l2: GemmaInputLayer;
  readonly #t2: GemmaInputLayer;
  readonly #l3: GemmaInputLayer;
  readonly #t3: GemmaInputLayer;
  readonly #l4: GemmaInputLayer;
  readonly #t4: GemmaInputLayer;
  readonly #l5: GemmaInputLayer;
  readonly #t5: GemmaInputLayer;
  readonly #l6: GemmaInputLayer;
  readonly #t6: GemmaInputLayer;
  readonly #l7: GemmaInputLayer;
  readonly #t7: GemmaInputLayer;
  readonly #l8: GemmaInputLayer;
  readonly #t8: GemmaInputLayer;
  readonly #l9: GemmaInputLayer;
  readonly #t9: GemmaInputLayer;
  readonly #l10: GemmaInputLayer;
  readonly #t10: GemmaInputLayer;
  readonly #l11: GemmaInputLayer;
  readonly #t11: GemmaInputLayer;
  readonly #l12: GemmaInputLayer;
  readonly #t12: GemmaInputLayer;
  readonly #l13: GemmaInputLayer;
  readonly #t13: GemmaInputLayer;
  readonly #l14: GemmaInputLayer;
  readonly #t14: GemmaInputLayer;
  readonly #l15: GemmaInputLayer;
  readonly #t15: GemmaInputLayer;
  readonly #l16: GemmaInputLayer;
  readonly #t16: GemmaInputLayer;
  readonly #l17: GemmaInputLayer;
  readonly #t17: GemmaInputLayer;
  readonly #l18: GemmaInputLayer;
  readonly #t18: GemmaInputLayer;
  readonly #l19: GemmaInputLayer;
  readonly #t19: GemmaInputLayer;
  readonly #l20: GemmaInputLayer;
  readonly #t20: GemmaInputLayer;
  readonly #l21: GemmaInputLayer;
  readonly #t21: GemmaInputLayer;
  readonly #l22: GemmaInputLayer;
  readonly #t22: GemmaInputLayer;
  readonly #l23: GemmaInputLayer;
  readonly #t23: GemmaInputLayer;
  readonly #l24: GemmaInputLayer;
  readonly #t24: GemmaInputLayer;
  readonly #l25: GemmaInputLayer;
  readonly #t25: GemmaInputLayer;
  readonly #l26: GemmaInputLayer;
  readonly #t26: GemmaInputLayer;
  readonly #l27: GemmaInputLayer;
  readonly #t27: GemmaInputLayer;
  readonly #l28: GemmaInputLayer;
  readonly #t28: GemmaInputLayer;
  readonly #l29: GemmaInputLayer;
  readonly #t29: GemmaInputLayer;
  readonly #l30: GemmaInputLayer;
  readonly #t30: GemmaInputLayer;
  readonly #l31: GemmaInputLayer;
  readonly #t31: GemmaInputLayer;
  readonly #l32: GemmaInputLayer;
  readonly #t32: GemmaInputLayer;
  readonly #l33: GemmaInputLayer;
  readonly #t33: GemmaInputLayer;
  readonly #l34: GemmaInputLayer;
  readonly #t34: GemmaInputLayer;
  readonly #l35: GemmaInputLayer;
  readonly #t35: GemmaInputLayer;
  readonly #l36: GemmaInputLayer;
  readonly #t36: GemmaInputLayer;
  readonly #l37: GemmaInputLayer;
  readonly #t37: GemmaInputLayer;
  readonly #l38: GemmaInputLayer;
  readonly #t38: GemmaInputLayer;
  readonly #l39: GemmaInputLayer;
  readonly #t39: GemmaInputLayer;
  readonly #l40: GemmaInputLayer;
  readonly #t40: GemmaInputLayer;
  readonly #l41: GemmaInputLayer;
  readonly #t41: GemmaInputLayer;
  constructor(weights: Weights, readonly config: ModelConfig) {
    using resources = new GemmaBuildScope();
    this.weightsBytes = weightBytes(weights);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.embed_tokens`, config);
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.norm.weight`), config.text.rmsNormEps);
    this.embedScale = Math.sqrt(config.text.hiddenSize);
    this.windowSize = config.text.slidingWindow;
    this.#inputs = new FixedPerLayerInputs(weights, config, PREFIX);
    this.#traceInputs = new TracePerLayerInputs(weights, config, PREFIX);
    this.perLayerWidth = this.#inputs.width;
    const p0 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.0`, new SlidingAttention(weights, config, `${PREFIX}.layers.0.self_attn`)));
    this.#l0 = new GemmaInputLayer(p0, new CompiledGegluMLP(p0.mlp));
    this.#t0 = new GemmaInputLayer(p0, new PlainGegluMLP(p0.mlp));
    const p1 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.1`, new SlidingAttention(weights, config, `${PREFIX}.layers.1.self_attn`)));
    this.#l1 = new GemmaInputLayer(p1, new CompiledGegluMLP(p1.mlp));
    this.#t1 = new GemmaInputLayer(p1, new PlainGegluMLP(p1.mlp));
    const p2 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.2`, new SlidingAttention(weights, config, `${PREFIX}.layers.2.self_attn`)));
    this.#l2 = new GemmaInputLayer(p2, new CompiledGegluMLP(p2.mlp));
    this.#t2 = new GemmaInputLayer(p2, new PlainGegluMLP(p2.mlp));
    const p3 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.3`, new SlidingAttention(weights, config, `${PREFIX}.layers.3.self_attn`)));
    this.#l3 = new GemmaInputLayer(p3, new CompiledGegluMLP(p3.mlp));
    this.#t3 = new GemmaInputLayer(p3, new PlainGegluMLP(p3.mlp));
    const p4 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.4`, new SlidingAttention(weights, config, `${PREFIX}.layers.4.self_attn`)));
    this.#l4 = new GemmaInputLayer(p4, new CompiledGegluMLP(p4.mlp));
    this.#t4 = new GemmaInputLayer(p4, new PlainGegluMLP(p4.mlp));
    const p5 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.5`, new FullAttention(weights, config, `${PREFIX}.layers.5.self_attn`)));
    this.#l5 = new GemmaInputLayer(p5, new CompiledGegluMLP(p5.mlp));
    this.#t5 = new GemmaInputLayer(p5, new PlainGegluMLP(p5.mlp));
    const p6 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.6`, new SlidingAttention(weights, config, `${PREFIX}.layers.6.self_attn`)));
    this.#l6 = new GemmaInputLayer(p6, new CompiledGegluMLP(p6.mlp));
    this.#t6 = new GemmaInputLayer(p6, new PlainGegluMLP(p6.mlp));
    const p7 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.7`, new SlidingAttention(weights, config, `${PREFIX}.layers.7.self_attn`)));
    this.#l7 = new GemmaInputLayer(p7, new CompiledGegluMLP(p7.mlp));
    this.#t7 = new GemmaInputLayer(p7, new PlainGegluMLP(p7.mlp));
    const p8 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.8`, new SlidingAttention(weights, config, `${PREFIX}.layers.8.self_attn`)));
    this.#l8 = new GemmaInputLayer(p8, new CompiledGegluMLP(p8.mlp));
    this.#t8 = new GemmaInputLayer(p8, new PlainGegluMLP(p8.mlp));
    const p9 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.9`, new SlidingAttention(weights, config, `${PREFIX}.layers.9.self_attn`)));
    this.#l9 = new GemmaInputLayer(p9, new CompiledGegluMLP(p9.mlp));
    this.#t9 = new GemmaInputLayer(p9, new PlainGegluMLP(p9.mlp));
    const p10 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.10`, new SlidingAttention(weights, config, `${PREFIX}.layers.10.self_attn`)));
    this.#l10 = new GemmaInputLayer(p10, new CompiledGegluMLP(p10.mlp));
    this.#t10 = new GemmaInputLayer(p10, new PlainGegluMLP(p10.mlp));
    const p11 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.11`, new FullAttention(weights, config, `${PREFIX}.layers.11.self_attn`)));
    this.#l11 = new GemmaInputLayer(p11, new CompiledGegluMLP(p11.mlp));
    this.#t11 = new GemmaInputLayer(p11, new PlainGegluMLP(p11.mlp));
    const p12 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.12`, new SlidingAttention(weights, config, `${PREFIX}.layers.12.self_attn`)));
    this.#l12 = new GemmaInputLayer(p12, new CompiledGegluMLP(p12.mlp));
    this.#t12 = new GemmaInputLayer(p12, new PlainGegluMLP(p12.mlp));
    const p13 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.13`, new SlidingAttention(weights, config, `${PREFIX}.layers.13.self_attn`)));
    this.#l13 = new GemmaInputLayer(p13, new CompiledGegluMLP(p13.mlp));
    this.#t13 = new GemmaInputLayer(p13, new PlainGegluMLP(p13.mlp));
    const p14 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.14`, new SlidingAttention(weights, config, `${PREFIX}.layers.14.self_attn`)));
    this.#l14 = new GemmaInputLayer(p14, new CompiledGegluMLP(p14.mlp));
    this.#t14 = new GemmaInputLayer(p14, new PlainGegluMLP(p14.mlp));
    const p15 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.15`, new SlidingAttention(weights, config, `${PREFIX}.layers.15.self_attn`)));
    this.#l15 = new GemmaInputLayer(p15, new CompiledGegluMLP(p15.mlp));
    this.#t15 = new GemmaInputLayer(p15, new PlainGegluMLP(p15.mlp));
    const p16 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.16`, new SlidingAttention(weights, config, `${PREFIX}.layers.16.self_attn`)));
    this.#l16 = new GemmaInputLayer(p16, new CompiledGegluMLP(p16.mlp));
    this.#t16 = new GemmaInputLayer(p16, new PlainGegluMLP(p16.mlp));
    const p17 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.17`, new FullAttention(weights, config, `${PREFIX}.layers.17.self_attn`)));
    this.#l17 = new GemmaInputLayer(p17, new CompiledGegluMLP(p17.mlp));
    this.#t17 = new GemmaInputLayer(p17, new PlainGegluMLP(p17.mlp));
    const p18 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.18`, new SlidingAttention(weights, config, `${PREFIX}.layers.18.self_attn`)));
    this.#l18 = new GemmaInputLayer(p18, new CompiledGegluMLP(p18.mlp));
    this.#t18 = new GemmaInputLayer(p18, new PlainGegluMLP(p18.mlp));
    const p19 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.19`, new SlidingAttention(weights, config, `${PREFIX}.layers.19.self_attn`)));
    this.#l19 = new GemmaInputLayer(p19, new CompiledGegluMLP(p19.mlp));
    this.#t19 = new GemmaInputLayer(p19, new PlainGegluMLP(p19.mlp));
    const p20 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.20`, new SlidingAttention(weights, config, `${PREFIX}.layers.20.self_attn`)));
    this.#l20 = new GemmaInputLayer(p20, new CompiledGegluMLP(p20.mlp));
    this.#t20 = new GemmaInputLayer(p20, new PlainGegluMLP(p20.mlp));
    const p21 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.21`, new SlidingAttention(weights, config, `${PREFIX}.layers.21.self_attn`)));
    this.#l21 = new GemmaInputLayer(p21, new CompiledGegluMLP(p21.mlp));
    this.#t21 = new GemmaInputLayer(p21, new PlainGegluMLP(p21.mlp));
    const p22 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.22`, new SlidingAttention(weights, config, `${PREFIX}.layers.22.self_attn`)));
    this.#l22 = new GemmaInputLayer(p22, new CompiledGegluMLP(p22.mlp));
    this.#t22 = new GemmaInputLayer(p22, new PlainGegluMLP(p22.mlp));
    const p23 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.23`, new FullAttention(weights, config, `${PREFIX}.layers.23.self_attn`)));
    this.#l23 = new GemmaInputLayer(p23, new CompiledGegluMLP(p23.mlp));
    this.#t23 = new GemmaInputLayer(p23, new PlainGegluMLP(p23.mlp));
    const p24 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.24`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.24.self_attn`)));
    this.#l24 = new GemmaInputLayer(p24, new CompiledGegluMLP(p24.mlp));
    this.#t24 = new GemmaInputLayer(p24, new PlainGegluMLP(p24.mlp));
    const p25 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.25`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.25.self_attn`)));
    this.#l25 = new GemmaInputLayer(p25, new CompiledGegluMLP(p25.mlp));
    this.#t25 = new GemmaInputLayer(p25, new PlainGegluMLP(p25.mlp));
    const p26 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.26`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.26.self_attn`)));
    this.#l26 = new GemmaInputLayer(p26, new CompiledGegluMLP(p26.mlp));
    this.#t26 = new GemmaInputLayer(p26, new PlainGegluMLP(p26.mlp));
    const p27 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.27`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.27.self_attn`)));
    this.#l27 = new GemmaInputLayer(p27, new CompiledGegluMLP(p27.mlp));
    this.#t27 = new GemmaInputLayer(p27, new PlainGegluMLP(p27.mlp));
    const p28 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.28`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.28.self_attn`)));
    this.#l28 = new GemmaInputLayer(p28, new CompiledGegluMLP(p28.mlp));
    this.#t28 = new GemmaInputLayer(p28, new PlainGegluMLP(p28.mlp));
    const p29 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.29`, new SharedFullAttention(weights, config, `${PREFIX}.layers.29.self_attn`)));
    this.#l29 = new GemmaInputLayer(p29, new CompiledGegluMLP(p29.mlp));
    this.#t29 = new GemmaInputLayer(p29, new PlainGegluMLP(p29.mlp));
    const p30 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.30`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.30.self_attn`)));
    this.#l30 = new GemmaInputLayer(p30, new CompiledGegluMLP(p30.mlp));
    this.#t30 = new GemmaInputLayer(p30, new PlainGegluMLP(p30.mlp));
    const p31 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.31`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.31.self_attn`)));
    this.#l31 = new GemmaInputLayer(p31, new CompiledGegluMLP(p31.mlp));
    this.#t31 = new GemmaInputLayer(p31, new PlainGegluMLP(p31.mlp));
    const p32 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.32`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.32.self_attn`)));
    this.#l32 = new GemmaInputLayer(p32, new CompiledGegluMLP(p32.mlp));
    this.#t32 = new GemmaInputLayer(p32, new PlainGegluMLP(p32.mlp));
    const p33 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.33`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.33.self_attn`)));
    this.#l33 = new GemmaInputLayer(p33, new CompiledGegluMLP(p33.mlp));
    this.#t33 = new GemmaInputLayer(p33, new PlainGegluMLP(p33.mlp));
    const p34 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.34`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.34.self_attn`)));
    this.#l34 = new GemmaInputLayer(p34, new CompiledGegluMLP(p34.mlp));
    this.#t34 = new GemmaInputLayer(p34, new PlainGegluMLP(p34.mlp));
    const p35 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.35`, new SharedFullAttention(weights, config, `${PREFIX}.layers.35.self_attn`)));
    this.#l35 = new GemmaInputLayer(p35, new CompiledGegluMLP(p35.mlp));
    this.#t35 = new GemmaInputLayer(p35, new PlainGegluMLP(p35.mlp));
    const p36 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.36`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.36.self_attn`)));
    this.#l36 = new GemmaInputLayer(p36, new CompiledGegluMLP(p36.mlp));
    this.#t36 = new GemmaInputLayer(p36, new PlainGegluMLP(p36.mlp));
    const p37 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.37`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.37.self_attn`)));
    this.#l37 = new GemmaInputLayer(p37, new CompiledGegluMLP(p37.mlp));
    this.#t37 = new GemmaInputLayer(p37, new PlainGegluMLP(p37.mlp));
    const p38 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.38`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.38.self_attn`)));
    this.#l38 = new GemmaInputLayer(p38, new CompiledGegluMLP(p38.mlp));
    this.#t38 = new GemmaInputLayer(p38, new PlainGegluMLP(p38.mlp));
    const p39 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.39`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.39.self_attn`)));
    this.#l39 = new GemmaInputLayer(p39, new CompiledGegluMLP(p39.mlp));
    this.#t39 = new GemmaInputLayer(p39, new PlainGegluMLP(p39.mlp));
    const p40 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.40`, new SharedSlidingAttention(weights, config, `${PREFIX}.layers.40.self_attn`)));
    this.#l40 = new GemmaInputLayer(p40, new CompiledGegluMLP(p40.mlp));
    this.#t40 = new GemmaInputLayer(p40, new PlainGegluMLP(p40.mlp));
    const p41 = resources.hold(new GemmaInputLayerWeights(weights, config, `${PREFIX}.layers.41`, new SharedFullAttention(weights, config, `${PREFIX}.layers.41.self_attn`)));
    this.#l41 = new GemmaInputLayer(p41, new CompiledGegluMLP(p41.mlp));
    this.#t41 = new GemmaInputLayer(p41, new PlainGegluMLP(p41.mlp));
    this.layers = Object.freeze([this.#l0, this.#l1, this.#l2, this.#l3, this.#l4, this.#l5, this.#l6, this.#l7, this.#l8, this.#l9, this.#l10, this.#l11, this.#l12, this.#l13, this.#l14, this.#l15, this.#l16, this.#l17, this.#l18, this.#l19, this.#l20, this.#l21, this.#l22, this.#l23, this.#l24, this.#l25, this.#l26, this.#l27, this.#l28, this.#l29, this.#l30, this.#l31, this.#l32, this.#l33, this.#l34, this.#l35, this.#l36, this.#l37, this.#l38, this.#l39, this.#l40, this.#l41]);
    this.traceLayers = Object.freeze([this.#t0, this.#t1, this.#t2, this.#t3, this.#t4, this.#t5, this.#t6, this.#t7, this.#t8, this.#t9, this.#t10, this.#t11, this.#t12, this.#t13, this.#t14, this.#t15, this.#t16, this.#t17, this.#t18, this.#t19, this.#t20, this.#t21, this.#t22, this.#t23, this.#t24, this.#t25, this.#t26, this.#t27, this.#t28, this.#t29, this.#t30, this.#t31, this.#t32, this.#t33, this.#t34, this.#t35, this.#t36, this.#t37, this.#t38, this.#t39, this.#t40, this.#t41]);
    this.#parts = Object.freeze([p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41]);
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
    ]);
    this.prompt = Object.freeze([{ from: 1, to: Infinity, operation: this.#window }]);
    this.promptChunk = this.prompt;
    this.multiSequencePrompt = this.prompt;
    this.multiSequencePromptChunk = this.multiSequencePrompt;
    this.decode = Object.freeze({ 1: this.#decode, 2: this.#decode, 3: this.#decode, 4: this.#decode, 5: this.#decode, 6: this.#decode, 7: this.#decode, 8: this.#decode ,
      default: this.#decode,
    });
    this.verify = Object.freeze({ 1: this.#window, 2: this.#window, 3: this.#window, 4: this.#window, 5: this.#window, 6: this.#window, 7: this.#window, 8: this.#window, 9: this.#window, 10: this.#window, 11: this.#window, 12: this.#window, 13: this.#window, 14: this.#window, 15: this.#window, 16: this.#window, 17: this.#window, 18: this.#window, 19: this.#window, 20: this.#window, 21: this.#window, 22: this.#window, 23: this.#window, 24: this.#window, 25: this.#window, 26: this.#window, 27: this.#window, 28: this.#window, 29: this.#window, 30: this.#window, 31: this.#window, 32: this.#window, 33: this.#window, 34: this.#window, 35: this.#window, 36: this.#window, 37: this.#window, 38: this.#window, 39: this.#window, 40: this.#window, 41: this.#window, 42: this.#window, 43: this.#window, 44: this.#window, 45: this.#window, 46: this.#window, 47: this.#window, 48: this.#window, 49: this.#window, 50: this.#window, 51: this.#window, 52: this.#window, 53: this.#window, 54: this.#window, 55: this.#window, 56: this.#window, 57: this.#window, 58: this.#window, 59: this.#window, 60: this.#window, 61: this.#window, 62: this.#window, 63: this.#window, 64: this.#window ,
      default: this.#window,
    });
    this.appendKnown = [{ from: 1, to: Infinity, operation: this.#known }];
    this.logits = Object.freeze({ 1: this.#head, 2: this.#head, 3: this.#head, 4: this.#head, 5: this.#head, 6: this.#head, 7: this.#head, 8: this.#head, 9: this.#head, 10: this.#head, 11: this.#head, 12: this.#head, 13: this.#head, 14: this.#head, 15: this.#head, 16: this.#head, 17: this.#head, 18: this.#head, 19: this.#head, 20: this.#head, 21: this.#head, 22: this.#head, 23: this.#head, 24: this.#head, 25: this.#head, 26: this.#head, 27: this.#head, 28: this.#head, 29: this.#head, 30: this.#head, 31: this.#head, 32: this.#head, 33: this.#head, 34: this.#head, 35: this.#head, 36: this.#head, 37: this.#head, 38: this.#head, 39: this.#head, 40: this.#head, 41: this.#head, 42: this.#head, 43: this.#head, 44: this.#head, 45: this.#head, 46: this.#head, 47: this.#head, 48: this.#head, 49: this.#head, 50: this.#head, 51: this.#head, 52: this.#head, 53: this.#head, 54: this.#head, 55: this.#head, 56: this.#head, 57: this.#head, 58: this.#head, 59: this.#head, 60: this.#head, 61: this.#head, 62: this.#head, 63: this.#head, 64: this.#head ,
      default: this.#head,
    });
    this.mixed = Object.freeze([{ from: 1, to: Infinity, operation: this.#mixed }]);
  }
  readonly #window = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#windowHidden(this.#embedTokens(ids), caches, "window", ids, capture);
  #windowHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaInputForwardScope(hidden, ids, capture, CACHES, this.#inputs);
    scope.own(0, this.#l0.forward(scope.hidden, caches[0]!, phase, null, scope.input(0)));
    scope.own(1, this.#l1.forward(scope.hidden, caches[1]!, phase, null, scope.input(1)));
    scope.own(2, this.#l2.forward(scope.hidden, caches[2]!, phase, null, scope.input(2)));
    scope.own(3, this.#l3.forward(scope.hidden, caches[3]!, phase, null, scope.input(3)));
    scope.own(4, this.#l4.forward(scope.hidden, caches[4]!, phase, null, scope.input(4)));
    scope.own(5, this.#l5.forward(scope.hidden, caches[5]!, phase, null, scope.input(5)));
    scope.own(6, this.#l6.forward(scope.hidden, caches[6]!, phase, null, scope.input(6)));
    scope.own(7, this.#l7.forward(scope.hidden, caches[7]!, phase, null, scope.input(7)));
    scope.own(8, this.#l8.forward(scope.hidden, caches[8]!, phase, null, scope.input(8)));
    scope.own(9, this.#l9.forward(scope.hidden, caches[9]!, phase, null, scope.input(9)));
    scope.own(10, this.#l10.forward(scope.hidden, caches[10]!, phase, null, scope.input(10)));
    scope.own(11, this.#l11.forward(scope.hidden, caches[11]!, phase, null, scope.input(11)));
    scope.own(12, this.#l12.forward(scope.hidden, caches[12]!, phase, null, scope.input(12)));
    scope.own(13, this.#l13.forward(scope.hidden, caches[13]!, phase, null, scope.input(13)));
    scope.own(14, this.#l14.forward(scope.hidden, caches[14]!, phase, null, scope.input(14)));
    scope.own(15, this.#l15.forward(scope.hidden, caches[15]!, phase, null, scope.input(15)));
    scope.own(16, this.#l16.forward(scope.hidden, caches[16]!, phase, null, scope.input(16)));
    scope.own(17, this.#l17.forward(scope.hidden, caches[17]!, phase, null, scope.input(17)));
    scope.own(18, this.#l18.forward(scope.hidden, caches[18]!, phase, null, scope.input(18)));
    scope.own(19, this.#l19.forward(scope.hidden, caches[19]!, phase, null, scope.input(19)));
    scope.own(20, this.#l20.forward(scope.hidden, caches[20]!, phase, null, scope.input(20)));
    scope.own(21, this.#l21.forward(scope.hidden, caches[21]!, phase, null, scope.input(21)));
    scope.donor(22, this.#l22.forward(scope.hidden, caches[22]!, phase, null, scope.input(22)));
    scope.donor(23, this.#l23.forward(scope.hidden, caches[23]!, phase, null, scope.input(23)));
    scope.shared(24, this.#l24.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(24)));
    scope.shared(25, this.#l25.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(25)));
    scope.shared(26, this.#l26.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(26)));
    scope.shared(27, this.#l27.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(27)));
    scope.shared(28, this.#l28.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(28)));
    scope.shared(29, this.#l29.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(29)));
    scope.shared(30, this.#l30.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(30)));
    scope.shared(31, this.#l31.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(31)));
    scope.shared(32, this.#l32.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(32)));
    scope.shared(33, this.#l33.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(33)));
    scope.shared(34, this.#l34.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(34)));
    scope.shared(35, this.#l35.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(35)));
    scope.shared(36, this.#l36.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(36)));
    scope.shared(37, this.#l37.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(37)));
    scope.shared(38, this.#l38.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(38)));
    scope.shared(39, this.#l39.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(39)));
    scope.shared(40, this.#l40.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(40)));
    scope.shared(41, this.#l41.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(41)));
    return scope.finish(42, this.finalNorm.forward(scope.hidden));
  }
  readonly #decode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#decodeHidden(this.#embedTokens(ids), caches, "decode", ids, capture);
  #decodeHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaInputForwardScope(hidden, ids, capture, CACHES, this.#inputs);
    scope.own(0, this.#l0.forward(scope.hidden, caches[0]!, phase, null, scope.input(0)));
    scope.own(1, this.#l1.forward(scope.hidden, caches[1]!, phase, null, scope.input(1)));
    scope.own(2, this.#l2.forward(scope.hidden, caches[2]!, phase, null, scope.input(2)));
    scope.own(3, this.#l3.forward(scope.hidden, caches[3]!, phase, null, scope.input(3)));
    scope.own(4, this.#l4.forward(scope.hidden, caches[4]!, phase, null, scope.input(4)));
    scope.own(5, this.#l5.forward(scope.hidden, caches[5]!, phase, null, scope.input(5)));
    scope.own(6, this.#l6.forward(scope.hidden, caches[6]!, phase, null, scope.input(6)));
    scope.own(7, this.#l7.forward(scope.hidden, caches[7]!, phase, null, scope.input(7)));
    scope.own(8, this.#l8.forward(scope.hidden, caches[8]!, phase, null, scope.input(8)));
    scope.own(9, this.#l9.forward(scope.hidden, caches[9]!, phase, null, scope.input(9)));
    scope.own(10, this.#l10.forward(scope.hidden, caches[10]!, phase, null, scope.input(10)));
    scope.own(11, this.#l11.forward(scope.hidden, caches[11]!, phase, null, scope.input(11)));
    scope.own(12, this.#l12.forward(scope.hidden, caches[12]!, phase, null, scope.input(12)));
    scope.own(13, this.#l13.forward(scope.hidden, caches[13]!, phase, null, scope.input(13)));
    scope.own(14, this.#l14.forward(scope.hidden, caches[14]!, phase, null, scope.input(14)));
    scope.own(15, this.#l15.forward(scope.hidden, caches[15]!, phase, null, scope.input(15)));
    scope.own(16, this.#l16.forward(scope.hidden, caches[16]!, phase, null, scope.input(16)));
    scope.own(17, this.#l17.forward(scope.hidden, caches[17]!, phase, null, scope.input(17)));
    scope.own(18, this.#l18.forward(scope.hidden, caches[18]!, phase, null, scope.input(18)));
    scope.own(19, this.#l19.forward(scope.hidden, caches[19]!, phase, null, scope.input(19)));
    scope.own(20, this.#l20.forward(scope.hidden, caches[20]!, phase, null, scope.input(20)));
    scope.own(21, this.#l21.forward(scope.hidden, caches[21]!, phase, null, scope.input(21)));
    scope.donor(22, this.#l22.forward(scope.hidden, caches[22]!, phase, null, scope.input(22)));
    scope.donor(23, this.#l23.forward(scope.hidden, caches[23]!, phase, null, scope.input(23)));
    scope.shared(24, this.#l24.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(24)));
    scope.shared(25, this.#l25.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(25)));
    scope.shared(26, this.#l26.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(26)));
    scope.shared(27, this.#l27.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(27)));
    scope.shared(28, this.#l28.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(28)));
    scope.shared(29, this.#l29.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(29)));
    scope.shared(30, this.#l30.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(30)));
    scope.shared(31, this.#l31.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(31)));
    scope.shared(32, this.#l32.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(32)));
    scope.shared(33, this.#l33.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(33)));
    scope.shared(34, this.#l34.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(34)));
    scope.shared(35, this.#l35.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(35)));
    scope.shared(36, this.#l36.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(36)));
    scope.shared(37, this.#l37.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(37)));
    scope.shared(38, this.#l38.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(38)));
    scope.shared(39, this.#l39.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(39)));
    scope.shared(40, this.#l40.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(40)));
    scope.shared(41, this.#l41.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(41)));
    return scope.finish(42, this.finalNorm.forward(scope.hidden));
  }
  readonly #traceDecode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#traceDecodeHidden(this.#embedTokens(ids), caches, "decode", ids, capture);
  #traceDecodeHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
    using scope = new GemmaInputForwardScope(hidden, ids, capture, CACHES, this.#traceInputs);
    scope.own(0, this.#t0.forward(scope.hidden, caches[0]!, phase, null, scope.input(0)));
    scope.own(1, this.#t1.forward(scope.hidden, caches[1]!, phase, null, scope.input(1)));
    scope.own(2, this.#t2.forward(scope.hidden, caches[2]!, phase, null, scope.input(2)));
    scope.own(3, this.#t3.forward(scope.hidden, caches[3]!, phase, null, scope.input(3)));
    scope.own(4, this.#t4.forward(scope.hidden, caches[4]!, phase, null, scope.input(4)));
    scope.own(5, this.#t5.forward(scope.hidden, caches[5]!, phase, null, scope.input(5)));
    scope.own(6, this.#t6.forward(scope.hidden, caches[6]!, phase, null, scope.input(6)));
    scope.own(7, this.#t7.forward(scope.hidden, caches[7]!, phase, null, scope.input(7)));
    scope.own(8, this.#t8.forward(scope.hidden, caches[8]!, phase, null, scope.input(8)));
    scope.own(9, this.#t9.forward(scope.hidden, caches[9]!, phase, null, scope.input(9)));
    scope.own(10, this.#t10.forward(scope.hidden, caches[10]!, phase, null, scope.input(10)));
    scope.own(11, this.#t11.forward(scope.hidden, caches[11]!, phase, null, scope.input(11)));
    scope.own(12, this.#t12.forward(scope.hidden, caches[12]!, phase, null, scope.input(12)));
    scope.own(13, this.#t13.forward(scope.hidden, caches[13]!, phase, null, scope.input(13)));
    scope.own(14, this.#t14.forward(scope.hidden, caches[14]!, phase, null, scope.input(14)));
    scope.own(15, this.#t15.forward(scope.hidden, caches[15]!, phase, null, scope.input(15)));
    scope.own(16, this.#t16.forward(scope.hidden, caches[16]!, phase, null, scope.input(16)));
    scope.own(17, this.#t17.forward(scope.hidden, caches[17]!, phase, null, scope.input(17)));
    scope.own(18, this.#t18.forward(scope.hidden, caches[18]!, phase, null, scope.input(18)));
    scope.own(19, this.#t19.forward(scope.hidden, caches[19]!, phase, null, scope.input(19)));
    scope.own(20, this.#t20.forward(scope.hidden, caches[20]!, phase, null, scope.input(20)));
    scope.own(21, this.#t21.forward(scope.hidden, caches[21]!, phase, null, scope.input(21)));
    scope.donor(22, this.#t22.forward(scope.hidden, caches[22]!, phase, null, scope.input(22)));
    scope.donor(23, this.#t23.forward(scope.hidden, caches[23]!, phase, null, scope.input(23)));
    scope.shared(24, this.#t24.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(24)));
    scope.shared(25, this.#t25.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(25)));
    scope.shared(26, this.#t26.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(26)));
    scope.shared(27, this.#t27.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(27)));
    scope.shared(28, this.#t28.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(28)));
    scope.shared(29, this.#t29.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(29)));
    scope.shared(30, this.#t30.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(30)));
    scope.shared(31, this.#t31.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(31)));
    scope.shared(32, this.#t32.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(32)));
    scope.shared(33, this.#t33.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(33)));
    scope.shared(34, this.#t34.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(34)));
    scope.shared(35, this.#t35.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(35)));
    scope.shared(36, this.#t36.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(36)));
    scope.shared(37, this.#t37.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(37)));
    scope.shared(38, this.#t38.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(38)));
    scope.shared(39, this.#t39.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(39)));
    scope.shared(40, this.#t40.forward(scope.hidden, null, phase, scope.reads[22]!, scope.input(40)));
    scope.shared(41, this.#t41.forward(scope.hidden, null, phase, scope.reads[23]!, scope.input(41)));
    return scope.finish(42, this.finalNorm.forward(scope.hidden));
  }
  readonly #known = (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null);
  readonly #head = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, compiledLogitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly traceLogits = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, logitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly traceDecode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null) => this.#traceDecode(ids, caches, capture);
  compiledDecodeStep() { return CompiledDecode.for(this); }
  releaseCompiledDecode(): void { CompiledDecode.release(this); }
  readonly #mixed = (work: Parameters<MlxMixedRange["operation"]>[0]): MlxArray[] => {
    using scope = new GemmaMixedScope(work, ids => this.#embedTokens(ids), CACHES, this.#inputs);
    scope.layer(0, (x, group) => ownMixed(this.#l0.forwardAttn(x, group.cache[0]!, group.phase, null)), (x, input) => this.#l0.feedforward(x, input!));
    scope.layer(1, (x, group) => ownMixed(this.#l1.forwardAttn(x, group.cache[1]!, group.phase, null)), (x, input) => this.#l1.feedforward(x, input!));
    scope.layer(2, (x, group) => ownMixed(this.#l2.forwardAttn(x, group.cache[2]!, group.phase, null)), (x, input) => this.#l2.feedforward(x, input!));
    scope.layer(3, (x, group) => ownMixed(this.#l3.forwardAttn(x, group.cache[3]!, group.phase, null)), (x, input) => this.#l3.feedforward(x, input!));
    scope.layer(4, (x, group) => ownMixed(this.#l4.forwardAttn(x, group.cache[4]!, group.phase, null)), (x, input) => this.#l4.feedforward(x, input!));
    scope.layer(5, (x, group) => ownMixed(this.#l5.forwardAttn(x, group.cache[5]!, group.phase, null)), (x, input) => this.#l5.feedforward(x, input!));
    scope.layer(6, (x, group) => ownMixed(this.#l6.forwardAttn(x, group.cache[6]!, group.phase, null)), (x, input) => this.#l6.feedforward(x, input!));
    scope.layer(7, (x, group) => ownMixed(this.#l7.forwardAttn(x, group.cache[7]!, group.phase, null)), (x, input) => this.#l7.feedforward(x, input!));
    scope.layer(8, (x, group) => ownMixed(this.#l8.forwardAttn(x, group.cache[8]!, group.phase, null)), (x, input) => this.#l8.feedforward(x, input!));
    scope.layer(9, (x, group) => ownMixed(this.#l9.forwardAttn(x, group.cache[9]!, group.phase, null)), (x, input) => this.#l9.feedforward(x, input!));
    scope.layer(10, (x, group) => ownMixed(this.#l10.forwardAttn(x, group.cache[10]!, group.phase, null)), (x, input) => this.#l10.feedforward(x, input!));
    scope.layer(11, (x, group) => ownMixed(this.#l11.forwardAttn(x, group.cache[11]!, group.phase, null)), (x, input) => this.#l11.feedforward(x, input!));
    scope.layer(12, (x, group) => ownMixed(this.#l12.forwardAttn(x, group.cache[12]!, group.phase, null)), (x, input) => this.#l12.feedforward(x, input!));
    scope.layer(13, (x, group) => ownMixed(this.#l13.forwardAttn(x, group.cache[13]!, group.phase, null)), (x, input) => this.#l13.feedforward(x, input!));
    scope.layer(14, (x, group) => ownMixed(this.#l14.forwardAttn(x, group.cache[14]!, group.phase, null)), (x, input) => this.#l14.feedforward(x, input!));
    scope.layer(15, (x, group) => ownMixed(this.#l15.forwardAttn(x, group.cache[15]!, group.phase, null)), (x, input) => this.#l15.feedforward(x, input!));
    scope.layer(16, (x, group) => ownMixed(this.#l16.forwardAttn(x, group.cache[16]!, group.phase, null)), (x, input) => this.#l16.feedforward(x, input!));
    scope.layer(17, (x, group) => ownMixed(this.#l17.forwardAttn(x, group.cache[17]!, group.phase, null)), (x, input) => this.#l17.feedforward(x, input!));
    scope.layer(18, (x, group) => ownMixed(this.#l18.forwardAttn(x, group.cache[18]!, group.phase, null)), (x, input) => this.#l18.feedforward(x, input!));
    scope.layer(19, (x, group) => ownMixed(this.#l19.forwardAttn(x, group.cache[19]!, group.phase, null)), (x, input) => this.#l19.feedforward(x, input!));
    scope.layer(20, (x, group) => ownMixed(this.#l20.forwardAttn(x, group.cache[20]!, group.phase, null)), (x, input) => this.#l20.feedforward(x, input!));
    scope.layer(21, (x, group) => ownMixed(this.#l21.forwardAttn(x, group.cache[21]!, group.phase, null)), (x, input) => this.#l21.feedforward(x, input!));
    scope.layer(22, (x, group) => donorMixed(group, 22, this.#l22.forwardAttn(x, group.cache[22]!, group.phase, null)), (x, input) => this.#l22.feedforward(x, input!));
    scope.layer(23, (x, group) => donorMixed(group, 23, this.#l23.forwardAttn(x, group.cache[23]!, group.phase, null)), (x, input) => this.#l23.feedforward(x, input!));
    scope.layer(24, (x, group) => sharedMixed(this.#l24.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l24.feedforward(x, input!));
    scope.layer(25, (x, group) => sharedMixed(this.#l25.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l25.feedforward(x, input!));
    scope.layer(26, (x, group) => sharedMixed(this.#l26.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l26.feedforward(x, input!));
    scope.layer(27, (x, group) => sharedMixed(this.#l27.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l27.feedforward(x, input!));
    scope.layer(28, (x, group) => sharedMixed(this.#l28.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l28.feedforward(x, input!));
    scope.layer(29, (x, group) => sharedMixed(this.#l29.forwardAttn(x, null, group.phase, group.reads[23]!)), (x, input) => this.#l29.feedforward(x, input!));
    scope.layer(30, (x, group) => sharedMixed(this.#l30.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l30.feedforward(x, input!));
    scope.layer(31, (x, group) => sharedMixed(this.#l31.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l31.feedforward(x, input!));
    scope.layer(32, (x, group) => sharedMixed(this.#l32.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l32.feedforward(x, input!));
    scope.layer(33, (x, group) => sharedMixed(this.#l33.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l33.feedforward(x, input!));
    scope.layer(34, (x, group) => sharedMixed(this.#l34.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l34.feedforward(x, input!));
    scope.layer(35, (x, group) => sharedMixed(this.#l35.forwardAttn(x, null, group.phase, group.reads[23]!)), (x, input) => this.#l35.feedforward(x, input!));
    scope.layer(36, (x, group) => sharedMixed(this.#l36.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l36.feedforward(x, input!));
    scope.layer(37, (x, group) => sharedMixed(this.#l37.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l37.feedforward(x, input!));
    scope.layer(38, (x, group) => sharedMixed(this.#l38.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l38.feedforward(x, input!));
    scope.layer(39, (x, group) => sharedMixed(this.#l39.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l39.feedforward(x, input!));
    scope.layer(40, (x, group) => sharedMixed(this.#l40.forwardAttn(x, null, group.phase, group.reads[22]!)), (x, input) => this.#l40.feedforward(x, input!));
    scope.layer(41, (x, group) => sharedMixed(this.#l41.forwardAttn(x, null, group.phase, group.reads[23]!)), (x, input) => this.#l41.feedforward(x, input!));
    return scope.finish(42, this.finalNorm);
  };
  #embedTokens(ids: MlxArray): MlxArray { const hidden = this.embed.encode(ids); return disposing(hidden, ops.mulScalar(hidden, this.embedScale)); }
  loraTargets() { return inputLoraTargets(this.#parts); }
  materializeGraphConstants(): void { ops.evalAll(this.#constants.borrow()); }
  dispose(): void { this.#constants.close(); }
  bindMediaInput(input: Vision) { return bindGemma4MediaInput(this, input); }
  mediaEncoders(modelDir: string, probes: MediaSidecarProbes) { return gemma4MediaEncoders(this, modelDir, probes); }
  draftTarget(caches: Cache[]) { return gemma4DraftTarget(this, caches); }
  logitsFromHidden(hidden: MlxArray): MlxArray { return this.#head(hidden); }
  readonly mixedSeparate = Object.freeze({
    decode: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#decode(group.ids, group.state, group.capture) }]),
    window: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }]),
    verify: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }]),
  });
  readonly sequence = Object.freeze([{ from: 1, to: Infinity, operation: (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null) }]);
  sequenceHidden(ids: MlxArray, caches: Cache[], _rows: number): MlxArray { return this.#window(ids, caches, null); }

  readonly mediaPrefill = Object.freeze([{ from: 1, to: Infinity, operation: (embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null) => writtenInputMedia(this.embedScale, (hidden, cache, phase, tokens) => this.#windowHidden(hidden, cache, phase, tokens, null), embeds, caches, bidir, ids, multimodal) }]);
  prefillEmbeddings(embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null = null): MlxArray { return this.mediaPrefill[0]!.operation(embeds, caches, bidir, ids, multimodal); }
}
import { writtenMedia, writtenInputMedia } from "./written-input";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Gemma4E4b
