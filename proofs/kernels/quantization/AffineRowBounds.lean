import kernels.quantization.AffineRow
import contracts.mlx.AdditionFoldBounds
import contracts.mlx.BFloat16ConversionBounds

namespace Inference.Kernels.Quantization.AffineRowBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineRow
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem accumulation_range (p : Platform) (tiles : Fin steps → Fin 32 → Float32)
    (weight : Nat) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (size : 32 * (steps * weight) < 16777216)
    (ht : ∀ step lane, (tiles step lane).isFinite = true ∧
      |real (tiles step lane)| ≤ (weight : ℝ) * (2 : ℝ)^exponent) :
    Arithmetic.Finite (bind tiles) (expression steps p.reduction.tree) ∧
      (source p tiles).isFinite = true ∧
      |real (source p tiles)| ≤ ((32 * (steps * weight) : Nat) : ℝ) * (2 : ℝ)^exponent := by
  have hl (lane : Fin 32) : Arithmetic.Finite (bind tiles) (laneExpr steps lane) ∧
      |real (Arithmetic.evaluate (bind tiles) (laneExpr steps lane))| ≤ ((steps * weight : Nat) : ℝ) * (2 : ℝ)^exponent := by
    have h := AdditionFoldBounds.from_zero (bind tiles)
      (fun step : Fin steps => .input (AffineLayout.chunkIndex step lane).val) exponent weight lo hi
      (fun step => by simpa only [Arithmetic.Finite, Arithmetic.evaluate, bind_read] using ht step lane)
      (List.finRange steps) (by rw [List.length_finRange]; omega)
    simpa only [laneExpr, List.length_finRange] using h
  have hc : (Reduction.leaves p.reduction.tree).length = 32 := by
    simpa only [List.length_finRange] using p.reduction.coverage.length_eq
  have hr := AdditionFoldBounds.reduce_range (bind tiles) (laneExpr steps) exponent (steps * weight) lo hi hl
    p.reduction.tree (by rwa [hc])
  change Arithmetic.Finite (bind tiles) (expression steps p.reduction.tree) ∧ _ at hr
  have hf := Arithmetic.finite_evaluate (bind tiles) (expression steps p.reduction.tree) hr.1
  rw [execution] at hf
  have hb := hr.2
  change |real (Arithmetic.evaluate (bind tiles) (expression steps p.reduction.tree))| ≤ _ at hb
  rw [execution, hc] at hb
  exact ⟨hr.1, hf, hb⟩

theorem output_range (p : Platform) (tiles : Fin steps → Fin 32 → Float32)
    (weight : Nat) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (size : 32 * (steps * weight) < 16777216)
    (ht : ∀ step lane, (tiles step lane).isFinite = true ∧
      |real (tiles step lane)| ≤ (weight : ℝ) * (2 : ℝ)^exponent)
    (cap : BF) (hc : Model.isFinite cap = true)
    (capacity : ((32 * (steps * weight) : Nat) : ℝ) * (2 : ℝ)^exponent ≤ Model.toReal cap) :
    Arithmetic.Finite (bind tiles) (expression steps p.reduction.tree) ∧
      Model.isFinite (output p tiles) = true ∧ |Model.toReal (output p tiles)| ≤ Model.toReal cap := by
  have h := accumulation_range p tiles weight exponent lo hi size ht
  have ho := BFloat16ConversionBounds.narrow_range (source p tiles) cap h.2.1 hc (h.2.2.trans capacity)
  exact ⟨h.1, ho⟩

end Inference.Kernels.Quantization.AffineRowBounds
