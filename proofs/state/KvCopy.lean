import state.KvAllocation
import contracts.mlx.Copy2D

namespace Inference.State.KvCopy
open Contracts.Mlx KvBytes

-- The source may be a strided view. Attachment describes the bytes read
-- by elem_to_loc_2; it does not assume a contiguous projected key/value.
structure Source (next : Row) where
  bytes : HalfMemory.Bytes
  base : Nat
  rowStride : Nat
  columnStride : Nat
  aligned : base%2=0
  attached : ∀ head i, HalfMemory.load bytes (base+2*(i.val*columnStride+head.val*rowStride))=bits (next head i)

def Source.canonical (next : Row) : Source next where
  bytes := HalfMemory.encode (initialWords 1 (fun head (_ : Fin 1) i => next head i))
  base := 0
  rowStride := 256
  columnStride := 1
  aligned := by decide
  attached := by
    intro head i
    simpa only [Nat.zero_add, Nat.mul_one, Nat.add_zero, Kv.address, Nat.add_comm] using
      initial_attached 1 (by decide) (fun head (_ : Fin 1) i => next head i) head ⟨0, by decide⟩ i

def layout (source : Source next) (base capacity n : Nat) : Copy2D.Layout where
  sourceBase := source.base
  sourceRow := source.rowStride
  sourceColumn := source.columnStride
  destinationBase := base+2*(n*256)
  destinationRow := capacity*256

theorem destination_word (source : Source next) (base capacity n : Nat) (label : Label) :
    (layout source base capacity n).destinationBase/2+
      Copy2D.destination (layout source base capacity n).destinationRow label=
      base/2+Kv.address capacity label.1 n label.2 := by
  dsimp [layout, Copy2D.destination, Kv.address]
  rw [show (base+2*(n*256))/2=base/2+n*256 by omega]
  ring

theorem entry_eq (source : Source next) (base capacity n : Nat) (label : Label) :
    Copy2D.entry (layout source base capacity n) source.bytes label=KvBytes.entry base capacity n next label := by
  have loaded : HalfMemory.load source.bytes (Copy2D.sourceAddress (layout source base capacity n) label)=bits (next label.1 label.2) :=
    source.attached label.1 label.2
  unfold Copy2D.entry KvBytes.entry
  rw [destination_word, loaded]

theorem programs_eq (source : Source next) (base capacity n : Nat) :
    Copy2D.programs (layout source base capacity n) source.bytes 4 256=KvBytes.programs base capacity n next := by
  unfold Copy2D.programs KvBytes.programs
  apply congrArg (fun f => KvBytes.labels.map f)
  funext label
  rw [entry_eq]

-- Convert a completed concrete two-dimensional copy schedule into the KV
-- append contract. Neither the stored new value nor the preserved old values
-- are supplied as proof premises.
def fromCopy (source : Source next) (base capacity : Nat) (old : History n)
    (room : n<capacity) (aligned : base%2=0)
    (trace : Copy2D.Trace (layout source base capacity n) source.bytes 4 256)
    (attached : ∀ head time i, HalfMemory.load trace.before (base+2*Kv.address capacity head time.val i)=bits (old head time i)) :
    KvBytes.Trace old next where
  capacity := capacity
  room := room
  before := trace.before
  base := base
  aligned := aligned
  attached := attached
  schedule := trace.schedule
  remaining := trace.remaining
  execution := by
    rw [← programs_eq source base capacity n]
    exact trace.execution
  completed := trace.completed

theorem fromCopy_memory (source : Source next) (base capacity : Nat) (old : History n)
    (room : n<capacity) (aligned : base%2=0)
    (trace : Copy2D.Trace (layout source base capacity n) source.bytes 4 256)
    (attached : ∀ head time i, HalfMemory.load trace.before (base+2*Kv.address capacity head time.val i)=bits (old head time i)) :
    (fromCopy source base capacity old room aligned trace attached).memory=trace.memory := rfl

def canonicalCopy (source : Source next) (base capacity n : Nat) (before : HalfMemory.Bytes)
    (aligned : base%2=0) (room : n<capacity) : Copy2D.Trace (layout source base capacity n) source.bytes 4 256 :=
  Copy2D.Trace.canonical _ _ before 4 256 (by dsimp [layout]; omega) (by dsimp [layout]; omega)

def appendTrace (source : Source next) (old : History n) (before : HalfMemory.Bytes) (attached : KvAllocation.Attached before old) :
    KvBytes.Trace old next :=
  fromCopy source 0 (KvAllocation.capacity (n+1)) old
    (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1) (by decide)
    (canonicalCopy source 0 (KvAllocation.capacity (n+1)) n (KvAllocation.prepare n before) (by decide)
      (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1))
    (by
      intro head time i
      simpa only [canonicalCopy, Copy2D.Trace.canonical, Nat.zero_add] using
        KvAllocation.prepare_attached before old attached head time i)

theorem append_read (source : Source next) (old : History n) (before : HalfMemory.Bytes) (attached : KvAllocation.Attached before old)
    (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    (appendTrace source old before attached).read head time i=Kv.appendRows (fun t => old head t i) (next head i) time :=
  KvBytes.Trace.read_correct _ head time i

def fromStorage {cache : Kv.Cache BF n} {key value : Row} (storage : KvAllocation.Storage cache)
    (keySource : Source key) (valueSource : Source value) : KvBytes.Execution cache key value :=
  ⟨appendTrace keySource cache.keys storage.keys storage.keysAttached,
    appendTrace valueSource cache.values storage.values storage.valuesAttached⟩

theorem fromStorage_correct {cache : Kv.Cache BF n} {key value : Row} (storage : KvAllocation.Storage cache)
    (keySource : Source key) (valueSource : Source value) :
    KvBytes.cacheAfter (fromStorage storage keySource valueSource)=Kv.append cache key value :=
  KvBytes.cacheAfter_eq _

theorem destination_bounds (source : Source next) (capacity n : Nat) (room : n<capacity)
    (supported : capacity ≤ 262144) (label : Label) :
    let index := n*256+Copy2D.destination (layout source 0 capacity n).destinationRow label
    index<4*capacity*256 ∧ index<2^31 ∧ 2*index+2 ≤ 2^64 := by
  have bounded := Kv.address_bounds capacity label.1 n label.2 room
  have equal : n*256+Copy2D.destination (layout source 0 capacity n).destinationRow label=
      Kv.address capacity label.1 n label.2 := by
    dsimp [Copy2D.destination, layout, Kv.address]
    ring
  dsimp only
  rw [equal]
  omega

end Inference.State.KvCopy
