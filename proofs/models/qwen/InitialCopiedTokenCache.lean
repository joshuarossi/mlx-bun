import models.qwen.InitialCopiedTokenSource
import models.qwen.Qwen38InitialCopiedCache
namespace Inference.Models.Qwen.InitialCopiedTokenCache
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache 0}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : InitialCopiedTokenSource.Execution p sampling cache token angle)
  (safe : Qwen38InitialCopiedCache.Safe execution.forward)

def before := Qwen38InitialCopiedCache.after execution.forward safe

def WorkspaceSafe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.final.workspace.base NormalizedArgmaxAllocation.bytes base size

def Safe : Prop := DecodePreservation.Protected (WorkspaceSafe execution) p.graph.stages
  (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
  (Qwen38InitialCopiedExecution.logitsBuffer execution.forward).bytes (before execution safe)

def after (preserved : Safe execution safe) : DecodeFrame.Storage p.graph.stages
    (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2 execution.final.sampler.memory :=
  DecodePreservation.reframe (WorkspaceSafe execution)
    (Qwen38InitialCopiedExecution.logitsBuffer execution.forward).bytes execution.final.sampler.memory
    (fun _ _ region => FinalProjectionSamplerSource.preserve_region execution.final region)
    p.graph.stages (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
    (before execution safe) preserved

def readResult (preserved : Safe execution safe) : Nat × p.graph.Cache 1 :=
  ⟨(ByteMemory.load32 execution.final.sampler.memory execution.final.sampler.selection.destination).toNat,
    DecodeFrameRead.caches p.graph.stages (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
      execution.final.sampler.memory (after execution safe preserved)⟩

theorem read_result_eq (preserved : Safe execution safe) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token angle).1,(p.run cache token angle).2) :=
  Prod.ext (InitialCopiedTokenSource.token_read execution primitive bound) (DecodeFrameRead.caches_eq _ _ _ _)

-- Every retained updated cache view reads this same post-sampler heap.
theorem cache_read (preserved : Safe execution safe) :
    (readResult execution safe preserved).2=(p.run cache token angle).2 := DecodeFrameRead.caches_eq _ _ _ _

theorem owned (preserved : Safe execution safe) (allocator : AllocatorOwnership.State)
    (original : CacheOwnership.OwnedCaches allocator p.graph.stages (p.run cache token angle).2
      (Qwen38InitialCopiedExecution.logitsBuffer execution.forward).bytes (before execution safe)) :
    CacheOwnership.OwnedCaches allocator p.graph.stages (p.run cache token angle).2
      execution.final.sampler.memory (after execution safe preserved) :=
  DecodePreservation.preserves_ownership allocator (WorkspaceSafe execution)
    (Qwen38InitialCopiedExecution.logitsBuffer execution.forward).bytes execution.final.sampler.memory
    (fun _ _ region => FinalProjectionSamplerSource.preserve_region execution.final region)
    p.graph.stages (p.run cache token angle).2 (before execution safe) preserved original
end Inference.Models.Qwen.InitialCopiedTokenCache
