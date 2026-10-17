import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.Memory

namespace Inference.Contracts.Mlx.ElementwiseAdd
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open BFloat16Arithmetic (Value)

-- Same-shape bf16 addition used by Qwen's residual branches. The native
-- elementwise kernel and compiler must implement these scalar operations.
def forward (left right : Fin n → Value) (i : Fin n) : Value :=
  BFloat16Arithmetic.add (left i) (right i)

noncomputable def budget (left right : Fin n → Value) (leftError rightError : Fin n → ℝ) (i : Fin n) : ℝ :=
  BFloat16Arithmetic.addBudget (left i) (right i) + leftError i + rightError i

structure Bounds (left right : Fin n → Value) where
  leftBound : Fin n → ℝ
  rightBound : Fin n → ℝ
  leftFinite : ∀ i, Model.isFinite (left i) = true
  rightFinite : ∀ i, Model.isFinite (right i) = true
  leftMagnitude : ∀ i, |Model.toReal (left i)| ≤ leftBound i
  rightMagnitude : ∀ i, |Model.toReal (right i)| ≤ rightBound i
  capacity : ∀ i, leftBound i + rightBound i ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)

theorem operand_bound (left right : Fin n → Value) (bounds : Bounds left right) (i : Fin n) :
    |Model.toReal (left i)| + |Model.toReal (right i)| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16) :=
  (add_le_add (bounds.leftMagnitude i) (bounds.rightMagnitude i)).trans (bounds.capacity i)

theorem forward_finite (left right : Fin n → Value) (bounds : Bounds left right) (i : Fin n) :
    Model.isFinite (forward left right i) = true :=
  BFloat16Arithmetic.add_finite _ _ (bounds.leftFinite i) (bounds.rightFinite i) (operand_bound left right bounds i)

theorem forward_error (left right : Fin n → Value) (bounds : Bounds left right)
    (leftTarget rightTarget leftError rightError : Fin n → ℝ)
    (hl : ∀ i, |Model.toReal (left i) - leftTarget i| ≤ leftError i)
    (hr : ∀ i, |Model.toReal (right i) - rightTarget i| ≤ rightError i) (i : Fin n) :
    |Model.toReal (forward left right i) - (leftTarget i + rightTarget i)| ≤ budget left right leftError rightError i := by
  have localError := BFloat16Arithmetic.add_error (left i) (right i) (bounds.leftFinite i) (bounds.rightFinite i)
    (BFloat16Arithmetic.raw_add_finite _ _ (bounds.leftFinite i) (bounds.rightFinite i) (operand_bound left right bounds i))
  unfold forward budget
  calc
    _ = |(Model.toReal (BFloat16Arithmetic.add (left i) (right i)) - (Model.toReal (left i) + Model.toReal (right i))) +
      ((Model.toReal (left i) - leftTarget i) + (Model.toReal (right i) - rightTarget i))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add localError ((abs_add_le _ _).trans (add_le_add (hl i) (hr i))))
      linarith

theorem forward_bound (left right : Fin n → Value) (bounds : Bounds left right) (i : Fin n) :
    |Model.toReal (forward left right i)| ≤ bounds.leftBound i + bounds.rightBound i +
      BFloat16Arithmetic.addBudget (left i) (right i) := by
  have he := forward_error left right bounds (fun j => Model.toReal (left j))
    (fun j => Model.toReal (right j)) (fun _ => 0) (fun _ => 0) (by intro j; simp) (by intro j; simp) i
  simp only [budget, add_zero] at he
  calc
    _ = |(Model.toReal (forward left right i) - (Model.toReal (left i) + Model.toReal (right i))) +
      (Model.toReal (left i) + Model.toReal (right i))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add he
        ((abs_add_le _ _).trans (add_le_add (bounds.leftMagnitude i) (bounds.rightMagnitude i))))
      linarith

-- Ownership permits any order of distinct output cells. The right-hand
-- input is held fixed throughout this phase, as required by donation rules.
def inPlace (left right : Nat → Value) (schedule : List Nat) : Nat → Value :=
  Memory.mapCells (fun index value => BFloat16Arithmetic.add value (right index)) schedule left

theorem inPlace_read (left right : Nat → Value) (schedule : List Nat) (unique : schedule.Nodup) (index : Nat) :
    inPlace left right schedule index =
      if index ∈ schedule then BFloat16Arithmetic.add (left index) (right index) else left index :=
  Memory.mapCells_read _ _ _ unique index

end Inference.Contracts.Mlx.ElementwiseAdd
