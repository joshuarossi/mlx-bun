import models.qwen.CopiedAttentionAllocatedInitialRead
namespace Inference.Models.Qwen.CopiedAttentionAllocatedFrontFrame
open Contracts.Mlx Layers State Kernels Kernels.Attention
set_option maxRecDepth 10000
variable {layer : Attention.Layer} {input : Fin 5120 → ArrayStorage.BF} {source : ArrayStorage.BFBuffer input}
  (weights : AttentionAffineConstruction.Weights layer.projections source.bytes)
  (w : CopiedAttentionProjectionAllocation.Workspace source weights)
  (original : AttentionParameterMemory.Storage layer source.bytes)
  (protectedParameters : AttentionParameterMemory.Protected original
    (MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes))
  (queryDispatch : layer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs)

theorem safe {base size : Nat} (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size) :
    AttentionGateCopyFront.Safe
      (CopiedAttentionAllocatedFront.front weights w original protectedParameters queryDispatch keyDispatch angle) base size where
  phase := CopiedAttentionParameterConstruction.phase_safe weights (CopiedAttentionProjectionAllocation.plan w) separate
  queryCopy := (CopiedAttentionProjectionAllocation.queryAllocation w).safe base size separate
  normalization := CopiedAttentionNormalizationAllocation.safe weights w original protectedParameters queryDispatch keyDispatch separate
  rotation := CopiedAttentionRopeAllocation.safe weights w original protectedParameters queryDispatch keyDispatch angle separate

theorem frame {base size : Nat} (separate : MemoryRegions.Disjoint w.base CopiedAttentionProjectionAllocation.bytes base size)
    (offset : Nat) (bound : offset<size) :
    (CopiedAttentionAllocatedFront.front weights w original protectedParameters queryDispatch keyDispatch angle).memory (base+offset)=
      source.bytes (base+offset) := by
  have same := AttentionGateCopyPreservation.frame _
    (safe weights w original protectedParameters queryDispatch keyDispatch angle separate) offset bound
  have linked := CopiedAttentionFrontConstruction.original_source weights (CopiedAttentionProjectionAllocation.plan w)
    (CopiedAttentionProjectionAllocation.queryAllocation w) original protectedParameters
    (CopiedAttentionRopeAllocation.native weights w original protectedParameters queryDispatch keyDispatch angle)
  exact same.trans (congrArg (fun buffer : ArrayStorage.BFBuffer input => buffer.bytes (base+offset)) linked)

variable (aligned : w.base%16=0)
  (room : w.base+CopiedAttentionProjectionAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes≤2^64)

theorem initial_frame (cache : Kv.Cache Kv.BF 0) {base size : Nat} (below : base+size≤w.base)
    (offset : Nat) (bound : offset<size) :
    (CopiedAttentionAllocatedInitialRead.read weights w original protectedParameters queryDispatch keyDispatch angle aligned room cache).input.cache.memory (base+offset)=
      source.bytes (base+offset) :=
  (CopiedAttentionAllocatedInitialRead.frame weights w original protectedParameters queryDispatch keyDispatch angle aligned room cache below offset bound).trans
    (frame weights w original protectedParameters queryDispatch keyDispatch angle (Or.inr below) offset bound)
end Inference.Models.Qwen.CopiedAttentionAllocatedFrontFrame
