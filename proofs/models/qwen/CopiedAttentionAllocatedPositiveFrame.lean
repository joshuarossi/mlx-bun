import models.qwen.CopiedAttentionAllocatedPositiveRead
import models.qwen.AttentionGateCopyCapacityTrellisFrames
namespace Inference.Models.Qwen.CopiedAttentionAllocatedPositiveFrame
open Contracts.Mlx Layers State Kernels Kernels.Attention
open CopiedAttentionAllocatedPositiveInput CopiedAttentionAllocatedPositiveRead
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {values : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)
  {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
  (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base)
  (aligned : w.base%16=0) (positive : 0<n)

private theorem front_safe {base size : Nat} (below : base+size≤w.base) :
    AttentionGateCopyFront.Safe (front w queryDispatch keyDispatch angle) base size :=
  CopiedAttentionAllocatedFrontFrame.safe _ _ _ _ queryDispatch keyDispatch angle
    (Or.inr (below.trans (Nat.le_add_right _ _)))

theorem reuse_safe (reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (room : w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n≤2^64)
    {base size : Nat} (below : base+size≤w.base) :
    AttentionGateCopyCapacityTrellisFrames.Safe
      (reuseRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room) base size :=
  ⟨front_safe w queryDispatch keyDispatch angle below,True.intro,
    CopiedAttentionPositiveReuseAllocation.safe_below _ (below.trans (Nat.le_add_right _ _))⟩

theorem growth_safe (growing : KvAllocation.capacity n<n+1)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64)
    {base size : Nat} (below : base+size≤w.base) :
    AttentionGateCopyCapacityTrellisFrames.Safe
      (growthRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room) base size :=
  ⟨front_safe w queryDispatch keyDispatch angle below,
    CopiedAttentionGrowthPreparation.safe _ _ (Or.inr (below.trans (Nat.le_add_right _ _))),
    CopiedAttentionFreshAppendAllocation.safe_below _
      ((below.trans (Nat.le_add_right _ _)).trans (Nat.le_add_right _ _))⟩

private theorem normal_frame {base size : Nat} (below : base+size≤w.base) (offset : Nat) (bound : offset<size) :
    (front w queryDispatch keyDispatch angle).phase.q.source.bytes (base+offset)=source.bytes (base+offset) := by
  have linked : (front w queryDispatch keyDispatch angle).phase.q.source=NormalizationMemory.forwardBuffer (CopiedAttentionEntryAllocation.normal w) :=
    CopiedAttentionFrontConstruction.original_source (CopiedAttentionEntryAllocation.normalized w).projections
      (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w)
      (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1
      (CopiedAttentionRopeAllocation.native _ _ _ _ queryDispatch keyDispatch angle)
  exact (congrArg (fun buffer : ArrayStorage.BFBuffer (layer.inputNorm.forward values) => buffer.bytes (base+offset)) linked).trans
    (CopiedAttentionOriginalBundle.normalization_frame source original (CopiedAttentionEntryAllocation.normal w)
      (by change MemoryRegions.Disjoint (2*(w.base/2)) 10240 base size;
          rw [CopiedAttentionEntryAllocation.half_base]; exact Or.inr below) offset bound)

theorem reuse_frame (reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (room : w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n≤2^64)
    {base size : Nat} (below : base+size≤w.base) (offset : Nat) (bound : offset<size) :
    (reuseRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room).input.cache.memory (base+offset)=source.bytes (base+offset) :=
  (AttentionGateCopyCapacityTrellisFrames.frame _
    (reuse_safe w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room below) offset bound).trans
    (normal_frame w queryDispatch keyDispatch angle below offset bound)

theorem growth_frame (growing : KvAllocation.capacity n<n+1)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64)
    {base size : Nat} (below : base+size≤w.base) (offset : Nat) (bound : offset<size) :
    (growthRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room).input.cache.memory (base+offset)=source.bytes (base+offset) :=
  (AttentionGateCopyCapacityTrellisFrames.frame _
    (growth_safe w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room below) offset bound).trans
    (normal_frame w queryDispatch keyDispatch angle below offset bound)
end Inference.Models.Qwen.CopiedAttentionAllocatedPositiveFrame
