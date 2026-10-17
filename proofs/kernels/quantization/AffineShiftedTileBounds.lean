import kernels.quantization.AffineTile
import kernels.quantization.AffineShiftedDotBounds
import kernels.quantization.AffineValueBounds

namespace Inference.Kernels.Quantization.AffineShiftedTileBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

private theorem zero_range (exponent : Int) :
    (0 : Float32).isFinite = true ∧ |real (0 : Float32)| ≤ (0 : Nat) * (2 : ℝ)^exponent := by
  have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
  exact ⟨by decide +kernel, by simp only [hz, abs_zero, Nat.cast_zero, zero_mul, le_refl]⟩

theorem dot4_range (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent+4 ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    DotFinite4 p x w ∧ (dot4 p x w).isFinite = true ∧ |real (dot4 p x w)| ≤ 16 * (2 : ℝ)^(exponent+4) := by
  have hp (c : Fin 4) (i : Fin 4) : (prepared4 p x c i).isFinite = true ∧
      |real (prepared4 p x c i)| ≤ (2 : ℝ)^(exponent-((4*i.val : Nat) : Int)) :=
    AffineScaledBounds.prepare_range p.divide division _ _ exponent lo (by omega) (hx _)
  have next (c : Fin 4) (acc : Float32) (count : Nat) (size : count+4 < 16777216)
      (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+4)) :
      valid4 p x w c acc ∧ (step4 p x w c acc).isFinite = true ∧
        |real (step4 p x w c acc)| ≤ ((count+4 : Nat) : ℝ) * (2 : ℝ)^(exponent+4) := by
    have h := AffineShiftedDotBounds.range4 p.contracted (w c) (prepared4 p x c) acc exponent count (by omega) hi size (hp c) ha
    have hf := Arithmetic.finite_evaluate (AffineDot.bind4 (w c) (prepared4 p x c) acc)
      (AffineDot.expression4 p.contracted) h.1
    rw [AffineDot.execution4] at hf
    exact ⟨h.1, hf, h.2⟩
  have h0 := next 0 0 0 (by decide) (zero_range _)
  have h1 := next 1 _ 4 (by decide) h0.2
  have h2 := next 2 _ 8 (by decide) h1.2
  have h3 := next 3 _ 12 (by decide) h2.2
  have hb := h3.2.2
  norm_num only [Nat.cast_add, Nat.cast_ofNat] at hb
  exact ⟨⟨fun i => (hx i).1, fun c i => (hp c i).1, ⟨h0.1, h1.1, h2.1, h3.1, True.intro⟩⟩, h3.2.1, hb⟩

theorem dot3_range (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (exponent : Int) (lo : -133 ≤ exponent) (hi : exponent+3 ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    DotFinite3 p x w ∧ (dot3 p x w).isFinite = true ∧ |real (dot3 p x w)| ≤ 20 * (2 : ℝ)^(exponent+3) := by
  have hp (c : Fin 2) (i : Fin 8) : (prepared3 p x c i).isFinite = true ∧
      |real (prepared3 p x c i)| ≤ (2 : ℝ)^(exponent-(AffineDot.inputShift3 i : Int)) :=
    AffineScaledBounds.prepare_range p.divide division _ _ exponent lo (by omega) (hx _)
  have next (c : Fin 2) (acc : Float32) (count : Nat) (size : count+10 < 16777216)
      (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+3)) :
      valid3 p x w c acc ∧ (step3 p x w c acc).isFinite = true ∧
        |real (step3 p x w c acc)| ≤ ((count+10 : Nat) : ℝ) * (2 : ℝ)^(exponent+3) := by
    have h := AffineShiftedDotBounds.range3 p.contracted (w c) (prepared3 p x c) acc exponent count (by omega) hi size (hp c) ha
    have hf := Arithmetic.finite_evaluate (AffineDot.bind3 (w c) (prepared3 p x c) acc)
      (AffineDot.expression3 p.contracted) h.1
    rw [AffineDot.execution3] at hf
    exact ⟨h.1, hf, h.2⟩
  have h0 := next 0 0 0 (by decide) (zero_range _)
  have h1 := next 1 _ 10 (by decide) h0.2
  have hb := h1.2.2
  norm_num only [Nat.cast_add, Nat.cast_ofNat] at hb
  have hd : dot3 p x w = step3 p x w 1 (step3 p x w 0 0) := by
    simp only [dot3, show List.finRange 2 = [0, 1] from by decide +kernel, List.foldl_cons, List.foldl_nil]
  rw [hd]
  exact ⟨⟨fun i => (hx i).1, fun c i => (hp c i).1, ⟨h0.1, h1.1, True.intro⟩⟩, h1.2.1, hb⟩

theorem range3 (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (scale bias : BF)
    (ex es eb out : Int) (lo : -133 ≤ ex) (hi : ex+3 ≤ 100)
    (outLo : -149 ≤ out) (outHi : out ≤ 100) (scaled : ex+3+es ≤ out) (biased : ex+eb ≤ out)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^ex)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ (2 : ℝ)^es)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ (2 : ℝ)^eb) :
    Finite3 p x w scale bias ∧ (value3 p x w scale bias).isFinite = true ∧
      |real (value3 p x w scale bias)| ≤ 36 * (2 : ℝ)^out := by
  have hd := dot3_range p division x w ex (by omega) hi hx
  have hu := AffineSumBounds.range3 x ex lo (by omega) hx
  have ht := AffineValueBounds.tail_range p.tailContracted scale bias (dot3 p x w) (AffineInput.summed x AffineInput.groups3)
    20 (ex+3) ex es eb out outLo outHi (by decide) scaled biased hs hb hd.2 hu.2.2
  exact ⟨⟨hd.1, hu.1, hu.2.1, hs.1, hb.1, ht.1⟩, ht.2.1,
    by simpa only [value3, show (20 : Nat)+16=36 from rfl, Nat.cast_ofNat] using ht.2.2⟩

theorem range4 (p : Platform) (division : DivisionDirectedBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (scale bias : BF)
    (ex es eb out : Int) (lo : -133 ≤ ex) (hi : ex+4 ≤ 100)
    (outLo : -149 ≤ out) (outHi : out ≤ 100) (scaled : ex+4+es ≤ out) (biased : ex+eb ≤ out)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^ex)
    (hs : Model.isFinite scale = true ∧ |Model.toReal scale| ≤ (2 : ℝ)^es)
    (hb : Model.isFinite bias = true ∧ |Model.toReal bias| ≤ (2 : ℝ)^eb) :
    Finite4 p x w scale bias ∧ (value4 p x w scale bias).isFinite = true ∧
      |real (value4 p x w scale bias)| ≤ 32 * (2 : ℝ)^out := by
  have hd := dot4_range p division x w ex (by omega) hi hx
  have hu := AffineSumBounds.range4 x ex lo (by omega) hx
  have ht := AffineValueBounds.tail_range p.tailContracted scale bias (dot4 p x w) (AffineInput.summed x AffineInput.groups4)
    16 (ex+4) ex es eb out outLo outHi (by decide) scaled biased hs hb hd.2 hu.2.2
  exact ⟨⟨hd.1, hu.1, hu.2.1, hs.1, hb.1, ht.1⟩, ht.2.1,
    by simpa only [value4, show (16 : Nat)+16=32 from rfl, Nat.cast_ofNat] using ht.2.2⟩

end Inference.Kernels.Quantization.AffineShiftedTileBounds
