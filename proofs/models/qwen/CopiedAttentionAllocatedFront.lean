import models.qwen.CopiedAttentionRopeAllocation
import state.KvAppendMemory
namespace Inference.Models.Qwen.CopiedAttentionAllocatedFront
open Contracts.Mlx Layers Kernels Kernels.Attention State
set_option maxRecDepth 10000

private theorem donated_query {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    {copy : AttentionGateCopyQueryMemory.Execution phase} {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
    (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) :
    (AttentionGateCopyRopeMemory.donation normal angle).query.destination=2*copy.destination := rfl
private theorem donated_key {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    {copy : AttentionGateCopyQueryMemory.Execution phase} {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
    (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs) :
    (AttentionGateCopyRopeMemory.donation normal angle).key.destination=phase.keyBuffer.base := rfl

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (w : CopiedAttentionProjectionAllocation.Workspace source weights)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes))
  (queryDispatch : layer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs)

def front := CopiedAttentionFrontConstruction.execution weights (CopiedAttentionProjectionAllocation.plan w)
  (CopiedAttentionProjectionAllocation.queryAllocation w) original protectedParameters
  (CopiedAttentionRopeAllocation.native weights w original protectedParameters queryDispatch keyDispatch angle)

theorem query_base (head : Fin 24) :
    ((front weights w original protectedParameters queryDispatch keyDispatch angle).query head).base=
      w.base+40960+2*(head.val*256) := by
  rw [AttentionGateCopyFront.Execution.query_base]
  change (AttentionGateCopyRopeMemory.donation (CopiedAttentionNormalizationAllocation.normal weights w original protectedParameters queryDispatch keyDispatch) angle).query.destination+2*(head.val*256)=_
  rw [donated_query]
  rw [CopiedAttentionNormalizationAllocation.query_base]

theorem gate_base (head : Fin 24) :
    ((front weights w original protectedParameters queryDispatch keyDispatch angle).gate head).base=
      w.base+24576+2*(head.val*256) := by
  rw [AttentionGateCopyFront.Execution.gate_base]
  change (CopiedAttentionProjectionConstruction.copy weights (CopiedAttentionProjectionAllocation.plan w)).base+2*(head.val*256)=_
  rw [CopiedAttentionProjectionConstruction.copy_base]
  rfl

theorem key_base :
    (front weights w original protectedParameters queryDispatch keyDispatch angle).keySource.base=w.base+36864 := by
  change (AttentionGateCopyRopeMemory.donation (CopiedAttentionNormalizationAllocation.normal weights w original protectedParameters queryDispatch keyDispatch) angle).key.destination=_
  rw [donated_key]
  exact CopiedAttentionNormalizationAllocation.key_base weights w

private theorem front_value_base {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    (front : AttentionGateCopyFront.Execution layer input angle) : front.valueSource.base=front.phase.valueBuffer.base := rfl

theorem value_base :
    (front weights w original protectedParameters queryDispatch keyDispatch angle).valueSource.base=w.base+38912 := by
  rw [front_value_base]
  change (CopiedAttentionProjectionConstruction.value weights (CopiedAttentionProjectionAllocation.plan w)).forwardBuffer.base=_
  rw [AttentionAffineConstruction.forward_base,CopiedAttentionProjectionConstruction.value_base]
  rfl

theorem key_span : KvAppendMemory.sourceBytes
    (front weights w original protectedParameters queryDispatch keyDispatch angle).keySource=2048 := rfl
theorem value_span : KvAppendMemory.sourceBytes
    (front weights w original protectedParameters queryDispatch keyDispatch angle).valueSource=2048 := rfl
end Inference.Models.Qwen.CopiedAttentionAllocatedFront
