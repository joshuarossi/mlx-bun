import models.qwen.CopiedAttentionParameterConstruction
import models.qwen.AttentionGateCopyFront
namespace Inference.Models.Qwen.CopiedAttentionFrontConstruction
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {live : Nat → Nat → Prop}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (plan : CopiedAttentionProjectionConstruction.Plan layer.projections source weights live)
  (allocation : CopiedAttentionParameterConstruction.QueryAllocation weights plan)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original live)

structure Native (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
    (plan : CopiedAttentionProjectionConstruction.Plan layer.projections source weights live)
    (allocation : CopiedAttentionParameterConstruction.QueryAllocation weights plan)
    (original : AttentionParameterMemory.Storage layer source.bytes)
    (protectedParameters : AttentionParameterMemory.Protected original live) (angle : RopeAngles.Inputs) where
  normal : AttentionGateCopyNormalizationMemory.Execution
    (CopiedAttentionParameterConstruction.queryCopy weights plan allocation)
    (CopiedAttentionParameterConstruction.parameters weights plan allocation original protectedParameters)
  rope : AttentionGateCopyRopeMemory.Execution normal angle
  normalGateSafe : ∀ head, AttentionGateCopyNormalizationMemory.Safe normal
    ((CopiedAttentionParameterConstruction.queryCopy weights plan allocation).gate head).base 512
  gateSafe : ∀ head, AttentionGateCopyRopeMemory.Safe rope (normal.gate head (normalGateSafe head)).base 512
  copyValueSafe : MemoryRegions.Disjoint (2*allocation.destination) 12288
    (CopiedAttentionParameterConstruction.phase weights plan).valueBuffer.base 2048
  normalValueSafe : AttentionGateCopyNormalizationMemory.Safe normal
    (CopiedAttentionParameterConstruction.phase weights plan).valueBuffer.base 2048
  valueSafe : AttentionGateCopyRopeMemory.Safe rope (normal.valueBuffer copyValueSafe normalValueSafe).base 2048

variable (native : Native weights plan allocation original protectedParameters angle)
def execution : AttentionGateCopyFront.Execution layer input angle where
  phase := CopiedAttentionParameterConstruction.phase weights plan
  queryCopy := CopiedAttentionParameterConstruction.queryCopy weights plan allocation
  parameters := CopiedAttentionParameterConstruction.parameters weights plan allocation original protectedParameters
  normal := native.normal
  rope := native.rope
  normalGateSafe := native.normalGateSafe
  gateSafe := native.gateSafe
  copyValueSafe := native.copyValueSafe
  normalValueSafe := native.normalValueSafe
  valueSafe := native.valueSafe

theorem original_source : (execution weights plan allocation original protectedParameters native).phase.q.source=source :=
  CopiedAttentionParameterConstruction.phase_source weights plan

theorem memory : (execution weights plan allocation original protectedParameters native).memory=native.rope.memory := rfl

theorem current_parameters :
    (execution weights plan allocation original protectedParameters native).parameters=
      CopiedAttentionParameterConstruction.parameters weights plan allocation original protectedParameters := rfl
end Inference.Models.Qwen.CopiedAttentionFrontConstruction
