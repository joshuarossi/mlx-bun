import models.qwen.CopiedAttentionEntryAllocation
import models.qwen.CopiedAttentionAllocatedFrontFrame
import models.qwen.CopiedAttentionOriginalCache
namespace Inference.Models.Qwen.CopiedAttentionAllocatedPositiveInput
open Contracts.Mlx Layers State Kernels Kernels.Attention
set_option maxRecDepth 10000
variable {layer : ResidualAttention.Layer} {values : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)
  {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
  (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base)

def front := CopiedAttentionAllocatedFront.front (CopiedAttentionEntryAllocation.normalized w).projections
  (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer
  (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle

include keysBelow in
theorem keys_normal : MemoryRegions.Disjoint
    (2*(CopiedAttentionEntryAllocation.normal w).normalized.base) 10240 storage.layout.keyBase (KvRegions.bytes n) := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 10240 _ _
  rw [CopiedAttentionEntryAllocation.half_base]
  exact Or.inr keysBelow

include valuesBelow in
theorem values_normal : MemoryRegions.Disjoint
    (2*(CopiedAttentionEntryAllocation.normal w).normalized.base) 10240 storage.layout.valueBase (KvRegions.bytes n) := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 10240 _ _
  rw [CopiedAttentionEntryAllocation.half_base]
  exact Or.inr valuesBelow

def input : AttentionGateCopyReadConstruction.Input layer.mixer cache (layer.inputNorm.forward values) angle where
  front := front w queryDispatch keyDispatch angle
  storage := CopiedAttentionOriginalCache.normalizedCache source original (CopiedAttentionEntryAllocation.normal w)
    storage shared (keys_normal w storage keysBelow) (values_normal w storage valuesBelow)
  shared := (congrArg ArrayStorage.BFBuffer.bytes
    (CopiedAttentionFrontConstruction.original_source (CopiedAttentionEntryAllocation.normalized w).projections
      (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w)
      (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1
      (CopiedAttentionRopeAllocation.native _ _ _ _ queryDispatch keyDispatch angle))).symm
  keysSafe := CopiedAttentionAllocatedFrontFrame.safe _ _ _ _ queryDispatch keyDispatch angle
    (Or.inr (keysBelow.trans (Nat.le_add_right _ _)))
  valuesSafe := CopiedAttentionAllocatedFrontFrame.safe _ _ _ _ queryDispatch keyDispatch angle
    (Or.inr (valuesBelow.trans (Nat.le_add_right _ _)))

theorem old_layout : (input w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow).oldAfter.layout=storage.layout := rfl

theorem keys_end : (front w queryDispatch keyDispatch angle).keySource.base+
    KvAppendMemory.sourceBytes (front w queryDispatch keyDispatch angle).keySource≤w.base+CopiedAttentionEntryAllocation.bytes := by
  unfold front
  rw [CopiedAttentionAllocatedFront.key_base (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle,CopiedAttentionAllocatedFront.key_span (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle]
  change w.base+10240+36864+2048≤w.base+63488
  omega

theorem values_end : (front w queryDispatch keyDispatch angle).valueSource.base+
    KvAppendMemory.sourceBytes (front w queryDispatch keyDispatch angle).valueSource≤w.base+CopiedAttentionEntryAllocation.bytes := by
  unfold front
  rw [CopiedAttentionAllocatedFront.value_base (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle,CopiedAttentionAllocatedFront.value_span (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle]
  change w.base+10240+38912+2048≤w.base+63488
  omega

theorem queries_end (head : Fin 24) : ((front w queryDispatch keyDispatch angle).query head).base+512≤w.base+CopiedAttentionEntryAllocation.bytes := by
  unfold front
  rw [CopiedAttentionAllocatedFront.query_base (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle head]
  change w.base+10240+40960+2*(head.val*256)+512≤w.base+63488
  have := head.isLt
  omega

theorem gates_end (head : Fin 24) : ((front w queryDispatch keyDispatch angle).gate head).base+512≤w.base+CopiedAttentionEntryAllocation.bytes := by
  unfold front
  rw [CopiedAttentionAllocatedFront.gate_base (layer:=layer.mixer) (CopiedAttentionEntryAllocation.normalized w).projections (CopiedAttentionEntryAllocation.projectionWorkspace w) (CopiedAttentionEntryAllocation.normalized w).mixer (CopiedAttentionEntryAllocation.projection_regions w).2.2.1 queryDispatch keyDispatch angle head]
  change w.base+10240+24576+2*(head.val*256)+512≤w.base+63488
  have := head.isLt
  omega
end Inference.Models.Qwen.CopiedAttentionAllocatedPositiveInput
