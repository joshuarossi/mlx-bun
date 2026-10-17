import kernels.delta.RecurrenceNumericalStability
import Mathlib.Analysis.Complex.ExponentialBounds

namespace Inference.Kernels.Delta.RecurrenceGrowth
open Contracts.Mlx Contracts.Mlx.Numerics

-- Discrete growth bound for local relative rounding plus bounded forcing.
-- Binding the local numerical budget to `relative` and `forcing` is a
-- separate kernel theorem, not assumed to follow from finiteness alone.
theorem affine_growth (size : Nat → ℝ) (relative forcing : ℝ) (steps : Nat)
    (hr : 0 ≤ relative) (hf : 0 ≤ forcing)
    (step : ∀ t, t < steps → size (t+1) ≤ (1+relative)*size t+forcing) :
    size steps ≤ (size 0+(steps : ℝ)*forcing)*(1+relative)^steps := by
  induction steps with
  | zero => simp
  | succ t ih =>
    have previous := ih (fun j hj => step j (by omega))
    have scaled := mul_le_mul_of_nonneg_left previous (by linarith : 0 ≤ 1+relative)
    have upperPower : 1 ≤ (1+relative)^(t+1) := one_le_pow₀ (by linarith)
    have extra := mul_le_mul_of_nonneg_right upperPower hf
    rw [pow_succ] at extra
    have result := (step t (by omega)).trans (add_le_add scaled (le_refl forcing))
    push_cast
    rw [pow_succ]
    nlinarith only [result, extra]

theorem supported_growth (steps : Nat) (bound : steps ≤ 262144) :
    (1+(2 : ℝ)^(-17 : Int))^steps ≤ 9 := by
  have step : 1+(2 : ℝ)^(-17 : Int) ≤ Real.exp ((2 : ℝ)^(-17 : Int)) := by
    simpa only [add_comm] using Real.add_one_le_exp ((2 : ℝ)^(-17 : Int))
  have hp := pow_le_pow_left₀ (by positivity : (0 : ℝ) ≤ 1+(2 : ℝ)^(-17 : Int)) step steps
  rw [← Real.exp_nat_mul] at hp
  have duration : (steps : ℝ)*(2 : ℝ)^(-17 : Int) ≤ 2 := by
    have hn : (steps : ℝ) ≤ 262144 := by exact_mod_cast bound
    norm_num
    linarith only [hn]
  have exponential := Real.exp_le_exp.mpr duration
  have two : Real.exp (2 : ℝ) ≤ 9 := by
    rw [show (2 : ℝ) = 1+1 from by norm_num, Real.exp_add]
    nlinarith only [Real.exp_one_lt_three, Real.exp_pos (1 : ℝ)]
  exact hp.trans (exponential.trans two)

theorem zero_initial_supported (size : Nat → ℝ) (steps : Nat) (bound : steps ≤ 262144)
    (initial : size 0 = 0)
    (step : ∀ t, t < steps → size (t+1) ≤ (1+(2 : ℝ)^(-17 : Int))*size t+(2 : ℝ)^(37 : Nat)) :
    size steps ≤ 9*(2 : ℝ)^(55 : Nat) := by
  have growth := affine_growth size ((2 : ℝ)^(-17 : Int)) ((2 : ℝ)^(37 : Nat)) steps
    (by positivity) (by positivity) step
  rw [initial, zero_add] at growth
  have hp := supported_growth steps bound
  have hn : (steps : ℝ) ≤ 262144 := by exact_mod_cast bound
  calc
    _ ≤ ((steps : ℝ)*(2 : ℝ)^(37 : Nat))*(1+(2 : ℝ)^(-17 : Int))^steps := growth
    _ ≤ (262144*(2 : ℝ)^(37 : Nat))*9 :=
      mul_le_mul (mul_le_mul_of_nonneg_right hn (by positivity)) hp (by positivity) (by positivity)
    _ = _ := by norm_num

end Inference.Kernels.Delta.RecurrenceGrowth
