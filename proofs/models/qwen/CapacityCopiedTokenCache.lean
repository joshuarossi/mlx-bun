import models.qwen.CapacityCopiedTokenSource
import models.qwen.Qwen38CapacityAttentionCache
namespace Inference.Models.Qwen.CapacityCopiedTokenCache
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token angle)
  (safe : Qwen38CapacityAttentionCache.Safe execution.forward)

def before := Qwen38CapacityAttentionCache.after execution.forward safe

def WorkspaceSafe (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.final.workspace.base NormalizedArgmaxAllocation.bytes base size

def Safe : Prop := DecodePreservation.Protected (WorkspaceSafe execution) p.graph.stages
  (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
  (Qwen38CapacityAttentionExecution.logitsBuffer execution.forward).bytes (before execution safe)

def after (preserved : Safe execution safe) : DecodeFrame.Storage p.graph.stages
    (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2 execution.final.sampler.memory :=
  DecodePreservation.reframe (WorkspaceSafe execution)
    (Qwen38CapacityAttentionExecution.logitsBuffer execution.forward).bytes execution.final.sampler.memory
    (fun _ _ region => FinalProjectionSamplerSource.preserve_region execution.final region)
    p.graph.stages (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
    (before execution safe) preserved

def readResult (preserved : Safe execution safe) : Nat × p.graph.Cache (n+1) :=
  ⟨(ByteMemory.load32 execution.final.sampler.memory execution.final.sampler.selection.destination).toNat,
    DecodeFrameRead.caches p.graph.stages (DecodeChain.run p.graph.stages cache (p.embedding.forward token) angle).2
      execution.final.sampler.memory (after execution safe preserved)⟩

theorem read_result_eq (preserved : Safe execution safe) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat)) :
    readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token angle).1,(p.run cache token angle).2) :=
  Prod.ext (CapacityCopiedTokenSource.token_read execution primitive bound) (DecodeFrameRead.caches_eq _ _ _ _)
end Inference.Models.Qwen.CapacityCopiedTokenCache
