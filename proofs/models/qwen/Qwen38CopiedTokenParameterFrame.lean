import models.qwen.Qwen38CopiedTokenState
import models.qwen.TokenParameterConstruction

namespace Inference.Models.Qwen.Qwen38CopiedTokenParameterFrame
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : Qwen38CopiedTokenState.Step p sampling before angle)

-- These are the actual writes of the retained embedding, copied chain,
-- final normalization/projection and sampler. This proves preservation of
-- the original parameter bundle; attaching every copied layer to that
-- same bundle is a separate constructor obligation.
def Safe (base size : Nat) : Prop :=
  step.execution.embedding.regions.Live base size ∧
  CopiedAttentionDecodeChain.Safe p.graph.stages before.logical.cache (p.embedding.forward before.logical.token)
    angle step.execution.decode.forward.source step.execution.decode.forward.storage step.execution.decode.forward.chain base size ∧
  MemoryRegions.Disjoint (2*step.execution.decode.forward.allocation.normBase) 10240 base size ∧
  MemoryRegions.Disjoint step.execution.decode.forward.allocation.outputBase 496640 base size ∧
  Qwen38CopiedTokenCache.Region step.execution base size

theorem frame (safe : Safe step base size) (offset : Nat) (bound : offset<size) :
    step.execution.decode.sampler.memory (base+offset)=before.index.bytes (base+offset) := by
  have sampler := Qwen38CopiedAttentionSamplerSource.preserve_region step.execution.decode safe.2.2.2.2 offset bound
  have final := FinalProjectionConstruction.other_region step.execution.decode.forward.finalParameters
    step.execution.decode.forward.allocation safe.2.2.1 safe.2.2.2.1 offset bound
  have hidden := congrArg (fun buffer => buffer.bytes (base+offset)) step.execution.decode.forward.linked
  have chain := CopiedAttentionDecodeChain.other_region p.graph.stages before.logical.cache
    (p.embedding.forward before.logical.token) angle step.execution.decode.forward.source
    step.execution.decode.forward.storage step.execution.decode.forward.chain base size safe.2.1 offset bound
  have entry := congrArg (fun buffer => buffer.bytes (base+offset)) step.execution.linked
  have embedding := (congrFun step.execution.embedding.buffers_shared.1 (base+offset)).trans
    (step.execution.embedding.other_region safe.1 offset bound)
  exact sampler.trans (final.trans (hidden.trans (chain.trans (entry.trans
    (embedding.trans (congrFun (Qwen38CopiedTokenState.entry_heap step) (base+offset)))))))

variable (original : TokenParameterMemory.Storage p before.index.bytes)
  (safe : original.Protected (Safe step))

def after : TokenParameterMemory.Storage p step.execution.decode.sampler.memory :=
  original.reframe _ (original.protected_mono (fun _ _ live => frame step live) safe)

theorem parameters_preserved (property : Nat → Nat → Prop) :
    (after step original safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

include safe in
theorem original_bytes (region : TokenParameterConstruction.Region original base size)
    (offset : Nat) (bound : offset<size) :
    step.execution.decode.sampler.memory (base+offset)=before.index.bytes (base+offset) :=
  frame step (region (Safe step) safe) offset bound

theorem embedding_bases :
    (after step original safe).embedding.packedBase=original.embedding.packedBase ∧
    (after step original safe).embedding.scales.base=original.embedding.scales.base ∧
    (after step original safe).embedding.biases.base=original.embedding.biases.base := ⟨rfl,rfl,rfl⟩

end Inference.Models.Qwen.Qwen38CopiedTokenParameterFrame
