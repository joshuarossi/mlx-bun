import contracts.mlx.ArrayStorage

namespace Inference.Contracts.Mlx.ArrayViews
open ArrayStorage

-- A consumer may use the producer's actual readback as its logical value
-- without allocating or re-encoding the buffer.
def readback {values : Fin n → BF} (buffer : BFBuffer values) : BFBuffer buffer.read where
  bytes := buffer.bytes
  base := buffer.base
  aligned := buffer.aligned
  bounded := buffer.bounded
  attached := fun _ => rfl

theorem readback_bytes {values : Fin n → BF} (buffer : BFBuffer values) : (readback buffer).bytes=buffer.bytes := rfl
theorem readback_base {values : Fin n → BF} (buffer : BFBuffer values) : (readback buffer).base=buffer.base := rfl

def reindex {values other : Fin n → BF} (equal : values=other) (buffer : BFBuffer values) : BFBuffer other := by
  cases equal
  exact buffer

theorem reindex_bytes {values other : Fin n → BF} (equal : values=other) (buffer : BFBuffer values) :
    (reindex equal buffer).bytes=buffer.bytes := by cases equal; rfl

theorem reindex_base {values other : Fin n → BF} (equal : values=other) (buffer : BFBuffer values) :
    (reindex equal buffer).base=buffer.base := by cases equal; rfl

def sliceIndex (offset count : Nat) (bounded : offset+count ≤ n) (i : Fin count) : Fin n :=
  ⟨offset+i.val, by have := i.isLt; omega⟩

def slice {values : Fin n → BF} (buffer : BFBuffer values) (offset count : Nat) (bounded : offset+count ≤ n) :
    BFBuffer (fun i => values (sliceIndex offset count bounded i)) where
  bytes := buffer.bytes
  base := buffer.base+2*offset
  aligned := by have := buffer.aligned; omega
  bounded := by have := buffer.bounded; omega
  attached := by
    intro i
    have read := buffer.attached (sliceIndex offset count bounded i)
    simpa only [sliceIndex, Nat.mul_add, Nat.add_assoc] using read

theorem slice_bytes {values : Fin n → BF} (buffer : BFBuffer values) (offset count : Nat) (bounded : offset+count ≤ n) :
    (slice buffer offset count bounded).bytes=buffer.bytes := rfl

theorem slice_read {values : Fin n → BF} (buffer : BFBuffer values) (offset count : Nat) (bounded : offset+count ≤ n) (i : Fin count) :
    (slice buffer offset count bounded).read i=buffer.read (sliceIndex offset count bounded i) := by
  rw [BFBuffer.read_correct, BFBuffer.read_correct]

end Inference.Contracts.Mlx.ArrayViews
