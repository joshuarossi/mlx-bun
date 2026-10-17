import models.qwen.CopiedAttentionAllocatedPositiveRoute
import models.qwen.CopiedAttentionTailArenaBuilt
import models.qwen.CopiedAttentionTailArenaBounds
import models.qwen.CopiedAttentionPreparedGeometry
namespace Inference.Models.Qwen.CopiedAttentionCapacityArenaFactory
open Contracts.Mlx Layers State Kernels Kernels.Attention
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

structure Request {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
    {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
    {n : Nat} {cache : Kv.Cache Kv.BF n} (storage : KvRegions.Storage cache) (shared : storage.memory=source.bytes) where
  workspace : CopiedAttentionEntryAllocation.Workspace source original
  queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2
  keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2
  aligned : workspace.base%16=0
  positive : 0<n
  sourceBefore : Before workspace.base source.base 10240
  parametersBefore : original.Protected (Before workspace.base)
  keysBelow : storage.layout.keyBase+KvRegions.bytes n≤workspace.base
  valuesBelow : storage.layout.valueBase+KvRegions.bytes n≤workspace.base
  room : workspace.base+CopiedAttentionEntryAllocation.bytes+(CopiedAttentionAllocatedPositiveRoute.Route.selected n).bytes≤2^64

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  {n : Nat} {cache : Kv.Cache Kv.BF n} {storage : KvRegions.Storage cache} {shared : storage.memory=source.bytes}
  (a : Request (layer:=layer) (source:=source) (original:=original) storage shared) (angle : RopeAngles.Inputs)

abbrev normal := CopiedAttentionEntryAllocation.normal a.workspace
abbrev normalized := CopiedAttentionEntryAllocation.normalized a.workspace
abbrev projectionWorkspace := CopiedAttentionEntryAllocation.projectionWorkspace a.workspace
abbrev protectedParameters := (CopiedAttentionEntryAllocation.projection_regions a.workspace).2.2.1
abbrev regions := original.protected_mono
  (fun _ _ separate => CopiedAttentionEntryAllocation.projection_separate a.workspace separate) a.workspace.parametersSeparate
abbrev native := CopiedAttentionRopeAllocation.native (normalized a).projections (projectionWorkspace a)
  (normalized a).mixer (protectedParameters a) a.queryDispatch a.keyDispatch angle
abbrev upstream := CopiedAttentionAllocatedPositiveInput.input a.workspace a.queryDispatch a.keyDispatch angle storage shared a.keysBelow a.valuesBelow
abbrev result := CopiedAttentionAllocatedPositiveRoute.execution a.workspace a.queryDispatch a.keyDispatch angle storage shared
  a.keysBelow a.valuesBelow a.aligned a.positive (CopiedAttentionAllocatedPositiveRoute.Route.selected n) a.room
abbrev preparation := (result a angle).preparation
abbrev read := (result a angle).read
abbrev frontier := (result a angle).frontier
abbrev linked := CopiedAttentionOriginalBundle.front_input source original (normal a)
  (CopiedAttentionEntryAllocation.normal_safe a.workspace) (regions a)
  (CopiedAttentionEntryAllocation.projections a.workspace) (CopiedAttentionEntryAllocation.queryCopy a.workspace) angle (native a angle)

theorem cursor : (frontier a angle).cursor=a.workspace.base+CopiedAttentionEntryAllocation.bytes+(CopiedAttentionAllocatedPositiveRoute.Route.selected n).bytes :=
  CopiedAttentionAllocatedPositiveRoute.cursor a.workspace a.queryDispatch a.keyDispatch angle storage shared
    a.keysBelow a.valuesBelow a.aligned a.positive (CopiedAttentionAllocatedPositiveRoute.Route.selected n) a.room

theorem normal_safe {base size : Nat} (before : Before a.workspace.base base size) :
    MemoryRegions.Disjoint (2*(normal a).normalized.base) 10240 base size := by
  change MemoryRegions.Disjoint (2*(a.workspace.base/2)) 10240 base size
  rw [CopiedAttentionEntryAllocation.half_base]
  exact Or.inr before

theorem before_frontier {base size : Nat} (before : Before a.workspace.base base size) :
    Before (frontier a angle).cursor base size := by
  have cursor := CopiedAttentionAllocatedPositiveRoute.cursor a.workspace a.queryDispatch a.keyDispatch angle storage shared
    a.keysBelow a.valuesBelow a.aligned a.positive (CopiedAttentionAllocatedPositiveRoute.Route.selected n) a.room
  rw [cursor]
  dsimp [Before] at before ⊢
  omega

theorem output_prefix : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection
    (CopiedAttentionCapacityTailFactory.PrefixSafe source original (normal a) (read a angle)) :=
  AffineMemoryFrames.protected_mono _ _
    (fun base size before => ⟨normal_safe a before,(result a angle).safe base size before⟩) a.parametersBefore.2.2.1.2.2

theorem live : CopiedAttentionTailArena.Live (read a angle).input (read a angle).gate
    (CopiedAttentionCapacityTailFactory.weights source original (normal a) (linked a angle) (read a angle) (output_prefix a angle)) (frontier a angle) where
  keys := (result a angle).bounds.keys
  values := (result a angle).bounds.values
  queries := (result a angle).bounds.queries
  gates := (result a angle).bounds.gates
  weights := (AffineMemoryFrames.reframe_protected _ _ _ _ _).mpr
    (AffineMemoryFrames.protected_mono _ _ (fun _ _ before => before_frontier a angle before) a.parametersBefore.2.2.1.2.2)

variable (arenaRoom : (CopiedAttentionTailArena.next (frontier a angle) layer.mixer.architectureSuffix (n+1)).cursor≤2^64)
abbrev attention := CopiedAttentionTailArena.attention _ arenaRoom _ _ (live a angle) layer.mixer.attention layer.mixer.mergeContracted
abbrev tail := CopiedAttentionTailArena.execution _ arenaRoom _ _ (live a angle) layer.mixer.attention layer.mixer.mergeContracted layer.mixer.gate
  (read a angle).gates_shared (CopiedAttentionCapacityTailFactory.weights_shared source original (normal a) (linked a angle) (read a angle) (output_prefix a angle))

theorem geometry : CopiedAttentionOriginalCapacityStage.Regions source original (normal a) (read a angle)
    (attention a angle arenaRoom) (tail a angle arenaRoom) where
  residualNormal := normal_safe a a.sourceBefore
  residualPrefix := (result a angle).safe _ _ a.sourceBefore
  residualTail := CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _ (before_frontier a angle a.sourceBefore)
  suffixPrefix := DecodeParameterMemory.suffix_mono _ (fun base size before => (result a angle).safe base size before) a.parametersBefore.2.2.2
  suffixTail := DecodeParameterMemory.suffix_mono _
    (fun _ _ before => CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _ (before_frontier a angle before)) a.parametersBefore.2.2.2

abbrev keysNormal := CopiedAttentionAllocatedPositiveInput.keys_normal a.workspace storage a.keysBelow
abbrev valuesNormal := CopiedAttentionAllocatedPositiveInput.values_normal a.workspace storage a.valuesBelow
abbrev keysSafe := (upstream a angle).keysSafe
abbrev valuesSafe := (upstream a angle).valuesSafe
abbrev prepared := CopiedAttentionOriginalCapacityStage.prepared source original (normal a)
  (CopiedAttentionEntryAllocation.normal_safe a.workspace) (regions a)
  (CopiedAttentionEntryAllocation.projections a.workspace) (CopiedAttentionEntryAllocation.queryCopy a.workspace) angle (native a angle)
  storage shared (keysNormal a) (valuesNormal a) (keysSafe a angle) (valuesSafe a angle) (preparation a angle)
  (read a angle) (attention a angle arenaRoom) (tail a angle arenaRoom) (geometry a angle arenaRoom)

theorem prepared_source : (prepared a angle arenaRoom).source.base=source.base :=
  CopiedAttentionPreparedGeometry.Capacity.source_base source original (normal a)
  (CopiedAttentionEntryAllocation.normal_safe a.workspace) (regions a)
  (CopiedAttentionEntryAllocation.projections a.workspace) (CopiedAttentionEntryAllocation.queryCopy a.workspace) angle (native a angle)
  storage shared (keysNormal a) (valuesNormal a) (keysSafe a angle) (valuesSafe a angle) (preparation a angle)
  (read a angle) (attention a angle arenaRoom) (tail a angle arenaRoom) (geometry a angle arenaRoom)

theorem prepared_norm : (prepared a angle arenaRoom).norm.base=original.suffix.norm.base :=
  CopiedAttentionPreparedGeometry.Capacity.norm_base source original (normal a)
  (CopiedAttentionEntryAllocation.normal_safe a.workspace) (regions a)
  (CopiedAttentionEntryAllocation.projections a.workspace) (CopiedAttentionEntryAllocation.queryCopy a.workspace) angle (native a angle)
  storage shared (keysNormal a) (valuesNormal a) (keysSafe a angle) (valuesSafe a angle) (preparation a angle)
  (read a angle) (attention a angle arenaRoom) (tail a angle arenaRoom) (geometry a angle arenaRoom)

theorem prepared_parameters (property : Nat → Nat → Prop) :
    (prepared a angle arenaRoom).parameters.Protected property ↔ original.suffix.trellis.Protected property :=
  CopiedAttentionPreparedGeometry.Capacity.parameters_regions source original (normal a)
  (CopiedAttentionEntryAllocation.normal_safe a.workspace) (regions a)
  (CopiedAttentionEntryAllocation.projections a.workspace) (CopiedAttentionEntryAllocation.queryCopy a.workspace) angle (native a angle)
  storage shared (keysNormal a) (valuesNormal a) (keysSafe a angle) (valuesSafe a angle) (preparation a angle)
  (read a angle) (attention a angle arenaRoom) (tail a angle arenaRoom) (geometry a angle arenaRoom) property


variable (suffix : AttentionSuffixAllocation.Plan (tail a angle arenaRoom) (prepared a angle arenaRoom))
def plan : CopiedAttentionCapacityFactory.Plan layer cache input angle source storage shared original where
  normal := normal a
  safe := CopiedAttentionEntryAllocation.normal_safe a.workspace
  live := MemoryRegions.Disjoint (projectionWorkspace a).base CopiedAttentionProjectionAllocation.bytes
  regions := regions a
  projections := CopiedAttentionEntryAllocation.projections a.workspace
  queryCopy := CopiedAttentionEntryAllocation.queryCopy a.workspace
  native := native a angle
  keysNormal := keysNormal a
  valuesNormal := valuesNormal a
  keysSafe := keysSafe a angle
  valuesSafe := valuesSafe a angle
  preparation := preparation a angle
  read := read a angle
  attention := attention a angle arenaRoom
  tail := tail a angle arenaRoom
  geometry := geometry a angle arenaRoom
  suffix := suffix

theorem built : CopiedAttentionCapacityTailFactory.CapacityBuilt source original (plan a angle arenaRoom suffix) :=
  CopiedAttentionCapacityTailFactory.Built.construct (output_prefix a angle)
    (fun head => CopiedAttentionTailArena.attention_safe _ _ _ _ _ _ _ ((live a angle).gates head))
    (CopiedAttentionTailArena.tailWorkspace _ _ _ _ (live a angle) _ _).regions
    (CopiedAttentionTailArena.tailWorkspace _ _ _ _ (live a angle) _ _).allocation
end Inference.Models.Qwen.CopiedAttentionCapacityArenaFactory
