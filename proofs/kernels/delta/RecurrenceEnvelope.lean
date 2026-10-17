import kernels.delta.RecurrenceSupportedRanges

namespace Inference.Kernels.Delta.RecurrenceEnvelope
open Contracts.Mlx Contracts.Mlx.Numerics

-- A cache contract indexed by the number of processed tokens. Its successor
-- is derived by one actual decode step, so graph composition need not assume
-- a fresh zero state at every token or reconstruct the complete input stream.
noncomputable def bound (time : Nat) : ℝ :=
  (time : ℝ)*(2 : ℝ)^(37 : Nat)*(1+(2 : ℝ)^(-17 : Int))^time

theorem zero : bound 0 = 0 := by simp [bound]

theorem upper (time : Nat) (supported : time ≤ 262144) : bound time ≤ 9*(2 : ℝ)^(55 : Nat) := by
  have count : (time : ℝ) ≤ 262144 := by exact_mod_cast supported
  have power := RecurrenceGrowth.supported_growth time supported
  have h := mul_le_mul (mul_le_mul_of_nonneg_right count (by positivity : (0 : ℝ) ≤ 2^37))
    power (by positivity) (by positivity : (0 : ℝ) ≤ 262144*2^37)
  change bound time ≤ _ at h
  exact h.trans (by norm_num)

theorem next (time : Nat) : (1+(2 : ℝ)^(-17 : Int))*bound time+(2 : ℝ)^(37 : Nat) ≤ bound (time+1) := by
  have power : 1 ≤ (1+(2 : ℝ)^(-17 : Int))^(time+1) := one_le_pow₀ (by norm_num)
  have extra := mul_le_mul_of_nonneg_right power (by positivity : (0 : ℝ) ≤ 2^37)
  unfold bound
  push_cast
  rw [pow_succ (1+(2 : ℝ)^(-17 : Int)) time] at extra ⊢
  nlinarith only [extra]

theorem step (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (time : Nat) (supported : time+1 ≤ 262144)
    (hs : ∀ i, (state i).isFinite = true)
    (size : RecurrenceStability.magnitude (fun i => real (state i)) ≤ bound time)
    (hi : RecurrenceSupportedRanges.Inputs input) :
    (∀ i, (Recurrence.step reduce flags state input i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)) ≤ bound (time+1) := by
  have h := RecurrenceSupportedRanges.one_step reduce platform flags state input hs
    (size.trans ((upper time (by omega)).trans (by norm_num))) hi
  exact ⟨h.1, h.2.trans ((add_le_add
    (mul_le_mul_of_nonneg_left size (by positivity)) (le_refl _)).trans (next time))⟩

end Inference.Kernels.Delta.RecurrenceEnvelope
