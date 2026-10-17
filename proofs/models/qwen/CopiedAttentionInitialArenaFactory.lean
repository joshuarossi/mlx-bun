import models.qwen.CopiedAttentionAllocatedFrontFrame
import models.qwen.CopiedAttentionEntryAllocation
import models.qwen.CopiedAttentionReadHighWater
import models.qwen.CopiedAttentionTailArenaBuilt
import models.qwen.CopiedAttentionTailArenaBounds
namespace Inference.Models.Qwen.CopiedAttentionInitialArenaFactory
open Contracts.Mlx Layers State Kernels Kernels.Attention
open ResidualDeltaHighWater (Before Frontier)
set_option maxRecDepth 10000
set_option maxHeartbeats 800000

variable {layer : ResidualAttention.Layer} {input : Fin 5120 → ArrayStorage.BF}
  {source : ArrayStorage.BFBuffer input} {original : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (w : CopiedAttentionEntryAllocation.Workspace source original)
  (queryDispatch : layer.mixer.preparation.qNorm.platform.groups=2)
  (keyDispatch : layer.mixer.preparation.kNorm.platform.groups=2)
  (angle : RopeAngles.Inputs) (cache : Kv.Cache Kv.BF 0)
  (aligned : (CopiedAttentionEntryAllocation.projectionWorkspace w).base%16=0)
  (room : (CopiedAttentionEntryAllocation.projectionWorkspace w).base+CopiedAttentionProjectionAllocation.bytes+CopiedAttentionInitialReadAllocation.bytes≤2^64)

abbrev normal := CopiedAttentionEntryAllocation.normal w
abbrev normalized := CopiedAttentionEntryAllocation.normalized w
abbrev projectionWorkspace := CopiedAttentionEntryAllocation.projectionWorkspace w
abbrev protectedParameters := (CopiedAttentionEntryAllocation.projection_regions w).2.2.1

theorem regions : original.Protected (MemoryRegions.Disjoint (projectionWorkspace w).base CopiedAttentionProjectionAllocation.bytes) :=
  original.protected_mono (fun _ _ separate => CopiedAttentionEntryAllocation.projection_separate w separate) w.parametersSeparate

abbrev native := CopiedAttentionRopeAllocation.native (normalized w).projections (projectionWorkspace w)
  (normalized w).mixer (protectedParameters w) queryDispatch keyDispatch angle

abbrev front := CopiedAttentionAllocatedFront.front (normalized w).projections (projectionWorkspace w)
  (normalized w).mixer (protectedParameters w) queryDispatch keyDispatch angle

abbrev read := CopiedAttentionAllocatedInitialRead.read (normalized w).projections (projectionWorkspace w)
  (normalized w).mixer (protectedParameters w) queryDispatch keyDispatch angle aligned room cache

abbrev request := CopiedAttentionAllocatedInitialRead.request (normalized w).projections (projectionWorkspace w)
  (normalized w).mixer (protectedParameters w) queryDispatch keyDispatch angle aligned room

def frontier : Frontier where
  cursor := (request w queryDispatch keyDispatch angle aligned room).cursor+CopiedAttentionInitialReadAllocation.bytes
  aligned := CopiedAttentionInitialReadAllocation.next_aligned (request w queryDispatch keyDispatch angle aligned room)

theorem prefix_safe {base size : Nat} (before : Before w.base base size) :
    AttentionGateCopyInitialTrellisFrames.Safe (read w queryDispatch keyDispatch angle cache aligned room) base size := by
  refine ⟨CopiedAttentionAllocatedFrontFrame.safe _ _ _ _ _ _ _ ?_,?_⟩
  · exact CopiedAttentionEntryAllocation.projection_separate w (Or.inr before)
  · exact CopiedAttentionInitialReadAllocation.safe_below _ (by
      change base+size≤(projectionWorkspace w).base+CopiedAttentionProjectionAllocation.bytes
      change base+size≤w.base+10240+53248
      dsimp [Before] at before
      omega)

theorem normal_safe {base size : Nat} (before : Before w.base base size) :
    MemoryRegions.Disjoint (2*(normal w).normalized.base) 10240 base size := by
  change MemoryRegions.Disjoint (2*(w.base/2)) 10240 base size
  rw [CopiedAttentionEntryAllocation.half_base]
  exact Or.inr before

theorem before_frontier {base size : Nat} (before : Before w.base base size) :
    Before (frontier w queryDispatch keyDispatch angle aligned room).cursor base size := by
  change base+size≤w.base+10240+53248+CopiedAttentionInitialReadAllocation.bytes
  dsimp [Before] at before
  omega

variable (sourceBefore : Before w.base source.base 10240)
  (parametersBefore : original.Protected (Before w.base))

include parametersBefore in
theorem output_prefix : AffineMemoryFrames.Protected layer.mixer.output original.mixer.projection
    (CopiedAttentionInitialTailFactory.PrefixSafe source original (normal w) (read w queryDispatch keyDispatch angle cache aligned room)) :=
  AffineMemoryFrames.protected_mono _ _
    (fun _ _ before => ⟨normal_safe w before,prefix_safe w queryDispatch keyDispatch angle cache aligned room before⟩)
    parametersBefore.2.2.1.2.2

abbrev linked := CopiedAttentionOriginalBundle.front_input source original (normal w)
  (CopiedAttentionEntryAllocation.normal_safe w) (regions w)
  (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w) angle
  (native w queryDispatch keyDispatch angle)

theorem live : CopiedAttentionTailArena.Live
    (read w queryDispatch keyDispatch angle cache aligned room).input
    (read w queryDispatch keyDispatch angle cache aligned room).gate
    (CopiedAttentionInitialTailFactory.weights source original (normal w)
      (linked w queryDispatch keyDispatch angle) (read w queryDispatch keyDispatch angle cache aligned room)
      (output_prefix w queryDispatch keyDispatch angle cache aligned room parametersBefore))
    (frontier w queryDispatch keyDispatch angle aligned room) where
  keys := (CopiedAttentionReadHighWater.Initial.bounds (request w queryDispatch keyDispatch angle aligned room) cache).keys
  values := (CopiedAttentionReadHighWater.Initial.bounds (request w queryDispatch keyDispatch angle aligned room) cache).values
  queries := (CopiedAttentionReadHighWater.Initial.bounds (request w queryDispatch keyDispatch angle aligned room) cache).queries
  gates := (CopiedAttentionReadHighWater.Initial.bounds (request w queryDispatch keyDispatch angle aligned room) cache).gates
  weights := (AffineMemoryFrames.reframe_protected _ _ _ _ _).mpr
    (AffineMemoryFrames.protected_mono _ _ (fun _ _ before => before_frontier w queryDispatch keyDispatch angle aligned room before)
      parametersBefore.2.2.1.2.2)

variable (arenaRoom : (CopiedAttentionTailArena.next (frontier w queryDispatch keyDispatch angle aligned room) layer.mixer.architectureSuffix 1).cursor≤2^64)

abbrev attention := CopiedAttentionTailArena.attention _ arenaRoom _ _
  (live w queryDispatch keyDispatch angle cache aligned room parametersBefore) layer.mixer.attention layer.mixer.mergeContracted

abbrev tail := CopiedAttentionTailArena.execution _ arenaRoom _ _
  (live w queryDispatch keyDispatch angle cache aligned room parametersBefore) layer.mixer.attention layer.mixer.mergeContracted layer.mixer.gate
  (read w queryDispatch keyDispatch angle cache aligned room).gates_shared
  (CopiedAttentionInitialTailFactory.weights_shared source original (normal w)
    (linked w queryDispatch keyDispatch angle) (read w queryDispatch keyDispatch angle cache aligned room)
    (output_prefix w queryDispatch keyDispatch angle cache aligned room parametersBefore))

include sourceBefore in
theorem geometry : CopiedAttentionOriginalInitialStage.Regions source original (normal w)
    (read w queryDispatch keyDispatch angle cache aligned room)
    (attention w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom)
    (tail w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom) where
  residualNormal := normal_safe w sourceBefore
  residualPrefix := prefix_safe w queryDispatch keyDispatch angle cache aligned room sourceBefore
  residualTail := CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _
    (before_frontier w queryDispatch keyDispatch angle aligned room sourceBefore)
  suffixPrefix := DecodeParameterMemory.suffix_mono _
    (fun _ _ before => prefix_safe w queryDispatch keyDispatch angle cache aligned room before) parametersBefore.2.2.2
  suffixTail := DecodeParameterMemory.suffix_mono _
    (fun _ _ before => CopiedAttentionTailArena.protect _ _ _ _ _ _ _ _ _ _
      (before_frontier w queryDispatch keyDispatch angle aligned room before)) parametersBefore.2.2.2


abbrev prepared := CopiedAttentionOriginalInitialStage.prepared source original (normal w)
  (CopiedAttentionEntryAllocation.normal_safe w) (regions w)
  (CopiedAttentionEntryAllocation.projections w) (CopiedAttentionEntryAllocation.queryCopy w) angle
  (native w queryDispatch keyDispatch angle) (read w queryDispatch keyDispatch angle cache aligned room)
  (attention w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom)
  (tail w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom)
  (geometry w queryDispatch keyDispatch angle cache aligned room sourceBefore parametersBefore arenaRoom)

variable (suffix : AttentionSuffixAllocation.Plan
  (tail w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom)
  (prepared w queryDispatch keyDispatch angle cache aligned room sourceBefore parametersBefore arenaRoom))

def plan : CopiedAttentionInitialFactory.Plan layer cache input angle source original where
  normal := normal w
  safe := CopiedAttentionEntryAllocation.normal_safe w
  live := MemoryRegions.Disjoint (projectionWorkspace w).base CopiedAttentionProjectionAllocation.bytes
  regions := regions w
  projections := CopiedAttentionEntryAllocation.projections w
  queryCopy := CopiedAttentionEntryAllocation.queryCopy w
  native := native w queryDispatch keyDispatch angle
  read := read w queryDispatch keyDispatch angle cache aligned room
  attention := attention w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom
  tail := tail w queryDispatch keyDispatch angle cache aligned room parametersBefore arenaRoom
  geometry := geometry w queryDispatch keyDispatch angle cache aligned room sourceBefore parametersBefore arenaRoom
  suffix := suffix

theorem built : CopiedAttentionInitialTailFactory.InitialBuilt source original
    (plan w queryDispatch keyDispatch angle cache aligned room sourceBefore parametersBefore arenaRoom suffix) := by
  exact CopiedAttentionInitialTailFactory.Built.construct
    (output_prefix w queryDispatch keyDispatch angle cache aligned room parametersBefore)
    (fun head => CopiedAttentionTailArena.attention_safe _ _ _ _ _ _ _
      ((live w queryDispatch keyDispatch angle cache aligned room parametersBefore).gates head))
    (CopiedAttentionTailArena.tailWorkspace _ _ _ _
      (live w queryDispatch keyDispatch angle cache aligned room parametersBefore) _ _).regions
    (CopiedAttentionTailArena.tailWorkspace _ _ _ _
      (live w queryDispatch keyDispatch angle cache aligned room parametersBefore) _ _).allocation

end Inference.Models.Qwen.CopiedAttentionInitialArenaFactory
