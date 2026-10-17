import models.qwen.CapacityCopiedTokenResult
import models.qwen.TokenParameterConstruction
namespace Inference.Models.Qwen.CapacityCopiedTokenParameterFrame
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token angle)

-- Covers the actual retained writes, including full capacity preservation
-- copies. Native descriptor attachment to this original bundle is separate.
def Safe (base size : Nat) : Prop :=
  execution.embedding.regions.Live base size ∧
  CapacityAttentionDecodeChain.Safe p.graph.stages cache (p.embedding.forward token) angle
    execution.forward.source execution.forward.storage execution.forward.chain base size ∧
  MemoryRegions.Disjoint (2*execution.forward.allocation.normBase) 10240 base size ∧
  MemoryRegions.Disjoint execution.forward.allocation.outputBase 496640 base size ∧
  MemoryRegions.Disjoint execution.final.workspace.base NormalizedArgmaxAllocation.bytes base size

theorem frame (safe : Safe execution base size) (offset : Nat) (bound : offset<size) :
    execution.final.sampler.memory (base+offset)=execution.embedding.tokenBuffer.bytes (base+offset) := by
  have sampler := FinalProjectionSamplerSource.preserve_region execution.final safe.2.2.2.2 offset bound
  have final := FinalProjectionConstruction.other_region execution.forward.finalParameters
    execution.forward.allocation safe.2.2.1 safe.2.2.2.1 offset bound
  have hidden := congrArg (fun buffer => buffer.bytes (base+offset)) execution.forward.linked
  have chain := CapacityAttentionDecodeChain.other_region p.graph.stages cache (p.embedding.forward token) angle
    execution.forward.source execution.forward.storage execution.forward.chain base size safe.2.1 offset bound
  have entry := congrArg (fun buffer => buffer.bytes (base+offset)) execution.linked
  have embedding := (congrFun execution.embedding.buffers_shared.1 (base+offset)).trans
    (execution.embedding.other_region safe.1 offset bound)
  exact sampler.trans (final.trans (hidden.trans (chain.trans (entry.trans embedding))))

variable (original : TokenParameterMemory.Storage p execution.embedding.tokenBuffer.bytes)
  (safe : original.Protected (Safe execution))

def after : TokenParameterMemory.Storage p execution.final.sampler.memory :=
  original.reframe _ (original.protected_mono (fun _ _ live => frame execution live) safe)

theorem parameters_preserved (property : Nat → Nat → Prop) :
    (after execution original safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

include safe in
theorem original_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    execution.final.sampler.memory (base+offset)=execution.embedding.tokenBuffer.bytes (base+offset) :=
  frame execution (region (Safe execution) safe) offset bound

theorem embedding_bases :
    (after execution original safe).embedding.packedBase=original.embedding.packedBase ∧
    (after execution original safe).embedding.scales.base=original.embedding.scales.base ∧
    (after execution original safe).embedding.biases.base=original.embedding.biases.base := ⟨rfl,rfl,rfl⟩
end Inference.Models.Qwen.CapacityCopiedTokenParameterFrame
