import models.qwen.CopiedAttentionNormalizationAllocation
import models.qwen.CopiedAttentionFrontConstruction
namespace Inference.Models.Qwen.CopiedAttentionRopeAllocation
open Contracts.Mlx Layers Kernels Kernels.Attention
open CopiedAttentionNormalizationAllocation
set_option maxRecDepth 10000

private theorem donated_safe {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    {copy : AttentionGateCopyQueryMemory.Execution phase} {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
    (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs)
    {base size : Nat} (safe : AttentionGateCopyNormalizationMemory.Safe normal base size) :
    AttentionGateCopyRopeMemory.Safe (AttentionGateCopyRopeMemory.donation normal angle) base size := safe

private theorem donated_gate {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    {copy : AttentionGateCopyQueryMemory.Execution phase} {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
    (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs)
    (head : Fin 24) (safe : AttentionGateCopyNormalizationMemory.Safe normal (copy.gate head).base 512) :
    AttentionGateCopyRopeMemory.Safe (AttentionGateCopyRopeMemory.donation normal angle) (normal.gate head safe).base 512 :=
  donated_safe normal angle safe
private theorem donated_value {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {phase : AttentionGateCopyKvMemory.Execution layer.projections input}
    {copy : AttentionGateCopyQueryMemory.Execution phase} {parameters : AttentionParameterMemory.Storage layer copy.copy.memory}
    (normal : AttentionGateCopyNormalizationMemory.Execution copy parameters) (angle : RopeAngles.Inputs)
    (copySafe : MemoryRegions.Disjoint (2*copy.destination) 12288 phase.valueBuffer.base 2048)
    (safe : AttentionGateCopyNormalizationMemory.Safe normal phase.valueBuffer.base 2048) :
    AttentionGateCopyRopeMemory.Safe (AttentionGateCopyRopeMemory.donation normal angle) (normal.valueBuffer copySafe safe).base 2048 :=
  donated_safe normal angle safe

variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (w : CopiedAttentionProjectionAllocation.Workspace source weights)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes))
  (queryDispatch : layer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs)

def rope := AttentionGateCopyRopeMemory.donation (normal weights w original protectedParameters queryDispatch keyDispatch) angle

theorem safe {base size : Nat} (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size) :
    AttentionGateCopyRopeMemory.Safe (rope weights w original protectedParameters queryDispatch keyDispatch angle) base size :=
  donated_safe _ angle (CopiedAttentionNormalizationAllocation.safe weights w original protectedParameters queryDispatch keyDispatch separate)

private theorem gate_base (head : Fin 24) :
    ((copy weights w).gate head).base=w.base+24576+2*(head.val*256) := rfl

private theorem value_base : (phase weights w).valueBuffer.base=w.base+38912 :=
  (AttentionAffineConstruction.forward_base _).trans
    (CopiedAttentionProjectionConstruction.value_base weights (CopiedAttentionProjectionAllocation.plan w))

theorem gate_safe (head : Fin 24) :
    AttentionGateCopyNormalizationMemory.Safe (normal weights w original protectedParameters queryDispatch keyDispatch)
      ((copy weights w).gate head).base 512 := by
  change MemoryRegions.Disjoint (2*(copy weights w).destination) 12288 _ 512 ∧
    MemoryRegions.Disjoint (phase weights w).keyBuffer.base 2048 _ 512
  rw [query_base,key_base,gate_base]
  have := head.isLt
  constructor <;> exact Or.inr (by omega)

theorem value_safe :
    AttentionGateCopyNormalizationMemory.Safe (normal weights w original protectedParameters queryDispatch keyDispatch)
      (phase weights w).valueBuffer.base 2048 := by
  change MemoryRegions.Disjoint (2*(copy weights w).destination) 12288 _ 2048 ∧
    MemoryRegions.Disjoint (phase weights w).keyBuffer.base 2048 _ 2048
  rw [query_base,key_base,value_base]
  exact ⟨Or.inr (by omega),Or.inl (by omega)⟩

def native : CopiedAttentionFrontConstruction.Native weights (CopiedAttentionProjectionAllocation.plan w)
    (CopiedAttentionProjectionAllocation.queryAllocation w) original protectedParameters angle where
  normal := normal weights w original protectedParameters queryDispatch keyDispatch
  rope := rope weights w original protectedParameters queryDispatch keyDispatch angle
  normalGateSafe := gate_safe weights w original protectedParameters queryDispatch keyDispatch
  gateSafe := fun head => donated_gate _ angle head (gate_safe weights w original protectedParameters queryDispatch keyDispatch head)
  copyValueSafe := by
    change MemoryRegions.Disjoint (2*(copy weights w).destination) 12288 (phase weights w).valueBuffer.base 2048
    rw [query_base,value_base]; exact Or.inr (by omega)
  normalValueSafe := value_safe weights w original protectedParameters queryDispatch keyDispatch
  valueSafe := donated_value _ angle _ (value_safe weights w original protectedParameters queryDispatch keyDispatch)
end Inference.Models.Qwen.CopiedAttentionRopeAllocation
