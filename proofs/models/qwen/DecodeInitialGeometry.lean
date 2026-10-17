import models.qwen.DecodeInitialConstruction
import models.qwen.DecodeInitialChainGeometry

namespace Inference.Models.Qwen.DecodeInitialGeometry
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
open DecodeInitialConstruction
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

open DecodeInitialChainGeometry (After after_lower after_pairwise)

section Stage
variable {all rest : List Stage} {kind : Stage}
  (position : DecodeParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (next frontier kind).cursor≤2^64)
  (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
  (dispatch : DecodeHighWaterConstruction.Dispatch kind) (keyCopied valueCopied : Bool)

theorem step_lower : DecodePreservation.StageProtected (After frontier.cursor) kind
    (cacheAfter kind cache.1 input angle)
    (step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch keyCopied valueCopied).first.cacheAfter.storage := by
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
    let workspace := attentionWorkspace (position:=position) (cache:=cache) (input:=input)
      (source:=source) (storage:=storage) (parameters:=parameters) (frontier:=frontier)
      capacity sourceBound parametersBound dispatch
    change After frontier.cursor (workspace.execution angle keyCopied valueCopied).afterCache.layout.keyBase _ ∧
      After frontier.cursor (workspace.execution angle keyCopied valueCopied).afterCache.layout.valueBase _
    have lower := workspace.cache_lower angle keyCopied valueCopied
    exact ⟨(Nat.le_add_right _ _).trans lower.1,(Nat.le_add_right _ _).trans lower.2⟩
end Stage

section Build
variable {all : List Stage}

def Geometry {stages : List Stage} {cache : Caches stages 0} {input : Row BF} {angle : RopeAngles.Inputs}
    {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes} {frontier : Frontier}
    (result : Result cache input angle source storage frontier) : Prop :=
  DecodePreservation.Protected (After frontier.cursor) stages (DecodeChain.run stages cache input angle).2 _ result.after ∧
  DecodeCacheGeometry.Pairwise stages (DecodeChain.run stages cache input angle).2 _ result.after

theorem build_geometry : (stages : List Stage) → (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    (capacity : frontier.cursor+bytes stages≤2^64) → (sourceBound : Before frontier.cursor source.base 10240) →
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) →
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage) →
    (dispatch : DecodeHighWaterConstruction.Dispatches stages) → (keyCopied valueCopied : Bool) →
    Geometry (build stages position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch keyCopied valueCopied)
  | [], _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ => ⟨trivial,List.Pairwise.nil⟩
  | kind::rest, position, cache, input, angle, source, storage, parameters, frontier, capacity, sourceBound, parametersBound, cachesBound, dispatch, keyCopied, valueCopied => by
    have headCapacity : (next frontier kind).cursor≤2^64 := by
      change frontier.cursor+(stageBytes kind+bytes rest)≤2^64 at capacity
      change frontier.cursor+stageBytes kind≤2^64
      omega
    let first := step position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound dispatch.1 keyCopied valueCopied
    have tailCapacity : (next frontier kind).cursor+bytes rest≤2^64 := by
      simpa only [next,bytes,Nat.add_assoc] using capacity
    let tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.first.buffer (first.chainStep cachesBound).nextStorage (first.nextParameters parameters parametersBound)
      (next frontier kind) tailCapacity first.outputBound (first.parameters_bound parameters parametersBound) (first.retained_bound cachesBound) dispatch.2 keyCopied valueCopied
    have tailGeometry := build_geometry rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.first.buffer (first.chainStep cachesBound).nextStorage (first.nextParameters parameters parametersBound)
      (next frontier kind) tailCapacity first.outputBound (first.parameters_bound parameters parametersBound) (first.retained_bound cachesBound) dispatch.2 keyCopied valueCopied
    have lower := step_lower position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound dispatch.1 keyCopied valueCopied
    have monotone : frontier.cursor≤(next frontier kind).cursor := Nat.le_add_right _ _
    let result := build (kind::rest) position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch keyCopied valueCopied
    refine ⟨?_,?_⟩
    · exact after_lower cache input angle source storage result.trace result.cacheSafe frontier.cursor lower
        (ResidualDeltaHighWater.cacheProtected_mono rest _ _ (fun _ _ h => monotone.trans h) tailGeometry.1)
    · exact after_pairwise cache input angle source storage result.trace result.cacheSafe (next frontier kind).cursor
        first.updatedBound tailGeometry.1 tailGeometry.2
theorem Geometry.after_cut {stages : List Stage} {cache : Caches stages 0} {input : Row BF} {angle : RopeAngles.Inputs}
    {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes} {frontier : Frontier}
    {result : Result cache input angle source storage frontier} (geometry : Geometry result)
    (cut : Nat) (ordered : cut≤frontier.cursor) :
    DecodePreservation.Protected (After cut) stages (DecodeChain.run stages cache input angle).2 _ result.after ∧
    DecodeCacheGeometry.Pairwise stages (DecodeChain.run stages cache input angle).2 _ result.after :=
  ⟨ResidualDeltaHighWater.cacheProtected_mono stages _ _ (fun _ _ lower => ordered.trans lower) geometry.1,geometry.2⟩

end Build

end Inference.Models.Qwen.DecodeInitialGeometry
