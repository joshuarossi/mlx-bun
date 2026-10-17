import models.qwen.CopiedCapacityGrowthBounds
namespace Inference.Models.Qwen.CopiedCapacityGrowthChainBounds
open Contracts.Mlx Layers State DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before)
set_option maxRecDepth 10000

variable {n : Nat}

def StageBounded : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CapacityAttentionDecodeStage.Execution kind cache input angle → Prop
  | .delta _,_,_,_,_ => True
  | .attention _,_,_,_,execution => CopiedCapacityGrowthBounds.Bounded _ execution.val.preparation.preparation

def ChainBounded : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    CapacityAttentionDecodeChain.Trace stages cache input angle source storage → Prop
  | [],_,_,_,_,_,_ => True
  | kind::rest,cache,input,angle,_,_,trace =>
    StageBounded kind cache.1 input angle trace.1.first.execution ∧
      ChainBounded rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

section Step
variable {all rest : List Stage} {kind : Stage}
  (position : CapacityAttentionParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : (CapacityCopiedWorkspace.next n frontier kind).cursor≤2^64)
  (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
  (positive : 0<n) (dispatch : CapacityCopiedHighWaterConstruction.Dispatch kind)

theorem step : StageBounded kind cache.1 input angle
    (CapacityCopiedHighWaterConstruction.step position cache input angle source storage parameters frontier
      capacity sourceBound parametersBound cachesBound positive dispatch).plan.step.first.execution := by
  cases kind with
  | delta _ => exact True.intro
  | attention layer =>
    let request : CopiedAttentionCapacityArenaHighWater.Request source
        (CapacityAttentionParameterConstruction.remainingParameters position parameters).1 storage.1.storage storage.1.shared := {
      frontier := frontier
      queryDispatch := dispatch.1
      keyDispatch := dispatch.2
      positive := positive
      sourceBefore := sourceBound
      parametersBefore := (CapacityCopiedDeltaHighWater.remaining_protected position parameters parametersBound).1
      keysBelow := cachesBound.1.1
      valuesBelow := cachesBound.1.2
      capacity := capacity }
    exact CopiedCapacityGrowthBounds.highwater_plan request angle
end Step

-- The concrete recursive arena builder supplies every temporary-slab bound;
-- callers do not add bounds or scalar-source assumptions to completed plans.
theorem build {all : List Stage} : (stages : List Stage) →
    (position : CapacityAttentionParameterConstruction.Cursor all stages) →
    (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    (capacity : frontier.cursor+CapacityCopiedWorkspace.bytes n stages≤2^64) →
    (sourceBound : Before frontier.cursor source.base 10240) →
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) →
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage) →
    (positive : 0<n) → (dispatch : CapacityCopiedHighWaterConstruction.Dispatches stages) →
    ChainBounded stages cache input angle source storage
      (CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters
        (CapacityCopiedHighWaterConstruction.build stages position cache input angle source storage parameters frontier
          capacity sourceBound parametersBound cachesBound positive dispatch).plan)
  | [],_,_,_,_,_,_,_,_,_,_,_,_,_,_ => True.intro
  | kind::rest,position,cache,input,angle,source,storage,parameters,frontier,capacity,sourceBound,parametersBound,cachesBound,positive,dispatch => by
    have headRoom := CapacityCopiedWorkspace.head_room n frontier kind rest capacity
    let first := CapacityCopiedHighWaterConstruction.step position cache input angle source storage parameters frontier
      headRoom sourceBound parametersBound cachesBound positive dispatch.1
    have tailRoom := CapacityCopiedWorkspace.tail_room n frontier kind rest capacity
    have tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.plan.step.first.buffer first.plan.step.nextStorage first.plan.nextParameters
      (CapacityCopiedWorkspace.next n frontier kind) tailRoom first.outputBound first.parametersBound first.retainedBound positive dispatch.2
    exact ⟨step position cache input angle source storage parameters frontier headRoom sourceBound parametersBound cachesBound positive dispatch.1,tail⟩

end Inference.Models.Qwen.CopiedCapacityGrowthChainBounds
