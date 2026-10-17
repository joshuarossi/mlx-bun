import kernels.delta.Recurrence
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

namespace Inference.Kernels.Delta.RecurrenceStability
open Contracts.Mlx Contracts.Mlx.Numerics
open scoped BigOperators

noncomputable def dot (x y : Fin n → ℝ) : ℝ := ∑ i, x i*y i
noncomputable def energy (x : Fin n → ℝ) : ℝ := ∑ i, (x i)^2
noncomputable def correct (state key : Fin n → ℝ) (beta : ℝ) : Fin n → ℝ :=
  fun i => state i-beta*dot state key*key i

theorem energy_nonnegative (x : Fin n → ℝ) : 0 ≤ energy x :=
  Finset.sum_nonneg (fun i _ => sq_nonneg (x i))

theorem energy_scale (x : Fin n → ℝ) (scale : ℝ) :
    energy (fun i => scale*x i) = scale^2*energy x := by
  simp only [energy, mul_pow, Finset.mul_sum]

theorem energy_add (x y : Fin n → ℝ) :
    energy (fun i => x i+y i) = energy x + 2*dot x y + energy y := by
  unfold energy dot
  calc
    _ = ∑ i, ((x i)^2 + 2*(x i*y i) + (y i)^2) := by
      apply Finset.sum_congr rfl
      intro i _
      ring
    _ = _ := by rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.mul_sum]

theorem dot_scale_right (x y : Fin n → ℝ) (scale : ℝ) :
    dot x (fun i => scale*y i) = scale*dot x y := by
  unfold dot
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem correction_energy (state key : Fin n → ℝ) (beta : ℝ) :
    energy (correct state key beta) =
      energy state-beta*(2-beta*energy key)*(dot state key)^2 := by
  have point : correct state key beta = fun i => state i+(-beta*dot state key)*key i := by
    funext i
    unfold correct
    ring
  rw [point, energy_add, energy_scale, dot_scale_right]
  ring

-- The rank-one state correction is nonexpansive whenever beta*||key||²
-- lies in [0,2]. This is a mathematical condition to derive for the rounded
-- normalized key, not a new hardware or whole-kernel axiom.
theorem correction_nonexpansive (state key : Fin n → ℝ) (beta : ℝ)
    (positive : 0 ≤ beta) (stable : beta*energy key ≤ 2) :
    energy (correct state key beta) ≤ energy state := by
  rw [correction_energy]
  exact sub_le_self _ (mul_nonneg (mul_nonneg positive (sub_nonneg.mpr stable)) (sq_nonneg _))

theorem homogeneous_nonexpansive (state key : Fin n → ℝ) (decay beta : ℝ)
    (hd : |decay| ≤ 1) (hb : 0 ≤ beta) (hk : beta*energy key ≤ 2) :
    energy (fun i => decay*correct state key beta i) ≤ energy state := by
  rw [energy_scale]
  have hdecay : decay^2 ≤ 1 := by
    have h := (sq_le_sq₀ (abs_nonneg decay) (by norm_num : (0 : ℝ) ≤ 1)).mpr hd
    simpa only [sq_abs, one_pow] using h
  have hc := correction_nonexpansive state key beta hb hk
  exact (mul_le_mul_of_nonneg_left hc (sq_nonneg decay)).trans
    ((mul_le_mul_of_nonneg_right hdecay (energy_nonnegative state)).trans_eq (one_mul _))

theorem target_step_decomposition (state : Fin 128 → ℝ) (input : Recurrence.Inputs ℝ) :
    Recurrence.targetStep state input = fun i =>
      input.decay*correct state input.key input.beta i + input.beta*input.value*input.key i := by
  funext i
  rw [Recurrence.targetStep_formula]
  unfold correct dot
  ring

theorem target_step_difference (left right : Fin 128 → ℝ) (input : Recurrence.Inputs ℝ) :
    (fun i => Recurrence.targetStep left input i-Recurrence.targetStep right input i) =
      fun i => input.decay*correct (fun j => left j-right j) input.key input.beta i := by
  funext i
  rw [target_step_decomposition, target_step_decomposition]
  have hd : dot (fun j => left j-right j) input.key = dot left input.key-dot right input.key := by
    unfold dot
    simp only [sub_mul, Finset.sum_sub_distrib]
  simp only [correct, hd]
  ring

theorem target_step_stable (left right : Fin 128 → ℝ) (input : Recurrence.Inputs ℝ)
    (hd : |input.decay| ≤ 1) (hb : 0 ≤ input.beta) (hk : input.beta*energy input.key ≤ 2) :
    energy (fun i => Recurrence.targetStep left input i-Recurrence.targetStep right input i) ≤
      energy (fun i => left i-right i) := by
  rw [target_step_difference]
  exact homogeneous_nonexpansive _ _ _ _ hd hb hk

theorem target_run_stable (inputs : Nat → Recurrence.Inputs ℝ) (left right : Fin 128 → ℝ)
    (steps : Nat) (hd : ∀ t, t < steps → |(inputs t).decay| ≤ 1)
    (hb : ∀ t, t < steps → 0 ≤ (inputs t).beta)
    (hk : ∀ t, t < steps → (inputs t).beta*energy (inputs t).key ≤ 2) :
    energy (fun i => Recurrence.targetRun inputs left steps i-Recurrence.targetRun inputs right steps i) ≤
      energy (fun i => left i-right i) := by
  induction steps with
  | zero => exact le_refl _
  | succ steps ih =>
    have previous := ih (fun t ht => hd t (by omega)) (fun t ht => hb t (by omega))
      (fun t ht => hk t (by omega))
    exact (target_step_stable _ _ (inputs steps) (hd steps (by omega)) (hb steps (by omega))
      (hk steps (by omega))).trans previous

noncomputable def magnitude (x : Fin n → ℝ) : ℝ := Real.sqrt (energy x)

theorem magnitude_nonnegative (x : Fin n → ℝ) : 0 ≤ magnitude x := Real.sqrt_nonneg _
theorem magnitude_square (x : Fin n → ℝ) : (magnitude x)^2 = energy x :=
  Real.sq_sqrt (energy_nonnegative x)
theorem magnitude_mono (x y : Fin n → ℝ) (h : energy x ≤ energy y) : magnitude x ≤ magnitude y :=
  Real.sqrt_le_sqrt h
theorem magnitude_scale (x : Fin n → ℝ) (scale : ℝ) :
    magnitude (fun i => scale*x i) = |scale| * magnitude x := by
  unfold magnitude
  rw [energy_scale, Real.sqrt_mul (sq_nonneg scale), Real.sqrt_sq_eq_abs]

theorem cauchy (x y : Fin n → ℝ) : |dot x y| ≤ magnitude x*magnitude y := by
  have h : (dot x y)^2 ≤ energy x*energy y := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ x y
  apply (sq_le_sq₀ (abs_nonneg _) (mul_nonneg (magnitude_nonnegative x) (magnitude_nonnegative y))).mp
  simpa only [sq_abs, mul_pow, magnitude_square] using h

theorem triangle (x y : Fin n → ℝ) :
    magnitude (fun i => x i+y i) ≤ magnitude x+magnitude y := by
  apply (sq_le_sq₀ (magnitude_nonnegative _) (add_nonneg (magnitude_nonnegative _) (magnitude_nonnegative _))).mp
  rw [magnitude_square, energy_add]
  have h := (le_abs_self (dot x y)).trans (cauchy x y)
  nlinarith [magnitude_square x, magnitude_square y]

theorem pointwise_bound (x bounds : Fin n → ℝ) (h : ∀ i, |x i| ≤ bounds i) :
    magnitude x ≤ magnitude bounds := by
  apply magnitude_mono
  apply Finset.sum_le_sum
  intro i _
  have hn := (abs_nonneg (x i)).trans (h i)
  have hi := (sq_le_sq₀ (abs_nonneg (x i)) hn).mpr (h i)
  simpa only [sq_abs] using hi

theorem target_step_growth (state : Fin 128 → ℝ) (input : Recurrence.Inputs ℝ)
    (hd : |input.decay| ≤ 1) (hb : 0 ≤ input.beta) (hk : input.beta*energy input.key ≤ 2) :
    magnitude (Recurrence.targetStep state input) ≤ magnitude state + |input.beta*input.value| * magnitude input.key := by
  rw [target_step_decomposition]
  have h := triangle (fun i => input.decay*correct state input.key input.beta i)
    (fun i => (input.beta*input.value)*input.key i)
  rw [magnitude_scale input.key] at h
  exact h.trans (add_le_add (magnitude_mono _ _ (homogeneous_nonexpansive state _ _ _ hd hb hk)) (le_refl _))

-- Local numerical defects accumulate additively in this norm when each
-- exact state update is nonexpansive. This replaces a coordinate-wise
-- exponential Lipschitz estimate; the defects still have to be bounded.
theorem error_accumulation (inputs : Nat → Recurrence.Inputs ℝ) (actual : Nat → Fin 128 → ℝ)
    (targetInitial : Fin 128 → ℝ) (defect : Nat → ℝ) (steps : Nat)
    (hd : ∀ t, t < steps → |(inputs t).decay| ≤ 1)
    (hb : ∀ t, t < steps → 0 ≤ (inputs t).beta)
    (hk : ∀ t, t < steps → (inputs t).beta*energy (inputs t).key ≤ 2)
    (he : ∀ t, t < steps → magnitude (fun i => actual (t+1) i-Recurrence.targetStep (actual t) (inputs t) i) ≤ defect t) :
    magnitude (fun i => actual steps i-Recurrence.targetRun inputs targetInitial steps i) ≤
      magnitude (fun i => actual 0 i-targetInitial i) + ∑ t ∈ Finset.range steps, defect t := by
  induction steps with
  | zero => simp only [Recurrence.targetRun, Finset.range_zero, Finset.sum_empty, add_zero, le_refl]
  | succ t ih =>
    have previous := ih (fun j hj => hd j (by omega)) (fun j hj => hb j (by omega))
      (fun j hj => hk j (by omega)) (fun j hj => he j (by omega))
    have hs := magnitude_mono _ _ (target_step_stable (actual t) (Recurrence.targetRun inputs targetInitial t)
      (inputs t) (hd t (by omega)) (hb t (by omega)) (hk t (by omega)))
    have ht := triangle
      (fun i => actual (t+1) i-Recurrence.targetStep (actual t) (inputs t) i)
      (fun i => Recurrence.targetStep (actual t) (inputs t) i-
        Recurrence.targetStep (Recurrence.targetRun inputs targetInitial t) (inputs t) i)
    simp only [sub_add_sub_cancel] at ht
    have h := ht.trans (add_le_add (he t (by omega)) (hs.trans previous))
    simpa only [Recurrence.targetRun, Finset.sum_range_succ, add_assoc, add_comm, add_left_comm] using h

end Inference.Kernels.Delta.RecurrenceStability
