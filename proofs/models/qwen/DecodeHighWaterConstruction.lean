import models.qwen.ResidualAttentionHighWater
import models.qwen.Qwen38TrellisM1MaxWorkspaceFootprint

namespace Inference.Models.Qwen.DecodeHighWaterConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before before_mono cacheProtected_mono remaining_protected)
set_option maxRecDepth 10000

def stageBytes : Stage → Nat → Nat
  | .delta _, _ => ResidualDeltaAllocation.bytes
  | .attention layer, tokens => ResidualAttentionHighWater.fixedBytes layer tokens+State.KvGrowthAllocation.bytes tokens

def bytes : List Stage → Nat → Nat
  | [], _ => 0
  | stage::rest, tokens => stageBytes stage tokens+bytes rest tokens

def next : Frontier → Stage → Nat → Frontier
  | frontier, .delta _, _ => frontier.next
  | frontier, .attention layer, tokens => ResidualAttentionHighWater.next frontier layer tokens

theorem next_cursor (frontier : Frontier) (stage : Stage) (tokens : Nat) :
    (next frontier stage tokens).cursor=frontier.cursor+stageBytes stage tokens := by
  cases stage <;> simp only [next,stageBytes,ResidualDeltaHighWater.Frontier.next,
    ResidualAttentionHighWater.next,Nat.add_assoc]

theorem stage_bytes_aligned (stage : Stage) (tokens : Nat) : stageBytes stage tokens%16=0 := by
  have aligned := (next ⟨0,by decide⟩ stage tokens).aligned
  simpa only [next_cursor,Nat.zero_add] using aligned

theorem bytes_aligned (stages : List Stage) (tokens : Nat) : bytes stages tokens%16=0 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => simp only [bytes,Nat.add_mod,stage_bytes_aligned,ih,Nat.zero_add,Nat.zero_mod]

theorem footprint_eq (stages : List Stage) (tokens : Nat) :
    bytes stages tokens=Qwen38TrellisM1MaxWorkspaceFootprint.bytes tokens stages := by
  induction stages with
  | nil => rfl
  | cons stage rest ih =>
    cases stage <;> simp only [bytes,stageBytes,Qwen38TrellisM1MaxWorkspaceFootprint.bytes,
      Qwen38TrellisM1MaxWorkspaceFootprint.stageBytes,ih]

theorem first_token_footprint (graph : Qwen38TrellisM1Max.Graph) : bytes graph.stages 0≤450451968 := by
  rw [footprint_eq]
  exact Qwen38TrellisM1MaxWorkspaceFootprint.first_token_bound_bytes graph

def Dispatch : Stage → Prop
  | .delta _ => True
  | .attention layer => layer.mixer.preparation.qNorm.platform.groups=2 ∧ layer.mixer.preparation.kNorm.platform.groups=2

def Dispatches : List Stage → Prop
  | [] => True
  | stage::rest => Dispatch stage ∧ Dispatches rest

variable {all rest : List Stage} {kind : Stage} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

-- This record is produced by the concrete Delta/attention constructors below.
-- Callers supply live-region bounds, not a completed execution or its result.
structure Step where
  plan : DecodeParameterConstruction.StepPlan position cache input angle source storage parameters
  writes : ∀ base size, Before frontier.cursor base size → plan.step.first.Safe base size
  outputBound : Before (next frontier kind tokens).cursor plan.step.first.buffer.base 10240
  updatedBound : DecodePreservation.StageProtected (Before (next frontier kind tokens).cursor) kind
    (cacheAfter kind cache.1 input angle) plan.step.first.cacheAfter.storage
  parametersBound : DecodeParameterMemory.Protected all plan.nextParameters (Before (next frontier kind tokens).cursor)
  retainedBound : DecodePreservation.Protected (Before (next frontier kind tokens).cursor) rest cache.2 _ plan.step.nextStorage

def step (capacity : (next frontier kind tokens).cursor≤2^64)
    (sourceBound : Before frontier.cursor source.base 10240)
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
    (dispatch : Dispatch kind) (growing : State.KvAllocation.capacity tokens<tokens+1) :
    Step position cache input angle source storage parameters frontier := by
  cases kind with
  | delta layer =>
    exact {
      plan := ResidualDeltaHighWater.boundStep position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      writes := fun _ _ bound => ResidualDeltaHighWater.stage_safe_before source storage.1
        (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
        (remaining_protected position parameters parametersBound).1 cachesBound.1 angle bound
      outputBound := ResidualDeltaHighWater.boundStep_output position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      updatedBound := ResidualDeltaHighWater.boundStep_updated position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      parametersBound := ResidualDeltaHighWater.boundStep_parameters position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound
      retainedBound := ResidualDeltaHighWater.boundStep_retained position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound }
  | attention layer =>
    exact {
      plan := ResidualAttentionHighWater.boundStep position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing
      writes := fun _ _ bound => ResidualAttentionHighWater.boundStep_safe_before position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing bound
      outputBound := ResidualAttentionHighWater.boundStep_output position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing
      updatedBound := ResidualAttentionHighWater.boundStep_updated position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing
      parametersBound := ResidualAttentionHighWater.boundStep_parameters position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing
      retainedBound := ResidualAttentionHighWater.boundStep_retained position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound dispatch.1 dispatch.2 growing }

section Result
variable {stages : List Stage}
  (position : DecodeParameterConstruction.Cursor all stages)
  (cache : Caches stages tokens) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

structure Result where
  plan : DecodeParameterConstruction.ChainPlan stages position cache input angle source storage parameters
  safeBefore : ∀ base size, Before frontier.cursor base size →
    DecodeMemoryChain.Safe stages cache input angle source storage
      (DecodeParameterConstruction.chain stages position cache input angle source storage parameters plan) base size
  cacheSafe : DecodeParameterConstruction.CacheRegions stages position cache input angle source storage parameters plan
  outputBound : Before (frontier.cursor+bytes stages tokens)
    (DecodeParameterConstruction.outputBuffer stages position cache input angle source storage parameters plan).base 10240
  cachesBound : DecodePreservation.Protected (Before (frontier.cursor+bytes stages tokens)) stages
    (DecodeChain.run stages cache input angle).2 _
    (DecodeParameterConstruction.after stages position cache input angle source storage parameters plan cacheSafe)

end Result

theorem stage_mono (stage : Stage) (cache : Cache stage tokens) (storage : DecodeFrame.StageStorage stage cache)
    {first second : Nat → Nat → Prop} (implies : ∀ base size, first base size → second base size)
    (safe : DecodePreservation.StageProtected first stage cache storage) :
    DecodePreservation.StageProtected second stage cache storage := by
  cases stage <;> exact ⟨implies _ _ safe.1,implies _ _ safe.2⟩

-- Structural recursion consumes one concrete constructed launch at a time.
def build : (stages : List Stage) → (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages tokens) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    frontier.cursor+bytes stages tokens≤2^64 → Before frontier.cursor source.base 10240 →
    DecodeParameterMemory.Protected all parameters (Before frontier.cursor) →
    DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage →
    Dispatches stages → State.KvAllocation.capacity tokens<tokens+1 →
    Result position cache input angle source storage parameters frontier
  | [], _, _, _, _, _, _, _, _, _, sourceBound, _, _, _, _ => {
      plan := ⟨⟩
      safeBefore := fun _ _ _ => trivial
      cacheSafe := trivial
      outputBound := by simpa only [DecodeParameterConstruction.outputBuffer,DecodeMemoryChain.outputBuffer,bytes,Nat.add_zero] using sourceBound
      cachesBound := trivial }
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
    have headSurvives : DecodePreservation.StageProtected
        (DecodeMemoryChain.Safe rest cache.2 (forward kind cache.1 input angle) angle first.plan.step.first.buffer first.plan.step.nextStorage
          (DecodeParameterConstruction.chain rest (.next position) cache.2 (forward kind cache.1 input angle) angle
            first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters tail.plan))
        kind (cacheAfter kind cache.1 input angle) first.plan.step.first.cacheAfter.storage :=
      stage_mono kind _ _ (fun _ _ bound => tail.safeBefore _ _ bound) first.updatedBound
    refine {
      plan := ⟨first.plan,tail.plan⟩
      safeBefore := ?_
      cacheSafe := ⟨headSurvives,tail.cacheSafe⟩
      outputBound := ?_
      cachesBound := ?_ }
    · intro base size bound
      exact ⟨first.writes base size bound,tail.safeBefore base size
        (before_mono (by rw [next_cursor]; omega) bound)⟩
    · have bound := tail.outputBound
      rw [next_cursor] at bound
      simpa only [DecodeParameterConstruction.outputBuffer,DecodeMemoryChain.outputBuffer,DecodeParameterConstruction.chain,bytes,Nat.add_assoc] using bound
    · constructor
      · exact DecodePreservation.stage_preserves_geometry _ _ _ _
          (fun base size safe => DecodeMemoryChain.other_region rest cache.2 (forward kind cache.1 input angle) angle
            first.plan.step.first.buffer first.plan.step.nextStorage
            (DecodeParameterConstruction.chain rest (.next position) cache.2 (forward kind cache.1 input angle) angle
              first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters tail.plan) base size safe)
          kind (cacheAfter kind cache.1 input angle) first.plan.step.first.cacheAfter headSurvives
          (stage_mono kind _ _ (fun _ _ bound => before_mono
            (by rw [next_cursor]; dsimp [bytes]; omega) bound) first.updatedBound)
      · have bound := tail.cachesBound
        rw [next_cursor] at bound
        simpa only [DecodeParameterConstruction.after,DecodeParameterConstruction.chain,DecodeMemoryChain.after,
          DecodeMemoryChain.outputBuffer,DecodeChain.run,bytes,Nat.add_assoc] using bound

section Derived
variable {stages : List Stage} {position : DecodeParameterConstruction.Cursor all stages}
  {cache : Caches stages tokens} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes} {frontier : Frontier}
  (result : Result position cache input angle source storage parameters frontier)

def Result.endFrontier (_result : Result position cache input angle source storage parameters frontier) : Frontier where
  cursor := frontier.cursor+bytes stages tokens
  aligned := by rw [Nat.add_mod,frontier.aligned,bytes_aligned]

theorem Result.other_region {base size : Nat} (bound : Before frontier.cursor base size) (offset : Nat) (inside : offset<size) :
    (DecodeParameterConstruction.outputBuffer stages position cache input angle source storage parameters result.plan).bytes (base+offset)=
      source.bytes (base+offset) :=
  DecodeMemoryChain.other_region stages cache input angle source storage
    (DecodeParameterConstruction.chain stages position cache input angle source storage parameters result.plan)
    base size (result.safeBefore base size bound) offset inside

theorem Result.read_result : DecodeParameterConstruction.readResult stages position cache input angle source storage parameters
    result.plan result.cacheSafe=DecodeChain.run stages cache input angle :=
  DecodeParameterConstruction.read_result_eq stages position cache input angle source storage parameters result.plan result.cacheSafe

theorem Result.parameters_bound (bound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Protected all
      (DecodeParameterConstruction.finalParameters stages position cache input angle source storage parameters result.plan)
      (Before result.endFrontier.cursor) :=
  (DecodeParameterConstruction.finalParameters_regions stages position cache input angle source storage parameters result.plan _).mpr
    (DecodeParameterMemory.protected_mono all parameters (fun _ _ region => before_mono (Nat.le_add_right _ _) region) bound)

end Derived

end Inference.Models.Qwen.DecodeHighWaterConstruction
