import contracts.mlx.ArrayStorage
import contracts.mlx.MemoryRegions
import contracts.mlx.HalfArrayWrites
import contracts.mlx.WordArrayWrites
import contracts.mlx.FloatArrayWrites

namespace Inference.Contracts.Mlx.ArrayFrame

-- A protected buffer retains its attachment when a launch writes only a
-- disjoint region of the same memory. These are proofs about the stores;
-- they introduce no runtime bounds or compatibility checks.
theorem half_congr (before after : ByteMemory.Bytes) (base size address : Nat)
    (same : ∀ offset < size, after (base+offset)=before (base+offset)) (bound : address+2 ≤ size) :
    HalfMemory.load after (base+address)=HalfMemory.load before (base+address) := by
  unfold HalfMemory.load
  rw [Nat.add_assoc, same _ (by omega), Nat.add_assoc, same _ (by omega)]

theorem word_congr (before after : ByteMemory.Bytes) (base size address : Nat)
    (same : ∀ offset < size, after (base+offset)=before (base+offset)) (bound : address+4 ≤ size) :
    ByteMemory.load32 after (base+address)=ByteMemory.load32 before (base+address) := by
  unfold ByteMemory.load32
  rw [Nat.add_assoc, same _ (by omega), Nat.add_assoc, same _ (by omega),
    Nat.add_assoc, same _ (by omega), Nat.add_assoc, same _ (by omega)]

def bf {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values) (after : ByteMemory.Bytes)
    (same : ∀ offset < 2*n, after (source.base+offset)=source.bytes (source.base+offset)) :
    ArrayStorage.BFBuffer values where
  bytes := after
  base := source.base
  aligned := source.aligned
  bounded := source.bounded
  attached := by
    intro i
    rw [half_congr source.bytes after source.base (2*n) _ same (by have := i.isLt; omega)]
    exact source.attached i

def fp {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values) (after : ByteMemory.Bytes)
    (same : ∀ offset < 4*n, after (source.base+offset)=source.bytes (source.base+offset)) :
    ArrayStorage.FloatBuffer values where
  bytes := after
  base := source.base
  aligned := source.aligned
  bounded := source.bounded
  attached := by
    intro i
    unfold FloatMemory.load
    rw [word_congr source.bytes after source.base (4*n) _ same (by have := i.isLt; omega)]
    exact source.attached i

def bf_after32 {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (2*n)) : ArrayStorage.BFBuffer values :=
  bf source (ByteMemory.execute stores source.bytes) (MemoryRegions.execute32_other stores source.bytes inside separate)

def bf_after16 {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (2*n)) : ArrayStorage.BFBuffer values :=
  bf source (HalfMemory.execute stores source.bytes) (MemoryRegions.execute16_other stores source.bytes inside separate)

def fp_after32 {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values)
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (4*n)) : ArrayStorage.FloatBuffer values :=
  fp source (ByteMemory.execute stores source.bytes) (MemoryRegions.execute32_other stores source.bytes inside separate)

def fp_after16 {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (4*n)) : ArrayStorage.FloatBuffer values :=
  fp source (HalfMemory.execute stores source.bytes) (MemoryRegions.execute16_other stores source.bytes inside separate)

theorem bf_after32_bytes {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (stores : List ByteMemory.Store) (inside : MemoryRegions.Inside32 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (2*n)) :
    (bf_after32 source stores inside separate).bytes=ByteMemory.execute stores source.bytes := rfl

theorem fp_after16_bytes {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values)
    (stores : List HalfMemory.Store) (inside : MemoryRegions.Inside16 base size stores)
    (separate : MemoryRegions.Disjoint base size source.base (4*n)) :
    (fp_after16 source stores inside separate).bytes=HalfMemory.execute stores source.bytes := rfl

theorem half_stores_inside {values : Fin n → BitVec 16} (trace : HalfArrayWrites.Trace base values) :
    MemoryRegions.Inside16 base (2*n) trace.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨i, rfl⟩ := HalfArrayWrites.member _ _ store original
  have := i.isLt
  have := trace.aligned
  dsimp only [HalfArrayWrites.entry]
  omega

theorem word_stores_inside {values : Fin n → BitVec 32} (trace : WordArrayWrites.Trace base values) :
    MemoryRegions.Inside32 base (4*n) trace.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨i, rfl⟩ := WordArrayWrites.member _ _ store original
  have := i.isLt
  have := trace.aligned
  dsimp only [WordArrayWrites.entry]
  omega

theorem float_stores_inside {values : Fin n → Float32} (trace : FloatArrayWrites.Trace base values) :
    MemoryRegions.Inside32 base (4*n) trace.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule trace.execution trace.completed).mem_iff.mp member
  obtain ⟨i, rfl⟩ := FloatArrayWrites.member _ _ store original
  have := i.isLt
  have := trace.aligned
  dsimp only [FloatArrayWrites.entry]
  omega

def bf_after_words {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    {output : Fin m → BitVec 32} (trace : WordArrayWrites.Trace base output)
    (shared : trace.before=source.bytes) (separate : MemoryRegions.Disjoint base (4*m) source.base (2*n)) :
    ArrayStorage.BFBuffer values :=
  bf source trace.memory (by
    intro offset bound
    unfold WordArrayWrites.Trace.memory
    rw [shared]
    exact MemoryRegions.execute32_other _ _ (word_stores_inside trace) separate offset bound)

def bf_after_halves {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    {output : Fin m → BitVec 16} (trace : HalfArrayWrites.Trace base output)
    (shared : trace.before=source.bytes) (separate : MemoryRegions.Disjoint base (2*m) source.base (2*n)) :
    ArrayStorage.BFBuffer values :=
  bf source trace.memory (by
    intro offset bound
    unfold HalfArrayWrites.Trace.memory
    rw [shared]
    exact MemoryRegions.execute16_other _ _ (half_stores_inside trace) separate offset bound)

def fp_after_floats {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values)
    {output : Fin m → Float32} (trace : FloatArrayWrites.Trace base output)
    (shared : trace.before=source.bytes) (separate : MemoryRegions.Disjoint base (4*m) source.base (4*n)) :
    ArrayStorage.FloatBuffer values :=
  fp source trace.memory (by
    intro offset bound
    unfold FloatArrayWrites.Trace.memory
    rw [shared]
    exact MemoryRegions.execute32_other _ _ (float_stores_inside trace) separate offset bound)

theorem bf_after_words_bytes {values : Fin n → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    {output : Fin m → BitVec 32} (trace : WordArrayWrites.Trace base output)
    (shared : trace.before=source.bytes) (separate : MemoryRegions.Disjoint base (4*m) source.base (2*n)) :
    (bf_after_words source trace shared separate).bytes=trace.memory := rfl

theorem fp_after_floats_bytes {values : Fin n → Float32} (source : ArrayStorage.FloatBuffer values)
    {output : Fin m → Float32} (trace : FloatArrayWrites.Trace base output)
    (shared : trace.before=source.bytes) (separate : MemoryRegions.Disjoint base (4*m) source.base (4*n)) :
    (fp_after_floats source trace shared separate).bytes=trace.memory := rfl

end Inference.Contracts.Mlx.ArrayFrame
