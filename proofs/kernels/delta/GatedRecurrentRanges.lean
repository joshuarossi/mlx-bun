import kernels.delta.GatedRanges

namespace Inference.Kernels.Delta.GatedRecurrentRanges
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- These bounds establish finiteness of every instruction for an incoming
-- state interval. The tighter outgoing norm is established separately by
-- recurrence stability; the coarse coordinate bound here is not inductive.
structure Inputs (input : Nat → Float32) (exponent : Int) : Prop where
  state : ∀ i : Fin 128, (input i.val).isFinite = true ∧ |real (input i.val)| ≤ (2 : ℝ)^exponent
  key : ∀ i : Fin 128, (input (128+i.val)).isFinite = true ∧ |real (input (128+i.val))| ≤ 2
  query : ∀ i : Fin 128, (input (256+i.val)).isFinite = true ∧ |real (input (256+i.val))| ≤ 1/8
  value : (input 384).isFinite = true ∧ |real (input 384)| ≤ (2 : ℝ)^(36 : Nat)
  decay : (input 385).isFinite = true ∧ |real (input 385)| ≤ 1
  beta : (input 386).isFinite = true ∧ |real (input 386)| ≤ 1

private theorem cap (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100) :
    (DyadicBounds.ceiling 1 exponent).isFinite = true ∧
      real (DyadicBounds.ceiling 1 exponent) = (2 : ℝ)^exponent := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 exponent (by decide) lo hi

theorem ranges (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (exponent : Int)
    (lower : 36 ≤ exponent) (upper : exponent ≤ 70) (hx : Inputs input exponent) :
    (∀ i, Arithmetic.Finite input (Gated.stateExpr flags tree i) ∧
      |real (evaluate input (Gated.stateExpr flags tree i))| ≤ (2 : ℝ)^(exponent+11)) ∧
    Arithmetic.Finite input (Gated.outputExpr flags tree) ∧
      |real (evaluate input (Gated.outputExpr flags tree))| ≤ (2 : ℝ)^(exponent+15) := by
  have hd (i : Fin 128) := GatedRanges.mul_range input (.input i.val) (.input 385) exponent (by omega) (by omega)
    (hx.state i).1 hx.decay.1 (by
      simp only [evaluate]
      exact (mul_le_mul (hx.state i).2 hx.decay.2 (abs_nonneg _) (by positivity)).trans_eq (mul_one _))
  have hp := GatedRanges.dot_range input flags.prediction tree coverage Gated.decayedExpr (fun i => .input (128+i.val))
    exponent 1 (by omega) (by omega) hd (fun i => by
      norm_num only [Arithmetic.Finite, evaluate, zpow_one]
      exact hx.key i)
  have prediction : |real (evaluate input (Gated.predictionExpr flags tree))| ≤ (2 : ℝ)^(exponent+8) := by
    simpa only [Gated.predictionExpr, show exponent+1+7 = exponent+8 from by omega] using hp.2
  have valueBound : |real (input 384)| ≤ (2 : ℝ)^(exponent+8) := by
    exact hx.value.2.trans (by
      rw [← zpow_natCast]
      exact zpow_le_zpow_right₀ (by norm_num) (by omega))
  have subcap := cap (exponent+9) (by omega) (by omega)
  have hs := Float32Bounds.sub_range (input 384) (evaluate input (Gated.predictionExpr flags tree))
    (DyadicBounds.ceiling 1 (exponent+9)) hx.value.1 (finite_evaluate _ _ hp.1) subcap.1 (by
      rw [subcap.2]
      calc
        _ ≤ (2 : ℝ)^(exponent+8)+(2 : ℝ)^(exponent+8) := add_le_add valueBound prediction
        _ = _ := by
          rw [show exponent+9 = (exponent+8)+1 from by omega,
            zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0) (exponent+8) 1, zpow_one]
          ring)
  have subfinite : Arithmetic.Finite input (.sub (.input 384) (Gated.predictionExpr flags tree)) := ⟨hx.value.1, hp.1, hs.1⟩
  have hdelta := GatedRanges.mul_range input (.sub (.input 384) (Gated.predictionExpr flags tree)) (.input 386)
    (exponent+9) (by omega) (by omega) subfinite hx.beta.1 (by
      have hb : |real (evaluate input (.sub (.input 384) (Gated.predictionExpr flags tree)))| ≤ (2 : ℝ)^(exponent+9) := by
        simpa only [evaluate, subcap.2] using hs.2
      exact (mul_le_mul hb hx.beta.2 (abs_nonneg _) (by positivity)).trans_eq (mul_one _))
  have hstate (i : Fin 128) := ArithmeticFoldBounds.madd_range input flags.update (.input (128+i.val))
    (Gated.deltaExpr flags tree) (Gated.decayedExpr i) 1 (exponent+9) 1 (by omega) (by omega) (by decide)
    (by norm_num only [Arithmetic.Finite, evaluate, zpow_one]; exact hx.key i) hdelta
    ⟨(hd i).1, (hd i).2.trans (by
      simp only [Nat.cast_one, one_mul]
      exact zpow_le_zpow_right₀ (by norm_num) (by omega))⟩
  have state (i : Fin 128) : Arithmetic.Finite input (Gated.stateExpr flags tree i) ∧
      |real (evaluate input (Gated.stateExpr flags tree i))| ≤ (2 : ℝ)^(exponent+11) := by
    have he : (2 : ℝ)^(exponent+11) = 2*(2 : ℝ)^(1+(exponent+9)) := by
      rw [show exponent+11 = 1+(1+(exponent+9)) from by omega, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0), zpow_one]
    simpa only [Gated.stateExpr, Nat.cast_add, Nat.cast_one, show (1 : ℝ)+1 = 2 from by norm_num, he] using hstate i
  have output := GatedRanges.dot_range input flags.output tree coverage (Gated.stateExpr flags tree)
    (fun i => .input (256+i.val)) (exponent+11) (-3) (by omega) (by omega) state (fun i => by
      norm_num only [Arithmetic.Finite, evaluate, zpow_neg, zpow_ofNat]
      exact hx.query i)
  refine ⟨state, output.1, ?_⟩
  simpa only [Gated.outputExpr, show exponent+11+(-3)+7 = exponent+15 from by omega] using output.2

theorem value (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (exponent : Int) (lower : 36 ≤ exponent) (upper : exponent ≤ 70) (hx : Inputs input exponent) :
    Model.isFinite (Gated.value input reduce flags) = true ∧
      |Model.toReal (Gated.value input reduce flags)| ≤ (2 : ℝ)^(exponent+15) := by
  have h := ranges input flags platform.tree platform.coverage exponent lower upper hx
  have hf := finite_evaluate input _ h.2.1
  rw [Gated.output_execution input reduce platform flags] at hf
  have hb := h.2.2
  rw [Gated.output_execution input reduce platform flags] at hb
  have hc := BFloat16DyadicBounds.ceiling_range 1 (exponent+15) (by decide) (by omega) (by omega)
  have hn := BFloat16ConversionBounds.narrow_range (Gated.sourceOutput input reduce flags)
    (BFloat16DyadicBounds.ceiling 1 (exponent+15)) hf hc.1 (by simpa only [hc.2, Nat.cast_one, one_mul] using hb)
  exact ⟨hn.1, by simpa only [Gated.value, hc.2, Nat.cast_one, one_mul] using hn.2⟩

end Inference.Kernels.Delta.GatedRecurrentRanges
