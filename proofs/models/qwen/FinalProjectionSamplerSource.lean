import models.qwen.FinalProjectionParsedSource
import kernels.sampling.NormalizedArgmaxAllocation
import kernels.sampling.LogSumExpSamplerSource
namespace Inference.Models.Qwen.FinalProjectionSamplerSource
open Contracts.Mlx Layers Kernels.Sampling
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
variable {norm : Blocks.Norm} {projection : AffineVerifyLinear.Projection 10 248320}
  {input : Fin 5120 → ArrayStorage.BF}

def logitsBuffer (storage : FinalProjectionConstruction.Storage norm projection input)
    (allocation : FinalProjectionConstruction.Allocation storage) :=
  (FinalProjectionConstruction.output storage allocation).outputBuffer
attribute [local irreducible] logitsBuffer FinalProjectionConstruction.output

structure Execution (storage : FinalProjectionConstruction.Storage norm projection input)
    (allocation : FinalProjectionConstruction.Allocation storage) (sampling : LogSumExpRanges.Platform) where
  workspace : NormalizedArgmaxAllocation.Workspace (logitsBuffer storage allocation)
  lseLocal : ByteMemory.Bytes
  tileLocal : Fin 243 → ByteMemory.Bytes
  finishLocal : ByteMemory.Bytes

variable {storage : FinalProjectionConstruction.Storage norm projection input}
  {allocation : FinalProjectionConstruction.Allocation storage} {sampling : LogSumExpRanges.Platform}
  (execution : Execution storage allocation sampling)

def Execution.sampler := execution.workspace.pipeline sampling execution.lseLocal execution.tileLocal execution.finishLocal

def Execution.logits (_execution : Execution storage allocation sampling) := (FinalProjectionConstruction.output storage allocation).output

theorem Execution.logits_eq : execution.logits=projection.forward (norm.forward input) := FinalProjectionConstruction.output_eq storage allocation

theorem Execution.logits_bound
    (bound : ∀ i, Model.isFinite (projection.forward (norm.forward input) i)=true ∧
      |Model.toReal (projection.forward (norm.forward input) i)| ≤ (2:ℝ)^(23:Nat)) :
    ∀ i, Model.isFinite (execution.logits i)=true ∧ |Model.toReal (execution.logits i)| ≤ (2:ℝ)^(23:Nat) := by
  rw [execution.logits_eq]
  exact bound

structure Certificate (native : FinalProjectionParsedSource.Native storage allocation) (lseNative : LogSumExpSourceHost.Attachment) : Prop where
  projection : FinalProjectionParsedSource.Certificate storage allocation native
  sampling : LogSumExpSamplerSource.Certificate execution.sampler.selection lseNative

theorem checked (native : FinalProjectionParsedSource.Native storage allocation)
    (finite : projection.Finite (norm.forward input)) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (projection.forward (norm.forward input) i)=true ∧
      |Model.toReal (projection.forward (norm.forward input) i)| ≤ (2:ℝ)^(23:Nat)) : Certificate execution native lseNative :=
  ⟨FinalProjectionParsedSource.checked storage allocation native finite,
    LogSumExpSamplerSource.checked execution.sampler.selection lseNative primitive (execution.logits_bound bound)⟩

theorem normalizer_heap (lseNative : LogSumExpSourceHost.Attachment) :
    LogSumExpSamplerSource.nativeMemory execution.sampler.lse=some execution.sampler.selection.partials.before :=
  LogSumExpSamplerSource.consumer_heap execution.sampler.selection lseNative

theorem normalizer_read (lseNative : LogSumExpSourceHost.Attachment) (stores : List ByteMemory.Store)
    (subset : ∀ store∈stores,store∈execution.sampler.selection.partials.schedule) :
    LogSumExpSamplerSource.nativeValue execution.sampler.lse=(execution.sampler.selection.lseDuring stores subset).read 0 :=
  LogSumExpSamplerSource.consumer_read execution.sampler.selection lseNative stores subset

theorem source_token (native : FinalProjectionParsedSource.Native storage allocation)
    (finite : projection.Finite (norm.forward input)) (lseNative : LogSumExpSourceHost.Attachment)
    (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (projection.forward (norm.forward input) i)=true ∧
      |Model.toReal (projection.forward (norm.forward input) i)| ≤ (2:ℝ)^(23:Nat)) :
    Certificate execution native lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (projection.forward (norm.forward input))) := by
  refine ⟨checked execution native finite lseNative primitive bound,?_⟩
  have result := (LogSumExpSamplerSource.source_token execution.sampler.selection lseNative primitive (execution.logits_bound bound)).2
  change _=some (GreedySampling.sample sampling execution.logits) at result
  rw [execution.logits_eq] at result
  exact result

theorem token_read (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (projection.forward (norm.forward input) i)=true ∧
      |Model.toReal (projection.forward (norm.forward input) i)| ≤ (2:ℝ)^(23:Nat)) :
    (ByteMemory.load32 execution.sampler.memory execution.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (projection.forward (norm.forward input)) := by
  change execution.sampler.selection.token=_
  have result := execution.sampler.token_eq primitive (execution.logits_bound bound)
  change _=GreedySampling.sample sampling execution.logits at result
  rw [execution.logits_eq] at result
  exact result

theorem lowest_index (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (projection.forward (norm.forward input) i)=true ∧
      |Model.toReal (projection.forward (norm.forward input) i)| ≤ (2:ℝ)^(23:Nat)) :
    ∃ selected : Fin 248320, execution.sampler.selection.token=selected.val ∧
      (∀ i, GreedySampling.score sampling (projection.forward (norm.forward input)) i ≤
        GreedySampling.score sampling (projection.forward (norm.forward input)) selected) ∧
      (∀ i, GreedySampling.score sampling (projection.forward (norm.forward input)) selected=
        GreedySampling.score sampling (projection.forward (norm.forward input)) i → selected.val ≤ i.val) := by
  have result := execution.sampler.correct primitive (execution.logits_bound bound)
  change ∃ selected : Fin 248320, execution.sampler.selection.token=selected.val ∧
    (∀ i, GreedySampling.score sampling execution.logits i ≤ GreedySampling.score sampling execution.logits selected) ∧
    (∀ i, GreedySampling.score sampling execution.logits selected=GreedySampling.score sampling execution.logits i → selected.val ≤ i.val) at result
  rw [execution.logits_eq] at result
  exact result

theorem preserve_region
    (safe : MemoryRegions.Disjoint execution.workspace.base NormalizedArgmaxAllocation.bytes base size)
    (offset : Nat) (inside : offset<size) :
    execution.sampler.memory (base+offset)=(logitsBuffer storage allocation).bytes (base+offset) :=
  execution.workspace.other_region sampling execution.lseLocal execution.tileLocal execution.finishLocal safe offset inside
end Inference.Models.Qwen.FinalProjectionSamplerSource
