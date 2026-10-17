import kernels.copy.ScalarCopyFloatSourceRefinement
import models.qwen.InitialHistorySource

namespace Inference.Models.Qwen.InitialRecurrentSource
-- Selected FP32/N=2 parsed-body and word-atomic event models. Native source
-- binding, host scalar upload/allocation, compiler and hardware remain boundaries.
open Contracts.Mlx Kernels.Copy
set_option maxRecDepth 100000
attribute [local irreducible] List.finRange ScalarCopyFloatSemantics.run

theorem allocation (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4) :
    ScalarCopyFloatSemantics.Allocation source.base layout.recurrentBase where
  sourceAligned := source.aligned
  sourceBounded := by simpa using source.bounded
  destinationAligned := layout.recurrentAligned
  destinationBounded := layout.recurrentBound
  fresh := fresh

private theorem zero_word : FloatMemory.bits (0 : Float32)=0 := by decide +kernel

-- Old recurrent schedules re-encode their decoded scalar value. For this zero
-- specialization that value is exactly0; no arbitrary raw/NaN identity is used.
private theorem modeled_read (trace : InitialStorage.DeltaTrace)
    (layout : InitialStorageRegions.Layout) (before : ByteMemory.Bytes) (i : Fin 786432) :
    ByteMemory.load32 (ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) before)
      (layout.recurrentBase+4*i.val)=0 := by
  rw [← MemoryRegions.load32_view]
  unfold InitialStorageRegions.recurrentStores
  rw [MemoryRegions.execute32_view _ _ _ layout.recurrentAligned]
  let changed : CopyFloatContiguous.Trace 0 (fun _ : Fin (2*393216) =>
      FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base) :=
    {trace.recurrent with before := MemoryRegions.view before layout.recurrentBase}
  have read := changed.raw_read i
  have source := trace.recurrentScalar.attached (0 : Fin 1)
  have scalarZero : FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base=0 := by
    simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,InitialStorage.recurrentZero] using source
  simpa only [Nat.zero_add,changed,CopyFloatContiguous.Trace.memory] using
    read.trans ((congrArg FloatMemory.bits scalarZero).trans zero_word)

private theorem modeled_byte (trace : InitialStorage.DeltaTrace)
    (layout : InitialStorageRegions.Layout) (before : ByteMemory.Bytes) (offset : Nat) (bound : offset<3145728) :
    ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) before (layout.recurrentBase+offset)=0 := by
  let i : Fin 786432 := ⟨offset/4,by omega⟩
  have read := congrArg (fun word => ByteMemory.byte word (offset%4)) (modeled_read trace layout before i)
  rw [ByteMemory.byte_load32 _ _ _ (by omega)] at read
  have address : layout.recurrentBase+4*i.val+offset%4=layout.recurrentBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [ByteMemory.byte] using read

variable (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4)
    (raw : ByteMemory.load32 source.bytes source.base=0)
    {threads : List (Fin ScalarCopyFloatSemantics.threadCount)} {after : ByteMemory.Bytes}
    (execution : ScalarCopyFloatBodySemantics.Launch source.base layout.recurrentBase threads source.bytes after)
    (completed : threads.Perm (List.finRange ScalarCopyFloatSemantics.threadCount))

include source layout fresh raw execution completed in
theorem raw_read (i : Fin 786432) : ByteMemory.load32 after (layout.recurrentBase+4*i.val)=0 :=
  (ScalarCopyFloatBodySemantics.execution_raw_read (allocation source layout fresh) execution completed i).trans raw

include source layout fresh raw execution completed in
theorem byte_read (offset : Nat) (bound : offset<3145728) : after (layout.recurrentBase+offset)=0 := by
  let i : Fin 786432 := ⟨offset/4,by omega⟩
  have read := congrArg (fun word => ByteMemory.byte word (offset%4)) (raw_read source layout fresh raw execution completed i)
  rw [ByteMemory.byte_load32 _ _ _ (by omega)] at read
  have address : layout.recurrentBase+4*i.val+offset%4=layout.recurrentBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [ByteMemory.byte] using read

include source layout fresh execution in
theorem other_region (separate : MemoryRegions.Disjoint layout.recurrentBase 3145728 other size)
    (offset : Nat) (bound : offset<size) : after (other+offset)=source.bytes (other+offset) :=
  ScalarCopyFloatBodySemantics.execution_frame (allocation source layout fresh) execution separate offset bound

include source layout fresh raw execution completed in
theorem afterRecurrent_eq (trace : InitialStorage.DeltaTrace) :
    after=ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) source.bytes := by
  funext address
  by_cases inside : layout.recurrentBase≤address ∧ address<layout.recurrentBase+3145728
  · have bound : address-layout.recurrentBase<3145728 := by omega
    have same : layout.recurrentBase+(address-layout.recurrentBase)=address := by omega
    have actual := byte_read source layout fresh raw execution completed _ bound
    have modeled := modeled_byte trace layout source.bytes _ bound
    rw [same] at actual modeled
    exact actual.trans modeled.symm
  · have separate : MemoryRegions.Disjoint layout.recurrentBase 3145728 address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have actual := other_region source layout fresh execution separate 0 (by omega)
    have modeled := MemoryRegions.execute32_other _ source.bytes
      (InitialStorageRegions.shifted_recurrent_inside trace layout) separate 0 (by omega)
    simpa only [Nat.add_zero,MemoryRegions.view] using actual.trans modeled.symm

def canonicalAfter (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout) : ByteMemory.Bytes :=
  ScalarCopyFloatSemantics.run source.base layout.recurrentBase
    (ScalarCopyFloatSemantics.indices (List.finRange ScalarCopyFloatSemantics.threadCount)) source.bytes

theorem canonical_execution (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout) :
    ScalarCopyFloatBodySemantics.Launch source.base layout.recurrentBase (List.finRange ScalarCopyFloatSemantics.threadCount)
      source.bytes (canonicalAfter source layout) :=
  ScalarCopyFloatBodySemantics.launch_refines _ _ layout.recurrentAligned _ _

theorem canonical_afterRecurrent_eq (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4)
    (raw : ByteMemory.load32 source.bytes source.base=0) (trace : InitialStorage.DeltaTrace) :
    canonicalAfter source layout=ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) source.bytes :=
  afterRecurrent_eq source layout fresh raw (canonical_execution source layout) (List.Perm.refl _) trace

-- Separate load/store schedules retain the per-thread N=2 loop order. Their
-- final heap is linked to the constructed full parsed-body launch, not supplied.
structure Checked (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4)
    (raw : ByteMemory.load32 source.bytes source.base=0) : Prop where
  source_raw : ByteMemory.load32 source.bytes source.base=0
  body : ScalarCopyFloatBodySemantics.Launch source.base layout.recurrentBase
    (List.finRange ScalarCopyFloatSemantics.threadCount) source.bytes (canonicalAfter source layout)
  events : ScalarCopyFloatInterleaving.Executes source.base layout.recurrentBase
    (ScalarCopyFloatInterleaving.initial source.bytes)
    ((List.finRange ScalarCopyFloatSemantics.threadCount).flatMap ScalarCopyFloatInterleaving.threadEvents)
    (ScalarCopyFloatInterleaving.canonicalAfter source.base layout.recurrentBase source.bytes)
  completed : ScalarCopyFloatInterleaving.Completed
    (ScalarCopyFloatInterleaving.canonicalAfter source.base layout.recurrentBase source.bytes)
  agreement : ScalarCopyFloatSourceRefinement.Agreement source.base layout.recurrentBase (allocation source layout fresh)
    source.bytes (canonicalAfter source layout)
    (ScalarCopyFloatInterleaving.canonicalAfter source.base layout.recurrentBase source.bytes) 0

theorem checked (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4)
    (raw : ByteMemory.load32 source.bytes source.base=0) : Checked source layout fresh raw where
  source_raw := raw
  body := canonical_execution source layout
  events := ScalarCopyFloatInterleaving.canonical_execution _ _ _
  completed := ScalarCopyFloatInterleaving.canonical_completed _ _ _
  agreement := ScalarCopyFloatSourceRefinement.joined (allocation source layout fresh)
    (canonical_execution source layout) (List.Perm.refl _)
    (ScalarCopyFloatInterleaving.canonical_execution _ _ _)
    (ScalarCopyFloatInterleaving.canonical_completed _ _ _) 0 (raw.trans zero_word.symm)

theorem interleaving_afterRecurrent_eq (source : ArrayStorage.FloatBuffer InitialStorage.recurrentZero)
    (layout : InitialStorageRegions.Layout)
    (fresh : MemoryRegions.Disjoint layout.recurrentBase 3145728 source.base 4)
    (raw : ByteMemory.load32 source.bytes source.base=0)
    {events : List ScalarCopyFloatInterleaving.Event} {after : ScalarCopyFloatInterleaving.Machine}
    (execution : ScalarCopyFloatInterleaving.Executes source.base layout.recurrentBase
      (ScalarCopyFloatInterleaving.initial source.bytes) events after)
    (completed : ScalarCopyFloatInterleaving.Completed after) (trace : InitialStorage.DeltaTrace) :
    after.memory=ByteMemory.execute (InitialStorageRegions.recurrentStores trace layout) source.bytes :=
  (ScalarCopyFloatSourceRefinement.joined (allocation source layout fresh) (canonical_execution source layout)
    (List.Perm.refl _) execution completed 0 (raw.trans zero_word.symm)).same_heap.symm.trans
    (canonical_afterRecurrent_eq source layout fresh raw trace)

end Inference.Models.Qwen.InitialRecurrentSource
