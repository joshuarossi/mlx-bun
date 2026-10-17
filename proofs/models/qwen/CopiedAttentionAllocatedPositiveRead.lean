import models.qwen.CopiedAttentionAllocatedPositiveInput
import models.qwen.CopiedAttentionPositiveReuseAllocation
import models.qwen.CopiedAttentionGrowthPreparation
import models.qwen.CopiedAttentionFreshReadHighWater
namespace Inference.Models.Qwen.CopiedAttentionAllocatedPositiveRead
open Contracts.Mlx Layers State Kernels Kernels.Attention
open CopiedAttentionAllocatedPositiveInput
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

def reuseRequest (reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (room : w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n≤2^64) :
    CopiedAttentionPositiveReuseAllocation.Request
      (input w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow) where
  positive := positive
  reuse := reuse
  cursor := w.base+CopiedAttentionEntryAllocation.bytes
  aligned := by unfold CopiedAttentionEntryAllocation.bytes; omega
  room := room
  oldKeys := by
    rw [old_layout,KvRegions.bytes,←reuse]
    exact keysBelow.trans (Nat.le_add_right _ _)
  oldValues := by
    rw [old_layout,KvRegions.bytes,←reuse]
    exact valuesBelow.trans (Nat.le_add_right _ _)
  keys := keys_end w queryDispatch keyDispatch angle
  values := values_end w queryDispatch keyDispatch angle
  queries := queries_end w queryDispatch keyDispatch angle
  gates := gates_end w queryDispatch keyDispatch angle

def reuseRead (reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (room : w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n≤2^64) :=
  CopiedAttentionPositiveReuseAllocation.read
    (reuseRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room)

def growthRequest (growing : KvAllocation.capacity n<n+1)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64) :
    CopiedAttentionGrowthPreparation.Request
      (input w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow) where
  positive := positive
  growing := growing
  cursor := w.base+CopiedAttentionEntryAllocation.bytes
  aligned := by unfold CopiedAttentionEntryAllocation.bytes; omega
  room := room
  oldKeys := by rw [old_layout]; exact keysBelow.trans (Nat.le_add_right _ _)
  oldValues := by rw [old_layout]; exact valuesBelow.trans (Nat.le_add_right _ _)
  keys := keys_end w queryDispatch keyDispatch angle
  values := values_end w queryDispatch keyDispatch angle
  queries := queries_end w queryDispatch keyDispatch angle
  gates := gates_end w queryDispatch keyDispatch angle

def growthRead (growing : KvAllocation.capacity n<n+1)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64) :=
  CopiedAttentionGrowthPreparation.read
    (growthRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room)

theorem reuse_bounds (reuse : KvAllocation.capacity n=KvAllocation.capacity (n+1))
    (room : w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n≤2^64) :
    CopiedAttentionReadHighWater.Bounds (reuseRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room).input
      (reuseRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room).gate
      (w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n) :=
  CopiedAttentionReadHighWater.Positive.bounds (reuseRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive reuse room)

theorem growth_bounds (growing : KvAllocation.capacity n<n+1)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+(KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n)≤2^64) :
    CopiedAttentionReadHighWater.Bounds (growthRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room).input
      (growthRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room).gate
      (w.base+CopiedAttentionEntryAllocation.bytes+KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n) :=
  CopiedAttentionFreshReadHighWater.growth_bounds (growthRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room)
end Inference.Models.Qwen.CopiedAttentionAllocatedPositiveRead
