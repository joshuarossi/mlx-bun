import kernels.delta.GatedDeltaRelative

namespace Inference.Kernels.Delta.GatedUpdateRelative
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open scoped BigOperators

theorem constant_magnitude (value : ℝ) (hn : 0 ≤ value) :
    RecurrenceStability.magnitude (fun _ : Fin 128 => value) ≤ 16*value := by
  have hs := RecurrenceStability.magnitude_square (fun _ : Fin 128 => value)
  simp only [RecurrenceStability.energy, Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    nsmul_eq_mul, Nat.cast_ofNat] at hs
  nlinarith only [hs, hn, RecurrenceStability.magnitude_nonnegative (fun _ : Fin 128 => value)]

theorem two_terms (x y errors : Fin 128 → ℝ) (a b c : ℝ)
    (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c)
    (bound : ∀ i, |errors i| ≤ a*|x i|+b*|y i|+c) :
    RecurrenceStability.magnitude errors ≤ a*RecurrenceStability.magnitude x+
      b*RecurrenceStability.magnitude y+16*c := by
  have point := RecurrenceStability.pointwise_bound errors _ bound
  have outer := RecurrenceStability.triangle (fun i => a*|x i|+b*|y i|) (fun _ => c)
  have inner := RecurrenceStability.triangle (fun i => a*|x i|) (fun i => b*|y i|)
  rw [RecurrenceStability.magnitude_scale, RecurrenceStability.magnitude_scale,
    DecayStateBounds.magnitude_abs, DecayStateBounds.magnitude_abs, abs_of_nonneg ha, abs_of_nonneg hb] at inner
  exact point.trans (outer.trans (add_le_add inner (constant_magnitude c hc)))

theorem update_error (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (keyBound : ∀ i : Fin 128, |real (input (128+i.val))| ≤ 2)
    (deltaBound : |real (evaluate input (Gated.deltaExpr flags tree))| ≤ (2 : ℝ)^(62 : Nat))
    (hf : ∀ i, Arithmetic.Finite input (Gated.stateExpr flags tree i)) :
    RecurrenceStability.magnitude (fun i => real (evaluate input (Gated.stateExpr flags tree i))-
      (real (input (128+i.val))*real (evaluate input (Gated.deltaExpr flags tree))+
        real (evaluate input (Gated.decayedExpr i)))) ≤
      3*(2 : ℝ)^(-24 : Int)*
        (|real (evaluate input (Gated.deltaExpr flags tree))| * RecurrenceStability.magnitude (GatedPredictionRelative.key input)+
          RecurrenceStability.magnitude (fun i => real (evaluate input (Gated.decayedExpr i))))+(2 : ℝ)^(-56 : Int) := by
  have h := two_terms (GatedPredictionRelative.key input) (fun i => real (evaluate input (Gated.decayedExpr i)))
    (fun i => real (evaluate input (Gated.stateExpr flags tree i))-
      (real (input (128+i.val))*real (evaluate input (Gated.deltaExpr flags tree))+real (evaluate input (Gated.decayedExpr i))))
    (3*(2 : ℝ)^(-24 : Int)*|real (evaluate input (Gated.deltaExpr flags tree))|)
    (3*(2 : ℝ)^(-24 : Int)) ((2 : ℝ)^(-60 : Int)) (by positivity) (by positivity) (by positivity) (by
      intro i
      have h := ArithmeticMaddRelative.error_sum input flags.update (.input (128+i.val))
        (Gated.deltaExpr flags tree) (Gated.decayedExpr i) (hf i) (by
          change |real (input (128+i.val))|+|real (evaluate input (Gated.deltaExpr flags tree))| ≤ _
          have h := add_le_add (keyBound i) deltaBound
          linarith only [h])
      change |real (evaluate input (Gated.stateExpr flags tree i))-
        (real (input (128+i.val))*real (evaluate input (Gated.deltaExpr flags tree))+
          real (evaluate input (Gated.decayedExpr i)))| ≤ _ at h
      change _ ≤ _*|real (input (128+i.val))|+_+_
      simp only [Arithmetic.evaluate] at h
      nlinarith only [h])
  norm_num at h ⊢
  nlinarith only [h]

theorem ideal_state (input : Nat → Float32) (i : Fin 128) :
    Gated.state (fun j => real (input j)) i = real (input i.val)*real (input 385)+
      real (input (128+i.val))*GatedDeltaRelative.ideal input := by
  rw [Gated.state_rank_one]
  unfold GatedDeltaRelative.ideal GatedPredictionRelative.ideal GatedPredictionRelative.state GatedPredictionRelative.key
    RecurrenceStability.dot
  ring

theorem ideal_delta_bound (input : Nat → Float32) (hg : |real (input 385)| ≤ 1) (hb : |real (input 386)| ≤ 1) :
    |GatedDeltaRelative.ideal input| ≤ |real (input 384)|+
      RecurrenceStability.magnitude (GatedPredictionRelative.state input)*RecurrenceStability.magnitude (GatedPredictionRelative.key input) := by
  unfold GatedDeltaRelative.ideal
  rw [abs_mul]
  exact (mul_le_mul_of_nonneg_left hb (abs_nonneg _)).trans
    (by simpa only [mul_one] using ((abs_sub _ _).trans
      (add_le_add (le_refl _) (GatedPredictionRelative.ideal_bound input hg))))

-- The local rounding defect of the complete executed state update. This
-- is a software theorem, not a scalar hardware premise or an observed test.
theorem local_error (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32))
    (hs : ∀ i : Fin 128, (input i.val).isFinite = true ∧ |real (input i.val)| ≤ (2 : ℝ)^(62 : Nat))
    (hk : ∀ i : Fin 128, (input (128+i.val)).isFinite = true ∧ |real (input (128+i.val))| ≤ 2)
    (hg : (input 385).isFinite = true ∧ |real (input 385)| ≤ 1)
    (stateBound : RecurrenceStability.magnitude (GatedPredictionRelative.state input) ≤ (2 : ℝ)^(59 : Nat))
    (keyEnergy : RecurrenceStability.energy (GatedPredictionRelative.key input) ≤ 2)
    (valueBound : |real (input 384)| ≤ (2 : ℝ)^(36 : Nat))
    (betaBound : |real (input 386)| ≤ 1)
    (hf : ∀ i, Arithmetic.Finite input (Gated.stateExpr flags tree i)) :
    RecurrenceStability.magnitude (fun i => real (evaluate input (Gated.stateExpr flags tree i))-
      Gated.state (fun j => real (input j)) i) ≤
      (2 : ℝ)^(-17 : Int)*RecurrenceStability.magnitude (GatedPredictionRelative.state input)+(2 : ℝ)^(35 : Nat) := by
  let stateSize := RecurrenceStability.magnitude (GatedPredictionRelative.state input)
  let keySize := RecurrenceStability.magnitude (GatedPredictionRelative.key input)
  let valueSize := |real (input 384)|
  let delta := real (evaluate input (Gated.deltaExpr flags tree))
  let deltaTarget := GatedDeltaRelative.ideal input
  let decayed := fun i : Fin 128 => real (evaluate input (Gated.decayedExpr i))
  let updateErrors := fun i : Fin 128 => real (evaluate input (Gated.stateExpr flags tree i))-
    (GatedPredictionRelative.key input i*delta+decayed i)
  let decayErrors := fun i : Fin 128 => decayed i-real (input i.val)*real (input 385)
  let deltaErrors := fun i : Fin 128 => (delta-deltaTarget)*GatedPredictionRelative.key input i
  let deltaBudget := 51*(2 : ℝ)^(-24 : Int)*stateSize*keySize+3*(2 : ℝ)^(-24 : Int)*valueSize+(2 : ℝ)^(-47 : Int)
  have sn : 0 ≤ stateSize := RecurrenceStability.magnitude_nonnegative _
  have kn : 0 ≤ keySize := RecurrenceStability.magnitude_nonnegative _
  have vn : 0 ≤ valueSize := abs_nonneg _
  have keySquared : keySize^2 ≤ 2 := by
    rw [RecurrenceStability.magnitude_square]
    exact keyEnergy
  have keyBound : keySize ≤ 2 := by nlinarith only [keySquared]
  have deltaFinite := (ArithmeticDependencies.madd_finite input flags.update (.input (128+(0 : Fin 128).val))
    (Gated.deltaExpr flags tree) (Gated.decayedExpr 0) (hf 0)).2.1
  have hd := GatedDeltaRelative.error input flags tree coverage hs hk hg stateBound keyBound valueBound betaBound deltaFinite
  have deltaError : |delta-deltaTarget| ≤ deltaBudget := hd.2
  have deltaAbs : |delta| ≤ valueSize+stateSize*keySize+deltaBudget := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ deltaError
    have hi : |deltaTarget| ≤ valueSize+stateSize*keySize := ideal_delta_bound input hg.2 betaBound
    linarith only [h, hi]
  have decayContraction := (DecayStateBounds.contraction (fun i : Fin 128 => input i.val) (input 385)
    (fun i => (hs i).1) hg.1 hg.2).2
  change RecurrenceStability.magnitude decayed ≤ stateSize at decayContraction
  have update := update_error input flags tree (fun i => (hk i).2) hd.1 hf
  change RecurrenceStability.magnitude updateErrors ≤
    3*(2 : ℝ)^(-24 : Int)*(|delta| * keySize+RecurrenceStability.magnitude decayed)+(2 : ℝ)^(-56 : Int) at update
  have updateBound : RecurrenceStability.magnitude updateErrors ≤
      3*(2 : ℝ)^(-24 : Int)*(|delta| * keySize+stateSize)+(2 : ℝ)^(-56 : Int) := by
    norm_num at update ⊢
    linarith only [update, decayContraction]
  have decayBound : RecurrenceStability.magnitude decayErrors ≤ (2 : ℝ)^(-24 : Int)*stateSize+(2 : ℝ)^(-59 : Int) :=
    DecayStateBounds.error (fun i : Fin 128 => input i.val) (input 385) hs hg.1 hg.2
  have deltaBound : RecurrenceStability.magnitude deltaErrors ≤ deltaBudget*keySize := by
    rw [RecurrenceStability.magnitude_scale]
    exact mul_le_mul_of_nonneg_right deltaError kn
  have decomposition : (fun i => real (evaluate input (Gated.stateExpr flags tree i))-
      Gated.state (fun j => real (input j)) i) = fun i => updateErrors i+(decayErrors i+deltaErrors i) := by
    funext i
    rw [ideal_state]
    dsimp [updateErrors, decayErrors, deltaErrors, deltaTarget, GatedPredictionRelative.key]
    ring
  rw [decomposition]
  have triangle := (RecurrenceStability.triangle updateErrors (fun i => decayErrors i+deltaErrors i)).trans
    (add_le_add (le_refl _) (RecurrenceStability.triangle decayErrors deltaErrors))
  have total := triangle.trans (add_le_add updateBound (add_le_add decayBound deltaBound))
  have deltaKey := mul_le_mul_of_nonneg_right deltaAbs kn
  have stateKey := mul_le_mul_of_nonneg_left keySquared sn
  have valueKey := mul_le_mul_of_nonneg_left keyBound vn
  change _ ≤ (2 : ℝ)^(-17 : Int)*stateSize+(2 : ℝ)^(35 : Nat)
  change valueSize ≤ (2 : ℝ)^(36 : Nat) at valueBound
  dsimp [deltaBudget] at total deltaKey
  norm_num at total deltaKey valueBound ⊢
  nlinarith only [total, deltaKey, stateKey, valueKey, keyBound, valueBound, sn]

end Inference.Kernels.Delta.GatedUpdateRelative
