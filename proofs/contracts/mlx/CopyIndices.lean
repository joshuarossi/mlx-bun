import Std

namespace Inference.Contracts.Mlx.CopyIndices

-- The non-large copy kernels instantiate IdxT=int. Prove the bit-vector
-- arithmetic agrees with natural indexing, and that both products and the
-- sum remain in the nonnegative signed-32 range (so no signed overflow).
def elem2 (x y xStride yStride : Nat) : BitVec 32 :=
  BitVec.ofNat 32 x * BitVec.ofNat 32 xStride + BitVec.ofNat 32 y * BitVec.ofNat 32 yStride

theorem products_bound (x y xStride yStride : Nat) (bounded : x*xStride+y*yStride<2^31) :
    x*xStride<2^31 ∧ y*yStride<2^31 := by omega

theorem elem2_exact (x y xStride yStride : Nat) (hx : x<2^31) (hy : y<2^31)
    (hxs : xStride<2^31) (hys : yStride<2^31) (bounded : x*xStride+y*yStride<2^31) :
    (elem2 x y xStride yStride).toNat=x*xStride+y*yStride := by
  have a : x*xStride<2^32 := by omega
  have b : y*yStride<2^32 := by omega
  have total : x*xStride+y*yStride<2^32 := by omega
  simp only [elem2, BitVec.toNat_add, BitVec.toNat_mul, BitVec.toNat_ofNat,
    Nat.mod_eq_of_lt (show x<2^32 by omega), Nat.mod_eq_of_lt (show y<2^32 by omega),
    Nat.mod_eq_of_lt (show xStride<2^32 by omega), Nat.mod_eq_of_lt (show yStride<2^32 by omega),
    Nat.mod_eq_of_lt a, Nat.mod_eq_of_lt b, Nat.mod_eq_of_lt total]

theorem elem2_signed (x y xStride yStride : Nat) (hx : x<2^31) (hy : y<2^31)
    (hxs : xStride<2^31) (hys : yStride<2^31) (bounded : x*xStride+y*yStride<2^31) :
    (elem2 x y xStride yStride).toInt=Int.ofNat (x*xStride+y*yStride) := by
  have exactNat := elem2_exact x y xStride yStride hx hy hxs hys bounded
  rw [BitVec.toInt_eq_toNat_of_lt (by rw [exactNat]; omega), exactNat]
  rfl

end Inference.Contracts.Mlx.CopyIndices
