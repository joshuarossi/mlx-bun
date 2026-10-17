import contracts.mlx.FlushedDotProduct
import contracts.mlx.NativeFma
import contracts.mlx.DyadicBounds

namespace Inference.Contracts.Mlx.FlushedDotProductBounds
open Numerics DotProduct

def count : Expr → Nat
  | .zero => 0
  | .fma _ acc => count acc + 1
  | .add a b => count a + count b

theorem count_ideal (e : Expr) : (count e : ℝ) = ideal (fun _ => 1) e := by
  induction e with
  | zero => simp [count, ideal]
  | fma i acc ih => simp [count, ideal, ih]; ring
  | add a b ia ib => simp [count, ideal, ia, ib]

-- Each product and every partial sum receives an exactly representable
-- ceiling. This derives finiteness for the actual flushed FMA expression.
theorem ranges_weighted (code scale input : Nat → Float32) (ec es ei : Int) (multiplicity weightCount : Nat) (weightSize : weightCount < 16777216)
    (weightLo : -149 ≤ ec+es) (weightHi : ec+es ≤ 100)
    (termLo : -149 ≤ ec+es+ei) (termHi : ec+es+ei ≤ 100)
    (hc : ∀ i, (code i).isFinite = true ∧ |real (code i)| ≤ (2 : ℝ)^ec)
    (hs : ∀ i, (scale i).isFinite = true ∧ |real (scale i)| ≤ (weightCount : ℝ)*(2 : ℝ)^es)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (multiplicity : ℝ) * (2 : ℝ)^ei)
    (e : Expr) (size : count e * (weightCount*multiplicity) < 16777216) :
    FlushedDotProduct.Finite code scale input e ∧
      |real (FlushedDotProduct.evaluate code scale input e)| ≤
        ((count e * (weightCount*multiplicity) : Nat) : ℝ) * (2 : ℝ)^(ec+es+ei) := by
  have weightCap := DyadicBounds.ceiling_range weightCount (ec+es) weightSize weightLo weightHi
  induction e with
  | zero =>
    refine ⟨trivial, ?_⟩
    simp only [FlushedDotProduct.evaluate, count, Nat.cast_zero, zero_mul]
    have hz : real (0 : Float32) = 0 := by
      rw [real_unpack]
      exact FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_zero .positive
    simp only [hz, abs_zero, le_refl]
  | fma i acc ih =>
    have ha := ih (lt_of_le_of_lt (Nat.mul_le_mul_right (weightCount*multiplicity) (Nat.le_add_right _ _)) size)
    have hw := NativeMultiplication.range (code i) (scale i) (DyadicBounds.ceiling weightCount (ec+es))
      (hc i).1 (hs i).1 weightCap.1 (by
        rw [weightCap.2]
        calc
          _ ≤ (2 : ℝ)^ec * ((weightCount : ℝ)*(2 : ℝ)^es) := mul_le_mul (hc i).2 (hs i).2 (abs_nonneg _) (by positivity)
          _ = _ := by rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0) ec es]; ring)
    have cap := DyadicBounds.ceiling_range ((count acc+1)*(weightCount*multiplicity)) (ec+es+ei) size termLo termHi
    have hout := NativeFma.range (FlushToZero.mul (code i) (scale i)) (input i)
      (FlushedDotProduct.evaluate code scale input acc) (DyadicBounds.ceiling ((count acc+1)*(weightCount*multiplicity)) (ec+es+ei))
      (FlushToZero.finite_flush _ hw.1) (hx i).1 (FlushedDotProduct.finite_evaluate _ _ _ _ ha.1) cap.1 (by
        rw [cap.2]
        have hm := mul_le_mul (hw.2.trans_eq weightCap.2) (hx i).2 (abs_nonneg _) (by positivity)
        have hexp : ((weightCount : ℝ)*(2 : ℝ)^(ec+es)) * ((multiplicity : ℝ)*(2 : ℝ)^ei) = ((weightCount*multiplicity : Nat) : ℝ)*(2 : ℝ)^(ec+es+ei) := by
          rw [zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0) (ec+es) ei]; push_cast; ring
        rw [hexp] at hm
        calc
          _ ≤ ((weightCount*multiplicity : Nat) : ℝ)*(2 : ℝ)^(ec+es+ei) + ((count acc*(weightCount*multiplicity) : Nat) : ℝ)*(2 : ℝ)^(ec+es+ei) := add_le_add hm ha.2
          _ = _ := by push_cast; ring)
    exact ⟨⟨ha.1, hw.1, (hx i).1, hout.1⟩, by simpa only [FlushedDotProduct.evaluate, count, cap.2] using hout.2⟩
  | add a b ia ib =>
    have ha := ia (lt_of_le_of_lt (Nat.mul_le_mul_right (weightCount*multiplicity) (Nat.le_add_right _ _)) size)
    have hb := ib (lt_of_le_of_lt (Nat.mul_le_mul_right (weightCount*multiplicity) (Nat.le_add_left _ _)) size)
    have cap := DyadicBounds.ceiling_range ((count a+count b)*(weightCount*multiplicity)) (ec+es+ei) size termLo termHi
    have hout := Float32Bounds.add_range (FlushedDotProduct.evaluate code scale input a)
      (FlushedDotProduct.evaluate code scale input b) (DyadicBounds.ceiling ((count a+count b)*(weightCount*multiplicity)) (ec+es+ei))
      (FlushedDotProduct.finite_evaluate _ _ _ _ ha.1) (FlushedDotProduct.finite_evaluate _ _ _ _ hb.1) cap.1 (by
        rw [cap.2, Nat.add_mul, Nat.cast_add, add_mul]
        exact add_le_add ha.2 hb.2)
    exact ⟨⟨ha.1, hb.1, hout.1⟩, by simpa only [FlushedDotProduct.evaluate, count, cap.2] using hout.2⟩

theorem ranges_scaled (code scale input : Nat → Float32) (ec es ei : Int) (multiplicity : Nat)
    (weightLo : -149 ≤ ec+es) (weightHi : ec+es ≤ 100)
    (termLo : -149 ≤ ec+es+ei) (termHi : ec+es+ei ≤ 100)
    (hc : ∀ i, (code i).isFinite = true ∧ |real (code i)| ≤ (2 : ℝ)^ec)
    (hs : ∀ i, (scale i).isFinite = true ∧ |real (scale i)| ≤ (2 : ℝ)^es)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (multiplicity : ℝ) * (2 : ℝ)^ei)
    (e : Expr) (size : count e * multiplicity < 16777216) :
    FlushedDotProduct.Finite code scale input e ∧
      |real (FlushedDotProduct.evaluate code scale input e)| ≤
        ((count e * multiplicity : Nat) : ℝ) * (2 : ℝ)^(ec+es+ei) := by
  simpa only [Nat.one_mul, Nat.cast_one, one_mul] using ranges_weighted code scale input ec es ei multiplicity 1
    (by decide) weightLo weightHi termLo termHi hc (by simpa only [Nat.cast_one, one_mul] using hs) hx e
    (by simpa only [Nat.one_mul] using size)

theorem ranges (code scale input : Nat → Float32) (ec es ei : Int)
    (weightLo : -149 ≤ ec+es) (weightHi : ec+es ≤ 100)
    (termLo : -149 ≤ ec+es+ei) (termHi : ec+es+ei ≤ 100)
    (hc : ∀ i, (code i).isFinite = true ∧ |real (code i)| ≤ (2 : ℝ)^ec)
    (hs : ∀ i, (scale i).isFinite = true ∧ |real (scale i)| ≤ (2 : ℝ)^es)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^ei)
    (e : Expr) (size : count e < 16777216) :
    FlushedDotProduct.Finite code scale input e ∧
      |real (FlushedDotProduct.evaluate code scale input e)| ≤
        (count e : ℝ) * (2 : ℝ)^(ec+es+ei) := by
  simpa only [Nat.mul_one, Nat.cast_one, one_mul] using ranges_scaled code scale input ec es ei 1
    weightLo weightHi termLo termHi hc hs (by simpa only [Nat.cast_one, one_mul] using hx) e
    (by simpa only [Nat.mul_one] using size)

end Inference.Contracts.Mlx.FlushedDotProductBounds
