import contracts.mlx.BFloat16Bounds

namespace Inference.Contracts.Mlx.BFloat16UnitInterval
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open BFloat16Arithmetic

theorem flush_interval (x : Value) (hx : 0 ≤ Model.toReal x ∧ Model.toReal x ≤ 1) :
    0 ≤ Model.toReal (flush x) ∧ Model.toReal (flush x) ≤ 1 := by
  refine ⟨flush_nonnegative x hx.1, ?_⟩
  exact (le_abs_self _).trans ((flush_abs_le x).trans (by rw [abs_of_nonneg hx.1]; exact hx.2))

theorem rounded_interval (x : ℝ) (hx : 0 ≤ x ∧ x ≤ 1) :
    0 ≤ Model.roundAt FloatFormat.bfloat16 x ∧ Model.roundAt FloatFormat.bfloat16 x ≤ 1 := by
  have lo := Model.roundAt_mono FloatFormat.bfloat16 hx.1
  have hi := Model.roundAt_mono FloatFormat.bfloat16 hx.2
  have oneRounded := Model.roundAt_toReal_eq one finite_one
  rw [real_one] at oneRounded
  simpa only [Model.roundAt_zero, oneRounded] using And.intro lo hi

-- A denominator at least one gives a finite reciprocal in [0,1], including
-- underflow and flushing. No finiteness premise is needed for the quotient.
theorem reciprocal (x : Value) (hx : Model.isFinite x = true) (lower : 1 ≤ Model.toReal x) :
    Model.isFinite (Model.div one x) = true ∧
    Model.isFinite (div one x) = true ∧
    (0 ≤ Model.toReal (div one x) ∧ Model.toReal (div one x) ≤ 1) := by
  have hp : 0 < Model.toReal x := by linarith
  have hz : Model.isZero x = false := by
    cases he : Model.isZero x
    · rfl
    · have h := Model.toReal_eq_zero_of_isZero x he
      linarith
  have interval : 0 ≤ (1 : ℝ) / Model.toReal x ∧ (1 : ℝ) / Model.toReal x ≤ 1 := by
    exact ⟨by positivity, (div_le_one hp).mpr lower⟩
  have bound : |Model.toReal one / Model.toReal x| ≤ Model.toReal one := by
    rw [real_one, abs_of_nonneg interval.1]
    exact interval.2
  have hf := Model.isFinite_div_of_abs_div_le_posMaxFinite one x (by decide)
    finite_one hx hz (bound.trans (BFloat16Bounds.ceiling_max one finite_one))
  have hr : Model.toReal (Model.div one x) = Model.roundAt FloatFormat.bfloat16 (1 / Model.toReal x) := by
    rw [Model.toReal_div_eq_roundAt one x (by decide) finite_one hx hz hf, real_one]
  have hi : 0 ≤ Model.toReal (Model.div one x) ∧ Model.toReal (Model.div one x) ≤ 1 := by
    rw [hr]
    exact rounded_interval _ interval
  refine ⟨hf, ?_, ?_⟩
  · unfold div
    rw [flush_one, flush_eq_of_one_le x lower]
    exact finite_flush _ hf
  · unfold div
    rw [flush_one, flush_eq_of_one_le x lower]
    exact flush_interval _ hi

-- The positive sigmoid branch computes 1-y. Cancellation makes the exact
-- result stay in [0,1], so an absolute-sum overflow premise is unnecessary.
theorem complement (x : Value) (hx : Model.isFinite x = true)
    (interval : 0 ≤ Model.toReal x ∧ Model.toReal x ≤ 1) :
    Model.isFinite (Model.sub (flush one) (flush x)) = true ∧
    Model.isFinite (sub one x) = true ∧
    (0 ≤ Model.toReal (sub one x) ∧ Model.toReal (sub one x) ≤ 1) := by
  have hi := flush_interval x interval
  have hd : 0 ≤ (1 : ℝ) - Model.toReal (flush x) ∧ (1 : ℝ) - Model.toReal (flush x) ≤ 1 := by
    constructor <;> linarith [hi.1, hi.2]
  have hb : |Model.toReal one - Model.toReal (flush x)| ≤ Model.toReal one := by
    rw [real_one, abs_of_nonneg hd.1]
    exact hd.2
  have hf := Model.isFinite_sub_of_abs_toReal_sub_le_posMaxFinite one (flush x) (by decide)
    finite_one (finite_flush x hx) (hb.trans (BFloat16Bounds.ceiling_max one finite_one))
  have hr : 0 ≤ Model.toReal (Model.sub one (flush x)) ∧ Model.toReal (Model.sub one (flush x)) ≤ 1 := by
    rw [Model.toReal_sub_eq_roundAt one (flush x) (by decide) finite_one (finite_flush x hx) hf, real_one]
    exact rounded_interval _ hd
  refine ⟨by simpa only [flush_one] using hf, ?_, ?_⟩
  · simpa only [sub, flush_one] using finite_flush _ hf
  · simpa only [sub, flush_one] using flush_interval _ hr

end Inference.Contracts.Mlx.BFloat16UnitInterval
