import kernels.trellis.GateUpSplitTail
import kernels.trellis.SwiGLUStability
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

namespace Inference.Kernels.Delta.Gates
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Contracts.Mlx.BFloat16Arithmetic
open Trellis

noncomputable def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)
noncomputable def stableSoftplus (x : ℝ) : ℝ := max x 0 + Real.log (1 + Real.exp (-|x|))

theorem softplus_positive (x : ℝ) : 0 < softplus x := by
  apply Real.log_pos
  have := Real.exp_pos x
  linarith

theorem stable_softplus (x : ℝ) : stableSoftplus x = softplus x := by
  unfold stableSoftplus softplus
  by_cases hx : 0 ≤ x
  · rw [max_eq_left hx, abs_of_nonneg hx]
    have he : Real.exp x * (1 + Real.exp (-x)) = 1 + Real.exp x := by
      rw [mul_add, mul_one, ← Real.exp_add]
      simp
      ring
    rw [← he, Real.log_mul (ne_of_gt (Real.exp_pos x)) (by positivity), Real.log_exp]
  · have hx' : x ≤ 0 := le_of_lt (lt_of_not_ge hx)
    rw [max_eq_right hx', abs_of_nonpos hx', neg_neg, zero_add]

theorem softplus_upper (x : ℝ) : softplus x ≤ max x 0 + Real.log 2 := by
  rw [← stable_softplus]
  unfold stableSoftplus
  apply add_le_add (le_refl _)
  apply Real.log_le_log (by positivity)
  have he : Real.exp (-|x|) ≤ 1 := by
    rw [Real.exp_le_one_iff]
    exact neg_nonpos.mpr (abs_nonneg x)
  linarith

theorem softplus_derivative (x : ℝ) : HasDerivAt softplus (Real.exp x / (1 + Real.exp x)) x := by
  have h := ((hasDerivAt_const x (1 : ℝ)).add (Real.hasDerivAt_exp x)).log
    (by change 1 + Real.exp x ≠ 0; positivity)
  convert h using 1 <;> first | rfl | simp

theorem softplus_derivative_bound (x : ℝ) : |Real.exp x / (1 + Real.exp x)| ≤ 1 := by
  rw [abs_of_nonneg (by positivity)]
  apply (div_le_iff₀ (by positivity)).mpr
  linarith

theorem softplus_lipschitz (x y : ℝ) : |softplus y - softplus x| ≤ |y - x| := by
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (s := Set.univ) (f := softplus) (f' := fun t => Real.exp t / (1 + Real.exp t))
    (fun t _ => (softplus_derivative t).hasDerivWithinAt)
    (fun t _ => by simpa only [Real.norm_eq_abs] using softplus_derivative_bound t)
    (convex_univ : Convex ℝ (Set.univ : Set ℝ)) (Set.mem_univ x) (Set.mem_univ y)
  simpa only [Real.norm_eq_abs, one_mul] using h

theorem log1p_derivative (x : ℝ) (hx : 0 ≤ x) :
    HasDerivAt (fun t : ℝ => Real.log (1 + t)) (1 / (1 + x)) x := by
  have h := ((hasDerivAt_const x (1 : ℝ)).add (hasDerivAt_id x)).log (by change 1 + x ≠ 0; linarith)
  convert h using 1 <;> first | rfl | simp

theorem log1p_lipschitz (x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y) :
    |Real.log (1 + y) - Real.log (1 + x)| ≤ |y - x| := by
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (s := Set.Ici 0) (f := fun t : ℝ => Real.log (1 + t)) (f' := fun t => 1 / (1 + t))
    (fun t ht => (log1p_derivative t ht).hasDerivWithinAt)
    (fun t ht => show ‖(1 / (1 + t) : ℝ)‖ ≤ (1 : ℝ) from by
      have htp : 0 < 1 + t := by change 0 ≤ t at ht; linarith
      rw [Real.norm_eq_abs, abs_of_pos (by positivity)]
      exact (div_le_iff₀ htp).mpr (by change 0 ≤ t at ht; linarith))
    (convex_Ici (0 : ℝ)) hx hy
  simpa only [Real.norm_eq_abs, one_mul] using h

noncomputable def decay (aLog x : ℝ) : ℝ := Real.exp (-Real.exp aLog * softplus x)

theorem decay_range (aLog x : ℝ) : 0 < decay aLog x ∧ decay aLog x < 1 := by
  constructor
  · exact Real.exp_pos _
  · apply Real.exp_lt_one_iff.mpr
    exact mul_neg_of_neg_of_pos (neg_neg_of_pos (Real.exp_pos aLog)) (softplus_positive x)

theorem exp_nonpos_lipschitz (x y : ℝ) (hx : x ≤ 0) (hy : y ≤ 0) :
    |Real.exp y - Real.exp x| ≤ |y - x| := by
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (s := Set.Iic 0) (f := Real.exp) (f' := Real.exp)
    (fun t _ => (Real.hasDerivAt_exp t).hasDerivWithinAt)
    (fun t ht => show ‖Real.exp t‖ ≤ (1 : ℝ) from by
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos t)]
      exact Real.exp_le_one_iff.mpr ht)
    (convex_Iic (0 : ℝ)) hx hy
  simpa only [Real.norm_eq_abs, one_mul] using h

theorem exp_lipschitz (x y : ℝ) :
    |Real.exp y - Real.exp x| ≤ Real.exp (max x y) * |y - x| := by
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (s := Set.Iic (max x y)) (f := Real.exp) (f' := Real.exp)
    (fun t _ => (Real.hasDerivAt_exp t).hasDerivWithinAt)
    (fun t ht => show ‖Real.exp t‖ ≤ Real.exp (max x y) from by
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos t)]
      exact Real.exp_le_exp.mpr ht)
    (convex_Iic (max x y)) (le_max_left x y) (le_max_right x y)
  simpa only [Real.norm_eq_abs] using h

theorem decay_perturbation (a b x y ea ex : ℝ)
    (ha : |Real.exp a - Real.exp b| ≤ ea) (hx : |x - y| ≤ ex) :
    |decay a x - decay b y| ≤ ea * softplus x + Real.exp b * ex := by
  have ep := exp_nonpos_lipschitz (-Real.exp b * softplus y) (-Real.exp a * softplus x)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Real.exp_pos b).le) (softplus_positive y).le)
    (mul_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr (Real.exp_pos a).le) (softplus_positive x).le)
  have es := (softplus_lipschitz y x).trans hx
  have h1 := mul_le_mul_of_nonneg_right ha (softplus_positive x).le
  have h2 := mul_le_mul_of_nonneg_left es (Real.exp_pos b).le
  apply ep.trans
  calc
    _ = |-(Real.exp a - Real.exp b) * softplus x - Real.exp b * (softplus x - softplus y)| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_sub (-(Real.exp a - Real.exp b) * softplus x) (Real.exp b * (softplus x - softplus y))
      simp only [abs_mul, abs_neg, abs_of_pos (softplus_positive x), abs_of_pos (Real.exp_pos b)] at h
      exact h.trans (add_le_add h1 h2)

theorem beta_error (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs error) (x : Value)
    (hf : GateUpSplitTail.SigmoidFinite expAbs x) (ideal inputError : ℝ)
    (hi : |Model.toReal x - ideal| ≤ inputError) :
    |Model.toReal (GateUpSplitTail.sigmoidValue expAbs x) - GateUpTail.sigmoid ideal| ≤
      GateUpSplitTail.sigmoidBudget expAbs error x + inputError / 4 := by
  have hl := GateUpSplitTail.sigmoid_error expAbs error exponential x hf
  have hi' := (SwiGLUStability.sigmoid_lipschitz ideal (Model.toReal x)).trans
    (mul_le_mul_of_nonneg_left hi (by norm_num : (0 : ℝ) ≤ 1/4))
  calc
    _ = |(Model.toReal (GateUpSplitTail.sigmoidValue expAbs x) - GateUpTail.sigmoid (Model.toReal x)) +
      (GateUpTail.sigmoid (Model.toReal x) - GateUpTail.sigmoid ideal)| := by congr 1; ring
    _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hl hi'); linarith

-- Stable sigmoid also has a finite output when exp(abs(x)) overflows.
-- This is a source branch with an exact reciprocal-to-zero result.
def BetaValid (expAbs : Value → Value) (x : Value) : Prop :=
  GateUpSplitTail.SigmoidFinite expAbs x ∨ expAbs x = Model.posInf FloatFormat.bfloat16

noncomputable def betaBudget (expAbs : Value → Value) (error : Value → ℝ) (x : Value) : ℝ :=
  if Model.isFinite (expAbs x) then GateUpSplitTail.sigmoidBudget expAbs error x
  else 1 / (1 + Real.exp (|Model.toReal x|)) + Contracts.Mlx.FlushToZero.threshold

theorem beta_finite (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs error) (x : Value) (hv : BetaValid expAbs x) :
    Model.isFinite (GateUpSplitTail.sigmoidValue expAbs x) = true := by
  rcases hv with hf | he
  · exact GateUpSplitTail.sigmoid_finite expAbs error exponential x hf
  · rw [GateUpSplitTail.sigmoid_of_exp_inf expAbs x he]
    split
    · decide
    · exact finite_one

theorem beta_total_error (expAbs : Value → Value) (error : Value → ℝ)
    (exponential : GateUpSplitTail.ExpAbsContract expAbs error) (x : Value)
    (hx : Model.isFinite x = true) (hv : BetaValid expAbs x) (ideal inputError : ℝ)
    (hi : |Model.toReal x - ideal| ≤ inputError) :
    |Model.toReal (GateUpSplitTail.sigmoidValue expAbs x) - GateUpTail.sigmoid ideal| ≤
      betaBudget expAbs error x + inputError / 4 := by
  rcases hv with hf | he
  · simpa only [betaBudget, hf.hExp, Bool.true_eq, ite_true] using
      beta_error expAbs error exponential x hf ideal inputError hi
  · have hl := GateUpSplitTail.sigmoid_overflow_error expAbs x hx he

    have hi' := (SwiGLUStability.sigmoid_lipschitz ideal (Model.toReal x)).trans
      (mul_le_mul_of_nonneg_left hi (by norm_num : (0 : ℝ) ≤ 1/4))
    have hn : Model.isFinite (expAbs x) = false := by rw [he]; decide
    simp only [betaBudget, hn, Bool.false_eq_true, ite_false]
    calc
      _ = |(Model.toReal (GateUpSplitTail.sigmoidValue expAbs x) - GateUpTail.sigmoid (Model.toReal x)) +
        (GateUpTail.sigmoid (Model.toReal x) - GateUpTail.sigmoid ideal)| := by congr 1; ring
      _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hl hi'); linarith

end Inference.Kernels.Delta.Gates
