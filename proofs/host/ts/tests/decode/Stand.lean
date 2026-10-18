import host.ts.tests.layers.Common
set_option maxRecDepth 100000

/-! Stand-ins for the decode drivers (`Decode`), beside the layer runs' (`tests/layers/Common`):
files on the import graph the route does not execute, files of types only, and the stand-in for the graph
file's decode route. Host modules: `checkpoint` (`Data`), `node:fs`, `sym`. -/

namespace Host.Ts.Tests.Decode.StandInferenceQwen38one
/-- STAND-IN for the decode route of `packages/inference/src/models/qwen/qwen38-27b-trellis-m1max.ts` restricted to its first block (layers 0-3 of `#one`): the constructor statements D1 and H1 read, `#submitted`, `#run`, copied from the file; replace by the graph file's own AST once embedded. -/
def source : String := r#"// STAND-IN for the decode route of packages/inference/src/models/qwen/qwen38-27b-trellis-m1max.ts,
// to be replaced by that file's own constructor once its AST is embedded: its first block. Every
// statement below is copied from the file (line numbers there), restricted to layers 0-3 (the
// first of its sixteen [Delta, Delta, Delta, Attention] blocks of `#one`) and to the members D1
// (`decode[1]`) and H1 (`logits[1]`) read: no ANE, row, MMA, wide or prompt tables, LoRA targets,
// draft projections or mRoPE.
import * as ops from "@mlx-bun/mlx/ops";
import { LoraState } from "./layers/lora";
import { RMSNorm } from "./layers/normalization";
import { QuantizedEmbedding } from "./layers/quantized-embedding";
import { QuantizedLinear, QuantizedLinearPlain as Plain } from "./layers/quantized-linear";
import { CodebookSplitGateUpRow as GateRow } from "./layers/trellis-codebook-gate-up";
import { CodebookDownK3iRow as DownK3iRow, CodebookDownRow as DownRow } from "./layers/trellis-codebook-down";
import { AffineRowLinear as AffineRow } from "./layers/affine-verify-linear";
import { TrellisReducePrompt as Reduce } from "./layers/trellis-prompt";
import { SubmittedGraphForwardScope } from "./runtime/graph-forward";
import { QwenResidualDeltaLayer as ResidualDelta, QwenResidualAttentionLayer as ResidualAttention, QwenFusedHeadsDeltaNet as FusedDelta } from "./models/qwen/blocks";
import { DeltaWeights, AttentionWeights, GateDownMLP, canonicalQwenWeights } from "./models/qwen/written-layers";
// lines 66-67
const PREFIX="language_model.model";
const REPRESENTATIONS={gateUpCodebook:true,mixedExactBits:true,scatter:{bits:true,genericBits:true,floatCodebook:true},widePrefill:false};
/** Lines 85-155, 161, 170-174, 251-255, 1065, 1090, 1152-1153, 1369-1372, 1397-1401, 1462-1463 of the graph file. */
export class Qwen38TrellisM1Max {
  readonly loraState=new LoraState();
  readonly wiredWeights=true;
  readonly embed;
  readonly finalNorm;
  readonly lmHead;
  readonly decode;
  readonly logits;
  readonly #head;
  readonly #one;
  constructor(weights,readonly config) {
    const w=canonicalQwenWeights(weights),c=config,t=config.text;
    this.embed=QuantizedEmbedding.load(w,`${PREFIX}.embed_tokens`,c);
    this.finalNorm=new RMSNorm(w.tensor(`${PREFIX}.norm.weight`),t.rmsNormEps);
    this.lmHead=QuantizedLinear.load(w,"language_model.lm_head",c);
    this.#head=new Plain(this.lmHead);
    const invScale=Math.pow(t.linearKeyHeadDim,-0.5),qk={q:ops.filledBf16(invScale*invScale,t.linearKeyHeadDim),k:ops.filledBf16(invScale,t.linearKeyHeadDim)};
    const state=this.loraState;
    const d0=new DeltaWeights(w,c,`${PREFIX}.layers.0`,REPRESENTATIONS,state);
    const d1=new DeltaWeights(w,c,`${PREFIX}.layers.1`,REPRESENTATIONS,state);
    const d2=new DeltaWeights(w,c,`${PREFIX}.layers.2`,REPRESENTATIONS,state);
    const a3=new AttentionWeights(w,c,`${PREFIX}.layers.3`,REPRESENTATIONS,state);
    this.#one=[
      d0.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownRow,Plain,Plain,Plain,Plain,Plain,qk,FusedDelta),
      d1.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,Plain,qk,FusedDelta),
      d2.stage(w,c,ResidualDelta,GateDownMLP,GateRow,Reduce,DownK3iRow,AffineRow,AffineRow,Plain,Plain,Plain,qk,FusedDelta),
      a3.stage(w,c,ResidualAttention,GateDownMLP,GateRow,Reduce,DownK3iRow,Plain,Plain,Plain,Plain),
    ];
    const one=this.#one;
    const D1=(ids,cache,capture)=>this.#submitted(one,ids,cache,"decode",capture);
    this.decode=Object.freeze({1:D1});
    const rowHead=new AffineRow(this.lmHead);
    const H1=hidden=>rowHead.forward(hidden);
    this.logits=Object.freeze({1:H1});
  }
  #submitted(layers,ids,state,phase,capture) {
    using scope=new SubmittedGraphForwardScope(this.embed.encode(ids),capture,64,4);
    return this.#run(layers,state,phase,scope);
  }
  #run(layers,state,phase,scope,positions=null) {
    scope.accept(0,layers[0].forward(scope.hidden,state[0]!,phase));
    scope.accept(1,layers[1].forward(scope.hidden,state[1]!,phase));
    scope.accept(2,layers[2].forward(scope.hidden,state[2]!,phase));
    scope.accept(3,layers[3].forward(scope.hidden,state[3]!,phase,positions));
    return scope.finish(64,this.finalNorm.forward(scope.hidden));
  }
}
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceQwen38one

namespace Host.Ts.Tests.Decode.StandInferenceRuntimeResources
/-- Stand-in for `packages/inference/src/runtime/resources.ts` (not executed on the route). -/
def source : String := r#"export function disposeResources() { throw new Error("stand-in"); }
export function withResource() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceRuntimeResources

namespace Host.Ts.Tests.Decode.StandInferenceGenerationFillAppend
/-- Stand-in for `packages/inference/src/generation/fill-append.ts` (fill is off). -/
def source : String := r#"export async function appendFillHidden() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceGenerationFillAppend

namespace Host.Ts.Tests.Decode.StandInferenceGenerationGrammarStep
/-- Stand-in for `packages/inference/src/generation/grammar-step.ts` (no grammar). -/
def source : String := r#"export async function appendGrammarSpan() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceGenerationGrammarStep

namespace Host.Ts.Tests.Decode.StandInferenceGenerationFillSession
/-- Stand-in for `packages/inference/src/generation/fill/session.ts` (fill is off: `shouldUseFill` returns before these). -/
def source : String := r#"export function fillTraceEnabled() { throw new Error("stand-in"); }
export function fillTracePath() { throw new Error("stand-in"); }
export function resolveFillMode() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceGenerationFillSession

namespace Host.Ts.Tests.Decode.StandInferenceStateRollback
/-- Stand-in for `packages/inference/src/state/rollback.ts` (fill is off). -/
def source : String := r#"export function rollbackVerifyBlock() { throw new Error("stand-in"); }
export function rollsBackVerifyBlock() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceStateRollback

namespace Host.Ts.Tests.Decode.StandInferenceStateLeases
/-- Stand-in for `packages/inference/src/state/leases.ts` (`evalCacheState` runs only for prefill drains and an early return). -/
def source : String := r#"export function leaseCacheStates() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceStateLeases

namespace Host.Ts.Tests.Decode.StandInferenceGenerationTypes
/-- Stand-in for `packages/inference/src/generation/types.ts`: interfaces only, which Bun erases; the imports bind these empty cells. -/
def source : String := r#"export let GenerateOptions, GenerateStats, GenerateDiagnostics, GeneratedToken;
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceGenerationTypes

namespace Host.Ts.Tests.Decode.StandInferenceSamplingTypes
/-- Stand-in for `packages/inference/src/sampling/types.ts`: interfaces and types only, which Bun erases; the imports bind these empty cells. -/
def source : String := r#"export let DeviceStepSampler, DeviceStepSamplerConfig, NumberStepSampler, NumberStepSamplerConfig, StepExtras, StepSample, StepSamplerOptions, LogitsProcessor, LogitsProcessorOptions, Sampler, SamplerOptions, HlgConfig;
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceSamplingTypes

namespace Host.Ts.Tests.Decode.StandInferenceSamplingSampler
/-- Stand-in for `packages/inference/src/sampling/sampler.ts` (its bigint literals are not lexed yet): `makeSampler`'s greedy branch, the only one the route takes; `makeStepSampler` builds it and, greedy without metadata, never calls it. -/
def source : String := r#"import * as ops from "@mlx-bun/mlx/ops";
export function stepKey() { throw new Error("stand-in"); }
export function makeSampler(opts = {}) {
  const { temperature = 0, curve } = opts;
  if (curve || temperature !== 0) throw new Error("stand-in");
  return (lp) => ops.argmaxAxis(lp, -1);
}
export function toLogprobs() { throw new Error("stand-in"); }
"#
source_parse source
source_ast
end Host.Ts.Tests.Decode.StandInferenceSamplingSampler

namespace Host.Ts.Tests.Decode
open Host.Ts

/-- `node:fs`: `appendFileSync`, called only by fill tracing (off). -/
def nodeFs {S : Type} : HMod S := ⟨chars!"node:fs", do
  let f ← mkFn (.err .error)
  pure [(chars!"appendFileSync", f)]⟩

/-- The run's `process` global (`runtime/config.ts` reads `process.env` at load): an empty
environment, so every `MLX_BUN_*` setting takes its default. A host module of no exports that
installs the global while linking. -/
def processMod {S : Type} : HMod S := ⟨chars!"bun:process", do
  let env ← newObj (.obj aObjectProto)
  let p ← newObj (.obj aObjectProto)
  setP p (.str chars!"env") (.data (.obj env) true true)
  global chars!"process" (.obj p)
  pure []⟩

/-- The symbolic numbers of the decode runs: `n` (a cache offset, number-table entry 0), `c` (a
full-attention capacity, entry 1) and `M` (`maxTokens`, entry 2). -/
def symMod {S : Type} : HMod S := ⟨chars!"sym", pure [(chars!"n", .num (.ref 0)), (chars!"c", .num (.ref 1)), (chars!"M", .num (.ref 2))]⟩

end Host.Ts.Tests.Decode
