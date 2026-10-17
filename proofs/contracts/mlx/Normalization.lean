import contracts.mlx.Numerics
import Mathlib.Analysis.Real.Sqrt
import Mathlib.Algebra.BigOperators.Fin

namespace Inference.Contracts.Mlx.Normalization
open Numerics
open scoped BigOperators

noncomputable def meanSquare {n : Nat} (x : Fin n → ℝ) : ℝ := (∑ i, x i ^ 2) / n
noncomputable def denominator {n : Nat} (x : Fin n → ℝ) (eps : ℝ) : ℝ := meanSquare x + eps
noncomputable def rmsNorm {n : Nat} (x weight : Fin n → ℝ) (eps : ℝ) (i : Fin n) : ℝ :=
  weight i * (x i / Real.sqrt (denominator x eps))

theorem meanSquare_nonnegative {n : Nat} (x : Fin n → ℝ) : 0 ≤ meanSquare x := by
  unfold meanSquare
  positivity

theorem denominator_positive {n : Nat} (x : Fin n → ℝ) (eps : ℝ) (he : 0<eps) :
    0 < denominator x eps := by
  have := meanSquare_nonnegative x
  unfold denominator
  linarith

-- This bound is independent of the input magnitude. It is useful for proving
-- subsequent projection ranges once rounding and weight errors are included.
theorem normalized_bound {n : Nat} (hn : 0<n) (x : Fin n → ℝ) (eps : ℝ) (he : 0<eps) (i : Fin n) :
    |x i / Real.sqrt (denominator x eps)| ≤ Real.sqrt n := by
  have hn' : (0 : ℝ)<n := by exact_mod_cast hn
  have hd := denominator_positive x eps he
  have hs : x i ^ 2 ≤ ∑ j : Fin n, x j ^ 2 := by
    exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)
  have hdEq : (n : ℝ)*denominator x eps = (∑ j : Fin n, x j ^ 2)+(n : ℝ)*eps := by
    unfold denominator meanSquare
    field_simp
  have boundSq : |x i| ^ 2 ≤ (Real.sqrt n * Real.sqrt (denominator x eps)) ^ 2 := by
    rw [sq_abs, mul_pow, Real.sq_sqrt hn'.le, Real.sq_sqrt hd.le, hdEq]
    nlinarith
  have hb : |x i| ≤ Real.sqrt n * Real.sqrt (denominator x eps) :=
    (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))).mp boundSq
  rw [abs_div, abs_of_pos (Real.sqrt_pos.mpr hd)]
  exact (div_le_iff₀ (Real.sqrt_pos.mpr hd)).mpr hb

theorem output_bound {n : Nat} (hn : 0<n) (x weight : Fin n → ℝ) (eps : ℝ) (he : 0<eps) (i : Fin n) :
    |rmsNorm x weight eps i| ≤ |weight i| * Real.sqrt n := by
  unfold rmsNorm
  rw [abs_mul]
  exact mul_le_mul_of_nonneg_left (normalized_bound hn x eps he i) (abs_nonneg _)

theorem output_bound_of_error {n : Nat} (hn : 0 < n) (x weight : Fin n → ℝ) (eps : ℝ)
    (he : 0 < eps) (i : Fin n) (actual error : ℝ)
    (ha : |actual - rmsNorm x weight eps i| ≤ error) :
    |actual| ≤ |weight i| * Real.sqrt n + error := by
  have h := (abs_add_le (actual - rmsNorm x weight eps i) (rmsNorm x weight eps i)).trans
    (add_le_add ha (output_bound hn x weight eps he i))
  simpa only [sub_add_cancel, add_comm error] using h

-- Loading Qwen normalization weights adds one in the tensor's dtype. A
-- weight error therefore contributes at most sqrt(width) times that error.
theorem weight_perturbation {n : Nat} (hn : 0 < n) (x weight target : Fin n → ℝ)
    (eps : ℝ) (he : 0 < eps) (i : Fin n) (weightError : ℝ)
    (hw : |weight i - target i| ≤ weightError) :
    |rmsNorm x weight eps i - rmsNorm x target eps i| ≤ weightError * Real.sqrt n := by
  unfold rmsNorm
  rw [← sub_mul, abs_mul]
  exact mul_le_mul hw (normalized_bound hn x eps he i) (abs_nonneg _) (le_trans (abs_nonneg _) hw)

theorem inverse_sqrt_difference (d t : ℝ) (hd : 0<d) (ht : 0<t) :
    |1/Real.sqrt d-1/Real.sqrt t| =
      |d-t|/(Real.sqrt d*Real.sqrt t*(Real.sqrt d+Real.sqrt t)) := by
  have sd := Real.sqrt_pos.mpr hd
  have st := Real.sqrt_pos.mpr ht
  have dd := Real.sq_sqrt hd.le
  have tt := Real.sq_sqrt ht.le
  have hf : d-t=(Real.sqrt d-Real.sqrt t)*(Real.sqrt d+Real.sqrt t) := by nlinarith
  have hi : 1/Real.sqrt d-1/Real.sqrt t = -(Real.sqrt d-Real.sqrt t)/(Real.sqrt d*Real.sqrt t) := by
    field_simp
    ring
  simp only [hi, hf, abs_div, abs_neg, abs_mul,
    abs_of_pos sd, abs_of_pos st, abs_of_pos (by linarith : 0<Real.sqrt d+Real.sqrt t)]
  field_simp

noncomputable def meanSquareBudget (x target error : Fin n → ℝ) : ℝ :=
  (∑ i, error i * (|x i| + |target i|)) / n

theorem meanSquare_error (x target error : Fin n → ℝ) (he : ∀ i, |x i - target i| ≤ error i) :
    |meanSquare x - meanSquare target| ≤ meanSquareBudget x target error := by
  have hs : |(∑ i, x i ^ 2) - (∑ i, target i ^ 2)| ≤ ∑ i, error i * (|x i| + |target i|) := by
    rw [← Finset.sum_sub_distrib]
    apply (Finset.abs_sum_le_sum_abs _ _).trans
    apply Finset.sum_le_sum
    intro i _
    rw [show x i ^ 2 - target i ^ 2 = (x i - target i) * (x i + target i) by ring, abs_mul]
    exact mul_le_mul (he i) (abs_add_le _ _) (abs_nonneg _) ((abs_nonneg _).trans (he i))
  unfold meanSquare meanSquareBudget
  rw [← sub_div, abs_div, abs_of_nonneg (show (0 : ℝ) ≤ (n : ℝ) from Nat.cast_nonneg n)]
  exact div_le_div_of_nonneg_right hs (Nat.cast_nonneg n)

noncomputable def inputBudget (x target error : Fin n → ℝ) (eps : ℝ) (i : Fin n) : ℝ :=
  let d := denominator x eps
  let t := denominator target eps
  error i / Real.sqrt d + |target i| *
    (meanSquareBudget x target error / (Real.sqrt d * Real.sqrt t * (Real.sqrt d + Real.sqrt t)))

-- Errors arriving from the preceding layer perturb both the coordinate and
-- the shared normalization denominator. Neither effect is dropped.
theorem normalized_input_error (x target error : Fin n → ℝ) (eps : ℝ) (hp : 0 < eps)
    (he : ∀ i, |x i - target i| ≤ error i) (i : Fin n) :
    |x i / Real.sqrt (denominator x eps) - target i / Real.sqrt (denominator target eps)| ≤
      inputBudget x target error eps i := by
  have hd := denominator_positive x eps hp
  have ht := denominator_positive target eps hp
  have hs := meanSquare_error x target error he
  have hr : |1 / Real.sqrt (denominator x eps) - 1 / Real.sqrt (denominator target eps)| ≤
      meanSquareBudget x target error /
        (Real.sqrt (denominator x eps) * Real.sqrt (denominator target eps) *
          (Real.sqrt (denominator x eps) + Real.sqrt (denominator target eps))) := by
    rw [inverse_sqrt_difference _ _ hd ht]
    have hdiff : denominator x eps - denominator target eps = meanSquare x - meanSquare target := by
      unfold denominator
      ring
    rw [hdiff]
    apply div_le_div_of_nonneg_right hs
    positivity
  have hc : |(x i - target i) / Real.sqrt (denominator x eps)| ≤ error i / Real.sqrt (denominator x eps) := by
    rw [abs_div, abs_of_pos (Real.sqrt_pos.mpr hd)]
    exact div_le_div_of_nonneg_right (he i) (Real.sqrt_nonneg _)
  have hm := mul_le_mul_of_nonneg_left hr (abs_nonneg (target i))
  rw [← abs_mul] at hm
  unfold inputBudget
  calc
    _ = |(x i - target i) / Real.sqrt (denominator x eps) + target i *
        (1 / Real.sqrt (denominator x eps) - 1 / Real.sqrt (denominator target eps))| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hc hm)

theorem input_perturbation (x target error weight : Fin n → ℝ) (eps : ℝ) (hp : 0 < eps)
    (he : ∀ i, |x i - target i| ≤ error i) (i : Fin n) :
    |rmsNorm x weight eps i - rmsNorm target weight eps i| ≤ |weight i| * inputBudget x target error eps i := by
  unfold rmsNorm
  rw [← mul_sub, abs_mul]
  exact mul_le_mul_of_nonneg_left (normalized_input_error x target error eps hp he i) (abs_nonneg _)

theorem perturbation (hn : 0 < n) (x target error weight targetWeight : Fin n → ℝ) (eps : ℝ)
    (hp : 0 < eps) (he : ∀ i, |x i - target i| ≤ error i) (i : Fin n) (weightError : ℝ)
    (hw : |weight i - targetWeight i| ≤ weightError) :
    |rmsNorm x weight eps i - rmsNorm target targetWeight eps i| ≤
      |weight i| * inputBudget x target error eps i + weightError * Real.sqrt n := by
  have hx := input_perturbation x target error weight eps hp he i
  have hw := weight_perturbation hn target weight targetWeight eps hp i weightError hw
  calc
    _ = |(rmsNorm x weight eps i - rmsNorm target weight eps i) +
        (rmsNorm target weight eps i - rmsNorm target targetWeight eps i)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add hx hw)

structure RsqrtContract (rsqrt : Float32 → Float32) (error : Float32 → ℝ) : Prop where
  accuracy : ∀ x, x.isFinite=true → 0<real x → (rsqrt x).isFinite=true →
    |real (rsqrt x)-1/Real.sqrt (real x)| ≤ error x

-- Only the primitive reciprocal-square-root error is a platform premise.
-- Perturbation of its argument is propagated here by a proved identity.
theorem rsqrt_error (rsqrt : Float32 → Float32) (error : Float32 → ℝ)
    (hardware : RsqrtContract rsqrt error) (x : Float32) (target inputError : ℝ)
    (hx : x.isFinite=true) (hp : 0<real x) (ht : 0<target) (ho : (rsqrt x).isFinite=true)
    (he : |real x-target| ≤ inputError) :
    |real (rsqrt x)-1/Real.sqrt target| ≤ error x +
      inputError/(Real.sqrt (real x)*Real.sqrt target*(Real.sqrt (real x)+Real.sqrt target)) := by
  have localError := hardware.accuracy x hx hp ho
  have propagated : |1/Real.sqrt (real x)-1/Real.sqrt target| ≤
      inputError/(Real.sqrt (real x)*Real.sqrt target*(Real.sqrt (real x)+Real.sqrt target)) := by
    rw [inverse_sqrt_difference _ _ hp ht]
    apply div_le_div_of_nonneg_right he
    positivity
  calc
    _ = |(real (rsqrt x)-1/Real.sqrt (real x))+(1/Real.sqrt (real x)-1/Real.sqrt target)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add localError propagated)

end Inference.Contracts.Mlx.Normalization
