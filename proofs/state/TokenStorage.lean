import contracts.mlx.WordArrayWrites

namespace Inference.State.TokenStorage
open Contracts.Mlx

structure Buffer (token : Fin 248320) where
  bytes : ByteMemory.Bytes
  base : Nat
  aligned : base%4=0
  bounded : base+4 ≤ 2^64
  attached : ByteMemory.load32 bytes base=BitVec.ofNat 32 token.val

def Buffer.canonical (token : Fin 248320) : Buffer token where
  bytes := ByteMemory.encode (fun _ => BitVec.ofNat 32 token.val)
  base := 0
  aligned := by decide
  bounded := by decide
  attached := ByteMemory.load32_encode _ _ (by decide)

variable {token : Fin 248320}

def Buffer.read (buffer : Buffer token) : Nat := (ByteMemory.load32 buffer.bytes buffer.base).toNat

theorem Buffer.read_correct (buffer : Buffer token) : buffer.read=token.val := by
  unfold Buffer.read
  rw [buffer.attached, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by have := token.isLt; omega)]

-- Attachment can be constructed directly from a completed sampler's raw
-- readback, keeping exactly its byte image and address.
def Buffer.fromRead (token : Fin 248320) (bytes : ByteMemory.Bytes) (base : Nat)
    (aligned : base%4=0) (bounded : base+4 ≤ 2^64)
    (read : (ByteMemory.load32 bytes base).toNat=token.val) : Buffer token where
  bytes := bytes
  base := base
  aligned := aligned
  bounded := bounded
  attached := by
    apply BitVec.eq_of_toNat_eq
    rw [read, BitVec.toNat_ofNat, Nat.mod_eq_of_lt (by have := token.isLt; omega)]

theorem Buffer.fromRead_bytes (token : Fin 248320) (bytes : ByteMemory.Bytes) (base : Nat)
    (aligned : base%4=0) (bounded : base+4 ≤ 2^64)
    (read : (ByteMemory.load32 bytes base).toNat=token.val) :
    (Buffer.fromRead token bytes base aligned bounded read).bytes=bytes := rfl

theorem Buffer.row_bounds (buffer : Buffer token) (width : Nat) (i : Fin width) : buffer.read*width+i.val<248320*width := by
  rw [buffer.read_correct]
  calc
    _ < token.val*width+width := Nat.add_lt_add_left i.isLt _
    _ = (token.val+1)*width := by rw [Nat.add_mul, Nat.one_mul]
    _ ≤ 248320*width := Nat.mul_le_mul_right width (by have := token.isLt; omega)

theorem Buffer.int32_index (buffer : Buffer token) : buffer.read<2^31 := by
  rw [buffer.read_correct]
  have := token.isLt
  omega

end Inference.State.TokenStorage
