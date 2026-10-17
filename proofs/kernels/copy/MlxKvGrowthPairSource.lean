import kernels.copy.MlxKvZeroSource
import kernels.copy.MlxKvConcatMemory
import kernels.copy.MlxKvConcatHost
import state.KvGrowthPairMemory

namespace Inference.Kernels.Copy.MlxKvGrowthPairSource
open Contracts.Mlx State
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels CopyContiguous.programs Copy2DMemory.programs
  CopyExecution.Trace.memory KvConcatMemory.programs ScalarCopyQuadSourceRefinement.zeroTrace

variable {n : Nat} {cache : Kv.Cache Kv.BF n} (growth : KvGrowthPairMemory.Execution cache)

-- Both zero scalars start on the original preparation heap. The second is
-- preserved through all key work; no new post-key scalar attachment is given.
structure Sources where
  key : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  value : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues
  keyShared : key.bytes=growth.keys.zeros.before
  valueShared : value.bytes=growth.keys.zeros.before
  keyAllocation : ScalarCopyQuadSemantics.Allocation key.base (2*growth.keyLayout.zeroBase)
  keyZeroKeepsValue : MemoryRegions.Disjoint (2*growth.keyLayout.zeroBase) 524288 value.base 2
  keyCopyKeepsValue : MemoryRegions.Disjoint (2*growth.keyLayout.destination) (2*(4*(n+256)*256)) value.base 2
  valueFresh : MemoryRegions.Disjoint (2*growth.valueLayout.zeroBase) 524288 value.base 2
  valueZeroBound : 2*growth.valueLayout.zeroBase+524288≤2^64
  keyOldBound : 2*growth.keyLayout.oldBase+2*(4*n*256)≤2^64
  valueOldBound : 2*growth.valueLayout.oldBase+2*(4*n*256)≤2^64

variable (sources : Sources growth)

def Sources.valueAfter : ArrayStorage.BFBuffer ScalarCopyQuadSourceRefinement.zeroValues :=
  ArrayFrame.bf sources.value growth.values.zeros.before (by
    intro offset bound
    have frame := KvGrowthPairMemory.growth_frame growth.keyLayout growth.keys
      sources.keyZeroKeepsValue sources.keyCopyKeepsValue offset bound
    rw [growth.linked]
    exact frame.trans (congrFun sources.valueShared _).symm)

theorem Sources.valueAllocation : ScalarCopyQuadSemantics.Allocation sources.valueAfter.base (2*growth.valueLayout.zeroBase) where
  sourceAligned := sources.valueAfter.aligned
  sourceBounded := sources.valueAfter.bounded
  destinationAligned := by omega
  destinationBounded := sources.valueZeroBound
  fresh := sources.valueFresh

def keyZero := MlxKvZeroSource.checked sources.key sources.keyAllocation

def valueZero := MlxKvZeroSource.checked sources.valueAfter sources.valueAllocation

theorem key_zero_heap : (keyZero growth sources).eventAfter.memory=growth.keys.zeros.memory :=
  MlxKvZeroSource.event_heap growth.keys sources.key sources.keyShared sources.keyAllocation

theorem value_zero_heap : (valueZero growth sources).eventAfter.memory=growth.values.zeros.memory :=
  MlxKvZeroSource.event_heap growth.values sources.valueAfter rfl sources.valueAllocation

include sources in
theorem keyAllocation (supported : n≤262144) : MlxKvConcatSource.Allocation growth.keyLayout where
  supported := supported
  oldBound := sources.keyOldBound
  zeroBound := sources.keyAllocation.destinationBounded
  destinationBound := growth.keyBound

include sources in
theorem valueAllocation (supported : n≤262144) : MlxKvConcatSource.Allocation growth.valueLayout where
  supported := supported
  oldBound := sources.valueOldBound
  zeroBound := sources.valueZeroBound
  destinationBound := growth.valueBound

def keyOld (supported : n≤262144) :=
  MlxKvConcatMemory.oldChecked growth.keyLayout (keyAllocation growth sources supported) growth.keys.concatenation.before

def keyNew (supported : n≤262144) :=
  MlxKvConcatMemory.newChecked growth.keyLayout (keyAllocation growth sources supported) growth.keys.concatenation.before

def valueOld (supported : n≤262144) :=
  MlxKvConcatMemory.oldChecked growth.valueLayout (valueAllocation growth sources supported) growth.values.concatenation.before

def valueNew (supported : n≤262144) :=
  MlxKvConcatMemory.newChecked growth.valueLayout (valueAllocation growth sources supported) growth.values.concatenation.before

theorem key_starts_zero (supported : n≤262144) :
    GeneralCopy2DWideInterleaving.Executes (width:=n*256) (MlxKvConcatSource.oldLayout growth.keyLayout)
      (GeneralCopy2DWideInterleaving.initial (keyZero growth sources).eventAfter.memory)
      (keyOld growth sources supported).events (keyOld growth sources supported).eventAfter := by
  rw [key_zero_heap]
  rw [←growth.keys.initial]
  exact (keyOld growth sources supported).eventExecution

theorem key_new_heap (supported : n≤262144) :
    (keyNew growth sources supported).eventAfter.memory=growth.keys.concatenation.memory :=
  (MlxKvConcatMemory.new_heap growth.keyLayout (keyAllocation growth sources supported) growth.keys.concatenation).2

theorem value_zero_starts_key (supported : n≤262144) :
    sources.valueAfter.bytes=(keyNew growth sources supported).eventAfter.memory := by
  change growth.values.zeros.before=_
  rw [key_new_heap,growth.linked]

theorem value_starts_zero (supported : n≤262144) :
    GeneralCopy2DWideInterleaving.Executes (width:=n*256) (MlxKvConcatSource.oldLayout growth.valueLayout)
      (GeneralCopy2DWideInterleaving.initial (valueZero growth sources).eventAfter.memory)
      (valueOld growth sources supported).events (valueOld growth sources supported).eventAfter := by
  rw [value_zero_heap]
  rw [←growth.values.initial]
  exact (valueOld growth sources supported).eventExecution

theorem final_heap (supported : n≤262144) :
    (valueNew growth sources supported).bodyAfter=growth.prepared.memory ∧
    (valueNew growth sources supported).eventAfter.memory=growth.prepared.memory :=
  MlxKvConcatMemory.new_heap growth.valueLayout (valueAllocation growth sources supported) growth.values.concatenation

include growth in
theorem native_nonempty_geometry (positive : 0<n) (supported : n≤262144) :
    KvRowDispatchGeometry.grid
      (KvRowDispatchGeometry.collapse (MlxKvConcatHost.axes n n) (2^31-1))=⟨n*256,4,1⟩ ∧
    KvRowDispatchGeometry.grid
      (KvRowDispatchGeometry.collapse (MlxKvConcatHost.axes 256 n) (2^31-1))=⟨65536,4,1⟩ :=
  ⟨(MlxKvConcatHost.old_selected n positive (KvAllocation.no_trim_on_growth n growth.growing) supported).2,
    (MlxKvConcatHost.new_selected n positive).2⟩

structure Certificate (supported : n≤262144) : Prop where
  parser : GeneralCopy2DSyntax.parseBody GeneralCopy2DSyntax.sourceBody=some GeneralCopy2DSyntax.body
  keyZeroCurrent : ScalarCopyQuadInterleaving.Executes sources.key.base (2*growth.keyLayout.zeroBase)
    (ScalarCopyQuadInterleaving.initial growth.keys.zeros.before)
    (keyZero growth sources).events (keyZero growth sources).eventAfter
  keyZeroHeap : (keyZero growth sources).bodyAfter=growth.keys.zeros.memory ∧
    (keyZero growth sources).eventAfter.memory=growth.keys.zeros.memory
  keyOldCurrent : GeneralCopy2DWideInterleaving.Executes (width:=n*256) (MlxKvConcatSource.oldLayout growth.keyLayout)
    (GeneralCopy2DWideInterleaving.initial (keyZero growth sources).eventAfter.memory)
    (keyOld growth sources supported).events (keyOld growth sources supported).eventAfter
  keyNewCurrent : GeneralCopy2DWideInterleaving.Executes (width:=256*256) (MlxKvConcatSource.newLayout growth.keyLayout)
    (GeneralCopy2DWideInterleaving.initial (keyOld growth sources supported).eventAfter.memory)
    (keyNew growth sources supported).events (keyNew growth sources supported).eventAfter
  keyNewHeap : (keyNew growth sources supported).eventAfter.memory=growth.keys.concatenation.memory
  valueZeroCurrent : ScalarCopyQuadInterleaving.Executes sources.valueAfter.base (2*growth.valueLayout.zeroBase)
    (ScalarCopyQuadInterleaving.initial (keyNew growth sources supported).eventAfter.memory)
    (valueZero growth sources).events (valueZero growth sources).eventAfter
  valueZeroHeap : (valueZero growth sources).bodyAfter=growth.values.zeros.memory ∧
    (valueZero growth sources).eventAfter.memory=growth.values.zeros.memory
  valueOldCurrent : GeneralCopy2DWideInterleaving.Executes (width:=n*256) (MlxKvConcatSource.oldLayout growth.valueLayout)
    (GeneralCopy2DWideInterleaving.initial (valueZero growth sources).eventAfter.memory)
    (valueOld growth sources supported).events (valueOld growth sources supported).eventAfter
  valueNewCurrent : GeneralCopy2DWideInterleaving.Executes (width:=256*256) (MlxKvConcatSource.newLayout growth.valueLayout)
    (GeneralCopy2DWideInterleaving.initial (valueOld growth sources supported).eventAfter.memory)
    (valueNew growth sources supported).events (valueNew growth sources supported).eventAfter
  finalHeap : (valueNew growth sources supported).bodyAfter=growth.prepared.memory ∧
    (valueNew growth sources supported).eventAfter.memory=growth.prepared.memory

theorem checked (supported : n≤262144) : Certificate growth sources supported := by
  refine ⟨GeneralCopy2DSyntax.parsed_body,?_,?_,key_starts_zero growth sources supported,
    MlxKvConcatMemory.new_starts growth.keyLayout (keyAllocation growth sources supported) _,
    key_new_heap growth sources supported,?_,?_,value_starts_zero growth sources supported,
    MlxKvConcatMemory.new_starts growth.valueLayout (valueAllocation growth sources supported) _,
    final_heap growth sources supported⟩
  · rw [←sources.keyShared]
    exact (keyZero growth sources).eventExecution
  · exact ⟨MlxKvZeroSource.body_heap growth.keys sources.key sources.keyShared sources.keyAllocation,
      key_zero_heap growth sources⟩
  · rw [←value_zero_starts_key growth sources supported]
    exact (valueZero growth sources).eventExecution
  · exact ⟨MlxKvZeroSource.body_heap growth.values sources.valueAfter rfl sources.valueAllocation,
      value_zero_heap growth sources⟩

end Inference.Kernels.Copy.MlxKvGrowthPairSource
