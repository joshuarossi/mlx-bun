import kernels.quantization.AffineScaledBounds

namespace Inference.Kernels.Quantization.AffineShiftedDotBounds
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold AffineDot

theorem mask4_range (w : BitVec 16) (i : Fin 4) :
    (AffineLift.value (mask4 w i)).isFinite = true ∧
      |real (AffineLift.value (mask4 w i))| ≤ (2 : ℝ)^(4+((4*i.val : Nat) : Int)) := by
  refine ⟨(AffineDotBounds.mask4_range w i).1, ?_⟩
  rw [mask4_exact, abs_of_nonneg (Nat.cast_nonneg _)]
  have hm : 15 * 2^(4*i.val) < 65536 := by fin_cases i <;> decide
  have hb : mask4 w i ≤ 15 * 2^(4*i.val) := by
    simp only [mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm]
    exact Nat.and_le_right
  calc
    (mask4 w i : ℝ) ≤ ((15 * 2^(4*i.val) : Nat) : ℝ) := by exact_mod_cast hb
    _ ≤ _ := by fin_cases i <;> norm_num

theorem range4 (contracted : Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32)
    (exponent : Int) (count : Nat) (lo : -149 ≤ exponent+4) (hi : exponent+4 ≤ 100)
    (size : count+4 < 16777216)
    (hx : ∀ i, (scaled i).isFinite = true ∧ |real (scaled i)| ≤ (2 : ℝ)^(exponent-((4*i.val : Nat) : Int)))
    (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+4)) :
    Arithmetic.Finite (bind4 w scaled acc) (expression4 contracted) ∧
      |real (source4 contracted w scaled acc)| ≤ ((count+4 : Nat) : ℝ) * (2 : ℝ)^(exponent+4) := by
  let input := bind4 w scaled acc
  have hx' (i : Fin 4) : Arithmetic.Finite input (.input i.val) ∧
      |real (evaluate input (.input i.val))| ≤ (2 : ℝ)^(exponent-((4*i.val : Nat) : Int)) := by
    simpa only [Arithmetic.Finite, evaluate, input, bind4, dite_eq_left i.isLt] using hx i
  have hw' (i : Fin 4) : Arithmetic.Finite input (.input (4+i.val)) ∧
      |real (evaluate input (.input (4+i.val)))| ≤ (2 : ℝ)^(4+((4*i.val : Nat) : Int)) := by
    have := i.isLt
    simpa [Arithmetic.Finite, evaluate, input, bind4, show ¬4+i.val < 4 by omega, show 4+i.val < 8 by omega] using mask4_range w i
  have hp := DyadicBounds.ceiling_range 1 (exponent+4) (by decide) lo hi
  have hm := NativeMultiplication.range (scaled 0) (AffineLift.value (mask4 w 0)) (DyadicBounds.ceiling 1 (exponent+4))
    (hx 0).1 (mask4_range w 0).1 hp.1
    (by rw [hp.2, Nat.cast_one, one_mul, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
        simpa only [Fin.val_zero, Nat.mul_zero, Nat.cast_zero, sub_zero, add_zero] using
          mul_le_mul (hx 0).2 (mask4_range w 0).2 (abs_nonneg _) (zpow_nonneg (by norm_num) _))
  have h0 : Arithmetic.Finite input (.mul (.input 0) (.input 4)) ∧
      |real (evaluate input (.mul (.input 0) (.input 4)))| ≤ (1 : Nat) * (2 : ℝ)^(exponent+4) := by
    refine ⟨⟨(hx' 0).1, (hw' 0).1, ?_⟩, ?_⟩
    · simpa [input, evaluate, bind4] using hm.1
    · simpa [input, evaluate, bind4, hp.2] using hm.2
  have step (i : Fin 4) (accExpr : Expr) (count : Nat) (small : count+1 < 16777216)
      (hc : Arithmetic.Finite input accExpr ∧ |real (evaluate input accExpr)| ≤ (count : ℝ) * (2 : ℝ)^(exponent+4)) :=
    ArithmeticVaryingBounds.madd_range input contracted (.input i.val) (.input (4+i.val)) accExpr
      (exponent-((4*i.val : Nat) : Int)) (4+((4*i.val : Nat) : Int)) (exponent+4) count (by ring)
      lo hi small (hx' i) (hw' i) hc
  have h1 := step 1 _ 1 (by decide) h0
  have h2 := step 2 _ 2 (by decide) h1
  have h3 := step 3 _ 3 (by decide) h2
  have hc := DyadicBounds.ceiling_range (count+4) (exponent+4) size lo hi
  have hadd := Float32Bounds.add_range acc _ (DyadicBounds.ceiling (count+4) (exponent+4)) ha.1
    (Arithmetic.finite_evaluate _ _ h3.1) hc.1
    (by rw [hc.2]; calc
        _ ≤ (count : ℝ) * (2 : ℝ)^(exponent+4) + ((3+1 : Nat) : ℝ) * (2 : ℝ)^(exponent+4) := add_le_add ha.2 h3.2
        _ = _ := by push_cast; ring)
  have he : Arithmetic.Finite input (expression4 contracted) :=
    ⟨by simpa [Arithmetic.Finite, input, bind4] using ha.1, h3.1, by simpa [evaluate, input, bind4] using hadd.1⟩
  refine ⟨he, ?_⟩
  rw [← execution4]
  change |real (evaluate input (expression4 contracted))| ≤ _
  simpa [expression4, evaluate, input, bind4, hc.2] using hadd.2

def maskExponent3 (i : Fin 10) : Int := 3 + (inputShift3 (coordinate3 i) : Int) - (if crossed3 i then 8 else 0)
def inputExponent3 (exponent : Int) (i : Fin 10) : Int :=
  exponent - (inputShift3 (coordinate3 i) : Int) + (if crossed3 i then 8 else 0)

theorem mask3_range (w : Fin 3 → BitVec 8) (i : Fin 10) :
    (AffineLift.value (mask3 w i)).isFinite = true ∧
      |real (AffineLift.value (mask3 w i))| ≤ (2 : ℝ)^(maskExponent3 i) := by
  refine ⟨(AffineDotBounds.mask3_range w i).1, ?_⟩
  rw [mask3_exact, abs_of_nonneg (Nat.cast_nonneg _)]
  have hm : (2^(width3 i)-1)*2^(shift3 i) < 256 := by fin_cases i <;> decide
  have hb : mask3 w i ≤ (2^(width3 i)-1)*2^(shift3 i) := by
    simp only [mask3, AffinePacking.mask8, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm]
    exact Nat.and_le_right
  calc
    (mask3 w i : ℝ) ≤ (((2^(width3 i)-1)*2^(shift3 i) : Nat) : ℝ) := by exact_mod_cast hb
    _ ≤ _ := by fin_cases i <;> norm_num [maskExponent3, width3, shift3, inputShift3, coordinate3, crossed3]

theorem range3 (contracted : Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32)
    (exponent : Int) (count : Nat) (lo : -133 ≤ exponent) (hi : exponent+3 ≤ 100)
    (size : count+10 < 16777216)
    (hx : ∀ i, (scaled i).isFinite = true ∧ |real (scaled i)| ≤ (2 : ℝ)^(exponent-(inputShift3 i : Int)))
    (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+3)) :
    Arithmetic.Finite (bind3 w scaled acc) (expression3 contracted) ∧
      |real (source3 contracted w scaled acc)| ≤ ((count+10 : Nat) : ℝ) * (2 : ℝ)^(exponent+3) := by
  let input := bind3 w scaled acc
  have hl (i : Fin 10) : Arithmetic.Finite input (left3 i) ∧
      |real (evaluate input (left3 i))| ≤ (2 : ℝ)^(maskExponent3 i) := by
    have := i.isLt
    simpa [Arithmetic.Finite, evaluate, left3, input, bind3, show ¬8+i.val < 8 by omega,
      show 8+i.val < 18 by omega] using mask3_range w i
  have hr (i : Fin 10) : Arithmetic.Finite input (right3 i) ∧
      |real (evaluate input (right3 i))| ≤ (2 : ℝ)^(inputExponent3 exponent i) := by
    by_cases cross : crossed3 i = true
    · have hlow : -149 ≤ exponent - (inputShift3 (coordinate3 i) : Int) + 8 := by
        have hs : inputShift3 (coordinate3 i) ≤ 7 := by fin_cases i <;> decide
        omega
      have hhigh : exponent - (inputShift3 (coordinate3 i) : Int) + 8 ≤ 100 := by
        fin_cases i <;> simp [crossed3] at cross
        all_goals (norm_num [coordinate3, inputShift3]; omega)
      have hc := DyadicBounds.ceiling_range 1 (exponent - (inputShift3 (coordinate3 i) : Int) + 8) (by decide) hlow hhigh
      have hm := NativeMultiplication.range (scaled (coordinate3 i)) 256
        (DyadicBounds.ceiling 1 (exponent - (inputShift3 (coordinate3 i) : Int) + 8))
        (hx _).1 (by decide +kernel) hc.1
        (by rw [hc.2, Nat.cast_one, one_mul, AffineDotBounds.real256,
              abs_of_pos (zpow_pos (by norm_num : (0 : ℝ) < 2) (8 : Int)),
              zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
            exact mul_le_mul_of_nonneg_right (hx _).2 (zpow_nonneg (by norm_num) _))
      simp only [right3, cross, ite_true]
      refine ⟨⟨?_, ?_, ?_⟩, ?_⟩
      · simpa [Arithmetic.Finite, input, bind3, (coordinate3 i).isLt] using (hx (coordinate3 i)).1
      · change (input 18).isFinite = true
        change (256 : Float32).isFinite = true
        decide +kernel
      · simpa [evaluate, input, bind3, (coordinate3 i).isLt] using hm.1
      · simpa [evaluate, input, bind3, (coordinate3 i).isLt, hc.2, inputExponent3, cross] using hm.2
    · simpa [right3, inputExponent3, cross, Arithmetic.Finite, evaluate, input, bind3, (coordinate3 i).isLt] using hx (coordinate3 i)
  have he (i : Fin 10) : maskExponent3 i + inputExponent3 exponent i = exponent+3 := by
    unfold maskExponent3 inputExponent3
    ring
  have h := ArithmeticVaryingBounds.fold_range input contracted left3 right3 maskExponent3 (inputExponent3 exponent)
    (exponent+3) he (by omega) hi hl hr (List.finRange 10) (.input 19) count
    (by simpa only [List.length_finRange] using size)
    (by simpa [Arithmetic.Finite, evaluate, input, bind3] using ha)
  change Arithmetic.Finite (bind3 w scaled acc) (expression3 contracted) ∧
    |real (evaluate (bind3 w scaled acc) (expression3 contracted))| ≤
      ((count + (List.finRange 10).length : Nat) : ℝ) * (2 : ℝ)^(exponent+3) at h
  simpa only [execution3, List.length_finRange] using h

end Inference.Kernels.Quantization.AffineShiftedDotBounds
