import kernels.quantization.AffineDot
import contracts.mlx.ArithmeticFoldBounds

namespace Inference.Kernels.Quantization.AffineDotBounds
open Contracts.Mlx Contracts.Mlx.Numerics Arithmetic ArithmeticFold AffineDot

theorem mask4_range (w : BitVec 16) (i : Fin 4) :
    (AffineLift.value (mask4 w i)).isFinite = true ∧ |real (AffineLift.value (mask4 w i))| ≤ (2 : ℝ)^(16 : Int) := by
  have hm : 15 * 2^(4*i.val) < 65536 := by fin_cases i <;> decide
  have hs : 4*i.val < 13 := by have := i.isLt; omega
  constructor
  · simpa only [mask4, AffinePacking.mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm,
      show 2^4-1 = 15 from rfl] using AffineLift.mask_finite w.toNat 4 (4*i.val) (by decide) hs
  · rw [mask4_exact, abs_of_nonneg (Nat.cast_nonneg _)]
    have h : mask4 w i < 65536 := (w &&& BitVec.ofNat 16 (15 * 2^(4*i.val))).isLt
    norm_num
    exact_mod_cast h.le

theorem range4 (contracted : Nat → Bool) (w : BitVec 16) (scaled : Fin 4 → Float32) (acc : Float32)
    (exponent : Int) (count : Nat) (lo : -149 ≤ exponent + 16) (hi : exponent + 16 ≤ 100)
    (size : count + 4 < 16777216)
    (hx : ∀ i, (scaled i).isFinite = true ∧ |real (scaled i)| ≤ (2 : ℝ)^exponent)
    (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+16)) :
    Arithmetic.Finite (bind4 w scaled acc) (expression4 contracted) ∧
      |real (source4 contracted w scaled acc)| ≤ ((count+4 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := by
  let input := bind4 w scaled acc
  have hx' (i : Fin 4) : Arithmetic.Finite input (.input i.val) ∧
      |real (evaluate input (.input i.val))| ≤ (2 : ℝ)^exponent := by
    simpa only [Arithmetic.Finite, evaluate, input, bind4, dite_eq_left i.isLt] using hx i
  have hw' (i : Fin 4) : Arithmetic.Finite input (.input (4+i.val)) ∧
      |real (evaluate input (.input (4+i.val)))| ≤ (2 : ℝ)^(16 : Int) := by
    have := i.isLt
    simpa [Arithmetic.Finite, evaluate, input, bind4, show ¬4+i.val < 4 by omega, show 4+i.val < 8 by omega] using mask4_range w i
  have hp := DyadicBounds.ceiling_range 1 (exponent+16) (by decide) lo hi
  have hprod (i : Fin 4) : Arithmetic.Finite input (.mul (.input i.val) (.input (4+i.val))) ∧
      |real (evaluate input (.mul (.input i.val) (.input (4+i.val))))| ≤ (1 : Nat) * (2 : ℝ)^(exponent+16) := by
    have hm := NativeMultiplication.range (evaluate input (.input i.val)) (evaluate input (.input (4+i.val)))
      (DyadicBounds.ceiling 1 (exponent+16)) (finite_evaluate _ _ (hx' i).1) (finite_evaluate _ _ (hw' i).1) hp.1
      (by rw [hp.2, Nat.cast_one, one_mul, zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)];
          exact mul_le_mul (hx' i).2 (hw' i).2 (abs_nonneg _) (zpow_nonneg (by norm_num) _))
    exact ⟨⟨(hx' i).1, (hw' i).1, hm.1⟩, by simpa only [evaluate, hp.2] using hm.2⟩
  -- Site 0 adds the first two products; either may be the accumulated operand.
  have h1 (c : Bool) : Arithmetic.Finite input (maddLeft c (.input 0) (.input 4) (.mul (.input 1) (.input 5))) ∧
      |real (evaluate input (maddLeft c (.input 0) (.input 4) (.mul (.input 1) (.input 5))))| ≤
        ((1+1 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := by
    cases c
    · rw [maddLeft_false]
      exact ArithmeticFoldBounds.madd_range input false (.input 1) (.input 5) _ exponent 16 1 lo hi (by decide) (hx' 1) (hw' 1)
        (hprod 0)
    · rw [maddLeft_true]
      exact ArithmeticFoldBounds.madd_range input true (.input 0) (.input 4) _ exponent 16 1 lo hi (by decide) (hx' 0) (hw' 0)
        (hprod 1)
  have h2 := ArithmeticFoldBounds.madd_range input (contracted 1) (.input 2) (.input 6) _ exponent 16 2 lo hi (by decide)
    (hx' 2) (hw' 2) (h1 (contracted 0))
  have h3 := ArithmeticFoldBounds.madd_range input (contracted 2) (.input 3) (.input 7) _ exponent 16 3 lo hi (by decide)
    (hx' 3) (hw' 3) h2
  have hc := DyadicBounds.ceiling_range (count+4) (exponent+16) size lo hi
  have hadd := Float32Bounds.add_range acc _ (DyadicBounds.ceiling (count+4) (exponent+16)) ha.1
    (Arithmetic.finite_evaluate _ _ h3.1) hc.1
    (by rw [hc.2]; calc
        _ ≤ (count : ℝ) * (2 : ℝ)^(exponent+16) + ((3+1 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := add_le_add ha.2 h3.2
        _ = _ := by push_cast; ring)
  have he : Arithmetic.Finite input (expression4 contracted) :=
    ⟨by simpa [Arithmetic.Finite, input, bind4] using ha.1, h3.1, by simpa [evaluate, input, bind4] using hadd.1⟩
  refine ⟨he, ?_⟩
  rw [← execution4]
  change |real (evaluate input (expression4 contracted))| ≤ _
  simpa [expression4, evaluate, input, bind4, hc.2] using hadd.2

theorem mask3_range (w : Fin 3 → BitVec 8) (i : Fin 10) :
    (AffineLift.value (mask3 w i)).isFinite = true ∧ |real (AffineLift.value (mask3 w i))| ≤ (2 : ℝ)^(8 : Int) := by
  have hm : (2^(width3 i)-1)*2^(shift3 i) < 256 := by fin_cases i <;> decide
  have hw : width3 i ≤ 4 := by fin_cases i <;> decide
  have hs : shift3 i < 13 := by fin_cases i <;> decide
  constructor
  · simpa only [mask3, AffinePacking.mask8, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt hm] using
      AffineLift.mask_finite (w (byte3 i)).toNat (width3 i) (shift3 i) hw hs
  · rw [mask3_exact, abs_of_nonneg (Nat.cast_nonneg _)]
    have h : mask3 w i < 256 := (w (byte3 i) &&& BitVec.ofNat 8 ((2^(width3 i)-1)*2^(shift3 i))).isLt
    norm_num
    exact_mod_cast h.le

theorem real256 : real (256 : Float32) = (2 : ℝ)^(8 : Int) := by
  rw [real_unpack]
  change FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal
    (.finite .positive 8388608 (-15) (by decide)) = _
  norm_num [FloatLib.Floats.Formats.BinaryInterchange.Model.unpackedToReal_finite,
    FloatLib.Floats.Formats.BinaryInterchange.Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow,
    FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

theorem range3 (contracted : Nat → Bool) (w : Fin 3 → BitVec 8) (scaled : Fin 8 → Float32) (acc : Float32)
    (exponent : Int) (count : Nat) (lo : -149 ≤ exponent + 8) (hi : exponent + 16 ≤ 100)
    (size : count + 10 < 16777216)
    (hx : ∀ i, (scaled i).isFinite = true ∧ |real (scaled i)| ≤ (2 : ℝ)^exponent)
    (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+16)) :
    Arithmetic.Finite (bind3 w scaled acc) (expression3 contracted) ∧
      |real (source3 contracted w scaled acc)| ≤ ((count+10 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := by
  let input := bind3 w scaled acc
  have hl (i : Fin 10) : Arithmetic.Finite input (left3 i) ∧
      |real (evaluate input (left3 i))| ≤ (2 : ℝ)^(8 : Int) := by
    have := i.isLt
    simpa [Arithmetic.Finite, evaluate, left3, input, bind3, show ¬8+i.val < 8 by omega,
      show 8+i.val < 18 by omega] using mask3_range w i
  have hr (i : Fin 10) : Arithmetic.Finite input (right3 i) ∧
      |real (evaluate input (right3 i))| ≤ (2 : ℝ)^(exponent+8) := by
    have hc := DyadicBounds.ceiling_range 1 (exponent+8) (by decide) lo (by omega)
    have hm := NativeMultiplication.range (scaled (coordinate3 i)) 256 (DyadicBounds.ceiling 1 (exponent+8))
      (hx _).1 (by decide +kernel) hc.1
      (by rw [hc.2, Nat.cast_one, one_mul, real256, abs_of_pos (zpow_pos (by norm_num : (0 : ℝ) < 2) (8 : Int)),
            zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)];
          exact mul_le_mul_of_nonneg_right (hx _).2 (zpow_nonneg (by norm_num) _))
    unfold right3
    split
    · refine ⟨⟨?_, ?_, ?_⟩, ?_⟩
      · simpa [Arithmetic.Finite, input, bind3, (coordinate3 i).isLt] using (hx (coordinate3 i)).1
      · change (input 18).isFinite = true
        change (256 : Float32).isFinite = true
        decide +kernel
      · simpa [evaluate, input, bind3, (coordinate3 i).isLt] using hm.1
      · simpa [evaluate, input, bind3, (coordinate3 i).isLt, hc.2] using hm.2
    · refine ⟨?_, ?_⟩
      · simpa [Arithmetic.Finite, input, bind3, (coordinate3 i).isLt] using (hx (coordinate3 i)).1
      · have hpow : (2 : ℝ)^exponent ≤ (2 : ℝ)^(exponent+8) := zpow_le_zpow_right₀ (by norm_num) (by omega)
        simpa [evaluate, input, bind3, (coordinate3 i).isLt] using (hx (coordinate3 i)).2.trans hpow
  have he : (8 : Int) + (exponent+8) = exponent+16 := by omega
  have h := ArithmeticFoldBounds.sites_range input (fun i : Fin 10 => contracted i.val) left3 right3 8 (exponent+8)
    (by omega) (by omega)
    hl hr (List.finRange 10) (.input 19) count (by simpa only [List.length_finRange] using size)
    (by simpa [Arithmetic.Finite, evaluate, input, bind3, he] using ha)
  change Arithmetic.Finite (bind3 w scaled acc) (expression3 contracted) ∧
    |real (evaluate (bind3 w scaled acc) (expression3 contracted))| ≤
      ((count + (List.finRange 10).length : Nat) : ℝ) * (2 : ℝ)^((8 : Int)+(exponent+8)) at h
  simpa only [execution3, List.length_finRange, he] using h

end Inference.Kernels.Quantization.AffineDotBounds
