import kernels.delta.Gates

namespace Inference.Kernels.Delta.Softplus
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx.BFloat16Arithmetic
open Trellis.GateUpSplitTail (zero negative negative_iff)

-- Finite-input branch of MLX 0.32.2 LogAddExp(x, 0). Every arithmetic
-- operation here has bf16 storage and the explicit flush/round model.
def top (x : Value) : Value := if negative x then zero else x
def bottom (x : Value) : Value := if negative x then x else zero
def difference (x : Value) : Value := sub (bottom x) (top x)
def value (exp log1p : Value → Value) (x : Value) : Value :=
  add (top x) (log1p (exp (difference x)))

-- These contracts cover scalar library primitives only. The composite
-- softplus error is derived below from their bounds and rounded arithmetic.
structure ExpContract (exp : Value → Value) (error : Value → ℝ) : Prop where
  nonnegative : ∀ x, Model.isFinite x = true → Model.isFinite (exp x) = true → 0 ≤ Model.toReal (exp x)
  accuracy : ∀ x, Model.isFinite x = true → Model.isFinite (exp x) = true →
    |Model.toReal (exp x) - Real.exp (Model.toReal x)| ≤ error x

structure Log1pContract (log1p : Value → Value) (error : Value → ℝ) : Prop where
  nonnegative : ∀ x, Model.isFinite x = true → 0 ≤ Model.toReal x →
    Model.isFinite (log1p x) = true → 0 ≤ Model.toReal (log1p x)
  accuracy : ∀ x, Model.isFinite x = true → 0 ≤ Model.toReal x →
    Model.isFinite (log1p x) = true → |Model.toReal (log1p x) - Real.log (1 + Model.toReal x)| ≤ error x

structure Finite (exp log1p : Value → Value) (x : Value) : Prop where
  input : Model.isFinite x = true
  exponential : Model.isFinite (exp (difference x)) = true
  logarithm : Model.isFinite (log1p (exp (difference x))) = true
  addition : Model.isFinite (Model.add (flush (top x)) (flush (log1p (exp (difference x))))) = true

theorem top_finite (x : Value) (hx : Model.isFinite x = true) : Model.isFinite (top x) = true := by
  unfold top
  split
  · decide
  · exact hx

theorem bottom_finite (x : Value) (hx : Model.isFinite x = true) : Model.isFinite (bottom x) = true := by
  unfold bottom
  split
  · exact hx
  · decide

-- Only one of min(x, 0), max(x, 0) can be nonzero. Thus subtraction
-- cannot overflow for any finite input, even at the format endpoints.
theorem raw_difference_finite (x : Value) (hx : Model.isFinite x = true) :
    Model.isFinite (Model.sub (flush (bottom x)) (flush (top x))) = true := by
  apply Model.isFinite_sub_of_abs_add_le_posMaxFinite _ _ (by decide)
    (finite_flush _ (bottom_finite x hx)) (finite_flush _ (top_finite x hx))
  have hm : |Model.toReal (bottom x)| + |Model.toReal (top x)| = |Model.toReal x| := by
    unfold bottom top
    split <;> simp only [zero, Model.toReal_zero, abs_zero, add_zero, zero_add]
  exact ((add_le_add (flush_abs_le (bottom x)) (flush_abs_le (top x))).trans_eq hm).trans
    (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite x (by decide) hx)

theorem top_real (x : Value) (hx : Model.isFinite x = true) : Model.toReal (top x) = max (Model.toReal x) 0 := by
  unfold top
  by_cases hn : negative x
  · simp only [hn, ite_true, zero, Model.toReal_zero, max_eq_right ((negative_iff x hx).mp hn).le]
  · have h := le_of_not_gt (mt (negative_iff x hx).mpr hn)
    simp only [hn, ite_false, max_eq_left h]

theorem bottom_real (x : Value) (hx : Model.isFinite x = true) : Model.toReal (bottom x) = min (Model.toReal x) 0 := by
  unfold bottom
  by_cases hn : negative x
  · simp only [hn, ite_true, min_eq_left ((negative_iff x hx).mp hn).le]
  · have h := le_of_not_gt (mt (negative_iff x hx).mpr hn)
    simp only [hn, ite_false, zero, Model.toReal_zero, min_eq_right h]

theorem difference_target (x : Value) (hx : Model.isFinite x = true) :
    Model.toReal (bottom x) - Model.toReal (top x) = -|Model.toReal x| := by
  rw [top_real x hx, bottom_real x hx]
  by_cases hn : 0 ≤ Model.toReal x
  · rw [min_eq_right hn, max_eq_left hn, abs_of_nonneg hn, zero_sub]
  · have hn' := le_of_lt (lt_of_not_ge hn)
    rw [min_eq_left hn', max_eq_right hn', abs_of_nonpos hn', neg_neg, sub_zero]

theorem difference_finite (exp log1p : Value → Value) (x : Value) (hf : Finite exp log1p x) :
    Model.isFinite (difference x) = true := finite_flush _ (raw_difference_finite x hf.input)

theorem difference_nonpositive (exp log1p : Value → Value) (x : Value) (hf : Finite exp log1p x) :
    Model.toReal (difference x) ≤ 0 := by
  apply sub_nonpositive _ _ (bottom_finite x hf.input) (top_finite x hf.input) _ _ (raw_difference_finite x hf.input)
  · rw [bottom_real x hf.input]; exact min_le_right _ _
  · rw [top_real x hf.input]; exact le_max_right _ _

theorem difference_error (exp log1p : Value → Value) (x : Value) (hf : Finite exp log1p x) :
    |Model.toReal (difference x) - (-|Model.toReal x|)| ≤ subBudget (bottom x) (top x) := by
  have h := sub_error (bottom x) (top x) (bottom_finite x hf.input) (top_finite x hf.input) (raw_difference_finite x hf.input)
  rw [difference_target x hf.input] at h
  exact h

noncomputable def expBudget (expError : Value → ℝ) (x : Value) : ℝ :=
  expError (difference x) + subBudget (bottom x) (top x)
noncomputable def logBudget (exp : Value → Value) (expError logError : Value → ℝ) (x : Value) : ℝ :=
  logError (exp (difference x)) + expBudget expError x
noncomputable def budget (exp log1p : Value → Value) (expError logError : Value → ℝ) (x : Value) : ℝ :=
  addBudget (top x) (log1p (exp (difference x))) + logBudget exp expError logError x

theorem exp_error (exp log1p : Value → Value) (expError : Value → ℝ)
    (he : ExpContract exp expError) (x : Value) (hf : Finite exp log1p x) :
    |Model.toReal (exp (difference x)) - Real.exp (-|Model.toReal x|)| ≤ expBudget expError x := by
  have hp := he.accuracy (difference x) (difference_finite exp log1p x hf) hf.exponential
  have hs := (Gates.exp_nonpos_lipschitz (-|Model.toReal x|) (Model.toReal (difference x))
    (neg_nonpos.mpr (abs_nonneg _)) (difference_nonpositive exp log1p x hf)).trans (difference_error exp log1p x hf)
  calc
    _ = |(Model.toReal (exp (difference x)) - Real.exp (Model.toReal (difference x))) +
      (Real.exp (Model.toReal (difference x)) - Real.exp (-|Model.toReal x|))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hp hs)

theorem log_error (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite exp log1p x) :
    |Model.toReal (log1p (exp (difference x))) - Real.log (1 + Real.exp (-|Model.toReal x|))| ≤ logBudget exp expError logError x := by
  have hn := he.nonnegative (difference x) (difference_finite exp log1p x hf) hf.exponential
  have hp := hl.accuracy (exp (difference x)) hf.exponential hn hf.logarithm
  have hs := (Gates.log1p_lipschitz (Real.exp (-|Model.toReal x|)) (Model.toReal (exp (difference x)))
    (Real.exp_pos _).le hn).trans (exp_error exp log1p expError he x hf)
  calc
    _ = |(Model.toReal (log1p (exp (difference x))) - Real.log (1 + Model.toReal (exp (difference x)))) +
      (Real.log (1 + Model.toReal (exp (difference x))) - Real.log (1 + Real.exp (-|Model.toReal x|)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hp hs)

theorem value_error (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite exp log1p x) :
    |Model.toReal (value exp log1p x) - Gates.softplus (Model.toReal x)| ≤ budget exp log1p expError logError x := by
  have ha := add_error (top x) (log1p (exp (difference x))) (top_finite x hf.input) hf.logarithm hf.addition
  have hl' := log_error exp log1p expError logError he hl x hf
  rw [← Gates.stable_softplus]
  unfold Gates.stableSoftplus budget value
  rw [← top_real x hf.input]
  calc
    _ = |(Model.toReal (add (top x) (log1p (exp (difference x)))) -
      (Model.toReal (top x) + Model.toReal (log1p (exp (difference x))))) +
      (Model.toReal (log1p (exp (difference x))) - Real.log (1 + Real.exp (-|Model.toReal x|)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ha hl')

theorem value_nonnegative (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite exp log1p x) :
    0 ≤ Model.toReal (value exp log1p x) := by
  apply add_nonnegative _ _ (top_finite x hf.input) hf.logarithm _ _ hf.addition
  · rw [top_real x hf.input]; exact le_max_right _ _
  · exact hl.nonnegative _ hf.exponential
      (he.nonnegative _ (difference_finite exp log1p x hf) hf.exponential) hf.logarithm

theorem value_finite (exp log1p : Value → Value) (x : Value) (hf : Finite exp log1p x) :
    Model.isFinite (value exp log1p x) = true := finite_flush _ hf.addition

end Inference.Kernels.Delta.Softplus
