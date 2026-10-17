import kernels.trellis.GateUpTail
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Analysis.Calculus.Deriv.Inv
import Mathlib.Analysis.SpecialFunctions.ExpDeriv

namespace Inference.Kernels.Trellis.SwiGLUStability
open GateUpTail (sigmoid swiglu)

theorem arithmetic_composition (g s a u o es em eo : ℝ)
    (hs : |s-sigmoid g| ≤ es) (hm : |a-g*s| ≤ em) (ho : |o-a*u| ≤ eo) :
    |o-swiglu g u| ≤ eo+(em+|g| *es)*|u| := by
  have hgs := mul_le_mul_of_nonneg_left hs (abs_nonneg g)
  have ha : |a-g*sigmoid g| ≤ em+|g| *es := by
    calc
      _ = |(a-g*s)+g*(s-sigmoid g)| := by congr 1; ring
      _ ≤ _ := by
        rw [← abs_mul] at hgs
        exact (abs_add_le _ _).trans (add_le_add hm hgs)
  have hau := mul_le_mul_of_nonneg_right ha (abs_nonneg u)
  unfold swiglu
  calc
    _ = |(o-a*u)+(a-g*sigmoid g)*u| := by congr 1; ring
    _ ≤ _ := by
      rw [← abs_mul] at hau
      exact (abs_add_le _ _).trans (add_le_add ho hau)

theorem sigmoid_derivative (x : ℝ) :
    HasDerivAt sigmoid (Real.exp (-x)/(1+Real.exp (-x))^2) x := by
  have he := (Real.hasDerivAt_exp (-x)).comp x (hasDerivAt_id x).neg
  have hd := (hasDerivAt_const x (1 : ℝ)).add he
  have h := (hasDerivAt_const x (1 : ℝ)).div hd (by change 1+Real.exp (-x) ≠ 0; positivity)
  convert h using 1 <;> first | rfl | simp [Function.comp_def]

theorem sigmoid_derivative_bound (x : ℝ) :
    |Real.exp (-x)/(1+Real.exp (-x))^2| ≤ (1 : ℝ)/4 := by
  have hp := Real.exp_pos (-x)
  rw [abs_of_nonneg (by positivity)]
  apply (div_le_iff₀ (by positivity)).mpr
  nlinarith [sq_nonneg (Real.exp (-x)-1)]

theorem sigmoid_lipschitz (x y : ℝ) : |sigmoid y-sigmoid x| ≤ (1 : ℝ)/4 * |y-x| := by
  have h := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (s := Set.univ) (f := sigmoid) (f' := fun t => Real.exp (-t)/(1+Real.exp (-t))^2)
    (fun t _ => (sigmoid_derivative t).hasDerivWithinAt)
    (fun t _ => by simpa only [Real.norm_eq_abs] using sigmoid_derivative_bound t)
    (convex_univ : Convex ℝ (Set.univ : Set ℝ)) (Set.mem_univ x) (Set.mem_univ y)
  simpa only [Real.norm_eq_abs] using h

theorem silu_perturbation (g G eg : ℝ) (hg : |g-G| ≤ eg) :
    |g*sigmoid g-G*sigmoid G| ≤ eg*(1+|G|/4) := by
  have sg := GateUpTail.sigmoid_pos g
  have sgle := GateUpTail.sigmoid_le_one g
  have hs : |sigmoid g| ≤ 1 := by rwa [abs_of_pos sg]
  have ea := mul_le_mul (hg) hs (abs_nonneg _) (le_trans (abs_nonneg _) hg)
  have eb := mul_le_mul_of_nonneg_left (sigmoid_lipschitz G g) (abs_nonneg G)
  have ec := mul_le_mul_of_nonneg_left hg (show 0 ≤ |G|/4 by positivity)
  calc
    _ = |(g-G)*sigmoid g+G*(sigmoid g-sigmoid G)| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_add_le ((g-G)*sigmoid g) (G*(sigmoid g-sigmoid G))
      simp only [abs_mul] at h
      nlinarith

-- Error in both projected inputs is propagated to the exact SwiGLU target.
-- The local arithmetic budget can then be added by the triangle inequality.
theorem swiglu_perturbation (g u G U eg eu : ℝ) (hg : |g-G| ≤ eg) (hu : |u-U| ≤ eu) :
    |swiglu g u-swiglu G U| ≤ eg*(1+|G|/4)*|u|+|G| *eu := by
  have eg' := mul_le_mul_of_nonneg_right (silu_perturbation g G eg hg) (abs_nonneg u)
  have hs : |G*sigmoid G| ≤ |G| := by
    rw [abs_mul, abs_of_pos (GateUpTail.sigmoid_pos G)]
    simpa using mul_le_mul_of_nonneg_left (GateUpTail.sigmoid_le_one G) (abs_nonneg G)
  have eu' := mul_le_mul hs hu (abs_nonneg _) (abs_nonneg G)
  simp only [abs_mul] at eu'
  unfold swiglu
  calc
    _ = |(g*sigmoid g-G*sigmoid G)*u+(G*sigmoid G)*(u-U)| := by congr 1; ring
    _ ≤ _ := by
      have h := abs_add_le ((g*sigmoid g-G*sigmoid G)*u) ((G*sigmoid G)*(u-U))
      simp only [abs_mul] at h
      linarith

theorem compose (output g u G U localError gateError upError : ℝ)
    (hl : |output-swiglu g u| ≤ localError)
    (hg : |g-G| ≤ gateError) (hu : |u-U| ≤ upError) :
    |output-swiglu G U| ≤ localError+gateError*(1+|G|/4)*|u|+|G| *upError := by
  have hp := swiglu_perturbation g u G U gateError upError hg hu
  calc
    _ = |(output-swiglu g u)+(swiglu g u-swiglu G U)| := by congr 1; ring
    _ ≤ _ := by
      have h := (abs_add_le _ _).trans (add_le_add hl hp)
      linarith

end Inference.Kernels.Trellis.SwiGLUStability
