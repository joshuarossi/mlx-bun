import state.Kv
import contracts.mlx.HalfMemory
import contracts.mlx.WriteOwnership

namespace Inference.State.KvBytes
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
abbrev Row := Fin 4 → Fin 256 → BF
abbrev History (n : Nat) := Fin 4 → Fin n → Fin 256 → BF
abbrev Label := Fin 4 × Fin 256
def labels : List Label := (List.finRange 4).product (List.finRange 256)
def bits (value : BF) : BitVec 16 := value.bits

-- Logical scalar writes for the selected slice update. Native copy-kernel
-- geometry, allocation and resizing must implement this storage contract.
def entry (base capacity n : Nat) (next : Row) (label : Label) : HalfMemory.Store :=
  ⟨base/2+Kv.address capacity label.1 n label.2, bits (next label.1 label.2)⟩
def programs (base capacity n : Nat) (next : Row) : List (List HalfMemory.Store) :=
  labels.map (fun label => [entry base capacity n next label])

theorem member (base capacity n : Nat) (next : Row) (store : HalfMemory.Store)
    (inside : store ∈ (programs base capacity n next).flatten) : ∃ label, store=entry base capacity n next label := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨label, _, rfl⟩ := List.mem_map.mp ht
  exact ⟨label, List.mem_singleton.mp hs⟩

theorem covers (base capacity n : Nat) (next : Row) (head : Fin 4) (i : Fin 256) :
    entry base capacity n next (head, i) ∈ (programs base capacity n next).flatten :=
  List.mem_flatten.mpr ⟨[entry base capacity n next (head, i)], List.mem_map.mpr
    ⟨(head, i), List.mem_product.mpr ⟨List.mem_finRange _, List.mem_finRange _⟩, rfl⟩, by simp⟩

theorem stored_new (base capacity n : Nat) (room : n<capacity) (next : Row) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base capacity n next) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 4) (i : Fin 256) :
    MemoryCells.execute schedule before (base/2+Kv.address capacity head n i)=bits (next head i) := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨label, rfl⟩ := member base capacity n next store inside
    have equal : Kv.address capacity label.1 n label.2=Kv.address capacity head n i := by
      simpa only [entry, Nat.add_left_cancel_iff] using same
    obtain ⟨headEq, _, indexEq⟩ := Kv.address_unique capacity label.1 head n n label.2 i room room equal
    simp only [entry, headEq, indexEq]
  · exact ⟨entry base capacity n next (head, i), covers base capacity n next head i, rfl⟩

theorem stored_old (base capacity n : Nat) (room : n<capacity) (next : Row) (before : HalfMemory.Words)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base capacity n next) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (head : Fin 4) (time : Fin n) (i : Fin 256) :
    MemoryCells.execute schedule before (base/2+Kv.address capacity head time.val i)=before (base/2+Kv.address capacity head time.val i) := by
  apply MemoryCells.frame
  intro store inside same
  have order := ThreadgroupWrites.completed_schedule execution completed
  obtain ⟨label, rfl⟩ := member base capacity n next store (order.mem_iff.mp inside)
  have equal : Kv.address capacity label.1 n label.2=Kv.address capacity head time.val i := by
    simpa only [entry, Nat.add_left_cancel_iff] using same
  have timeEq := (Kv.address_unique capacity label.1 head n time.val label.2 i room (time.isLt.trans room) equal).2.1
  have := time.isLt
  omega

private def owner (base capacity word : Nat) : Label :=
  (⟨(word-base/2)/256/capacity%4, by omega⟩, ⟨(word-base/2)%256, by omega⟩)

theorem separated (base capacity n : Nat) (room : n<capacity) (next : Row) :
    WriteOwnership.Separated MemoryCells.Store.word (programs base capacity n next) := by
  apply WriteOwnership.owned labels ((List.nodup_finRange 4).product (List.nodup_finRange 256)) _ _ (owner base capacity)
  intro label _ store inside
  have equal := List.mem_singleton.mp inside
  subst store
  simp only [owner, entry, Nat.add_sub_cancel_left, Kv.address_head capacity _ _ _ room,
    Kv.address_coordinate, Nat.mod_eq_of_lt label.1.isLt]

def initialWords (capacity : Nat) (old : History n) (word : Nat) : BitVec 16 :=
  if active : word/256%capacity<n then
    bits (old ⟨word/256/capacity%4, by omega⟩ ⟨word/256%capacity,active⟩ ⟨word%256, by omega⟩)
  else 0

theorem initial_attached (capacity : Nat) (active : n ≤ capacity) (old : History n)
    (head : Fin 4) (time : Fin n) (i : Fin 256) :
    HalfMemory.load (HalfMemory.encode (initialWords capacity old)) (2*Kv.address capacity head time.val i)=bits (old head time i) := by
  rw [HalfMemory.load_encode _ _ (by omega), show 2*Kv.address capacity head time.val i/2=Kv.address capacity head time.val i by omega]
  simp only [initialWords, Kv.address_head capacity head time.val i (time.isLt.trans_le active),
    Kv.address_time capacity head time.val i (time.isLt.trans_le active), Kv.address_coordinate,
    Nat.mod_eq_of_lt head.isLt, time.isLt, ↓reduceDIte]

structure Trace (old : History n) (next : Row) where
  capacity : Nat
  room : n<capacity
  before : HalfMemory.Bytes
  base : Nat
  aligned : base%2=0
  attached : ∀ head time i, HalfMemory.load before (base+2*Kv.address capacity head time.val i)=bits (old head time i)
  schedule : List HalfMemory.Store
  remaining : List (List HalfMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base capacity n next) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (old : History n) (next : Row) : Trace old next where
  capacity := n+1
  room := by omega
  before := HalfMemory.encode (initialWords (n+1) old)
  base := 0
  aligned := by decide
  attached := by
    intro head time i
    simpa only [Nat.zero_add] using initial_attached (n+1) (Nat.le_succ n) old head time i
  schedule := (programs 0 (n+1) n next).flatten
  remaining := List.replicate (programs 0 (n+1) n next).length []
  execution := ThreadgroupWrites.canonical _
  completed := ThreadgroupWrites.canonical_barrier _

variable {n : Nat} {old : History n} {next : Row}

def Trace.memory (trace : Trace old next) : HalfMemory.Bytes := HalfMemory.execute trace.schedule trace.before
def Trace.read (trace : Trace old next) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) : BF :=
  Model.ofBits (HalfMemory.load trace.memory (trace.base+2*Kv.address trace.capacity head time.val i))

theorem Trace.load_correct (trace : Trace old next) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load trace.memory (trace.base+2*Kv.address trace.capacity head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
    unfold Trace.memory
    rw [HalfMemory.execute_load _ _ _ (by have := trace.aligned; omega),
      show (trace.base+2*Kv.address trace.capacity head time.val i)/2=trace.base/2+Kv.address trace.capacity head time.val i by omega]
    by_cases existing : time.val<n
    · rw [stored_old _ _ _ trace.room next _ _ _ trace.execution trace.completed head ⟨time.val, existing⟩ i]
      have initial := trace.attached head ⟨time.val, existing⟩ i
      rw [show trace.base+2*Kv.address trace.capacity head time.val i=2*(trace.base/2+Kv.address trace.capacity head time.val i) by
        have := trace.aligned; omega] at initial
      simpa only [HalfMemory.view, Kv.appendRows, dite_eq_left existing] using initial
    · have newest : time.val=n := by omega
      rw [newest, stored_new _ _ _ trace.room next _ _ _ trace.execution trace.completed]
      simp only [Kv.appendRows, dite_eq_right existing]

theorem Trace.read_correct (trace : Trace old next) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    trace.read head time i=Kv.appendRows (fun t => old head t i) (next head i) time := by
  exact congrArg (fun bits : BitVec 16 => (Model.ofBits bits : BF)) (trace.load_correct head time i)

theorem Trace.read_bounds (trace : Trace old next) (addressable : trace.base+2*(4*trace.capacity*256) ≤ 2^64)
    (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    let address := trace.base+2*Kv.address trace.capacity head time.val i
    address%2=0 ∧ trace.base ≤ address ∧ address+2 ≤ trace.base+2*(4*trace.capacity*256) ∧ address+2 ≤ 2^64 := by
  have := Kv.address_bounds trace.capacity head time.val i (by have := trace.room; omega)
  have := trace.aligned
  dsimp only
  omega

theorem canonical_addressable (old : History n) (next : Row) (supported : n+1 ≤ 262144) :
    (Trace.canonical old next).base+2*(4*(Trace.canonical old next).capacity*256) ≤ 2^64 := by
  change 0+2*(4*(n+1)*256) ≤ 2^64
  omega

structure Execution (old : Kv.Cache BF n) (key value : Row) where
  keys : Trace old.keys key
  values : Trace old.values value

def Execution.canonical (old : Kv.Cache BF n) (key value : Row) : Execution old key value :=
  ⟨Trace.canonical old.keys key, Trace.canonical old.values value⟩

def cacheAfter {cache : Kv.Cache BF n} {key value : Row} (execution : Execution cache key value) : Kv.Cache BF (n+1) :=
  ⟨execution.keys.read, execution.values.read⟩

theorem cacheAfter_eq {cache : Kv.Cache BF n} {key value : Row} (execution : Execution cache key value) : cacheAfter execution=Kv.append cache key value := by
  have keyEq : execution.keys.read=fun h t i => Kv.appendRows (fun s => cache.keys h s i) (key h i) t :=
    funext fun h => funext fun t => funext fun i => execution.keys.read_correct h t i
  have valueEq : execution.values.read=fun h t i => Kv.appendRows (fun s => cache.values h s i) (value h i) t :=
    funext fun h => funext fun t => funext fun i => execution.values.read_correct h t i
  unfold cacheAfter Kv.append
  rw [keyEq, valueEq]

end Inference.State.KvBytes
