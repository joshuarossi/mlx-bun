import kernels.delta.Gates

namespace Inference.Kernels.Delta.Softplus
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx.BFloat16Arithmetic
open Trellis.GateUpSplitTail (zero negative negative_iff)
open Contracts.Mlx.FlushToZero (threshold threshold_pos)


-- metal::max/min remain scalar compiler primitives comparing flushed
-- operands. These flags specify their equal-operand choice, including
-- distinct signed-zero and subnormal bit patterns. Every proof below holds
-- for each choice; no claim about the installed compiler's ties is made.
structure Policy where
  maximumLeft : Bool
  minimumLeft : Bool
  deriving DecidableEq,Repr

def maximum (leftTie : Bool) (x y : Value) : Value :=
  if Model.compare (flush x) (flush y)=some .lt then y else
    if Model.compare (flush x) (flush y)=some .gt then x else if leftTie then x else y
def minimum (leftTie : Bool) (x y : Value) : Value :=
  if Model.compare (flush x) (flush y)=some .lt then x else
    if Model.compare (flush x) (flush y)=some .gt then y else if leftTie then x else y

-- Finite-input branch of MLX 0.32.2 LogAddExp(x, 0). Every arithmetic
-- operation here has bf16 storage and the explicit flush/round model.
def top (policy : Policy) (x : Value) : Value := maximum policy.maximumLeft x zero
def bottom (policy : Policy) (x : Value) : Value := minimum policy.minimumLeft x zero
def difference (policy : Policy) (x : Value) : Value := sub (bottom policy x) (top policy x)
def value (policy : Policy) (exp log1p : Value → Value) (x : Value) : Value :=
  add (top policy x) (log1p (exp (difference policy x)))

-- These contracts cover scalar library primitives only. The composite
-- softplus error is derived below from their bounds and rounded arithmetic.
structure ExpContract (exp : Value → Value) (error : Value → ℝ) : Prop where
  nonnegative : ∀ x, Model.isFinite x = true → Model.isFinite (exp x) = true → 0 ≤ Model.toReal (exp x)
  accuracy : ∀ x, Model.isFinite x = true → Model.isFinite (exp x) = true →
    |Model.toReal (exp x) - Real.exp (Model.toReal x)| ≤ error x

structure Log1pContract (log1p : Value → Value) (error : Value → ℝ) : Prop where
  accuracy : ∀ x, Model.isFinite x = true → 0 ≤ Model.toReal x →
    Model.isFinite (log1p x) = true → |Model.toReal (log1p x) - Real.log (1 + Model.toReal x)| ≤ error x

structure Finite (policy : Policy) (exp log1p : Value → Value) (x : Value) : Prop where
  input : Model.isFinite x = true
  exponential : Model.isFinite (exp (difference policy x)) = true
  logarithm : Model.isFinite (log1p (exp (difference policy x))) = true
  addition : Model.isFinite (Model.add (flush (top policy x)) (flush (log1p (exp (difference policy x))))) = true
  -- Range fact of the reached log1p call (SoftplusRanges), not a library contract.
  nonnegative : 0 ≤ Model.toReal (log1p (exp (difference policy x)))

-- The selection compares the flushed input, so its flushed result is exact.
theorem flush_zero : flush (Model.zero FloatFormat.bfloat16 false) = Model.zero FloatFormat.bfloat16 false := by
  decide

theorem real_zero : Model.toReal zero = 0 := Model.toReal_zero _ _

-- Against zero, the flushed comparison is decided by the flushed real value;
-- an equal comparison has a zero flushed operand, whichever operand is kept.
theorem select (leftTie : Bool) (x : Value) (hx : Model.isFinite x = true) :
    maximum leftTie x zero = (if Model.toReal (flush x) < 0 then zero else
      if 0 < Model.toReal (flush x) then x else if leftTie then x else zero) ∧
    minimum leftTie x zero = (if Model.toReal (flush x) < 0 then x else
      if 0 < Model.toReal (flush x) then zero else if leftTie then x else zero) := by
  have hf := finite_flush x hx
  have hz : Model.isFinite (flush zero) = true := by rw [zero, flush_zero]; decide
  have lt := Model.compare_eq_some_lt_iff_toReal_lt_of_isFinite (flush x) (flush zero) hf hz
  have gt := Model.compare_eq_some_gt_iff_toReal_gt_of_isFinite (flush x) (flush zero) hf hz
  have hr : Model.toReal (flush zero) = 0 := by rw [zero, flush_zero]; exact Model.toReal_zero _ _
  rw [hr] at lt gt
  unfold maximum minimum
  by_cases h1 : Model.toReal (flush x) < 0
  · exact ⟨by rw [if_pos (lt.mpr h1), if_pos h1], by rw [if_pos (lt.mpr h1), if_pos h1]⟩
  · have n1 : Model.compare (flush x) (flush zero) ≠ some .lt := fun e => h1 (lt.mp e)
    by_cases h2 : 0 < Model.toReal (flush x)
    · exact ⟨by rw [if_neg n1, if_pos (gt.mpr h2), if_neg h1, if_pos h2],
        by rw [if_neg n1, if_pos (gt.mpr h2), if_neg h1, if_pos h2]⟩
    · have n2 : Model.compare (flush x) (flush zero) ≠ some .gt := fun e => h2 (gt.mp e)
      exact ⟨by rw [if_neg n1, if_neg n2, if_neg h1, if_neg h2],
        by rw [if_neg n1, if_neg n2, if_neg h1, if_neg h2]⟩

theorem top_mem (policy : Policy) (x : Value) : top policy x = x ∨ top policy x = zero := by
  unfold top maximum
  split
  · exact Or.inr rfl
  · split
    · exact Or.inl rfl
    · split
      · exact Or.inl rfl
      · exact Or.inr rfl

theorem bottom_mem (policy : Policy) (x : Value) : bottom policy x = x ∨ bottom policy x = zero := by
  unfold bottom minimum
  split
  · exact Or.inl rfl
  · split
    · exact Or.inr rfl
    · split
      · exact Or.inl rfl
      · exact Or.inr rfl

theorem top_finite (policy : Policy) (x : Value) (hx : Model.isFinite x = true) : Model.isFinite (top policy x) = true := by
  rcases top_mem policy x with e | e <;> rw [e]
  · exact hx
  · decide

theorem bottom_finite (policy : Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.isFinite (bottom policy x) = true := by
  rcases bottom_mem policy x with e | e <;> rw [e]
  · exact hx
  · decide

theorem flush_zero_real : Model.toReal (flush zero) = 0 := by rw [zero, flush_zero]; exact Model.toReal_zero _ _

theorem top_real (policy : Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.toReal (flush (top policy x)) = max (Model.toReal (flush x)) 0 := by
  unfold top
  rw [(select _ x hx).1]
  by_cases h1 : Model.toReal (flush x) < 0
  · simp only [h1, ite_true, flush_zero_real, max_eq_right h1.le]
  · by_cases h2 : 0 < Model.toReal (flush x)
    · simp only [h1, h2, ite_true, ite_false, max_eq_left h2.le]
    · have h0 : Model.toReal (flush x) = 0 := by linarith [not_lt.mp h1, not_lt.mp h2]
      simp only [h1, h2, ite_false]
      split <;> simp only [h0, flush_zero_real, max_self]

theorem bottom_real (policy : Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.toReal (flush (bottom policy x)) = min (Model.toReal (flush x)) 0 := by
  unfold bottom
  rw [(select _ x hx).2]
  by_cases h1 : Model.toReal (flush x) < 0
  · simp only [h1, ite_true, min_eq_left h1.le]
  · by_cases h2 : 0 < Model.toReal (flush x)
    · simp only [h1, h2, ite_true, ite_false, flush_zero_real, min_eq_right h2.le]
    · have h0 : Model.toReal (flush x) = 0 := by linarith [not_lt.mp h1, not_lt.mp h2]
      simp only [h1, h2, ite_false]
      split <;> simp only [h0, flush_zero_real, min_self]

-- Only one of min(x, 0), max(x, 0) can be nonzero. Thus subtraction
-- cannot overflow for any finite input, even at the format endpoints.
theorem raw_difference_finite (policy : Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.isFinite (Model.sub (flush (bottom policy x)) (flush (top policy x))) = true := by
  apply Model.isFinite_sub_of_abs_add_le_posMaxFinite _ _ (by decide)
    (finite_flush _ (bottom_finite policy x hx)) (finite_flush _ (top_finite policy x hx))
  have hm : |Model.toReal (flush (bottom policy x))| + |Model.toReal (flush (top policy x))| = |Model.toReal (flush x)| := by
    rw [top_real policy x hx, bottom_real policy x hx]
    rcases le_total (Model.toReal (flush x)) 0 with h | h
    · rw [min_eq_left h, max_eq_right h, abs_zero, add_zero]
    · rw [min_eq_right h, max_eq_left h, abs_zero, zero_add]
  exact (hm.trans_le (flush_abs_le x)).trans
    (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite x (by decide) hx)

theorem difference_target (policy : Policy) (x : Value) (hx : Model.isFinite x = true) :
    Model.toReal (flush (bottom policy x)) - Model.toReal (flush (top policy x)) = -|Model.toReal (flush x)| := by
  rw [top_real policy x hx, bottom_real policy x hx]
  by_cases hn : 0 ≤ Model.toReal (flush x)
  · rw [min_eq_right hn, max_eq_left hn, abs_of_nonneg hn, zero_sub]
  · have hn' := le_of_lt (lt_of_not_ge hn)
    rw [min_eq_left hn', max_eq_right hn', abs_of_nonpos hn', neg_neg, sub_zero]

theorem difference_finite (policy : Policy) (exp log1p : Value → Value) (x : Value) (hf : Finite policy exp log1p x) :
    Model.isFinite (difference policy x) = true := finite_flush _ (raw_difference_finite policy x hf.input)

theorem difference_nonpositive (policy : Policy) (exp log1p : Value → Value) (x : Value) (hf : Finite policy exp log1p x) :
    Model.toReal (difference policy x) ≤ 0 := by
  apply sub_nonpositive_flushed _ _ (bottom_finite policy x hf.input) (top_finite policy x hf.input) _ _ (raw_difference_finite policy x hf.input)
  · rw [bottom_real policy x hf.input]; exact min_le_right _ _
  · rw [top_real policy x hf.input]; exact le_max_right _ _

theorem difference_error (policy : Policy) (exp log1p : Value → Value) (x : Value) (hf : Finite policy exp log1p x) :
    |Model.toReal (difference policy x) - (-|Model.toReal x|)| ≤ subBudget (bottom policy x) (top policy x) := by
  have h := sub_error_flushed (bottom policy x) (top policy x) (bottom_finite policy x hf.input) (top_finite policy x hf.input)
    (raw_difference_finite policy x hf.input)
  have hx : |-|Model.toReal (flush x)|-(-|Model.toReal x|)| ≤ threshold := by
    rw [neg_sub_neg, abs_sub_comm]
    exact (abs_abs_sub_abs_le_abs_sub _ _).trans (flush_error x)
  unfold subBudget difference
  rw [difference_target policy x hf.input] at h ⊢

  calc
    _ = |(Model.toReal (sub (bottom policy x) (top policy x))-(-|Model.toReal (flush x)|))+(-|Model.toReal (flush x)|-(-|Model.toReal x|))| := by

      congr 1; ring
    _ ≤ _ := by
      have := (abs_add_le _ _).trans (add_le_add h hx)
      linarith [threshold_pos]

noncomputable def expBudget (policy : Policy) (expError : Value → ℝ) (x : Value) : ℝ :=
  expError (difference policy x) + subBudget (bottom policy x) (top policy x)
noncomputable def logBudget (policy : Policy) (exp : Value → Value) (expError logError : Value → ℝ) (x : Value) : ℝ :=
  logError (exp (difference policy x)) + expBudget policy expError x
noncomputable def budget (policy : Policy) (exp log1p : Value → Value) (expError logError : Value → ℝ) (x : Value) : ℝ :=
  addBudget (top policy x) (log1p (exp (difference policy x))) + logBudget policy exp expError logError x

theorem exp_error (policy : Policy) (exp log1p : Value → Value) (expError : Value → ℝ)
    (he : ExpContract exp expError) (x : Value) (hf : Finite policy exp log1p x) :
    |Model.toReal (exp (difference policy x)) - Real.exp (-|Model.toReal x|)| ≤ expBudget policy expError x := by
  have hp := he.accuracy (difference policy x) (difference_finite policy exp log1p x hf) hf.exponential
  have hs := (Gates.exp_nonpos_lipschitz (-|Model.toReal x|) (Model.toReal (difference policy x))
    (neg_nonpos.mpr (abs_nonneg _)) (difference_nonpositive policy exp log1p x hf)).trans (difference_error policy exp log1p x hf)
  calc
    _ = |(Model.toReal (exp (difference policy x)) - Real.exp (Model.toReal (difference policy x))) +
      (Real.exp (Model.toReal (difference policy x)) - Real.exp (-|Model.toReal x|))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hp hs)

theorem log_error (policy : Policy) (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite policy exp log1p x) :
    |Model.toReal (log1p (exp (difference policy x))) - Real.log (1 + Real.exp (-|Model.toReal x|))| ≤ logBudget policy exp expError logError x := by
  have hn := he.nonnegative (difference policy x) (difference_finite policy exp log1p x hf) hf.exponential
  have hp := hl.accuracy (exp (difference policy x)) hf.exponential hn hf.logarithm
  have hs := (Gates.log1p_lipschitz (Real.exp (-|Model.toReal x|)) (Model.toReal (exp (difference policy x)))
    (Real.exp_pos _).le hn).trans (exp_error policy exp log1p expError he x hf)
  calc
    _ = |(Model.toReal (log1p (exp (difference policy x))) - Real.log (1 + Model.toReal (exp (difference policy x)))) +
      (Real.log (1 + Model.toReal (exp (difference policy x))) - Real.log (1 + Real.exp (-|Model.toReal x|)))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hp hs)

theorem value_error (policy : Policy) (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite policy exp log1p x) :
    |Model.toReal (value policy exp log1p x) - Gates.softplus (Model.toReal x)| ≤ budget policy exp log1p expError logError x := by
  have ha := add_error_flushed (top policy x) (log1p (exp (difference policy x))) (top_finite policy x hf.input) hf.logarithm hf.addition
  have hl' := log_error policy exp log1p expError logError he hl x hf
  have ht : |max (Model.toReal (flush x)) 0-max (Model.toReal x) 0| ≤ threshold :=
    (abs_max_sub_max_le_abs _ _ _).trans (flush_error x)
  have hf' := flush_error (log1p (exp (difference policy x)))
  rw [← Gates.stable_softplus]
  unfold Gates.stableSoftplus budget value addBudget
  rw [top_real policy x hf.input] at ha ⊢
  calc
    _ = |(Model.toReal (add (top policy x) (log1p (exp (difference policy x)))) -
      (max (Model.toReal (flush x)) 0 + Model.toReal (flush (log1p (exp (difference policy x)))))) +
      ((max (Model.toReal (flush x)) 0-max (Model.toReal x) 0) +
      ((Model.toReal (flush (log1p (exp (difference policy x))))-Model.toReal (log1p (exp (difference policy x)))) +
      (Model.toReal (log1p (exp (difference policy x))) - Real.log (1 + Real.exp (-|Model.toReal x|)))))| := by congr 1; ring
    _ ≤ _ := by
      have := (abs_add_le _ _).trans (add_le_add ha ((abs_add_le _ _).trans (add_le_add ht
        ((abs_add_le _ _).trans (add_le_add hf' hl')))))
      linarith

theorem value_nonnegative (policy : Policy) (exp log1p : Value → Value) (expError logError : Value → ℝ)
    (he : ExpContract exp expError) (hl : Log1pContract log1p logError) (x : Value) (hf : Finite policy exp log1p x) :
    0 ≤ Model.toReal (value policy exp log1p x) := by
  apply add_nonnegative_flushed _ _ (top_finite policy x hf.input) hf.logarithm _ _ hf.addition
  · rw [top_real policy x hf.input]; exact le_max_right _ _
  · exact flush_nonnegative _ hf.nonnegative


theorem value_finite (policy : Policy) (exp log1p : Value → Value) (x : Value) (hf : Finite policy exp log1p x) :
    Model.isFinite (value policy exp log1p x) = true := finite_flush _ hf.addition

end Inference.Kernels.Delta.Softplus
