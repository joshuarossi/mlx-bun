import contracts.mlx.HalfMemory
import contracts.mlx.TensorWords

namespace Inference.Contracts.Mlx.TensorMemory

-- A finite immutable payload placed in an otherwise arbitrary byte memory.
-- The native loader must supply these bytes at this base address. Bounds
-- below establish the accesses without assuming a word-level attachment.
def place (payload : Fin n → BitVec 8) (base : Nat) (before : ByteMemory.Bytes) : ByteMemory.Bytes :=
  fun address => if h : base ≤ address ∧ address-base<n then payload ⟨address-base,h.2⟩ else before address

theorem placed_byte (payload : Fin n → BitVec 8) (base : Nat) (before : ByteMemory.Bytes) (offset : Fin n) :
    place payload base before (base+offset.val)=payload offset := by
  simp only [place, Nat.add_sub_cancel_left, Nat.le_add_right, offset.isLt, and_self, ↓reduceDIte]

theorem frame (payload : Fin n → BitVec 8) (base : Nat) (before : ByteMemory.Bytes) (address : Nat)
    (outside : address<base ∨ base+n ≤ address) : place payload base before address=before address := by
  unfold place
  rw [dite_eq_right (by omega)]

private theorem append_value (high : BitVec m) (low : BitVec n) :
    (high ++ low).toNat=high.toNat*2^n+low.toNat := by
  rw [BitVec.toNat_append, ← Nat.shiftLeft_add_eq_or_of_lt low.isLt, Nat.shiftLeft_eq]

theorem load16 (payload : Fin (2*n) → BitVec 8) (base : Nat) (before : ByteMemory.Bytes) (index : Fin n) :
    HalfMemory.load (place payload base before) (base+2*index.val)=TensorWords.readWord payload index := by
  unfold HalfMemory.load TensorWords.readWord
  simp only [Nat.add_zero, Nat.add_assoc]
  rw [placed_byte payload base before ⟨2*index.val+1, by omega⟩,
    placed_byte payload base before ⟨2*index.val, by omega⟩]
  apply BitVec.eq_of_toNat_eq
  rw [TensorWords.littleEndian16_value, append_value]
  norm_num
  omega

theorem load32 (payload : Fin (4*n) → BitVec 8) (base : Nat) (before : ByteMemory.Bytes) (index : Fin n) :
    ByteMemory.load32 (place payload base before) (base+4*index.val)=TensorWords.readWord32 payload index := by
  unfold ByteMemory.load32
  simp only [Nat.add_zero, Nat.add_assoc]
  rw [placed_byte payload base before ⟨4*index.val, by omega⟩,
    placed_byte payload base before ⟨4*index.val+1, by omega⟩,
    placed_byte payload base before ⟨4*index.val+2, by omega⟩,
    placed_byte payload base before ⟨4*index.val+3, by omega⟩]
  apply BitVec.eq_of_toNat_eq
  rw [TensorWords.readWord32_value]
  simp only [ByteMemory.join, append_value]
  norm_num
  omega

theorem load16_bounds (base : Nat) (index : Fin n) (aligned : base%2=0) (bounded : base+2*n ≤ 2^64) :
    (base+2*index.val)%2=0 ∧ base ≤ base+2*index.val ∧ base+2*index.val+2 ≤ base+2*n ∧
      base+2*index.val+2 ≤ 2^64 := by omega

theorem load32_bounds (base : Nat) (index : Fin n) (aligned : base%4=0) (bounded : base+4*n ≤ 2^64) :
    (base+4*index.val)%4=0 ∧ base ≤ base+4*index.val ∧ base+4*index.val+4 ≤ base+4*n ∧
      base+4*index.val+4 ≤ 2^64 := by omega

end Inference.Contracts.Mlx.TensorMemory
