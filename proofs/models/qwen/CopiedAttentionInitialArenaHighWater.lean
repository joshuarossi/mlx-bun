import models.qwen.CopiedAttentionInitialArenaFactory
import models.qwen.AttentionSuffixHighWater
import models.qwen.CopiedAttentionPreparedGeometry
namespace Inference.Models.Qwen.CopiedAttentionInitialArenaHighWater
open Contracts.Mlx Layers State Kernels Kernels.Attention
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

def bytes (arch : Char) : Nat := CopiedAttentionEntryAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes+
  CopiedAttentionTailArena.bytes arch 1+ResidualMlpAllocation.bytes

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs) (cache : Kv.Cache Kv.BF 0)
  (aligned : (CopiedAttentionEntryAllocation.projectionWorkspace w).base%16=0)
  (sourceBefore : Before w.base source.base 10240)
  (parametersBefore : original.Protected (Before w.base))
  (capacity : w.base+bytes layer.mixer.architectureSuffix≤2^64)

include capacity in
theorem read_room : (CopiedAttentionEntryAllocation.projectionWorkspace w).base+CopiedAttentionProjectionAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes≤2^64 := by
  change w.base+10240+53248+CopiedAttentionInitialReadAllocation.bytes≤2^64
  dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at capacity
  omega

include capacity in
theorem arena_room : (CopiedAttentionTailArena.next (CopiedAttentionInitialArenaFactory.frontier w queryDispatch keyDispatch angle aligned (read_room w capacity)) layer.mixer.architectureSuffix 1).cursor≤2^64 := by
  change w.base+10240+53248+CopiedAttentionInitialReadAllocation.bytes+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix 1≤2^64
  dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at capacity
  omega

abbrev prepared := CopiedAttentionInitialArenaFactory.prepared w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)
abbrev tail := CopiedAttentionInitialArenaFactory.tail w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)

def cursor : Nat := (CopiedAttentionTailArena.next (CopiedAttentionInitialArenaFactory.frontier w queryDispatch keyDispatch angle aligned (read_room w capacity)) layer.mixer.architectureSuffix 1).cursor

private theorem below_cursor {base size : Nat} (before : Before w.base base size) :
    AttentionSuffixHighWater.Before (cursor w queryDispatch keyDispatch angle aligned capacity) base size :=
  (CopiedAttentionInitialArenaFactory.before_frontier w queryDispatch keyDispatch angle aligned (read_room w capacity) before).trans (Nat.le_add_right _ _)

def request : AttentionSuffixHighWater.Request (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity)
    (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) where
  cursor := cursor w queryDispatch keyDispatch angle aligned capacity
  aligned := (CopiedAttentionTailArena.next (CopiedAttentionInitialArenaFactory.frontier w queryDispatch keyDispatch angle aligned (read_room w capacity)) layer.mixer.architectureSuffix 1).aligned
  room := by
    change w.base+10240+53248+CopiedAttentionInitialReadAllocation.bytes+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix 1+ResidualMlpAllocation.bytes≤2^64
    dsimp [bytes,CopiedAttentionEntryAllocation.bytes] at capacity
    omega
  source := by
    rw [CopiedAttentionPreparedGeometry.Initial.source_base source original (CopiedAttentionInitialArenaFactory.normal w) (CopiedAttentionEntryAllocation.normal_safe w) (CopiedAttentionInitialArenaFactory.regions w)
    (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w) angle
    (CopiedAttentionInitialArenaFactory.native w queryDispatch keyDispatch angle) (CopiedAttentionInitialArenaFactory.read w queryDispatch keyDispatch angle cache aligned (read_room w capacity))
    (CopiedAttentionInitialArenaFactory.attention w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity))
    (CopiedAttentionInitialArenaFactory.tail w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)) (CopiedAttentionInitialArenaFactory.geometry w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity))]
    exact below_cursor w queryDispatch keyDispatch angle aligned capacity sourceBefore
  update := CopiedAttentionTailArenaBounds.output_bound _ _ _ _ _ _ _ _ _ _
  norm := by
    rw [CopiedAttentionPreparedGeometry.Initial.norm_base source original (CopiedAttentionInitialArenaFactory.normal w) (CopiedAttentionEntryAllocation.normal_safe w) (CopiedAttentionInitialArenaFactory.regions w)
    (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w) angle
    (CopiedAttentionInitialArenaFactory.native w queryDispatch keyDispatch angle) (CopiedAttentionInitialArenaFactory.read w queryDispatch keyDispatch angle cache aligned (read_room w capacity))
    (CopiedAttentionInitialArenaFactory.attention w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity))
    (CopiedAttentionInitialArenaFactory.tail w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)) (CopiedAttentionInitialArenaFactory.geometry w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity))]
    exact below_cursor w queryDispatch keyDispatch angle aligned capacity parametersBefore.2.2.2.1
  parameters := (CopiedAttentionPreparedGeometry.Initial.parameters_regions source original (CopiedAttentionInitialArenaFactory.normal w) (CopiedAttentionEntryAllocation.normal_safe w) (CopiedAttentionInitialArenaFactory.regions w)
    (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w) angle
    (CopiedAttentionInitialArenaFactory.native w queryDispatch keyDispatch angle) (CopiedAttentionInitialArenaFactory.read w queryDispatch keyDispatch angle cache aligned (read_room w capacity))
    (CopiedAttentionInitialArenaFactory.attention w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity))
    (CopiedAttentionInitialArenaFactory.tail w queryDispatch keyDispatch angle cache aligned (read_room w capacity) parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)) (CopiedAttentionInitialArenaFactory.geometry w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity)) _).mpr
    (original.suffix.trellis.protected_mono (fun _ _ before => below_cursor w queryDispatch keyDispatch angle aligned capacity before) parametersBefore.2.2.2.2)
  keys := (CopiedAttentionTailArenaBounds.cache_bounds _ _ _ _ _ _ _ _ _ _).1
  values := (CopiedAttentionTailArenaBounds.cache_bounds _ _ _ _ _ _ _ _ _ _).2

abbrev suffix := AttentionSuffixHighWater.plan (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity) (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) (request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)
abbrev plan := CopiedAttentionInitialArenaFactory.plan w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity) (suffix w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)
abbrev stage := CopiedAttentionInitialFactory.stage (plan w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)

theorem built : CopiedAttentionInitialTailFactory.InitialBuilt source original (plan w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) :=
  CopiedAttentionInitialArenaFactory.built w queryDispatch keyDispatch angle cache aligned (read_room w capacity) sourceBefore parametersBefore (arena_room w queryDispatch keyDispatch angle aligned capacity) (suffix w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)

def next : Nat := w.base+bytes layer.mixer.architectureSuffix

theorem next_eq : next w=(request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity).cursor+ResidualMlpAllocation.bytes := by
  change w.base+bytes layer.mixer.architectureSuffix=w.base+10240+53248+CopiedAttentionInitialReadAllocation.bytes+CopiedAttentionTailArena.bytes layer.mixer.architectureSuffix 1+ResidualMlpAllocation.bytes
  unfold bytes CopiedAttentionEntryAllocation.bytes
  omega

include queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity in
theorem next_aligned : (next w)%16=0 := by
  rw [next_eq w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity]
  exact AttentionSuffixHighWater.next_aligned (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity) (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) (request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)

include capacity in
theorem next_bounded : next w≤2^64 := capacity

theorem safe {base size : Nat} (before : Before w.base base size) :
    AttentionGateCopyInitialResidualStage.Safe (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) base size :=
  ⟨CopiedAttentionInitialArenaFactory.normal_safe w before,CopiedAttentionInitialArenaFactory.prefix_safe w queryDispatch keyDispatch angle cache aligned (read_room w capacity) before,
    CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _
      (CopiedAttentionInitialArenaFactory.before_frontier w queryDispatch keyDispatch angle aligned (read_room w capacity) before),
    AttentionSuffixHighWater.suffix_safe (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity) (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) (request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)
      (below_cursor w queryDispatch keyDispatch angle aligned capacity before)⟩

attribute [local irreducible] ResidualMlpMemory.Execution.outputBuffer

theorem output_bound : Before (next w)
    (AttentionGateCopyInitialResidualStage.forwardBuffer (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)).base 10240 := by
  rw [next_eq w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity]
  rw [AttentionGateCopyInitialResidualStage.forwardBuffer]
  rw [ArrayViews.reindex_base
    (AttentionGateCopyInitialResidualStage.output_eq (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity))
    (AttentionGateCopyInitialResidualStage.outputBuffer (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity))]
  exact AttentionSuffixHighWater.output_bound (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity) (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) (request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)

theorem cache_bounds :
    Before (next w) (AttentionGateCopyInitialResidualStage.afterCache (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)).layout.keyBase (KvRegions.bytes 1) ∧
    Before (next w) (AttentionGateCopyInitialResidualStage.afterCache (stage w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)).layout.valueBase (KvRegions.bytes 1) := by
  rw [next_eq w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity]
  exact AttentionSuffixHighWater.cache_bounds (tail w queryDispatch keyDispatch angle cache aligned parametersBefore capacity) (prepared w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity) (request w queryDispatch keyDispatch angle cache aligned sourceBefore parametersBefore capacity)

end Inference.Models.Qwen.CopiedAttentionInitialArenaHighWater
