import kernels.delta.Gated
import contracts.mlx.Memory
import Mathlib.Data.List.Nodup

namespace Inference.Kernels.Delta.Layout
open Contracts.Mlx Contracts.Mlx.Numerics

-- Static Qwen geometry: 16 key/query heads, 48 value heads, 128 key and
-- value coordinates. Offsets are in elements until stateAddress adds bytes.
structure Row (batchSize : Nat) where
  batch : Fin batchSize
  head : Fin 48
  value : Fin 128

def keyHead (head : Fin 48) : Fin 16 := ⟨head.val / 3, by have := head.isLt; omega⟩

theorem keyHead_range (head : Fin 48) :
    3 * (keyHead head).val ≤ head.val ∧ head.val < 3 * (keyHead head).val + 3 := by
  unfold keyHead
  dsimp only
  omega

theorem keyHead_three (head : Fin 16) (copy : Fin 3) :
    keyHead ⟨head.val * 3 + copy.val, by have := head.isLt; have := copy.isLt; omega⟩ = head := by
  apply Fin.ext
  dsimp [keyHead]
  have := copy.isLt
  omega

private theorem flatten_bound (a b sizeA sizeB : Nat) (ha : a < sizeA) (hb : b < sizeB) :
    a * sizeB + b < sizeA * sizeB := by
  calc
    _ < a * sizeB + sizeB := Nat.add_lt_add_left hb _
    _ = (a+1) * sizeB := by ring
    _ ≤ sizeA * sizeB := Nat.mul_le_mul_right sizeB ha

def rowIndex (row : Row batchSize) : Nat := (row.batch.val * 48 + row.head.val) * 128 + row.value.val

def stateIndex (row : Row batchSize) (key : Fin 128) : Nat := rowIndex row * 128 + key.val

def stateAddress (base : Nat) (row : Row batchSize) (key : Fin 128) : Nat := base + 4 * stateIndex row key

theorem rowIndex_bound (row : Row batchSize) : rowIndex row < batchSize * 48 * 128 :=
  flatten_bound _ _ _ _ (flatten_bound _ _ _ _ row.batch.isLt row.head.isLt) row.value.isLt

theorem stateIndex_bound (row : Row batchSize) (key : Fin 128) : stateIndex row key < batchSize * 48 * 128 * 128 :=
  flatten_bound _ _ _ _ (rowIndex_bound row) key.isLt

theorem stateAddress_aligned (base : Nat) (row : Row batchSize) (key : Fin 128) (ha : base % 4 = 0) :
    stateAddress base row key % 4 = 0 := by unfold stateAddress; omega

theorem stateAddress_bound (base : Nat) (row : Row batchSize) (key : Fin 128)
    (capacity : base + 4 * (batchSize * 48 * 128 * 128) ≤ 2^64) : stateAddress base row key + 4 ≤ 2^64 := by
  have := stateIndex_bound row key
  unfold stateAddress
  omega

theorem stateIndex_injective (left right : Row batchSize) (i j : Fin 128)
    (he : stateIndex left i = stateIndex right j) : left = right ∧ i = j := by
  have hi := i.isLt
  have hj := j.isLt
  have hlh := left.head.isLt
  have hrh := right.head.isLt
  have hlv := left.value.isLt
  have hrv := right.value.isLt
  unfold stateIndex rowIndex at he
  constructor
  · cases left
    cases right
    congr 1 <;> apply Fin.ext <;> dsimp only at * <;> omega
  · apply Fin.ext
    omega

theorem stateAddress_injective (base : Nat) (left right : Row batchSize) (i j : Fin 128)
    (he : stateAddress base left i = stateAddress base right j) : left = right ∧ i = j := by
  apply stateIndex_injective left right i j
  unfold stateAddress at he
  omega

-- The q/k and v/y pointers begin at t=0 and advance once per iteration.
-- Show that their addresses agree with the mathematical tensor layout.
def qBase (row : Row batchSize) (timeCount : Nat) : Nat :=
  row.batch.val * timeCount * 16 * 128 + (keyHead row.head).val * 128

def qIndex (row : Row batchSize) (timeCount time : Nat) (key : Fin 128) : Nat :=
  ((row.batch.val * timeCount + time) * 16 + (keyHead row.head).val) * 128 + key.val

theorem q_pointer (row : Row batchSize) (timeCount time : Nat) (key : Fin 128) :
    qBase row timeCount + time * (16 * 128) + key.val = qIndex row timeCount time key := by
  unfold qBase qIndex
  ring

theorem qIndex_bound (row : Row batchSize) (timeCount time : Nat) (ht : time < timeCount) (key : Fin 128) :
    qIndex row timeCount time key < batchSize * timeCount * 16 * 128 :=
  flatten_bound _ _ _ _
    (flatten_bound _ _ _ _ (flatten_bound _ _ _ _ row.batch.isLt ht) (keyHead row.head).isLt) key.isLt

def yBase (row : Row batchSize) (timeCount : Nat) : Nat := row.batch.val * timeCount * 48 * 128 + row.head.val * 128

def yIndex (row : Row batchSize) (timeCount time : Nat) : Nat :=
  ((row.batch.val * timeCount + time) * 48 + row.head.val) * 128 + row.value.val

theorem y_pointer (row : Row batchSize) (timeCount time : Nat) :
    yBase row timeCount + time * (48 * 128) + row.value.val = yIndex row timeCount time := by
  unfold yBase yIndex
  ring

theorem yIndex_bound (row : Row batchSize) (timeCount time : Nat) (ht : time < timeCount) :
    yIndex row timeCount time < batchSize * timeCount * 48 * 128 :=
  flatten_bound _ _ _ _
    (flatten_bound _ _ _ _ (flatten_bound _ _ _ _ row.batch.isLt ht) row.head.isLt) row.value.isLt

def gateIndex (row : Row batchSize) (timeCount time : Nat) : Nat :=
  (row.batch.val * timeCount + time) * 48 + row.head.val

theorem gate_pointer (row : Row batchSize) (timeCount time : Nat) :
    row.batch.val * timeCount * 48 + time * 48 + row.head.val = gateIndex row timeCount time := by
  unfold gateIndex
  ring

theorem gateIndex_bound (row : Row batchSize) (timeCount time : Nat) (ht : time < timeCount) :
    gateIndex row timeCount time < batchSize * timeCount * 48 :=
  flatten_bound _ _ _ _ (flatten_bound _ _ _ _ row.batch.isLt ht) row.head.isLt

-- Every lane's four register values are written after the recurrence loop.
-- Prove the final contents for any interleaving and preserve other rows.
def stores (base : Nat) (row : Row batchSize) (values : Fin 128 → Float32) : List Memory.Store :=
  (List.finRange 128).map (fun i => ⟨stateAddress base row i, values i⟩)

theorem addresses_unique (base : Nat) (row : Row batchSize) :
    ((List.finRange 128).map (stateAddress base row)).Nodup :=
  (List.nodup_finRange 128).map (fun _ _ h => (stateAddress_injective base row row _ _ h).2)

theorem state_written (base : Nat) (row : Row batchSize) (values : Fin 128 → Float32)
    (before : M1Max.WordMemory) (scheduled : List Memory.Store) (order : scheduled.Perm (stores base row values)) (i : Fin 128) :
    Memory.execute scheduled before (stateAddress base row i) = values i := by
  apply Memory.written_value_permuted (stores base row values) scheduled order before _ _
  · intro store hs he
    obtain ⟨j, _, rfl⟩ := List.mem_map.mp hs
    have hij := (stateAddress_injective base row row j i he).2
    subst j
    rfl
  · exact ⟨⟨stateAddress base row i, values i⟩, List.mem_map.mpr ⟨i, List.mem_finRange i, rfl⟩, rfl⟩

theorem other_row_preserved (base : Nat) (row other : Row batchSize) (different : row ≠ other)
    (values : Fin 128 → Float32) (before : M1Max.WordMemory)
    (scheduled : List Memory.Store) (order : scheduled.Perm (stores base row values)) (i : Fin 128) :
    Memory.execute scheduled before (stateAddress base other i) = before (stateAddress base other i) := by
  apply Memory.frame
  intro store hs he
  obtain ⟨j, _, rfl⟩ := List.mem_map.mp (order.mem_iff.mp hs)
  exact different (stateAddress_injective base row other j i he).1

theorem stored_state_error (base : Nat) (row : Row batchSize) (input : Nat → Float32) (target inputError : Nat → ℝ)
    (hi : ∀ i, |real (input i) - target i| ≤ inputError i)
    (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce) (flags : Gated.Contraction)
    (before : M1Max.WordMemory) (scheduled : List Memory.Store)
    (order : scheduled.Perm (stores base row (Gated.sourceState input reduce flags)))
    (i : Fin 128) (hf : Arithmetic.Finite input (Gated.stateExpr flags platform.tree i)) :
    |real (Memory.execute scheduled before (stateAddress base row i)) - Gated.state target i| ≤
      Arithmetic.budget input target inputError (Gated.stateExpr flags platform.tree i) := by
  rw [state_written base row _ before scheduled order i]
  exact Gated.state_error input target inputError hi reduce platform flags i hf

end Inference.Kernels.Delta.Layout
