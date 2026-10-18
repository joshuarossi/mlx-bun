import host.ts.Source
namespace Host.Ts.Sources.Inference.Models.Gemma4.Gemma412b
set_option maxRecDepth 100000

/-- Verbatim `packages/inference/src/models/gemma4/gemma4-12b.ts`; `host/ts/SourceBinding.ts` checks the bytes. -/
def source : String := r#"// Written Gemma 4 12b graph. Layer order and every operation binding are literal.
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
export const FINGERPRINT = GEMMA_GRAPH_FINGERPRINTS["12b"];

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

/** The artifact's layers and kv_config, from mlx-community/gemma-4-12B-it-OptiQ-4bit@5b1101065d2094c8f12aa87fee80e0afa5b292b7. */
export const LAYERS: readonly Gemma4Layer[] = Object.freeze([
  /*  0 */ { attention: "sliding", cache: 0, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  1 */ { attention: "sliding", cache: 1, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  2 */ { attention: "sliding", cache: 2, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  3 */ { attention: "sliding", cache: 3, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  4 */ { attention: "sliding", cache: 4, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  5 */ { attention: "full", cache: 5, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
  /*  6 */ { attention: "sliding", cache: 6, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  7 */ { attention: "sliding", cache: 7, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  8 */ { attention: "sliding", cache: 8, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /*  9 */ { attention: "sliding", cache: 9, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 10 */ { attention: "sliding", cache: 10, kv: { bits: 8, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 11 */ { attention: "full", cache: 11, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
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
  /* 30 */ { attention: "sliding", cache: 30, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 31 */ { attention: "sliding", cache: 31, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 32 */ { attention: "sliding", cache: 32, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 33 */ { attention: "sliding", cache: 33, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 34 */ { attention: "sliding", cache: 34, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 35 */ { attention: "full", cache: 35, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
  /* 36 */ { attention: "sliding", cache: 36, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 37 */ { attention: "sliding", cache: 37, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 38 */ { attention: "sliding", cache: 38, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 39 */ { attention: "sliding", cache: 39, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 40 */ { attention: "sliding", cache: 40, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 41 */ { attention: "full", cache: 41, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
  /* 42 */ { attention: "sliding", cache: 42, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 43 */ { attention: "sliding", cache: 43, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 44 */ { attention: "sliding", cache: 44, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 45 */ { attention: "sliding", cache: 45, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 46 */ { attention: "sliding", cache: 46, kv: { bits: 4, groupSize: 64 }, kEqV: false, layerScalar: true },
  /* 47 */ { attention: "full", cache: 47, kv: { bits: 4, groupSize: 64 }, kEqV: true, layerScalar: true },
]);

/** Layers [0, CACHES) own a cache. */
const CACHES = 48;
const PREFIX = "language_model.model";
const FINAL_LOGIT_SOFTCAP = 30;

export const DECODE_ROWS = 8;
export const VERIFY_ROWS = 64;

export class Gemma4TwelveB implements MlxDeclaredGraph, MlxTokenPhases {
  readonly prefixBase = PREFIX;
  readonly loraState = new LoraState();
  readonly weightsBytes: number;
  readonly embed: QuantizedEmbedding;
  readonly finalNorm: RMSNorm;
  readonly embedScale: number;
  readonly windowSize: number;
  readonly numDonors = CACHES;
  readonly perLayerWidth = 0;
  readonly graphCapabilities = declareGraph({ media: { input: "embeddings", video: false }, hiddenLayerTaps: true, compiledDecode: true });
  makeCache!: () => Cache[];
  readonly cacheLayers: readonly MlxCacheLayer[];
  readonly layers: readonly GemmaDenseLayer[];
  readonly traceLayers: readonly GemmaDenseLayer[];
  readonly #constants: ReturnType<typeof ownResource<MlxArray[]>>;
  readonly #parts: readonly GemmaLayerWeights[];
  readonly prompt: readonly MlxPromptRange[];
  readonly promptChunk: typeof this.prompt;
  readonly multiSequencePromptChunk: typeof this.multiSequencePrompt;
  readonly multiSequencePrompt: readonly MlxPromptRange[];
  readonly decode: MlxRowTable<MlxCapturingForward>;
  readonly verify: MlxRowTable<MlxCapturingForward>;
  readonly appendKnown: MlxKnownOperations;
  readonly logits: MlxRowTable<MlxHeadForward>;
  readonly mixed: readonly MlxMixedRange[];
  readonly #l0: GemmaDenseLayer;
  readonly #t0: GemmaDenseLayer;
  readonly #l1: GemmaDenseLayer;
  readonly #t1: GemmaDenseLayer;
  readonly #l2: GemmaDenseLayer;
  readonly #t2: GemmaDenseLayer;
  readonly #l3: GemmaDenseLayer;
  readonly #t3: GemmaDenseLayer;
  readonly #l4: GemmaDenseLayer;
  readonly #t4: GemmaDenseLayer;
  readonly #l5: GemmaDenseLayer;
  readonly #t5: GemmaDenseLayer;
  readonly #l6: GemmaDenseLayer;
  readonly #t6: GemmaDenseLayer;
  readonly #l7: GemmaDenseLayer;
  readonly #t7: GemmaDenseLayer;
  readonly #l8: GemmaDenseLayer;
  readonly #t8: GemmaDenseLayer;
  readonly #l9: GemmaDenseLayer;
  readonly #t9: GemmaDenseLayer;
  readonly #l10: GemmaDenseLayer;
  readonly #t10: GemmaDenseLayer;
  readonly #l11: GemmaDenseLayer;
  readonly #t11: GemmaDenseLayer;
  readonly #l12: GemmaDenseLayer;
  readonly #t12: GemmaDenseLayer;
  readonly #l13: GemmaDenseLayer;
  readonly #t13: GemmaDenseLayer;
  readonly #l14: GemmaDenseLayer;
  readonly #t14: GemmaDenseLayer;
  readonly #l15: GemmaDenseLayer;
  readonly #t15: GemmaDenseLayer;
  readonly #l16: GemmaDenseLayer;
  readonly #t16: GemmaDenseLayer;
  readonly #l17: GemmaDenseLayer;
  readonly #t17: GemmaDenseLayer;
  readonly #l18: GemmaDenseLayer;
  readonly #t18: GemmaDenseLayer;
  readonly #l19: GemmaDenseLayer;
  readonly #t19: GemmaDenseLayer;
  readonly #l20: GemmaDenseLayer;
  readonly #t20: GemmaDenseLayer;
  readonly #l21: GemmaDenseLayer;
  readonly #t21: GemmaDenseLayer;
  readonly #l22: GemmaDenseLayer;
  readonly #t22: GemmaDenseLayer;
  readonly #l23: GemmaDenseLayer;
  readonly #t23: GemmaDenseLayer;
  readonly #l24: GemmaDenseLayer;
  readonly #t24: GemmaDenseLayer;
  readonly #l25: GemmaDenseLayer;
  readonly #t25: GemmaDenseLayer;
  readonly #l26: GemmaDenseLayer;
  readonly #t26: GemmaDenseLayer;
  readonly #l27: GemmaDenseLayer;
  readonly #t27: GemmaDenseLayer;
  readonly #l28: GemmaDenseLayer;
  readonly #t28: GemmaDenseLayer;
  readonly #l29: GemmaDenseLayer;
  readonly #t29: GemmaDenseLayer;
  readonly #l30: GemmaDenseLayer;
  readonly #t30: GemmaDenseLayer;
  readonly #l31: GemmaDenseLayer;
  readonly #t31: GemmaDenseLayer;
  readonly #l32: GemmaDenseLayer;
  readonly #t32: GemmaDenseLayer;
  readonly #l33: GemmaDenseLayer;
  readonly #t33: GemmaDenseLayer;
  readonly #l34: GemmaDenseLayer;
  readonly #t34: GemmaDenseLayer;
  readonly #l35: GemmaDenseLayer;
  readonly #t35: GemmaDenseLayer;
  readonly #l36: GemmaDenseLayer;
  readonly #t36: GemmaDenseLayer;
  readonly #l37: GemmaDenseLayer;
  readonly #t37: GemmaDenseLayer;
  readonly #l38: GemmaDenseLayer;
  readonly #t38: GemmaDenseLayer;
  readonly #l39: GemmaDenseLayer;
  readonly #t39: GemmaDenseLayer;
  readonly #l40: GemmaDenseLayer;
  readonly #t40: GemmaDenseLayer;
  readonly #l41: GemmaDenseLayer;
  readonly #t41: GemmaDenseLayer;
  readonly #l42: GemmaDenseLayer;
  readonly #t42: GemmaDenseLayer;
  readonly #l43: GemmaDenseLayer;
  readonly #t43: GemmaDenseLayer;
  readonly #l44: GemmaDenseLayer;
  readonly #t44: GemmaDenseLayer;
  readonly #l45: GemmaDenseLayer;
  readonly #t45: GemmaDenseLayer;
  readonly #l46: GemmaDenseLayer;
  readonly #t46: GemmaDenseLayer;
  readonly #l47: GemmaDenseLayer;
  readonly #t47: GemmaDenseLayer;
  constructor(weights: Weights, readonly config: ModelConfig) {
    using resources = new GemmaBuildScope();
    this.weightsBytes = weightBytes(weights);
    this.embed = QuantizedEmbedding.load(weights, `${PREFIX}.embed_tokens`, config);
    this.finalNorm = new RMSNorm(weights.tensor(`${PREFIX}.norm.weight`), config.text.rmsNormEps);
    this.embedScale = Math.sqrt(config.text.hiddenSize);
    this.windowSize = config.text.slidingWindow;
    const p0 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.0`, new SlidingAttention(weights, config, `${PREFIX}.layers.0.self_attn`)));
    this.#l0 = new GemmaDenseLayer(p0, new CompiledGegluMLP(p0.mlp));
    this.#t0 = new GemmaDenseLayer(p0, new PlainGegluMLP(p0.mlp));
    const p1 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.1`, new SlidingAttention(weights, config, `${PREFIX}.layers.1.self_attn`)));
    this.#l1 = new GemmaDenseLayer(p1, new CompiledGegluMLP(p1.mlp));
    this.#t1 = new GemmaDenseLayer(p1, new PlainGegluMLP(p1.mlp));
    const p2 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.2`, new SlidingAttention(weights, config, `${PREFIX}.layers.2.self_attn`)));
    this.#l2 = new GemmaDenseLayer(p2, new CompiledGegluMLP(p2.mlp));
    this.#t2 = new GemmaDenseLayer(p2, new PlainGegluMLP(p2.mlp));
    const p3 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.3`, new SlidingAttention(weights, config, `${PREFIX}.layers.3.self_attn`)));
    this.#l3 = new GemmaDenseLayer(p3, new CompiledGegluMLP(p3.mlp));
    this.#t3 = new GemmaDenseLayer(p3, new PlainGegluMLP(p3.mlp));
    const p4 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.4`, new SlidingAttention(weights, config, `${PREFIX}.layers.4.self_attn`)));
    this.#l4 = new GemmaDenseLayer(p4, new CompiledGegluMLP(p4.mlp));
    this.#t4 = new GemmaDenseLayer(p4, new PlainGegluMLP(p4.mlp));
    const p5 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.5`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.5.self_attn`)));
    this.#l5 = new GemmaDenseLayer(p5, new CompiledGegluMLP(p5.mlp));
    this.#t5 = new GemmaDenseLayer(p5, new PlainGegluMLP(p5.mlp));
    const p6 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.6`, new SlidingAttention(weights, config, `${PREFIX}.layers.6.self_attn`)));
    this.#l6 = new GemmaDenseLayer(p6, new CompiledGegluMLP(p6.mlp));
    this.#t6 = new GemmaDenseLayer(p6, new PlainGegluMLP(p6.mlp));
    const p7 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.7`, new SlidingAttention(weights, config, `${PREFIX}.layers.7.self_attn`)));
    this.#l7 = new GemmaDenseLayer(p7, new CompiledGegluMLP(p7.mlp));
    this.#t7 = new GemmaDenseLayer(p7, new PlainGegluMLP(p7.mlp));
    const p8 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.8`, new SlidingAttention(weights, config, `${PREFIX}.layers.8.self_attn`)));
    this.#l8 = new GemmaDenseLayer(p8, new CompiledGegluMLP(p8.mlp));
    this.#t8 = new GemmaDenseLayer(p8, new PlainGegluMLP(p8.mlp));
    const p9 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.9`, new SlidingAttention(weights, config, `${PREFIX}.layers.9.self_attn`)));
    this.#l9 = new GemmaDenseLayer(p9, new CompiledGegluMLP(p9.mlp));
    this.#t9 = new GemmaDenseLayer(p9, new PlainGegluMLP(p9.mlp));
    const p10 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.10`, new SlidingAttention(weights, config, `${PREFIX}.layers.10.self_attn`)));
    this.#l10 = new GemmaDenseLayer(p10, new CompiledGegluMLP(p10.mlp));
    this.#t10 = new GemmaDenseLayer(p10, new PlainGegluMLP(p10.mlp));
    const p11 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.11`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.11.self_attn`)));
    this.#l11 = new GemmaDenseLayer(p11, new CompiledGegluMLP(p11.mlp));
    this.#t11 = new GemmaDenseLayer(p11, new PlainGegluMLP(p11.mlp));
    const p12 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.12`, new SlidingAttention(weights, config, `${PREFIX}.layers.12.self_attn`)));
    this.#l12 = new GemmaDenseLayer(p12, new CompiledGegluMLP(p12.mlp));
    this.#t12 = new GemmaDenseLayer(p12, new PlainGegluMLP(p12.mlp));
    const p13 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.13`, new SlidingAttention(weights, config, `${PREFIX}.layers.13.self_attn`)));
    this.#l13 = new GemmaDenseLayer(p13, new CompiledGegluMLP(p13.mlp));
    this.#t13 = new GemmaDenseLayer(p13, new PlainGegluMLP(p13.mlp));
    const p14 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.14`, new SlidingAttention(weights, config, `${PREFIX}.layers.14.self_attn`)));
    this.#l14 = new GemmaDenseLayer(p14, new CompiledGegluMLP(p14.mlp));
    this.#t14 = new GemmaDenseLayer(p14, new PlainGegluMLP(p14.mlp));
    const p15 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.15`, new SlidingAttention(weights, config, `${PREFIX}.layers.15.self_attn`)));
    this.#l15 = new GemmaDenseLayer(p15, new CompiledGegluMLP(p15.mlp));
    this.#t15 = new GemmaDenseLayer(p15, new PlainGegluMLP(p15.mlp));
    const p16 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.16`, new SlidingAttention(weights, config, `${PREFIX}.layers.16.self_attn`)));
    this.#l16 = new GemmaDenseLayer(p16, new CompiledGegluMLP(p16.mlp));
    this.#t16 = new GemmaDenseLayer(p16, new PlainGegluMLP(p16.mlp));
    const p17 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.17`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.17.self_attn`)));
    this.#l17 = new GemmaDenseLayer(p17, new CompiledGegluMLP(p17.mlp));
    this.#t17 = new GemmaDenseLayer(p17, new PlainGegluMLP(p17.mlp));
    const p18 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.18`, new SlidingAttention(weights, config, `${PREFIX}.layers.18.self_attn`)));
    this.#l18 = new GemmaDenseLayer(p18, new CompiledGegluMLP(p18.mlp));
    this.#t18 = new GemmaDenseLayer(p18, new PlainGegluMLP(p18.mlp));
    const p19 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.19`, new SlidingAttention(weights, config, `${PREFIX}.layers.19.self_attn`)));
    this.#l19 = new GemmaDenseLayer(p19, new CompiledGegluMLP(p19.mlp));
    this.#t19 = new GemmaDenseLayer(p19, new PlainGegluMLP(p19.mlp));
    const p20 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.20`, new SlidingAttention(weights, config, `${PREFIX}.layers.20.self_attn`)));
    this.#l20 = new GemmaDenseLayer(p20, new CompiledGegluMLP(p20.mlp));
    this.#t20 = new GemmaDenseLayer(p20, new PlainGegluMLP(p20.mlp));
    const p21 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.21`, new SlidingAttention(weights, config, `${PREFIX}.layers.21.self_attn`)));
    this.#l21 = new GemmaDenseLayer(p21, new CompiledGegluMLP(p21.mlp));
    this.#t21 = new GemmaDenseLayer(p21, new PlainGegluMLP(p21.mlp));
    const p22 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.22`, new SlidingAttention(weights, config, `${PREFIX}.layers.22.self_attn`)));
    this.#l22 = new GemmaDenseLayer(p22, new CompiledGegluMLP(p22.mlp));
    this.#t22 = new GemmaDenseLayer(p22, new PlainGegluMLP(p22.mlp));
    const p23 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.23`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.23.self_attn`)));
    this.#l23 = new GemmaDenseLayer(p23, new CompiledGegluMLP(p23.mlp));
    this.#t23 = new GemmaDenseLayer(p23, new PlainGegluMLP(p23.mlp));
    const p24 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.24`, new SlidingAttention(weights, config, `${PREFIX}.layers.24.self_attn`)));
    this.#l24 = new GemmaDenseLayer(p24, new CompiledGegluMLP(p24.mlp));
    this.#t24 = new GemmaDenseLayer(p24, new PlainGegluMLP(p24.mlp));
    const p25 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.25`, new SlidingAttention(weights, config, `${PREFIX}.layers.25.self_attn`)));
    this.#l25 = new GemmaDenseLayer(p25, new CompiledGegluMLP(p25.mlp));
    this.#t25 = new GemmaDenseLayer(p25, new PlainGegluMLP(p25.mlp));
    const p26 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.26`, new SlidingAttention(weights, config, `${PREFIX}.layers.26.self_attn`)));
    this.#l26 = new GemmaDenseLayer(p26, new CompiledGegluMLP(p26.mlp));
    this.#t26 = new GemmaDenseLayer(p26, new PlainGegluMLP(p26.mlp));
    const p27 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.27`, new SlidingAttention(weights, config, `${PREFIX}.layers.27.self_attn`)));
    this.#l27 = new GemmaDenseLayer(p27, new CompiledGegluMLP(p27.mlp));
    this.#t27 = new GemmaDenseLayer(p27, new PlainGegluMLP(p27.mlp));
    const p28 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.28`, new SlidingAttention(weights, config, `${PREFIX}.layers.28.self_attn`)));
    this.#l28 = new GemmaDenseLayer(p28, new CompiledGegluMLP(p28.mlp));
    this.#t28 = new GemmaDenseLayer(p28, new PlainGegluMLP(p28.mlp));
    const p29 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.29`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.29.self_attn`)));
    this.#l29 = new GemmaDenseLayer(p29, new CompiledGegluMLP(p29.mlp));
    this.#t29 = new GemmaDenseLayer(p29, new PlainGegluMLP(p29.mlp));
    const p30 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.30`, new SlidingAttention(weights, config, `${PREFIX}.layers.30.self_attn`)));
    this.#l30 = new GemmaDenseLayer(p30, new CompiledGegluMLP(p30.mlp));
    this.#t30 = new GemmaDenseLayer(p30, new PlainGegluMLP(p30.mlp));
    const p31 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.31`, new SlidingAttention(weights, config, `${PREFIX}.layers.31.self_attn`)));
    this.#l31 = new GemmaDenseLayer(p31, new CompiledGegluMLP(p31.mlp));
    this.#t31 = new GemmaDenseLayer(p31, new PlainGegluMLP(p31.mlp));
    const p32 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.32`, new SlidingAttention(weights, config, `${PREFIX}.layers.32.self_attn`)));
    this.#l32 = new GemmaDenseLayer(p32, new CompiledGegluMLP(p32.mlp));
    this.#t32 = new GemmaDenseLayer(p32, new PlainGegluMLP(p32.mlp));
    const p33 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.33`, new SlidingAttention(weights, config, `${PREFIX}.layers.33.self_attn`)));
    this.#l33 = new GemmaDenseLayer(p33, new CompiledGegluMLP(p33.mlp));
    this.#t33 = new GemmaDenseLayer(p33, new PlainGegluMLP(p33.mlp));
    const p34 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.34`, new SlidingAttention(weights, config, `${PREFIX}.layers.34.self_attn`)));
    this.#l34 = new GemmaDenseLayer(p34, new CompiledGegluMLP(p34.mlp));
    this.#t34 = new GemmaDenseLayer(p34, new PlainGegluMLP(p34.mlp));
    const p35 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.35`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.35.self_attn`)));
    this.#l35 = new GemmaDenseLayer(p35, new CompiledGegluMLP(p35.mlp));
    this.#t35 = new GemmaDenseLayer(p35, new PlainGegluMLP(p35.mlp));
    const p36 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.36`, new SlidingAttention(weights, config, `${PREFIX}.layers.36.self_attn`)));
    this.#l36 = new GemmaDenseLayer(p36, new CompiledGegluMLP(p36.mlp));
    this.#t36 = new GemmaDenseLayer(p36, new PlainGegluMLP(p36.mlp));
    const p37 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.37`, new SlidingAttention(weights, config, `${PREFIX}.layers.37.self_attn`)));
    this.#l37 = new GemmaDenseLayer(p37, new CompiledGegluMLP(p37.mlp));
    this.#t37 = new GemmaDenseLayer(p37, new PlainGegluMLP(p37.mlp));
    const p38 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.38`, new SlidingAttention(weights, config, `${PREFIX}.layers.38.self_attn`)));
    this.#l38 = new GemmaDenseLayer(p38, new CompiledGegluMLP(p38.mlp));
    this.#t38 = new GemmaDenseLayer(p38, new PlainGegluMLP(p38.mlp));
    const p39 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.39`, new SlidingAttention(weights, config, `${PREFIX}.layers.39.self_attn`)));
    this.#l39 = new GemmaDenseLayer(p39, new CompiledGegluMLP(p39.mlp));
    this.#t39 = new GemmaDenseLayer(p39, new PlainGegluMLP(p39.mlp));
    const p40 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.40`, new SlidingAttention(weights, config, `${PREFIX}.layers.40.self_attn`)));
    this.#l40 = new GemmaDenseLayer(p40, new CompiledGegluMLP(p40.mlp));
    this.#t40 = new GemmaDenseLayer(p40, new PlainGegluMLP(p40.mlp));
    const p41 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.41`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.41.self_attn`)));
    this.#l41 = new GemmaDenseLayer(p41, new CompiledGegluMLP(p41.mlp));
    this.#t41 = new GemmaDenseLayer(p41, new PlainGegluMLP(p41.mlp));
    const p42 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.42`, new SlidingAttention(weights, config, `${PREFIX}.layers.42.self_attn`)));
    this.#l42 = new GemmaDenseLayer(p42, new CompiledGegluMLP(p42.mlp));
    this.#t42 = new GemmaDenseLayer(p42, new PlainGegluMLP(p42.mlp));
    const p43 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.43`, new SlidingAttention(weights, config, `${PREFIX}.layers.43.self_attn`)));
    this.#l43 = new GemmaDenseLayer(p43, new CompiledGegluMLP(p43.mlp));
    this.#t43 = new GemmaDenseLayer(p43, new PlainGegluMLP(p43.mlp));
    const p44 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.44`, new SlidingAttention(weights, config, `${PREFIX}.layers.44.self_attn`)));
    this.#l44 = new GemmaDenseLayer(p44, new CompiledGegluMLP(p44.mlp));
    this.#t44 = new GemmaDenseLayer(p44, new PlainGegluMLP(p44.mlp));
    const p45 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.45`, new SlidingAttention(weights, config, `${PREFIX}.layers.45.self_attn`)));
    this.#l45 = new GemmaDenseLayer(p45, new CompiledGegluMLP(p45.mlp));
    this.#t45 = new GemmaDenseLayer(p45, new PlainGegluMLP(p45.mlp));
    const p46 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.46`, new SlidingAttention(weights, config, `${PREFIX}.layers.46.self_attn`)));
    this.#l46 = new GemmaDenseLayer(p46, new CompiledGegluMLP(p46.mlp));
    this.#t46 = new GemmaDenseLayer(p46, new PlainGegluMLP(p46.mlp));
    const p47 = resources.hold(new GemmaLayerWeights(weights, config, `${PREFIX}.layers.47`, new FullKEqVAttention(weights, config, `${PREFIX}.layers.47.self_attn`)));
    this.#l47 = new GemmaDenseLayer(p47, new CompiledGegluMLP(p47.mlp));
    this.#t47 = new GemmaDenseLayer(p47, new PlainGegluMLP(p47.mlp));
    this.layers = Object.freeze([this.#l0, this.#l1, this.#l2, this.#l3, this.#l4, this.#l5, this.#l6, this.#l7, this.#l8, this.#l9, this.#l10, this.#l11, this.#l12, this.#l13, this.#l14, this.#l15, this.#l16, this.#l17, this.#l18, this.#l19, this.#l20, this.#l21, this.#l22, this.#l23, this.#l24, this.#l25, this.#l26, this.#l27, this.#l28, this.#l29, this.#l30, this.#l31, this.#l32, this.#l33, this.#l34, this.#l35, this.#l36, this.#l37, this.#l38, this.#l39, this.#l40, this.#l41, this.#l42, this.#l43, this.#l44, this.#l45, this.#l46, this.#l47]);
    this.traceLayers = Object.freeze([this.#t0, this.#t1, this.#t2, this.#t3, this.#t4, this.#t5, this.#t6, this.#t7, this.#t8, this.#t9, this.#t10, this.#t11, this.#t12, this.#t13, this.#t14, this.#t15, this.#t16, this.#t17, this.#t18, this.#t19, this.#t20, this.#t21, this.#t22, this.#t23, this.#t24, this.#t25, this.#t26, this.#t27, this.#t28, this.#t29, this.#t30, this.#t31, this.#t32, this.#t33, this.#t34, this.#t35, this.#t36, this.#t37, this.#t38, this.#t39, this.#t40, this.#t41, this.#t42, this.#t43, this.#t44, this.#t45, this.#t46, this.#t47]);
    this.#parts = Object.freeze([p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47]);
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
    scope.own(30, this.#l30.forward(scope.hidden, caches[30]!, phase, null));
    scope.own(31, this.#l31.forward(scope.hidden, caches[31]!, phase, null));
    scope.own(32, this.#l32.forward(scope.hidden, caches[32]!, phase, null));
    scope.own(33, this.#l33.forward(scope.hidden, caches[33]!, phase, null));
    scope.own(34, this.#l34.forward(scope.hidden, caches[34]!, phase, null));
    scope.own(35, this.#l35.forward(scope.hidden, caches[35]!, phase, null));
    scope.own(36, this.#l36.forward(scope.hidden, caches[36]!, phase, null));
    scope.own(37, this.#l37.forward(scope.hidden, caches[37]!, phase, null));
    scope.own(38, this.#l38.forward(scope.hidden, caches[38]!, phase, null));
    scope.own(39, this.#l39.forward(scope.hidden, caches[39]!, phase, null));
    scope.own(40, this.#l40.forward(scope.hidden, caches[40]!, phase, null));
    scope.own(41, this.#l41.forward(scope.hidden, caches[41]!, phase, null));
    scope.own(42, this.#l42.forward(scope.hidden, caches[42]!, phase, null));
    scope.own(43, this.#l43.forward(scope.hidden, caches[43]!, phase, null));
    scope.own(44, this.#l44.forward(scope.hidden, caches[44]!, phase, null));
    scope.own(45, this.#l45.forward(scope.hidden, caches[45]!, phase, null));
    scope.own(46, this.#l46.forward(scope.hidden, caches[46]!, phase, null));
    scope.own(47, this.#l47.forward(scope.hidden, caches[47]!, phase, null));
    return scope.finish(48, this.finalNorm.forward(scope.hidden));
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
    scope.own(30, this.#l30.forward(scope.hidden, caches[30]!, phase, null));
    scope.own(31, this.#l31.forward(scope.hidden, caches[31]!, phase, null));
    scope.own(32, this.#l32.forward(scope.hidden, caches[32]!, phase, null));
    scope.own(33, this.#l33.forward(scope.hidden, caches[33]!, phase, null));
    scope.own(34, this.#l34.forward(scope.hidden, caches[34]!, phase, null));
    scope.own(35, this.#l35.forward(scope.hidden, caches[35]!, phase, null));
    scope.own(36, this.#l36.forward(scope.hidden, caches[36]!, phase, null));
    scope.own(37, this.#l37.forward(scope.hidden, caches[37]!, phase, null));
    scope.own(38, this.#l38.forward(scope.hidden, caches[38]!, phase, null));
    scope.own(39, this.#l39.forward(scope.hidden, caches[39]!, phase, null));
    scope.own(40, this.#l40.forward(scope.hidden, caches[40]!, phase, null));
    scope.own(41, this.#l41.forward(scope.hidden, caches[41]!, phase, null));
    scope.own(42, this.#l42.forward(scope.hidden, caches[42]!, phase, null));
    scope.own(43, this.#l43.forward(scope.hidden, caches[43]!, phase, null));
    scope.own(44, this.#l44.forward(scope.hidden, caches[44]!, phase, null));
    scope.own(45, this.#l45.forward(scope.hidden, caches[45]!, phase, null));
    scope.own(46, this.#l46.forward(scope.hidden, caches[46]!, phase, null));
    scope.own(47, this.#l47.forward(scope.hidden, caches[47]!, phase, null));
    return scope.finish(48, this.finalNorm.forward(scope.hidden));
  }
  readonly #traceDecode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null): MlxArray => this.#traceDecodeHidden(this.#embedTokens(ids), caches, "decode", ids, capture);
  #traceDecodeHidden(hidden: MlxArray, caches: Cache[], phase: Gemma4Phase, ids: MlxArray, capture: MlxLayerCapture | null): MlxArray {
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
    scope.own(30, this.#t30.forward(scope.hidden, caches[30]!, phase, null));
    scope.own(31, this.#t31.forward(scope.hidden, caches[31]!, phase, null));
    scope.own(32, this.#t32.forward(scope.hidden, caches[32]!, phase, null));
    scope.own(33, this.#t33.forward(scope.hidden, caches[33]!, phase, null));
    scope.own(34, this.#t34.forward(scope.hidden, caches[34]!, phase, null));
    scope.own(35, this.#t35.forward(scope.hidden, caches[35]!, phase, null));
    scope.own(36, this.#t36.forward(scope.hidden, caches[36]!, phase, null));
    scope.own(37, this.#t37.forward(scope.hidden, caches[37]!, phase, null));
    scope.own(38, this.#t38.forward(scope.hidden, caches[38]!, phase, null));
    scope.own(39, this.#t39.forward(scope.hidden, caches[39]!, phase, null));
    scope.own(40, this.#t40.forward(scope.hidden, caches[40]!, phase, null));
    scope.own(41, this.#t41.forward(scope.hidden, caches[41]!, phase, null));
    scope.own(42, this.#t42.forward(scope.hidden, caches[42]!, phase, null));
    scope.own(43, this.#t43.forward(scope.hidden, caches[43]!, phase, null));
    scope.own(44, this.#t44.forward(scope.hidden, caches[44]!, phase, null));
    scope.own(45, this.#t45.forward(scope.hidden, caches[45]!, phase, null));
    scope.own(46, this.#t46.forward(scope.hidden, caches[46]!, phase, null));
    scope.own(47, this.#t47.forward(scope.hidden, caches[47]!, phase, null));
    return scope.finish(48, this.finalNorm.forward(scope.hidden));
  }
  readonly #known = (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null);
  readonly #head = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, compiledLogitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly traceLogits = (hidden: MlxArray) => { const logits = this.embed.asLinear(hidden); return disposing(logits, logitSoftcap(logits, FINAL_LOGIT_SOFTCAP)); };
  readonly traceDecode = (ids: MlxArray, caches: Cache[], capture: MlxLayerCapture | null) => this.#traceDecode(ids, caches, capture);
  compiledDecodeStep() { return CompiledDecode.for(this); }
  releaseCompiledDecode(): void { CompiledDecode.release(this); }
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
    scope.layer(30, (x, group) => ownMixed(this.#l30.forwardAttn(x, group.cache[30]!, group.phase, null)), x => this.#l30.feedforward(x));
    scope.layer(31, (x, group) => ownMixed(this.#l31.forwardAttn(x, group.cache[31]!, group.phase, null)), x => this.#l31.feedforward(x));
    scope.layer(32, (x, group) => ownMixed(this.#l32.forwardAttn(x, group.cache[32]!, group.phase, null)), x => this.#l32.feedforward(x));
    scope.layer(33, (x, group) => ownMixed(this.#l33.forwardAttn(x, group.cache[33]!, group.phase, null)), x => this.#l33.feedforward(x));
    scope.layer(34, (x, group) => ownMixed(this.#l34.forwardAttn(x, group.cache[34]!, group.phase, null)), x => this.#l34.feedforward(x));
    scope.layer(35, (x, group) => ownMixed(this.#l35.forwardAttn(x, group.cache[35]!, group.phase, null)), x => this.#l35.feedforward(x));
    scope.layer(36, (x, group) => ownMixed(this.#l36.forwardAttn(x, group.cache[36]!, group.phase, null)), x => this.#l36.feedforward(x));
    scope.layer(37, (x, group) => ownMixed(this.#l37.forwardAttn(x, group.cache[37]!, group.phase, null)), x => this.#l37.feedforward(x));
    scope.layer(38, (x, group) => ownMixed(this.#l38.forwardAttn(x, group.cache[38]!, group.phase, null)), x => this.#l38.feedforward(x));
    scope.layer(39, (x, group) => ownMixed(this.#l39.forwardAttn(x, group.cache[39]!, group.phase, null)), x => this.#l39.feedforward(x));
    scope.layer(40, (x, group) => ownMixed(this.#l40.forwardAttn(x, group.cache[40]!, group.phase, null)), x => this.#l40.feedforward(x));
    scope.layer(41, (x, group) => ownMixed(this.#l41.forwardAttn(x, group.cache[41]!, group.phase, null)), x => this.#l41.feedforward(x));
    scope.layer(42, (x, group) => ownMixed(this.#l42.forwardAttn(x, group.cache[42]!, group.phase, null)), x => this.#l42.feedforward(x));
    scope.layer(43, (x, group) => ownMixed(this.#l43.forwardAttn(x, group.cache[43]!, group.phase, null)), x => this.#l43.feedforward(x));
    scope.layer(44, (x, group) => ownMixed(this.#l44.forwardAttn(x, group.cache[44]!, group.phase, null)), x => this.#l44.feedforward(x));
    scope.layer(45, (x, group) => ownMixed(this.#l45.forwardAttn(x, group.cache[45]!, group.phase, null)), x => this.#l45.feedforward(x));
    scope.layer(46, (x, group) => ownMixed(this.#l46.forwardAttn(x, group.cache[46]!, group.phase, null)), x => this.#l46.feedforward(x));
    scope.layer(47, (x, group) => ownMixed(this.#l47.forwardAttn(x, group.cache[47]!, group.phase, null)), x => this.#l47.feedforward(x));
    return scope.finish(48, this.finalNorm);
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
    decode: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#decode(group.ids, group.state, group.capture) }]),
    window: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }]),
    verify: Object.freeze([{ from: 1, to: Infinity, operation: (group: MlxPhaseGroup) => this.#window(group.ids, group.state, group.capture) }]),
  });
  readonly sequence = Object.freeze([{ from: 1, to: Infinity, operation: (ids: MlxArray, caches: Cache[]) => this.#window(ids, caches, null) }]);
  sequenceHidden(ids: MlxArray, caches: Cache[], _rows: number): MlxArray { return this.#window(ids, caches, null); }

  readonly mediaPrefill = Object.freeze([{ from: 1, to: Infinity, operation: (embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null) => writtenMedia(this.embedScale, (hidden, cache, phase, tokens) => this.#windowHidden(hidden, cache, phase, tokens, null), embeds, caches, bidir, ids) }]);
  prefillEmbeddings(embeds: MlxArray, caches: Cache[], bidir: MlxArray | null, ids: MlxArray, multimodal: MlxArray | null = null): MlxArray { return this.mediaPrefill[0]!.operation(embeds, caches, bidir, ids, multimodal); }
}
import { writtenMedia, writtenInputMedia } from "./written-input";
"#

source_parse source

/-- Lean's lexer and parser accept the whole file (kernel-checked chunks). -/
theorem parses : (parse chars).isSome = true := parse_isSome lex_eq parsesTokens

theorem sourceParses : (parse source.toList).isSome = true := chars.eq ▸ parses

end Host.Ts.Sources.Inference.Models.Gemma4.Gemma412b
