import models.qwen.CopiedAttentionAllocatedPositiveFrame
import models.qwen.ResidualDeltaHighWater
namespace Inference.Models.Qwen.CopiedAttentionAllocatedPositiveRoute
open Contracts.Mlx Layers State Kernels Kernels.Attention
open ResidualDeltaHighWater (Frontier)
set_option maxRecDepth 10000
set_option genSizeOf false
attribute [local irreducible] CopiedAttentionAllocatedPositiveInput.input

inductive Route (n : Nat) where
  | reuse (same : KvAllocation.capacity n=KvAllocation.capacity (n+1))
  | growth (growing : KvAllocation.capacity n<n+1)

def Route.selected (n : Nat) : Route n :=
  if room : n+1≤KvAllocation.capacity n then
    .reuse (by rw [KvAllocation.next_capacity,ite_eq_right (Nat.not_lt.mpr room)])
  else .growth (Nat.lt_of_not_ge room)

def Route.bytes : Route n → Nat
  | .reuse _ => CopiedAttentionPositiveReuseAllocation.bytes n
  | .growth _ => KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n

structure Result {layer : ResidualAttention.Layer} {values : Fin 5120 → ArrayStorage.BF}
    {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
    (w : CopiedAttentionEntryAllocation.Workspace source original)
    (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
    (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)
    {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
    (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
    (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base) where
  preparation : AttentionGateCopyFreshRead.Prepared
    (CopiedAttentionAllocatedPositiveInput.input w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow)
  read : AttentionGateCopyFreshRead.Read preparation
  frontier : Frontier
  bounds : CopiedAttentionReadHighWater.Bounds (n:=n+1)
    (query:=(layer.mixer.heads (layer.inputNorm.forward values) angle).query)
    (cache:=layer.mixer.cacheAfter (layer.inputNorm.forward values) angle cache)
    read.input read.gate frontier.cursor
  safe : ∀ base size, base+size≤w.base → AttentionGateCopyCapacityTrellisFrames.Safe (layer:=layer.mixer) (n:=n) (cache:=cache)
    (values:=layer.inputNorm.forward values) (angle:=angle) read base size

variable {layer : ResidualAttention.Layer} {values : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)
  {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
  (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base)
  (aligned : w.base%16=0) (positive : 0<n)

def execution : (route : Route n) →
    (room : w.base+CopiedAttentionEntryAllocation.bytes+route.bytes≤2^64) →
    Result w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow
  | .reuse same, room => {
    preparation := CopiedAttentionPositiveReuseAllocation.prepared
      (CopiedAttentionAllocatedPositiveRead.reuseRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive same room)
    read := CopiedAttentionAllocatedPositiveRead.reuseRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive same room
    frontier := ⟨w.base+CopiedAttentionEntryAllocation.bytes+CopiedAttentionPositiveReuseAllocation.bytes n,by
      have := aligned
      dsimp [CopiedAttentionEntryAllocation.bytes,CopiedAttentionPositiveReuseAllocation.bytes,KvRegions.bytes]
      omega⟩
    bounds := CopiedAttentionAllocatedPositiveRead.reuse_bounds w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive same room
    safe := fun _ _ below => CopiedAttentionAllocatedPositiveFrame.reuse_safe w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive same room below }
  | .growth growing, room => {
    preparation := CopiedAttentionGrowthPreparation.prepared
      (CopiedAttentionAllocatedPositiveRead.growthRequest w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room)
    read := CopiedAttentionAllocatedPositiveRead.growthRead w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room
    frontier := ⟨w.base+CopiedAttentionEntryAllocation.bytes+KvGrowthAllocation.bytes n+CopiedAttentionFreshAppendAllocation.bytes n,by
      have := aligned
      dsimp [CopiedAttentionEntryAllocation.bytes,KvGrowthAllocation.bytes,KvGrowthAllocation.tensorBytes,CopiedAttentionFreshAppendAllocation.bytes,KvRegions.bytes]
      omega⟩
    bounds := CopiedAttentionAllocatedPositiveRead.growth_bounds w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room
    safe := fun _ _ below => CopiedAttentionAllocatedPositiveFrame.growth_safe w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive growing room below }

theorem cursor (route : Route n) (room : w.base+CopiedAttentionEntryAllocation.bytes+route.bytes≤2^64) :
    (execution w queryDispatch keyDispatch angle storage shared keysBelow valuesBelow aligned positive route room).frontier.cursor=
      w.base+CopiedAttentionEntryAllocation.bytes+route.bytes := by
  cases route <;> simp only [execution,Route.bytes,Nat.add_assoc]
end Inference.Models.Qwen.CopiedAttentionAllocatedPositiveRoute
