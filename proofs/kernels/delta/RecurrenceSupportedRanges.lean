import kernels.delta.GatedUpdateRelative
import kernels.delta.GatedRecurrentRanges
import kernels.delta.RecurrenceGrowth

namespace Inference.Kernels.Delta.RecurrenceSupportedRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open scoped BigOperators

structure Inputs (input : Recurrence.Inputs Float32) : Prop where
  key : ∀ i, (input.key i).isFinite = true ∧ |real (input.key i)| ≤ 2
  query : ∀ i, (input.query i).isFinite = true ∧ |real (input.query i)| ≤ 1/8
  value : input.value.isFinite = true ∧ |real input.value| ≤ (2 : ℝ)^(36 : Nat)
  decay : input.decay.isFinite = true ∧ |real input.decay| ≤ 1
  beta : input.beta.isFinite = true ∧ 0 ≤ real input.beta ∧ real input.beta ≤ 1
  keyEnergy : RecurrenceStability.energy (fun i => real (input.key i)) ≤ 2

theorem coordinate (x : Fin n → ℝ) (i : Fin n) : |x i| ≤ RecurrenceStability.magnitude x := by
  apply (sq_le_sq₀ (abs_nonneg _) (RecurrenceStability.magnitude_nonnegative _)).mp
  rw [sq_abs, RecurrenceStability.magnitude_square]
  exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)

theorem bound_inputs (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hs : ∀ i, (state i).isFinite = true)
    (size : RecurrenceStability.magnitude (fun i => real (state i)) ≤ (2 : ℝ)^(59 : Nat))
    (hi : Inputs input) : GatedRecurrentRanges.Inputs (Recurrence.bind state input) 59 := by
  constructor
  · intro i; rw [Recurrence.bind_state]
    exact ⟨hs i, by simpa only [zpow_ofNat] using (coordinate _ i).trans size⟩
  · intro i; simpa only [Recurrence.bind_key] using hi.key i
  · intro i; simpa only [Recurrence.bind_query] using hi.query i
  · simpa only [Recurrence.bind_value] using hi.value
  · simpa only [Recurrence.bind_decay] using hi.decay
  · rw [Recurrence.bind_beta]
    exact ⟨hi.beta.1, by rw [abs_of_nonneg hi.beta.2.1]; exact hi.beta.2.2⟩

theorem local_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hs : ∀ i, (state i).isFinite = true)
    (size : RecurrenceStability.magnitude (fun i => real (state i)) ≤ (2 : ℝ)^(59 : Nat))
    (hi : Inputs input) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)-
      Recurrence.targetStep (fun j => real (state j)) (RecurrenceNumericalStability.realInputs input) i) ≤
        (2 : ℝ)^(-17 : Int)*RecurrenceStability.magnitude (fun i => real (state i))+(2 : ℝ)^(35 : Nat) := by
  have bound := bound_inputs state input hs size hi
  have ranges := GatedRecurrentRanges.ranges (Recurrence.bind state input) flags platform.tree platform.coverage
    59 (by decide) (by decide) bound
  have stateReal : GatedPredictionRelative.state (Recurrence.bind state input) = (fun i => real (state i)) := by
    funext i
    exact congrArg real (Recurrence.bind_state state input i)
  have keyReal : GatedPredictionRelative.key (Recurrence.bind state input) = (fun i => real (input.key i)) := by
    funext i
    exact congrArg real (Recurrence.bind_key state input i)
  have h := GatedUpdateRelative.local_error (Recurrence.bind state input) flags platform.tree platform.coverage
    (fun i => by rw [Recurrence.bind_state]; exact ⟨hs i, ((coordinate _ i).trans size).trans (by norm_num)⟩)
    bound.key bound.decay (by rw [stateReal]; exact size) (by rw [keyReal]; exact hi.keyEnergy)
    bound.value.2 bound.beta.2 (fun i => (ranges.1 i).1)
  simp_rw [Gated.state_execution _ reduce platform flags, Gated.state_rank_one,
    Recurrence.bind_state, Recurrence.bind_key, Recurrence.bind_value, Recurrence.bind_decay, Recurrence.bind_beta] at h
  simpa only [Recurrence.step, Recurrence.targetStep_formula, RecurrenceNumericalStability.realInputs, stateReal] using h

theorem one_step (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hs : ∀ i, (state i).isFinite = true)
    (size : RecurrenceStability.magnitude (fun i => real (state i)) ≤ (2 : ℝ)^(59 : Nat))
    (hi : Inputs input) :
    (∀ i, (Recurrence.step reduce flags state input i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)) ≤
        (1+(2 : ℝ)^(-17 : Int))*RecurrenceStability.magnitude (fun i => real (state i))+(2 : ℝ)^(37 : Nat) := by
  have betaBound : |real input.beta| ≤ 1 := by rw [abs_of_nonneg hi.beta.2.1]; exact hi.beta.2.2
  have bound := bound_inputs state input hs size hi
  have ranges := GatedRecurrentRanges.ranges (Recurrence.bind state input) flags platform.tree platform.coverage
    59 (by decide) (by decide) bound
  have kn := RecurrenceStability.magnitude_nonnegative (fun i => real (input.key i))
  have keySquared := RecurrenceStability.magnitude_square (fun i => real (input.key i))
  have keyBound : RecurrenceStability.magnitude (fun i => real (input.key i)) ≤ (3/2 : ℝ) := by
    nlinarith only [keySquared, hi.keyEnergy]
  have stable : real input.beta*RecurrenceStability.energy (fun i => real (input.key i)) ≤ 2 :=
    (mul_le_mul_of_nonneg_right hi.beta.2.2 (RecurrenceStability.energy_nonnegative _)).trans
      (by simpa only [one_mul] using hi.keyEnergy)
  let ideal := Recurrence.targetStep (fun i => real (state i)) (RecurrenceNumericalStability.realInputs input)
  have rounding := local_error reduce platform flags state input hs size hi
  have target := RecurrenceStability.target_step_growth (fun i => real (state i))
    (RecurrenceNumericalStability.realInputs input) hi.decay.2 hi.beta.2.1 stable
  change RecurrenceStability.magnitude ideal ≤ RecurrenceStability.magnitude (fun i => real (state i))+
    |real input.beta*real input.value| * RecurrenceStability.magnitude (fun i => real (input.key i)) at target
  have betaValue : |real input.beta*real input.value| ≤ (2 : ℝ)^(36 : Nat) := by
    rw [abs_mul]
    exact (mul_le_mul betaBound hi.value.2 (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
  have forcing := mul_le_mul betaValue keyBound kn (by positivity : (0 : ℝ) ≤ 2^36)
  have triangle := RecurrenceStability.triangle
    (fun i => real (Recurrence.step reduce flags state input i)-ideal i) ideal
  simp only [sub_add_cancel] at triangle
  have total := triangle.trans (add_le_add rounding target)
  refine ⟨?_, ?_⟩
  · intro i
    have h := Arithmetic.finite_evaluate _ _ (ranges.1 i).1
    rwa [Gated.state_execution _ reduce platform flags i] at h
  · norm_num at total forcing ⊢
    nlinarith only [total, forcing]

-- The induction derives every intermediate instruction's finiteness from
-- the previous bounded state. No per-step finiteness or error premise is
-- supplied by the caller.
theorem run_uniform (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32)
    (initialFinite : ∀ i, (initial i).isFinite = true)
    (initialZero : RecurrenceStability.magnitude (fun i => real (initial i)) = 0)
    (steps : Nat) (bound : steps ≤ 262144) (hi : ∀ t, t < steps → Inputs (inputs t)) :
    ∀ t, t ≤ steps →
      (∀ i, (Recurrence.run reduce flags inputs initial t i).isFinite = true) ∧
        RecurrenceStability.magnitude (fun i => real (Recurrence.run reduce flags inputs initial t i)) ≤
          9*(2 : ℝ)^(55 : Nat) := by
  intro t
  induction t using Nat.strong_induction_on with
  | h t ih =>
    intro ht
    have step (j : Nat) (hj : j < t) := one_step reduce platform flags
      (Recurrence.run reduce flags inputs initial j) (inputs j)
      (ih j hj (by omega)).1
      ((ih j hj (by omega)).2.trans (by norm_num)) (hi j (by omega))
    refine ⟨?_, ?_⟩
    · cases t with
      | zero => exact initialFinite
      | succ k => exact (step k (by omega)).1
    · exact RecurrenceGrowth.zero_initial_supported
        (fun j => RecurrenceStability.magnitude (fun i => real (Recurrence.run reduce flags inputs initial j i)))
        t (by omega) initialZero (fun j hj => (step j hj).2)

end Inference.Kernels.Delta.RecurrenceSupportedRanges
