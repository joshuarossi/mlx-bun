import models.qwen.Qwen38TrellisM1MaxMemory
import models.qwen.Qwen38TrellisM1MaxSequenceRanges
import kernels.sampling.NormalizedArgmaxMemory
import state.TokenStorage

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxSamplingMemory
open Contracts.Mlx Qwen38TrellisM1Max DecodeStage Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 400000
attribute [local irreducible] Graph.stages Qwen38TrellisM1MaxMemory.Execution.logitsBuffer

structure Execution (graph : Graph) (cache : graph.Cache n) (input : Row BF)
    (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) where
  forward : Qwen38TrellisM1MaxMemory.Execution graph cache input angle
  forwardSafe : Qwen38TrellisM1MaxMemory.CacheSafe forward
  sampler : NormalizedArgmaxMemory.Pipeline sampling forward.logitsBuffer
  cacheSafe : DecodePreservation.Protected sampler.Safe graph.stages (DecodeChain.run graph.stages cache input angle).2
    forward.logitsBuffer.bytes (forward.afterCache forwardSafe)

variable {graph : Graph} {cache : graph.Cache n} {input : Row BF} {angle : RopeAngles.Inputs}
  {sampling : LogSumExpRanges.Platform}

def Execution.memory (execution : Execution graph cache input angle sampling) : ByteMemory.Bytes := execution.sampler.memory

def Execution.afterCache (execution : Execution graph cache input angle sampling) :
    DecodeFrame.Storage graph.stages (DecodeChain.run graph.stages cache input angle).2 execution.memory :=
  DecodePreservation.reframe execution.sampler.Safe execution.forward.logitsBuffer.bytes execution.memory
    (fun _ _ region => execution.sampler.other_region region) graph.stages
    (DecodeChain.run graph.stages cache input angle).2 (execution.forward.afterCache execution.forwardSafe) execution.cacheSafe

theorem Execution.logits_bound (execution : Execution graph cache input angle sampling)
    (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters graph)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives graph)
    (cacheBound : DecodeChainSequenceRanges.CachesBound graph.stages cache)
    (inputBound : ResidualMlpRanges.InputBound 0 input) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : n+1≤262144) :
    ∀ i, Model.isFinite (execution.forward.logits i)=true ∧ |Model.toReal (execution.forward.logits i)|≤(2:ℝ)^(23:Nat) := by
  rw [execution.forward.logits_eq]
  exact (Qwen38TrellisM1MaxSequenceRanges.checked graph parameters primitive cache cacheBound input inputBound angle angleBound supported).output

theorem Execution.token_eq (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) :
    execution.sampler.selection.token=GreedySampling.sample sampling (graph.forward cache input angle) := by
  have actual : ∀ i, Model.isFinite (execution.forward.logits i)=true ∧ |Model.toReal (execution.forward.logits i)|≤(2:ℝ)^(23:Nat) := by
    rw [execution.forward.logits_eq]
    exact bound
  rw [execution.sampler.token_eq primitive actual,execution.forward.logits_eq]

def Execution.selected (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) : Fin 248320 :=
  ⟨execution.sampler.selection.token,by
    rw [execution.token_eq primitive bound]
    obtain ⟨selected,same,_,_⟩ := (GreedySampling.correct sampling primitive (graph.forward cache input angle) bound).2.2
    rw [same]
    exact selected.isLt⟩

def Execution.index (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) : Inference.State.TokenStorage.Buffer (execution.selected primitive bound) :=
  Inference.State.TokenStorage.Buffer.fromRead (execution.selected primitive bound) execution.memory execution.sampler.selection.destination
    execution.sampler.selection.output.aligned execution.sampler.selection.output.bounded rfl

theorem Execution.index_bytes (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) :
    (execution.index primitive bound).bytes=execution.memory := rfl

def Execution.readResult (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) : Nat × graph.Cache (n+1) :=
  ⟨(execution.index primitive bound).read,DecodeFrameRead.caches graph.stages (DecodeChain.run graph.stages cache input angle).2
    execution.memory execution.afterCache⟩

theorem Execution.read_result_eq (execution : Execution graph cache input angle sampling) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)|≤(2:ℝ)^(23:Nat)) :
    execution.readResult primitive bound=(GreedySampling.sample sampling (graph.forward cache input angle),
      (DecodeChain.run graph.stages cache input angle).2) := by
  apply Prod.ext
  · exact (Inference.State.TokenStorage.Buffer.read_correct _).trans (execution.token_eq primitive bound)
  · exact DecodeFrameRead.caches_eq _ _ _ _

def Execution.checkedIndex (execution : Execution graph cache input angle sampling)
    (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters graph)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives graph)
    (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (cacheBound : DecodeChainSequenceRanges.CachesBound graph.stages cache)
    (inputBound : ResidualMlpRanges.InputBound 0 input) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : n+1≤262144) :
    Inference.State.TokenStorage.Buffer (execution.selected samplingPrimitive
      (Qwen38TrellisM1MaxSequenceRanges.checked graph parameters primitive cache cacheBound input inputBound angle angleBound supported).output) :=
  execution.index samplingPrimitive (Qwen38TrellisM1MaxSequenceRanges.checked graph parameters primitive cache cacheBound input inputBound angle angleBound supported).output

def Execution.caches (execution : Execution graph cache input angle sampling) : graph.Cache (n+1) :=
  DecodeFrameRead.caches graph.stages (DecodeChain.run graph.stages cache input angle).2 execution.memory execution.afterCache

theorem Execution.caches_eq (execution : Execution graph cache input angle sampling) :
    execution.caches=(DecodeChain.run graph.stages cache input angle).2 := DecodeFrameRead.caches_eq _ _ _ _

theorem Execution.next_cache_bound (execution : Execution graph cache input angle sampling)
    (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters graph)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives graph)
    (cacheBound : DecodeChainSequenceRanges.CachesBound graph.stages cache)
    (inputBound : ResidualMlpRanges.InputBound 0 input) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : n+1≤262144) : DecodeChainSequenceRanges.CachesBound graph.stages execution.caches := by
  rw [execution.caches_eq]
  exact (Qwen38TrellisM1MaxSequenceRanges.checked graph parameters primitive cache cacheBound input inputBound angle angleBound supported).cacheBound

theorem Execution.logits_accuracy (execution : Execution graph cache input angle sampling)
    (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters graph)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives graph)
    (cacheBound : DecodeChainSequenceRanges.CachesBound graph.stages cache)
    (inputBound : ResidualMlpRanges.InputBound 0 input) (angleBound : RopeAnglesRanges.InputsBound angle)
    (supported : n+1≤262144) (ct ce : graph.ReferenceCache n)
    (cacheError : DecodeChain.CacheErrors graph.stages cache ct ce)
    (target error : Row ℝ) (inputError : ∀ i, |Model.toReal (input i)-target i|≤error i)
    (aim ae : RopeAngles.Target) (angleError : RopeAngles.InputError angle aim ae) (base : 0≤aim.base) :
    ∀ i, |Model.toReal (execution.forward.logits i)-graph.target ct target aim i|≤
      graph.budget cache ct ce input target error angle aim ae
        (Qwen38TrellisM1MaxSequenceRanges.checked graph parameters primitive cache cacheBound input inputBound angle angleBound supported).finite i := by
  rw [execution.forward.logits_eq]
  exact (Qwen38TrellisM1MaxSequenceRanges.run_correct graph parameters primitive cache cacheBound input inputBound angle angleBound
    supported ct ce cacheError target error inputError aim ae angleError base).1

structure Safe (execution : Execution graph cache input angle sampling) (base size : Nat) : Prop where
  forward : Qwen38TrellisM1MaxMemory.Safe execution.forward base size
  sampling : execution.sampler.Safe base size

theorem Execution.other_region (execution : Execution graph cache input angle sampling) (safe : Safe execution base size)
    (offset : Nat) (bound : offset<size) : execution.memory (base+offset)=execution.forward.source.bytes (base+offset) :=
  (execution.sampler.other_region safe.sampling offset bound).trans (execution.forward.other_region safe.forward offset bound)

-- Preserve a parameter buffer through both graph execution and all sampler
-- writes, retaining the final global heap rather than a reconstructed image.
def Execution.preserveBF {values : Fin count → BF} (execution : Execution graph cache input angle sampling)
    (buffer : ArrayStorage.BFBuffer values) (shared : buffer.bytes=execution.forward.source.bytes)
    (safe : Safe execution buffer.base (2*count)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf buffer execution.memory (fun offset bound => (execution.other_region safe offset bound).trans (congrFun shared _).symm)

end Inference.Models.Qwen.Qwen38TrellisM1MaxSamplingMemory
