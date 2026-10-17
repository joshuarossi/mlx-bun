import contracts.mlx.Arithmetic

namespace Inference.Kernels.Quantization.AffinePacking
open scoped BigOperators

-- The masks in affine-row.ts keep fields in their original bit positions.
-- Dividing the corresponding input coordinate by that power of two cancels
-- the position. The two 3-bit fields that cross bytes need two products.
theorem shifted_mask (n width shift : Nat) :
    n &&& ((2^width - 1) * 2^shift) = (n / 2^shift % 2^width) * 2^shift := by
  have hm := Nat.and_mod_two_pow (a := n) (b := (2^width - 1) * 2^shift) (n := shift)
  have hd := Nat.and_div_two_pow (a := n) (b := (2^width - 1) * 2^shift) (n := shift)
  simp only [Nat.mul_mod_left, Nat.and_zero] at hm
  rw [Nat.mul_div_left _ (by positivity), Nat.and_two_pow_sub_one_eq_mod] at hd
  calc
    _ = (n &&& ((2^width - 1) * 2^shift)) % 2^shift +
      2^shift * ((n &&& ((2^width - 1) * 2^shift)) / 2^shift) := (Nat.mod_add_div _ _).symm
    _ = _ := by rw [hm, hd]; ring

def packed3 (w : Fin 3 → BitVec 8) : Nat := (w 0).toNat + 256 * (w 1).toNat + 65536 * (w 2).toNat
def field3 (w : Fin 3 → BitVec 8) (i : Fin 8) : Nat := packed3 w / 2^(3*i.val) % 8
def split3 (w : Fin 3 → BitVec 8) (i : Fin 8) : Nat :=
  match i.val with
  | 0 => (w 0).toNat % 8
  | 1 => (w 0).toNat / 8 % 8
  | 2 => (w 0).toNat / 64 + 4 * ((w 1).toNat % 2)
  | 3 => (w 1).toNat / 2 % 8
  | 4 => (w 1).toNat / 16 % 8
  | 5 => (w 1).toNat / 128 + 2 * ((w 2).toNat % 4)
  | 6 => (w 2).toNat / 4 % 8
  | _ => (w 2).toNat / 32

theorem split3_correct (w : Fin 3 → BitVec 8) (i : Fin 8) : split3 w i = field3 w i := by
  have h0 := (w 0).isLt
  have h1 := (w 1).isLt
  have h2 := (w 2).isLt
  fin_cases i <;> norm_num [split3, field3, packed3] <;> omega

theorem field3_bound (w : Fin 3 → BitVec 8) (i : Fin 8) : field3 w i < 8 := Nat.mod_lt _ (by decide)

def mask8 (w : BitVec 8) (mask : Nat) : Nat := (w &&& BitVec.ofNat 8 mask).toNat
def mask16 (w : BitVec 16) (mask : Nat) : Nat := (w &&& BitVec.ofNat 16 mask).toNat

theorem mask8_shift (w : BitVec 8) (width shift : Nat) (h : (2^width-1)*2^shift < 256) :
    mask8 w ((2^width-1)*2^shift) = (w.toNat / 2^shift % 2^width) * 2^shift := by
  simp only [mask8, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt h]
  exact shifted_mask _ _ _

theorem mask16_shift (w : BitVec 16) (width shift : Nat) (h : (2^width-1)*2^shift < 65536) :
    mask16 w ((2^width-1)*2^shift) = (w.toNat / 2^shift % 2^width) * 2^shift := by
  simp only [mask16, BitVec.toNat_and, BitVec.toNat_ofNat, Nat.mod_eq_of_lt h]
  exact shifted_mask _ _ _

noncomputable def coefficient3 (w : Fin 3 → BitVec 8) (i : Fin 8) : ℝ :=
  match i.val with
  | 0 => mask8 (w 0) 0x07
  | 1 => (mask8 (w 0) 0x38 : ℝ) / 8
  | 2 => (mask8 (w 0) 0xc0 : ℝ) / 64 + (mask8 (w 1) 0x01 : ℝ) * 256 / 64
  | 3 => (mask8 (w 1) 0x0e : ℝ) / 2
  | 4 => (mask8 (w 1) 0x70 : ℝ) / 16
  | 5 => (mask8 (w 1) 0x80 : ℝ) / 128 + (mask8 (w 2) 0x03 : ℝ) * 256 / 128
  | 6 => (mask8 (w 2) 0x1c : ℝ) / 4
  | _ => (mask8 (w 2) 0xe0 : ℝ) / 32

theorem coefficient3_correct (w : Fin 3 → BitVec 8) (i : Fin 8) : coefficient3 w i = (field3 w i : ℝ) := by
  rw [← split3_correct]
  have h0 : (w 0).toNat / 64 % 4 = (w 0).toNat / 64 := by have := (w 0).isLt; omega
  have h1 : (w 1).toNat / 128 % 2 = (w 1).toNat / 128 := by have := (w 1).isLt; omega
  have h2 : (w 2).toNat / 32 % 8 = (w 2).toNat / 32 := by have := (w 2).isLt; omega
  have m07 (v : BitVec 8) := mask8_shift v 3 0 (by decide)
  have m38 (v : BitVec 8) := mask8_shift v 3 3 (by decide)
  have mc0 (v : BitVec 8) := mask8_shift v 2 6 (by decide)
  have m01 (v : BitVec 8) := mask8_shift v 1 0 (by decide)
  have m0e (v : BitVec 8) := mask8_shift v 3 1 (by decide)
  have m70 (v : BitVec 8) := mask8_shift v 3 4 (by decide)
  have m80 (v : BitVec 8) := mask8_shift v 1 7 (by decide)
  have m03 (v : BitVec 8) := mask8_shift v 2 0 (by decide)
  have m1c (v : BitVec 8) := mask8_shift v 3 2 (by decide)
  have me0 (v : BitVec 8) := mask8_shift v 3 5 (by decide)
  norm_num at m07 m38 mc0 m01 m0e m70 m80 m03 m1c me0
  fin_cases i <;> simp only [coefficient3, split3, m07, m38, mc0, m01, m0e, m70, m80, m03, m1c, me0,
    h0, h1, h2, Nat.cast_add, Nat.cast_mul, Nat.cast_ofNat] <;> ring

def field4 (w : BitVec 16) (i : Fin 4) : Nat := w.toNat / 2^(4*i.val) % 16
noncomputable def coefficient4 (w : BitVec 16) (i : Fin 4) : ℝ :=
  (mask16 w (15 * 2^(4*i.val)) : ℝ) / (2 : ℝ)^(4*i.val)

theorem coefficient4_correct (w : BitVec 16) (i : Fin 4) : coefficient4 w i = (field4 w i : ℝ) := by
  have hm : 15 * 2^(4*i.val) < 65536 := by fin_cases i <;> decide
  have hs := mask16_shift w 4 (4*i.val) hm
  norm_num only [show 2^4-1 = 15 from rfl, show 2^4 = 16 from rfl] at hs
  unfold coefficient4 field4
  rw [hs, Nat.cast_mul, Nat.cast_pow, Nat.cast_ofNat]
  exact mul_div_cancel_right₀ _ (by positivity)

theorem field4_bound (w : BitVec 16) (i : Fin 4) : field4 w i < 16 := Nat.mod_lt _ (by decide)

-- This is the exact real algebra of one three-byte portion of qdot: ten
-- products reconstruct eight weights, without treating split fields as
-- distinct weights or losing either byte's contribution.
noncomputable def qdot3 (w : Fin 3 → BitVec 8) (x : Fin 8 → ℝ) : ℝ :=
  (mask8 (w 0) 0x07 : ℝ) * x 0 + (mask8 (w 0) 0x38 : ℝ) * (x 1 / 8) +
  (mask8 (w 0) 0xc0 : ℝ) * (x 2 / 64) + (mask8 (w 1) 0x01 : ℝ) * ((x 2 / 64) * 256) +
  (mask8 (w 1) 0x0e : ℝ) * (x 3 / 2) + (mask8 (w 1) 0x70 : ℝ) * (x 4 / 16) +
  (mask8 (w 1) 0x80 : ℝ) * (x 5 / 128) + (mask8 (w 2) 0x03 : ℝ) * ((x 5 / 128) * 256) +
  (mask8 (w 2) 0x1c : ℝ) * (x 6 / 4) + (mask8 (w 2) 0xe0 : ℝ) * (x 7 / 32)

theorem qdot3_correct (w : Fin 3 → BitVec 8) (x : Fin 8 → ℝ) :
    qdot3 w x = ∑ i, x i * field3 w i := by
  simp_rw [← coefficient3_correct]
  simp [Fin.sum_univ_succ, coefficient3, qdot3]
  ring

noncomputable def qdot4 (w : BitVec 16) (x : Fin 4 → ℝ) : ℝ :=
  ((x 0 * (mask16 w 0x000f : ℝ) + (x 1 / 16) * (mask16 w 0x00f0 : ℝ)) +
    (x 2 / 256) * (mask16 w 0x0f00 : ℝ)) + (x 3 / 4096) * (mask16 w 0xf000 : ℝ)

theorem qdot4_correct (w : BitVec 16) (x : Fin 4 → ℝ) : qdot4 w x = ∑ i, x i * field4 w i := by
  simp_rw [← coefficient4_correct]
  simp [Fin.sum_univ_succ, coefficient4, qdot4]
  ring

theorem affine_identity (x quant : Fin n → ℝ) (scale bias : ℝ) :
    scale * (∑ i, x i * quant i) + (∑ i, x i) * bias = ∑ i, x i * (scale * quant i + bias) := by
  rw [Finset.mul_sum, Finset.sum_mul, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem affine3_correct (w : Fin 3 → BitVec 8) (x : Fin 8 → ℝ) (scale bias : ℝ) :
    scale * qdot3 w x + (∑ i, x i) * bias = ∑ i, x i * (scale * field3 w i + bias) := by
  rw [qdot3_correct]
  exact affine_identity x _ scale bias

theorem affine4_correct (w : BitVec 16) (x : Fin 4 → ℝ) (scale bias : ℝ) :
    scale * qdot4 w x + (∑ i, x i) * bias = ∑ i, x i * (scale * field4 w i + bias) := by
  rw [qdot4_correct]
  exact affine_identity x _ scale bias

end Inference.Kernels.Quantization.AffinePacking
