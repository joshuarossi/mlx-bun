import state.KvInitialPairMemory
import kernels.copy.ScalarCopyQuadSourceRefinement

namespace Inference.Models.Qwen.InitialKvSourceMemory
open Contracts.Mlx State Kernels.Copy
open KvSlicePreparationMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs

variable {layout : KvRegions.Layout 1} {before : ByteMemory.Bytes}

-- Two actual BF16 zero scalar inputs on the incoming heap. The second
-- scalar is transported through K initialization rather than supplied again.
structure Sources (zeros : KvInitialPairMemory.ZeroPair layout before) where
  keyScalar : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  valueScalar : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  keyShared : keyScalar.bytes=before
  valueShared : valueScalar.bytes=before
  keyAllocation : ScalarCopyQuadSemantics.Allocation keyScalar.base layout.keyBase
  keyKeepsValue : MemoryRegions.Disjoint layout.keyBase bytes valueScalar.base 2
  valueFresh : MemoryRegions.Disjoint layout.valueBase bytes valueScalar.base 2

variable {zeros : KvInitialPairMemory.ZeroPair layout before} (sources : Sources zeros)

def Sources.valueAfter : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf sources.valueScalar zeros.keys.memory (fun offset bound =>
    (KvSlicePreparationMemory.trace_frame zeros.keys sources.keyKeepsValue offset bound).trans
      ((congrFun zeros.initial _).trans (congrFun sources.valueShared _).symm))

theorem Sources.valueAllocation : ScalarCopyQuadSemantics.Allocation sources.valueAfter.base layout.valueBase where
  sourceAligned := sources.valueAfter.aligned
  sourceBounded := sources.valueAfter.bounded
  destinationAligned := layout.valueAligned
  destinationBounded := layout.valueBound
  fresh := sources.valueFresh

def Sources.keyChecked : ScalarCopyQuadSourceRefinement.Checked sources.keyScalar layout.keyBase sources.keyAllocation :=
  ScalarCopyQuadSourceRefinement.canonical sources.keyScalar layout.keyBase sources.keyAllocation

def Sources.valueChecked : ScalarCopyQuadSourceRefinement.Checked sources.valueAfter layout.valueBase sources.valueAllocation :=
  ScalarCopyQuadSourceRefinement.canonical sources.valueAfter layout.valueBase sources.valueAllocation

theorem Sources.key_events_heap : sources.keyChecked.eventAfter.memory=zeros.keys.memory :=
  ScalarCopyQuadSourceRefinement.events_zero_eq sources.keyAllocation sources.keyChecked.eventExecution sources.keyChecked.eventCompleted
    (ScalarCopyQuadSourceRefinement.scalar_zero sources.keyScalar) zeros.keys (zeros.initial.trans sources.keyShared.symm)

theorem Sources.value_events_heap : sources.valueChecked.eventAfter.memory=zeros.memory :=
  ScalarCopyQuadSourceRefinement.events_zero_eq sources.valueAllocation sources.valueChecked.eventExecution sources.valueChecked.eventCompleted
    (ScalarCopyQuadSourceRefinement.scalar_zero sources.valueAfter) zeros.values zeros.linked

theorem Sources.value_starts_key_heap : sources.valueAfter.bytes=sources.keyChecked.eventAfter.memory := sources.key_events_heap.symm

theorem Sources.key_body_heap : sources.keyChecked.bodyAfter=zeros.keys.memory :=
  sources.keyChecked.agreement.same_heap.trans sources.key_events_heap

theorem Sources.value_body_heap : sources.valueChecked.bodyAfter=zeros.memory :=
  sources.valueChecked.agreement.same_heap.trans sources.value_events_heap

end Inference.Models.Qwen.InitialKvSourceMemory
