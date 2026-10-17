import models.qwen.CapacityCopiedAttentionHighWater
import models.qwen.CapacityCopiedDeltaHighWater

namespace Inference.Models.Qwen.CapacityCopiedHighWaterConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before before_mono cacheProtected_mono)
set_option maxRecDepth 10000

open CapacityCopiedWorkspace (stageBytes bytes next bytes_aligned)
variable {n : Nat}
private theorem next_cursor (n : Nat) (frontier : Frontier) (stage : Stage) :
    (next n frontier stage).cursor=frontier.cursor+stageBytes n stage := rfl

def Dispatch : Stage → Prop
  | .delta _ => True
  | .attention layer => layer.mixer.preparation.qNorm.platform.groups=2 ∧ layer.mixer.preparation.kNorm.platform.groups=2

def Dispatches : List Stage → Prop
  | [] => True
  | stage::rest => Dispatch stage ∧ Dispatches rest

variable {all rest : List Stage} {kind : Stage}
  (position : CapacityAttentionParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

-- This record is produced by the concrete Delta/attention constructors below.
-- Callers supply live-region bounds, not a completed execution or its result.
structure Step where
  plan : CapacityAttentionParameterConstruction.StepPlan position cache input angle source storage parameters
  writes : ∀ base size, Before frontier.cursor base size → plan.step.first.Safe base size
  outputBound : Before (next n frontier kind).cursor plan.step.first.buffer.base 10240
  updatedBound : DecodePreservation.StageProtected (Before (next n frontier kind).cursor) kind
    (cacheAfter kind cache.1 input angle) plan.step.first.cacheAfter.storage
  parametersBound : DecodeParameterMemory.Protected all plan.nextParameters (Before (next n frontier kind).cursor)
  built : CopiedAttentionOriginalTailChains.Capacity.StageBuilt kind cache.1 input angle source storage.1
    (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 plan.first
  retainedBound : DecodePreservation.Protected (Before (next n frontier kind).cursor) rest cache.2 _ plan.step.nextStorage

def step (capacity : (next n frontier kind).cursor≤2^64)
    (sourceBound : Before frontier.cursor source.base 10240)
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
    (positive : 0<n)
    (dispatch : Dispatch kind) : Step position cache input angle source storage parameters frontier := by
  cases kind with
  | delta layer =>
    exact {
      plan := CapacityCopiedDeltaHighWater.step position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      writes := fun _ _ bound => CapacityCopiedDeltaHighWater.writes position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound bound
      outputBound := CapacityCopiedDeltaHighWater.output_bound position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      updatedBound := CapacityCopiedDeltaHighWater.updated_bound position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      parametersBound := CapacityCopiedDeltaHighWater.parameters_bound position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      retainedBound := CapacityCopiedDeltaHighWater.retained_bound position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      built := trivial }
  | attention layer =>
    exact {
      plan := CapacityCopiedAttentionHighWater.step (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
      writes := fun _ _ bound => CapacityCopiedAttentionHighWater.writes (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2) bound
      outputBound := CapacityCopiedAttentionHighWater.output_bound (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
      updatedBound := CapacityCopiedAttentionHighWater.updated_bound (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
      parametersBound := CapacityCopiedAttentionHighWater.parameters_bound (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
      retainedBound := CapacityCopiedAttentionHighWater.retained_bound (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
      built := CapacityCopiedAttentionHighWater.built (position := position) (cache := cache) (input := input) (angle := angle) (source := source) (storage := storage) (parameters := parameters) (frontier := frontier) (capacity := capacity) (sourceBound := sourceBound) (parametersBound := parametersBound) (cachesBound := cachesBound) (positive := positive) (queryDispatch := dispatch.1) (keyDispatch := dispatch.2)
    }

section Result
variable {stages : List Stage}
  (position : CapacityAttentionParameterConstruction.Cursor all stages)
  (cache : Caches stages n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

structure Result where
  plan : CapacityAttentionParameterConstruction.ChainPlan stages position cache input angle source storage parameters
  safeBefore : ∀ base size, Before frontier.cursor base size →
    CapacityAttentionDecodeChain.Safe stages cache input angle source storage
      (CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters plan) base size
  built : CopiedAttentionOriginalTailChains.Capacity.Built stages position cache input angle source storage parameters plan
  cacheSafe : CapacityAttentionParameterConstruction.CacheRegions stages position cache input angle source storage parameters plan
  outputBound : Before (frontier.cursor+bytes n stages)
    (CapacityAttentionParameterConstruction.outputBuffer stages position cache input angle source storage parameters plan).base 10240
  cachesBound : DecodePreservation.Protected (Before (frontier.cursor+bytes n stages)) stages
    (DecodeChain.run stages cache input angle).2 _
    (CapacityAttentionParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)

end Result

theorem stage_mono {n : Nat} (stage : Stage) (cache : Cache stage n) (storage : DecodeFrame.StageStorage stage cache)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : DecodePreservation.StageProtected first stage cache storage) :
    DecodePreservation.StageProtected second stage cache storage := by
  cases stage <;> exact ⟨implies _ _ safe.1,implies _ _ safe.2⟩

-- Structural recursion consumes one concrete constructed launch at a time.
def build : (stages : List Stage) → (position : CapacityAttentionParameterConstruction.Cursor all stages) →
    (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    frontier.cursor+bytes n stages≤2^64 → Before frontier.cursor source.base 10240 →
    DecodeParameterMemory.Protected all parameters (Before frontier.cursor) →
    DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage →
    0<n → Dispatches stages →
    Result position cache input angle source storage parameters frontier
  | [], _, _, _, _, _, _, _, _, _, sourceBound, _, _, _, _ => {
      plan := ⟨⟩
      safeBefore := fun _ _ _ => trivial
      built := trivial
      cacheSafe := trivial
      outputBound := by simpa only [CapacityAttentionParameterConstruction.outputBuffer,CapacityAttentionDecodeChain.outputBuffer,bytes,Nat.add_zero] using sourceBound
      cachesBound := trivial }
  | kind::rest, position, cache, input, angle, source, storage, parameters, frontier, capacity, sourceBound, parametersBound, cachesBound, positive, dispatch => by
    have headCapacity : (next n frontier kind).cursor≤2^64 := by
      rw [next_cursor]
      change frontier.cursor+(stageBytes n kind+bytes n rest)≤2^64 at capacity
      omega
    let first := step position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound positive dispatch.1
    have tailCapacity : (next n frontier kind).cursor+bytes n rest≤2^64 := by
      rw [next_cursor]
      simpa only [bytes,Nat.add_assoc] using capacity
    let tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters
      (next n frontier kind) tailCapacity first.outputBound first.parametersBound first.retainedBound positive dispatch.2
    have headSurvives : DecodePreservation.StageProtected
        (CapacityAttentionDecodeChain.Safe rest cache.2 (forward kind cache.1 input angle) angle first.plan.step.first.buffer first.plan.step.nextStorage
          (CapacityAttentionParameterConstruction.chain rest (.next position) cache.2 (forward kind cache.1 input angle) angle
            first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters tail.plan))
        kind (cacheAfter kind cache.1 input angle) first.plan.step.first.cacheAfter.storage :=
      stage_mono kind _ _ (fun _ _ bound => tail.safeBefore _ _ bound) first.updatedBound
    refine {
      plan := ⟨first.plan,tail.plan⟩
      safeBefore := ?_
      built := ⟨first.built,tail.built⟩
      cacheSafe := ⟨headSurvives,tail.cacheSafe⟩
      outputBound := ?_
      cachesBound := ?_ }
    · intro base size bound
      exact ⟨first.writes base size bound,tail.safeBefore base size
        (before_mono (by rw [next_cursor]; omega) bound)⟩
    · have bound := tail.outputBound
      rw [next_cursor] at bound
      simpa only [CapacityAttentionParameterConstruction.outputBuffer,CapacityAttentionDecodeChain.outputBuffer,CapacityAttentionParameterConstruction.chain,bytes,Nat.add_assoc] using bound
    · constructor
      · exact DecodePreservation.stage_preserves_geometry _ _ _ _
          (fun base size safe => CapacityAttentionDecodeChain.other_region rest cache.2 (forward kind cache.1 input angle) angle
            first.plan.step.first.buffer first.plan.step.nextStorage
            (CapacityAttentionParameterConstruction.chain rest (.next position) cache.2 (forward kind cache.1 input angle) angle
              first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters tail.plan) base size safe)
          kind (cacheAfter kind cache.1 input angle) first.plan.step.first.cacheAfter headSurvives
          (stage_mono kind _ _ (fun _ _ bound => before_mono
            (by rw [next_cursor]; dsimp [bytes]; omega) bound) first.updatedBound)
      · have bound := tail.cachesBound
        rw [next_cursor] at bound
        simpa only [CapacityAttentionParameterConstruction.after,CapacityAttentionParameterConstruction.chain,CapacityAttentionDecodeChain.after,
          CapacityAttentionDecodeChain.outputBuffer,DecodeChain.run,bytes,Nat.add_assoc] using bound

section Derived
variable {stages : List Stage} {position : CapacityAttentionParameterConstruction.Cursor all stages}
  {cache : Caches stages n} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes} {frontier : Frontier}
  (result : Result position cache input angle source storage parameters frontier)

def Result.endFrontier (_result : Result position cache input angle source storage parameters frontier) : Frontier where
  cursor := frontier.cursor+bytes n stages
  aligned := by rw [Nat.add_mod,frontier.aligned,bytes_aligned]

theorem Result.other_region {base size : Nat} (bound : Before frontier.cursor base size) (offset : Nat) (inside : offset<size) :
    (CapacityAttentionParameterConstruction.outputBuffer stages position cache input angle source storage parameters result.plan).bytes (base+offset)=
      source.bytes (base+offset) :=
  CapacityAttentionDecodeChain.other_region stages cache input angle source storage
    (CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters result.plan)
    base size (result.safeBefore base size bound) offset inside

theorem Result.read_result : CapacityAttentionParameterConstruction.readResult stages position cache input angle source storage parameters
    result.plan result.cacheSafe=DecodeChain.run stages cache input angle :=
  CapacityAttentionParameterConstruction.read_result_eq stages position cache input angle source storage parameters result.plan result.cacheSafe

theorem Result.parameters_bound (bound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Protected all
      (CapacityAttentionParameterConstruction.finalParameters stages position cache input angle source storage parameters result.plan)
      (Before result.endFrontier.cursor) :=
  (CapacityAttentionParameterConstruction.finalParameters_regions stages position cache input angle source storage parameters result.plan _).mpr
    (DecodeParameterMemory.protected_mono all parameters (fun _ _ region => before_mono (Nat.le_add_right _ _) region) bound)

end Derived

end Inference.Models.Qwen.CapacityCopiedHighWaterConstruction
