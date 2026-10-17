import contracts.mlx.Memory
import contracts.mlx.BFloat16Arithmetic
import Mathlib.Data.List.OfFn

namespace Inference.State.Kv
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Active [1,4,n,256] view of plain BF16 storage. Allocator ownership and
-- resizing are separate; the store/read theorem below permits any capacity.
structure Cache (α : Type) (n : Nat) where
  keys : Fin 4 → Fin n → Fin 256 → α
  values : Fin 4 → Fin n → Fin 256 → α

def appendRows (old : Fin n → α) (next : α) (t : Fin (n+1)) : α :=
  if h : t.val < n then old ⟨t.val, h⟩ else next
def append (old : Cache α n) (key value : Fin 4 → Fin 256 → α) : Cache α (n+1) where
  keys h t i := appendRows (fun s => old.keys h s i) (key h i) t
  values h t i := appendRows (fun s => old.values h s i) (value h i) t

theorem appendRows_old (old : Fin n → α) (next : α) (t : Fin n) :
    appendRows old next t.castSucc = old t := by simp [appendRows, t.isLt]
theorem appendRows_new (old : Fin n → α) (next : α) :
    appendRows old next (Fin.last n) = next := by simp [appendRows]
theorem append_keys_old (old : Cache α n) (key value : Fin 4 → Fin 256 → α) (h : Fin 4) (t : Fin n) (i : Fin 256) :
    (append old key value).keys h t.castSucc i = old.keys h t i := appendRows_old (fun s => old.keys h s i) (key h i) t
theorem append_values_old (old : Cache α n) (key value : Fin 4 → Fin 256 → α) (h : Fin 4) (t : Fin n) (i : Fin 256) :
    (append old key value).values h t.castSucc i = old.values h t i := appendRows_old (fun s => old.values h s i) (value h i) t
theorem append_keys_new (old : Cache α n) (key value : Fin 4 → Fin 256 → α) (h : Fin 4) (i : Fin 256) :
    (append old key value).keys h (Fin.last n) i = key h i := appendRows_new (fun s => old.keys h s i) (key h i)
theorem append_values_new (old : Cache α n) (key value : Fin 4 → Fin 256 → α) (h : Fin 4) (i : Fin 256) :
    (append old key value).values h (Fin.last n) i = value h i := appendRows_new (fun s => old.values h s i) (value h i)

structure Error (actual : Cache BF n) (target error : Cache ℝ n) : Prop where
  keys : ∀ h t i, |Model.toReal (actual.keys h t i) - target.keys h t i| ≤ error.keys h t i
  values : ∀ h t i, |Model.toReal (actual.values h t i) - target.values h t i| ≤ error.values h t i
structure Finite (actual : Cache BF n) : Prop where
  keys : ∀ h t i, Model.isFinite (actual.keys h t i) = true
  values : ∀ h t i, Model.isFinite (actual.values h t i) = true

theorem appendRows_error (old : Fin n → BF) (next : BF) (target error : Fin n → ℝ) (targetNext errorNext : ℝ)
    (ho : ∀ t, |Model.toReal (old t) - target t| ≤ error t)
    (hn : |Model.toReal next - targetNext| ≤ errorNext) (t : Fin (n+1)) :
    |Model.toReal (appendRows old next t) - appendRows target targetNext t| ≤ appendRows error errorNext t := by
  unfold appendRows
  split
  · exact ho _
  · exact hn

theorem append_error (old : Cache BF n) (target error : Cache ℝ n)
    (key value : Fin 4 → Fin 256 → BF) (targetKey targetValue errorKey errorValue : Fin 4 → Fin 256 → ℝ)
    (ho : Error old target error)
    (hk : ∀ h i, |Model.toReal (key h i) - targetKey h i| ≤ errorKey h i)
    (hv : ∀ h i, |Model.toReal (value h i) - targetValue h i| ≤ errorValue h i) :
    Error (append old key value) (append target targetKey targetValue) (append error errorKey errorValue) where
  keys h t i := appendRows_error _ _ _ _ _ _ (fun s => ho.keys h s i) (hk h i) t
  values h t i := appendRows_error _ _ _ _ _ _ (fun s => ho.values h s i) (hv h i) t

theorem append_finite (old : Cache BF n) (key value : Fin 4 → Fin 256 → BF) (ho : Finite old)
    (hk : ∀ h i, Model.isFinite (key h i) = true) (hv : ∀ h i, Model.isFinite (value h i) = true) :
    Finite (append old key value) := by
  constructor
  · intro h t i
    dsimp only [append, appendRows]
    split
    · exact ho.keys h _ i
    · exact hk h i
  · intro h t i
    dsimp only [append, appendRows]
    split
    · exact ho.values h _ i
    · exact hv h i

def address (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) : Nat :=
  (h.val*capacity+t)*256+i.val

theorem address_bounds (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) (ht : t < capacity) :
    address capacity h t i < 4*capacity*256 := by
  have := h.isLt
  have := i.isLt
  dsimp [address]
  nlinarith

theorem address_coordinate (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) :
    address capacity h t i % 256 = i.val := by simp [address, Nat.mod_eq_of_lt i.isLt]
theorem address_row (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) :
    address capacity h t i / 256 = h.val*capacity+t := by
  dsimp [address]
  have := i.isLt
  omega
theorem address_head (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) (ht : t < capacity) :
    address capacity h t i / 256 / capacity = h.val := by
  rw [address_row, Nat.add_div]
  all_goals first | exact Nat.zero_lt_of_lt ht | simp [Nat.div_eq_of_lt ht, Nat.ne_of_gt (Nat.zero_lt_of_lt ht), Nat.mod_lt _ (Nat.zero_lt_of_lt ht)]
theorem address_time (capacity : Nat) (h : Fin 4) (t : Nat) (i : Fin 256) (ht : t < capacity) :
    address capacity h t i / 256 % capacity = t := by
  rw [address_row]
  simp [Nat.mod_eq_of_lt ht]

theorem address_unique (capacity : Nat) (h g : Fin 4) (t s : Nat) (i j : Fin 256)
    (ht : t < capacity) (hs : s < capacity) (he : address capacity h t i = address capacity g s j) :
    h = g ∧ t = s ∧ i = j := by
  have hh := congrArg (fun a => a/256/capacity) he
  have htime := congrArg (fun a => a/256%capacity) he
  have hi := congrArg (fun a => a%256) he
  rw [address_head _ _ _ _ ht, address_head _ _ _ _ hs] at hh
  rw [address_time _ _ _ _ ht, address_time _ _ _ _ hs] at htime
  rw [address_coordinate, address_coordinate] at hi
  exact ⟨Fin.ext hh, htime, Fin.ext hi⟩

def writeIndices (capacity n : Nat) : List Nat :=
  (List.finRange 4).flatMap (fun h => (List.finRange 256).map (address capacity h n))
def writeValue (capacity : Nat) (next : Fin 4 → Fin 256 → α) (a : Nat) : α :=
  next ⟨a/256/capacity%4, Nat.mod_lt _ (by decide)⟩ ⟨a%256, Nat.mod_lt _ (by decide)⟩
def stored (capacity _n : Nat) (next : Fin 4 → Fin 256 → α) (before : Nat → α) (schedule : List Nat) : Nat → α :=
  Memory.writeCells (writeValue capacity next) schedule before

theorem mem_writeIndices (capacity n : Nat) (h : Fin 4) (i : Fin 256) :
    address capacity h n i ∈ writeIndices capacity n := by
  simp only [writeIndices, List.mem_flatMap, List.mem_finRange, List.mem_map, true_and]
  exact ⟨h, i, rfl⟩

theorem stored_new (capacity n : Nat) (hn : n < capacity) (next : Fin 4 → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) (hs : schedule.Perm (writeIndices capacity n)) (h : Fin 4) (i : Fin 256) :
    stored capacity n next before schedule (address capacity h n i) = next h i := by
  unfold stored
  rw [Memory.writeCells_read, ite_eq_left (hs.mem_iff.mpr (mem_writeIndices capacity n h i))]
  simp [writeValue, address_head _ _ _ _ hn, address_coordinate, Nat.mod_eq_of_lt h.isLt]

theorem stored_old (capacity n : Nat) (hn : n < capacity) (next : Fin 4 → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) (hs : schedule.Perm (writeIndices capacity n))
    (h : Fin 4) (t : Fin n) (i : Fin 256) :
    stored capacity n next before schedule (address capacity h t.val i) = before (address capacity h t.val i) := by
  unfold stored
  rw [Memory.writeCells_read]
  apply ite_eq_right
  intro hm
  have hm := hs.mem_iff.mp hm
  simp only [writeIndices, List.mem_flatMap, List.mem_finRange, List.mem_map, true_and] at hm
  obtain ⟨g, j, he⟩ := hm
  have ht := (address_unique capacity g h n t.val j i hn (Nat.lt_trans t.isLt hn) he).2.1
  have := t.isLt
  omega

theorem stored_read (capacity n : Nat) (hn : n < capacity) (next : Fin 4 → Fin 256 → α)
    (before : Nat → α) (schedule : List Nat) (hs : schedule.Perm (writeIndices capacity n))
    (h : Fin 4) (t : Fin (n+1)) (i : Fin 256) :
    stored capacity n next before schedule (address capacity h t.val i) =
      appendRows (fun s : Fin n => before (address capacity h s.val i)) (next h i) t := by
  by_cases ht : t.val < n
  · simpa only [appendRows, dite_eq_left ht] using stored_old capacity n hn next before schedule hs h ⟨t.val, ht⟩ i
  · have he : t.val = n := by have := t.isLt; omega
    simpa [appendRows, he] using stored_new capacity n hn next before schedule hs h i

end Inference.State.Kv
