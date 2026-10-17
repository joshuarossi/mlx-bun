import kernels.quantization.AffineInput
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Kernels.Quantization.AffineInputBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineInput
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def count : SumExpr n → Nat
  | .input _ => 1
  | .add a b => count a + count b

-- load_vector performs these additions in BF16, before widening. The bound
-- is proved at that precision, with every internal rounding and flush.
theorem expression_range (x : Fin n → BF) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 119)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent)
    (expr : SumExpr n) (size : count expr < 256) :
    AffineInput.Finite x expr ∧ |Model.toReal (evaluate x expr)| ≤ (count expr : ℝ) * (2 : ℝ)^exponent := by
  induction expr with
  | input i => simpa only [AffineInput.Finite, evaluate, count, Nat.cast_one, one_mul] using hx i
  | add a b ia ib =>
    have ha := ia (by simp only [count] at size; omega)
    have hb := ib (by simp only [count] at size; omega)
    have hc := BFloat16DyadicBounds.ceiling_range (count (.add a b)) exponent size lo hi
    have h := BFloat16Bounds.add_range (evaluate x a) (evaluate x b)
      (BFloat16DyadicBounds.ceiling (count (.add a b)) exponent)
      (evaluate_finite x a ha.1) (evaluate_finite x b hb.1) hc.1
      (by rw [hc.2]; calc
          _ ≤ (count a : ℝ) * (2 : ℝ)^exponent + (count b : ℝ) * (2 : ℝ)^exponent := add_le_add ha.2 hb.2
          _ = _ := by simp only [count, Nat.cast_add]; ring)
    exact ⟨⟨ha.1, hb.1, h.1⟩, by simpa only [evaluate, hc.2] using h.2⟩

theorem group4_range (x : Fin 16 → BF) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 119)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) (group : Fin 4) :
    AffineInput.Finite x (groups4 group) ∧ Model.isFinite (evaluate x (groups4 group)) = true ∧
      |real (BFloat16.widen (evaluate x (groups4 group)))| ≤ 4 * (2 : ℝ)^exponent := by
  have h := expression_range x exponent lo hi hx (groups4 group) (by change 4 < 256; decide)
  have hf := evaluate_finite _ _ h.1
  refine ⟨h.1, hf, ?_⟩
  rw [BFloat16.widen_real _ hf]
  simpa only [show count (groups4 group) = 4 from rfl, Nat.cast_ofNat] using h.2

theorem group3_range (x : Fin 16 → BF) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent ≤ 119)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) (group : Fin 2) :
    AffineInput.Finite x (groups3 group) ∧ Model.isFinite (evaluate x (groups3 group)) = true ∧
      |real (BFloat16.widen (evaluate x (groups3 group)))| ≤ 8 * (2 : ℝ)^exponent := by
  have h := expression_range x exponent lo hi hx (groups3 group) (by change 8 < 256; decide)
  have hf := evaluate_finite _ _ h.1
  refine ⟨h.1, hf, ?_⟩
  rw [BFloat16.widen_real _ hf]
  simpa only [show count (groups3 group) = 8 from rfl, Nat.cast_ofNat] using h.2

end Inference.Kernels.Quantization.AffineInputBounds
