import models.qwen.NativeCopiedConstructedInputs
import models.qwen.InitialCopiedHighWaterConstruction

namespace Inference.Models.Qwen.InitialCopiedScalarBoundary
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention Kernels.Copy Kernels.Normalization
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyInitialRead.Read.kv AttentionGateCopyInitialRead.Read.input
  AttentionGateCopyInitialResidualStage.block

private theorem bytes_one : KvRegions.bytes 1=524288 := by norm_num [KvRegions.bytes,KvAllocation.capacity]

structure AttentionBoundary {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0}
    {input : Row BF} {angle : RopeAngles.Inputs} (plan : AttentionGateCopyInitialResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyInitialResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat

namespace Attention
variable {layer : ResidualAttention.Layer} {cache : Kv.Cache Kv.BF 0} {input : Row BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyInitialResidualStage.Plan layer cache input angle)
  (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=plan.input.lhs.bytes)
  (safe : AttentionGateCopyInitialResidualStage.Safe plan zero.base 2)

private def currentZero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf zero plan.front.memory (fun offset bound =>
    (AttentionGateCopyPreservation.frame plan.front.rope safe.2.1.1 offset bound).trans
      ((congrFun (AttentionGateCopyInitialTrellisEntry.shared (layer:=layer) plan.normal plan.linked).symm _).trans
        ((plan.normal.other_region safe.1 offset bound).trans (congrFun shared _).symm)))

private def sources : InitialKvSourceMemory.Sources plan.read.kv.zeros where
  keyScalar := currentZero plan zero shared safe
  valueScalar := currentZero plan zero shared safe
  keyShared := plan.read.before.symm
  valueShared := plan.read.before.symm
  keyAllocation := {
    sourceAligned := zero.aligned
    sourceBounded := by simpa using (currentZero plan zero shared safe).bounded
    destinationAligned := plan.read.kv.layout.keyAligned
    destinationBounded := by
      have bound := plan.read.kv.layout.keyBound
      rw [bytes_one] at bound
      exact bound
    fresh := safe.2.1.2.keyZero }
  keyKeepsValue := safe.2.1.2.keyZero
  valueFresh := safe.2.1.2.valueZero

def boundary (native : AttentionBoundary plan) : NativeCopiedConstructedInputs.Initial.AttentionBoundary plan where
  trellis := native.trellis
  before := native.before
  kernel := native.kernel
  nativeThreads := native.nativeThreads
  scratch := native.scratch
  inverseBefore := native.inverseBefore
  base := native.base
  inverseBase := native.inverseBase
  sources := sources plan zero shared safe

theorem source_base (native : AttentionBoundary plan) :
    (boundary plan zero shared safe native).sources.keyScalar.base=zero.base := rfl
end Attention

def StageBoundary : (kind : Stage) → (cache : Cache kind 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    InitialCopiedDecodeStage.Execution kind cache input angle → Type
  | .delta _,_,_,_,execution => NativeCopiedConstructedInputs.Initial.StageBoundary _ _ _ _ execution
  | .attention _,_,_,_,execution => AttentionBoundary execution

def BoundaryInputs : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    InitialCopiedDecodeChain.Trace stages cache input angle source storage → Type
  | [],_,_,_,_,_,_ => PUnit
  | kind::rest,cache,input,angle,_,_,trace =>
    StageBoundary kind cache.1 input angle trace.1.first.execution ×
    BoundaryInputs rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2

private def stageBoundary (kind : Stage) (cache : Cache kind 0) (input : Row BF) (angle : RopeAngles.Inputs)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer kind cache source.bytes)
    (trace : InitialCopiedDecodeStage.Trace kind cache input angle source storage)
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) (shared : zero.bytes=source.bytes)
    (safe : trace.Safe zero.base 2) (boundary : StageBoundary kind cache input angle trace.execution) :
    NativeCopiedConstructedInputs.Initial.StageBoundary kind cache input angle trace.execution := by
  cases kind with
  | delta _ => exact boundary
  | attention layer =>
    have linked : trace.execution.input.lhs=source := trace.inputLinked
    exact Attention.boundary trace.execution zero (shared.trans (congrArg ArrayStorage.BFBuffer.bytes linked).symm) safe boundary

private def fill : (stages : List Stage) → (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (trace : InitialCopiedDecodeChain.Trace stages cache input angle source storage) →
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) → zero.bytes=source.bytes →
    InitialCopiedDecodeChain.Safe stages cache input angle source storage trace zero.base 2 →
    BoundaryInputs stages cache input angle source storage trace →
    NativeCopiedConstructedInputs.Initial.BoundaryInputs stages cache input angle source storage trace
  | [],_,_,_,_,_,_,_,_,_,_ => PUnit.unit
  | kind::rest,cache,input,angle,source,storage,trace,zero,shared,safe,boundary =>
    let nextZero := ArrayFrame.bf zero trace.1.first.buffer.bytes
      (fun offset bound => (trace.1.first.other_region safe.1 offset bound).trans (congrFun shared _).symm)
    ⟨stageBoundary kind cache.1 input angle source storage.1 trace.1.first zero shared safe.1 boundary.1,
      fill rest cache.2 (forward kind cache.1 input angle) angle trace.1.first.buffer trace.1.nextStorage trace.2
        nextZero rfl safe.2 boundary.2⟩

variable {all stages : List Stage} (position : DecodeParameterConstruction.Cursor all stages)
  (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : ResidualDeltaHighWater.Frontier)
  (capacity : frontier.cursor+InitialCopiedWorkspace.bytes stages≤2^64)
  (sourceBound : ResidualDeltaHighWater.Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (ResidualDeltaHighWater.Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (ResidualDeltaHighWater.Before frontier.cursor) stages cache source.bytes storage)
  (canonical : EmptyKvLineage.Canonical stages cache source.bytes storage)
  (dispatch : InitialCopiedHighWaterConstruction.Dispatches stages)

abbrev result := InitialCopiedHighWaterConstruction.build stages position cache input angle source storage parameters frontier
  capacity sourceBound parametersBound cachesBound canonical dispatch

abbrev trace := InitialCopiedParameterConstruction.chain stages position cache input angle source storage parameters
  (result position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound canonical dispatch).plan

def inputs (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
    (shared : zero.bytes=source.bytes) (below : zero.base+2≤frontier.cursor)
    (boundary : BoundaryInputs stages cache input angle source storage
      (trace position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound canonical dispatch)) :
    NativeCopiedConstructedInputs.Initial.BoundaryInputs stages cache input angle source storage
      (trace position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound canonical dispatch) :=
  fill stages cache input angle source storage _ zero shared
    ((result position cache input angle source storage parameters frontier capacity sourceBound parametersBound cachesBound canonical dispatch).safeBefore zero.base 2 below) boundary

theorem inputs_nil {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
    {storage : DecodeFrame.Storage [] () source.bytes}
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) (shared : zero.bytes=source.bytes) :
    fill [] () input angle source storage PUnit.unit zero shared trivial PUnit.unit=PUnit.unit := rfl

end Inference.Models.Qwen.InitialCopiedScalarBoundary
