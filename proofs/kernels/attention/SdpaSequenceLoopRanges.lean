import kernels.attention.SdpaLoopBounds

namespace Inference.Kernels.Attention.SdpaSequenceLoopRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaVector
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure PartialBounds (s : State) (count : Nat) : Prop where
  shift : s.shift.isFinite = true
  denominator : s.denominator.isFinite = true
  numerator : s.numerator.isFinite = true
  denominatorRange : 0 ≤ real s.denominator ∧ real s.denominator ≤ (count : ℝ)
  numeratorRange : |real s.numerator| ≤ (2 : ℝ)^(25 : Nat)*real s.denominator
  active : 0 < count → |real s.shift| ≤ (2 : ℝ)^(24 : Nat) ∧ 1 ≤ real s.denominator
  empty : count = 0 → s = SdpaLoop.initial initialShift

theorem group_length (steps : Nat) (group : Fin 32) :
    (SdpaLayout.keys steps group).length = SdpaLayout.count steps group := by
  simp only [SdpaLayout.keys, List.length_ofFn]

theorem group_bound (steps : Nat) (bound : steps ≤ 262144) (group : Fin 32) :
    SdpaLayout.count steps group ≤ 8192 := by
  unfold SdpaLayout.count
  omega

structure Result (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF) : Prop where
  scores : ∀ t, Arithmetic.Finite (SdpaScore.bind query (keys t)) (SdpaScore.expression p.scoreContracted p.merge.reduction.tree)
  loops : ∀ i g, SdpaLoop.Finite p.merge.scalar p.maximum (SdpaVector.scores p query keys) (valuesAt values i)
    (SdpaLayout.keys steps g) (SdpaLoop.initial initialShift)
  partials : ∀ i g, PartialBounds (SdpaVector.partials p query keys values i g) (SdpaLayout.count steps g)
  common : (commonShift p query keys values).isFinite = true ∧
    |real (commonShift p query keys values)| ≤ (2 : ℝ)^(24 : Nat)
  exponent : ∀ i g,
    ExponentFinite p.merge.scalar (SdpaVector.partials p query keys values i g).shift (commonShift p query keys values) ∧
      0 ≤ real (exponential p.merge.scalar (SdpaVector.partials p query keys values i g).shift (commonShift p query keys values)) ∧
      real (exponential p.merge.scalar (SdpaVector.partials p query keys values i g).shift (commonShift p query keys values)) ≤ 1
  witness : ∃ g, ∀ i, 1 ≤ real (SdpaVector.partials p query keys values i g).denominator ∧
    real (exponential p.merge.scalar (SdpaVector.partials p query keys values i g).shift (commonShift p query keys values)) = 1

theorem ranges (p : SdpaVector.Platform) (maximum : SdpaInitialLoopRanges.Maximum p)
    (primitive : SdpaExponentRanges.Primitive p.merge.scalar) (steps : Nat) (positive : 0 < steps) (bound : steps ≤ 262144)
    (query : Fin 256 → BF) (keys values : Fin steps → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Result p query keys values := by
  have scoreRange t := SdpaScoreRanges.ranges p.scoreContracted p.merge.reduce p.merge.reduction query (keys t) hq (hk t)
  have hs t : (SdpaVector.scores p query keys t).isFinite = true ∧
      |real (SdpaVector.scores p query keys t)| ≤ (2 : ℝ)^(24 : Nat) :=
    ⟨SdpaScore.source_finite _ _ _ _ _ (scoreRange t).1, (scoreRange t).2⟩
  have valuesRange i t : (valuesAt values i t).isFinite = true ∧
      |real (valuesAt values i t)| ≤ (2 : ℝ)^(23 : Nat) :=
    ⟨BFloat16.widen_finite _ (hv t i).1, by rw [valuesAt, BFloat16.widen_real _ (hv t i).1]; exact (hv t i).2⟩
  have groups (i : Fin 256) (g : Fin 32) :
      SdpaLoop.Finite p.merge.scalar p.maximum (SdpaVector.scores p query keys) (valuesAt values i)
        (SdpaLayout.keys steps g) (SdpaLoop.initial initialShift) ∧
      PartialBounds (SdpaVector.partials p query keys values i g) (SdpaLayout.count steps g) := by
    by_cases empty : SdpaLayout.keys steps g = []
    · have countZero : SdpaLayout.count steps g = 0 := by rw [← group_length, empty]; rfl
      have state : SdpaVector.partials p query keys values i g = SdpaLoop.initial initialShift := by
        rw [SdpaVector.partials, empty, SdpaLoop.run]
      refine ⟨by rw [empty]; trivial, ?_⟩
      rw [state, countZero]
      exact ⟨initial_finite, by decide, by decide,
        by simp only [SdpaLoop.initial, FlushedIdentities.zero_real, Nat.cast_zero, le_refl, and_self],
        by simp only [SdpaLoop.initial, FlushedIdentities.zero_real, abs_zero, mul_zero, le_refl],
        by intro h; omega, fun _ => rfl⟩
    · have loop := SdpaLoopBounds.initialized p maximum primitive (SdpaVector.scores p query keys) (valuesAt values i)
        hs (valuesRange i) (SdpaLayout.keys steps g) empty (by rw [group_length]; exact group_bound steps bound g)
      rw [group_length] at loop
      have ratio := (SdpaLoopBounds.ratio_bounds (SdpaLayout.count steps g) (group_bound steps bound g)).2
      have positiveDen : 0 ≤ real (SdpaVector.partials p query keys values i g).denominator := by
        have h := loop.2.denominator.2.1
        change 1 ≤ real (SdpaVector.partials p query keys values i g).denominator at h
        linarith only [h]
      refine ⟨loop.1, ⟨loop.2.shift.1, loop.2.denominator.1, loop.2.numerator.1,
        ⟨positiveDen, loop.2.denominator.2.2⟩,
        loop.2.numerator.2.trans (mul_le_mul_of_nonneg_right ratio positiveDen),
        fun _ => ⟨loop.2.shift.2, loop.2.denominator.2.1⟩, ?_⟩⟩
      intro h
      exact False.elim (empty (List.eq_nil_of_length_eq_zero (by rw [group_length, h])))
  have hp i g := (groups i g).2
  obtain ⟨winner, selected, largest⟩ := maximum.simd
    (fun g => (SdpaVector.partials p query keys values 0 g).shift) (fun g => (hp 0 g).shift)
  have groupZero : 0 < SdpaLayout.count steps 0 := by unfold SdpaLayout.count; simp only [Fin.val_zero]; omega
  have winnerActive : 0 < SdpaLayout.count steps winner := by
    by_contra inactive
    have zero : SdpaLayout.count steps winner = 0 := by omega
    have bad := largest 0
    rw [(hp 0 winner).empty zero] at bad
    change real (SdpaVector.partials p query keys values 0 0).shift ≤ real initialShift at bad
    exact (not_le_of_gt (SdpaInitialLoopRanges.initial_lt _ ((hp 0 0).active groupZero).1)) bad
  have common : (commonShift p query keys values).isFinite = true ∧
      |real (commonShift p query keys values)| ≤ (2 : ℝ)^(24 : Nat) := by
    unfold commonShift
    rw [selected]
    exact ⟨(hp 0 winner).shift, ((hp 0 winner).active winnerActive).1⟩
  have order i g : real (SdpaVector.partials p query keys values i g).shift ≤ real (commonShift p query keys values) := by
    rw [(partials_shared p query keys values i 0 g).1]
    change _ ≤ real (p.simdMaximum _)
    rw [selected]
    exact largest g
  refine ⟨fun t => (scoreRange t).1, fun i g => (groups i g).1, hp, common, ?_, ?_⟩
  · intro i g
    by_cases empty : SdpaLayout.count steps g = 0
    · rw [(hp i g).empty empty]
      exact SdpaExponentRanges.initial p.merge.scalar primitive _ common.1 common.2
    · exact SdpaOrderedExponentRanges.ordered p.merge.scalar primitive _ _
        ⟨(hp i g).shift, ((hp i g).active (by omega)).1⟩ common (order i g)
  · refine ⟨winner, fun i => ⟨((hp i winner).active winnerActive).2, ?_⟩⟩
    rw [(partials_shared p query keys values i 0 winner).1]
    change real (exponential _ _ (p.simdMaximum _)) = 1
    rw [selected]
    exact (SdpaExponentRanges.diagonal p.merge.scalar primitive _ (hp 0 winner).shift).2

end Inference.Kernels.Attention.SdpaSequenceLoopRanges
