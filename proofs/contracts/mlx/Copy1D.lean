import contracts.mlx.HalfArrayWrites
import contracts.mlx.CopyIndices

namespace Inference.Contracts.Mlx.Copy1D

-- copy_gg_nd1 with one 16-bit word per thread, unit output stride, and
-- an already computed source offset. Scalar/vector copies below 65536
-- elements share these accesses when sourceStride is zero/one.
def values (source : HalfMemory.Bytes) (sourceBase sourceStride : Nat) (i : Fin n) : BitVec 16 :=
  HalfMemory.load source (sourceBase+2*(i.val*sourceStride))

abbrev Trace (source : HalfMemory.Bytes) (sourceBase sourceStride destinationBase n : Nat) :=
  HalfArrayWrites.Trace destinationBase (values (n := n) source sourceBase sourceStride)

def Trace.canonical (source : HalfMemory.Bytes) (sourceBase sourceStride n : Nat) (bounded : 2*n ≤ 2^64) :
    Trace source sourceBase sourceStride 0 n := HalfArrayWrites.Trace.canonical _ bounded

theorem read_correct (source : HalfMemory.Bytes) (sourceBase sourceStride destinationBase n : Nat)
    (trace : Trace source sourceBase sourceStride destinationBase n) (i : Fin n) :
    HalfMemory.load trace.memory (destinationBase+2*i.val)=HalfMemory.load source (sourceBase+2*(i.val*sourceStride)) :=
  trace.read_correct i

theorem vector_read (source : HalfMemory.Bytes) (sourceBase destinationBase n : Nat)
    (trace : Trace source sourceBase 1 destinationBase n) (i : Fin n) :
    HalfMemory.load trace.memory (destinationBase+2*i.val)=HalfMemory.load source (sourceBase+2*i.val) := by
  simpa only [Nat.mul_one] using read_correct source sourceBase 1 destinationBase n trace i

theorem scalar_read (source : HalfMemory.Bytes) (sourceBase destinationBase n : Nat)
    (trace : Trace source sourceBase 0 destinationBase n) (i : Fin n) :
    HalfMemory.load trace.memory (destinationBase+2*i.val)=HalfMemory.load source sourceBase := by
  simpa only [Nat.mul_zero, Nat.add_zero] using read_correct source sourceBase 0 destinationBase n trace i

theorem source_bounds (sourceBase sourceStride n : Nat) (aligned : sourceBase%2=0)
    (bounded : sourceBase+2*((n-1)*sourceStride)+2 ≤ 2^64) (i : Fin n) :
    (sourceBase+2*(i.val*sourceStride))%2=0 ∧ sourceBase+2*(i.val*sourceStride)+2 ≤ 2^64 := by
  have order : i.val ≤ n-1 := by have := i.isLt; omega
  have := Nat.mul_le_mul_right sourceStride order
  omega

theorem signed_index (i stride : Nat) (ib : i<2^31) (sb : stride<2^31) (bound : i*stride<2^31) :
    (CopyIndices.elem2 i 0 stride 0).toInt=Int.ofNat (i*stride) := by
  simpa only [Nat.zero_mul, Nat.add_zero] using CopyIndices.elem2_signed i 0 stride 0 ib (by decide) sb (by decide) (by simpa using bound)

end Inference.Contracts.Mlx.Copy1D
