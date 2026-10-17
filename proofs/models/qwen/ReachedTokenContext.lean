import models.qwen.ReachedSequenceRanges
import models.qwen.GraphDivisionPrimitives

-- Weak reached-domain contracts, original scalar functions and graph outputs.
-- Normal envelopes, exact scalar division selection and all other native
-- primitive/accuracy contracts remain explicit; no subnormal rsqrt behavior
-- or inhabitant of the old universal Primitives/Context records is assumed.
namespace Inference.Models.Qwen.ReachedTokenContext
open Contracts.Mlx Contracts.Mlx.Numerics TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

namespace Primitive
open Qwen38TrellisM1Max Layers.AffineVerifyLinear
open GraphDivisionPrimitives (Selected AffineSelected normalizedAffine outputAffine head128)
structure MlpOther (layer : ResidualBlocks.Mlp) where
  root : RsqrtEpsilonBounds.NormalEnvelope layer.norm.platform.rsqrt 2
  activation : TrellisMlpRanges.ActivationPrimitive layer.mlp.activation

def mlp (selected : Selected layer.norm.platform.divide) (other : MlpOther layer) :
    ReachedStageRanges.Mlp.Primitives layer where
  division := NativeDivisionDomain.of_selection _ selected
  root := RsqrtEpsilonBounds.from_normal other.root Blocks.eps_normal
  activation := other.activation

abbrev DeltaSelected (norm : Blocks.Norm) (layer : DeltaNet.Layer) : Prop := GraphDivisionPrimitives.DeltaSelected norm layer

-- No division range record occurs here. The sharper head envelope also
-- supplies its old coarse envelope, so the caller need not supply both.
structure DeltaOther (norm : Blocks.Norm) (layer : DeltaNet.Layer) where
  normalizationRoot : RsqrtEpsilonBounds.NormalEnvelope norm.platform.rsqrt 2
  headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs
  headRoot : RsqrtEpsilonBounds.NormalEnvelope layer.recurrence.heads.rsqrt (17/16)
  decay : Kernels.Delta.DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile
  beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs
  gatedRoot : RsqrtEpsilonBounds.NormalEnvelope layer.gated.rsqrt 2
  gatedExp : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs

theorem head128 (selected : Selected divide) (x : Float32) (hx : x.isFinite=true) :
    divide x (Float32.ofInt 128)=FlushToZero.div x (Float32.ofInt 128) :=
  selected x _ hx (NativeNormalizationDivision.divisor_finite .deltaHead)
    (NativeNormalizationDivision.divisor_domain .deltaHead)

def delta {norm : Blocks.Norm} (selected : DeltaSelected norm layer) (other : DeltaOther norm layer) :
    ReachedStageRanges.DeltaMix.Primitives norm layer where
  normalizationDivision := NativeDivisionDomain.of_selection _ selected.normalization
  normalizationRoot := RsqrtEpsilonBounds.from_normal other.normalizationRoot Blocks.eps_normal
  projections := ⟨normalizedAffine _ selected.qkv,normalizedAffine _ selected.z,
    normalizedAffine _ selected.a,normalizedAffine _ selected.b⟩
  headExp := other.headExp
  headDivision := NativeDivisionDomain.of_selection _ selected.heads
  decay := other.decay
  beta := other.beta
  gatedDivision := NativeDivisionDomain.of_selection _ selected.gated
  gatedRoot := RsqrtEpsilonBounds.from_normal other.gatedRoot Blocks.eps_normal
  gatedExp := other.gatedExp
  output := outputAffine _ selected.output
  headRootTight := RsqrtEpsilonBounds.from_normal other.headRoot Blocks.eps_normal
  headDivisionNative := head128 selected.heads

abbrev AttentionSelected (norm : Blocks.Norm) (layer : Attention.Layer) : Prop := GraphDivisionPrimitives.AttentionSelected norm layer

structure AttentionOther (norm : Blocks.Norm) (layer : Attention.Layer) where
  normalizationRoot : RsqrtEpsilonBounds.NormalEnvelope norm.platform.rsqrt 2
  queryRoot : RsqrtEpsilonBounds.NormalEnvelope layer.preparation.qNorm.platform.rsqrt 2
  keyRoot : RsqrtEpsilonBounds.NormalEnvelope layer.preparation.kNorm.platform.rsqrt 2
  frequency : RopeAnglesRanges.Exp2Range layer.preparation.angles
  rotation : RopeRanges.TrigRanges layer.preparation.rotation
  angleDomain : AttentionSequenceHeadsRanges.AngleDomain layer.preparation
  maximum : SdpaInitialLoopRanges.Maximum layer.attention
  exponential : SdpaExponentRanges.Primitive layer.attention.merge.scalar
  gate : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.gate.expAbs

def attention {norm : Blocks.Norm} (selected : AttentionSelected norm layer) (other : AttentionOther norm layer) :
    ReachedStageRanges.AttentionMix.Primitives norm layer where
  normalization := NativeDivisionDomain.of_selection _ selected.normalization
  root := RsqrtEpsilonBounds.from_normal other.normalizationRoot Blocks.eps_normal
  projections := ⟨normalizedAffine _ selected.q,normalizedAffine _ selected.k,normalizedAffine _ selected.v⟩
  heads := {
    queryDivision := NativeDivisionDomain.of_selection _ selected.queryNormalization
    queryRoot := RsqrtEpsilonBounds.from_normal other.queryRoot Blocks.eps_normal
    keyDivision := NativeDivisionDomain.of_selection _ selected.keyNormalization
    keyRoot := RsqrtEpsilonBounds.from_normal other.keyRoot Blocks.eps_normal
    angleDivision := (NativeDivisionDomain.of_selection _ selected.angle).toContract
    frequency := other.frequency
    rotation := other.rotation
    zeroDomain := by
      intro theta finite zero
      apply other.angleDomain theta finite
      rw [zero,abs_zero]
      positivity }
  attention := {
    maximum := other.maximum
    exponential := other.exponential
    division := (NativeDivisionDomain.of_selection _ selected.attention).toContract }
  gate := other.gate
  output := outputAffine _ selected.output
  angleDomain := other.angleDomain
  attentionDivision := NativeDivisionDomain.of_selection _ selected.attention

abbrev ResidualDeltaSelected (layer : ResidualDelta.Layer) : Prop := GraphDivisionPrimitives.ResidualDeltaSelected layer

structure ResidualDeltaOther (layer : ResidualDelta.Layer) where
  mixer : DeltaOther layer.inputNorm layer.mixer
  suffix : MlpOther layer.suffix

def residualDelta (selected : ResidualDeltaSelected layer) (other : ResidualDeltaOther layer) :
    ReachedStageRanges.DeltaResidual.Primitives layer := ⟨delta selected.mixer other.mixer,mlp selected.suffix other.suffix⟩

abbrev ResidualAttentionSelected (layer : ResidualAttention.Layer) : Prop := GraphDivisionPrimitives.ResidualAttentionSelected layer

structure ResidualAttentionOther (layer : ResidualAttention.Layer) where
  mixer : AttentionOther layer.inputNorm layer.mixer
  suffix : MlpOther layer.suffix

def residualAttention (selected : ResidualAttentionSelected layer) (other : ResidualAttentionOther layer) :
    ReachedStageRanges.AttentionResidual.Primitives layer := ⟨attention selected.mixer other.mixer,mlp selected.suffix other.suffix⟩

abbrev Selections (graph : Graph) : Prop := GraphDivisionPrimitives.Selections graph

structure Other (graph : Graph) where
  delta : ∀ i, ResidualDeltaOther (graph.delta i)
  attention : ∀ i, ResidualAttentionOther (graph.attention i)
  root : RsqrtEpsilonBounds.NormalEnvelope graph.finalNorm.platform.rsqrt 2

-- Directly accepted by every existing sequence/checkpoint/context primitive
-- argument. Its inputs contain no old assembled Primitives record and no
-- mathematical division envelopes; all divide fields are proved here.
def graphPrimitives (selected : Selections graph) (other : Other graph) :
    ReachedSequenceRanges.Graph.Primitives graph where
  delta i := residualDelta (selected.delta i) (other.delta i)
  attention i := residualAttention (selected.attention i) (other.attention i)
  normalization := NativeDivisionDomain.of_selection _ selected.normalization
  root := RsqrtEpsilonBounds.from_normal other.root Blocks.eps_normal
  output := normalizedAffine _ selected.output

end Primitive

namespace Logical
open TokenAutoregressive (State initial Angles)
noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) : State p (time+1) := by
  let output := TokenSampledSequenceRanges.run p sampling before.cache before.token angle
  let error := ReachedSequenceRanges.Sample.budget p parameters primitive before.cache before.cacheBound
    before.targetCache before.errorCache before.token angle ha supported aim ae
  have correct := ReachedSequenceRanges.Sample.run_correct p parameters primitive sampling samplingPrimitive
    before.cache before.cacheBound before.targetCache before.errorCache before.cacheError before.token angle ha supported aim ae he hb
  have tokenBound : output.1 < 248320 := by
    obtain ⟨selected, same, _, _⟩ := correct.2.2.2.2.2
    change (TokenSampledSequenceRanges.run p sampling before.cache before.token angle).1 < 248320
    rw [same]
    exact selected.isLt
  exact ⟨⟨output.1, tokenBound⟩, output.2, correct.2.2.1,
    (p.targetRun before.targetCache before.token aim).2, error.2, correct.2.1⟩

theorem advance_data (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0≤aim.base) :
    let after := advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb
    after.token.val=(TokenSampledSequenceRanges.run p sampling before.cache before.token angle).1 ∧
      after.cache=(p.run before.cache before.token angle).2 := ⟨rfl,rfl⟩

theorem advance_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    let next := advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token angle
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token aim).1 i| ≤
      (ReachedSequenceRanges.Sample.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token angle ha supported aim ae).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits next.token) ∧
    (∀ i, GreedySampling.score sampling logits next.token = GreedySampling.score sampling logits i → next.token.val ≤ i.val) := by
  have correct := ReachedSequenceRanges.Sample.run_correct p parameters primitive sampling samplingPrimitive
    before.cache before.cacheBound before.targetCache before.errorCache before.cacheError before.token angle ha supported aim ae he hb
  obtain ⟨selected, same, largest, tie⟩ := correct.2.2.2.2.2
  have token : (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb).token = selected :=
    Fin.ext same
  dsimp only
  rw [token]
  exact ⟨correct.1, correct.2.2.2.1, correct.2.2.2.2.1, largest, tie⟩

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) : (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => initial p token
  | t+1, supported =>
    advance p parameters primitive sampling samplingPrimitive
      (run p parameters primitive sampling samplingPrimitive token angles t (by omega))
      (angles.value t) (angles.ranges t (by omega)) supported (angles.target t) (angles.error t)
      (angles.accuracy t (by omega)) (angles.base t (by omega))

theorem run_step (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p parameters primitive sampling samplingPrimitive token angles time (by omega)
    let after := run p parameters primitive sampling samplingPrimitive token angles (time+1) supported
    after.token.val = (TokenSampledSequenceRanges.run p sampling before.cache before.token (angles.value time)).1 ∧
      after.cache = (p.run before.cache before.token (angles.value time)).2 := ⟨rfl, rfl⟩

theorem run_invariant (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time ≤ 262144) :
    let state := run p parameters primitive sampling samplingPrimitive token angles time supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.cache ∧
      DecodeChain.CacheErrors p.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages state.cache := by
  let state := run p parameters primitive sampling samplingPrimitive token angles time supported
  exact ⟨state.cacheBound, state.cacheError, DecodeChainSequenceRanges.caches_finite _ _ state.cacheBound⟩

theorem run_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p parameters primitive sampling samplingPrimitive token angles time (by omega)
    let after := run p parameters primitive sampling samplingPrimitive token angles (time+1) supported
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (angles.value time)
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (angles.target time)).1 i| ≤
      (ReachedSequenceRanges.Sample.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (angles.value time) (angles.ranges time (by omega)) supported
          (angles.target time) (angles.error time)).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token = GreedySampling.score sampling logits i → after.token.val ≤ i.val) :=
  advance_correct p parameters primitive sampling samplingPrimitive
    (run p parameters primitive sampling samplingPrimitive token angles time (by omega))
    (angles.value time) (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
    (angles.accuracy time (by omega)) (angles.base time (by omega))

end Logical

structure Context (pipeline : Pipeline) where
  parameters : TokenSequenceRanges.Parameters pipeline
  primitive : ReachedSequenceRanges.Graph.Primitives pipeline.graph
  sampling : LogSumExpRanges.Platform
  samplingPrimitive : LogSumExpRanges.Primitives sampling
  angles : TokenAutoregressive.Angles
  locals : Nat → TokenReadyMemory.Locals

def ofNormal (parameters : TokenSequenceRanges.Parameters pipeline)
    (selected : Primitive.Selections pipeline.graph) (other : Primitive.Other pipeline.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (angles : TokenAutoregressive.Angles) (locals : Nat → TokenReadyMemory.Locals) : Context pipeline :=
  ⟨parameters,Primitive.graphPrimitives selected other,sampling,samplingPrimitive,angles,locals⟩

noncomputable def Context.run (context : Context pipeline) (token : Fin 248320) (steps : Nat)
    (supported : steps≤262144) : TokenAutoregressive.State pipeline steps :=
  Logical.run pipeline context.parameters context.primitive context.sampling context.samplingPrimitive token context.angles steps supported

theorem Context.run_step (context : Context pipeline) (token : Fin 248320) (time : Nat) (supported : time+1≤262144) :
    let before := context.run token time (by omega)
    let after := context.run token (time+1) supported
    after.token.val=(TokenSampledSequenceRanges.run pipeline context.sampling before.cache before.token (context.angles.value time)).1 ∧
      after.cache=(pipeline.run before.cache before.token (context.angles.value time)).2 :=
  Logical.run_step pipeline context.parameters context.primitive context.sampling context.samplingPrimitive token context.angles time supported

theorem Context.run_invariant (context : Context pipeline) (token : Fin 248320) (time : Nat) (supported : time≤262144) :
    let state := context.run token time supported
    DecodeChainSequenceRanges.CachesBound pipeline.graph.stages state.cache ∧
      DecodeChain.CacheErrors pipeline.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite pipeline.graph.stages state.cache :=
  Logical.run_invariant pipeline context.parameters context.primitive context.sampling context.samplingPrimitive token context.angles time supported

end Inference.Models.Qwen.ReachedTokenContext
