import models.qwen.DecodeHighWaterConstruction
import models.qwen.DecodeCacheGeometry

namespace Inference.Models.Qwen.DecodeHighWaterGeometry
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
open DecodeHighWaterConstruction
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def After (cursor base _size : Nat) : Prop := cursor≤base

section Stage
variable {all rest : List Stage} {kind : Stage} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (next frontier kind tokens).cursor≤2^64)
  (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
  (dispatch : Dispatch kind) (growing : State.KvAllocation.capacity tokens<tokens+1)

theorem step_lower : DecodePreservation.StageProtected (After frontier.cursor) kind
    (cacheAfter kind cache.1 input angle)
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch growing).plan.step.first.cacheAfter.storage := by
  cases kind with
  | delta layer =>
    apply (ResidualDeltaHighWater.afterStorage_regions
      (ResidualDeltaHighWater.execution source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1) _).mpr
    rw [(ResidualDeltaHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
      frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1).1,
      (ResidualDeltaHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
      frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1).2]
    exact ⟨Nat.le_add_right _ _,Nat.le_add_right _ _⟩
  | attention layer =>
    change After frontier.cursor
      (ResidualAttentionHighWater.execution source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1 dispatch.1 dispatch.2 angle growing).afterCache.layout.keyBase _ ∧
      After frontier.cursor
      (ResidualAttentionHighWater.execution source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
        frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1 dispatch.1 dispatch.2 angle growing).afterCache.layout.valueBase _
    rw [(ResidualAttentionHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
      frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1 dispatch.1 dispatch.2 angle growing).1,
      (ResidualAttentionHighWater.cache_bases source storage.1 (DecodeParameterConstruction.remainingParameters position parameters).1
      frontier capacity sourceBound (ResidualDeltaHighWater.remaining_protected position parameters parametersBound).1 cachesBound.1 dispatch.1 dispatch.2 angle growing).2]
    exact ⟨(Nat.le_add_right _ _).trans (Nat.le_add_right _ _),
      (Nat.le_add_right _ _).trans ((Nat.le_add_right _ _).trans (Nat.le_add_right _ _))⟩
end Stage

section Chain
variable {kind : Stage} {rest : List Stage} {tokens : Nat}
  (cache : Caches (kind::rest) tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (trace : DecodeMemoryChain.Trace (kind::rest) cache input angle source storage)
  (safe : DecodeMemoryChain.CacheSafe (kind::rest) cache input angle source storage trace)

theorem after_regions :
    DecodeCacheGeometry.regions (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeMemoryChain.after (kind::rest) cache input angle source storage trace safe)=
    DecodeCacheGeometry.stageRegions kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage ++
      DecodeCacheGeometry.regions rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
        (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2) := by
  simp only [DecodeCacheGeometry.regions,DecodeMemoryChain.after,DecodeChain.run,
    DecodeCacheGeometry.stage_reframe_regions,DecodeMemoryChain.outputBuffer]


theorem after_lower (cursor : Nat)
    (head : DecodePreservation.StageProtected (After cursor) kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tail : DecodePreservation.Protected (After cursor) rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodePreservation.Protected (After cursor) (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  apply (DecodeCacheGeometry.protected_iff _ _ _ _ _).mpr
  rw [after_regions]
  intro region member
  rcases List.mem_append.mp member with first|second
  · exact (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp head region first
  · exact (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp tail region second

theorem after_pairwise (cursor : Nat)
    (head : DecodePreservation.StageProtected (Before cursor) kind (cacheAfter kind cache.1 input angle) trace.1.first.cacheAfter.storage)
    (tail : DecodePreservation.Protected (After cursor) rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2))
    (tailPairwise : DecodeCacheGeometry.Pairwise rest (DecodeChain.run rest cache.2 (forward kind cache.1 input angle) angle).2 _
      (DecodeMemoryChain.after rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2 safe.2)) :
    DecodeCacheGeometry.Pairwise (kind::rest) (DecodeChain.run (kind::rest) cache input angle).2 _
      (DecodeMemoryChain.after (kind::rest) cache input angle source storage trace safe) := by
  unfold DecodeCacheGeometry.Pairwise
  rw [after_regions]
  apply List.pairwise_append.mpr
  refine ⟨DecodeCacheGeometry.stage_pairwise _ _ _,tailPairwise,?_⟩
  intro first firstMember second secondMember
  have upper := (DecodeCacheGeometry.stage_protected_iff _ _ _ _).mp head first firstMember
  have lower := (DecodeCacheGeometry.protected_iff _ _ _ _ _).mp tail second secondMember
  exact Or.inl (upper.trans lower)

end Chain

section Build
variable {all : List Stage} {tokens : Nat}

def Geometry {stages : List Stage} {position : DecodeParameterConstruction.Cursor all stages}
    {cache : Caches stages tokens} {input : Row BF} {angle : RopeAngles.Inputs}
    {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes}
    {parameters : DecodeParameterMemory.Storage all source.bytes} {frontier : Frontier}
    (result : Result position cache input angle source storage parameters frontier) : Prop :=
  DecodePreservation.Protected (After frontier.cursor) stages (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters result.plan result.cacheSafe) ∧
  DecodeCacheGeometry.Pairwise stages (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters result.plan result.cacheSafe)

theorem build_geometry : (stages : List Stage) → (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages tokens) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    (capacity : frontier.cursor+bytes stages tokens≤2^64) → (sourceBound : Before frontier.cursor source.base 10240) →
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) →
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage) →
    (dispatch : Dispatches stages) → (growing : State.KvAllocation.capacity tokens<tokens+1) →
    Geometry (build stages position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch growing)
  | [], _, _, _, _, _, _, _, _, _, _, _, _, _, _ => ⟨trivial,List.Pairwise.nil⟩
  | kind::rest, position, cache, input, angle, source, storage, parameters, frontier, capacity, sourceBound, parametersBound, cachesBound, dispatch, growing => by
    have headCapacity : (next frontier kind tokens).cursor≤2^64 := by
      rw [next_cursor]
      change frontier.cursor+(stageBytes kind tokens+bytes rest tokens)≤2^64 at capacity
      omega
    let first := step position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound dispatch.1 growing
    have tailCapacity : (next frontier kind tokens).cursor+bytes rest tokens≤2^64 := by
      rw [next_cursor]
      simpa only [bytes,Nat.add_assoc] using capacity
    let tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters
      (next frontier kind tokens) tailCapacity first.outputBound first.parametersBound first.retainedBound dispatch.2 growing
    have tailGeometry := build_geometry rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters
      (next frontier kind tokens) tailCapacity first.outputBound first.parametersBound first.retainedBound dispatch.2 growing
    have lower := step_lower position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound dispatch.1 growing
    have monotone : frontier.cursor≤(next frontier kind tokens).cursor := by rw [next_cursor]; exact Nat.le_add_right _ _
    let result := build (kind::rest) position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch growing
    let trace := DecodeParameterConstruction.chain (kind::rest) position cache input angle source storage parameters result.plan
    let safe := DecodeParameterConstruction.cacheSafe (kind::rest) position cache input angle source storage parameters result.plan result.cacheSafe
    refine ⟨?_,?_⟩
    · exact after_lower cache input angle source storage trace safe frontier.cursor lower
        (ResidualDeltaHighWater.cacheProtected_mono rest _ _ (fun _ _ h => monotone.trans h) tailGeometry.1)
    · exact after_pairwise cache input angle source storage trace safe (next frontier kind tokens).cursor
        first.updatedBound tailGeometry.1 tailGeometry.2
end Build

end Inference.Models.Qwen.DecodeHighWaterGeometry
