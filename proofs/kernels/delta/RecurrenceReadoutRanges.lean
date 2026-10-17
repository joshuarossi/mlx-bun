import kernels.delta.RecurrenceSupportedRanges

namespace Inference.Kernels.Delta.RecurrenceReadoutRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

set_option maxHeartbeats 800000 in
theorem value (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (state : Fin 128 → Float32) (input : Recurrence.Inputs Float32)
    (hs : ∀ i, (state i).isFinite = true)
    (size : RecurrenceStability.magnitude (fun i => real (state i)) ≤ (2 : ℝ)^(59 : Nat))
    (hi : RecurrenceSupportedRanges.Inputs input)
    (nextSize : RecurrenceStability.magnitude (fun i => real (Recurrence.step reduce flags state input i)) ≤
      9*(2 : ℝ)^(55 : Nat))
    (querySize : RecurrenceStability.magnitude (fun i => real (input.query i)) ≤ 1/8) :
    Arithmetic.Finite (Recurrence.bind state input) (Gated.outputExpr flags platform.tree) ∧
      Model.isFinite (Gated.value (Recurrence.bind state input) reduce flags) = true ∧
        |Model.toReal (Gated.value (Recurrence.bind state input) reduce flags)| ≤ (2 : ℝ)^(56 : Nat) := by
  let flat := Recurrence.bind state input
  have ranges := GatedRecurrentRanges.ranges flat flags platform.tree platform.coverage 59
    (by decide) (by decide) (RecurrenceSupportedRanges.bound_inputs state input hs size hi)
  have stateBound (i : Fin 128) : |real (Arithmetic.evaluate flat (Gated.stateExpr flags platform.tree i))| ≤
      (2 : ℝ)^(62 : Nat) := by
    rw [Gated.state_execution flat reduce platform flags i]
    exact ((RecurrenceSupportedRanges.coordinate _ i).trans nextSize).trans (by norm_num)
  have queryBound (i : Fin 128) : |real (Arithmetic.evaluate flat (.input (256+i.val)))| ≤ 2 := by
    change |real (Recurrence.bind state input (256+i.val))| ≤ 2
    rw [Recurrence.bind_query]
    exact (hi.query i).2.trans (by norm_num)
  have queryReal (i : Fin 128) : real (Arithmetic.evaluate flat (.input (256+i.val))) = real (input.query i) :=
    congrArg real (Recurrence.bind_query state input i)
  have error := GatedDotRelative.dot_norm_error flat flags.output platform.tree platform.coverage
    (Gated.stateExpr flags platform.tree) (fun i => .input (256+i.val)) stateBound queryBound ranges.2.1
  simp only [GatedDotRelative.term, queryReal] at error
  change |real (Arithmetic.evaluate flat (Gated.outputExpr flags platform.tree))-
      (∑ i : Fin 128, real (Arithmetic.evaluate flat (Gated.stateExpr flags platform.tree i))*real (input.query i))| ≤
        46*(2 : ℝ)^(-24 : Int)*
          RecurrenceStability.magnitude (fun i => real (Arithmetic.evaluate flat (Gated.stateExpr flags platform.tree i)))*
          RecurrenceStability.magnitude (fun i => real (input.query i))+(2 : ℝ)^(-50 : Int) at error
  simp_rw [Gated.state_execution flat reduce platform flags, Gated.output_execution flat reduce platform flags] at error
  have ideal := RecurrenceStability.cauchy (fun i => real (Recurrence.step reduce flags state input i))
    (fun i => real (input.query i))
  have absolute := NormalizedCastBounds.absolute_of_error _ _ _ error
  have product := mul_le_mul nextSize querySize (RecurrenceStability.magnitude_nonnegative _) (by positivity)
  have outputBound : |real (Gated.sourceOutput flat reduce flags)| ≤ (2 : ℝ)^(56 : Nat) := by
    change |∑ i : Fin 128, real (Gated.sourceState flat reduce flags i)*real (input.query i)| ≤
      RecurrenceStability.magnitude (fun i => real (Gated.sourceState flat reduce flags i))*
        RecurrenceStability.magnitude (fun i => real (input.query i)) at ideal
    change RecurrenceStability.magnitude (fun i => real (Gated.sourceState flat reduce flags i))*
      RecurrenceStability.magnitude (fun i => real (input.query i)) ≤ _ at product
    norm_num at absolute product ⊢
    nlinarith only [absolute, ideal, product]
  have finite := Arithmetic.finite_evaluate flat _ ranges.2.1
  rw [Gated.output_execution flat reduce platform flags] at finite
  have cap := BFloat16DyadicBounds.ceiling_range 1 56 (by decide) (by decide) (by decide)
  have cast := BFloat16ConversionBounds.narrow_range (Gated.sourceOutput flat reduce flags)
    (BFloat16DyadicBounds.ceiling 1 56) finite cap.1
    (by simpa only [cap.2, Nat.cast_one, one_mul, zpow_ofNat] using outputBound)
  exact ⟨ranges.2.1, cast.1, by simpa only [Gated.value, cap.2, Nat.cast_one, one_mul, zpow_ofNat] using cast.2⟩

theorem run_output (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (flags : Gated.Contraction) (inputs : Nat → Recurrence.Inputs Float32) (initial : Fin 128 → Float32)
    (initialFinite : ∀ i, (initial i).isFinite = true)
    (initialZero : RecurrenceStability.magnitude (fun i => real (initial i)) = 0)
    (time : Nat) (bound : time+1 ≤ 262144)
    (hi : ∀ t, t ≤ time → RecurrenceSupportedRanges.Inputs (inputs t))
    (querySize : RecurrenceStability.magnitude (fun i => real ((inputs time).query i)) ≤ 1/8) :
    Model.isFinite (Recurrence.outputAt reduce flags inputs initial time) = true ∧
      |Model.toReal (Recurrence.outputAt reduce flags inputs initial time)| ≤ (2 : ℝ)^(56 : Nat) := by
  have run := RecurrenceSupportedRanges.run_uniform reduce platform flags inputs initial initialFinite initialZero
    (time+1) bound (fun t ht => hi t (by omega))
  exact (value reduce platform flags _ _ (run time (by omega)).1
    ((run time (by omega)).2.trans (by norm_num)) (hi time (le_refl _))
      (run (time+1) (le_refl _)).2 querySize).2

end Inference.Kernels.Delta.RecurrenceReadoutRanges
