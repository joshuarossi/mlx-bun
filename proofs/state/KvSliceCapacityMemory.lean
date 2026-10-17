import state.KvSliceCapacityPreparation
namespace Inference.State.KvSliceCapacityMemory
open Contracts.Mlx KvBytes KvSliceCapacityPreparation
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

structure Slice (old : History n) (next : Row) (before : ByteMemory.Bytes) (slab : Nat) where
  choice : Choice (KvAllocation.capacity (n+1)) slab
  source : KvCopy.Source next
  shared : source.bytes=before
  safe : MemoryRegions.Disjoint choice.destination (bytes (KvAllocation.capacity (n+1)))
    source.base (KvAppendMemory.sourceBytes source)
  oldValues : ∀ head time i, HalfMemory.load before
    (slab+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=bits (old head time i)

variable {old : History n} {next : Row} {before : ByteMemory.Bytes} {slab : Nat}
def Slice.preservation (slice : Slice old next before slab) := slice.choice.prepare before

def Slice.input (slice : Slice old next before slab) : KvCopy.Source next :=
  KvAppendMemory.reframe slice.source slice.preservation.memory (fun offset bound =>
    (slice.preservation.frame (by unfold Slice.preservation; rw [Choice.destination_prepare]; exact slice.safe) offset bound).trans
      (congrFun slice.shared _).symm)

theorem old_index (head : Fin 4) (time : Fin n) (i : Fin 256) :
    Kv.address (KvAllocation.capacity (n+1)) head time.val i < words (KvAllocation.capacity (n+1)) := by
  have bound := KvPreparedMemory.old_bounds head time i
  rw [← region_bytes] at bound
  unfold bytes at bound
  omega

def Slice.appended (slice : Slice old next before slab) : KvAppendMemory.Execution old next :=
  KvAppendMemory.Execution.canonical old next slice.input slice.choice.destination (KvAllocation.capacity (n+1))
    slice.choice.aligned (Nat.lt_of_lt_of_le (Nat.lt_succ_self n) (KvAllocation.capacity_bounds (n+1)).1)
    (by simpa only [Slice.input,KvAppendMemory.reframe,KvAppendMemory.sourceBytes,bytes,words,Nat.mul_assoc] using slice.safe) (by
      intro head time i
      have same := slice.preservation.read ⟨Kv.address (KvAllocation.capacity (n+1)) head time.val i,old_index head time i⟩
      rw [show slice.preservation.destination=slice.choice.destination from Choice.destination_prepare _ _] at same
      exact same.trans (slice.oldValues head time i))

theorem Slice.appended_base (slice : Slice old next before slab) : slice.appended.base=slice.choice.destination := rfl
theorem Slice.appended_capacity (slice : Slice old next before slab) : slice.appended.capacity=KvAllocation.capacity (n+1) := rfl
theorem Slice.appended_before (slice : Slice old next before slab) : slice.appended.copy.before=slice.preservation.memory :=
  slice.appended.shared
attribute [local irreducible] Slice.appended

def Slice.memory (slice : Slice old next before slab) : ByteMemory.Bytes := slice.appended.copy.memory

theorem Slice.read (slice : Slice old next before slab) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load slice.memory (slice.choice.destination+2*Kv.address (KvAllocation.capacity (n+1)) head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
  have address := congrArg₂ (fun base capacity => base+2*Kv.address capacity head time.val i)
    slice.appended_base slice.appended_capacity
  exact (congrArg (HalfMemory.load slice.appended.copy.memory) address).symm.trans (slice.appended.load_correct head time i)

theorem Slice.frame (slice : Slice old next before slab)
    (safe : MemoryRegions.Disjoint slice.choice.destination (KvRegions.bytes (n+1)) base size)
    (offset : Nat) (bound : offset<size) : slice.memory (base+offset)=before (base+offset) := by
  have span : bytes (KvAllocation.capacity (n+1))=KvRegions.bytes (n+1) := region_bytes
  have same := slice.appended.other_region (by
    rw [slice.appended_base,slice.appended_capacity]
    simpa only [KvRegions.bytes] using safe) offset bound
  exact same.trans ((congrFun slice.appended_before _).trans
    (slice.preservation.frame (by unfold Slice.preservation; rw [Choice.destination_prepare,span]; exact safe) offset bound))
end Inference.State.KvSliceCapacityMemory
