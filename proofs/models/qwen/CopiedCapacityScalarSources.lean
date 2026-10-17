import models.qwen.CopiedCapacityGrowthBounds
import models.qwen.NativeCopiedConstructedInputs

namespace Inference.Models.Qwen.CopiedCapacityScalarSources
open Contracts.Mlx Layers DecodeStage DecodeChain State Kernels.Attention Kernels.Copy Kernels.Normalization
set_option maxRecDepth 10000
attribute [local irreducible] AttentionGateCopyFreshRead.Read.input AttentionGateCopyFreshRead.Read.kv
  AttentionGateCopyCapacityResidualStage.block

structure AttentionBoundary {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {input : Row BF} {angle : RopeAngles.Inputs} (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle) where
  trellis : TrellisParsedNative.Input (AttentionGateCopyCapacityResidualStage.block plan).suffix
  before : Nat → Float32
  kernel : MlxRmsHostSelection.KernelLimit
  nativeThreads : layer.inputNorm.platform.groups*32=kernel.threads
  scratch : M1Max.WordMemory
  inverseBefore : M1Max.WordMemory
  base : Nat
  inverseBase : Nat

private def preparedInputs {layer : Attention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n}
    {values : Fin 5120 → ArrayStorage.BF} {angle : RopeAngles.Inputs}
    (s : AttentionGateCopyReadConstruction.Input layer cache values angle)
    (preparation : AttentionBlockMemory.Preparation s.oldAfter)
    (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues) (shared : zero.bytes=s.oldAfter.memory)
    (safe : preparation.Safe zero.base 2) (bounded : CopiedCapacityGrowthBounds.Bounded s.oldAfter preparation) :
    AttentionGateCopyPositiveSources.Inputs (s:=s) preparation := by
  cases preparation with
  | existing _ => exact PUnit.unit
  | growth allocation =>
    exact {
      key := zero
      value := zero
      keyShared := shared
      valueShared := shared
      keyAllocation := {
        sourceAligned := zero.aligned
        sourceBounded := by simpa using zero.bounded
        destinationAligned := by omega
        destinationBounded := bounded.1
        fresh := safe.1 }
      keyZeroKeepsValue := safe.1
      keyCopyKeepsValue := safe.2.1
      valueFresh := safe.2.2.1
      valueZeroBound := bounded.2 }

namespace Attention
variable {layer : ResidualAttention.Layer} {n : Nat} {cache : Kv.Cache Kv.BF n} {input : Row BF} {angle : RopeAngles.Inputs}
  (plan : AttentionGateCopyCapacityResidualStage.Plan layer cache input angle)
  (zero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues)
  (shared : zero.bytes=plan.input.lhs.bytes)
  (safe : AttentionGateCopyCapacityResidualStage.Safe plan zero.base 2)
  (bounded : CopiedCapacityGrowthBounds.Bounded plan.front.oldAfter plan.preparation.preparation)

private def currentZero : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf zero plan.front.oldAfter.memory (fun offset bound =>
    (AttentionGateCopyPreservation.frame plan.front.front.rope safe.2.1.1 offset bound).trans
      ((congrFun (AttentionGateCopyCapacityTrellisEntry.shared (layer:=layer) plan.normal plan.linked).symm _).trans
        ((plan.normal.other_region safe.1 offset bound).trans (congrFun shared _).symm)))

def boundary (native : AttentionBoundary plan) : NativeCopiedConstructedInputs.Capacity.AttentionBoundary plan where
  trellis := native.trellis
  before := native.before
  kernel := native.kernel
  nativeThreads := native.nativeThreads
  scratch := native.scratch
  inverseBefore := native.inverseBefore
  base := native.base
  inverseBase := native.inverseBase
  growth := preparedInputs plan.front plan.preparation.preparation (currentZero plan zero shared safe) rfl
    safe.2.1.2.1 bounded

theorem current_base : (currentZero plan zero shared safe).base=zero.base := rfl
end Attention
end Inference.Models.Qwen.CopiedCapacityScalarSources
