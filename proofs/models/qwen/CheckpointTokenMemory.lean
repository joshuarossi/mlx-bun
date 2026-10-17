import models.qwen.TokenInitializedConstruction
import models.qwen.CheckpointDictionaryBinding
import models.qwen.Qwen38TrellisM1MaxMagnitude

namespace Inference.Models.Qwen.CheckpointTokenMemory
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

-- This adapter reuses the existing complete literal/dictionary certificate
-- chain. Ordered dictionary indices, exact bindings to the chosen model,
-- loaded byte attachments, primitive contracts and reached plans stay explicit.
-- Error budgets are symbolic; a useful final accuracy bound and independent
-- exact-real token-sequence agreement remain open.
variable {p : Pipeline} {token : Fin 248320} {initialHeap : ByteMemory.Bytes}
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (original : TokenParameterMemory.Storage p initialHeap)
  (initialization : TokenInitializationMemory.Plan p token initialHeap)
  (safe : original.Protected initialization.Safe)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angles : TokenAutoregressive.Angles)

abbrev Trace {time : Nat} (state : TokenAutoregressiveMemory.State p time)
    (current : TokenParameterMemory.Storage p state.index.bytes) :=
  TokenInitializedConstruction.Trace original initialization safe
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive angles state current

theorem initial : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles
    (TokenInitializationMemory.fromStorage original initialization safe).state
    (TokenInitializationMemory.fromStorage original initialization safe).parameters :=
  TokenInitializedConstruction.initial _ _ _ _ _ _ _ _

variable {encoded binding original initialization safe primitive sampling samplingPrimitive angles}
  {time : Nat} {state : TokenAutoregressiveMemory.State p time}
  {current : TokenParameterMemory.Storage p state.index.bytes}

theorem readback (trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (supported : time≤262144) :
    let reference := CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive token angles time supported
    (state.index.read,state.readCaches)=(reference.token.val,reference.cache) := trace.readback supported

theorem parameter_bytes (trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (region : TokenParameterConstruction.Region original base size) (offset : Nat) (bound : offset<size) :
    state.index.bytes (base+offset)=initialHeap (base+offset) := TokenInitializedConstruction.parameter_bytes trace region offset bound

theorem parameter_regions (trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (property : Nat → Nat → Prop) : current.Protected property ↔ original.Protected property :=
  TokenInitializedConstruction.parameters_regions trace property

theorem cache_ranges (_trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current) :
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.readCaches ∧
    DecodeChain.CacheErrors p.graph.stages state.readCaches state.logical.targetCache state.logical.errorCache ∧
    DecodeChain.CachesFinite p.graph.stages state.readCaches := by
  rw [TokenAutoregressiveMemory.State.caches_eq]
  exact ⟨state.logical.cacheBound,state.logical.cacheError,
    DecodeChainSequenceRanges.caches_finite _ _ state.logical.cacheBound⟩

variable {angle : RopeAngles.Inputs}

theorem step_logits_bound (_trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (plan : TokenParameterConstruction.Plan current angle sampling) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) :
    ∀ i, Model.isFinite (plan.graph.forward.logits i)=true ∧
      |Model.toReal (plan.graph.forward.logits i)|≤(2:ℝ)^(18:Nat) := by
  rw [plan.graph.forward.logits_eq]
  exact Qwen38TrellisM1MaxMagnitude.pipeline_output p
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive
    state.logical.cache state.logical.cacheBound state.logical.token angle angleBound supported

theorem step_accuracy (_trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (plan : TokenParameterConstruction.Plan current angle sampling) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base) :
    ∀ i, |Model.toReal (plan.graph.forward.logits i)-(p.targetRun state.logical.targetCache state.logical.token aim).1 i|≤
      (TokenSampledSequenceRanges.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        primitive state.logical.cache state.logical.cacheBound state.logical.targetCache state.logical.errorCache
        state.logical.token angle angleBound supported aim ae).1 i := by
  rw [plan.graph.forward.logits_eq]
  exact (TokenSequenceRanges.run_correct p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive state.logical.cache state.logical.cacheBound state.logical.targetCache state.logical.errorCache
    state.logical.cacheError state.logical.token angle angleBound supported aim ae angleError base).1

-- An exact-real token claim requires this explicit winner margin; the
-- numerical budget alone does not assert that rounding preserves a winner.
theorem step_target_winner (_trace : Trace encoded binding original initialization safe primitive sampling samplingPrimitive angles state current)
    (plan : TokenParameterConstruction.Plan current angle sampling) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : time+1≤262144) (aim ae : RopeAngles.Target)
    (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base) (winner : Fin 248320)
    (margin : ∀ i, i≠winner →
      (p.targetRun state.logical.targetCache state.logical.token aim).1 i+
        GreedySampling.error sampling (TokenSampledSequenceRanges.logits p state.logical.cache state.logical.token angle)
          (TokenSampledSequenceRanges.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
            primitive state.logical.cache state.logical.cacheBound state.logical.targetCache state.logical.errorCache
            state.logical.token angle angleBound supported aim ae).1 i <
      (p.targetRun state.logical.targetCache state.logical.token aim).1 winner-
        GreedySampling.error sampling (TokenSampledSequenceRanges.logits p state.logical.cache state.logical.token angle)
          (TokenSampledSequenceRanges.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
            primitive state.logical.cache state.logical.cacheBound state.logical.targetCache state.logical.errorCache
            state.logical.token angle angleBound supported aim ae).1 winner) :
    plan.sampled.sampler.selection.token=winner.val := by
  rw [plan.sampled.token_eq samplingPrimitive (plan.step.logitsBound
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive angleBound supported)]
  exact TokenSampledSequenceRanges.target_winner p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive state.logical.cache state.logical.cacheBound state.logical.targetCache
    state.logical.errorCache state.logical.cacheError state.logical.token angle angleBound supported aim ae angleError base winner margin

end Inference.Models.Qwen.CheckpointTokenMemory
