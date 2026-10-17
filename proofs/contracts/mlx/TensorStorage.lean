import contracts.mlx.TensorMemory
import contracts.mlx.ArrayFrame

namespace Inference.Contracts.Mlx.TensorStorage

-- Exact byte attachment, rather than a hash or a range-only certificate.
-- The loader must establish it for its actual allocation.
structure Buffer (payload : Fin n → BitVec 8) where
  bytes : ByteMemory.Bytes
  base : Nat
  bounded : base+n ≤ 2^64
  attached : ∀ i, bytes (base+i.val)=payload i

def placed (payload : Fin n → BitVec 8) (base : Nat) (before : ByteMemory.Bytes)
    (bounded : base+n ≤ 2^64) : Buffer payload :=
  ⟨TensorMemory.place payload base before, base, bounded, TensorMemory.placed_byte payload base before⟩

def Buffer.reframe {payload : Fin n → BitVec 8} (buffer : Buffer payload) (after : ByteMemory.Bytes)
    (same : ∀ offset < n, after (buffer.base+offset)=buffer.bytes (buffer.base+offset)) : Buffer payload where
  bytes := after
  base := buffer.base
  bounded := buffer.bounded
  attached := fun i => (same i.val i.isLt).trans (buffer.attached i)

theorem Buffer.placed_region {payload : Fin n → BitVec 8} (buffer : Buffer payload)
    (offset : Nat) (bound : offset<n) :
    buffer.bytes (buffer.base+offset)=TensorMemory.place payload buffer.base buffer.bytes (buffer.base+offset) :=
  (buffer.attached ⟨offset,bound⟩).trans (TensorMemory.placed_byte payload buffer.base buffer.bytes ⟨offset,bound⟩).symm

theorem Buffer.load16 {payload : Fin (2*n) → BitVec 8} (buffer : Buffer payload) (i : Fin n) :
    HalfMemory.load buffer.bytes (buffer.base+2*i.val)=TensorWords.readWord payload i := by
  rw [ArrayFrame.half_congr (TensorMemory.place payload buffer.base buffer.bytes) buffer.bytes buffer.base (2*n) _
    buffer.placed_region (by have := i.isLt; omega)]
  exact TensorMemory.load16 payload buffer.base buffer.bytes i

theorem Buffer.load32 {payload : Fin (4*n) → BitVec 8} (buffer : Buffer payload) (i : Fin n) :
    ByteMemory.load32 buffer.bytes (buffer.base+4*i.val)=TensorWords.readWord32 payload i := by
  rw [ArrayFrame.word_congr (TensorMemory.place payload buffer.base buffer.bytes) buffer.bytes buffer.base (4*n) _
    buffer.placed_region (by have := i.isLt; omega)]
  exact TensorMemory.load32 payload buffer.base buffer.bytes i

def Buffer.after16 {payload : Fin n → BitVec 8} (buffer : Buffer payload) {base size : Nat}
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores)
    (separate : MemoryRegions.Disjoint base size buffer.base n) : Buffer payload :=
  buffer.reframe (HalfMemory.execute stores buffer.bytes) (MemoryRegions.execute16_other stores buffer.bytes inside separate)

def Buffer.after32 {payload : Fin n → BitVec 8} (buffer : Buffer payload) {base size : Nat}
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores)
    (separate : MemoryRegions.Disjoint base size buffer.base n) : Buffer payload :=
  buffer.reframe (ByteMemory.execute stores buffer.bytes) (MemoryRegions.execute32_other stores buffer.bytes inside separate)

theorem place_other (payload : Fin n → BitVec 8) (base : Nat) (before : ByteMemory.Bytes)
    {other size : Nat} (separate : MemoryRegions.Disjoint base n other size) (offset : Nat) (bound : offset<size) :
    TensorMemory.place payload base before (other+offset)=before (other+offset) := by
  apply TensorMemory.frame
  rcases separate with left | right
  · exact Or.inr (by omega)
  · exact Or.inl (by omega)

def Buffer.afterPlace {payload : Fin n → BitVec 8} (buffer : Buffer payload)
    (added : Fin m → BitVec 8) (base : Nat) (separate : MemoryRegions.Disjoint base m buffer.base n) : Buffer payload :=
  buffer.reframe (TensorMemory.place added base buffer.bytes) (place_other added base buffer.bytes separate)

end Inference.Contracts.Mlx.TensorStorage
