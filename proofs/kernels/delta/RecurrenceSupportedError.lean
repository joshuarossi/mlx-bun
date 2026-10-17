import kernels.delta.RecurrenceSupportedRanges

namespace Inference.Kernels.Delta.RecurrenceSupportedError
open Contracts.Mlx Contracts.Mlx.Numerics
open scoped BigOperators

-- This isolates recurrent arithmetic error using the actual rounded input
-- sequence. Errors in producing that input sequence remain upstream.
theorem run_error (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32)
    (initialFinite : ∀ i, (initial i).isFinite = true)
    (initialZero : RecurrenceStability.magnitude (fun i => real (initial i)) = 0)
    (steps : Nat) (bound : steps ≤ 262144)
    (hi : ∀ t, t < steps → RecurrenceSupportedRanges.Inputs (inputs t)) :
    RecurrenceStability.magnitude (fun i => real (Recurrence.run reduce flags inputs initial steps i)-
      Recurrence.targetRun (fun t => RecurrenceNumericalStability.realInputs (inputs t))
        (fun i => real (initial i)) steps i) ≤
          (steps : ℝ)*((2 : ℝ)^(-17 : Int)*(9*(2 : ℝ)^(55 : Nat))+(2 : ℝ)^(35 : Nat)) := by
  have run := RecurrenceSupportedRanges.run_uniform reduce platform flags inputs initial initialFinite initialZero steps bound hi
  have stable (t : Nat) (ht : t < steps) : real (inputs t).beta*
      RecurrenceStability.energy (fun i => real ((inputs t).key i)) ≤ 2 :=
    (mul_le_mul_of_nonneg_right (hi t ht).beta.2.2 (RecurrenceStability.energy_nonnegative _)).trans
      (by simpa only [one_mul] using (hi t ht).keyEnergy)
  have localError (t : Nat) (ht : t < steps) := RecurrenceSupportedRanges.local_error reduce platform flags
    (Recurrence.run reduce flags inputs initial t) (inputs t) (run t (by omega)).1
    ((run t (by omega)).2.trans (by norm_num)) (hi t ht)
  have h := RecurrenceStability.error_accumulation
    (fun t => RecurrenceNumericalStability.realInputs (inputs t))
    (fun t i => real (Recurrence.run reduce flags inputs initial t i)) (fun i => real (initial i))
    (fun _ => (2 : ℝ)^(-17 : Int)*(9*(2 : ℝ)^(55 : Nat))+(2 : ℝ)^(35 : Nat)) steps
    (fun t ht => (hi t ht).decay.2) (fun t ht => (hi t ht).beta.2.1) stable (fun t ht =>
      (localError t ht).trans (add_le_add
        (mul_le_mul_of_nonneg_left (run t (by omega)).2 (by positivity)) (le_refl _)))
  have zero : RecurrenceStability.magnitude (fun i => real (initial i)-real (initial i)) = 0 := by
    simp [RecurrenceStability.magnitude, RecurrenceStability.energy]
  simpa only [Recurrence.run, zero, zero_add, Finset.sum_const, Finset.card_range, nsmul_eq_mul] using h

end Inference.Kernels.Delta.RecurrenceSupportedError
