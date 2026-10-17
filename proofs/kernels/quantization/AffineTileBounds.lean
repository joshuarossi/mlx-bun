import kernels.quantization.AffineTile
import kernels.quantization.AffineDotBounds
import contracts.mlx.DivisionBounds

namespace Inference.Kernels.Quantization.AffineTileBounds
open Contracts.Mlx Contracts.Mlx.Numerics AffineTile
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem prepare_range (divide : Float32 → Float32 → Float32) (division : DivisionBounds.Contract divide)
    (x : BF) (shift : Fin 13) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent ≤ 100)
    (hx : Model.isFinite x = true ∧ |Model.toReal x| ≤ (2 : ℝ)^exponent) :
    (AffineInput.prepare divide x shift).isFinite = true ∧
      |real (AffineInput.prepare divide x shift)| ≤ (2 : ℝ)^exponent := by
  have hf := BFloat16.widen_finite x hx.1
  have hb : |real (BFloat16.widen x)| ≤ (2 : ℝ)^exponent := by rw [BFloat16.widen_real _ hx.1]; exact hx.2
  unfold AffineInput.prepare
  split
  · exact ⟨hf, hb⟩
  · have hc := DyadicBounds.ceiling_range 1 exponent (by decide) lo hi
    have hr := division.bounded (BFloat16.widen x) (AffineInput.divisor shift) (DyadicBounds.ceiling 1 exponent)
      hf (AffineInput.divisors_checked shift).2 (AffineInput.divisor_domain shift) hc.1
      (by simpa only [hc.2, Nat.cast_one, one_mul] using hb)
    exact ⟨division.finite _ _ hf (AffineInput.divisors_checked shift).2 (AffineInput.divisor_domain shift),
      by simpa only [hc.2, Nat.cast_one, one_mul] using hr⟩

private theorem zero_range (exponent : Int) :
    (0 : Float32).isFinite = true ∧ |real (0 : Float32)| ≤ (0 : Nat) * (2 : ℝ)^exponent := by
  have hz : real (0 : Float32) = 0 := by rw [real_unpack]; exact Model.unpackedToReal_zero .positive
  exact ⟨by decide +kernel, by simp only [hz, abs_zero, Nat.cast_zero, zero_mul, le_refl]⟩

theorem dot4_range (p : Platform) (division : DivisionBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 4 → BitVec 16) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent+16 ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    DotFinite4 p x w ∧ (dot4 p x w).isFinite = true ∧ |real (dot4 p x w)| ≤ 16 * (2 : ℝ)^(exponent+16) := by
  have hp (c : Fin 4) (i : Fin 4) : (prepared4 p x c i).isFinite = true ∧
      |real (prepared4 p x c i)| ≤ (2 : ℝ)^exponent :=
    prepare_range p.divide division _ _ exponent lo (by omega) (hx _)
  have next (c : Fin 4) (acc : Float32) (count : Nat) (size : count+4 < 16777216)
      (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+16)) :
      valid4 p x w c acc ∧ (step4 p x w c acc).isFinite = true ∧
        |real (step4 p x w c acc)| ≤ ((count+4 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := by
    have h := AffineDotBounds.range4 p.contracted (w c) (prepared4 p x c) acc exponent count (by omega) hi size (hp c) ha
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

theorem dot3_range (p : Platform) (division : DivisionBounds.Contract p.divide)
    (x : Fin 16 → BF) (w : Fin 2 → Fin 3 → BitVec 8) (exponent : Int) (lo : -149 ≤ exponent) (hi : exponent+16 ≤ 100)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^exponent) :
    DotFinite3 p x w ∧ (dot3 p x w).isFinite = true ∧ |real (dot3 p x w)| ≤ 20 * (2 : ℝ)^(exponent+16) := by
  have hp (c : Fin 2) (i : Fin 8) : (prepared3 p x c i).isFinite = true ∧
      |real (prepared3 p x c i)| ≤ (2 : ℝ)^exponent :=
    prepare_range p.divide division _ _ exponent lo (by omega) (hx _)
  have next (c : Fin 2) (acc : Float32) (count : Nat) (size : count+10 < 16777216)
      (ha : acc.isFinite = true ∧ |real acc| ≤ (count : ℝ) * (2 : ℝ)^(exponent+16)) :
      valid3 p x w c acc ∧ (step3 p x w c acc).isFinite = true ∧
        |real (step3 p x w c acc)| ≤ ((count+10 : Nat) : ℝ) * (2 : ℝ)^(exponent+16) := by
    have h := AffineDotBounds.range3 p.contracted (w c) (prepared3 p x c) acc exponent count (by omega) hi size (hp c) ha
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

end Inference.Kernels.Quantization.AffineTileBounds
