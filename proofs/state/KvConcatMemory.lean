import state.KvConcat
import contracts.mlx.CopyExecution
import contracts.mlx.CopyContiguous

namespace Inference.State.KvConcatMemory
open Contracts.Mlx

structure Layout (capacity : Nat) where
  oldBase : Nat
  zeroBase : Nat
  destination : Nat
  oldSeparate : MemoryRegions.Disjoint (2*destination) (2*(4*(capacity+256)*256)) (2*oldBase) (2*(4*capacity*256))
  zeroSeparate : MemoryRegions.Disjoint (2*destination) (2*(4*(capacity+256)*256)) (2*zeroBase) (2*(4*256*256))

def oldOperation (layout : Layout capacity) (label : Copy2D.Label 4 (capacity*256)) : CopyExecution.Operation :=
  ⟨layout.oldBase+Kv.address capacity label.1 (KvConcat.oldTime label) (KvConcat.coordinate label),
    layout.destination+Kv.address (capacity+256) label.1 (KvConcat.oldTime label) (KvConcat.coordinate label)⟩

def zeroTime (label : Copy2D.Label 4 (256*256)) : Nat := label.2.val/256
theorem zero_time_bound (label : Copy2D.Label 4 (256*256)) : zeroTime label<256 := by
  have := label.2.isLt
  unfold zeroTime
  omega

def newOperation (layout : Layout capacity) (label : Copy2D.Label 4 (256*256)) : CopyExecution.Operation :=
  ⟨layout.zeroBase+Kv.address 256 label.1 (zeroTime label) (KvConcat.coordinate label),
    layout.destination+Kv.address (capacity+256) label.1 (capacity+zeroTime label) (KvConcat.coordinate label)⟩

-- Labels are the native two-dimensional scalar-copy grid coordinates.
-- These equalities connect their row/time decomposition to copy_gg_nd2.
theorem old_source_address (layout : Layout capacity) (label : Copy2D.Label 4 (capacity*256)) :
    2*(oldOperation layout label).source=
      2*layout.oldBase+Copy2D.sourceAddress (KvConcat.oldLayout capacity) label := by
  dsimp [oldOperation, Kv.address, KvConcat.oldTime, KvConcat.coordinate, Copy2D.sourceAddress, KvConcat.oldLayout]
  ring_nf
  omega

theorem new_source_address (layout : Layout capacity) (label : Copy2D.Label 4 (256*256)) :
    2*(newOperation layout label).source=
      2*layout.zeroBase+Copy2D.sourceAddress (KvConcat.newLayout capacity) label := by
  dsimp [newOperation, Kv.address, zeroTime, KvConcat.coordinate, Copy2D.sourceAddress, KvConcat.newLayout]
  ring_nf
  omega

theorem old_destination_address (layout : Layout capacity) (label : Copy2D.Label 4 (capacity*256)) :
    (oldOperation layout label).destination=layout.destination+
      (Copy2D.entry (KvConcat.oldLayout capacity) (fun _ => 0) label).word := by
  rw [KvConcat.old_destination]
  rfl

theorem new_destination_address (layout : Layout capacity) (label : Copy2D.Label 4 (256*256)) :
    (newOperation layout label).destination=layout.destination+
      (Copy2D.entry (KvConcat.newLayout capacity) KvConcat.zeros label).word := by
  rw [KvConcat.new_destination]
  rfl

def programs (layout : Layout capacity) : List (List CopyExecution.Operation) :=
  (Copy2D.labels 4 (capacity*256)).map (fun label => [oldOperation layout label]) ++
    (Copy2D.labels 4 (256*256)).map (fun label => [newOperation layout label])

theorem member (layout : Layout capacity) (op : CopyExecution.Operation) (inside : op ∈ (programs layout).flatten) :
    (∃ label, op=oldOperation layout label) ∨ (∃ label, op=newOperation layout label) := by
  simp only [programs, List.flatten_append, List.mem_append] at inside
  rcases inside with old|fresh
  · obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp old
    obtain ⟨label, _, rfl⟩ := List.mem_map.mp threadMember
    exact Or.inl ⟨label, List.mem_singleton.mp opMember⟩
  · obtain ⟨thread, threadMember, opMember⟩ := List.mem_flatten.mp fresh
    obtain ⟨label, _, rfl⟩ := List.mem_map.mp threadMember
    exact Or.inr ⟨label, List.mem_singleton.mp opMember⟩

theorem old_covers (layout : Layout capacity) (label : Copy2D.Label 4 (capacity*256)) :
    oldOperation layout label ∈ (programs layout).flatten := by
  simp only [programs, List.flatten_append, List.mem_append]
  exact Or.inl (List.mem_flatten.mpr ⟨[oldOperation layout label], List.mem_map.mpr
    ⟨label, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, List.mem_singleton_self _⟩)

theorem new_covers (layout : Layout capacity) (label : Copy2D.Label 4 (256*256)) :
    newOperation layout label ∈ (programs layout).flatten := by
  simp only [programs, List.flatten_append, List.mem_append]
  exact Or.inr (List.mem_flatten.mpr ⟨[newOperation layout label], List.mem_map.mpr
    ⟨label, List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, List.mem_singleton_self _⟩)

theorem writes_inside (layout : Layout capacity) (op : CopyExecution.Operation) (inside : op ∈ (programs layout).flatten) :
    2*layout.destination ≤ 2*op.destination ∧ 2*op.destination+2 ≤ 2*layout.destination+2*(4*(capacity+256)*256) := by
  rcases member layout op inside with ⟨label, rfl⟩|⟨label, rfl⟩
  · have time := KvConcat.old_time_bound label
    have bounds := Kv.address_bounds (capacity+256) label.1 (KvConcat.oldTime label) (KvConcat.coordinate label) (by omega)
    dsimp only [oldOperation]
    omega
  · have time := zero_time_bound label
    have bounds := Kv.address_bounds (capacity+256) label.1 (capacity+zeroTime label) (KvConcat.coordinate label) (by omega)
    dsimp only [newOperation]
    omega

theorem no_alias (layout : Layout capacity) : CopyExecution.NoAlias (programs layout).flatten := by
  apply CopyExecution.no_alias_regions _ (2*layout.destination) (2*(4*(capacity+256)*256)) (writes_inside layout)
  intro op inside
  rcases member layout op inside with ⟨label, rfl⟩|⟨label, rfl⟩
  · have bounds := Kv.address_bounds capacity label.1 (KvConcat.oldTime label) (KvConcat.coordinate label) (KvConcat.old_time_bound label)
    refine ⟨2*layout.oldBase, 2*(4*capacity*256), ?_, ?_, layout.oldSeparate⟩
    all_goals dsimp only [oldOperation]; omega
  · have bounds := Kv.address_bounds 256 label.1 (zeroTime label) (KvConcat.coordinate label) (zero_time_bound label)
    refine ⟨2*layout.zeroBase, 2*(4*256*256), ?_, ?_, layout.zeroSeparate⟩
    all_goals dsimp only [newOperation]; omega

abbrev Trace (layout : Layout capacity) := CopyExecution.Trace (programs layout)

theorem preserves (layout : Layout capacity) (trace : Trace layout) (head : Fin 4) (time : Fin capacity) (i : Fin 256) :
    HalfMemory.load trace.memory (2*(layout.destination+Kv.address (capacity+256) head time.val i))=
      HalfMemory.load trace.before (2*(layout.oldBase+Kv.address capacity head time.val i)) := by
  apply trace.read_correct (no_alias layout)
  · intro op inside same
    rcases member layout op inside with ⟨label, rfl⟩|⟨label, rfl⟩
    · have oldBound := KvConcat.old_time_bound label
      have equal := Kv.address_unique (capacity+256) label.1 head (KvConcat.oldTime label) time.val
        (KvConcat.coordinate label) i (by omega) (by have := time.isLt; omega) (Nat.add_left_cancel same)
      dsimp only [oldOperation]
      rw [equal.1, equal.2.1, equal.2.2]
    · have freshBound := zero_time_bound label
      have equal := Kv.address_unique (capacity+256) label.1 head (capacity+zeroTime label) time.val
        (KvConcat.coordinate label) i (by omega) (by have := time.isLt; omega) (Nat.add_left_cancel same)
      have := time.isLt
      omega
  · let label : Copy2D.Label 4 (capacity*256) := (head, ⟨time.val*256+i.val, by have := i.isLt; have := time.isLt; omega⟩)
    refine ⟨oldOperation layout label, old_covers layout label, ?_⟩
    have timeIndex : KvConcat.oldTime label=time.val := by dsimp [KvConcat.oldTime, label]; have := i.isLt; omega
    have coordinate : KvConcat.coordinate label=i := by apply Fin.ext; dsimp [KvConcat.coordinate, label]; have := i.isLt; omega
    simp only [oldOperation, timeIndex, coordinate]
    rfl

theorem extension_zero (layout : Layout capacity) (trace : Trace layout)
    (zeros : ∀ head : Fin 4, ∀ time : Fin 256, ∀ i : Fin 256,
      HalfMemory.load trace.before (2*(layout.zeroBase+Kv.address 256 head time.val i))=0)
    (head : Fin 4) (time : Fin 256) (i : Fin 256) :
    HalfMemory.load trace.memory (2*(layout.destination+Kv.address (capacity+256) head (capacity+time.val) i))=0 := by
  apply trace.read_correct (no_alias layout)
  · intro op inside same
    rcases member layout op inside with ⟨label, rfl⟩|⟨label, rfl⟩
    · have oldBound := KvConcat.old_time_bound label
      have equal := Kv.address_unique (capacity+256) label.1 head (KvConcat.oldTime label) (capacity+time.val)
        (KvConcat.coordinate label) i (by omega) (by have := time.isLt; omega) (Nat.add_left_cancel same)
      omega
    · exact zeros label.1 ⟨zeroTime label, zero_time_bound label⟩ (KvConcat.coordinate label)
  · let label : Copy2D.Label 4 (256*256) := (head, ⟨time.val*256+i.val, by have := i.isLt; have := time.isLt; omega⟩)
    refine ⟨newOperation layout label, new_covers layout label, ?_⟩
    have timeIndex : zeroTime label=time.val := by dsimp [zeroTime, label]; have := i.isLt; omega
    have coordinate : KvConcat.coordinate label=i := by apply Fin.ext; dsimp [KvConcat.coordinate, label]; have := i.isLt; omega
    simp only [newOperation, timeIndex, coordinate]
    rfl

theorem stores_inside (layout : Layout capacity) (trace : Trace layout) :
    MemoryRegions.Inside16 (2*layout.destination) (2*(4*(capacity+256)*256)) (trace.schedule.map (CopyExecution.store trace.before)) := by
  intro write inside
  obtain ⟨op, opMember, rfl⟩ := List.mem_map.mp inside
  exact writes_inside layout op ((ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp opMember)

theorem other_region (layout : Layout capacity) (trace : Trace layout)
    (separate : MemoryRegions.Disjoint (2*layout.destination) (2*(4*(capacity+256)*256)) base size) (offset : Nat) (bound : offset<size) :
    trace.memory (base+offset)=trace.before (base+offset) := by
  rw [trace.memory_fixed (no_alias layout)]
  exact MemoryRegions.execute16_other _ _ (stores_inside layout trace) separate offset bound

-- Native extension initialization: copy_s writes four BF16 zeros per
-- thread, 65536 threads in total, before the concurrent concatenation.
attribute [local irreducible] programs CopyContiguous.programs

abbrev ZeroTrace (base : Nat) := CopyContiguous.Trace (2*base) (fun _ : Fin (4*65536) => (0 : BitVec 16))

theorem zero_stores_inside (base : Nat) (trace : ZeroTrace base) :
    MemoryRegions.Inside16 (2*base) 524288 trace.schedule := by
  intro write present
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp present
  obtain ⟨thread, offset, rfl⟩ := CopyContiguous.member _ _ write original
  have bound := (CopyContiguous.index thread offset).isLt
  dsimp only [CopyContiguous.entry]
  omega

structure Initialized (layout : Layout capacity) where
  zeros : ZeroTrace layout.zeroBase
  oldSeparate : MemoryRegions.Disjoint (2*layout.zeroBase) 524288 (2*layout.oldBase) (2*(4*capacity*256))
  concatenation : Trace layout
  initial : concatenation.before=zeros.memory

variable {capacity : Nat} {layout : Layout capacity}

def Initialized.fromZeros (layout : Layout capacity) (zeros : ZeroTrace layout.zeroBase)
    (oldSeparate : MemoryRegions.Disjoint (2*layout.zeroBase) 524288 (2*layout.oldBase) (2*(4*capacity*256))) :
    Initialized layout :=
  ⟨zeros, oldSeparate, CopyExecution.Trace.canonical _ zeros.memory, rfl⟩

def Initialized.canonical (layout : Layout capacity) (before : ByteMemory.Bytes)
    (oldSeparate : MemoryRegions.Disjoint (2*layout.zeroBase) 524288 (2*layout.oldBase) (2*(4*capacity*256))) :
    Initialized layout :=
  Initialized.fromZeros layout
    (CopyContiguous.Trace.canonical (2*layout.zeroBase) (fun _ : Fin (4*65536) => (0 : BitVec 16)) before (by omega)) oldSeparate

theorem Initialized.zero_input (initialized : Initialized layout) (head : Fin 4) (time : Fin 256) (i : Fin 256) :
    HalfMemory.load initialized.concatenation.before (2*(layout.zeroBase+Kv.address 256 head time.val i))=0 := by
  rw [initialized.initial]
  have bound := Kv.address_bounds 256 head time.val i time.isLt
  have read := initialized.zeros.read_correct ⟨Kv.address 256 head time.val i, bound⟩
  simpa only [Nat.mul_add] using read

theorem Initialized.extension_zero (initialized : Initialized layout) (head : Fin 4) (time : Fin 256) (i : Fin 256) :
    HalfMemory.load initialized.concatenation.memory (2*(layout.destination+Kv.address (capacity+256) head (capacity+time.val) i))=0 :=
  KvConcatMemory.extension_zero layout initialized.concatenation initialized.zero_input head time i

theorem Initialized.preserves (initialized : Initialized layout) (head : Fin 4) (time : Fin capacity) (i : Fin 256) :
    HalfMemory.load initialized.concatenation.memory (2*(layout.destination+Kv.address (capacity+256) head time.val i))=
      HalfMemory.load initialized.zeros.before (2*(layout.oldBase+Kv.address capacity head time.val i)) := by
  rw [KvConcatMemory.preserves layout initialized.concatenation, initialized.initial]
  have bound := Kv.address_bounds capacity head time.val i time.isLt
  have same := ArrayFrame.half_congr initialized.zeros.before initialized.zeros.memory (2*layout.oldBase)
    (2*(4*capacity*256)) (2*Kv.address capacity head time.val i)
    (MemoryRegions.execute16_other _ _ (zero_stores_inside layout.zeroBase initialized.zeros) initialized.oldSeparate)
    (by omega)
  simpa only [Nat.mul_add] using same

end Inference.State.KvConcatMemory
