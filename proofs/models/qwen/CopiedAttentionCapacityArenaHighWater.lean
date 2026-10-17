import models.qwen.CopiedAttentionCapacityArenaFactory
import models.qwen.CopiedAttentionEntryHighWater
import models.qwen.AttentionSuffixHighWater
namespace Inference.Models.Qwen.CopiedAttentionCapacityArenaHighWater
open Contracts.Mlx Layers State Kernels Kernels.Attention
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] ResidualMlpMemory.Execution.outputBuffer

def bytes (arch : Char) (n : Nat) : Nat := 63488+
  (if n+1≤KvAllocation.capacity n then 2*KvRegions.bytes (n+1)
    else KvGrowthAllocation.bytes n+2*KvRegions.bytes (n+1))+
  CopiedAttentionTailArena.bytes arch (n+1)+ResidualMlpAllocation.bytes

private theorem selected_bytes (n : Nat) : (CopiedAttentionAllocatedPositiveRoute.Route.selected n).bytes=
    if n+1≤KvAllocation.capacity n then 2*KvRegions.bytes (n+1)
    else KvGrowthAllocation.bytes n+2*KvRegions.bytes (n+1) := by
  unfold CopiedAttentionAllocatedPositiveRoute.Route.selected
  split <;> rfl

structure Request {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer input) (original : DecodeParameterMemory.AttentionStorage layer source.bytes)
    {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes) where
  frontier : Frontier
  queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2
  positive : 0<n
  sourceBefore : Before frontier.cursor source.base 10240
  parametersBefore : original.Protected (Before frontier.cursor)
  keysBelow : storage.layout.keyBase+KvRegions.bytes n≤frontier.cursor
  valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤frontier.cursor
  capacity : frontier.cursor+bytes layer.mixer.architectureSuffix n≤2^64

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  {n : Nat} {cache : Kv.Cache Kv.BF n} {storage : KvRegions.Storage cache} {shared : storage.memory=source.bytes}
  (a : Request source original storage shared) (angle : RopeAngles.Inputs)

include a in
theorem entry_room : a.frontier.cursor+CopiedAttentionEntryAllocation.bytes≤2^64 := by
  have := a.capacity
  dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at *
  omega

def workspace := CopiedAttentionEntryHighWater.workspace source original a.frontier.cursor a.frontier.aligned
  (entry_room a) a.sourceBefore a.parametersBefore

def arena : CopiedAttentionCapacityArenaFactory.Request (layer:=layer) (source:=source) (original:=original) storage shared where
  workspace := workspace a
  queryDispatch := a.queryDispatch
  keyDispatch := a.keyDispatch
  aligned := a.frontier.aligned
  positive := a.positive
  sourceBefore := a.sourceBefore
  parametersBefore := a.parametersBefore
  keysBelow := a.keysBelow
  valuesBelow := a.valuesBelow
  room := by
    change a.frontier.cursor+CopiedAttentionEntryAllocation.bytes+(CopiedAttentionAllocatedPositiveRoute.Route.selected n).bytes≤2^64
    rw [selected_bytes]
    have := a.capacity
    dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at *
    omega

theorem arena_base : (arena a).workspace.base=a.frontier.cursor := rfl

theorem arena_room : (CopiedAttentionTailArena.next
    (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle) layer.mixer.architectureSuffix (n+1)).cursor≤2^64 := by
  change (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle).cursor+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix (n+1)≤2^64
  rw [CopiedAttentionCapacityArenaFactory.cursor,selected_bytes,arena_base]
  have := a.capacity
  dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at *
  omega

abbrev prepared := CopiedAttentionCapacityArenaFactory.prepared (arena a) angle (arena_room a angle)
abbrev tail := CopiedAttentionCapacityArenaFactory.tail (arena a) angle (arena_room a angle)
def cursor := (CopiedAttentionTailArena.next (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle) layer.mixer.architectureSuffix (n+1)).cursor

private theorem below_cursor {base size : Nat} (before : Before a.frontier.cursor base size) :
    AttentionSuffixHighWater.Before (cursor a angle) base size :=
  (CopiedAttentionCapacityArenaFactory.before_frontier (arena a) angle before).trans (Nat.le_add_right _ _)

def request : AttentionSuffixHighWater.Request (tail a angle) (prepared a angle) where
  cursor := cursor a angle
  aligned := (CopiedAttentionTailArena.next (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle) layer.mixer.architectureSuffix (n+1)).aligned
  room := by
    change (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle).cursor+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix (n+1)+ResidualMlpAllocation.bytes≤2^64
    rw [CopiedAttentionCapacityArenaFactory.cursor,selected_bytes,arena_base]
    simpa only [bytes,CopiedAttentionEntryAllocation.bytes,Nat.add_assoc] using a.capacity
  source := by
    rw [CopiedAttentionCapacityArenaFactory.prepared_source]
    exact below_cursor a angle a.sourceBefore
  update := CopiedAttentionTailArenaBounds.output_bound _ _ _ _ _ _ _ _ _ _
  norm := by
    rw [CopiedAttentionCapacityArenaFactory.prepared_norm]
    exact below_cursor a angle a.parametersBefore.2.2.2.1
  parameters := (CopiedAttentionCapacityArenaFactory.prepared_parameters _ _ _ _).mpr
    (original.suffix.trellis.protected_mono (fun _ _ before => below_cursor a angle before) a.parametersBefore.2.2.2.2)
  keys := (CopiedAttentionTailArenaBounds.cache_bounds _ _ _ _ _ _ _ _ _ _).1
  values := (CopiedAttentionTailArenaBounds.cache_bounds _ _ _ _ _ _ _ _ _ _).2

abbrev suffix := AttentionSuffixHighWater.plan (tail a angle) (prepared a angle) (request a angle)
abbrev plan := CopiedAttentionCapacityArenaFactory.plan (arena a) angle (arena_room a angle) (suffix a angle)
abbrev stage := CopiedAttentionCapacityFactory.stage (plan a angle)

theorem built : CopiedAttentionCapacityTailFactory.CapacityBuilt source original (plan a angle) :=
  CopiedAttentionCapacityArenaFactory.built (arena a) angle (arena_room a angle) (suffix a angle)

def next : Nat := a.frontier.cursor+bytes layer.mixer.architectureSuffix n

theorem next_eq : next a=(request a angle).cursor+ResidualMlpAllocation.bytes := by
  change a.frontier.cursor+bytes layer.mixer.architectureSuffix n=
    (CopiedAttentionCapacityArenaFactory.frontier (arena a) angle).cursor+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix (n+1)+ResidualMlpAllocation.bytes
  rw [CopiedAttentionCapacityArenaFactory.cursor,selected_bytes,arena_base]
  simp only [bytes,CopiedAttentionEntryAllocation.bytes,Nat.add_assoc]

include angle in
theorem next_aligned : (next a)%16=0 := by
  rw [next_eq a angle]
  exact AttentionSuffixHighWater.next_aligned (tail a angle) (prepared a angle) (request a angle)

theorem next_bounded : next a≤2^64 := a.capacity

theorem safe_below {base size : Nat} (before : Before a.frontier.cursor base size) :
    AttentionGateCopyCapacityResidualStage.Safe (stage a angle) base size :=
  ⟨CopiedAttentionCapacityArenaFactory.normal_safe (arena a) before,(CopiedAttentionCapacityArenaFactory.result (arena a) angle).safe base size before,
    CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _
      (CopiedAttentionCapacityArenaFactory.before_frontier (arena a) angle before),
    AttentionSuffixHighWater.suffix_safe (tail a angle) (prepared a angle) (request a angle)
      (below_cursor a angle before)⟩

theorem output_bound : Before (next a) (AttentionGateCopyCapacityResidualStage.forwardBuffer (stage a angle)).base 10240 := by
  rw [next_eq a angle]
  rw [AttentionGateCopyCapacityResidualStage.forwardBuffer]
  rw [ArrayViews.reindex_base (AttentionGateCopyCapacityResidualStage.output_eq (stage a angle))
    (AttentionGateCopyCapacityResidualStage.outputBuffer (stage a angle))]
  exact AttentionSuffixHighWater.output_bound (tail a angle) (prepared a angle) (request a angle)

theorem cache_bounds :
    Before (next a) (AttentionGateCopyCapacityResidualStage.afterCache (stage a angle)).layout.keyBase (KvRegions.bytes (n+1)) ∧
    Before (next a) (AttentionGateCopyCapacityResidualStage.afterCache (stage a angle)).layout.valueBase (KvRegions.bytes (n+1)) := by
  rw [next_eq a angle]
  exact AttentionSuffixHighWater.cache_bounds (tail a angle) (prepared a angle) (request a angle)
end Inference.Models.Qwen.CopiedAttentionCapacityArenaHighWater
