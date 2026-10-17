import kernels.delta.Gated
import contracts.mlx.ArithmeticFoldBounds
import contracts.mlx.AdditionFoldBounds
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Kernels.Delta.GatedRanges
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem dot_range (input : Nat → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (a b : Fin 128 → Expr)
    (ea eb : Int) (lo : -149 ≤ ea+eb) (hi : ea+eb ≤ 100)
    (ha : ∀ i, Arithmetic.Finite input (a i) ∧ |real (evaluate input (a i))| ≤ (2 : ℝ)^ea)
    (hb : ∀ i, Arithmetic.Finite input (b i) ∧ |real (evaluate input (b i))| ≤ (2 : ℝ)^eb) :
    Arithmetic.Finite input (Gated.dotExpr contracted tree a b) ∧
      |real (evaluate input (Gated.dotExpr contracted tree a b))| ≤ (2 : ℝ)^(ea+eb+7) := by
  have lanes (lane : Fin 32) := ArithmeticFoldBounds.from_zero input contracted
    (fun i => a (Gated.laneIndex lane i)) (fun i => b (Gated.laneIndex lane i)) ea eb lo hi
    (fun i => ha _) (fun i => hb _) (List.finRange 4) (by simp)
  have h := AdditionFoldBounds.reduce_range input (Gated.laneExpr contracted a b) (ea+eb) 4 lo hi
    (fun lane => by simpa only [Gated.laneExpr, List.length_finRange, Nat.cast_ofNat] using lanes lane)
    tree (by rw [coverage.length_eq, List.length_finRange]; decide)
  refine ⟨h.1, ?_⟩
  have size : (Reduction.leaves tree).length = 32 := by simpa only [List.length_finRange] using coverage.length_eq
  rw [size] at h
  calc
    _ ≤ ((32*4 : Nat) : ℝ) * (2 : ℝ)^(ea+eb) := h.2
    _ = _ := by rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0) (ea+eb) 7]; norm_num; ring

private theorem cap (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 e (by decide) lo hi

theorem mul_range (input : Nat → Float32) (a b : Expr) (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100)
    (ha : Arithmetic.Finite input a) (hb : Arithmetic.Finite input b)
    (bound : |real (evaluate input a)| * |real (evaluate input b)| ≤ (2 : ℝ)^e) :
    Arithmetic.Finite input (.mul a b) ∧ |real (evaluate input (.mul a b))| ≤ (2 : ℝ)^e := by
  have h := NativeMultiplication.range (evaluate input a) (evaluate input b) (DyadicBounds.ceiling 1 e)
    (finite_evaluate input a ha) (finite_evaluate input b hb) (cap e lo hi).1 (by rw [(cap e lo hi).2]; exact bound)
  exact ⟨⟨ha, hb, h.1⟩, by simpa only [evaluate, (cap e lo hi).2] using h.2⟩

-- Incoming-state bound used by the zero-initialized first-token path.
-- Later tokens need a propagated state invariant; this theorem does not
-- assert that its outgoing state satisfies this smaller incoming bound.
structure InitialInputs (input : Nat → Float32) : Prop where
  state : ∀ i : Fin 128, (input i.val).isFinite = true ∧ |real (input i.val)| ≤ 1
  key : ∀ i : Fin 128, (input (128+i.val)).isFinite = true ∧ |real (input (128+i.val))| ≤ 8
  query : ∀ i : Fin 128, (input (256+i.val)).isFinite = true ∧ |real (input (256+i.val))| ≤ 1/2
  value : (input 384).isFinite = true ∧ |real (input 384)| ≤ (2 : ℝ)^(36 : Nat)
  decay : (input 385).isFinite = true ∧ |real (input 385)| ≤ 1
  beta : (input 386).isFinite = true ∧ |real (input 386)| ≤ 1

theorem initial_ranges (input : Nat → Float32) (flags : Gated.Contraction) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (hx : InitialInputs input) :
    (∀ i, Arithmetic.Finite input (Gated.stateExpr flags tree i) ∧
      |real (evaluate input (Gated.stateExpr flags tree i))| ≤ (2 : ℝ)^(41 : Nat)) ∧
    Arithmetic.Finite input (Gated.outputExpr flags tree) ∧
      |real (evaluate input (Gated.outputExpr flags tree))| ≤ (2 : ℝ)^(47 : Nat) := by
  have hd (i : Fin 128) := mul_range input (.input i.val) (.input 385) 0 (by decide) (by decide)
    (hx.state i).1 hx.decay.1 (by
      simp only [evaluate, zpow_zero]
      have h := mul_le_mul (hx.state i).2 hx.decay.2 (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1)
      simpa only [one_mul] using h)
  have hp := dot_range input flags.prediction tree coverage Gated.decayedExpr (fun i => .input (128+i.val)) 0 3
    (by decide) (by decide) hd (fun i => by norm_num only [Arithmetic.Finite, evaluate, zpow_ofNat]; exact hx.key i)
  have hs := Float32Bounds.sub_range (input 384) (evaluate input (Gated.predictionExpr flags tree))
    (DyadicBounds.ceiling 1 37) hx.value.1 (finite_evaluate _ _ hp.1) (cap 37 (by decide) (by decide)).1 (by
      rw [(cap 37 (by decide) (by decide)).2]
      have hv := hx.value.2
      have hpred := hp.2
      change |real (evaluate input (Gated.predictionExpr flags tree))| ≤ _ at hpred
      norm_num at hpred ⊢
      norm_num at hv
      linarith)
  have hsub : Arithmetic.Finite input (.sub (.input 384) (Gated.predictionExpr flags tree)) := ⟨hx.value.1, hp.1, hs.1⟩
  have hdelta := mul_range input (.sub (.input 384) (Gated.predictionExpr flags tree)) (.input 386) 37
    (by decide) (by decide) hsub hx.beta.1 (by
      have hb : |real (evaluate input (.sub (.input 384) (Gated.predictionExpr flags tree)))| ≤ (2 : ℝ)^(37 : Int) := by
        simpa only [evaluate, (cap 37 (by decide) (by decide)).2] using hs.2
      exact (mul_le_mul hb hx.beta.2 (abs_nonneg _) (by positivity)).trans_eq (mul_one _))
  have hstate (i : Fin 128) := ArithmeticFoldBounds.madd_range input flags.update (.input (128+i.val))
    (Gated.deltaExpr flags tree) (Gated.decayedExpr i) 3 37 1 (by decide) (by decide) (by decide)
    (by norm_num only [Arithmetic.Finite, evaluate, zpow_ofNat]; exact hx.key i) hdelta
    ⟨(hd i).1, (hd i).2.trans (by norm_num)⟩
  have hstate' (i : Fin 128) : Arithmetic.Finite input (Gated.stateExpr flags tree i) ∧
      |real (evaluate input (Gated.stateExpr flags tree i))| ≤ (2 : ℝ)^(41 : Int) := by
    convert hstate i using 1 <;> norm_num [Gated.stateExpr]
  have ho := dot_range input flags.output tree coverage (Gated.stateExpr flags tree) (fun i => .input (256+i.val)) 41 (-1)
    (by decide) (by decide) hstate' (fun i => by
      norm_num only [Arithmetic.Finite, evaluate, zpow_neg_one]
      exact hx.query i)
  exact ⟨fun i => by simpa only [zpow_ofNat] using hstate' i,
    ho.1, by simpa only [Gated.outputExpr, show (41 : Int)+(-1)+7 = 47 from by decide, zpow_ofNat] using ho.2⟩

theorem initial_value (input : Nat → Float32) (flags : Gated.Contraction)
    (reduce : (Fin 32 → Float32) → Float32) (platform : FlushedReduction.SimdContract reduce)
    (hx : InitialInputs input) :
    Model.isFinite (Gated.value input reduce flags) = true ∧ |Model.toReal (Gated.value input reduce flags)| ≤ (2 : ℝ)^(47 : Nat) := by
  have h := initial_ranges input flags platform.tree platform.coverage hx
  have hf := finite_evaluate input _ h.2.1
  rw [Gated.output_execution input reduce platform flags] at hf
  have hb := h.2.2
  rw [Gated.output_execution input reduce platform flags] at hb
  have hc := BFloat16DyadicBounds.ceiling_range 1 47 (by decide) (by decide) (by decide)
  have hn := BFloat16ConversionBounds.narrow_range (Gated.sourceOutput input reduce flags) (BFloat16DyadicBounds.ceiling 1 47)
    hf hc.1 (by simpa only [hc.2, Nat.cast_one, one_mul, zpow_ofNat] using hb)
  exact ⟨hn.1, by simpa only [Gated.value, hc.2, Nat.cast_one, one_mul, zpow_ofNat] using hn.2⟩

end Inference.Kernels.Delta.GatedRanges
