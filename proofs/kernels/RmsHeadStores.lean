import kernels.RmsHeadReads
import contracts.mlx.MultiOutputWrites

namespace Inference.Kernels.RmsHeadStores
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] MultiOutputWrites.programs ReadBeforeOverwrite.allReaders ReadBeforeOverwrite.captureMany

structure Geometry (heads base : Nat) where
  aligned : base%2=0
  bounded : base+512*heads ≤ 2^64

def Geometry.layout (geometry : Geometry heads base) (values : Fin heads → Fin 256 → ArrayStorage.BF) :
    MultiOutputWrites.Layout heads where
  output head := ⟨64, (RmsHeadReads.layout heads base).base head, fun i => ArrayStorage.bits (values head i)⟩
  aligned head := by dsimp [RmsHeadReads.layout]; have := geometry.aligned; omega
  bounded head := by dsimp [RmsHeadReads.layout]; have := geometry.bounded; have := head.isLt; omega
  separate := (RmsHeadReads.layout heads base).separate

variable {heads base : Nat} {geometry : Geometry heads base} {values : Fin heads → Fin 256 → ArrayStorage.BF}

abbrev Trace (geometry : Geometry heads base) (values : Fin heads → Fin 256 → ArrayStorage.BF) :=
  MultiOutputWrites.Trace (geometry.layout values)

theorem store_coordinate (trace : Trace geometry values) (store : HalfMemory.Store) (present : store ∈ trace.schedule) :
    ∃ head : Fin heads, ∃ i : Fin 256, store.word=base/2+head.val*256+i.val := by
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp present
  obtain ⟨head, member⟩ := MultiOutputWrites.member (geometry.layout values) store original
  obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member _ _ store member
  refine ⟨head, CopyContiguous.index thread offset, ?_⟩
  have := geometry.aligned
  dsimp only [CopyContiguous.entry, Geometry.layout, RmsHeadReads.layout]
  omega

def owner (trace : Trace geometry values) (store : HalfMemory.Store) (present : store ∈ trace.schedule) : Fin heads :=
  ⟨(store.word-base/2)/256, by
    obtain ⟨head, i, address⟩ := store_coordinate trace store present
    have := head.isLt
    have := i.isLt
    omega⟩

theorem store_inside_head (trace : Trace geometry values) (store : HalfMemory.Store) (present : store ∈ trace.schedule) :
    (RmsHeadReads.layout heads base).base (owner trace store present) ≤ 2*store.word ∧
      2*store.word+2 ≤ (RmsHeadReads.layout heads base).base (owner trace store present)+512 := by
  obtain ⟨head, i, address⟩ := store_coordinate trace store present
  have := i.isLt
  have := geometry.aligned
  dsimp only [RmsHeadReads.layout, owner]
  omega

def ownedStores (trace : Trace geometry values) : List (Fin heads × HalfMemory.Store) :=
  trace.schedule.attach.map (fun store => (owner trace store.val store.property, store.val))

theorem owned_inside (trace : Trace geometry values) :
    ∀ entry ∈ ownedStores trace, (RmsHeadReads.layout heads base).base entry.1 ≤ 2*entry.2.word ∧
      2*entry.2.word+2 ≤ (RmsHeadReads.layout heads base).base entry.1+512 := by
  intro entry member
  obtain ⟨store, _, rfl⟩ := List.mem_map.mp member
  exact store_inside_head trace store.val store.property

theorem owned_projection (trace : Trace geometry values) : (ownedStores trace).map Prod.snd=trace.schedule := by
  simp [ownedStores]

-- Canonical completion captures all rows first. Other legal read traces
-- can interleave independent heads while sharing this same store schedule.
def readTrace (trace : Trace geometry values) : RmsHeadReads.Trace heads base :=
  let readers := (ReadBeforeOverwrite.allReaders heads 64).map (fun reader => ReadBeforeOverwrite.Event.capture reader.1 reader.2)
  let captured := ReadBeforeOverwrite.captureMany (RmsHeadReads.read base)
    (ReadBeforeOverwrite.allReaders heads 64) (ReadBeforeOverwrite.initial trace.before)
  { before := trace.before
    events := readers++(ownedStores trace).map (fun entry => .write entry.1 entry.2)
    after := ReadBeforeOverwrite.writeMany (ownedStores trace) captured
    execution := ReadBeforeOverwrite.append_execution ReadBeforeOverwrite.canonical
      (ReadBeforeOverwrite.writeMany_valid _ _ ReadBeforeOverwrite.canonical_ready (owned_inside trace))
    ready := ReadBeforeOverwrite.writeMany_ready _ _ ReadBeforeOverwrite.canonical_ready }

theorem readTrace_stores (trace : Trace geometry values) :
    (readTrace trace).events.filterMap ReadBeforeOverwrite.storeProjection=trace.schedule := by
  change (((ReadBeforeOverwrite.allReaders heads 64).map (fun reader : Fin heads × Fin 64 => ReadBeforeOverwrite.Event.capture reader.1 reader.2))++
    (ownedStores trace).map (fun entry : Fin heads × HalfMemory.Store => ReadBeforeOverwrite.Event.write entry.1 entry.2)).filterMap ReadBeforeOverwrite.storeProjection=_
  simp only [List.filterMap_append, List.filterMap_map, Function.comp_def, ReadBeforeOverwrite.storeProjection,
    List.filterMap_none, List.nil_append]
  rw [← owned_projection trace]
  generalize ownedStores trace=stores
  induction stores with
  | nil => rfl
  | cons entry rest ih => exact congrArg (List.cons entry.2) ih

theorem readTrace_memory (trace : Trace geometry values) : (readTrace trace).after.memory=trace.memory := by
  rw [RmsHeadReads.Trace.memory, readTrace_stores]
  rfl

def buffer (trace : Trace geometry values) (head : Fin heads) : ArrayStorage.BFBuffer (values head) where
  bytes := trace.memory
  base := (RmsHeadReads.layout heads base).base head
  aligned := (geometry.layout values).aligned head
  bounded := (geometry.layout values).bounded head
  attached i := trace.read_correct head i

theorem other_region (trace : Trace geometry values) {region size : Nat}
    (separate : MemoryRegions.Disjoint base (512*heads) region size) (offset : Nat) (bound : offset<size) :
    trace.memory (region+offset)=trace.before (region+offset) :=
  trace.other_region (RmsHeadReads.group_separate separate) offset bound

end Inference.Kernels.RmsHeadStores
