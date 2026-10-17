import kernels.copy.ScalarCopySourceRefinement
import models.qwen.TokenInitializationAllocation

namespace Inference.Models.Qwen.InitialHistorySource
open Contracts.Mlx Kernels.Copy ScalarCopySemantics ScalarCopyBodySemantics
set_option maxRecDepth 100000
attribute [local irreducible] List.finRange ScalarCopySemantics.run

-- The scalar is an actual attached buffer on the initial shared heap. Creating
-- that scalar, selecting BF16 -> BF16/N=1 and the exact 30720-thread dispatch,
-- source-file/header binding, compiler and hardware execution remain boundaries.
-- Launch uses the checked whole-thread-body schedule. The final adapter also
-- consumes the separate selected load/store event model, not a general Metal
-- concurrency or compiler-lowering semantics.
theorem allocation (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.historyBase 61440 scalar.base 2) :
    Allocation scalar.base layout.historyBase where
  sourceAligned := scalar.aligned
  sourceBounded := by simpa using scalar.bounded
  destinationAligned := layout.historyAligned
  destinationBounded := layout.historyBound
  fresh := fresh

private theorem zero_bits : ArrayStorage.bits (InitialStorage.historyZero 0)=0 := by decide +kernel

theorem scalar_read (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero) :
    HalfMemory.load scalar.bytes scalar.base=ArrayStorage.bits (InitialStorage.historyZero 0) := by
  simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] using scalar.attached (0 : Fin 1)

variable (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.historyBase 61440 scalar.base 2)
    {threads : List (Fin count)} {after : HalfMemory.Bytes}
    (execution : Launch scalar.base layout.historyBase threads scalar.bytes after)
    (completed : threads.Perm (List.finRange count))

include scalar layout fresh execution completed in
theorem history_read (i : Fin 30720) :
    HalfMemory.load after (layout.historyBase+2*i.val)=ArrayStorage.bits (InitialStorage.historyZero 0) :=
  (execution_read (allocation scalar layout fresh) execution completed i).trans (scalar_read scalar)

include scalar layout fresh execution completed in
theorem history_byte (offset : Nat) (bound : offset<61440) :
    after (layout.historyBase+offset)=0 := by
  let i : Fin 30720 := ⟨offset/2,by omega⟩
  have read := congrArg (fun word => HalfMemory.byte word (offset%2)) (history_read scalar layout fresh execution completed i)
  rw [HalfMemory.byte_load _ _ _ (by omega)] at read
  have address : layout.historyBase+2*i.val+offset%2=layout.historyBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [zero_bits,HalfMemory.byte] using read

include scalar layout fresh execution in
theorem other_region (separate : MemoryRegions.Disjoint layout.historyBase 61440 other size)
    (offset : Nat) (bound : offset<size) : after (other+offset)=scalar.bytes (other+offset) :=
  execution_frame (allocation scalar layout fresh) execution separate offset bound

-- This is the exact history attachment consumed by the Delta cache modules;
-- it is derived from the launch and initial scalar, not supplied as a buffer.
def history : State.ConvolutionStorage.Storage InitialState.delta.history where
  bytes := after
  base := layout.historyBase
  aligned := layout.historyAligned
  bounded := layout.historyBound
  attached := by
    intro i
    simpa only [State.ConvolutionStorage.flatten,InitialState.delta,InitialStorage.historyZero] using
      history_read scalar layout fresh execution completed i

def scalarAfter : ArrayStorage.BFBuffer InitialStorage.historyZero :=
  ArrayFrame.bf scalar after (by
    simpa using other_region scalar layout fresh execution fresh)

theorem history_bytes : (history scalar layout fresh execution completed).bytes=after := rfl
theorem history_base : (history scalar layout fresh execution completed).base=layout.historyBase := rfl

include scalar layout fresh execution in
theorem scalar_retained : HalfMemory.load after scalar.base=HalfMemory.load scalar.bytes scalar.base :=
  execution_scalar_retained (allocation scalar layout fresh) execution

-- Old initialization traces already prove the same concrete zero stores, with
-- arbitrary legal completed schedules. Equality below identifies their history
-- fragment with the actual source-backed launch on this SAME initial heap.
private theorem modeled_history_byte (trace : InitialStorage.DeltaTrace)
    (layout : InitialStorageRegions.Layout) (before : HalfMemory.Bytes)
    (offset : Nat) (bound : offset<61440) :
    InitialStorageRegions.afterHistory trace layout before (layout.historyBase+offset)=0 := by
  let i : Fin 30720 := ⟨offset/2,by omega⟩
  have read := congrArg (fun word => HalfMemory.byte word (offset%2))
    (InitialStorageRegions.after_history_read trace layout before i)
  rw [HalfMemory.byte_load _ _ _ (by omega)] at read
  have address : layout.historyBase+2*i.val+offset%2=layout.historyBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [zero_bits,HalfMemory.byte] using read

include scalar layout fresh execution completed in
theorem afterHistory_eq (trace : InitialStorage.DeltaTrace) :
    after=InitialStorageRegions.afterHistory trace layout scalar.bytes := by
  funext address
  by_cases inside : layout.historyBase≤address ∧ address<layout.historyBase+61440
  · have bound : address-layout.historyBase<61440 := by omega
    have same : layout.historyBase+(address-layout.historyBase)=address := by omega
    have actual := history_byte scalar layout fresh execution completed _ bound
    have modeled := modeled_history_byte trace layout scalar.bytes _ bound
    rw [same] at actual modeled
    exact actual.trans modeled.symm
  · have separate : MemoryRegions.Disjoint layout.historyBase 61440 address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have actual := other_region scalar layout fresh execution separate 0 (by omega)
    have modeled := MemoryRegions.execute16_other _ scalar.bytes
      (InitialStorageRegions.shifted_history_inside trace layout) separate 0 (by omega)
    simpa only [Nat.add_zero,InitialStorageRegions.afterHistory,MemoryRegions.view] using actual.trans modeled.symm

-- Only the history launch has been source-refined here. Recurrent initialization
-- remains the existing modeled FP32 copy schedule, deliberately exposed below.
def recurrentSuffix (trace : InitialStorage.DeltaTrace) : HalfMemory.Bytes :=
  ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) after

include scalar layout fresh execution completed in
theorem initializer_memory_eq (trace : InitialStorage.DeltaTrace) :
    recurrentSuffix layout (after:=after) trace=InitialStorageRegions.memory trace layout scalar.bytes :=
  congrArg (ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout))
    (afterHistory_eq scalar layout fresh execution completed trace)

include scalar layout fresh execution completed in
theorem stageMemory_eq (layer : ResidualDelta.Layer) (trace : InitialStorage.DeltaTrace) :
    InitialCacheMemory.stageMemory (.delta layer) ⟨trace,layout⟩ scalar.bytes=
      recurrentSuffix layout (after:=after) trace :=
  (initializer_memory_eq scalar layout fresh execution completed trace).symm

include scalar layout fresh execution completed in
theorem ready (trace : InitialStorage.DeltaTrace) :
    InitialCacheMemory.DeltaReady layout (recurrentSuffix layout (after:=after) trace) := by
  rw [initializer_memory_eq scalar layout fresh execution completed trace]
  exact ⟨InitialStorageZeros.history_byte trace layout scalar.bytes,
    InitialStorageZeros.recurrent_byte trace layout scalar.bytes⟩

def storage (trace : InitialStorage.DeltaTrace) : DeltaDevice.Storage InitialState.delta :=
  InitialCacheMemory.deltaStorage layout (recurrentSuffix layout (after:=after) trace)
    (ready scalar layout fresh execution completed trace)

theorem storage_history_bytes (trace : InitialStorage.DeltaTrace) :
    (storage scalar layout fresh execution completed trace).history.bytes=recurrentSuffix layout (after:=after) trace := rfl

theorem storage_recurrent_bytes (trace : InitialStorage.DeltaTrace) :
    (storage scalar layout fresh execution completed trace).recurrent.bytes=recurrentSuffix layout (after:=after) trace := rfl

-- The first Delta slot of the unchanged concrete arena allocator is an
-- immediate instance. No scalar slot or postexecution attachment is fabricated.
include scalar layout fresh execution completed in
theorem workspace_head (layer : ResidualDelta.Layer) (rest : List DecodeStage.Stage)
    (w : TokenInitializationAllocation.Workspace (.delta layer::rest))
    (sameLayout : layout=w.caches.1.layout) :
    after=InitialStorageRegions.afterHistory w.caches.1.trace w.caches.1.layout scalar.bytes := by
  rw [← sameLayout]
  exact afterHistory_eq scalar layout fresh execution completed _

-- Whole-arena freshness supplies the source separation of the first Delta
-- history region; no independent history-layout equality is requested.
theorem workspaceHeadFresh (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layer : ResidualDelta.Layer) (rest : List DecodeStage.Stage)
    (w : TokenInitializationAllocation.Workspace (.delta layer::rest))
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes (.delta layer::rest)) scalar.base 2) :
    MemoryRegions.Disjoint w.caches.1.layout.historyBase 61440 scalar.base 2 :=
  (w.cache_safe outside).1.1

theorem workspaceHead_afterHistory (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layer : ResidualDelta.Layer) (rest : List DecodeStage.Stage)
    (w : TokenInitializationAllocation.Workspace (.delta layer::rest))
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes (.delta layer::rest)) scalar.base 2)
    {threads : List (Fin count)} {after : HalfMemory.Bytes}
    (execution : Launch scalar.base w.caches.1.layout.historyBase threads scalar.bytes after)
    (completed : threads.Perm (List.finRange count)) :
    after=InitialStorageRegions.afterHistory w.caches.1.trace w.caches.1.layout scalar.bytes :=
  afterHistory_eq scalar w.caches.1.layout (workspaceHeadFresh scalar layer rest w outside) execution completed _

-- The old token plan writes the token before initializing caches. Reframe the
-- ACTUAL scalar through that write, deriving its attachment on the launch heap.
-- No additional scalar allocation is hidden inside TokenInitializationAllocation.
section Token
variable {p : TokenInference.Pipeline} {token : Fin 248320}

theorem tokenFresh (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) scalar.base 2) :
    MemoryRegions.Disjoint w.base 4 scalar.base 2 := by
  unfold MemoryRegions.Disjoint at *
  dsimp [TokenInitializationAllocation.bytes] at outside
  omega

def scalarAfterToken (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) scalar.base 2) :
    ArrayStorage.BFBuffer InitialStorage.historyZero :=
  let plan := w.plan (token:=token) (initialHeap:=scalar.bytes)
  ArrayFrame.bf_after32 scalar plan.tokenWrite.schedule (ArrayFrame.word_stores_inside plan.tokenWrite)
    (tokenFresh scalar w outside)

theorem scalarAfterToken_bytes (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) scalar.base 2) :
    (scalarAfterToken (token:=token) scalar w outside).bytes=
      (w.plan (token:=token) (initialHeap:=scalar.bytes)).tokenWrite.memory := rfl

theorem scalarAfterToken_base (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (outside : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) scalar.base 2) :
    (scalarAfterToken (token:=token) scalar w outside).base=scalar.base := rfl

end Token

include scalar layout fresh execution in
theorem recurrentSuffix_frame (trace : InitialStorage.DeltaTrace)
    (historySeparate : MemoryRegions.Disjoint layout.historyBase 61440 other size)
    (recurrentSeparate : MemoryRegions.Disjoint layout.recurrentBase 3145728 other size)
    (offset : Nat) (bound : offset<size) :
    recurrentSuffix layout (after:=after) trace (other+offset)=scalar.bytes (other+offset) :=
  (MemoryRegions.execute32_other _ after
    (InitialStorageRegions.shifted_recurrent_inside trace layout) recurrentSeparate offset bound).trans
    (other_region scalar layout fresh execution historySeparate offset bound)

-- Substitution through all later cache initialization writes is exact function
-- equality, so existing readiness/first-token cache proofs consume this heap.
theorem cacheTail_eq (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layer : ResidualDelta.Layer) (rest : List DecodeStage.Stage)
    (plan : InitialCacheMemory.Plan (.delta layer::rest))
    (fresh : MemoryRegions.Disjoint plan.1.layout.historyBase 61440 scalar.base 2)
    {threads : List (Fin count)} {after : HalfMemory.Bytes}
    (execution : Launch scalar.base plan.1.layout.historyBase threads scalar.bytes after)
    (completed : threads.Perm (List.finRange count)) :
    InitialCacheMemory.execute (.delta layer::rest) plan scalar.bytes=
      InitialCacheMemory.execute rest plan.2
        (recurrentSuffix plan.1.layout (after:=after) plan.1.trace) :=
  congrArg (InitialCacheMemory.execute rest plan.2)
    (stageMemory_eq scalar plan.1.layout fresh execution completed layer plan.1.trace)

def canonicalAfter (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout) : HalfMemory.Bytes :=
  ScalarCopySemantics.run scalar.base layout.historyBase (List.finRange count) scalar.bytes

theorem canonical_execution (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout) :
    Launch scalar.base layout.historyBase (List.finRange count) scalar.bytes (canonicalAfter scalar layout) :=
  launch_refines scalar.base layout.historyBase layout.historyAligned _ _

theorem canonical_afterHistory_eq (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.historyBase 61440 scalar.base 2) (trace : InitialStorage.DeltaTrace) :
    canonicalAfter scalar layout=InitialStorageRegions.afterHistory trace layout scalar.bytes :=
  afterHistory_eq scalar layout fresh (canonical_execution scalar layout) (List.Perm.refl _) trace

-- The separate-action model admits arbitrary valid load/store interleavings.
-- Its actual event execution is joined to a constructed full parsed-body launch;
-- no caller supplies a matching output heap or an agreement premise.
theorem interleaving_afterHistory_eq
    (scalar : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.historyBase 61440 scalar.base 2)
    {events : List ScalarCopyInterleaving.Event} {after : ScalarCopyInterleaving.Machine}
    (execution : ScalarCopyInterleaving.Executes scalar.base layout.historyBase
      (ScalarCopyInterleaving.initial scalar.bytes) events after)
    (completed : ScalarCopyInterleaving.Completed after) (trace : InitialStorage.DeltaTrace) :
    after.memory=InitialStorageRegions.afterHistory trace layout scalar.bytes :=
  (ScalarCopySourceRefinement.joined (allocation scalar layout fresh)
    (canonical_execution scalar layout) (List.Perm.refl _) execution completed).same_heap.symm.trans
      (canonical_afterHistory_eq scalar layout fresh trace)

end Inference.Models.Qwen.InitialHistorySource
