import contracts.mlx.FlushToZero
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Constants
import FloatLib.Floats.Formats.BinaryInterchange.Operations.Classification.Semantics

namespace Inference.Contracts.Mlx.BFloat16Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FlushToZero (threshold threshold_pos)

abbrev Value := Model FloatFormat.bfloat16
noncomputable abbrev epsilon (x : ℝ) := Model.epsilonAt FloatFormat.bfloat16 x
def one : Value := Model.posOne FloatFormat.bfloat16
def flush (x : Value) : Value := if Model.isSubnormal x then Model.zero _ (Model.signBit x) else x
def add (x y : Value) : Value := flush (Model.add (flush x) (flush y))
def sub (x y : Value) : Value := flush (Model.sub (flush x) (flush y))
def mul (x y : Value) : Value := flush (Model.mul (flush x) (flush y))
def div (x y : Value) : Value := flush (Model.div (flush x) (flush y))

theorem real_one : Model.toReal one = 1 := Model.toReal_posOne _
theorem finite_one : Model.isFinite one = true := Model.isFinite_posOne _

theorem finite_flush (x : Value) (h : Model.isFinite x = true) : Model.isFinite (flush x) = true := by
  unfold flush
  split
  · cases Model.signBit x <;> decide
  · exact h

theorem flush_error (x : Value) : |Model.toReal (flush x)-Model.toReal x| ≤ threshold := by
  unfold flush
  split
  · rename_i hs
    rw [Model.toReal_zero, zero_sub, abs_neg]
    exact ((Model.isSubnormal_iff_abs_toReal x).mp hs).2.2.le
  · simpa using threshold_pos.le

theorem flush_abs_le (x : Value) : |Model.toReal (flush x)| ≤ |Model.toReal x| := by
  unfold flush
  split
  · rw [Model.toReal_zero, abs_zero]
    exact abs_nonneg _
  · exact le_refl _

theorem flush_nonnegative (x : Value) (h : 0 ≤ Model.toReal x) : 0 ≤ Model.toReal (flush x) := by
  unfold flush
  split
  · rw [Model.toReal_zero]
  · exact h

theorem flush_nonpositive (x : Value) (h : Model.toReal x ≤ 0) : Model.toReal (flush x) ≤ 0 := by
  unfold flush
  split
  · rw [Model.toReal_zero]
  · exact h

theorem add_nonnegative (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hxn : 0 ≤ Model.toReal x) (hyn : 0 ≤ Model.toReal y)
    (ho : Model.isFinite (Model.add (flush x) (flush y)) = true) :
    0 ≤ Model.toReal (add x y) := by
  apply flush_nonnegative
  rw [Model.toReal_add_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho]
  have h := Model.roundAt_mono FloatFormat.bfloat16 (add_nonneg (flush_nonnegative x hxn) (flush_nonnegative y hyn))
  simpa only [Model.roundAt_zero] using h

theorem sub_nonpositive (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hxn : Model.toReal x ≤ 0) (hyn : 0 ≤ Model.toReal y)
    (ho : Model.isFinite (Model.sub (flush x) (flush y)) = true) :
    Model.toReal (sub x y) ≤ 0 := by
  apply flush_nonpositive
  rw [Model.toReal_sub_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho]
  have h := Model.roundAt_mono FloatFormat.bfloat16
    (sub_nonpos.mpr (le_trans (flush_nonpositive x hxn) (flush_nonnegative y hyn)))
  simpa only [Model.roundAt_zero] using h

theorem flush_eq_of_one_le (x : Value) (h : 1 ≤ Model.toReal x) : flush x = x := by
  unfold flush
  split
  · rename_i hs
    have hb := ((Model.isSubnormal_iff_abs_toReal x).mp hs).2.2
    change |Model.toReal x| < threshold at hb
    have ht : threshold < 1 := by norm_num [threshold]
    rw [abs_of_nonneg (by linarith)] at hb
    linarith
  · rfl

theorem flush_one : flush one = one := flush_eq_of_one_le one (by rw [real_one])

noncomputable def addBudget (x y : Value) : ℝ :=
  3*threshold + epsilon (Model.toReal (flush x)+Model.toReal (flush y))
noncomputable def subBudget (x y : Value) : ℝ :=
  3*threshold + epsilon (Model.toReal (flush x)-Model.toReal (flush y))
noncomputable def mulBudget (x y : Value) : ℝ :=
  threshold + epsilon (Model.toReal (flush x)*Model.toReal (flush y)) + threshold*(|Model.toReal x|+|Model.toReal y|)

-- Derive absence of addition overflow from operand bounds. Callers can carry
-- these bounds across layer contracts without inspecting execution results.
theorem raw_add_finite (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (bound : |Model.toReal x| + |Model.toReal y| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    Model.isFinite (Model.add (flush x) (flush y)) = true := by
  apply Model.isFinite_add_of_abs_add_le_posMaxFinite _ _ (by decide) (finite_flush x hx) (finite_flush y hy)
  exact (add_le_add (flush_abs_le x) (flush_abs_le y)).trans bound

theorem add_finite (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (bound : |Model.toReal x| + |Model.toReal y| ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    Model.isFinite (add x y) = true := finite_flush _ (raw_add_finite x y hx hy bound)

theorem add_error (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.add (flush x) (flush y))=true) :
    |Model.toReal (add x y)-(Model.toReal x+Model.toReal y)| ≤ addBudget x y := by
  have eo := flush_error (Model.add (flush x) (flush y))
  have er := Model.abs_toReal_add_sub_le (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) ho
  have ex := flush_error x
  have ey := flush_error y
  unfold add addBudget
  calc
    _ = |(Model.toReal (flush (Model.add (flush x) (flush y)))-Model.toReal (Model.add (flush x) (flush y))) +
        ((Model.toReal (Model.add (flush x) (flush y))-(Model.toReal (flush x)+Model.toReal (flush y))) +
          ((Model.toReal (flush x)-Model.toReal x)+(Model.toReal (flush y)-Model.toReal y)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_add_le _ _).trans (add_le_add ex ey)))))
      linarith

theorem sub_error (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.sub (flush x) (flush y))=true) :
    |Model.toReal (sub x y)-(Model.toReal x-Model.toReal y)| ≤ subBudget x y := by
  have eo := flush_error (Model.sub (flush x) (flush y))
  have er := Model.abs_toReal_sub_sub_le (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) ho
  have ex := flush_error x
  have ey := flush_error y
  unfold sub subBudget
  calc
    _ = |(Model.toReal (flush (Model.sub (flush x) (flush y)))-Model.toReal (Model.sub (flush x) (flush y))) +
        ((Model.toReal (Model.sub (flush x) (flush y))-(Model.toReal (flush x)-Model.toReal (flush y))) +
          ((Model.toReal (flush x)-Model.toReal x)-(Model.toReal (flush y)-Model.toReal y)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_sub _ _).trans (add_le_add ex ey)))))
      linarith

theorem mul_error (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.mul (flush x) (flush y))=true) :
    |Model.toReal (mul x y)-Model.toReal x*Model.toReal y| ≤ mulBudget x y := by
  have eo := flush_error (Model.mul (flush x) (flush y))
  have er := Model.abs_toReal_mul_sub_le (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) ho
  have ex := mul_le_mul_of_nonneg_right (flush_error x) (abs_nonneg (Model.toReal y))
  have ey := mul_le_mul_of_nonneg_left (flush_error y) (abs_nonneg (Model.toReal (flush x)))
  have hx' := mul_le_mul_of_nonneg_right (flush_abs_le x) threshold_pos.le
  have ei : |Model.toReal (flush x)*Model.toReal (flush y)-Model.toReal x*Model.toReal y| ≤ threshold*(|Model.toReal x|+|Model.toReal y|) := by
    calc
      _ = |Model.toReal (flush x)*(Model.toReal (flush y)-Model.toReal y)+(Model.toReal (flush x)-Model.toReal x)*Model.toReal y| := by congr 1; ring
      _ ≤ _ := by
        have h := abs_add_le (Model.toReal (flush x)*(Model.toReal (flush y)-Model.toReal y)) ((Model.toReal (flush x)-Model.toReal x)*Model.toReal y)
        simp only [abs_mul] at h
        nlinarith
  unfold mul mulBudget
  calc
    _ = |(Model.toReal (flush (Model.mul (flush x) (flush y)))-Model.toReal (Model.mul (flush x) (flush y))) +
        ((Model.toReal (Model.mul (flush x) (flush y))-Model.toReal (flush x)*Model.toReal (flush y)) +
          (Model.toReal (flush x)*Model.toReal (flush y)-Model.toReal x*Model.toReal y))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er ei)))
      linarith

theorem add_one_ge_one (x : Value) (hx : Model.isFinite x=true) (hn : 0 ≤ Model.toReal x)
    (ho : Model.isFinite (Model.add one (flush x))=true) : 1 ≤ Model.toReal (add one x) := by
  have hm := Model.roundAt_mono FloatFormat.bfloat16
    (show (1 : ℝ) ≤ 1+Model.toReal (flush x) by have := flush_nonnegative x hn; linarith)
  have hr := Model.roundAt_toReal_eq one finite_one
  rw [real_one] at hr
  rw [hr] at hm
  have hs : 1 ≤ Model.toReal (Model.add one (flush x)) := by
    rw [Model.toReal_add_eq_roundAt one (flush x) (by decide) finite_one (finite_flush x hx) ho, real_one]
    exact hm
  unfold add
  rw [flush_one, flush_eq_of_one_le _ hs]
  exact hs

theorem reciprocal_error (x : Value) (hx : Model.isFinite x=true) (hn : 1 ≤ Model.toReal x)
    (ho : Model.isFinite (Model.div one x)=true) :
    |Model.toReal (div one x)-1/Model.toReal x| ≤ threshold + epsilon (1/Model.toReal x) := by
  have hz : Model.isZero x=false := by
    cases he : Model.isZero x
    · rfl
    · have h := Model.toReal_eq_zero_of_isZero x he
      linarith
  have er := Model.abs_toReal_div_sub_le one x (by decide) finite_one hx hz ho
  rw [real_one] at er
  have ef := flush_error (Model.div one x)
  unfold div
  rw [flush_one, flush_eq_of_one_le x hn]
  calc
    _ = |(Model.toReal (flush (Model.div one x))-Model.toReal (Model.div one x)) +
        (Model.toReal (Model.div one x)-1/Model.toReal x)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ef er)

end Inference.Contracts.Mlx.BFloat16Arithmetic
