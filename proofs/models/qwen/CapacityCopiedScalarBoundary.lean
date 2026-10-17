import models.qwen.CopiedCapacityScalarSources
import models.qwen.CopiedCapacityGrowthChainBounds

namespace Inference.Models.Qwen.CapacityCopiedScalarBoundary
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention Kernels.Copy Kernels.Normalization
set_option maxRecDepth 10000
variable {n : Nat}

def StageBoundary : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    CapacityAttentionDecodeStage.Execution kind cache input angle → Type
  | .delta _,_,_,_,execution => NativeCopiedConstructedInputs.Capacity.StageBoundary _ _ _ _ execution
  | .attention _,_,_,_,execution => CopiedCapacityScalarSources.AttentionBoundary execution.val

def BoundaryInputs : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    CapacityAttentionDecodeChain.Trace stages cache input angle source storage → Type
  | [],_,_,_,_,_,_ => PUnit
  | kind::rest,cache,input,angle,_,_,trace =>
    StageBoundary kind cache.1 input angle trace.1.first.execution ×
    BoundaryInputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

private def stageBoundary (kind : Stage) (cache : Cache kind n) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer kind cache source.bytes)
    (trace : CapacityAttentionDecodeStage.Trace kind cache input angle source storage)
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) (shared : zero.bytes=source.bytes)
    (safe : trace.Safe zero.base 2)
    (bounded : CopiedCapacityGrowthChainBounds.StageBounded kind cache input angle trace.execution) (boundary : StageBoundary kind cache input angle trace.execution) :
    NativeCopiedConstructedInputs.Capacity.StageBoundary kind cache input angle trace.execution := by
  cases kind with
  | delta _ => exact boundary
  | attention layer =>
    have linked : trace.execution.val.input.lhs=source := trace.inputLinked
    exact CopiedCapacityScalarSources.Attention.boundary trace.execution.val zero (shared.trans (congrArg ArrayStorage.BFBuffer.bytes linked).symm) safe bounded boundary

private def fill : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : CapacityAttentionDecodeChain.Trace stages cache input angle source storage) →
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) → zero.bytes=source.bytes →
    CapacityAttentionDecodeChain.Safe stages cache input angle source storage trace zero.base 2 →
    CopiedCapacityGrowthChainBounds.ChainBounded stages cache input angle source storage trace →
    BoundaryInputs stages cache input angle source storage trace →
    NativeCopiedConstructedInputs.Capacity.BoundaryInputs stages cache input angle source storage trace
  | [],_,_,_,_,_,_,_,_,_,_,_ => PUnit.unit
  | kind::rest,cache,input,angle,source,storage,trace,zero,shared,safe,bounded,boundary =>
    let nextZero := ArrayFrame.bf zero trace.1.first.buffer.bytes
      (fun offset bound => (trace.1.first.other_region safe.1 offset bound).trans (congrFun shared _).symm)
    ⟨stageBoundary kind cache.1 input angle source storage.1 trace.1.first zero shared safe.1 bounded.1 boundary.1,
      fill rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2
        nextZero rfl safe.2 bounded.2 boundary.2⟩

variable {all stages : List Stage} (position : CapacityAttentionParameterConstruction.Cursor all stages)
  (cache : Caches stages n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : ResidualDeltaHighWater.Frontier)
  (capacity : frontier.cursor+CapacityCopiedWorkspace.bytes n stages≤2^64)
  (sourceBound : ResidualDeltaHighWater.Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (ResidualDeltaHighWater.Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (ResidualDeltaHighWater.Before frontier.cursor) stages cache source.bytes storage)
  (positive : 0<n)
  (dispatch : CapacityCopiedHighWaterConstruction.Dispatches stages)

abbrev result := CapacityCopiedHighWaterConstruction.build stages position cache input angle source storage parameters frontier
  capacity sourceBound parametersBound cachesBound positive dispatch

abbrev trace := CapacityAttentionParameterConstruction.chain stages position cache input angle source storage parameters
  (result position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive dispatch).plan

def inputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=source.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs stages cache input angle source storage
      (trace position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive dispatch)) :
    NativeCopiedConstructedInputs.Capacity.BoundaryInputs stages cache input angle source storage
      (trace position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive dispatch) :=
  fill stages cache input angle source storage _ zero shared
    ((result position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound positive dispatch).safeBefore zero.base 2 below)
    (CopiedCapacityGrowthChainBounds.build stages position cache input angle source storage parameters frontier
      capacity sourceBound parametersBound cachesBound positive dispatch) boundary

theorem inputs_nil {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.Storage (n:=n) [] () source.bytes}
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) (shared : zero.bytes=source.bytes) :
    fill (n:=n) [] () input angle source storage PUnit.unit zero shared trivial trivial PUnit.unit=PUnit.unit := rfl

end Inference.Models.Qwen.CapacityCopiedScalarBoundary
