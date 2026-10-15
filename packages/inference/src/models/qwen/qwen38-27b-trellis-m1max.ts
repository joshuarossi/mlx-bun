import type { MlxArray } from "@mlx-bun/mlx/array";
import * as ops from "@mlx-bun/mlx/ops";
import type { ModelConfig } from "../../artifacts/config";
import type { Weights } from "../../artifacts/weights";
import type { Cache } from "../../contracts/mlx/cache";
import type { DraftProjectionKernels } from "../../contracts/mlx/draft-target";
import type { DraftProjection } from "../../contracts/mlx/draft-projection";
import type { AneProgramSpec } from "../../kernels/ane/linear";
import type { ResidualBasis, TargetView } from "../../contracts/mlx/draft-target";
import type { MlxDeclaredGraph, MlxTokenPhases, MlxLayerCapture, MlxHeadForward, MlxRowTable, MlxPromptRange, MlxCacheLayer, MlxSequenceRange, MlxMixedRange, MlxPhaseGroup, MlxMixedGroupRange, MlxSeparateMixed, MlxKnownRange } from "../../contracts/mlx/graph";
import type { MediaEncoders, MlxPromptInput, Vision, MlxPositionedForward, MlxPositionedRange, MlxPositionedEmbeddingsRange, MlxEmbeddingsRange } from "../../contracts/mlx/media";
import type { MropeForwardState } from "../../contracts/mlx/positions";
import type { GraphCapabilities } from "../../contracts/portable/graph";
import { LoraState } from "../../layers/lora";
import { RMSNorm } from "../../layers/normalization";
import { QuantizedEmbedding } from "../../layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain as Plain } from "../../layers/quantized-linear";
import { mropeInvFreq } from "../../layers/qwen-mrope";
import { ReduceSplitMixedGateUp as MixedGate } from "../../layers/trellis-reduce-gate-up";
import { CodebookSplitGateUpRow as GateRow } from "../../layers/trellis-codebook-gate-up";
import { CodebookDownK3iRow as DownK3iRow, CodebookDownRow as DownRow } from "../../layers/trellis-codebook-down";
import { CodebookMmaGateUp as GateRows, MmaGateUpWide as WideGate } from "../../layers/trellis-gate-up";
import { CodebookMmaDown as DownRows, CodebookMmaDownK3i as DownK3iRows, MmaDownWide as WideDown, MmaDownWideK3i as WideDownK3i } from "../../layers/trellis-down";
import { AffineRowLinear as AffineRow, Affine3RowsLinear as Affine3, Affine4RowsLinear as Affine4, AffineSplitMmaLinear as AffineMma } from "../../layers/affine-verify-linear";
import { DequantizedMatmulLinear as Dense } from "../../layers/dequantized-linear";
import { AneAffineSplit, AneTrellisExpandedMlpSplit as AneSplit, AneTrellisExpandedMlpSplitK3i as AneSplitK3i, aneAffineSplitProgram, aneMlpSplitProgram } from "../../layers/ane-prefill-split";
import { TrellisFusedMLP, TrellisUnfusedMLP, TrellisReducePrompt as Reduce, TrellisScatterPrompt as Scatter, TrellisSplitKPrompt as SplitK, TrellisTiledPrompt as Tiled, TrellisExpandReducePrompt as ExpandGate, TrellisExpandScatterPrompt as ExpandDown } from "../../layers/trellis-prompt";
import { GraphForwardScope, BoundedGraphForwardScope, SubmittedGraphForwardScope, QueuedGraphForwardScope } from "../../runtime/graph-forward";
import { disposeResources } from "../../runtime/resources";
import { declareGraph } from "../capabilities";
import { type ReadPhase } from "../graph";
import { QwenDeltaLayer as Delta, QwenAttentionLayer as Attention, QwenResidualDeltaLayer as ResidualDelta, QwenResidualAttentionLayer as ResidualAttention, QwenFusedGatedDeltaNet as GatedNorm } from "./blocks";
import { bindQwenMediaInput, qwenDraftTarget, qwenDraftVocabularyMemo, qwenMediaEncoders, qwenResidualBasis } from "./media-input";
import { DeltaWeights, AttentionWeights, GateDownMLP, AneWeightShares, AneBoundMlp, canonicalQwenWeights, type QwenProjectionTarget } from "./written-layers";
import { PackedMixedScope } from "../../input/packed-mixed";

export const QWEN38_TRELLIS_M1MAX_GRAPH="qwen3.8-27b-trellis-3.2bpw-m1max";
/** Tuned exact entries. Larger rows use the declared operations in this file. */
export const DECODE_ROWS=256;
export const VERIFY_ROWS=256;
export interface AneWidths {hidden:number;intermediate:number;projections:readonly [readonly [number,number],readonly [number,number],readonly [number,number],readonly [number,number]]}
export const ANE_WIDTHS:AneWidths={hidden:5120,intermediate:17408,projections:[[5120,10240],[5120,6144],[6144,5120],[5120,12288]]};
/** Programs are installed beforehand. Loading this graph loads these fixed programs. */
export function anePrograms(widths:AneWidths=ANE_WIDTHS):AneProgramSpec[] {
  const h=widths.hidden,i=widths.intermediate,[[qi,qo],[zi,zo],[oi,oo],[ai,ao]]=widths.projections;
  return [
    aneMlpSplitProgram(h,i,.353,256,4),aneMlpSplitProgram(h,i,.353,320,4),aneMlpSplitProgram(h,i,.353,384,4),
    aneMlpSplitProgram(h,i,.353,448,4),aneMlpSplitProgram(h,i,.353,512,4),aneMlpSplitProgram(h,i,.353,576,4),
    aneMlpSplitProgram(h,i,.353,640,4),aneMlpSplitProgram(h,i,.353,704,4),
    aneMlpSplitProgram(h,i,.353,768,4),
    aneAffineSplitProgram(qi,qo,.375,768,4),aneAffineSplitProgram(zi,zo,.375,768,4),aneAffineSplitProgram(oi,oo,.375,768,4),aneAffineSplitProgram(ai,ao,.375,768,4),
    aneMlpSplitProgram(h,i,.382,896,4),
    aneAffineSplitProgram(qi,qo,.375,896,4),aneAffineSplitProgram(zi,zo,.375,896,4),aneAffineSplitProgram(oi,oo,.375,896,4),aneAffineSplitProgram(ai,ao,.375,896,4),
    aneMlpSplitProgram(h,i,.382,1024,4),
    aneAffineSplitProgram(qi,qo,.375,1024,4),aneAffineSplitProgram(zi,zo,.375,1024,4),aneAffineSplitProgram(oi,oo,.375,1024,4),aneAffineSplitProgram(ai,ao,.375,1024,4),
    aneMlpSplitProgram(h,i,.382,1280,4),
    aneAffineSplitProgram(qi,qo,.375,1280,4),aneAffineSplitProgram(zi,zo,.375,1280,4),aneAffineSplitProgram(oi,oo,.375,1280,4),aneAffineSplitProgram(ai,ao,.375,1280,4),
    aneMlpSplitProgram(h,i,.382,1536,4),
    aneAffineSplitProgram(qi,qo,.375,1536,4),aneAffineSplitProgram(zi,zo,.375,1536,4),aneAffineSplitProgram(oi,oo,.375,1536,4),aneAffineSplitProgram(ai,ao,.375,1536,4),
    aneMlpSplitProgram(h,i,.382,1792,4),
    aneAffineSplitProgram(qi,qo,.375,1792,4),aneAffineSplitProgram(zi,zo,.375,1792,4),aneAffineSplitProgram(oi,oo,.375,1792,4),aneAffineSplitProgram(ai,ao,.375,1792,4),
    aneMlpSplitProgram(h,i,.382,2048,4),
    aneAffineSplitProgram(qi,qo,.375,2048,4),aneAffineSplitProgram(zi,zo,.375,2048,4),aneAffineSplitProgram(oi,oo,.375,2048,4),aneAffineSplitProgram(ai,ao,.375,2048,4),
  ];
}
const PREFIX="language_model.model";
const REPRESENTATIONS={gateUpCodebook:true,mixedExactBits:true,scatter:{bits:true,genericBits:true,floatCodebook:true},widePrefill:false};
type Layers=readonly [
  Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,
  Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,
  Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,
  Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,Delta,Delta,Delta,Attention,
];
export type RowsForward=(ids:MlxArray,state:Cache[],capture:MlxLayerCapture|null)=>MlxArray;
type LayerWeights=readonly [
  DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,
  DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,
  DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,
  DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,DeltaWeights,DeltaWeights,DeltaWeights,AttentionWeights,
];

/** The M1 Max arrangement, with fixed codebook, MMA, and split ANE operations.
 * The loader recommends it; callers may choose it on any machine. */
export class Qwen38TrellisM1Max implements MlxDeclaredGraph,MlxTokenPhases {
  readonly graph=QWEN38_TRELLIS_M1MAX_GRAPH;
  readonly prefixBase=PREFIX;
  readonly loraState=new LoraState();
  readonly faIdx=3;
  readonly wiredWeights=true;
  readonly weightsBytes:number;
  readonly embed:QuantizedEmbedding;
  readonly finalNorm:RMSNorm;
  readonly lmHead:QuantizedLinear;
  readonly graphCapabilities:GraphCapabilities=declareGraph({media:{input:"embeddings+positions",video:true},hiddenLayerTaps:true,prefill:{boundedWorkspace:true}});
  readonly verifyRoundCosts=new Map([[1,1],[2,1.77],[3,1.95],[4,1.98],[5,2],[6,2.03],[7,2.04],[8,2.05],[16,3.46],[32,6.4]]);
  readonly adaptiveDraftWidths=new Map([["mtp",4]]);
  readonly adaptiveDraftGates=new Map([["dflash2",{decay:.95,idleDecay:.93,probeDepth:1}],["mtp",{decay:.95,idleDecay:.93}]]);
  readonly cacheLayers:readonly MlxCacheLayer[]=[
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
    {kind:"recurrent"},{kind:"recurrent"},{kind:"recurrent"},{kind:"full",turboQuant:"dense",kv4Head256:true,kv4DecodeBlock:128,windowRead:"folded"},
  ];
  readonly prompt:readonly MlxPromptRange[];
  readonly multiSequencePrompt:readonly MlxPromptRange[];
  readonly promptChunk:readonly MlxPromptRange[];
  readonly multiSequencePromptChunk:readonly MlxPromptRange[];
  readonly decode:MlxRowTable<RowsForward>;
  readonly verify:MlxRowTable<RowsForward>;
  readonly appendKnown:readonly MlxKnownRange[];
  readonly logits:MlxRowTable<MlxHeadForward>;
  readonly sequence:readonly MlxSequenceRange[];
  readonly mediaPrefill:readonly MlxPositionedEmbeddingsRange[];
  readonly mediaPrompt:readonly MlxPositionedRange[];
  readonly mediaDecode:MlxRowTable<MlxPositionedForward>;
  readonly embeddingPrompt:readonly MlxEmbeddingsRange[];
  readonly mixed:readonly MlxMixedRange[];
  readonly mixedSeparate:MlxSeparateMixed;
  readonly #head:Plain;
  readonly #targets:Map<string,QwenProjectionTarget>;
  readonly #owned:{dispose():void}[];
  readonly #residualBasis:ResidualBasis|undefined;
  readonly #mrope:{invFreq:MlxArray;rotaryDims:number};
  readonly #one:Layers;
  readonly #rows:Layers;
  readonly #mma:Layers;
  readonly #mmaFive:Layers;
  readonly #wide:Layers;
  readonly #draftProjections:DraftProjectionKernels;
  readonly #vocabulary:()=>NonNullable<DraftProjection["vocabulary"]>;
  readonly #stockNarrow:Layers;
  readonly #fiveToEight:Layers;
  readonly #tiled:Layers;
  readonly #expanded:Layers;

  constructor(weights:Weights,readonly config:ModelConfig) {
    const w=canonicalQwenWeights(weights),c=config,t=config.text;
    this.weightsBytes=[...weights.shards.files.values()].reduce((bytes,file)=>bytes+file.mmap.size,0);
    this.#residualBasis=qwenResidualBasis(this.graph,config.modelDir);
    this.embed=QuantizedEmbedding.load(w,`${PREFIX}.embed_tokens`,c);
    this.finalNorm=new RMSNorm(w.tensor(`${PREFIX}.norm.weight`),t.rmsNormEps);
    this.lmHead=QuantizedLinear.load(w,"language_model.lm_head",c);
    this.#head=new Plain(this.lmHead);
    this.#draftProjections=[
      {from:1,to:1,operation:(w,scales,biases)=>{const kernel=new Plain(new QuantizedLinear(w,scales,biases,{bits:4,groupSize:64,mode:"affine"}));return x=>kernel.forward(x);}},
      {from:2,to:3,operation:(w,scales,biases)=>{const kernel=new Affine4(new QuantizedLinear(w,scales,biases,{bits:4,groupSize:64,mode:"affine"}));return x=>kernel.forward(x);}},
      {from:4,to:Infinity,operation:(w,scales,biases)=>{const kernel=new AffineMma(new QuantizedLinear(w,scales,biases,{bits:4,groupSize:64,mode:"affine"}));return x=>kernel.forward(x);}},
    ];
    const invScale=Math.pow(t.linearKeyHeadDim,-0.5),qk={q:ops.filledBf16(invScale*invScale,t.linearKeyHeadDim),k:ops.filledBf16(invScale,t.linearKeyHeadDim)};
    const rotaryDims=Math.trunc(t.headDim*t.partialRotaryFactor);
    this.#mrope={invFreq:mropeInvFreq(rotaryDims,t.ropeParameters.full_attention!.ropeTheta),rotaryDims};
    this.#owned=[qk.q,qk.k,this.#mrope.invFreq];
    this.#vocabulary=qwenDraftVocabularyMemo(this.lmHead,c.modelDir,"mtp/draft_vocab.json",t.vocabSize,head=>{
      const row=new AffineRow(head),rows=new Affine4(head),mma=new AffineMma(head),plain=new Plain(head);
      return [{from:1,to:1,operation:hidden=>row.forward(hidden)},{from:2,to:3,operation:hidden=>rows.forward(hidden)},
        {from:4,to:256,operation:hidden=>mma.forward(hidden)},{from:257,to:Infinity,operation:hidden=>plain.forward(hidden)}];
    },this.#owned);
    const state=this.loraState;
    const d0=new DeltaWeights(w,c,`${PREFIX}.layers.0`,REPRESENTATIONS,state);
    const d1=new DeltaWeights(w,c,`${PREFIX}.layers.1`,REPRESENTATIONS,state);
    const d2=new DeltaWeights(w,c,`${PREFIX}.layers.2`,REPRESENTATIONS,state);
    const a3=new AttentionWeights(w,c,`${PREFIX}.layers.3`,REPRESENTATIONS,state);
    const d4=new DeltaWeights(w,c,`${PREFIX}.layers.4`,REPRESENTATIONS,state);
    const d5=new DeltaWeights(w,c,`${PREFIX}.layers.5`,REPRESENTATIONS,state);
    const d6=new DeltaWeights(w,c,`${PREFIX}.layers.6`,REPRESENTATIONS,state);
    const a7=new AttentionWeights(w,c,`${PREFIX}.layers.7`,REPRESENTATIONS,state);
    const d8=new DeltaWeights(w,c,`${PREFIX}.layers.8`,REPRESENTATIONS,state);
    const d9=new DeltaWeights(w,c,`${PREFIX}.layers.9`,REPRESENTATIONS,state);
    const d10=new DeltaWeights(w,c,`${PREFIX}.layers.10`,REPRESENTATIONS,state);
    const a11=new AttentionWeights(w,c,`${PREFIX}.layers.11`,REPRESENTATIONS,state);
    const d12=new DeltaWeights(w,c,`${PREFIX}.layers.12`,REPRESENTATIONS,state);
    const d13=new DeltaWeights(w,c,`${PREFIX}.layers.13`,REPRESENTATIONS,state);
    const d14=new DeltaWeights(w,c,`${PREFIX}.layers.14`,REPRESENTATIONS,state);
    const a15=new AttentionWeights(w,c,`${PREFIX}.layers.15`,REPRESENTATIONS,state);
    const d16=new DeltaWeights(w,c,`${PREFIX}.layers.16`,REPRESENTATIONS,state);
    const d17=new DeltaWeights(w,c,`${PREFIX}.layers.17`,REPRESENTATIONS,state);
    const d18=new DeltaWeights(w,c,`${PREFIX}.layers.18`,REPRESENTATIONS,state);
    const a19=new AttentionWeights(w,c,`${PREFIX}.layers.19`,REPRESENTATIONS,state);
    const d20=new DeltaWeights(w,c,`${PREFIX}.layers.20`,REPRESENTATIONS,state);
    const d21=new DeltaWeights(w,c,`${PREFIX}.layers.21`,REPRESENTATIONS,state);
    const d22=new DeltaWeights(w,c,`${PREFIX}.layers.22`,REPRESENTATIONS,state);
    const a23=new AttentionWeights(w,c,`${PREFIX}.layers.23`,REPRESENTATIONS,state);
    const d24=new DeltaWeights(w,c,`${PREFIX}.layers.24`,REPRESENTATIONS,state);
    const d25=new DeltaWeights(w,c,`${PREFIX}.layers.25`,REPRESENTATIONS,state);
    const d26=new DeltaWeights(w,c,`${PREFIX}.layers.26`,REPRESENTATIONS,state);
    const a27=new AttentionWeights(w,c,`${PREFIX}.layers.27`,REPRESENTATIONS,state);
    const d28=new DeltaWeights(w,c,`${PREFIX}.layers.28`,REPRESENTATIONS,state);
    const d29=new DeltaWeights(w,c,`${PREFIX}.layers.29`,REPRESENTATIONS,state);
    const d30=new DeltaWeights(w,c,`${PREFIX}.layers.30`,REPRESENTATIONS,state);
    const a31=new AttentionWeights(w,c,`${PREFIX}.layers.31`,REPRESENTATIONS,state);
    const d32=new DeltaWeights(w,c,`${PREFIX}.layers.32`,REPRESENTATIONS,state);
    const d33=new DeltaWeights(w,c,`${PREFIX}.layers.33`,REPRESENTATIONS,state);
    const d34=new DeltaWeights(w,c,`${PREFIX}.layers.34`,REPRESENTATIONS,state);
    const a35=new AttentionWeights(w,c,`${PREFIX}.layers.35`,REPRESENTATIONS,state);
    const d36=new DeltaWeights(w,c,`${PREFIX}.layers.36`,REPRESENTATIONS,state);
    const d37=new DeltaWeights(w,c,`${PREFIX}.layers.37`,REPRESENTATIONS,state);
    const d38=new DeltaWeights(w,c,`${PREFIX}.layers.38`,REPRESENTATIONS,state);
    const a39=new AttentionWeights(w,c,`${PREFIX}.layers.39`,REPRESENTATIONS,state);
    const d40=new DeltaWeights(w,c,`${PREFIX}.layers.40`,REPRESENTATIONS,state);
    const d41=new DeltaWeights(w,c,`${PREFIX}.layers.41`,REPRESENTATIONS,state);
    const d42=new DeltaWeights(w,c,`${PREFIX}.layers.42`,REPRESENTATIONS,state);
    const a43=new AttentionWeights(w,c,`${PREFIX}.layers.43`,REPRESENTATIONS,state);
    const d44=new DeltaWeights(w,c,`${PREFIX}.layers.44`,REPRESENTATIONS,state);
    const d45=new DeltaWeights(w,c,`${PREFIX}.layers.45`,REPRESENTATIONS,state);
    const d46=new DeltaWeights(w,c,`${PREFIX}.layers.46`,REPRESENTATIONS,state);
    const a47=new AttentionWeights(w,c,`${PREFIX}.layers.47`,REPRESENTATIONS,state);
    const d48=new DeltaWeights(w,c,`${PREFIX}.layers.48`,REPRESENTATIONS,state);
    const d49=new DeltaWeights(w,c,`${PREFIX}.layers.49`,REPRESENTATIONS,state);
    const d50=new DeltaWeights(w,c,`${PREFIX}.layers.50`,REPRESENTATIONS,state);
    const a51=new AttentionWeights(w,c,`${PREFIX}.layers.51`,REPRESENTATIONS,state);
    const d52=new DeltaWeights(w,c,`${PREFIX}.layers.52`,REPRESENTATIONS,state);
    const d53=new DeltaWeights(w,c,`${PREFIX}.layers.53`,REPRESENTATIONS,state);
    const d54=new DeltaWeights(w,c,`${PREFIX}.layers.54`,REPRESENTATIONS,state);
    const a55=new AttentionWeights(w,c,`${PREFIX}.layers.55`,REPRESENTATIONS,state);
    const d56=new DeltaWeights(w,c,`${PREFIX}.layers.56`,REPRESENTATIONS,state);
    const d57=new DeltaWeights(w,c,`${PREFIX}.layers.57`,REPRESENTATIONS,state);
    const d58=new DeltaWeights(w,c,`${PREFIX}.layers.58`,REPRESENTATIONS,state);
    const a59=new AttentionWeights(w,c,`${PREFIX}.layers.59`,REPRESENTATIONS,state);
    const d60=new DeltaWeights(w,c,`${PREFIX}.layers.60`,REPRESENTATIONS,state);
    const d61=new DeltaWeights(w,c,`${PREFIX}.layers.61`,REPRESENTATIONS,state);
    const d62=new DeltaWeights(w,c,`${PREFIX}.layers.62`,REPRESENTATIONS,state);
    const a63=new AttentionWeights(w,c,`${PREFIX}.layers.63`,REPRESENTATIONS,state);
    this.#owned.push(d0.trellis,d1.trellis,d2.trellis,a3.trellis,d4.trellis,d5.trellis,d6.trellis,a7.trellis,
      d8.trellis,d9.trellis,d10.trellis,a11.trellis,d12.trellis,d13.trellis,d14.trellis,a15.trellis,
      d16.trellis,d17.trellis,d18.trellis,a19.trellis,d20.trellis,d21.trellis,d22.trellis,a23.trellis,
      d24.trellis,d25.trellis,d26.trellis,a27.trellis,d28.trellis,d29.trellis,d30.trellis,a31.trellis,
      d32.trellis,d33.trellis,d34.trellis,a35.trellis,d36.trellis,d37.trellis,d38.trellis,a39.trellis,
      d40.trellis,d41.trellis,d42.trellis,a43.trellis,d44.trellis,d45.trellis,d46.trellis,a47.trellis,
      d48.trellis,d49.trellis,d50.trellis,a51.trellis,d52.trellis,d53.trellis,d54.trellis,a55.trellis,
      d56.trellis,d57.trellis,d58.trellis,a59.trellis,d60.trellis,d61.trellis,d62.trellis,a63.trellis);
    this.#targets=new Map([...d0.targets(),...d1.targets(),...d2.targets(),...a3.targets(),...d4.targets(),...d5.targets(),...d6.targets(),...a7.targets(),
      ...d8.targets(),...d9.targets(),...d10.targets(),...a11.targets(),...d12.targets(),...d13.targets(),...d14.targets(),...a15.targets(),
      ...d16.targets(),...d17.targets(),...d18.targets(),...a19.targets(),...d20.targets(),...d21.targets(),...d22.targets(),...a23.targets(),
      ...d24.targets(),...d25.targets(),...d26.targets(),...a27.targets(),...d28.targets(),...d29.targets(),...d30.targets(),...a31.targets(),
      ...d32.targets(),...d33.targets(),...d34.targets(),...a35.targets(),...d36.targets(),...d37.targets(),...d38.targets(),...a39.targets(),
      ...d40.targets(),...d41.targets(),...d42.targets(),...a43.targets(),...d44.targets(),...d45.targets(),...d46.targets(),...a47.targets(),
      ...d48.targets(),...d49.targets(),...d50.targets(),...a51.targets(),...d52.targets(),...d53.targets(),...d54.targets(),...a55.targets(),
      ...d56.targets(),...d57.targets(),...d58.targets(),...a59.targets(),...d60.targets(),...d61.targets(),...d62.targets(),...a63.targets()]);
    this.#one=[
      d0.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d1.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,Plain,qk,GatedNorm),
      d2.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,Plain,qk,GatedNorm),
      a3.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d4.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d5.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d6.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a7.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d8.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d9.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d10.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a11.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d12.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d13.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d14.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a15.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d16.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d17.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d18.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a19.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d20.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d21.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d22.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a23.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d24.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d25.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,Plain,Plain,Plain,AffineRow,qk,GatedNorm),
      d26.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a27.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d28.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d29.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d30.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a31.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d32.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d33.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d34.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a35.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d36.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d37.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d38.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a39.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d40.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d41.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d42.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a43.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d44.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d45.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d46.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a47.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d48.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d49.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d50.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a51.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
      d52.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      d53.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,Plain,Plain,Plain,AffineRow,qk,GatedNorm),
      d54.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,GatedNorm),
      a55.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d56.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d57.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d58.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,AffineRow,Plain,Plain,AffineRow,qk,GatedNorm),
      a59.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain),
      d60.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,AffineRow,qk,GatedNorm),
      d61.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,GatedNorm),
      d62.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain,AffineRow,qk,GatedNorm),
      a63.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
    ];
    this.#rows=[
      d0.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine4,qk),
      d1.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine4,qk),
      d2.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine4,qk),
      a3.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d4.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine4,Affine4,Affine4,Affine4,qk),
      d5.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine4,Affine4,Affine4,Affine4,qk),
      d6.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a7.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d8.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d9.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d10.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a11.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d12.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d13.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d14.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a15.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d16.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d17.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d18.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a19.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d20.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d21.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d22.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a23.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d24.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d25.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine4,Affine4,Affine4,Affine3,qk),
      d26.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a27.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d28.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d29.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d30.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a31.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d32.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d33.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d34.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a35.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d36.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d37.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d38.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a39.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d40.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d41.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d42.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a43.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d44.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d45.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d46.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a47.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d48.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d49.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d50.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      a51.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
      d52.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine3,Affine4,Affine4,Affine3,qk),
      d53.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine3,Affine4,Affine4,Affine4,Affine3,qk),
      d54.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine4,qk),
      a55.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d56.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine4,qk),
      d57.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine4,qk),
      d58.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine3,Affine4,Affine4,Affine3,qk),
      a59.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4),
      d60.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine3,qk),
      d61.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownRows,Affine4,Affine4,Affine4,Affine4,Affine4,qk),
      d62.stage(w,c,Delta,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4,Affine3,qk),
      a63.stage(w,c,Attention,GateDownMLP,GateRows,Reduce,DownK3iRows,Affine4,Affine4,Affine4,Affine4),
    ];
    const rowLayers=this.#rows;
    this.#mma=[
      d0.withProjections(w,c,Delta,rowLayers[0].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d1.withProjections(w,c,Delta,rowLayers[1].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d2.withProjections(w,c,Delta,rowLayers[2].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a3.withProjections(w,c,Attention,rowLayers[3].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d4.withProjections(w,c,Delta,rowLayers[4].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d5.withProjections(w,c,Delta,rowLayers[5].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d6.withProjections(w,c,Delta,rowLayers[6].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a7.withProjections(w,c,Attention,rowLayers[7].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d8.withProjections(w,c,Delta,rowLayers[8].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d9.withProjections(w,c,Delta,rowLayers[9].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d10.withProjections(w,c,Delta,rowLayers[10].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a11.withProjections(w,c,Attention,rowLayers[11].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d12.withProjections(w,c,Delta,rowLayers[12].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d13.withProjections(w,c,Delta,rowLayers[13].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d14.withProjections(w,c,Delta,rowLayers[14].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a15.withProjections(w,c,Attention,rowLayers[15].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d16.withProjections(w,c,Delta,rowLayers[16].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d17.withProjections(w,c,Delta,rowLayers[17].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d18.withProjections(w,c,Delta,rowLayers[18].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a19.withProjections(w,c,Attention,rowLayers[19].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d20.withProjections(w,c,Delta,rowLayers[20].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d21.withProjections(w,c,Delta,rowLayers[21].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d22.withProjections(w,c,Delta,rowLayers[22].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a23.withProjections(w,c,Attention,rowLayers[23].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d24.withProjections(w,c,Delta,rowLayers[24].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d25.withProjections(w,c,Delta,rowLayers[25].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d26.withProjections(w,c,Delta,rowLayers[26].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a27.withProjections(w,c,Attention,rowLayers[27].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d28.withProjections(w,c,Delta,rowLayers[28].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d29.withProjections(w,c,Delta,rowLayers[29].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d30.withProjections(w,c,Delta,rowLayers[30].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a31.withProjections(w,c,Attention,rowLayers[31].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d32.withProjections(w,c,Delta,rowLayers[32].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d33.withProjections(w,c,Delta,rowLayers[33].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d34.withProjections(w,c,Delta,rowLayers[34].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a35.withProjections(w,c,Attention,rowLayers[35].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d36.withProjections(w,c,Delta,rowLayers[36].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d37.withProjections(w,c,Delta,rowLayers[37].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d38.withProjections(w,c,Delta,rowLayers[38].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a39.withProjections(w,c,Attention,rowLayers[39].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d40.withProjections(w,c,Delta,rowLayers[40].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d41.withProjections(w,c,Delta,rowLayers[41].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d42.withProjections(w,c,Delta,rowLayers[42].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a43.withProjections(w,c,Attention,rowLayers[43].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d44.withProjections(w,c,Delta,rowLayers[44].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d45.withProjections(w,c,Delta,rowLayers[45].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d46.withProjections(w,c,Delta,rowLayers[46].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a47.withProjections(w,c,Attention,rowLayers[47].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d48.withProjections(w,c,Delta,rowLayers[48].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d49.withProjections(w,c,Delta,rowLayers[49].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d50.withProjections(w,c,Delta,rowLayers[50].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a51.withProjections(w,c,Attention,rowLayers[51].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d52.withProjections(w,c,Delta,rowLayers[52].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d53.withProjections(w,c,Delta,rowLayers[53].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d54.withProjections(w,c,Delta,rowLayers[54].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a55.withProjections(w,c,Attention,rowLayers[55].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d56.withProjections(w,c,Delta,rowLayers[56].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d57.withProjections(w,c,Delta,rowLayers[57].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d58.withProjections(w,c,Delta,rowLayers[58].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a59.withProjections(w,c,Attention,rowLayers[59].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
      d60.withProjections(w,c,Delta,rowLayers[60].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d61.withProjections(w,c,Delta,rowLayers[61].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d62.withProjections(w,c,Delta,rowLayers[62].mlp,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a63.withProjections(w,c,Attention,rowLayers[63].mlp,AffineMma,AffineMma,AffineMma,AffineMma),
    ];
    this.#mmaFive=[
      d0.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d1.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d2.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a3.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d4.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d5.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d6.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a7.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d8.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d9.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d10.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a11.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d12.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d13.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d14.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a15.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d16.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d17.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d18.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a19.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d20.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d21.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d22.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a23.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d24.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d25.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d26.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a27.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d28.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d29.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d30.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a31.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d32.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d33.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d34.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a35.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d36.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d37.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d38.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a39.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d40.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d41.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d42.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a43.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d44.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d45.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d46.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a47.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d48.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d49.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d50.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a51.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d52.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d53.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d54.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a55.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d56.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d57.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d58.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a59.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma),
      d60.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d61.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d62.stage(w,c,Delta,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a63.stage(w,c,Attention,GateDownMLP,GateRows,Tiled,DownK3iRows,AffineMma,AffineMma,AffineMma,AffineMma),
    ];
    this.#wide=[
      d0.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d1.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d2.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a3.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d4.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d5.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d6.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a7.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d8.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d9.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d10.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a11.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d12.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d13.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d14.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a15.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d16.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d17.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d18.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a19.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d20.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d21.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d22.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a23.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d24.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d25.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d26.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a27.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d28.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d29.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d30.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a31.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d32.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d33.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d34.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a35.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d36.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d37.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d38.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a39.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d40.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d41.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d42.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a43.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d44.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d45.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d46.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a47.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d48.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d49.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d50.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a51.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
      d52.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d53.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d54.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a55.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d56.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d57.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d58.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a59.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma),
      d60.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d61.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDown,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      d62.stage(w,c,Delta,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma,AffineMma,qk),
      a63.stage(w,c,Attention,GateDownMLP,WideGate,ExpandGate,WideDownK3i,AffineMma,AffineMma,AffineMma,AffineMma),
    ];
    this.#stockNarrow=[
      d0.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d1.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d2.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a3.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d4.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d5.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d6.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a7.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d8.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d9.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d10.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a11.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d12.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d13.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d14.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a15.stage(w,c,Attention,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain),
      d16.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d17.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d18.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a19.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d20.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d21.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      d22.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a23.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d24.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d25.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d26.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a27.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d28.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d29.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d30.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a31.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d32.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d33.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d34.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a35.stage(w,c,Attention,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain),
      d36.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      d37.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d38.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a39.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d40.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d41.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d42.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a43.stage(w,c,Attention,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain),
      d44.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d45.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d46.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a47.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d48.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d49.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d50.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      a51.stage(w,c,Attention,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain),
      d52.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d53.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      d54.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a55.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d56.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      d57.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d58.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      a59.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
      d60.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d61.fused(w,c,Delta,TrellisFusedMLP,Scatter,Plain,qk),
      d62.stage(w,c,Delta,GateDownMLP,MixedGate,Reduce,Scatter,Plain,Plain,Plain,Plain,Plain,qk),
      a63.fused(w,c,Attention,TrellisFusedMLP,Scatter,Plain),
    ];
    this.#fiveToEight=[
      d0.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d1.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d2.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a3.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d4.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d5.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d6.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a7.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d8.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d9.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d10.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a11.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d12.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d13.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d14.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a15.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d16.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d17.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d18.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a19.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d20.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d21.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d22.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a23.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d24.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d25.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d26.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a27.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d28.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d29.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d30.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a31.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d32.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d33.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d34.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a35.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d36.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d37.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d38.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a39.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d40.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d41.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d42.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a43.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d44.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d45.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d46.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a47.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d48.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d49.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d50.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a51.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d52.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d53.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d54.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a55.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d56.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d57.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d58.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a59.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
      d60.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d61.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      d62.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,SplitK,Plain,qk),
      a63.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,SplitK,Plain),
    ];
    this.#tiled=[
      d0.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d1.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d2.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a3.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d4.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d5.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d6.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a7.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d8.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d9.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d10.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a11.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d12.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d13.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d14.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a15.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d16.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d17.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d18.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a19.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d20.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d21.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d22.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a23.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d24.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d25.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d26.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a27.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d28.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d29.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d30.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a31.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d32.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d33.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d34.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a35.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d36.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d37.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d38.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a39.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d40.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d41.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d42.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a43.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d44.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d45.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d46.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a47.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d48.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d49.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d50.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a51.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d52.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d53.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d54.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a55.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d56.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d57.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d58.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a59.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
      d60.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d61.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      d62.prompt(w,c,Delta,TrellisUnfusedMLP,Tiled,ExpandDown,Plain,qk),
      a63.prompt(w,c,Attention,TrellisUnfusedMLP,Tiled,ExpandDown,Plain),
    ];
    this.#expanded=[
      d0.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d1.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d2.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a3.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d4.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d5.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d6.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a7.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d8.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d9.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d10.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a11.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d12.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d13.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d14.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a15.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d16.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d17.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d18.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a19.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d20.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d21.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d22.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a23.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d24.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d25.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d26.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a27.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d28.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d29.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d30.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a31.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d32.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d33.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d34.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a35.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d36.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d37.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d38.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a39.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d40.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d41.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d42.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a43.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d44.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d45.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d46.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a47.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d48.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d49.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d50.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a51.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d52.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d53.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d54.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a55.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d56.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d57.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d58.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a59.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
      d60.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d61.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      d62.prompt(w,c,Delta,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain,qk),
      a63.prompt(w,c,Attention,TrellisUnfusedMLP,ExpandGate,ExpandDown,Plain),
    ];
    const stock=this.#stockNarrow,five=this.#fiveToEight,tiled=this.#tiled,expanded=this.#expanded;
    const mixedUnfused:Layers=[
      d0.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d1.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d2.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a3.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d4.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d5.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d6.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a7.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d8.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d9.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d10.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a11.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d12.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d13.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d14.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a15.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d16.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d17.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d18.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a19.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d20.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d21.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d22.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a23.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d24.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d25.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d26.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a27.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d28.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d29.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d30.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a31.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d32.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d33.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d34.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a35.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d36.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d37.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d38.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a39.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d40.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d41.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d42.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a43.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d44.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d45.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d46.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a47.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d48.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d49.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d50.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a51.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d52.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d53.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d54.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a55.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d56.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d57.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d58.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a59.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
      d60.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d61.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),d62.prompt(w,c,Delta,TrellisUnfusedMLP,Reduce,Scatter,Plain,qk),a63.prompt(w,c,Attention,TrellisUnfusedMLP,Reduce,Scatter,Plain),
    ];
    const wide=this.#wide,mma=this.#mma;
    const prompt512:Layers=[
      d0.withProjections(w,c,Delta,expanded[0].mlp,Dense,Dense,Plain,Plain,Dense,qk),d1.withProjections(w,c,Delta,expanded[1].mlp,Dense,Dense,Plain,Plain,Dense,qk),d2.withProjections(w,c,Delta,expanded[2].mlp,Dense,Dense,Plain,Plain,Dense,qk),a3.withProjections(w,c,Attention,expanded[3].mlp,Dense,Plain,Plain,Dense),
      d4.withProjections(w,c,Delta,expanded[4].mlp,Dense,Dense,Plain,Plain,Dense,qk),d5.withProjections(w,c,Delta,expanded[5].mlp,Dense,Dense,Plain,Plain,Dense,qk),d6.withProjections(w,c,Delta,expanded[6].mlp,Dense,Dense,Plain,Plain,Dense,qk),a7.withProjections(w,c,Attention,expanded[7].mlp,Dense,Plain,Plain,Dense),
      d8.withProjections(w,c,Delta,expanded[8].mlp,Dense,Dense,Plain,Plain,Dense,qk),d9.withProjections(w,c,Delta,expanded[9].mlp,Dense,Dense,Plain,Plain,Dense,qk),d10.withProjections(w,c,Delta,expanded[10].mlp,Dense,Dense,Plain,Plain,Dense,qk),a11.withProjections(w,c,Attention,expanded[11].mlp,Dense,Plain,Plain,Dense),
      d12.withProjections(w,c,Delta,expanded[12].mlp,Dense,Dense,Plain,Plain,Dense,qk),d13.withProjections(w,c,Delta,expanded[13].mlp,Dense,Dense,Plain,Plain,Dense,qk),d14.withProjections(w,c,Delta,expanded[14].mlp,Dense,Dense,Plain,Plain,Dense,qk),a15.withProjections(w,c,Attention,expanded[15].mlp,Dense,Plain,Plain,Dense),
      d16.withProjections(w,c,Delta,expanded[16].mlp,Dense,Dense,Plain,Plain,Dense,qk),d17.withProjections(w,c,Delta,expanded[17].mlp,Dense,Dense,Plain,Plain,Dense,qk),d18.withProjections(w,c,Delta,expanded[18].mlp,Dense,Dense,Plain,Plain,Dense,qk),a19.withProjections(w,c,Attention,expanded[19].mlp,Dense,Plain,Plain,Dense),
      d20.withProjections(w,c,Delta,expanded[20].mlp,Dense,Dense,Plain,Plain,Dense,qk),d21.withProjections(w,c,Delta,expanded[21].mlp,Dense,Dense,Plain,Plain,Dense,qk),d22.withProjections(w,c,Delta,expanded[22].mlp,Dense,Dense,Plain,Plain,Dense,qk),a23.withProjections(w,c,Attention,expanded[23].mlp,Dense,Plain,Plain,Dense),
      d24.withProjections(w,c,Delta,expanded[24].mlp,Dense,Dense,Plain,Plain,Dense,qk),d25.withProjections(w,c,Delta,expanded[25].mlp,Dense,Dense,Plain,Plain,Dense,qk),d26.withProjections(w,c,Delta,expanded[26].mlp,Dense,Dense,Plain,Plain,Dense,qk),a27.withProjections(w,c,Attention,expanded[27].mlp,Dense,Plain,Plain,Dense),
      d28.withProjections(w,c,Delta,expanded[28].mlp,Dense,Dense,Plain,Plain,Dense,qk),d29.withProjections(w,c,Delta,expanded[29].mlp,Dense,Dense,Plain,Plain,Dense,qk),d30.withProjections(w,c,Delta,expanded[30].mlp,Dense,Dense,Plain,Plain,Dense,qk),a31.withProjections(w,c,Attention,expanded[31].mlp,Dense,Plain,Plain,Dense),
      d32.withProjections(w,c,Delta,expanded[32].mlp,Dense,Dense,Plain,Plain,Dense,qk),d33.withProjections(w,c,Delta,expanded[33].mlp,Dense,Dense,Plain,Plain,Dense,qk),d34.withProjections(w,c,Delta,expanded[34].mlp,Dense,Dense,Plain,Plain,Dense,qk),a35.withProjections(w,c,Attention,expanded[35].mlp,Dense,Plain,Plain,Dense),
      d36.withProjections(w,c,Delta,expanded[36].mlp,Dense,Dense,Plain,Plain,Dense,qk),d37.withProjections(w,c,Delta,expanded[37].mlp,Dense,Dense,Plain,Plain,Dense,qk),d38.withProjections(w,c,Delta,expanded[38].mlp,Dense,Dense,Plain,Plain,Dense,qk),a39.withProjections(w,c,Attention,expanded[39].mlp,Dense,Plain,Plain,Dense),
      d40.withProjections(w,c,Delta,expanded[40].mlp,Dense,Dense,Plain,Plain,Dense,qk),d41.withProjections(w,c,Delta,expanded[41].mlp,Dense,Dense,Plain,Plain,Dense,qk),d42.withProjections(w,c,Delta,expanded[42].mlp,Dense,Dense,Plain,Plain,Dense,qk),a43.withProjections(w,c,Attention,expanded[43].mlp,Dense,Plain,Plain,Dense),
      d44.withProjections(w,c,Delta,expanded[44].mlp,Dense,Dense,Plain,Plain,Dense,qk),d45.withProjections(w,c,Delta,expanded[45].mlp,Dense,Dense,Plain,Plain,Dense,qk),d46.withProjections(w,c,Delta,expanded[46].mlp,Dense,Dense,Plain,Plain,Dense,qk),a47.withProjections(w,c,Attention,expanded[47].mlp,Dense,Plain,Plain,Dense),
      d48.withProjections(w,c,Delta,expanded[48].mlp,Dense,Dense,Plain,Plain,Dense,qk),d49.withProjections(w,c,Delta,expanded[49].mlp,Dense,Dense,Plain,Plain,Dense,qk),d50.withProjections(w,c,Delta,expanded[50].mlp,Dense,Dense,Plain,Plain,Dense,qk),a51.withProjections(w,c,Attention,expanded[51].mlp,Dense,Plain,Plain,Dense),
      d52.withProjections(w,c,Delta,expanded[52].mlp,Dense,Dense,Plain,Plain,Dense,qk),d53.withProjections(w,c,Delta,expanded[53].mlp,Dense,Dense,Plain,Plain,Dense,qk),d54.withProjections(w,c,Delta,expanded[54].mlp,Dense,Dense,Plain,Plain,Dense,qk),a55.withProjections(w,c,Attention,expanded[55].mlp,Dense,Plain,Plain,Dense),
      d56.withProjections(w,c,Delta,expanded[56].mlp,Dense,Dense,Plain,Plain,Dense,qk),d57.withProjections(w,c,Delta,expanded[57].mlp,Dense,Dense,Plain,Plain,Dense,qk),d58.withProjections(w,c,Delta,expanded[58].mlp,Dense,Dense,Plain,Plain,Dense,qk),a59.withProjections(w,c,Attention,expanded[59].mlp,Dense,Plain,Plain,Dense),
      d60.withProjections(w,c,Delta,expanded[60].mlp,Dense,Dense,Plain,Plain,Dense,qk),d61.withProjections(w,c,Delta,expanded[61].mlp,Dense,Dense,Plain,Plain,Dense,qk),d62.withProjections(w,c,Delta,expanded[62].mlp,Dense,Dense,Plain,Plain,Dense,qk),a63.withProjections(w,c,Attention,expanded[63].mlp,Dense,Plain,Plain,Dense),
    ];
    const promptDense:Layers=[
      prompt512[0],prompt512[1],prompt512[2],a3.withProjections(w,c,Attention,expanded[3].mlp,Dense,Dense,Dense,Dense),
      prompt512[4],prompt512[5],prompt512[6],a7.withProjections(w,c,Attention,expanded[7].mlp,Dense,Dense,Dense,Dense),
      prompt512[8],prompt512[9],prompt512[10],a11.withProjections(w,c,Attention,expanded[11].mlp,Dense,Dense,Dense,Dense),
      prompt512[12],prompt512[13],prompt512[14],a15.withProjections(w,c,Attention,expanded[15].mlp,Dense,Dense,Dense,Dense),
      prompt512[16],prompt512[17],prompt512[18],a19.withProjections(w,c,Attention,expanded[19].mlp,Dense,Dense,Dense,Dense),
      prompt512[20],prompt512[21],prompt512[22],a23.withProjections(w,c,Attention,expanded[23].mlp,Dense,Dense,Dense,Dense),
      prompt512[24],prompt512[25],prompt512[26],a27.withProjections(w,c,Attention,expanded[27].mlp,Dense,Dense,Dense,Dense),
      prompt512[28],prompt512[29],prompt512[30],a31.withProjections(w,c,Attention,expanded[31].mlp,Dense,Dense,Dense,Dense),
      prompt512[32],prompt512[33],prompt512[34],a35.withProjections(w,c,Attention,expanded[35].mlp,Dense,Dense,Dense,Dense),
      prompt512[36],prompt512[37],prompt512[38],a39.withProjections(w,c,Attention,expanded[39].mlp,Dense,Dense,Dense,Dense),
      prompt512[40],prompt512[41],prompt512[42],a43.withProjections(w,c,Attention,expanded[43].mlp,Dense,Dense,Dense,Dense),
      prompt512[44],prompt512[45],prompt512[46],a47.withProjections(w,c,Attention,expanded[47].mlp,Dense,Dense,Dense,Dense),
      prompt512[48],prompt512[49],prompt512[50],a51.withProjections(w,c,Attention,expanded[51].mlp,Dense,Dense,Dense,Dense),
      prompt512[52],prompt512[53],prompt512[54],a55.withProjections(w,c,Attention,expanded[55].mlp,Dense,Dense,Dense,Dense),
      prompt512[56],prompt512[57],prompt512[58],a59.withProjections(w,c,Attention,expanded[59].mlp,Dense,Dense,Dense,Dense),
      prompt512[60],prompt512[61],prompt512[62],a63.withProjections(w,c,Attention,expanded[63].mlp,Dense,Dense,Dense,Dense),
    ];
    const mixedWide:Layers=[
      d0.withMlp(w,c,Delta,wide[0].mlp,Plain,qk),d1.withMlp(w,c,Delta,wide[1].mlp,Plain,qk),d2.withMlp(w,c,Delta,wide[2].mlp,Plain,qk),a3.withMlp(w,c,Attention,wide[3].mlp,Plain),
      d4.withMlp(w,c,Delta,wide[4].mlp,Plain,qk),d5.withMlp(w,c,Delta,wide[5].mlp,Plain,qk),d6.withMlp(w,c,Delta,wide[6].mlp,Plain,qk),a7.withMlp(w,c,Attention,wide[7].mlp,Plain),
      d8.withMlp(w,c,Delta,wide[8].mlp,Plain,qk),d9.withMlp(w,c,Delta,wide[9].mlp,Plain,qk),d10.withMlp(w,c,Delta,wide[10].mlp,Plain,qk),a11.withMlp(w,c,Attention,wide[11].mlp,Plain),
      d12.withMlp(w,c,Delta,wide[12].mlp,Plain,qk),d13.withMlp(w,c,Delta,wide[13].mlp,Plain,qk),d14.withMlp(w,c,Delta,wide[14].mlp,Plain,qk),a15.withMlp(w,c,Attention,wide[15].mlp,Plain),
      d16.withMlp(w,c,Delta,wide[16].mlp,Plain,qk),d17.withMlp(w,c,Delta,wide[17].mlp,Plain,qk),d18.withMlp(w,c,Delta,wide[18].mlp,Plain,qk),a19.withMlp(w,c,Attention,wide[19].mlp,Plain),
      d20.withMlp(w,c,Delta,wide[20].mlp,Plain,qk),d21.withMlp(w,c,Delta,wide[21].mlp,Plain,qk),d22.withMlp(w,c,Delta,wide[22].mlp,Plain,qk),a23.withMlp(w,c,Attention,wide[23].mlp,Plain),
      d24.withMlp(w,c,Delta,wide[24].mlp,Plain,qk),d25.withMlp(w,c,Delta,wide[25].mlp,Plain,qk),d26.withMlp(w,c,Delta,wide[26].mlp,Plain,qk),a27.withMlp(w,c,Attention,wide[27].mlp,Plain),
      d28.withMlp(w,c,Delta,wide[28].mlp,Plain,qk),d29.withMlp(w,c,Delta,wide[29].mlp,Plain,qk),d30.withMlp(w,c,Delta,wide[30].mlp,Plain,qk),a31.withMlp(w,c,Attention,wide[31].mlp,Plain),
      d32.withMlp(w,c,Delta,wide[32].mlp,Plain,qk),d33.withMlp(w,c,Delta,wide[33].mlp,Plain,qk),d34.withMlp(w,c,Delta,wide[34].mlp,Plain,qk),a35.withMlp(w,c,Attention,wide[35].mlp,Plain),
      d36.withMlp(w,c,Delta,wide[36].mlp,Plain,qk),d37.withMlp(w,c,Delta,wide[37].mlp,Plain,qk),d38.withMlp(w,c,Delta,wide[38].mlp,Plain,qk),a39.withMlp(w,c,Attention,wide[39].mlp,Plain),
      d40.withMlp(w,c,Delta,wide[40].mlp,Plain,qk),d41.withMlp(w,c,Delta,wide[41].mlp,Plain,qk),d42.withMlp(w,c,Delta,wide[42].mlp,Plain,qk),a43.withMlp(w,c,Attention,wide[43].mlp,Plain),
      d44.withMlp(w,c,Delta,wide[44].mlp,Plain,qk),d45.withMlp(w,c,Delta,wide[45].mlp,Plain,qk),d46.withMlp(w,c,Delta,wide[46].mlp,Plain,qk),a47.withMlp(w,c,Attention,wide[47].mlp,Plain),
      d48.withMlp(w,c,Delta,wide[48].mlp,Plain,qk),d49.withMlp(w,c,Delta,wide[49].mlp,Plain,qk),d50.withMlp(w,c,Delta,wide[50].mlp,Plain,qk),a51.withMlp(w,c,Attention,wide[51].mlp,Plain),
      d52.withMlp(w,c,Delta,wide[52].mlp,Plain,qk),d53.withMlp(w,c,Delta,wide[53].mlp,Plain,qk),d54.withMlp(w,c,Delta,wide[54].mlp,Plain,qk),a55.withMlp(w,c,Attention,wide[55].mlp,Plain),
      d56.withMlp(w,c,Delta,wide[56].mlp,Plain,qk),d57.withMlp(w,c,Delta,wide[57].mlp,Plain,qk),d58.withMlp(w,c,Delta,wide[58].mlp,Plain,qk),a59.withMlp(w,c,Attention,wide[59].mlp,Plain),
      d60.withMlp(w,c,Delta,wide[60].mlp,Plain,qk),d61.withMlp(w,c,Delta,wide[61].mlp,Plain,qk),d62.withMlp(w,c,Delta,wide[62].mlp,Plain,qk),a63.withMlp(w,c,Attention,wide[63].mlp,Plain),
    ];
    const mediaStock:Layers=[
      stock[0],stock[1],stock[2],a3.mediaLayer(w,c,Attention,stock[3].mlp,Plain),
      stock[4],stock[5],stock[6],a7.mediaLayer(w,c,Attention,stock[7].mlp,Plain),
      stock[8],stock[9],stock[10],a11.mediaLayer(w,c,Attention,stock[11].mlp,Plain),
      stock[12],stock[13],stock[14],a15.mediaLayer(w,c,Attention,stock[15].mlp,Plain),
      stock[16],stock[17],stock[18],a19.mediaLayer(w,c,Attention,stock[19].mlp,Plain),
      stock[20],stock[21],stock[22],a23.mediaLayer(w,c,Attention,stock[23].mlp,Plain),
      stock[24],stock[25],stock[26],a27.mediaLayer(w,c,Attention,stock[27].mlp,Plain),
      stock[28],stock[29],stock[30],a31.mediaLayer(w,c,Attention,stock[31].mlp,Plain),
      stock[32],stock[33],stock[34],a35.mediaLayer(w,c,Attention,stock[35].mlp,Plain),
      stock[36],stock[37],stock[38],a39.mediaLayer(w,c,Attention,stock[39].mlp,Plain),
      stock[40],stock[41],stock[42],a43.mediaLayer(w,c,Attention,stock[43].mlp,Plain),
      stock[44],stock[45],stock[46],a47.mediaLayer(w,c,Attention,stock[47].mlp,Plain),
      stock[48],stock[49],stock[50],a51.mediaLayer(w,c,Attention,stock[51].mlp,Plain),
      stock[52],stock[53],stock[54],a55.mediaLayer(w,c,Attention,stock[55].mlp,Plain),
      stock[56],stock[57],stock[58],a59.mediaLayer(w,c,Attention,stock[59].mlp,Plain),
      stock[60],stock[61],stock[62],a63.mediaLayer(w,c,Attention,stock[63].mlp,Plain),
    ];
    const mediaFive:Layers=[
      five[0],five[1],five[2],a3.mediaLayer(w,c,Attention,five[3].mlp,Plain),
      five[4],five[5],five[6],a7.mediaLayer(w,c,Attention,five[7].mlp,Plain),
      five[8],five[9],five[10],a11.mediaLayer(w,c,Attention,five[11].mlp,Plain),
      five[12],five[13],five[14],a15.mediaLayer(w,c,Attention,five[15].mlp,Plain),
      five[16],five[17],five[18],a19.mediaLayer(w,c,Attention,five[19].mlp,Plain),
      five[20],five[21],five[22],a23.mediaLayer(w,c,Attention,five[23].mlp,Plain),
      five[24],five[25],five[26],a27.mediaLayer(w,c,Attention,five[27].mlp,Plain),
      five[28],five[29],five[30],a31.mediaLayer(w,c,Attention,five[31].mlp,Plain),
      five[32],five[33],five[34],a35.mediaLayer(w,c,Attention,five[35].mlp,Plain),
      five[36],five[37],five[38],a39.mediaLayer(w,c,Attention,five[39].mlp,Plain),
      five[40],five[41],five[42],a43.mediaLayer(w,c,Attention,five[43].mlp,Plain),
      five[44],five[45],five[46],a47.mediaLayer(w,c,Attention,five[47].mlp,Plain),
      five[48],five[49],five[50],a51.mediaLayer(w,c,Attention,five[51].mlp,Plain),
      five[52],five[53],five[54],a55.mediaLayer(w,c,Attention,five[55].mlp,Plain),
      five[56],five[57],five[58],a59.mediaLayer(w,c,Attention,five[59].mlp,Plain),
      five[60],five[61],five[62],a63.mediaLayer(w,c,Attention,five[63].mlp,Plain),
    ];
    const mediaTiled:Layers=[
      tiled[0],tiled[1],tiled[2],a3.mediaLayer(w,c,Attention,tiled[3].mlp,Plain),
      tiled[4],tiled[5],tiled[6],a7.mediaLayer(w,c,Attention,tiled[7].mlp,Plain),
      tiled[8],tiled[9],tiled[10],a11.mediaLayer(w,c,Attention,tiled[11].mlp,Plain),
      tiled[12],tiled[13],tiled[14],a15.mediaLayer(w,c,Attention,tiled[15].mlp,Plain),
      tiled[16],tiled[17],tiled[18],a19.mediaLayer(w,c,Attention,tiled[19].mlp,Plain),
      tiled[20],tiled[21],tiled[22],a23.mediaLayer(w,c,Attention,tiled[23].mlp,Plain),
      tiled[24],tiled[25],tiled[26],a27.mediaLayer(w,c,Attention,tiled[27].mlp,Plain),
      tiled[28],tiled[29],tiled[30],a31.mediaLayer(w,c,Attention,tiled[31].mlp,Plain),
      tiled[32],tiled[33],tiled[34],a35.mediaLayer(w,c,Attention,tiled[35].mlp,Plain),
      tiled[36],tiled[37],tiled[38],a39.mediaLayer(w,c,Attention,tiled[39].mlp,Plain),
      tiled[40],tiled[41],tiled[42],a43.mediaLayer(w,c,Attention,tiled[43].mlp,Plain),
      tiled[44],tiled[45],tiled[46],a47.mediaLayer(w,c,Attention,tiled[47].mlp,Plain),
      tiled[48],tiled[49],tiled[50],a51.mediaLayer(w,c,Attention,tiled[51].mlp,Plain),
      tiled[52],tiled[53],tiled[54],a55.mediaLayer(w,c,Attention,tiled[55].mlp,Plain),
      tiled[56],tiled[57],tiled[58],a59.mediaLayer(w,c,Attention,tiled[59].mlp,Plain),
      tiled[60],tiled[61],tiled[62],a63.mediaLayer(w,c,Attention,tiled[63].mlp,Plain),
    ];
    const mediaExpanded:Layers=[
      expanded[0],expanded[1],expanded[2],a3.mediaLayer(w,c,Attention,expanded[3].mlp,Plain),
      expanded[4],expanded[5],expanded[6],a7.mediaLayer(w,c,Attention,expanded[7].mlp,Plain),
      expanded[8],expanded[9],expanded[10],a11.mediaLayer(w,c,Attention,expanded[11].mlp,Plain),
      expanded[12],expanded[13],expanded[14],a15.mediaLayer(w,c,Attention,expanded[15].mlp,Plain),
      expanded[16],expanded[17],expanded[18],a19.mediaLayer(w,c,Attention,expanded[19].mlp,Plain),
      expanded[20],expanded[21],expanded[22],a23.mediaLayer(w,c,Attention,expanded[23].mlp,Plain),
      expanded[24],expanded[25],expanded[26],a27.mediaLayer(w,c,Attention,expanded[27].mlp,Plain),
      expanded[28],expanded[29],expanded[30],a31.mediaLayer(w,c,Attention,expanded[31].mlp,Plain),
      expanded[32],expanded[33],expanded[34],a35.mediaLayer(w,c,Attention,expanded[35].mlp,Plain),
      expanded[36],expanded[37],expanded[38],a39.mediaLayer(w,c,Attention,expanded[39].mlp,Plain),
      expanded[40],expanded[41],expanded[42],a43.mediaLayer(w,c,Attention,expanded[43].mlp,Plain),
      expanded[44],expanded[45],expanded[46],a47.mediaLayer(w,c,Attention,expanded[47].mlp,Plain),
      expanded[48],expanded[49],expanded[50],a51.mediaLayer(w,c,Attention,expanded[51].mlp,Plain),
      expanded[52],expanded[53],expanded[54],a55.mediaLayer(w,c,Attention,expanded[55].mlp,Plain),
      expanded[56],expanded[57],expanded[58],a59.mediaLayer(w,c,Attention,expanded[59].mlp,Plain),
      expanded[60],expanded[61],expanded[62],a63.mediaLayer(w,c,Attention,expanded[63].mlp,Plain),
    ];
    const mmaFive=this.#mmaFive;
    const mixedWideNarrow:Layers=[
      d0.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d1.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d2.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a3.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d4.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d5.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d6.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a7.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d8.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d9.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d10.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a11.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d12.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d13.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d14.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a15.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d16.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d17.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d18.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a19.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d20.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d21.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d22.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a23.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d24.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d25.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d26.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a27.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d28.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d29.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d30.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a31.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d32.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d33.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d34.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a35.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d36.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d37.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d38.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a39.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d40.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d41.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d42.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a43.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d44.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d45.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d46.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a47.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d48.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d49.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d50.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a51.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
      d52.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d53.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d54.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a55.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d56.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d57.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d58.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a59.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain),
      d60.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d61.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d62.stage(w,c,Delta,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a63.stage(w,c,Attention,GateDownMLP,WideGate,Reduce,WideDownK3i,Plain,Plain,Plain,Plain),
    ];
    const mixedWideFive:Layers=[
      d0.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d1.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d2.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a3.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d4.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d5.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d6.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a7.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d8.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d9.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d10.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a11.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d12.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d13.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d14.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a15.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d16.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d17.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d18.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a19.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d20.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d21.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d22.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a23.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d24.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d25.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d26.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a27.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d28.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d29.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d30.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a31.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d32.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d33.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d34.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a35.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d36.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d37.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d38.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a39.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d40.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d41.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d42.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a43.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d44.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d45.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d46.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a47.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d48.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d49.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d50.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a51.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
      d52.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d53.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),d54.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a55.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d56.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d57.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d58.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),a59.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain),
      d60.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d61.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDown,Plain,Plain,Plain,Plain,Plain,qk),d62.stage(w,c,Delta,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain,Plain,qk),a63.stage(w,c,Attention,GateDownMLP,WideGate,Tiled,WideDownK3i,Plain,Plain,Plain,Plain),
    ];
    const chunkNarrow:Layers=[
      new Delta(w,c,`${PREFIX}.layers.0`,wide[0].mixer,mixedWideNarrow[0].mlp),new Delta(w,c,`${PREFIX}.layers.1`,wide[1].mixer,mixedWideNarrow[1].mlp),new Delta(w,c,`${PREFIX}.layers.2`,wide[2].mixer,mixedWideNarrow[2].mlp),new Attention(w,c,`${PREFIX}.layers.3`,wide[3].mixer,mixedWideNarrow[3].mlp),
      new Delta(w,c,`${PREFIX}.layers.4`,wide[4].mixer,mixedWideNarrow[4].mlp),new Delta(w,c,`${PREFIX}.layers.5`,wide[5].mixer,mixedWideNarrow[5].mlp),new Delta(w,c,`${PREFIX}.layers.6`,wide[6].mixer,mixedWideNarrow[6].mlp),new Attention(w,c,`${PREFIX}.layers.7`,wide[7].mixer,mixedWideNarrow[7].mlp),
      new Delta(w,c,`${PREFIX}.layers.8`,wide[8].mixer,mixedWideNarrow[8].mlp),new Delta(w,c,`${PREFIX}.layers.9`,wide[9].mixer,mixedWideNarrow[9].mlp),new Delta(w,c,`${PREFIX}.layers.10`,wide[10].mixer,mixedWideNarrow[10].mlp),new Attention(w,c,`${PREFIX}.layers.11`,wide[11].mixer,mixedWideNarrow[11].mlp),
      new Delta(w,c,`${PREFIX}.layers.12`,wide[12].mixer,mixedWideNarrow[12].mlp),new Delta(w,c,`${PREFIX}.layers.13`,wide[13].mixer,mixedWideNarrow[13].mlp),new Delta(w,c,`${PREFIX}.layers.14`,wide[14].mixer,mixedWideNarrow[14].mlp),new Attention(w,c,`${PREFIX}.layers.15`,wide[15].mixer,mixedWideNarrow[15].mlp),
      new Delta(w,c,`${PREFIX}.layers.16`,wide[16].mixer,mixedWideNarrow[16].mlp),new Delta(w,c,`${PREFIX}.layers.17`,wide[17].mixer,mixedWideNarrow[17].mlp),new Delta(w,c,`${PREFIX}.layers.18`,wide[18].mixer,mixedWideNarrow[18].mlp),new Attention(w,c,`${PREFIX}.layers.19`,wide[19].mixer,mixedWideNarrow[19].mlp),
      new Delta(w,c,`${PREFIX}.layers.20`,wide[20].mixer,mixedWideNarrow[20].mlp),new Delta(w,c,`${PREFIX}.layers.21`,wide[21].mixer,mixedWideNarrow[21].mlp),new Delta(w,c,`${PREFIX}.layers.22`,wide[22].mixer,mixedWideNarrow[22].mlp),new Attention(w,c,`${PREFIX}.layers.23`,wide[23].mixer,mixedWideNarrow[23].mlp),
      new Delta(w,c,`${PREFIX}.layers.24`,wide[24].mixer,mixedWideNarrow[24].mlp),new Delta(w,c,`${PREFIX}.layers.25`,wide[25].mixer,mixedWideNarrow[25].mlp),new Delta(w,c,`${PREFIX}.layers.26`,wide[26].mixer,mixedWideNarrow[26].mlp),new Attention(w,c,`${PREFIX}.layers.27`,wide[27].mixer,mixedWideNarrow[27].mlp),
      new Delta(w,c,`${PREFIX}.layers.28`,wide[28].mixer,mixedWideNarrow[28].mlp),new Delta(w,c,`${PREFIX}.layers.29`,wide[29].mixer,mixedWideNarrow[29].mlp),new Delta(w,c,`${PREFIX}.layers.30`,wide[30].mixer,mixedWideNarrow[30].mlp),new Attention(w,c,`${PREFIX}.layers.31`,wide[31].mixer,mixedWideNarrow[31].mlp),
      new Delta(w,c,`${PREFIX}.layers.32`,wide[32].mixer,mixedWideNarrow[32].mlp),new Delta(w,c,`${PREFIX}.layers.33`,wide[33].mixer,mixedWideNarrow[33].mlp),new Delta(w,c,`${PREFIX}.layers.34`,wide[34].mixer,mixedWideNarrow[34].mlp),new Attention(w,c,`${PREFIX}.layers.35`,wide[35].mixer,mixedWideNarrow[35].mlp),
      new Delta(w,c,`${PREFIX}.layers.36`,wide[36].mixer,mixedWideNarrow[36].mlp),new Delta(w,c,`${PREFIX}.layers.37`,wide[37].mixer,mixedWideNarrow[37].mlp),new Delta(w,c,`${PREFIX}.layers.38`,wide[38].mixer,mixedWideNarrow[38].mlp),new Attention(w,c,`${PREFIX}.layers.39`,wide[39].mixer,mixedWideNarrow[39].mlp),
      new Delta(w,c,`${PREFIX}.layers.40`,wide[40].mixer,mixedWideNarrow[40].mlp),new Delta(w,c,`${PREFIX}.layers.41`,wide[41].mixer,mixedWideNarrow[41].mlp),new Delta(w,c,`${PREFIX}.layers.42`,wide[42].mixer,mixedWideNarrow[42].mlp),new Attention(w,c,`${PREFIX}.layers.43`,wide[43].mixer,mixedWideNarrow[43].mlp),
      new Delta(w,c,`${PREFIX}.layers.44`,wide[44].mixer,mixedWideNarrow[44].mlp),new Delta(w,c,`${PREFIX}.layers.45`,wide[45].mixer,mixedWideNarrow[45].mlp),new Delta(w,c,`${PREFIX}.layers.46`,wide[46].mixer,mixedWideNarrow[46].mlp),new Attention(w,c,`${PREFIX}.layers.47`,wide[47].mixer,mixedWideNarrow[47].mlp),
      new Delta(w,c,`${PREFIX}.layers.48`,wide[48].mixer,mixedWideNarrow[48].mlp),new Delta(w,c,`${PREFIX}.layers.49`,wide[49].mixer,mixedWideNarrow[49].mlp),new Delta(w,c,`${PREFIX}.layers.50`,wide[50].mixer,mixedWideNarrow[50].mlp),new Attention(w,c,`${PREFIX}.layers.51`,wide[51].mixer,mixedWideNarrow[51].mlp),
      new Delta(w,c,`${PREFIX}.layers.52`,wide[52].mixer,mixedWideNarrow[52].mlp),new Delta(w,c,`${PREFIX}.layers.53`,wide[53].mixer,mixedWideNarrow[53].mlp),new Delta(w,c,`${PREFIX}.layers.54`,wide[54].mixer,mixedWideNarrow[54].mlp),new Attention(w,c,`${PREFIX}.layers.55`,wide[55].mixer,mixedWideNarrow[55].mlp),
      new Delta(w,c,`${PREFIX}.layers.56`,wide[56].mixer,mixedWideNarrow[56].mlp),new Delta(w,c,`${PREFIX}.layers.57`,wide[57].mixer,mixedWideNarrow[57].mlp),new Delta(w,c,`${PREFIX}.layers.58`,wide[58].mixer,mixedWideNarrow[58].mlp),new Attention(w,c,`${PREFIX}.layers.59`,wide[59].mixer,mixedWideNarrow[59].mlp),
      new Delta(w,c,`${PREFIX}.layers.60`,wide[60].mixer,mixedWideNarrow[60].mlp),new Delta(w,c,`${PREFIX}.layers.61`,wide[61].mixer,mixedWideNarrow[61].mlp),new Delta(w,c,`${PREFIX}.layers.62`,wide[62].mixer,mixedWideNarrow[62].mlp),new Attention(w,c,`${PREFIX}.layers.63`,wide[63].mixer,mixedWideNarrow[63].mlp),
    ];
    const chunkFive:Layers=[
      new Delta(w,c,`${PREFIX}.layers.0`,wide[0].mixer,mixedWideFive[0].mlp),new Delta(w,c,`${PREFIX}.layers.1`,wide[1].mixer,mixedWideFive[1].mlp),new Delta(w,c,`${PREFIX}.layers.2`,wide[2].mixer,mixedWideFive[2].mlp),new Attention(w,c,`${PREFIX}.layers.3`,wide[3].mixer,mixedWideFive[3].mlp),
      new Delta(w,c,`${PREFIX}.layers.4`,wide[4].mixer,mixedWideFive[4].mlp),new Delta(w,c,`${PREFIX}.layers.5`,wide[5].mixer,mixedWideFive[5].mlp),new Delta(w,c,`${PREFIX}.layers.6`,wide[6].mixer,mixedWideFive[6].mlp),new Attention(w,c,`${PREFIX}.layers.7`,wide[7].mixer,mixedWideFive[7].mlp),
      new Delta(w,c,`${PREFIX}.layers.8`,wide[8].mixer,mixedWideFive[8].mlp),new Delta(w,c,`${PREFIX}.layers.9`,wide[9].mixer,mixedWideFive[9].mlp),new Delta(w,c,`${PREFIX}.layers.10`,wide[10].mixer,mixedWideFive[10].mlp),new Attention(w,c,`${PREFIX}.layers.11`,wide[11].mixer,mixedWideFive[11].mlp),
      new Delta(w,c,`${PREFIX}.layers.12`,wide[12].mixer,mixedWideFive[12].mlp),new Delta(w,c,`${PREFIX}.layers.13`,wide[13].mixer,mixedWideFive[13].mlp),new Delta(w,c,`${PREFIX}.layers.14`,wide[14].mixer,mixedWideFive[14].mlp),new Attention(w,c,`${PREFIX}.layers.15`,wide[15].mixer,mixedWideFive[15].mlp),
      new Delta(w,c,`${PREFIX}.layers.16`,wide[16].mixer,mixedWideFive[16].mlp),new Delta(w,c,`${PREFIX}.layers.17`,wide[17].mixer,mixedWideFive[17].mlp),new Delta(w,c,`${PREFIX}.layers.18`,wide[18].mixer,mixedWideFive[18].mlp),new Attention(w,c,`${PREFIX}.layers.19`,wide[19].mixer,mixedWideFive[19].mlp),
      new Delta(w,c,`${PREFIX}.layers.20`,wide[20].mixer,mixedWideFive[20].mlp),new Delta(w,c,`${PREFIX}.layers.21`,wide[21].mixer,mixedWideFive[21].mlp),new Delta(w,c,`${PREFIX}.layers.22`,wide[22].mixer,mixedWideFive[22].mlp),new Attention(w,c,`${PREFIX}.layers.23`,wide[23].mixer,mixedWideFive[23].mlp),
      new Delta(w,c,`${PREFIX}.layers.24`,wide[24].mixer,mixedWideFive[24].mlp),new Delta(w,c,`${PREFIX}.layers.25`,wide[25].mixer,mixedWideFive[25].mlp),new Delta(w,c,`${PREFIX}.layers.26`,wide[26].mixer,mixedWideFive[26].mlp),new Attention(w,c,`${PREFIX}.layers.27`,wide[27].mixer,mixedWideFive[27].mlp),
      new Delta(w,c,`${PREFIX}.layers.28`,wide[28].mixer,mixedWideFive[28].mlp),new Delta(w,c,`${PREFIX}.layers.29`,wide[29].mixer,mixedWideFive[29].mlp),new Delta(w,c,`${PREFIX}.layers.30`,wide[30].mixer,mixedWideFive[30].mlp),new Attention(w,c,`${PREFIX}.layers.31`,wide[31].mixer,mixedWideFive[31].mlp),
      new Delta(w,c,`${PREFIX}.layers.32`,wide[32].mixer,mixedWideFive[32].mlp),new Delta(w,c,`${PREFIX}.layers.33`,wide[33].mixer,mixedWideFive[33].mlp),new Delta(w,c,`${PREFIX}.layers.34`,wide[34].mixer,mixedWideFive[34].mlp),new Attention(w,c,`${PREFIX}.layers.35`,wide[35].mixer,mixedWideFive[35].mlp),
      new Delta(w,c,`${PREFIX}.layers.36`,wide[36].mixer,mixedWideFive[36].mlp),new Delta(w,c,`${PREFIX}.layers.37`,wide[37].mixer,mixedWideFive[37].mlp),new Delta(w,c,`${PREFIX}.layers.38`,wide[38].mixer,mixedWideFive[38].mlp),new Attention(w,c,`${PREFIX}.layers.39`,wide[39].mixer,mixedWideFive[39].mlp),
      new Delta(w,c,`${PREFIX}.layers.40`,wide[40].mixer,mixedWideFive[40].mlp),new Delta(w,c,`${PREFIX}.layers.41`,wide[41].mixer,mixedWideFive[41].mlp),new Delta(w,c,`${PREFIX}.layers.42`,wide[42].mixer,mixedWideFive[42].mlp),new Attention(w,c,`${PREFIX}.layers.43`,wide[43].mixer,mixedWideFive[43].mlp),
      new Delta(w,c,`${PREFIX}.layers.44`,wide[44].mixer,mixedWideFive[44].mlp),new Delta(w,c,`${PREFIX}.layers.45`,wide[45].mixer,mixedWideFive[45].mlp),new Delta(w,c,`${PREFIX}.layers.46`,wide[46].mixer,mixedWideFive[46].mlp),new Attention(w,c,`${PREFIX}.layers.47`,wide[47].mixer,mixedWideFive[47].mlp),
      new Delta(w,c,`${PREFIX}.layers.48`,wide[48].mixer,mixedWideFive[48].mlp),new Delta(w,c,`${PREFIX}.layers.49`,wide[49].mixer,mixedWideFive[49].mlp),new Delta(w,c,`${PREFIX}.layers.50`,wide[50].mixer,mixedWideFive[50].mlp),new Attention(w,c,`${PREFIX}.layers.51`,wide[51].mixer,mixedWideFive[51].mlp),
      new Delta(w,c,`${PREFIX}.layers.52`,wide[52].mixer,mixedWideFive[52].mlp),new Delta(w,c,`${PREFIX}.layers.53`,wide[53].mixer,mixedWideFive[53].mlp),new Delta(w,c,`${PREFIX}.layers.54`,wide[54].mixer,mixedWideFive[54].mlp),new Attention(w,c,`${PREFIX}.layers.55`,wide[55].mixer,mixedWideFive[55].mlp),
      new Delta(w,c,`${PREFIX}.layers.56`,wide[56].mixer,mixedWideFive[56].mlp),new Delta(w,c,`${PREFIX}.layers.57`,wide[57].mixer,mixedWideFive[57].mlp),new Delta(w,c,`${PREFIX}.layers.58`,wide[58].mixer,mixedWideFive[58].mlp),new Attention(w,c,`${PREFIX}.layers.59`,wide[59].mixer,mixedWideFive[59].mlp),
      new Delta(w,c,`${PREFIX}.layers.60`,wide[60].mixer,mixedWideFive[60].mlp),new Delta(w,c,`${PREFIX}.layers.61`,wide[61].mixer,mixedWideFive[61].mlp),new Delta(w,c,`${PREFIX}.layers.62`,wide[62].mixer,mixedWideFive[62].mlp),new Attention(w,c,`${PREFIX}.layers.63`,wide[63].mixer,mixedWideFive[63].mlp),
    ];
    const one=this.#one,rows=this.#rows;
    const bindings:LayerWeights=[d0,d1,d2,a3,d4,d5,d6,a7,d8,d9,d10,a11,d12,d13,d14,a15,d16,d17,d18,a19,d20,d21,d22,a23,d24,d25,d26,a27,d28,d29,d30,a31,d32,d33,d34,a35,d36,d37,d38,a39,d40,d41,d42,a43,d44,d45,d46,a47,d48,d49,d50,a51,d52,d53,d54,a55,d56,d57,d58,a59,d60,d61,d62,a63];
    const shares=new AneWeightShares();
    this.#owned.push({dispose:()=>shares[Symbol.dispose]()});
    const ane2048=this.#aneAffine(w,c,bindings,qk,shares,.382,2048),ane1792=this.#aneAffine(w,c,bindings,qk,shares,.382,1792),ane1536=this.#aneAffine(w,c,bindings,qk,shares,.382,1536);
    const ane1280=this.#aneAffine(w,c,bindings,qk,shares,.382,1280),ane1024=this.#aneAffine(w,c,bindings,qk,shares,.382,1024),ane896=this.#aneAffine(w,c,bindings,qk,shares,.382,896),ane768=this.#aneAffine(w,c,bindings,qk,shares,.353,768);
    const ane704=this.#aneDense(w,c,bindings,qk,shares,.353,704),ane640=this.#aneDense(w,c,bindings,qk,shares,.353,640),ane576=this.#aneDense(w,c,bindings,qk,shares,.353,576);
    const ane512=this.#aneSmall(w,c,bindings,qk,shares,.353,512),ane448=this.#aneSmall(w,c,bindings,qk,shares,.353,448),ane384=this.#aneSmall(w,c,bindings,qk,shares,.353,384),ane320=this.#aneSmall(w,c,bindings,qk,shares,.353,320),ane256=this.#aneSmall(w,c,bindings,qk,shares,.353,256);
    const aneRanges:readonly MlxPromptRange[]=[
      {from:224,to:256,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane256,ids,cache,capture)},
      {from:257,to:320,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane320,ids,cache,capture)},
      {from:321,to:384,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane384,ids,cache,capture)},
      {from:385,to:448,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane448,ids,cache,capture)},
      {from:449,to:512,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane512,ids,cache,capture)},
      {from:513,to:576,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane576,ids,cache,capture)},
      {from:577,to:640,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane640,ids,cache,capture)},
      {from:641,to:704,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane704,ids,cache,capture)},
      {from:705,to:768,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane768,ids,cache,capture)},
      {from:769,to:896,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane896,ids,cache,capture)},
      {from:897,to:1024,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane1024,ids,cache,capture)},
      {from:1025,to:1280,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane1280,ids,cache,capture)},
      {from:1281,to:1536,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane1536,ids,cache,capture)},
      {from:1537,to:1792,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane1792,ids,cache,capture)},
      {from:1793,to:2048,unit:"ane",operation:(ids,cache,capture)=>this.#queued(ane2048,ids,cache,capture)},
    ];
    const D1:RowsForward=(ids,cache,capture)=>this.#submitted(one,ids,cache,"decode",capture);
    const D23:RowsForward=(ids,cache,capture)=>this.#submitted(rows,ids,cache,"decode",capture);
    const D4:RowsForward=(ids,cache,capture)=>this.#submitted(mma,ids,cache,"decode",capture);
    const D58:RowsForward=(ids,cache,capture)=>this.#submitted(mmaFive,ids,cache,"decode",capture);
    const DW:RowsForward=(ids,cache,capture)=>this.#submitted(wide,ids,cache,"decode",capture);
    const decodeExpanded:RowsForward=(ids,cache,capture)=>this.#lazy(expanded,ids,cache,"decode",capture);
    this.decode=Object.freeze({
      1:D1,2:D23,3:D23,4:D4,5:D58,6:D58,7:D58,8:D58,9:DW,10:DW,11:DW,12:DW,13:DW,14:DW,15:DW,16:DW,
      17:DW,18:DW,19:DW,20:DW,21:DW,22:DW,23:DW,24:DW,25:DW,26:DW,27:DW,28:DW,29:DW,30:DW,31:DW,32:DW,
      33:DW,34:DW,35:DW,36:DW,37:DW,38:DW,39:DW,40:DW,41:DW,42:DW,43:DW,44:DW,45:DW,46:DW,47:DW,48:DW,
      49:DW,50:DW,51:DW,52:DW,53:DW,54:DW,55:DW,56:DW,57:DW,58:DW,59:DW,60:DW,61:DW,62:DW,63:DW,64:DW,
      65:DW,66:DW,67:DW,68:DW,69:DW,70:DW,71:DW,72:DW,73:DW,74:DW,75:DW,76:DW,77:DW,78:DW,79:DW,80:DW,
      81:DW,82:DW,83:DW,84:DW,85:DW,86:DW,87:DW,88:DW,89:DW,90:DW,91:DW,92:DW,93:DW,94:DW,95:DW,96:DW,
      97:DW,98:DW,99:DW,100:DW,101:DW,102:DW,103:DW,104:DW,105:DW,106:DW,107:DW,108:DW,109:DW,110:DW,111:DW,112:DW,
      113:DW,114:DW,115:DW,116:DW,117:DW,118:DW,119:DW,120:DW,121:DW,122:DW,123:DW,124:DW,125:DW,126:DW,127:DW,128:DW,
      129:DW,130:DW,131:DW,132:DW,133:DW,134:DW,135:DW,136:DW,137:DW,138:DW,139:DW,140:DW,141:DW,142:DW,143:DW,144:DW,
      145:DW,146:DW,147:DW,148:DW,149:DW,150:DW,151:DW,152:DW,153:DW,154:DW,155:DW,156:DW,157:DW,158:DW,159:DW,160:DW,
      161:DW,162:DW,163:DW,164:DW,165:DW,166:DW,167:DW,168:DW,169:DW,170:DW,171:DW,172:DW,173:DW,174:DW,175:DW,176:DW,
      177:DW,178:DW,179:DW,180:DW,181:DW,182:DW,183:DW,184:DW,185:DW,186:DW,187:DW,188:DW,189:DW,190:DW,191:DW,192:DW,
      193:DW,194:DW,195:DW,196:DW,197:DW,198:DW,199:DW,200:DW,201:DW,202:DW,203:DW,204:DW,205:DW,206:DW,207:DW,208:DW,
      209:DW,210:DW,211:DW,212:DW,213:DW,214:DW,215:DW,216:DW,217:DW,218:DW,219:DW,220:DW,221:DW,222:DW,223:DW,224:DW,
      225:DW,226:DW,227:DW,228:DW,229:DW,230:DW,231:DW,232:DW,233:DW,234:DW,235:DW,236:DW,237:DW,238:DW,239:DW,240:DW,
      241:DW,242:DW,243:DW,244:DW,245:DW,246:DW,247:DW,248:DW,249:DW,250:DW,251:DW,252:DW,253:DW,254:DW,255:DW,256:DW,

      default: decodeExpanded,
    });
    const V1:RowsForward=(ids,cache,capture)=>this.#submitted(one,ids,cache,"window",capture);
    const V23:RowsForward=(ids,cache,capture)=>this.#submitted(rows,ids,cache,"window",capture);
    const V4:RowsForward=(ids,cache,capture)=>this.#submitted(mma,ids,cache,"window",capture);
    const V58:RowsForward=(ids,cache,capture)=>this.#submitted(mmaFive,ids,cache,"window",capture);
    const chunkNarrowWindow:RowsForward=(ids,cache,capture)=>this.#submitted(chunkNarrow,ids,cache,"window",capture);
    const chunkFiveWindow:RowsForward=(ids,cache,capture)=>this.#submitted(chunkFive,ids,cache,"window",capture);
    const VW:RowsForward=(ids,cache,capture)=>this.#submitted(wide,ids,cache,"window",capture);
    const windowExpanded:RowsForward=(ids,cache,capture)=>this.#lazy(expanded,ids,cache,"window",capture);
    this.verify=Object.freeze({
      1:V1,2:V23,3:V23,4:V4,5:V58,6:V58,7:V58,8:V58,9:VW,10:VW,11:VW,12:VW,13:VW,14:VW,15:VW,16:VW,
      17:VW,18:VW,19:VW,20:VW,21:VW,22:VW,23:VW,24:VW,25:VW,26:VW,27:VW,28:VW,29:VW,30:VW,31:VW,32:VW,
      33:VW,34:VW,35:VW,36:VW,37:VW,38:VW,39:VW,40:VW,41:VW,42:VW,43:VW,44:VW,45:VW,46:VW,47:VW,48:VW,
      49:VW,50:VW,51:VW,52:VW,53:VW,54:VW,55:VW,56:VW,57:VW,58:VW,59:VW,60:VW,61:VW,62:VW,63:VW,64:VW,
      65:VW,66:VW,67:VW,68:VW,69:VW,70:VW,71:VW,72:VW,73:VW,74:VW,75:VW,76:VW,77:VW,78:VW,79:VW,80:VW,
      81:VW,82:VW,83:VW,84:VW,85:VW,86:VW,87:VW,88:VW,89:VW,90:VW,91:VW,92:VW,93:VW,94:VW,95:VW,96:VW,
      97:VW,98:VW,99:VW,100:VW,101:VW,102:VW,103:VW,104:VW,105:VW,106:VW,107:VW,108:VW,109:VW,110:VW,111:VW,112:VW,
      113:VW,114:VW,115:VW,116:VW,117:VW,118:VW,119:VW,120:VW,121:VW,122:VW,123:VW,124:VW,125:VW,126:VW,127:VW,128:VW,
      129:VW,130:VW,131:VW,132:VW,133:VW,134:VW,135:VW,136:VW,137:VW,138:VW,139:VW,140:VW,141:VW,142:VW,143:VW,144:VW,
      145:VW,146:VW,147:VW,148:VW,149:VW,150:VW,151:VW,152:VW,153:VW,154:VW,155:VW,156:VW,157:VW,158:VW,159:VW,160:VW,
      161:VW,162:VW,163:VW,164:VW,165:VW,166:VW,167:VW,168:VW,169:VW,170:VW,171:VW,172:VW,173:VW,174:VW,175:VW,176:VW,
      177:VW,178:VW,179:VW,180:VW,181:VW,182:VW,183:VW,184:VW,185:VW,186:VW,187:VW,188:VW,189:VW,190:VW,191:VW,192:VW,
      193:VW,194:VW,195:VW,196:VW,197:VW,198:VW,199:VW,200:VW,201:VW,202:VW,203:VW,204:VW,205:VW,206:VW,207:VW,208:VW,
      209:VW,210:VW,211:VW,212:VW,213:VW,214:VW,215:VW,216:VW,217:VW,218:VW,219:VW,220:VW,221:VW,222:VW,223:VW,224:VW,
      225:VW,226:VW,227:VW,228:VW,229:VW,230:VW,231:VW,232:VW,233:VW,234:VW,235:VW,236:VW,237:VW,238:VW,239:VW,240:VW,
      241:VW,242:VW,243:VW,244:VW,245:VW,246:VW,247:VW,248:VW,249:VW,250:VW,251:VW,252:VW,253:VW,254:VW,255:VW,256:VW,

      default: windowExpanded,
    });
    this.appendKnown=[
      {from:1,to:1,operation:(ids,cache)=>this.#lazy(one,ids,cache,"window",null)},
      {from:2,to:3,operation:(ids,cache)=>this.#lazy(rows,ids,cache,"window",null)},
      {from:4,to:4,operation:(ids,cache)=>this.#lazy(mma,ids,cache,"window",null)},
      {from:5,to:8,operation:(ids,cache)=>this.#lazy(mmaFive,ids,cache,"window",null)},
      {from:9,to:256,operation:(ids,cache)=>this.#lazy(wide,ids,cache,"window",null)},
      {from:257,to:Infinity,operation:(ids,cache)=>this.#lazy(expanded,ids,cache,"window",null)},
    ];
    const rowHead=new AffineRow(this.lmHead),rowsHead=new Affine4(this.lmHead),mmaHead=new AffineMma(this.lmHead);
    const H1:MlxHeadForward=hidden=>rowHead.forward(hidden),H23:MlxHeadForward=hidden=>rowsHead.forward(hidden),HW:MlxHeadForward=hidden=>mmaHead.forward(hidden);
    const head:MlxHeadForward=hidden=>this.#head.forward(hidden);
    this.logits=Object.freeze({
      1:H1,2:H23,3:H23,4:HW,5:HW,6:HW,7:HW,8:HW,9:HW,10:HW,11:HW,12:HW,13:HW,14:HW,15:HW,16:HW,
      17:HW,18:HW,19:HW,20:HW,21:HW,22:HW,23:HW,24:HW,25:HW,26:HW,27:HW,28:HW,29:HW,30:HW,31:HW,32:HW,
      33:HW,34:HW,35:HW,36:HW,37:HW,38:HW,39:HW,40:HW,41:HW,42:HW,43:HW,44:HW,45:HW,46:HW,47:HW,48:HW,
      49:HW,50:HW,51:HW,52:HW,53:HW,54:HW,55:HW,56:HW,57:HW,58:HW,59:HW,60:HW,61:HW,62:HW,63:HW,64:HW,
      65:HW,66:HW,67:HW,68:HW,69:HW,70:HW,71:HW,72:HW,73:HW,74:HW,75:HW,76:HW,77:HW,78:HW,79:HW,80:HW,
      81:HW,82:HW,83:HW,84:HW,85:HW,86:HW,87:HW,88:HW,89:HW,90:HW,91:HW,92:HW,93:HW,94:HW,95:HW,96:HW,
      97:HW,98:HW,99:HW,100:HW,101:HW,102:HW,103:HW,104:HW,105:HW,106:HW,107:HW,108:HW,109:HW,110:HW,111:HW,112:HW,
      113:HW,114:HW,115:HW,116:HW,117:HW,118:HW,119:HW,120:HW,121:HW,122:HW,123:HW,124:HW,125:HW,126:HW,127:HW,128:HW,
      129:HW,130:HW,131:HW,132:HW,133:HW,134:HW,135:HW,136:HW,137:HW,138:HW,139:HW,140:HW,141:HW,142:HW,143:HW,144:HW,
      145:HW,146:HW,147:HW,148:HW,149:HW,150:HW,151:HW,152:HW,153:HW,154:HW,155:HW,156:HW,157:HW,158:HW,159:HW,160:HW,
      161:HW,162:HW,163:HW,164:HW,165:HW,166:HW,167:HW,168:HW,169:HW,170:HW,171:HW,172:HW,173:HW,174:HW,175:HW,176:HW,
      177:HW,178:HW,179:HW,180:HW,181:HW,182:HW,183:HW,184:HW,185:HW,186:HW,187:HW,188:HW,189:HW,190:HW,191:HW,192:HW,
      193:HW,194:HW,195:HW,196:HW,197:HW,198:HW,199:HW,200:HW,201:HW,202:HW,203:HW,204:HW,205:HW,206:HW,207:HW,208:HW,
      209:HW,210:HW,211:HW,212:HW,213:HW,214:HW,215:HW,216:HW,217:HW,218:HW,219:HW,220:HW,221:HW,222:HW,223:HW,224:HW,
      225:HW,226:HW,227:HW,228:HW,229:HW,230:HW,231:HW,232:HW,233:HW,234:HW,235:HW,236:HW,237:HW,238:HW,239:HW,240:HW,
      241:HW,242:HW,243:HW,244:HW,245:HW,246:HW,247:HW,248:HW,249:HW,250:HW,251:HW,252:HW,253:HW,254:HW,255:HW,256:HW,

      default: head,
    });
    const promptSmall:RowsForward=(ids,cache,capture)=>this.#bounded(prompt512,ids,cache,"window",capture);
    const promptLarge:RowsForward=(ids,cache,capture)=>this.#bounded(promptDense,ids,cache,"window",capture);
    const gpuTail:readonly MlxPromptRange[]=[{from:1,to:1,operation:V1},{from:2,to:3,operation:V23},{from:4,to:4,operation:V4},{from:5,to:8,operation:V58},{from:9,to:256,operation:VW},{from:257,to:512,operation:promptSmall},{from:513,to:Infinity,operation:promptLarge}];
    this.multiSequencePrompt=gpuTail;
    this.multiSequencePromptChunk=[{from:1,to:4,operation:chunkNarrowWindow},{from:5,to:8,operation:chunkFiveWindow},{from:9,to:256,operation:VW},{from:257,to:512,operation:promptSmall},{from:513,to:Infinity,operation:promptLarge}];
    this.prompt=[{from:1,to:1,operation:V1,unit:"gpu"},{from:2,to:3,operation:V23,unit:"gpu"},{from:4,to:4,operation:V4,unit:"gpu"},{from:5,to:8,operation:V58,unit:"gpu"},{from:9,to:223,operation:VW,unit:"gpu"},...aneRanges,{from:2049,to:Infinity,operation:promptLarge,unit:"gpu"}];
    this.promptChunk=[{from:1,to:4,operation:chunkNarrowWindow,unit:"gpu"},{from:5,to:8,operation:chunkFiveWindow,unit:"gpu"},{from:9,to:223,operation:VW,unit:"gpu"},...aneRanges,{from:2049,to:Infinity,operation:promptLarge,unit:"gpu"}];
    this.sequence=[{from:1,to:1,operation:(ids,cache)=>V1(ids,cache,null)},{from:2,to:3,operation:(ids,cache)=>V23(ids,cache,null)},
      {from:4,to:4,operation:(ids,cache)=>V4(ids,cache,null)},{from:5,to:8,operation:(ids,cache)=>V58(ids,cache,null)},{from:9,to:256,operation:(ids,cache)=>VW(ids,cache,null)},
      {from:257,to:512,operation:(ids,cache)=>promptSmall(ids,cache,null)},{from:513,to:Infinity,operation:(ids,cache)=>promptLarge(ids,cache,null)}];
    this.mediaPrefill=[
      {from:1,to:4,operation:(hidden,cache,positions)=>this.#positioned(mediaStock,ops.contiguous(hidden),cache,"window",positions)},
      {from:5,to:8,operation:(hidden,cache,positions)=>this.#positionedBounded(mediaFive,ops.contiguous(hidden),cache,positions)},
      {from:9,to:32,operation:(hidden,cache,positions)=>this.#positionedBounded(mediaTiled,ops.contiguous(hidden),cache,positions)},
      {from:33,to:Infinity,operation:(hidden,cache,positions)=>this.#positionedBounded(mediaExpanded,ops.contiguous(hidden),cache,positions)},
    ];
    this.mediaPrompt=[
      {from:1,to:4,operation:(ids,cache,positions)=>this.#positioned(mediaStock,this.embed.encode(ids),cache,"window",positions)},
      {from:5,to:8,operation:(ids,cache,positions)=>this.#positionedBounded(mediaFive,this.embed.encode(ids),cache,positions)},
      {from:9,to:32,operation:(ids,cache,positions)=>this.#positionedBounded(mediaTiled,this.embed.encode(ids),cache,positions)},
      {from:33,to:Infinity,operation:(ids,cache,positions)=>this.#positionedBounded(mediaExpanded,this.embed.encode(ids),cache,positions)},
    ];
    const mediaDecodeNarrow:MlxPositionedForward=(ids,cache,positions)=>this.#positioned(mediaStock,this.embed.encode(ids),cache,"decode",positions);
    const mediaDecodeFive:MlxPositionedForward=(ids,cache,positions)=>this.#positioned(mediaFive,this.embed.encode(ids),cache,"decode",positions);
    const mediaDecodeTiled:MlxPositionedForward=(ids,cache,positions)=>this.#positioned(mediaTiled,this.embed.encode(ids),cache,"decode",positions);
    const mediaDecodeExpanded:MlxPositionedForward=(ids,cache,positions)=>this.#positioned(mediaExpanded,this.embed.encode(ids),cache,"decode",positions);
    this.mediaDecode=Object.freeze({
      1:mediaDecodeNarrow,2:mediaDecodeNarrow,3:mediaDecodeNarrow,4:mediaDecodeNarrow,5:mediaDecodeFive,6:mediaDecodeFive,7:mediaDecodeFive,8:mediaDecodeFive,
      9:mediaDecodeTiled,10:mediaDecodeTiled,11:mediaDecodeTiled,12:mediaDecodeTiled,13:mediaDecodeTiled,14:mediaDecodeTiled,15:mediaDecodeTiled,16:mediaDecodeTiled,
      17:mediaDecodeTiled,18:mediaDecodeTiled,19:mediaDecodeTiled,20:mediaDecodeTiled,21:mediaDecodeTiled,22:mediaDecodeTiled,23:mediaDecodeTiled,24:mediaDecodeTiled,
      25:mediaDecodeTiled,26:mediaDecodeTiled,27:mediaDecodeTiled,28:mediaDecodeTiled,29:mediaDecodeTiled,30:mediaDecodeTiled,31:mediaDecodeTiled,32:mediaDecodeTiled,

      default: mediaDecodeExpanded,
    });
    this.embeddingPrompt=[
      {from:1,to:1,operation:(hidden,cache)=>this.#embeddingSubmitted(one,hidden,cache)},
      {from:2,to:3,operation:(hidden,cache)=>this.#embeddingSubmitted(rows,hidden,cache)},
      {from:4,to:4,operation:(hidden,cache)=>this.#embeddingSubmitted(mma,hidden,cache)},
      {from:5,to:8,operation:(hidden,cache)=>this.#embeddingSubmitted(mmaFive,hidden,cache)},
      {from:9,to:32,operation:(hidden,cache)=>this.#embeddingBounded(tiled,hidden,cache)},
      {from:33,to:Infinity,operation:(hidden,cache)=>this.#embeddingBounded(expanded,hidden,cache)},
    ];
    this.mixed=[{from:1,to:4,operation:groups=>this.#packed(stock,groups)},
      {from:5,to:8,operation:groups=>this.#packed(five,groups)},
      {from:9,to:256,operation:groups=>this.#packed(mixedWide,groups)},
      {from:257,to:Infinity,operation:groups=>this.#packed(expanded,groups)}];
    const separateWindow:readonly MlxMixedGroupRange[]=[
      {from:1,to:4,operation:group=>this.#lazy(stock,group.ids,group.state,"window",group.capture)},
      {from:5,to:8,operation:group=>this.#bounded(five,group.ids,group.state,"window",group.capture)},
      {from:9,to:256,operation:group=>this.#bounded(mixedWide,group.ids,group.state,"window",group.capture)},
      {from:257,to:Infinity,operation:group=>this.#bounded(expanded,group.ids,group.state,"window",group.capture)},
    ];
    this.mixedSeparate={decode:[
      {from:1,to:4,operation:group=>this.#lazy(stock,group.ids,group.state,"decode",group.capture)},
      {from:5,to:8,operation:group=>this.#lazy(five,group.ids,group.state,"decode",group.capture)},
      {from:9,to:256,operation:group=>this.#lazy(mixedWide,group.ids,group.state,"decode",group.capture)},
      {from:257,to:Infinity,operation:group=>decodeExpanded(group.ids,group.state,group.capture)},
    ],window:separateWindow,verify:[
      {from:1,to:4,operation:group=>this.#lazy(stock,group.ids,group.state,"window",group.capture)},
      {from:5,to:8,operation:group=>this.#lazy(five,group.ids,group.state,"window",group.capture)},
      {from:9,to:256,operation:group=>this.#lazy(mixedWide,group.ids,group.state,"window",group.capture)},
      {from:257,to:Infinity,operation:group=>windowExpanded(group.ids,group.state,group.capture)},
    ],packed:[
      {from:1,to:4,totalTo:4,operation:groups=>this.#packed(stock,groups)},
      {from:1,to:4,totalFrom:5,totalTo:8,operation:groups=>this.#packed(mixedUnfused,groups)},
      {from:5,to:8,totalTo:8,operation:groups=>this.#packed(five,groups)},
      {from:1,to:4,totalFrom:9,operation:groups=>this.#packed(mixedWideNarrow,groups)},
      {from:5,to:8,totalFrom:9,operation:groups=>this.#packed(mixedWideFive,groups)},
      {from:9,to:256,totalFrom:9,operation:groups=>this.#packed(mixedWide,groups)},
      {from:257,to:Infinity,operation:groups=>this.#packed(expanded,groups)},
    ]};
    console.error(`[graph] ${this.graph}`);
  }

  dispose():void { disposeResources(this.#owned.splice(0)); }
  #aneSmall(w:Weights,c:ModelConfig,b:LayerWeights,qk:{q:MlxArray;k:MlxArray},shares:AneWeightShares,fraction:number,capacity:number):Layers {
    return [
      b[0].withProjections(w,c,Delta,new AneBoundMlp(b[0].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[1].withProjections(w,c,Delta,new AneBoundMlp(b[1].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[2].withProjections(w,c,Delta,new AneBoundMlp(b[2].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[3].withProjections(w,c,Attention,new AneBoundMlp(b[3].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[4].withProjections(w,c,Delta,new AneBoundMlp(b[4].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[5].withProjections(w,c,Delta,new AneBoundMlp(b[5].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[6].withProjections(w,c,Delta,new AneBoundMlp(b[6].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[7].withProjections(w,c,Attention,new AneBoundMlp(b[7].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[8].withProjections(w,c,Delta,new AneBoundMlp(b[8].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[9].withProjections(w,c,Delta,new AneBoundMlp(b[9].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[10].withProjections(w,c,Delta,new AneBoundMlp(b[10].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[11].withProjections(w,c,Attention,new AneBoundMlp(b[11].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[12].withProjections(w,c,Delta,new AneBoundMlp(b[12].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[13].withProjections(w,c,Delta,new AneBoundMlp(b[13].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[14].withProjections(w,c,Delta,new AneBoundMlp(b[14].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[15].withProjections(w,c,Attention,new AneBoundMlp(b[15].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[16].withProjections(w,c,Delta,new AneBoundMlp(b[16].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[17].withProjections(w,c,Delta,new AneBoundMlp(b[17].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[18].withProjections(w,c,Delta,new AneBoundMlp(b[18].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[19].withProjections(w,c,Attention,new AneBoundMlp(b[19].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[20].withProjections(w,c,Delta,new AneBoundMlp(b[20].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[21].withProjections(w,c,Delta,new AneBoundMlp(b[21].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[22].withProjections(w,c,Delta,new AneBoundMlp(b[22].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[23].withProjections(w,c,Attention,new AneBoundMlp(b[23].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[24].withProjections(w,c,Delta,new AneBoundMlp(b[24].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[25].withProjections(w,c,Delta,new AneBoundMlp(b[25].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[26].withProjections(w,c,Delta,new AneBoundMlp(b[26].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[27].withProjections(w,c,Attention,new AneBoundMlp(b[27].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[28].withProjections(w,c,Delta,new AneBoundMlp(b[28].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[29].withProjections(w,c,Delta,new AneBoundMlp(b[29].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[30].withProjections(w,c,Delta,new AneBoundMlp(b[30].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[31].withProjections(w,c,Attention,new AneBoundMlp(b[31].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[32].withProjections(w,c,Delta,new AneBoundMlp(b[32].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[33].withProjections(w,c,Delta,new AneBoundMlp(b[33].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[34].withProjections(w,c,Delta,new AneBoundMlp(b[34].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[35].withProjections(w,c,Attention,new AneBoundMlp(b[35].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[36].withProjections(w,c,Delta,new AneBoundMlp(b[36].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[37].withProjections(w,c,Delta,new AneBoundMlp(b[37].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[38].withProjections(w,c,Delta,new AneBoundMlp(b[38].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[39].withProjections(w,c,Attention,new AneBoundMlp(b[39].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[40].withProjections(w,c,Delta,new AneBoundMlp(b[40].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[41].withProjections(w,c,Delta,new AneBoundMlp(b[41].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[42].withProjections(w,c,Delta,new AneBoundMlp(b[42].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[43].withProjections(w,c,Attention,new AneBoundMlp(b[43].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[44].withProjections(w,c,Delta,new AneBoundMlp(b[44].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[45].withProjections(w,c,Delta,new AneBoundMlp(b[45].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[46].withProjections(w,c,Delta,new AneBoundMlp(b[46].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[47].withProjections(w,c,Attention,new AneBoundMlp(b[47].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[48].withProjections(w,c,Delta,new AneBoundMlp(b[48].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[49].withProjections(w,c,Delta,new AneBoundMlp(b[49].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[50].withProjections(w,c,Delta,new AneBoundMlp(b[50].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[51].withProjections(w,c,Attention,new AneBoundMlp(b[51].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[52].withProjections(w,c,Delta,new AneBoundMlp(b[52].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[53].withProjections(w,c,Delta,new AneBoundMlp(b[53].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[54].withProjections(w,c,Delta,new AneBoundMlp(b[54].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[55].withProjections(w,c,Attention,new AneBoundMlp(b[55].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[56].withProjections(w,c,Delta,new AneBoundMlp(b[56].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[57].withProjections(w,c,Delta,new AneBoundMlp(b[57].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[58].withProjections(w,c,Delta,new AneBoundMlp(b[58].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[59].withProjections(w,c,Attention,new AneBoundMlp(b[59].trellis,AneSplit,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
      b[60].withProjections(w,c,Delta,new AneBoundMlp(b[60].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[61].withProjections(w,c,Delta,new AneBoundMlp(b[61].trellis,AneSplit,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[62].withProjections(w,c,Delta,new AneBoundMlp(b[62].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Dense,Plain,Plain,Dense,qk),
      b[63].withProjections(w,c,Attention,new AneBoundMlp(b[63].trellis,AneSplitK3i,fraction,capacity,shares,4),Dense,Plain,Plain,Dense),
    ];
  }
  #aneDense(w:Weights,c:ModelConfig,b:LayerWeights,qk:{q:MlxArray;k:MlxArray},shares:AneWeightShares,fraction:number,capacity:number):Layers {
    const small=this.#aneSmall(w,c,b,qk,shares,fraction,capacity);
    return [
      small[0],small[1],small[2],b[3].withProjections(w,c,Attention,small[3].mlp,Dense,Dense,Dense,Dense),
      small[4],small[5],small[6],b[7].withProjections(w,c,Attention,small[7].mlp,Dense,Dense,Dense,Dense),
      small[8],small[9],small[10],b[11].withProjections(w,c,Attention,small[11].mlp,Dense,Dense,Dense,Dense),
      small[12],small[13],small[14],b[15].withProjections(w,c,Attention,small[15].mlp,Dense,Dense,Dense,Dense),
      small[16],small[17],small[18],b[19].withProjections(w,c,Attention,small[19].mlp,Dense,Dense,Dense,Dense),
      small[20],small[21],small[22],b[23].withProjections(w,c,Attention,small[23].mlp,Dense,Dense,Dense,Dense),
      small[24],small[25],small[26],b[27].withProjections(w,c,Attention,small[27].mlp,Dense,Dense,Dense,Dense),
      small[28],small[29],small[30],b[31].withProjections(w,c,Attention,small[31].mlp,Dense,Dense,Dense,Dense),
      small[32],small[33],small[34],b[35].withProjections(w,c,Attention,small[35].mlp,Dense,Dense,Dense,Dense),
      small[36],small[37],small[38],b[39].withProjections(w,c,Attention,small[39].mlp,Dense,Dense,Dense,Dense),
      small[40],small[41],small[42],b[43].withProjections(w,c,Attention,small[43].mlp,Dense,Dense,Dense,Dense),
      small[44],small[45],small[46],b[47].withProjections(w,c,Attention,small[47].mlp,Dense,Dense,Dense,Dense),
      small[48],small[49],small[50],b[51].withProjections(w,c,Attention,small[51].mlp,Dense,Dense,Dense,Dense),
      small[52],small[53],small[54],b[55].withProjections(w,c,Attention,small[55].mlp,Dense,Dense,Dense,Dense),
      small[56],small[57],small[58],b[59].withProjections(w,c,Attention,small[59].mlp,Dense,Dense,Dense,Dense),
      small[60],small[61],small[62],b[63].withProjections(w,c,Attention,small[63].mlp,Dense,Dense,Dense,Dense),
    ];
  }
  #aneAffine(w:Weights,c:ModelConfig,b:LayerWeights,qk:{q:MlxArray;k:MlxArray},shares:AneWeightShares,fraction:number,capacity:number):Layers {
    const dense=this.#aneDense(w,c,b,qk,shares,fraction,capacity);
    return [
      b[0].aneProjections(w,c,Delta,dense[0].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[1].aneProjections(w,c,Delta,dense[1].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[2].aneProjections(w,c,Delta,dense[2].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[3].aneProjections(w,c,Attention,dense[3].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[4].aneProjections(w,c,Delta,dense[4].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[5].aneProjections(w,c,Delta,dense[5].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[6].aneProjections(w,c,Delta,dense[6].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[7].aneProjections(w,c,Attention,dense[7].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[8].aneProjections(w,c,Delta,dense[8].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[9].aneProjections(w,c,Delta,dense[9].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[10].aneProjections(w,c,Delta,dense[10].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[11].aneProjections(w,c,Attention,dense[11].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[12].aneProjections(w,c,Delta,dense[12].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[13].aneProjections(w,c,Delta,dense[13].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[14].aneProjections(w,c,Delta,dense[14].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[15].aneProjections(w,c,Attention,dense[15].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[16].aneProjections(w,c,Delta,dense[16].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[17].aneProjections(w,c,Delta,dense[17].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[18].aneProjections(w,c,Delta,dense[18].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[19].aneProjections(w,c,Attention,dense[19].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[20].aneProjections(w,c,Delta,dense[20].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[21].aneProjections(w,c,Delta,dense[21].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[22].aneProjections(w,c,Delta,dense[22].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[23].aneProjections(w,c,Attention,dense[23].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[24].aneProjections(w,c,Delta,dense[24].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[25].aneProjections(w,c,Delta,dense[25].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[26].aneProjections(w,c,Delta,dense[26].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[27].aneProjections(w,c,Attention,dense[27].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[28].aneProjections(w,c,Delta,dense[28].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[29].aneProjections(w,c,Delta,dense[29].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[30].aneProjections(w,c,Delta,dense[30].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[31].aneProjections(w,c,Attention,dense[31].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[32].aneProjections(w,c,Delta,dense[32].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[33].aneProjections(w,c,Delta,dense[33].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[34].aneProjections(w,c,Delta,dense[34].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[35].aneProjections(w,c,Attention,dense[35].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[36].aneProjections(w,c,Delta,dense[36].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[37].aneProjections(w,c,Delta,dense[37].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[38].aneProjections(w,c,Delta,dense[38].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[39].aneProjections(w,c,Attention,dense[39].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[40].aneProjections(w,c,Delta,dense[40].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[41].aneProjections(w,c,Delta,dense[41].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[42].aneProjections(w,c,Delta,dense[42].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[43].aneProjections(w,c,Attention,dense[43].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[44].aneProjections(w,c,Delta,dense[44].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[45].aneProjections(w,c,Delta,dense[45].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[46].aneProjections(w,c,Delta,dense[46].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[47].aneProjections(w,c,Attention,dense[47].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[48].aneProjections(w,c,Delta,dense[48].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[49].aneProjections(w,c,Delta,dense[49].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[50].aneProjections(w,c,Delta,dense[50].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[51].aneProjections(w,c,Attention,dense[51].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[52].aneProjections(w,c,Delta,dense[52].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[53].aneProjections(w,c,Delta,dense[53].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[54].aneProjections(w,c,Delta,dense[54].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[55].aneProjections(w,c,Attention,dense[55].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[56].aneProjections(w,c,Delta,dense[56].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[57].aneProjections(w,c,Delta,dense[57].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[58].aneProjections(w,c,Delta,dense[58].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[59].aneProjections(w,c,Attention,dense[59].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
      b[60].aneProjections(w,c,Delta,dense[60].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[61].aneProjections(w,c,Delta,dense[61].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[62].aneProjections(w,c,Delta,dense[62].mlp,AneAffineSplit,Dense,Plain,capacity,shares,qk),b[63].aneProjections(w,c,Attention,dense[63].mlp,AneAffineSplit,Dense,Plain,capacity,shares),
    ];
  }
  loraTargets():Map<string,QwenProjectionTarget> { return new Map(this.#targets); }
  bindMediaInput(input:Vision):MlxPromptInput { return bindQwenMediaInput(this,input.embeddings,input.mrope!); }
  mediaEncoders(modelDir:string):Promise<MediaEncoders> { return qwenMediaEncoders(this,modelDir); }
  draftTarget(_state:Cache[]):TargetView { return qwenDraftTarget(this,this.#residualBasis,this.#draftProjections,this.#vocabulary); }
  logitsFromHidden(hidden:MlxArray):MlxArray { return this.#head.forward(hidden); }
  #lazy(layers:Layers,ids:MlxArray,state:Cache[],phase:ReadPhase,capture:MlxLayerCapture|null):MlxArray {
    using scope=new GraphForwardScope(this.embed.encode(ids),capture);
    return this.#run(layers,state,phase,scope);
  }
  #submitted(layers:Layers,ids:MlxArray,state:Cache[],phase:ReadPhase,capture:MlxLayerCapture|null):MlxArray {
    using scope=new SubmittedGraphForwardScope(this.embed.encode(ids),capture,64,4);
    return this.#run(layers,state,phase,scope);
  }
  #queued(layers:Layers,ids:MlxArray,state:Cache[],capture:MlxLayerCapture|null):MlxArray {
    using scope=new QueuedGraphForwardScope(this.embed.encode(ids),capture,state);
    return this.#run(layers,state,"window",scope);
  }
  #embeddingSubmitted(layers:Layers,hidden:MlxArray,state:Cache[]):MlxArray {
    using scope=new SubmittedGraphForwardScope(ops.contiguous(hidden),null,64,4);
    return this.#run(layers,state,"window",scope);
  }
  #embeddingBounded(layers:Layers,hidden:MlxArray,state:Cache[]):MlxArray {
    using scope=new BoundedGraphForwardScope(ops.contiguous(hidden),null,state);
    return this.#run(layers,state,"window",scope);
  }
  #bounded(layers:Layers,ids:MlxArray,state:Cache[],phase:ReadPhase,capture:MlxLayerCapture|null):MlxArray {
    using scope=new BoundedGraphForwardScope(this.embed.encode(ids),capture,state);
    return this.#run(layers,state,phase,scope);
  }
  #positioned(layers:Layers,hidden:MlxArray,state:Cache[],phase:ReadPhase,positions:MlxArray):MlxArray {
    using scope=new GraphForwardScope(hidden,null);
    return this.#run(layers,state,phase,scope,{posIds:positions,...this.#mrope});
  }
  #positionedBounded(layers:Layers,hidden:MlxArray,state:Cache[],positions:MlxArray):MlxArray {
    using scope=new BoundedGraphForwardScope(hidden,null,state);
    return this.#run(layers,state,"window",scope,{posIds:positions,...this.#mrope});
  }
  #run(layers:Layers,state:Cache[],phase:ReadPhase,scope:GraphForwardScope,positions:MropeForwardState|null=null):MlxArray {
    scope.accept(0,layers[0].forward(scope.hidden,state[0]!,phase));
    scope.accept(1,layers[1].forward(scope.hidden,state[1]!,phase));
    scope.accept(2,layers[2].forward(scope.hidden,state[2]!,phase));
    scope.accept(3,layers[3].forward(scope.hidden,state[3]!,phase,positions));
    scope.accept(4,layers[4].forward(scope.hidden,state[4]!,phase));
    scope.accept(5,layers[5].forward(scope.hidden,state[5]!,phase));
    scope.accept(6,layers[6].forward(scope.hidden,state[6]!,phase));
    scope.accept(7,layers[7].forward(scope.hidden,state[7]!,phase,positions));
    scope.accept(8,layers[8].forward(scope.hidden,state[8]!,phase));
    scope.accept(9,layers[9].forward(scope.hidden,state[9]!,phase));
    scope.accept(10,layers[10].forward(scope.hidden,state[10]!,phase));
    scope.accept(11,layers[11].forward(scope.hidden,state[11]!,phase,positions));
    scope.accept(12,layers[12].forward(scope.hidden,state[12]!,phase));
    scope.accept(13,layers[13].forward(scope.hidden,state[13]!,phase));
    scope.accept(14,layers[14].forward(scope.hidden,state[14]!,phase));
    scope.accept(15,layers[15].forward(scope.hidden,state[15]!,phase,positions));
    scope.accept(16,layers[16].forward(scope.hidden,state[16]!,phase));
    scope.accept(17,layers[17].forward(scope.hidden,state[17]!,phase));
    scope.accept(18,layers[18].forward(scope.hidden,state[18]!,phase));
    scope.accept(19,layers[19].forward(scope.hidden,state[19]!,phase,positions));
    scope.accept(20,layers[20].forward(scope.hidden,state[20]!,phase));
    scope.accept(21,layers[21].forward(scope.hidden,state[21]!,phase));
    scope.accept(22,layers[22].forward(scope.hidden,state[22]!,phase));
    scope.accept(23,layers[23].forward(scope.hidden,state[23]!,phase,positions));
    scope.accept(24,layers[24].forward(scope.hidden,state[24]!,phase));
    scope.accept(25,layers[25].forward(scope.hidden,state[25]!,phase));
    scope.accept(26,layers[26].forward(scope.hidden,state[26]!,phase));
    scope.accept(27,layers[27].forward(scope.hidden,state[27]!,phase,positions));
    scope.accept(28,layers[28].forward(scope.hidden,state[28]!,phase));
    scope.accept(29,layers[29].forward(scope.hidden,state[29]!,phase));
    scope.accept(30,layers[30].forward(scope.hidden,state[30]!,phase));
    scope.accept(31,layers[31].forward(scope.hidden,state[31]!,phase,positions));
    scope.accept(32,layers[32].forward(scope.hidden,state[32]!,phase));
    scope.accept(33,layers[33].forward(scope.hidden,state[33]!,phase));
    scope.accept(34,layers[34].forward(scope.hidden,state[34]!,phase));
    scope.accept(35,layers[35].forward(scope.hidden,state[35]!,phase,positions));
    scope.accept(36,layers[36].forward(scope.hidden,state[36]!,phase));
    scope.accept(37,layers[37].forward(scope.hidden,state[37]!,phase));
    scope.accept(38,layers[38].forward(scope.hidden,state[38]!,phase));
    scope.accept(39,layers[39].forward(scope.hidden,state[39]!,phase,positions));
    scope.accept(40,layers[40].forward(scope.hidden,state[40]!,phase));
    scope.accept(41,layers[41].forward(scope.hidden,state[41]!,phase));
    scope.accept(42,layers[42].forward(scope.hidden,state[42]!,phase));
    scope.accept(43,layers[43].forward(scope.hidden,state[43]!,phase,positions));
    scope.accept(44,layers[44].forward(scope.hidden,state[44]!,phase));
    scope.accept(45,layers[45].forward(scope.hidden,state[45]!,phase));
    scope.accept(46,layers[46].forward(scope.hidden,state[46]!,phase));
    scope.accept(47,layers[47].forward(scope.hidden,state[47]!,phase,positions));
    scope.accept(48,layers[48].forward(scope.hidden,state[48]!,phase));
    scope.accept(49,layers[49].forward(scope.hidden,state[49]!,phase));
    scope.accept(50,layers[50].forward(scope.hidden,state[50]!,phase));
    scope.accept(51,layers[51].forward(scope.hidden,state[51]!,phase,positions));
    scope.accept(52,layers[52].forward(scope.hidden,state[52]!,phase));
    scope.accept(53,layers[53].forward(scope.hidden,state[53]!,phase));
    scope.accept(54,layers[54].forward(scope.hidden,state[54]!,phase));
    scope.accept(55,layers[55].forward(scope.hidden,state[55]!,phase,positions));
    scope.accept(56,layers[56].forward(scope.hidden,state[56]!,phase));
    scope.accept(57,layers[57].forward(scope.hidden,state[57]!,phase));
    scope.accept(58,layers[58].forward(scope.hidden,state[58]!,phase));
    scope.accept(59,layers[59].forward(scope.hidden,state[59]!,phase,positions));
    scope.accept(60,layers[60].forward(scope.hidden,state[60]!,phase));
    scope.accept(61,layers[61].forward(scope.hidden,state[61]!,phase));
    scope.accept(62,layers[62].forward(scope.hidden,state[62]!,phase));
    scope.accept(63,layers[63].forward(scope.hidden,state[63]!,phase,positions));
    return scope.finish(64,this.finalNorm.forward(scope.hidden));
  }
  #packed(layers:Layers,groups:readonly MlxPhaseGroup[]):MlxArray[] {
    using scope=new PackedMixedScope(groups,ids=>this.embed.encode(ids));
    scope.accept(0,(hidden,cache,phase)=>layers[0].forwardAttn(hidden,cache,phase),hidden=>layers[0].forwardMlp(hidden));
    scope.accept(1,(hidden,cache,phase)=>layers[1].forwardAttn(hidden,cache,phase),hidden=>layers[1].forwardMlp(hidden));
    scope.accept(2,(hidden,cache,phase)=>layers[2].forwardAttn(hidden,cache,phase),hidden=>layers[2].forwardMlp(hidden));
    scope.accept(3,(hidden,cache,phase)=>layers[3].forwardAttn(hidden,cache,phase),hidden=>layers[3].forwardMlp(hidden));
    scope.accept(4,(hidden,cache,phase)=>layers[4].forwardAttn(hidden,cache,phase),hidden=>layers[4].forwardMlp(hidden));
    scope.accept(5,(hidden,cache,phase)=>layers[5].forwardAttn(hidden,cache,phase),hidden=>layers[5].forwardMlp(hidden));
    scope.accept(6,(hidden,cache,phase)=>layers[6].forwardAttn(hidden,cache,phase),hidden=>layers[6].forwardMlp(hidden));
    scope.accept(7,(hidden,cache,phase)=>layers[7].forwardAttn(hidden,cache,phase),hidden=>layers[7].forwardMlp(hidden));
    scope.accept(8,(hidden,cache,phase)=>layers[8].forwardAttn(hidden,cache,phase),hidden=>layers[8].forwardMlp(hidden));
    scope.accept(9,(hidden,cache,phase)=>layers[9].forwardAttn(hidden,cache,phase),hidden=>layers[9].forwardMlp(hidden));
    scope.accept(10,(hidden,cache,phase)=>layers[10].forwardAttn(hidden,cache,phase),hidden=>layers[10].forwardMlp(hidden));
    scope.accept(11,(hidden,cache,phase)=>layers[11].forwardAttn(hidden,cache,phase),hidden=>layers[11].forwardMlp(hidden));
    scope.accept(12,(hidden,cache,phase)=>layers[12].forwardAttn(hidden,cache,phase),hidden=>layers[12].forwardMlp(hidden));
    scope.accept(13,(hidden,cache,phase)=>layers[13].forwardAttn(hidden,cache,phase),hidden=>layers[13].forwardMlp(hidden));
    scope.accept(14,(hidden,cache,phase)=>layers[14].forwardAttn(hidden,cache,phase),hidden=>layers[14].forwardMlp(hidden));
    scope.accept(15,(hidden,cache,phase)=>layers[15].forwardAttn(hidden,cache,phase),hidden=>layers[15].forwardMlp(hidden));
    scope.accept(16,(hidden,cache,phase)=>layers[16].forwardAttn(hidden,cache,phase),hidden=>layers[16].forwardMlp(hidden));
    scope.accept(17,(hidden,cache,phase)=>layers[17].forwardAttn(hidden,cache,phase),hidden=>layers[17].forwardMlp(hidden));
    scope.accept(18,(hidden,cache,phase)=>layers[18].forwardAttn(hidden,cache,phase),hidden=>layers[18].forwardMlp(hidden));
    scope.accept(19,(hidden,cache,phase)=>layers[19].forwardAttn(hidden,cache,phase),hidden=>layers[19].forwardMlp(hidden));
    scope.accept(20,(hidden,cache,phase)=>layers[20].forwardAttn(hidden,cache,phase),hidden=>layers[20].forwardMlp(hidden));
    scope.accept(21,(hidden,cache,phase)=>layers[21].forwardAttn(hidden,cache,phase),hidden=>layers[21].forwardMlp(hidden));
    scope.accept(22,(hidden,cache,phase)=>layers[22].forwardAttn(hidden,cache,phase),hidden=>layers[22].forwardMlp(hidden));
    scope.accept(23,(hidden,cache,phase)=>layers[23].forwardAttn(hidden,cache,phase),hidden=>layers[23].forwardMlp(hidden));
    scope.accept(24,(hidden,cache,phase)=>layers[24].forwardAttn(hidden,cache,phase),hidden=>layers[24].forwardMlp(hidden));
    scope.accept(25,(hidden,cache,phase)=>layers[25].forwardAttn(hidden,cache,phase),hidden=>layers[25].forwardMlp(hidden));
    scope.accept(26,(hidden,cache,phase)=>layers[26].forwardAttn(hidden,cache,phase),hidden=>layers[26].forwardMlp(hidden));
    scope.accept(27,(hidden,cache,phase)=>layers[27].forwardAttn(hidden,cache,phase),hidden=>layers[27].forwardMlp(hidden));
    scope.accept(28,(hidden,cache,phase)=>layers[28].forwardAttn(hidden,cache,phase),hidden=>layers[28].forwardMlp(hidden));
    scope.accept(29,(hidden,cache,phase)=>layers[29].forwardAttn(hidden,cache,phase),hidden=>layers[29].forwardMlp(hidden));
    scope.accept(30,(hidden,cache,phase)=>layers[30].forwardAttn(hidden,cache,phase),hidden=>layers[30].forwardMlp(hidden));
    scope.accept(31,(hidden,cache,phase)=>layers[31].forwardAttn(hidden,cache,phase),hidden=>layers[31].forwardMlp(hidden));
    scope.accept(32,(hidden,cache,phase)=>layers[32].forwardAttn(hidden,cache,phase),hidden=>layers[32].forwardMlp(hidden));
    scope.accept(33,(hidden,cache,phase)=>layers[33].forwardAttn(hidden,cache,phase),hidden=>layers[33].forwardMlp(hidden));
    scope.accept(34,(hidden,cache,phase)=>layers[34].forwardAttn(hidden,cache,phase),hidden=>layers[34].forwardMlp(hidden));
    scope.accept(35,(hidden,cache,phase)=>layers[35].forwardAttn(hidden,cache,phase),hidden=>layers[35].forwardMlp(hidden));
    scope.accept(36,(hidden,cache,phase)=>layers[36].forwardAttn(hidden,cache,phase),hidden=>layers[36].forwardMlp(hidden));
    scope.accept(37,(hidden,cache,phase)=>layers[37].forwardAttn(hidden,cache,phase),hidden=>layers[37].forwardMlp(hidden));
    scope.accept(38,(hidden,cache,phase)=>layers[38].forwardAttn(hidden,cache,phase),hidden=>layers[38].forwardMlp(hidden));
    scope.accept(39,(hidden,cache,phase)=>layers[39].forwardAttn(hidden,cache,phase),hidden=>layers[39].forwardMlp(hidden));
    scope.accept(40,(hidden,cache,phase)=>layers[40].forwardAttn(hidden,cache,phase),hidden=>layers[40].forwardMlp(hidden));
    scope.accept(41,(hidden,cache,phase)=>layers[41].forwardAttn(hidden,cache,phase),hidden=>layers[41].forwardMlp(hidden));
    scope.accept(42,(hidden,cache,phase)=>layers[42].forwardAttn(hidden,cache,phase),hidden=>layers[42].forwardMlp(hidden));
    scope.accept(43,(hidden,cache,phase)=>layers[43].forwardAttn(hidden,cache,phase),hidden=>layers[43].forwardMlp(hidden));
    scope.accept(44,(hidden,cache,phase)=>layers[44].forwardAttn(hidden,cache,phase),hidden=>layers[44].forwardMlp(hidden));
    scope.accept(45,(hidden,cache,phase)=>layers[45].forwardAttn(hidden,cache,phase),hidden=>layers[45].forwardMlp(hidden));
    scope.accept(46,(hidden,cache,phase)=>layers[46].forwardAttn(hidden,cache,phase),hidden=>layers[46].forwardMlp(hidden));
    scope.accept(47,(hidden,cache,phase)=>layers[47].forwardAttn(hidden,cache,phase),hidden=>layers[47].forwardMlp(hidden));
    scope.accept(48,(hidden,cache,phase)=>layers[48].forwardAttn(hidden,cache,phase),hidden=>layers[48].forwardMlp(hidden));
    scope.accept(49,(hidden,cache,phase)=>layers[49].forwardAttn(hidden,cache,phase),hidden=>layers[49].forwardMlp(hidden));
    scope.accept(50,(hidden,cache,phase)=>layers[50].forwardAttn(hidden,cache,phase),hidden=>layers[50].forwardMlp(hidden));
    scope.accept(51,(hidden,cache,phase)=>layers[51].forwardAttn(hidden,cache,phase),hidden=>layers[51].forwardMlp(hidden));
    scope.accept(52,(hidden,cache,phase)=>layers[52].forwardAttn(hidden,cache,phase),hidden=>layers[52].forwardMlp(hidden));
    scope.accept(53,(hidden,cache,phase)=>layers[53].forwardAttn(hidden,cache,phase),hidden=>layers[53].forwardMlp(hidden));
    scope.accept(54,(hidden,cache,phase)=>layers[54].forwardAttn(hidden,cache,phase),hidden=>layers[54].forwardMlp(hidden));
    scope.accept(55,(hidden,cache,phase)=>layers[55].forwardAttn(hidden,cache,phase),hidden=>layers[55].forwardMlp(hidden));
    scope.accept(56,(hidden,cache,phase)=>layers[56].forwardAttn(hidden,cache,phase),hidden=>layers[56].forwardMlp(hidden));
    scope.accept(57,(hidden,cache,phase)=>layers[57].forwardAttn(hidden,cache,phase),hidden=>layers[57].forwardMlp(hidden));
    scope.accept(58,(hidden,cache,phase)=>layers[58].forwardAttn(hidden,cache,phase),hidden=>layers[58].forwardMlp(hidden));
    scope.accept(59,(hidden,cache,phase)=>layers[59].forwardAttn(hidden,cache,phase),hidden=>layers[59].forwardMlp(hidden));
    scope.accept(60,(hidden,cache,phase)=>layers[60].forwardAttn(hidden,cache,phase),hidden=>layers[60].forwardMlp(hidden));
    scope.accept(61,(hidden,cache,phase)=>layers[61].forwardAttn(hidden,cache,phase),hidden=>layers[61].forwardMlp(hidden));
    scope.accept(62,(hidden,cache,phase)=>layers[62].forwardAttn(hidden,cache,phase),hidden=>layers[62].forwardMlp(hidden));
    scope.accept(63,(hidden,cache,phase)=>layers[63].forwardAttn(hidden,cache,phase),hidden=>layers[63].forwardMlp(hidden));
    return scope.finish(64,hidden=>this.finalNorm.forward(hidden));
  }
}
