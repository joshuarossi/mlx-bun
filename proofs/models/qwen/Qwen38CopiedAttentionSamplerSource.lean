import models.qwen.FinalProjectionParsedSource
import models.qwen.Qwen38CopiedAttentionExecution
import kernels.sampling.NormalizedArgmaxAllocation
import kernels.sampling.LogSumExpSamplerSource
namespace Inference.Models.Qwen.Qwen38CopiedAttentionSamplerSource
open Contracts.Mlx DecodeStage DecodeChain Kernels.Sampling Kernels.Attention Qwen38TrellisM1Max
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Graph.stages Qwen38CopiedAttentionExecution.logitsBuffer

-- This retains the copied-attention execution itself. The allocation supplies
-- only native addresses, spatial ownership, and initial threadgroup memories.
structure Execution (graph : Graph) (cache : graph.Cache n) (input : Row ArrayStorage.BF)
    (angle : RopeAngles.Inputs) (sampling : LogSumExpRanges.Platform) where
  forward : Qwen38CopiedAttentionExecution.Execution graph cache input angle
  workspace : NormalizedArgmaxAllocation.Workspace (Qwen38CopiedAttentionExecution.logitsBuffer forward)
  lseLocal : ByteMemory.Bytes
  tileLocal : Fin 243 → ByteMemory.Bytes
  finishLocal : ByteMemory.Bytes

variable {graph : Graph} {cache : graph.Cache n} {input : Row ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {sampling : LogSumExpRanges.Platform}

def Execution.sampler (execution : Execution graph cache input angle sampling) :=
  execution.workspace.pipeline sampling execution.lseLocal execution.tileLocal execution.finishLocal

def Execution.logits (execution : Execution graph cache input angle sampling) :=
  (Qwen38CopiedAttentionExecution.projection execution.forward).output

theorem Execution.logits_eq (execution : Execution graph cache input angle sampling) :
    execution.logits=graph.forward cache input angle := by
  funext column
  exact (ArrayStorage.BFBuffer.read_correct (Qwen38CopiedAttentionExecution.logitsBuffer execution.forward) column).symm.trans
    (Qwen38CopiedAttentionExecution.read_eq execution.forward column)

-- The finite envelope is on the original model function, not on a supplied
-- native result. The generic copied-model parameter bundle remains explicit.
theorem Execution.logits_bound (execution : Execution graph cache input angle sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) :
    ∀ i, Model.isFinite (execution.logits i)=true ∧ |Model.toReal (execution.logits i)| ≤ (2:ℝ)^(23:Nat) := by
  rw [execution.logits_eq]
  exact bound

structure Certificate (execution : Execution graph cache input angle sampling)
    (native : CopiedAttentionChainParsed.Native graph.stages cache input angle execution.forward.source
      execution.forward.storage execution.forward.chain) (lseNative : LogSumExpSourceHost.Attachment) : Prop where
  copied : CopiedAttentionChainParsed.Parsed graph.stages cache input angle execution.forward.source
    execution.forward.storage execution.forward.chain native
  sampling : LogSumExpSamplerSource.Certificate execution.sampler.selection lseNative

theorem checked (execution : Execution graph cache input angle sampling)
    (native : CopiedAttentionChainParsed.Native graph.stages cache input angle execution.forward.source
      execution.forward.storage execution.forward.chain) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) : Certificate execution native lseNative :=
  ⟨CopiedAttentionChainParsed.checked _ _ _ _ _ _ _ native,
    LogSumExpSamplerSource.checked execution.sampler.selection lseNative primitive (execution.logits_bound bound)⟩

-- Every sampler load is attached to the actual final projection allocation.
theorem projection_heap (execution : Execution graph cache input angle sampling) :
    (Qwen38CopiedAttentionExecution.logitsBuffer execution.forward).bytes=
      HalfMemory.execute (Qwen38CopiedAttentionExecution.projection execution.forward).stores
        (Qwen38CopiedAttentionExecution.projection execution.forward).source.bytes :=
  by simpa only [Qwen38CopiedAttentionExecution.logitsBuffer] using
    (Qwen38CopiedAttentionExecution.projection execution.forward).memory

theorem lse_to_argmax (execution : Execution graph cache input angle sampling) (lseNative : LogSumExpSourceHost.Attachment) :
    LogSumExpSamplerSource.nativeMemory execution.sampler.lse=some execution.sampler.selection.partials.before :=
  LogSumExpSamplerSource.consumer_heap execution.sampler.selection lseNative

theorem normalizer_read (execution : Execution graph cache input angle sampling) (lseNative : LogSumExpSourceHost.Attachment)
    (stores : List ByteMemory.Store) (subset : ∀ store∈stores,store∈execution.sampler.selection.partials.schedule) :
    LogSumExpSamplerSource.nativeValue execution.sampler.lse=(execution.sampler.selection.lseDuring stores subset).read 0 :=
  LogSumExpSamplerSource.consumer_read execution.sampler.selection lseNative stores subset

-- Read the parsed final uint32 store from the resulting heap. No requested
-- token, expected intermediate, or expected output buffer is supplied.
theorem source_token (execution : Execution graph cache input angle sampling)
    (native : CopiedAttentionChainParsed.Native graph.stages cache input angle execution.forward.source
      execution.forward.storage execution.forward.chain) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate execution native lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (graph.forward cache input angle)) := by
  refine ⟨checked execution native lseNative primitive bound,?_⟩
  have result := (LogSumExpSamplerSource.source_token execution.sampler.selection lseNative primitive
    (execution.logits_bound bound)).2
  change _=some (GreedySampling.sample sampling execution.logits) at result
  rw [execution.logits_eq] at result
  exact result

theorem token_read (execution : Execution graph cache input angle sampling)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 execution.sampler.memory execution.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (graph.forward cache input angle) := by
  change execution.sampler.selection.token=_
  have result := execution.sampler.token_eq primitive (execution.logits_bound bound)
  change _=GreedySampling.sample sampling execution.logits at result
  rw [execution.logits_eq] at result
  exact result

theorem lowest_index (execution : Execution graph cache input angle sampling)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ selected : Fin 248320, execution.sampler.selection.token=selected.val ∧
      (∀ i, GreedySampling.score sampling (graph.forward cache input angle) i ≤
        GreedySampling.score sampling (graph.forward cache input angle) selected) ∧
      (∀ i, GreedySampling.score sampling (graph.forward cache input angle) selected=
        GreedySampling.score sampling (graph.forward cache input angle) i → selected.val ≤ i.val) := by
  have result := execution.sampler.correct primitive (execution.logits_bound bound)
  change ∃ selected : Fin 248320, execution.sampler.selection.token=selected.val ∧
    (∀ i, GreedySampling.score sampling execution.logits i ≤ GreedySampling.score sampling execution.logits selected) ∧
    (∀ i, GreedySampling.score sampling execution.logits selected=GreedySampling.score sampling execution.logits i → selected.val ≤ i.val) at result
  rw [execution.logits_eq] at result
  exact result

-- Arbitrary live regions disjoint from the one 1952-byte sampler workspace
-- retain the actual projection heap, including parameter/cache attachments.
theorem preserve_region (execution : Execution graph cache input angle sampling)
    (safe : MemoryRegions.Disjoint execution.workspace.base NormalizedArgmaxAllocation.bytes base size)
    (offset : Nat) (inside : offset<size) :
    execution.sampler.memory (base+offset)=
      (Qwen38CopiedAttentionExecution.logitsBuffer execution.forward).bytes (base+offset) :=
  execution.workspace.other_region sampling execution.lseLocal execution.tileLocal execution.finishLocal safe offset inside

-- The final RMS/projection consumes the exact retained copied-chain output.
theorem projection_input (execution : Execution graph cache input angle sampling) :
    execution.forward.finalParameters.source=CopiedAttentionDecodeChain.outputBuffer graph.stages cache input angle
      execution.forward.source execution.forward.storage execution.forward.chain := execution.forward.linked

-- One certificate includes the copied stages, final RMS and either native
-- three/four-bit head, both sampler launches, and the actual token readback.
-- The generic copied route and its native parameter/finite attachments remain
-- visible; this does not assert checkpoint-specific global parameter bounds.
theorem complete_source_token (execution : Execution graph cache input angle sampling)
    (native : CopiedAttentionChainParsed.Native graph.stages cache input angle execution.forward.source
      execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (finalFinite : graph.output.Finite (graph.finalNorm.forward (graph.hidden cache input angle)))
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (graph.forward cache input angle i)=true ∧
      |Model.toReal (graph.forward cache input angle i)| ≤ (2:ℝ)^(23:Nat)) :
    FinalProjectionParsedSource.Certificate execution.forward.finalParameters execution.forward.allocation finalNative ∧
      Certificate execution native lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (graph.forward cache input angle)) :=
  ⟨FinalProjectionParsedSource.checked execution.forward.finalParameters execution.forward.allocation finalNative finalFinite,
    source_token execution native lseNative primitive bound⟩
end Inference.Models.Qwen.Qwen38CopiedAttentionSamplerSource
