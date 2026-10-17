import models.qwen.CapacityCopiedHighWaterConstruction
namespace Inference.Models.Qwen.CopiedCapacityGrowthBounds
open Contracts.Mlx Layers State DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000

-- Unlike a generic growth Allocation, the actual arena constructor bounds
-- both temporary zero slabs as well as the final concatenated cache buffers.
def Bounded {n : Nat} {cache : Kv.Cache Kv.BF n} (old : KvRegions.Storage cache) :
    AttentionBlockMemory.Preparation old → Prop
  | .existing _ => True
  | .growth allocation =>
    2*allocation.keyLayout.zeroBase+524288≤2^64 ∧
      2*allocation.valueLayout.zeroBase+524288≤2^64

theorem workspace {n : Nat} {cache : Kv.Cache Kv.BF n} {old : KvRegions.Storage cache}
    (w : KvGrowthAllocation.Workspace old) (growing : KvAllocation.capacity n<n+1) :
    Bounded old (.growth (w.allocation growing)) := by
  change 2*(w.base/2)+524288≤2^64 ∧ 2*((w.base+524288+KvGrowthAllocation.tensorBytes n)/2)+524288≤2^64
  rw [w.half_bases.1,w.half_bases.2.2.1]
  have bounded := w.bounded
  dsimp only [KvGrowthAllocation.bytes] at bounded
  omega

theorem growth_prepared {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    {s : AttentionGateCopyReadConstruction.Input layer cache input angle}
    (request : CopiedAttentionGrowthPreparation.Request s) :
    Bounded s.oldAfter (CopiedAttentionGrowthPreparation.prepared request).preparation :=
  workspace (CopiedAttentionGrowthPreparation.workspace request) request.growing

section Route
variable {layer : ResidualAttention.Layer} {values : Row BF}
  {source : ArrayStorage.BFBuffer values} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2) (angle : RopeAngles.Inputs)
  {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes)
  (keysBelow : storage.layout.keyBase+KvRegions.bytes n≤w.base)
  (valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤w.base)
  (aligned : w.base%16=0) (positive : 0<n)

theorem route (choice : CopiedAttentionAllocatedPositiveRoute.Route n)
    (room : w.base+CopiedAttentionEntryAllocation.bytes+choice.bytes≤2^64) :
    Bounded _ (CopiedAttentionAllocatedPositiveRoute.execution w queryDispatch keyDispatch angle storage shared
      keysBelow valuesBelow aligned positive choice room).preparation.preparation := by
  cases choice with
  | reuse same => exact True.intro
  | growth growing =>
    exact growth_prepared (CopiedAttentionAllocatedPositiveRead.growthRequest w queryDispatch keyDispatch angle storage shared
      keysBelow valuesBelow aligned positive growing room)
end Route

section Arena
variable {layer : ResidualAttention.Layer} {input : Row BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  {n : Nat} {cache : Kv.Cache Kv.BF n} {storage : KvRegions.Storage cache} {shared : storage.memory=source.bytes}
  (a : CopiedAttentionCapacityArenaFactory.Request (layer:=layer) (source:=source) (original:=original) storage shared)
  (angle : RopeAngles.Inputs)
  (arenaRoom : (CopiedAttentionTailArena.next (CopiedAttentionCapacityArenaFactory.frontier a angle)
    layer.mixer.architectureSuffix (n+1)).cursor≤2^64)
  (suffix : AttentionSuffixAllocation.Plan (CopiedAttentionCapacityArenaFactory.tail a angle arenaRoom)
    (CopiedAttentionCapacityArenaFactory.prepared a angle arenaRoom))

theorem arena_plan : Bounded _ (CopiedAttentionCapacityArenaFactory.plan a angle arenaRoom suffix).preparation.preparation :=
  route a.workspace a.queryDispatch a.keyDispatch angle storage shared a.keysBelow a.valuesBelow a.aligned a.positive
    (CopiedAttentionAllocatedPositiveRoute.Route.selected n) a.room
end Arena

section HighWater
variable {layer : ResidualAttention.Layer} {input : Row BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  {n : Nat} {cache : Kv.Cache Kv.BF n} {storage : KvRegions.Storage cache} {shared : storage.memory=source.bytes}
  (a : CopiedAttentionCapacityArenaHighWater.Request source original storage shared) (angle : RopeAngles.Inputs)

theorem highwater_plan : Bounded _ (CopiedAttentionCapacityArenaHighWater.plan a angle).preparation.preparation :=
  arena_plan (CopiedAttentionCapacityArenaHighWater.arena a) angle (CopiedAttentionCapacityArenaHighWater.arena_room a angle)
    (CopiedAttentionCapacityArenaHighWater.suffix a angle)
end HighWater

end Inference.Models.Qwen.CopiedCapacityGrowthBounds
