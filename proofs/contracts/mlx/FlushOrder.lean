import contracts.mlx.FlushedIdentities

namespace Inference.Contracts.Mlx.FlushOrder
open Numerics FlushToZero
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

private theorem unpack_bounds (x : Float32) (s : Float.Model.UnpackedFloat.Sign)
    (m : Nat) (e : Int) (hm : 0 < m)
    (hu : x.toModel.unpack = .finite s m e hm) :
    -149 ≤ e ∧ (8388608 ≤ m ∨ e = -149) := by
  unfold Float32.Model.unpack Float.Model.UnpackedFloat.unpack at hu
  dsimp only at hu
  split at hu
  · split at hu <;> contradiction
  · split at hu
    · rename_i hz
      split at hu
      · contradiction
      · cases hu
        simp only [hz, BitVec.toNat_ofNat]
        norm_num [Float.Model.Format.exponentBias, Float.Model.Format.binary32]
    · cases hu
      have he : 1 ≤ (Float.Model.UnpackedFloat.unpackExponent (spec := .binary32) x.toModel.toBits.toBitVec).toNat := by
        have hn : (Float.Model.UnpackedFloat.unpackExponent (spec := .binary32) x.toModel.toBits.toBitVec).toNat ≠ 0 := by
          intro h
          have : Float.Model.UnpackedFloat.unpackExponent (spec := .binary32) x.toModel.toBits.toBitVec = 0 := BitVec.eq_of_toNat_eq h
          contradiction
        omega
      constructor
      · change -149 ≤ ((Float.Model.UnpackedFloat.unpackExponent (spec := .binary32) x.toModel.toBits.toBitVec).toNat : Int) - 150
        omega
      · left
        simp only [BitVec.toNat_append, BitVec.toNat_ofNat]
        exact Nat.left_le_or

theorem small_flush (x : Float32) (hx : x.isFinite = true)
    (small : |real x| < threshold) : real (flush x) = 0 := by
  cases hu : x.toModel.unpack with
  | notANumber => simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hx
  | infinity s => simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hx
  | zero s => simp only [flush, real_unpack, hu, Model.unpackedToReal_zero]
  | finite s m e hm =>
    have hb := unpack_bounds x s m e hm hu
    have habs : |real x| = (m : ℝ) * (2 : ℝ)^e := by
      rw [real_unpack, hu, Model.unpackedToReal_finite]
      cases s <;> simp [Model.modelSignBit, Formats.Flocq.bpow,
        FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal, abs_mul]
    have hnormal : ¬8388608 ≤ m := by
      intro hm'
      have hp : (2 : ℝ)^(-149 : Int) ≤ (2 : ℝ)^e := zpow_le_zpow_right₀ (by norm_num) hb.1
      have hmreal : (8388608 : ℝ) ≤ m := by exact_mod_cast hm'
      have h := mul_le_mul hmreal hp (by positivity) (by positivity : (0 : ℝ) ≤ m)
      rw [habs] at small
      norm_num [threshold] at h small
      linarith
    have he : e = -149 := hb.2.resolve_left hnormal
    have hm' : m < 8388608 := Nat.lt_of_not_ge hnormal
    simp only [flush, hu, hm', he, and_self, ite_true, real_signed_zero]

theorem large_of_nonzero_flush (x : Float32) (hx : x.isFinite = true)
    (hn : real (flush x) ≠ 0) : threshold ≤ |real x| :=
  le_of_not_gt (fun h => hn (small_flush x hx h))

theorem flushed_small (x : Float32) (hx : flush x ≠ x) : |real x| < threshold := by
  unfold flush at hx
  split at hx
  · rename_i s m e hm hu
    split at hx
    · rename_i hs
      rw [real_unpack, hu, Model.unpackedToReal_finite]
      obtain ⟨hm', rfl⟩ := hs
      have hr : (m : ℝ) < 8388608 := by exact_mod_cast hm'
      cases s <;> norm_num [Model.modelSignBit, Formats.Flocq.bpow,
        FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal, abs_mul, threshold] <;> linarith
    · contradiction
  · contradiction

theorem monotone (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (hxy : real x ≤ real y) : real (flush x) ≤ real (flush y) := by
  by_cases ex : flush x = x
  · rw [ex]
    by_cases ey : flush y = y
    · rwa [ey]
    · have zy := (flush_eq_or_zero y).resolve_left ey
      rw [zy]
      by_contra hn
      have xp : 0 < real x := lt_of_not_ge hn
      have xnz : real (flush x) ≠ 0 := by rw [ex]; exact ne_of_gt xp
      have xl := large_of_nonzero_flush x hx xnz
      have ys := flushed_small y ey
      rw [abs_of_pos xp] at xl
      have := le_abs_self (real y)
      linarith
  · have zx := (flush_eq_or_zero x).resolve_left ex
    rw [zx]
    by_cases ey : flush y = y
    · rw [ey]
      by_contra hn
      have yp : real y < 0 := lt_of_not_ge hn
      have ynz : real (flush y) ≠ 0 := by rw [ey]; exact ne_of_lt yp
      have yl := large_of_nonzero_flush y hy ynz
      have xs := flushed_small x ex
      rw [abs_of_neg yp] at yl
      have := neg_le_abs (real x)
      linarith
    · rw [(flush_eq_or_zero y).resolve_left ey]

end Inference.Contracts.Mlx.FlushOrder
