import contracts.mlx.Numerics

namespace Inference.Contracts.Mlx.FlushToZero
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Binary32 subnormals have an exponent of -149 and fewer than 24 significant
-- bits. Model input and output flushing explicitly; IEEE gradual underflow is
-- not an unconditional description of M1 Max arithmetic.
def flush (x : Float32) : Float32 :=
  match x.toModel.unpack with
  | .finite s m e _ =>
    if m<8388608 ∧ e = -149 then Float32.ofModel (Float32.Model.pack (.zero s)) else x
  | _ => x

noncomputable def threshold : ℝ := (2 : ℝ)^(-126 : ℤ)

theorem threshold_pos : 0 < threshold := by unfold threshold; positivity

theorem real_signed_zero (s : Float.Model.UnpackedFloat.Sign) :
    real (Float32.ofModel (Float32.Model.pack (.zero s))) = 0 := by
  rw [real_unpack]
  cases s <;> exact Model.unpackedToReal_zero _

theorem finite_flush (x : Float32) (hx : x.isFinite=true) : (flush x).isFinite=true := by
  unfold flush
  split
  · split
    · rename_i s _ _ _ _ _
      cases s <;> decide
    · exact hx
  · exact hx

theorem finite_flush_iff (x : Float32) : (flush x).isFinite = x.isFinite := by
  unfold flush
  split
  · rename_i s m e hm hu
    split
    · have hx : x.isFinite = true := by
        simp only [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite]
      rw [hx]
      cases s <;> decide
    · rfl
  · rfl

theorem flush_abs_le (x : Float32) : |real (flush x)| ≤ |real x| := by
  unfold flush
  split
  · split
    · rw [real_signed_zero, abs_zero]
      exact abs_nonneg _
    · exact le_refl _
  · exact le_refl _

theorem flush_error (x : Float32) : |real (flush x)-real x| ≤ threshold := by
  unfold flush
  split
  · rename_i s m e hm hu
    split
    · rename_i h
      rw [real_signed_zero, zero_sub, abs_neg, real_unpack, hu, Model.unpackedToReal_finite]
      obtain ⟨hsmall, rfl⟩ := h
      have hm' : (m : ℝ) ≤ 8388608 := by exact_mod_cast (show m≤8388608 by omega)
      have hp : 0 < (2 : ℝ)^(-149 : ℤ) := by positivity
      have hbound := mul_le_mul_of_nonneg_right hm' hp.le
      cases s <;> norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow] at *
      all_goals
        change (m : ℝ) * (|(2 : ℝ)|^149)⁻¹ ≤ (2 : ℝ)^(-126 : ℤ)
        norm_num at hbound ⊢
        linarith
    · simpa using threshold_pos.le
  · simpa using threshold_pos.le

def mul (x y : Float32) : Float32 := flush (flush x * flush y)
def add (x y : Float32) : Float32 := flush (flush x + flush y)
def fma (x y z : Float32) : Float32 := flush (Float32.fma (flush x) (flush y) (flush z))
def div (x y : Float32) : Float32 := flush (flush x / flush y)

theorem flush_nonnegative (x : Float32) (hx : 0 ≤ real x) : 0 ≤ real (flush x) := by
  unfold flush
  split
  · split
    · rw [real_signed_zero]
    · exact hx
  · exact hx

theorem flush_eq_or_zero (x : Float32) : flush x = x ∨ real (flush x) = 0 := by
  unfold flush
  split
  · split
    · exact Or.inr (real_signed_zero _)
    · exact Or.inl rfl
  · exact Or.inl rfl

theorem flush_nonpositive (x : Float32) (hx : real x ≤ 0) : real (flush x) ≤ 0 := by
  rcases flush_eq_or_zero x with h | h
  · rwa [h]
  · rw [h]

theorem mul_nonpositive (x y : Float32) (hx : real x ≤ 0) (hy : 0 ≤ real y)
    (ho : (flush x * flush y).isFinite = true) : real (mul x y) ≤ 0 := by
  apply flush_nonpositive
  rw [Numerics.mul_real _ _ ho]
  have h := Model.roundAt_mono FloatFormat.binary32
    (mul_nonpos_of_nonpos_of_nonneg (flush_nonpositive x hx) (flush_nonnegative y hy))
  simpa only [Model.roundAt_zero] using h

theorem flush_eq_of_one_le (x : Float32) (hx : 1 ≤ real x) : flush x = x := by
  rcases flush_eq_or_zero x with h | h
  · exact h
  · have he := flush_error x
    rw [h, zero_sub, abs_neg, abs_of_nonneg (by linarith)] at he
    have ht : threshold < 1 := by norm_num [threshold]
    linarith

theorem flush_eq_of_threshold_lt (x : Float32) (hx : threshold < |real x|) : flush x = x := by
  rcases flush_eq_or_zero x with h | h
  · exact h
  · have he := flush_error x
    rw [h, zero_sub, abs_neg] at he
    linarith

theorem round_nonnegative (x : ℝ) (hx : 0 ≤ x) :
    0 ≤ Model.roundAt FloatFormat.binary32 x := by
  have h := Model.roundAt_mono FloatFormat.binary32 hx
  simpa only [Model.roundAt_zero] using h

theorem mul_nonnegative (x y : Float32)
    (hp : 0 ≤ real (flush x) * real (flush y)) (ho : (flush x * flush y).isFinite=true) :
    0 ≤ real (mul x y) := by
  apply flush_nonnegative
  rw [Numerics.mul_real _ _ ho]
  exact round_nonnegative _ hp

theorem add_nonnegative (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hnx : 0 ≤ real x) (hny : 0 ≤ real y) (ho : (flush x + flush y).isFinite=true) :
    0 ≤ real (add x y) := by
  apply flush_nonnegative
  rw [Numerics.add_real _ _ (finite_flush x hx) (finite_flush y hy) ho]
  exact round_nonnegative _ (add_nonneg (flush_nonnegative x hnx) (flush_nonnegative y hny))

theorem fma_square_nonnegative (x acc : Float32) (hx : x.isFinite=true) (ha : acc.isFinite=true)
    (hna : 0 ≤ real acc) (ho : (Float32.fma (flush x) (flush x) (flush acc)).isFinite=true) :
    0 ≤ real (fma x x acc) := by
  apply flush_nonnegative
  rw [Numerics.fma_real _ _ _ (finite_flush x hx) (finite_flush x hx) (finite_flush acc ha) ho]
  exact round_nonnegative _ (add_nonneg (mul_self_nonneg _) (flush_nonnegative acc hna))

theorem div_nonnegative (x y : Float32) (hy : y.isFinite=true)
    (hnx : 0 ≤ real x) (hny : 0 ≤ real y) (ho : (flush x / flush y).isFinite=true) :
    0 ≤ real (div x y) := by
  apply flush_nonnegative
  rw [Numerics.div_real _ _ (finite_flush y hy) ho]
  exact round_nonnegative _ (div_nonneg (flush_nonnegative x hnx) (flush_nonnegative y hny))

-- Adding a nonnegative value cannot decrease a positive normal addend, even
-- when input/output subnormals are flushed. Used to establish RMS positivity.
theorem add_ge_normal_right (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hnx : 0 ≤ real x) (hny : threshold < real y) (ho : (flush x + flush y).isFinite=true) :
    real y ≤ real (add x y) := by
  have hyp : 0 < real y := lt_trans threshold_pos hny
  have hfy := flush_eq_of_threshold_lt y (by rwa [abs_of_pos hyp])
  have h := Model.roundAt_mono FloatFormat.binary32
    (show real y ≤ real (flush x) + real y by have := flush_nonnegative x hnx; linarith)
  have hround : Model.roundAt FloatFormat.binary32 (real y) = real y :=
    Model.roundAt_toReal_eq (model y) (by rw [finite_model]; exact hy)
  rw [hround] at h
  have hr : real y ≤ real (flush x + flush y) := by
    rw [Numerics.add_real _ _ (finite_flush x hx) (finite_flush y hy) ho, hfy]
    exact h
  have hfo := flush_eq_of_threshold_lt (flush x + flush y) (by
    rw [abs_of_pos (lt_of_lt_of_le hyp hr)]
    exact lt_of_lt_of_le hny hr)
  simpa only [add, hfo] using hr

theorem flush_one : flush (1 : Float32) = 1 := by
  apply flush_eq_of_one_le
  rw [real_one]

-- A sigmoid denominator cannot be subnormal: adding a nonnegative finite
-- exponential to one and rounding nearest-even still produces at least one.
theorem add_one_ge_one (x : Float32) (hx : x.isFinite=true) (hn : 0 ≤ real x)
    (hs : ((1 : Float32) + flush x).isFinite=true) : 1 ≤ real (add 1 x) := by
  have hi := flush_nonnegative x hn
  have hm := Model.roundAt_mono FloatFormat.binary32 (show (1 : ℝ) ≤ 1+real (flush x) by linarith)
  have hr := Model.roundAt_toReal_eq (model (1 : Float32)) (by rw [finite_model]; decide)
  rw [show Model.toReal (model (1 : Float32))=1 from real_one] at hr
  rw [hr] at hm
  have hs' : 1 ≤ real ((1 : Float32)+flush x) := by
    rw [Numerics.add_real _ _ (by decide) (finite_flush x hx) hs, real_one]
    exact hm
  unfold add
  rw [flush_one, flush_eq_of_one_le _ hs']
  exact hs'

theorem reciprocal_error (x : Float32) (hx : x.isFinite=true) (hn : 1 ≤ real x)
    (hq : ((1 : Float32)/x).isFinite=true) :
    |real (div 1 x)-1/real x| ≤ threshold + epsilon (1/real x) := by
  have er := Numerics.div_error (1 : Float32) x hx hq
  rw [real_one] at er
  have ef := flush_error ((1 : Float32)/x)
  unfold div
  rw [flush_one, flush_eq_of_one_le x hn]
  calc
    _ = |(real (flush ((1 : Float32)/x))-real ((1 : Float32)/x)) +
        (real ((1 : Float32)/x)-1/real x)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ef er)

noncomputable def divBudget (x y : Float32) : ℝ :=
  threshold + epsilon (real (flush x)/real y) + threshold/|real y|

theorem div_normal_error (x y : Float32) (hy : y.isFinite=true) (hn : 1 ≤ real y)
    (ho : (flush x/y).isFinite=true) :
    |real (div x y)-real x/real y| ≤ divBudget x y := by
  have er := Numerics.div_error (flush x) y hy ho
  have ef := flush_error (flush x/y)
  have ei : |real (flush x)/real y-real x/real y| ≤ threshold/|real y| := by
    rw [← sub_div, abs_div]
    exact div_le_div_of_nonneg_right (flush_error x) (abs_nonneg _)
  unfold div divBudget
  rw [flush_eq_of_one_le y hn]
  calc
    _ = |(real (flush (flush x/y))-real (flush x/y)) +
        ((real (flush x/y)-real (flush x)/real y)+(real (flush x)/real y-real x/real y))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add ef ((abs_add_le _ _).trans (add_le_add er ei)))
      linarith

theorem product_input_error (x y : Float32) :
    |real (flush x)*real (flush y)-real x*real y| ≤ threshold*(|real x|+|real y|) := by
  have ex := flush_error x
  have ey := flush_error y
  have exy := mul_le_mul_of_nonneg_right ex (abs_nonneg (real y))
  have eyx := mul_le_mul_of_nonneg_left ey (abs_nonneg (real (flush x)))
  have hm := mul_le_mul_of_nonneg_right (flush_abs_le x) threshold_pos.le
  calc
    _ = |real (flush x)*(real (flush y)-real y)+(real (flush x)-real x)*real y| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_add_le (real (flush x)*(real (flush y)-real y)) ((real (flush x)-real x)*real y)
      simp only [abs_mul] at h
      nlinarith

theorem mul_error (x y : Float32) (hf : (flush x*flush y).isFinite=true) :
    |real (mul x y)-real x*real y| ≤
      threshold + epsilon (real (flush x)*real (flush y)) + threshold*(|real x|+|real y|) := by
  have eo := flush_error (flush x*flush y)
  have er := Numerics.mul_error (flush x) (flush y) hf
  have ei := product_input_error x y
  unfold mul
  calc
    _ = |(real (flush (flush x*flush y))-real (flush x*flush y)) +
        ((real (flush x*flush y)-real (flush x)*real (flush y)) +
          (real (flush x)*real (flush y)-real x*real y))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er ei)))
      linarith

theorem add_error (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (hf : (flush x+flush y).isFinite=true) :
    |real (add x y)-(real x+real y)| ≤
      3*threshold + epsilon (real (flush x)+real (flush y)) := by
  have eo := flush_error (flush x+flush y)
  have er := Numerics.add_error (flush x) (flush y) (finite_flush x hx) (finite_flush y hy) hf
  have ex := flush_error x
  have ey := flush_error y
  unfold add
  calc
    _ = |(real (flush (flush x+flush y))-real (flush x+flush y)) +
        ((real (flush x+flush y)-(real (flush x)+real (flush y))) +
          ((real (flush x)-real x)+(real (flush y)-real y)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_add_le _ _).trans (add_le_add ex ey)))))
      linarith

theorem fma_error (x y z : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true) (hz : z.isFinite=true)
    (hf : (Float32.fma (flush x) (flush y) (flush z)).isFinite=true) :
    |real (fma x y z)-(real x*real y+real z)| ≤
      2*threshold + epsilon (real (flush x)*real (flush y)+real (flush z)) + threshold*(|real x|+|real y|) := by
  have eo := flush_error (Float32.fma (flush x) (flush y) (flush z))
  have er := Numerics.fma_error (flush x) (flush y) (flush z) (finite_flush x hx) (finite_flush y hy) (finite_flush z hz) hf
  have ei := product_input_error x y
  have ez := flush_error z
  unfold fma
  calc
    _ = |(real (flush (Float32.fma (flush x) (flush y) (flush z)))-real (Float32.fma (flush x) (flush y) (flush z))) +
        ((real (Float32.fma (flush x) (flush y) (flush z))-(real (flush x)*real (flush y)+real (flush z))) +
          ((real (flush x)*real (flush y)-real x*real y)+(real (flush z)-real z)))| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add eo ((abs_add_le _ _).trans (add_le_add er
        ((abs_add_le _ _).trans (add_le_add ei ez)))))
      linarith

-- A kernel-checked distinction between the two models, also observed by the
-- locked M1 Max probe. This finite witness cannot establish all hardware cases.
theorem underflow_witness :
    (Float32.ofBits 0x00800000 * Float32.ofBits 0x3f000000).toBits = 0x00400000 ∧
    (mul (Float32.ofBits 0x00800000) (Float32.ofBits 0x3f000000)).toBits = 0 := by decide +kernel

noncomputable def mulBudget (x y : Float32) : ℝ :=
  threshold + epsilon (real (flush x)*real (flush y)) + threshold*(|real x|+|real y|)

noncomputable def addBudget (x y : Float32) : ℝ :=
  3*threshold + epsilon (real (flush x)+real (flush y))

noncomputable def fmaBudget (x y z : Float32) : ℝ :=
  2*threshold + epsilon (real (flush x)*real (flush y)+real (flush z)) + threshold*(|real x|+|real y|)

theorem scaled_fma_error (code scale input acc : Float32)
    (hw : (flush code*flush scale).isFinite=true) (hx : input.isFinite=true) (ha : acc.isFinite=true)
    (ho : (Float32.fma (flush (mul code scale)) (flush input) (flush acc)).isFinite=true) :
    |real (fma (mul code scale) input acc)-(real code*real scale*real input+real acc)| ≤
      mulBudget code scale * |real input| + fmaBudget (mul code scale) input acc := by
  have em := mul_error code scale hw
  have ef := fma_error (mul code scale) input acc (finite_flush _ hw) hx ha ho
  have ep := mul_le_mul_of_nonneg_right em (abs_nonneg (real input))
  unfold mulBudget fmaBudget
  calc
    _ = |(real (fma (mul code scale) input acc)-(real (mul code scale)*real input+real acc)) +
        (real (mul code scale)-real code*real scale)*real input| := by congr 1; ring
    _ ≤ _ := by
      have e : |(real (mul code scale)-real code*real scale)*real input| ≤
          (threshold+epsilon (real (flush code)*real (flush scale))+threshold*(|real code|+|real scale|))* |real input| := by
        simpa only [abs_mul] using ep
      have h := (abs_add_le _ _).trans (add_le_add ef e)
      linarith

end Inference.Contracts.Mlx.FlushToZero
