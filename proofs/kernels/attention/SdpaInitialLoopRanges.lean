import kernels.attention.SdpaInitialUpdateRanges
import kernels.attention.SdpaScoreRanges

namespace Inference.Kernels.Attention.SdpaInitialLoopRanges
open Contracts.Mlx Contracts.Mlx.Numerics SdpaUpdate SdpaVector
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Maximum instructions select an operand and preserve the maximum of the
-- flushed operands: with denormals disabled they compare flushed values.
-- This is a scalar/SIMD primitive contract, separate from the loop proof.
structure Maximum (p : SdpaVector.Platform) : Prop where
  pair : ∀ x y, x.isFinite = true → y.isFinite = true →
    (p.maximum x y = x ∨ p.maximum x y = y) ∧
      real (FlushToZero.flush (p.maximum x y)) = max (real (FlushToZero.flush x)) (real (FlushToZero.flush y))
  simd : ∀ input : Fin 32 → Float32, (∀ i, (input i).isFinite = true) →
    ∃ i, p.simdMaximum input = input i ∧ ∀ j, real (FlushToZero.flush (input j)) ≤ real (FlushToZero.flush (input i))

theorem initial_lt (score : Float32) (bound : |real score| ≤ (2 : ℝ)^(24 : Nat)) :
    real (FlushToZero.flush initialShift) < real (FlushToZero.flush score) := by
  rw [SdpaExponentRanges.initial_flush, SdpaExponentRanges.initial_real, Float32OverflowMargin.maximum_value]
  have h := (abs_le.mp ((FlushToZero.flush_abs_le score).trans bound)).1
  norm_num at h ⊢
  linarith

theorem choose_initial (p : SdpaVector.Platform) (maximum : Maximum p) (score : Float32)
    (hf : score.isFinite = true) (bound : |real score| ≤ (2 : ℝ)^(24 : Nat)) :
    p.maximum initialShift score = score := by
  have h := maximum.pair initialShift score initial_finite hf
  rcases h.1 with hi | hs
  · have hp := le_max_right (real (FlushToZero.flush initialShift)) (real (FlushToZero.flush score))
    rw [← h.2, hi] at hp
    exact False.elim ((not_le_of_gt (initial_lt score bound)) hp)
  · exact hs


theorem keys_initial (group : Fin 32) : SdpaLayout.keys 1 group = if group = 0 then [0] else [] := by
  by_cases hg : group = 0
  · subst group
    decide +kernel
  · rw [ite_eq_right hg]
    have hv : group.val ≠ 0 := by intro h; apply hg; exact Fin.ext h
    have hc : SdpaLayout.count 1 group = 0 := by
      unfold SdpaLayout.count
      have := group.isLt
      omega
    apply List.eq_nil_of_length_eq_zero
    simp only [SdpaLayout.keys, List.length_ofFn, hc]

theorem partials_eq (p : SdpaVector.Platform) (maximum : Maximum p)
    (query : Fin 256 → BF) (keys values : Fin 1 → Fin 256 → BF)
    (hs : (scores p query keys 0).isFinite = true) (bound : |real (scores p query keys 0)| ≤ (2 : ℝ)^(24 : Nat))
    (coordinate : Fin 256) (group : Fin 32) :
    partials p query keys values coordinate group = if group = 0 then
      step p.merge.scalar (SdpaLoop.initial initialShift) (scores p query keys 0)
        (valuesAt values coordinate 0) (scores p query keys 0)
      else SdpaLoop.initial initialShift := by
  rw [partials, keys_initial]
  split
  · simp only [SdpaLoop.run, SdpaLoop.next, SdpaLoop.initial, choose_initial p maximum _ hs bound]
  · rfl

structure PartialBounds (s : State) : Prop where
  shift : s.shift.isFinite = true
  denominator : s.denominator.isFinite = true
  numerator : s.numerator.isFinite = true
  denominatorRange : 0 ≤ real s.denominator ∧ real s.denominator ≤ 1
  numeratorRange : |real s.numerator| ≤ (2 : ℝ)^(23 : Nat)

structure Result (p : SdpaVector.Platform) (query : Fin 256 → BF) (keys values : Fin 1 → Fin 256 → BF) : Prop where
  scores : ∀ t, Arithmetic.Finite (SdpaScore.bind query (keys t)) (SdpaScore.expression p.scoreContracted p.merge.reduction.tree)
  scoreFinite : (SdpaVector.scores p query keys 0).isFinite = true
  scoreRange : |real (SdpaVector.scores p query keys 0)| ≤ (2 : ℝ)^(24 : Nat)
  loops : ∀ i g, SdpaLoop.Finite p.merge.scalar p.maximum (SdpaVector.scores p query keys) (valuesAt values i)
    (SdpaLayout.keys 1 g) (SdpaLoop.initial initialShift)
  partials : ∀ i g, PartialBounds (SdpaVector.partials p query keys values i g)
  common : commonShift p query keys values = SdpaVector.scores p query keys 0
  denominatorZero : ∀ i, real (SdpaVector.partials p query keys values i 0).denominator = 1
  shift : ∀ i g, (SdpaVector.partials p query keys values i g).shift =
    if g = 0 then SdpaVector.scores p query keys 0 else initialShift

theorem ranges (p : SdpaVector.Platform) (maximum : Maximum p) (primitive : SdpaExponentRanges.Primitive p.merge.scalar)
    (query : Fin 256 → BF) (keys values : Fin 1 → Fin 256 → BF)
    (hq : ∀ i, Model.isFinite (query i) = true ∧ |Model.toReal (query i)| ≤ 1024)
    (hk : ∀ t i, Model.isFinite (keys t i) = true ∧ |Model.toReal (keys t i)| ≤ 1024)
    (hv : ∀ t i, Model.isFinite (values t i) = true ∧ |Model.toReal (values t i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Result p query keys values := by
  have scores t := SdpaScoreRanges.ranges p.scoreContracted p.merge.reduce p.merge.reduction query (keys t) hq (hk t)
  have hs : (SdpaVector.scores p query keys 0).isFinite = true := SdpaScore.source_finite _ _ _ _ _ (scores 0).1
  have hb : |real (SdpaVector.scores p query keys 0)| ≤ (2 : ℝ)^(24 : Nat) := (scores 0).2
  have update i := SdpaInitialUpdateRanges.ranges p.merge.scalar primitive (SdpaVector.scores p query keys 0)
    (valuesAt values i 0) hs hb (BFloat16.widen_finite _ (hv 0 i).1)
    (by rw [valuesAt, BFloat16.widen_real _ (hv 0 i).1]; exact (hv 0 i).2)
  have hp i g : PartialBounds (SdpaVector.partials p query keys values i g) := by
    rw [partials_eq p maximum query keys values hs hb]
    split
    · have hf := step_finite _ _ _ _ _ (update i).1
      exact ⟨hf.1, hf.2.1, hf.2.2, by rw [(update i).2.1]; norm_num, (update i).2.2⟩
    · exact ⟨initial_finite, by decide, by decide, by simp [SdpaLoop.initial, FlushedIdentities.zero_real],
        by simp [SdpaLoop.initial, FlushedIdentities.zero_real]⟩
  have hshift i g : (SdpaVector.partials p query keys values i g).shift =
      if g = 0 then SdpaVector.scores p query keys 0 else initialShift := by
    rw [partials_eq p maximum query keys values hs hb]
    split <;> rfl
  have common : commonShift p query keys values = SdpaVector.scores p query keys 0 := by
    obtain ⟨g, selected, largest⟩ := maximum.simd (fun g => (SdpaVector.partials p query keys values 0 g).shift)
      (fun g => (hp 0 g).shift)
    by_cases hg : g = 0
    · change p.simdMaximum (fun g => (SdpaVector.partials p query keys values 0 g).shift) = _
      rw [selected, hshift, ite_eq_left hg]
    · have h := largest 0
      simp only [hshift, hg, ite_false, ite_true] at h
      exact False.elim ((not_le_of_gt (initial_lt _ hb)) h)
  refine ⟨fun t => (scores t).1, hs, hb, ?_, hp, common, ?_, hshift⟩
  · intro i g
    rw [keys_initial]
    split
    · simp only [SdpaLoop.Finite, SdpaLoop.initial, choose_initial p maximum _ hs hb, and_true]
      exact (update i).1
    · trivial
  · intro i
    rw [partials_eq p maximum query keys values hs hb, ite_eq_left rfl]
    exact (update i).2.1

end Inference.Kernels.Attention.SdpaInitialLoopRanges
