import models.qwen.ResidualAttentionExistingHighWater
import models.qwen.DecodeHighWaterGeometry

namespace Inference.Models.Qwen.DecodeExistingStepConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before before_mono cacheProtected_mono)
open DecodeHighWaterGeometry (After)
set_option maxRecDepth 10000

def stageBytes : Stage → Nat → Nat
  | .delta _, _ => ResidualDeltaAllocation.bytes
  | .attention layer, tokens => ResidualAttentionHighWater.fixedBytes layer tokens

def next : Frontier → Stage → Nat → Frontier
  | frontier, .delta _, _ => frontier.next
  | frontier, .attention layer, tokens => ResidualAttentionExistingHighWater.next frontier layer tokens

theorem next_cursor (frontier : Frontier) (kind : Stage) (tokens : Nat) :
    (next frontier kind tokens).cursor=frontier.cursor+stageBytes kind tokens := by
  cases kind <;> rfl

variable {all rest : List Stage} {kind : Stage} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

-- The checkpoint lies below parameterCut, old caches between the two cuts,
-- and this token's activations above cacheCut. Pairwise cache geometry comes
-- from the preceding constructed token; no per-kernel allocation is supplied.
structure Request (parameterCut cacheCut : Nat) : Prop where
  ordered : parameterCut≤cacheCut ∧ cacheCut≤frontier.cursor
  capacity : (next frontier kind tokens).cursor≤2^64
  sourceBound : Before frontier.cursor source.base 10240
  sourceLower : cacheCut≤source.base
  parametersBound : DecodeParameterMemory.Protected all parameters (Before parameterCut)
  cachesBelow : DecodePreservation.Protected (Before cacheCut) (kind::rest) cache source.bytes storage
  cachesAbove : DecodePreservation.Protected (After parameterCut) (kind::rest) cache source.bytes storage
  pairwise : DecodeCacheGeometry.Pairwise (kind::rest) cache source.bytes storage
  dispatch : DecodeHighWaterConstruction.Dispatch kind
  room : ¬State.KvAllocation.capacity tokens<tokens+1

variable {parameterCut cacheCut : Nat}
  (request : Request cache input source storage parameters frontier parameterCut cacheCut)

include request in
theorem Request.parameters_before : DecodeParameterMemory.Protected all parameters (Before frontier.cursor) :=
  DecodeParameterMemory.protected_mono all parameters
    (fun _ _ bound => before_mono (request.ordered.1.trans request.ordered.2) bound) request.parametersBound

include request in
theorem Request.caches_before : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage :=
  cacheProtected_mono (kind::rest) cache storage
    (fun _ _ bound => before_mono request.ordered.2 bound) request.cachesBelow

def plan : DecodeParameterConstruction.StepPlan position cache input angle source storage parameters := by
  cases kind with
  | delta layer =>
    exact ResidualDeltaHighWater.boundStep position cache input angle source storage parameters frontier request.capacity request.sourceBound
      request.parameters_before request.caches_before
  | attention layer =>
    have live : DecodeParameterMemory.Protected all parameters
        (fun base size => Before frontier.cursor base size ∧ ResidualAttentionExistingHighWater.CacheSafe storage.1 base size) :=
      DecodeParameterMemory.protected_mono all parameters (fun base size bound =>
        ⟨before_mono (request.ordered.1.trans request.ordered.2) bound,
          ResidualAttentionExistingHighWater.cache_safe_below storage.1 parameterCut base size request.cachesAbove.1 bound⟩)
        request.parametersBound
    exact ResidualAttentionExistingHighWater.boundStep position cache input angle source storage parameters frontier
      request.capacity request.sourceBound live request.caches_before request.pairwise request.dispatch.1 request.dispatch.2 request.room
      (ResidualAttentionExistingHighWater.cache_safe_above storage.1 cacheCut source.base 10240 request.cachesBelow.1 request.sourceLower)

theorem output_bound : Before (next frontier kind tokens).cursor
    (plan position cache input angle source storage parameters frontier request).step.first.buffer.base 10240 := by
  cases kind with
  | delta layer =>
    exact ResidualDeltaHighWater.boundStep_output position cache input angle source storage parameters frontier request.capacity request.sourceBound
      request.parameters_before request.caches_before
  | attention layer =>
    exact ResidualAttentionExistingHighWater.boundStep_output position cache input angle source storage parameters frontier
      request.capacity request.sourceBound _ request.caches_before request.pairwise request.dispatch.1 request.dispatch.2 request.room _

theorem updated_bound : DecodePreservation.StageProtected (Before (next frontier kind tokens).cursor) kind
    (cacheAfter kind cache.1 input angle)
    (plan position cache input angle source storage parameters frontier request).step.first.cacheAfter.storage := by
  cases kind with
  | delta layer =>
    exact ResidualDeltaHighWater.boundStep_updated position cache input angle source storage parameters frontier request.capacity request.sourceBound
      request.parameters_before request.caches_before
  | attention layer =>
    exact ResidualAttentionExistingHighWater.boundStep_updated position cache input angle source storage parameters frontier
      request.capacity request.sourceBound _ request.caches_before request.pairwise request.dispatch.1 request.dispatch.2 request.room _

theorem output_lower : cacheCut≤(plan position cache input angle source storage parameters frontier request).step.first.buffer.base := by
  rw [ResidualDeltaHighWater.trace_buffer_base]
  cases kind with
  | delta layer =>
    change cacheCut≤(ResidualDeltaHighWater.allocation source storage.1
      (DecodeParameterConstruction.remainingParameters position parameters).1 frontier request.capacity request.sourceBound
      (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1).fromStorage.outputBuffer.base
    rw [(ResidualDeltaHighWater.allocation source storage.1
      (DecodeParameterConstruction.remainingParameters position parameters).1 frontier request.capacity request.sourceBound
      (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1).output_base]
    exact request.ordered.2.trans (Nat.le_add_right _ _)
  | attention layer =>
    have live : DecodeParameterMemory.Protected all parameters
        (fun base size => Before frontier.cursor base size ∧ ResidualAttentionExistingHighWater.CacheSafe storage.1 base size) :=
      DecodeParameterMemory.protected_mono all parameters (fun base size bound =>
        ⟨before_mono (request.ordered.1.trans request.ordered.2) bound,
          ResidualAttentionExistingHighWater.cache_safe_below storage.1 parameterCut base size request.cachesAbove.1 bound⟩)
        request.parametersBound
    let chosen := ResidualAttentionExistingHighWater.selectedChoice position cache input angle source storage parameters frontier
      request.capacity request.sourceBound live request.caches_before request.dispatch.1 request.dispatch.2 request.room
      (ResidualAttentionExistingHighWater.cache_safe_above storage.1 cacheCut source.base 10240 request.cachesBelow.1 request.sourceLower)
    have physical : chosen.execution.outputBuffer.base=
        frontier.cursor+79872+Kernels.Attention.SdpaWorkspace.bytes
          (Kernels.Attention.SdpaDispatched.blockCount layer.mixer.architectureSuffix (tokens+1))+34816+720896 :=
      ResidualAttentionExistingHighWater.output_base source storage.1
        (DecodeParameterConstruction.remainingParameters position parameters).1 frontier request.capacity request.sourceBound
        _ request.caches_before.1 request.dispatch.1 request.dispatch.2 angle request.room _ _
    change cacheCut≤chosen.execution.outputBuffer.base
    rw [physical]
    exact request.ordered.2.trans ((Nat.le_add_right _ _).trans
      ((Nat.le_add_right _ _).trans ((Nat.le_add_right _ _).trans (Nat.le_add_right _ _))))

-- An updated cache either keeps an old attention region or occupies fresh
-- Delta workspace. This transports arbitrary geometric predicates.
theorem updated_geometry (property : Nat → Nat → Prop)
    (old : DecodePreservation.StageProtected property kind cache.1 storage.1.storage)
    (freshRegion : ∀ base size, frontier.cursor≤base → property base size) :
    DecodePreservation.StageProtected property kind (cacheAfter kind cache.1 input angle)
      (plan position cache input angle source storage parameters frontier request).step.first.cacheAfter.storage := by
  cases kind with
  | delta layer =>
    apply (ResidualDeltaHighWater.afterStorage_regions
      (ResidualDeltaHighWater.execution source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier request.capacity request.sourceBound
        (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1) property).mpr
    rw [(ResidualDeltaHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier request.capacity request.sourceBound
        (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1).1,
      (ResidualDeltaHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier request.capacity request.sourceBound
        (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1).2]
    exact ⟨freshRegion _ _ (Nat.le_add_right _ _),freshRegion _ _ (Nat.le_add_right _ _)⟩
  | attention layer =>
    exact ResidualAttentionExistingHighWater.boundStep_geometry position cache input angle source storage parameters frontier
      request.capacity request.sourceBound _ request.caches_before request.pairwise request.dispatch.1 request.dispatch.2 request.room _ property old

theorem updated_above : DecodePreservation.StageProtected (After parameterCut) kind
    (cacheAfter kind cache.1 input angle)
    (plan position cache input angle source storage parameters frontier request).step.first.cacheAfter.storage :=
  updated_geometry position cache input angle source storage parameters frontier request _ request.cachesAbove.1
    (fun _ _ lower => (request.ordered.1.trans request.ordered.2).trans lower)

theorem updated_separate {base size : Nat} (bound : Before frontier.cursor base size)
    (separate : DecodePreservation.Protected (MemoryRegions.Disjoint base size) (kind::rest) cache source.bytes storage) :
    DecodePreservation.StageProtected (MemoryRegions.Disjoint base size) kind (cacheAfter kind cache.1 input angle)
      (plan position cache input angle source storage parameters frontier request).step.first.cacheAfter.storage :=
  updated_geometry position cache input angle source storage parameters frontier request _ separate.1
    (fun _ _ lower => Or.inl (bound.trans lower))

-- Untouched caches keep their original addresses, while their bytes are
-- transported to the actual predecessor output heap.
theorem parameters_bound : DecodeParameterMemory.Protected all
    (plan position cache input angle source storage parameters frontier request).nextParameters (Before parameterCut) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr request.parametersBound

theorem retained_geometry (property : Nat → Nat → Prop)
    (safe : DecodePreservation.Protected property rest cache.2 source.bytes storage.2) :
    DecodePreservation.Protected property rest cache.2 _
      (plan position cache input angle source storage parameters frontier request).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest cache.2 storage.2
    (plan position cache input angle source storage parameters frontier request).retained safe

theorem retained_below : DecodePreservation.Protected (Before cacheCut) rest cache.2 _
    (plan position cache input angle source storage parameters frontier request).step.nextStorage :=
  retained_geometry position cache input angle source storage parameters frontier request _ request.cachesBelow.2

theorem retained_above : DecodePreservation.Protected (After parameterCut) rest cache.2 _
    (plan position cache input angle source storage parameters frontier request).step.nextStorage :=
  retained_geometry position cache input angle source storage parameters frontier request _ request.cachesAbove.2

theorem retained_regions : DecodeCacheGeometry.regions rest cache.2 _
    (plan position cache input angle source storage parameters frontier request).step.nextStorage=
    DecodeCacheGeometry.regions rest cache.2 source.bytes storage.2 :=
  DecodeCacheGeometry.reframe_regions _ _ _ _ _ _ _ _

theorem retained_pairwise : DecodeCacheGeometry.Pairwise rest cache.2 _
    (plan position cache input angle source storage parameters frontier request).step.nextStorage := by
  unfold DecodeCacheGeometry.Pairwise
  rw [retained_regions]
  exact (List.pairwise_append.mp request.pairwise).2.1

theorem updated_apart : DecodePreservation.StageProtected
    (fun base size => DecodePreservation.Protected (MemoryRegions.Disjoint base size) rest cache.2 _
      (plan position cache input angle source storage parameters frontier request).step.nextStorage)
    kind (cacheAfter kind cache.1 input angle)
    (plan position cache input angle source storage parameters frontier request).step.first.cacheAfter.storage := by
  apply updated_geometry position cache input angle source storage parameters frontier request
  · apply (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mpr
    intro region member
    exact retained_geometry position cache input angle source storage parameters frontier request _
      (DecodeCacheGeometry.head_separate_tail kind rest cache source.bytes storage request.pairwise region member)
  · intro base size lower
    exact cacheProtected_mono rest cache.2 _
      (fun _ _ bound => Or.inr (bound.trans (request.ordered.2.trans lower)))
      (retained_below position cache input angle source storage parameters frontier request)

-- A retained region must avoid old caches as well as new workspace writes.
theorem writes {base size : Nat} (bound : Before frontier.cursor base size)
    (separate : DecodePreservation.Protected (MemoryRegions.Disjoint base size) (kind::rest) cache source.bytes storage) :
    (plan position cache input angle source storage parameters frontier request).step.first.Safe base size := by
  cases kind with
  | delta layer =>
    exact ResidualDeltaHighWater.stage_safe_before source storage.1
      (DecodeParameterConstruction.remainingParameters position parameters).1 frontier request.capacity request.sourceBound
      (ResidualDeltaHighWater.remaining_protected position parameters request.parameters_before).1 request.caches_before.1 angle bound
  | attention layer =>
    exact ResidualAttentionExistingHighWater.boundStep_safe_before position cache input angle source storage parameters frontier
      request.capacity request.sourceBound _ request.caches_before request.pairwise request.dispatch.1 request.dispatch.2 request.room _ bound
      ⟨MemoryRegions.disjoint_symm separate.1.1,MemoryRegions.disjoint_symm separate.1.2⟩

end Inference.Models.Qwen.DecodeExistingStepConstruction
