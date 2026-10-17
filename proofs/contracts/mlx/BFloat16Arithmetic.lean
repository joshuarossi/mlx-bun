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
-- Multiplication and division flush nonzero exact results below 2^-126
-- before rounding (FlushToZero.underflow).
@[irreducible] def flushExact (exact
 : Option (Int × Nat × Int)) (rounded : Value) : Value :=
  match FlushToZero.underflow exact with
  | some negative => Model.zero _ negative
  | none => rounded
def mul (x y : Value) : Value := flushExact (FlushToZero.mulExact (flush x) (flush y)) (Model.mul (flush x) (flush y))
def div (x y : Value) : Value := flushExact (FlushToZero.divExact (flush x) (flush y)) (Model.div (flush x) (flush y))

theorem flushExact_cases (exact : Option (Int × Nat × Int)) (r : Value) :
    flushExact exact r = r ∨ Model.toReal (flushExact exact r) = 0 := by
  unfold flushExact
  split
  · exact Or.inr (Model.toReal_zero _ _)
  · exact Or.inl rfl

theorem flushExact_abs_le (exact : Option (Int × Nat × Int)) (r : Value) :
    |Model.toReal (flushExact exact r)| ≤ |Model.toReal r| := by
  rcases flushExact_cases exact r with h | h
  · rw [h]
  · rw [h, abs_zero]; exact abs_nonneg _

theorem finite_flushExact (exact : Option (Int × Nat × Int)) (r : Value) (hr : Model.isFinite r = true) :

    Model.isFinite (flushExact exact r) = true := by
  unfold flushExact
  split
  · rename_i s _
    cases s <;> decide
  · exact hr

theorem real_flushExact {exact : Option (Int × Nat × Int)} {v : ℝ} (h : FlushToZero.Exact exact v) (r : Value)
    (hr : Model.toReal r = Model.roundAt FloatFormat.bfloat16 v) :
    Model.toReal (flushExact exact r) = if |v|<threshold then 0 else Model.roundAt FloatFormat.bfloat16 v := by
  unfold flushExact
  split
  · rename_i s hu
    rw [Model.toReal_zero, if_pos (FlushToZero.underflow_some h hu)]
  · rename_i hu
    rw [hr]
    split
    · rename_i hl
      rcases FlushToZero.underflow_none h hu with h0 | h0
      · rw [h0, Model.roundAt_zero]
      · exact absurd h0 (not_le.mpr hl)
    · rfl

theorem flushExact_error {exact : Option (Int × Nat × Int)} {v : ℝ} (h : FlushToZero.Exact exact v) (r : Value)
    (hr : Model.toReal r = Model.roundAt FloatFormat.bfloat16 v) :
    |Model.toReal (flushExact exact r)-v| ≤ threshold + epsilon v := by
  have er : |Model.roundAt FloatFormat.bfloat16 v-v| ≤ epsilon v := Model.abs_roundAt_sub_le _ _
  have ep : 0 ≤ epsilon v := (abs_nonneg _).trans er
  rw [real_flushExact h r hr]
  split
  · rw [zero_sub, abs_neg]
    linarith
  · linarith [threshold_pos]


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

-- Variants on flushed operands, for operands selected by flushed comparisons.
theorem add_nonnegative_flushed (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hxn : 0 ≤ Model.toReal (flush x)) (hyn : 0 ≤ Model.toReal (flush y))
    (ho : Model.isFinite (Model.add (flush x) (flush y)) = true) :
    0 ≤ Model.toReal (add x y) := by
  apply flush_nonnegative
  rw [Model.toReal_add_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho]
  have h := Model.roundAt_mono FloatFormat.bfloat16 (add_nonneg hxn hyn)
  simpa only [Model.roundAt_zero] using h

theorem sub_nonpositive_flushed (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hxn : Model.toReal (flush x) ≤ 0) (hyn : 0 ≤ Model.toReal (flush y))
    (ho : Model.isFinite (Model.sub (flush x) (flush y)) = true) :
    Model.toReal (sub x y) ≤ 0 := by
  apply flush_nonpositive
  rw [Model.toReal_sub_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho]
  have h := Model.roundAt_mono FloatFormat.bfloat16 (sub_nonpos.mpr (le_trans hxn hyn))
  simpa only [Model.roundAt_zero] using h

theorem add_error_flushed (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.add (flush x) (flush y))=true) :
    |Model.toReal (add x y)-(Model.toReal (flush x)+Model.toReal (flush y))| ≤
      threshold + epsilon (Model.toReal (flush x)+Model.toReal (flush y)) := by
  have eo := flush_error (Model.add (flush x) (flush y))
  have er := Model.abs_toReal_add_sub_le (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) ho
  unfold add
  calc
    _ = |(Model.toReal (flush (Model.add (flush x) (flush y)))-Model.toReal (Model.add (flush x) (flush y))) +
        (Model.toReal (Model.add (flush x) (flush y))-(Model.toReal (flush x)+Model.toReal (flush y)))| := by
      congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add eo er)

theorem sub_error_flushed (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.sub (flush x) (flush y))=true) :
    |Model.toReal (sub x y)-(Model.toReal (flush x)-Model.toReal (flush y))| ≤
      threshold + epsilon (Model.toReal (flush x)-Model.toReal (flush y)) := by
  have eo := flush_error (Model.sub (flush x) (flush y))
  have er := Model.abs_toReal_sub_sub_le (flush x) (flush y) (by decide)
    (finite_flush x hx) (finite_flush y hy) ho
  unfold sub
  calc
    _ = |(Model.toReal (flush (Model.sub (flush x) (flush y)))-Model.toReal (Model.sub (flush x) (flush y))) +
        (Model.toReal (Model.sub (flush x) (flush y))-(Model.toReal (flush x)-Model.toReal (flush y)))| := by
      congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add eo er)

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

theorem real_mul (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.mul (flush x) (flush y))=true) :
    Model.toReal (mul x y) = if |Model.toReal (flush x)*Model.toReal (flush y)|<threshold then 0
      else Model.roundAt FloatFormat.bfloat16 (Model.toReal (flush x)*Model.toReal (flush y)) :=
  real_flushExact (FlushToZero.exact_mul _ _) _
    (Model.toReal_mul_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho)

theorem real_div (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (hz : Model.isZero (flush y)=false) (ho : Model.isFinite (Model.div (flush x) (flush y))=true) :
    Model.toReal (div x y) = if |Model.toReal (flush x)/Model.toReal (flush y)|<threshold then 0
      else Model.roundAt FloatFormat.bfloat16 (Model.toReal (flush x)/Model.toReal (flush y)) :=
  real_flushExact (FlushToZero.exact_div _ _) _
    (Model.toReal_div_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) hz ho)

theorem mul_finite (x y : Value) (ho : Model.isFinite (Model.mul (flush x) (flush y))=true) :
    Model.isFinite (mul x y)=true := finite_flushExact _ _ ho
theorem div_finite (x y : Value) (ho : Model.isFinite (Model.div (flush x) (flush y))=true) :
    Model.isFinite (div x y)=true := finite_flushExact _ _ ho

theorem mul_error (x y : Value) (hx : Model.isFinite x=true) (hy : Model.isFinite y=true)
    (ho : Model.isFinite (Model.mul (flush x) (flush y))=true) :
    |Model.toReal (mul x y)-Model.toReal x*Model.toReal y| ≤ mulBudget x y := by
  have e : |Model.toReal (mul x y)-Model.toReal (flush x)*Model.toReal (flush y)| ≤
      threshold + epsilon (Model.toReal (flush x)*Model.toReal (flush y)) :=
    flushExact_error (FlushToZero.exact_mul _ _) _
      (Model.toReal_mul_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) ho)
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
  unfold mulBudget
  calc
    _ = |(Model.toReal (mul x y)-Model.toReal (flush x)*Model.toReal (flush y)) +
          (Model.toReal (flush x)*Model.toReal (flush y)-Model.toReal x*Model.toReal y)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add e ei)
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
  have e : |Model.toReal (flushExact (FlushToZero.divExact one x) (Model.div one x))-Model.toReal one/Model.toReal x| ≤
      threshold + epsilon (Model.toReal one/Model.toReal x) :=
    flushExact_error (FlushToZero.exact_div _ _) _
      (Model.toReal_div_eq_roundAt one x (by decide) finite_one hx hz ho)
  rw [real_one] at e
  unfold div
  rw [flush_one, flush_eq_of_one_le x hn]
  exact e



theorem flush_eq_of_normal (x : Value) (h : Model.toReal x = 0 ∨ threshold ≤ |Model.toReal x|) : flush x = x := by
  unfold flush
  split
  · rename_i hs
    have hb := (Model.isSubnormal_iff_abs_toReal x).mp hs
    have hb2 : 0 < |Model.toReal x| ∧ |Model.toReal x| < threshold := hb.2
    rcases h with h | h
    · rw [h, abs_zero] at hb2; exact absurd hb2.1 (lt_irrefl _)
    · exact absurd h (not_le.mpr hb2.2)
  · rfl

theorem flush_cases (x : Value) :
    flush x = x ∨ (Model.toReal (flush x) = 0 ∧ Model.toReal x ≠ 0 ∧ |Model.toReal x| < threshold) := by
  unfold flush
  split
  · rename_i hs
    have hb := (Model.isSubnormal_iff_abs_toReal x).mp hs
    have hb2 : 0 < |Model.toReal x| ∧ |Model.toReal x| < threshold := hb.2
    exact Or.inr ⟨Model.toReal_zero _ _, abs_pos.mp hb2.1, hb2.2⟩
  · exact Or.inl rfl

-- A flushed value is zero or at least the normal threshold in magnitude.
theorem flush_normal (x : Value) : Model.toReal (flush x) = 0 ∨ threshold ≤ |Model.toReal (flush x)| := by
  unfold flush
  split
  · exact Or.inl (Model.toReal_zero _ _)
  · rename_i hs
    by_cases hf : Model.isFinite x = true
    · by_cases h0 : Model.toReal x = 0
      · exact Or.inl h0
      · right
        refine le_of_not_gt fun hl => hs ((Model.isSubnormal_iff_abs_toReal x).mpr ⟨hf, abs_pos.mpr h0, hl⟩)
    · left
      rw [Model.toReal_eq]
      cases hd : Model.toDyadic? x
      · rfl
      · have := Model.isFinite_eq_true_of_toDyadic?_some hd
        exact absurd this hf

theorem flush_flush (x : Value) : flush (flush x) = flush x := by


  unfold flush
  split
  · rename_i hs
    rw [if_neg (by cases Model.signBit x <;> decide)]
  · rfl



theorem round_normal (v : ℝ) (hv : threshold ≤ |v|) : threshold ≤ |Model.roundAt FloatFormat.bfloat16 v| := by
  have hm : Model.roundAt FloatFormat.bfloat16 threshold = threshold := by
    have h := Model.roundAt_toReal_eq (Model.ofNatBits (fmt := FloatFormat.bfloat16) 0x0080) (by decide)
    have hd : Model.toDyadic? (Model.ofNatBits (fmt := FloatFormat.bfloat16) 0x0080) = some ⟨false, 128, -133⟩ := by
      decide
    rw [FlushToZero.toReal_of_toDyadic hd] at h
    have ht : ((FloatLib.Numerics.Dyadic.signedSignificand ⟨false, 128, -133⟩ : ℤ) : ℝ)*(2 : ℝ)^(-133 : ℤ) = threshold := by
      unfold threshold
      simp [FloatLib.Numerics.Dyadic.signedSignificand]
      norm_num
    rwa [ht] at h
  rcases le_abs'.mp hv with h | h
  · have l := Model.roundAt_mono FloatFormat.bfloat16 h
    rw [Model.roundAt_neg, hm] at l
    rw [abs_of_nonpos (by linarith [threshold_pos])]
    linarith
  · have u := Model.roundAt_mono FloatFormat.bfloat16 h
    rw [hm] at u
    rw [abs_of_pos (by linarith [threshold_pos])]
    exact u

theorem flush_flushExact {exact : Option (Int × Nat × Int)} {v : ℝ} (h : FlushToZero.Exact exact v) (r : Value)
    (hr : Model.isFinite r = true → Model.toReal r = Model.roundAt FloatFormat.bfloat16 v) :
    flush (flushExact exact r) = flushExact exact r := by
  unfold flushExact
  split
  · exact flush_eq_of_normal _ (Or.inl (Model.toReal_zero _ _))
  · rename_i hu
    cases hf : Model.isFinite r
    · unfold flush
      rw [if_neg]
      intro hs
      have := ((Model.isSubnormal_iff_abs_toReal r).mp hs).1
      rw [hf] at this
      cases this
    · rcases FlushToZero.underflow_none h hu with h0 | h0
      · exact flush_eq_of_normal _ (Or.inl (by rw [hr hf, h0, Model.roundAt_zero]))
      · exact flush_eq_of_normal _ (Or.inr (by rw [hr hf]; exact round_normal _ h0))

theorem flush_add (x y : Value) : flush (add x y) = add x y := flush_flush _
theorem flush_sub (x y : Value) : flush (sub x y) = sub x y := flush_flush _

theorem flush_mul (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true) :
    flush (mul x y) = mul x y :=
  flush_flushExact (FlushToZero.exact_mul _ _) _
    (Model.toReal_mul_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy))

theorem flush_div (x y : Value) (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (hz : Model.isZero (flush y) = false) : flush (div x y) = div x y :=
  flush_flushExact (FlushToZero.exact_div _ _) _
    (Model.toReal_div_eq_roundAt _ _ (by decide) (finite_flush x hx) (finite_flush y hy) hz)

end Inference.Contracts.Mlx.BFloat16Arithmetic
