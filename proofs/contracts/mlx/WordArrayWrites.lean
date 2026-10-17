import contracts.mlx.ByteMemory
import contracts.mlx.WriteOwnership

namespace Inference.Contracts.Mlx.WordArrayWrites

-- Raw uint32 output cells retain every bit; a floating representation would
-- not be appropriate for the packed embedding codes copied by takeAxis.
def entry (base : Nat) (values : Fin n → BitVec 32) (i : Fin n) : ByteMemory.Store := ⟨base/4+i.val, values i⟩
def programs (base : Nat) (values : Fin n → BitVec 32) : List (List ByteMemory.Store) :=
  (List.finRange n).map (fun i => [entry base values i])

theorem member (base : Nat) (values : Fin n → BitVec 32) (store : ByteMemory.Store)
    (inside : store ∈ (programs base values).flatten) : ∃ i, store=entry base values i := by
  obtain ⟨thread, ht, hs⟩ := List.mem_flatten.mp inside
  obtain ⟨i, _, rfl⟩ := List.mem_map.mp ht
  exact ⟨i, List.mem_singleton.mp hs⟩

theorem covers (base : Nat) (values : Fin n → BitVec 32) (i : Fin n) :
    entry base values i ∈ (programs base values).flatten :=
  List.mem_flatten.mpr ⟨[entry base values i], List.mem_map.mpr ⟨i, List.mem_finRange _, rfl⟩, by simp⟩

theorem separated (base : Nat) (values : Fin n → BitVec 32) :
    WriteOwnership.Separated MemoryCells.Store.word (programs base values) := by
  apply List.pairwise_map.mpr
  apply (List.nodup_finRange n).imp_of_mem
  intro first second _ _ different word left right
  have hl : word=(entry base values first).word := by simpa only [List.map_singleton, List.mem_singleton] using left
  have hr : word=(entry base values second).word := by simpa only [List.map_singleton, List.mem_singleton] using right
  exact different (Fin.ext (Nat.add_left_cancel (hl.symm.trans hr)))

theorem stored (base : Nat) (values : Fin n → BitVec 32) (before : ByteMemory.Words)
    (schedule : List ByteMemory.Store) (remaining : List (List ByteMemory.Store))
    (execution : ThreadgroupWrites.Executes (programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (i : Fin n) :
    MemoryCells.execute schedule before (base/4+i.val)=values i := by
  apply MemoryCells.completed_value execution completed before _ _
  · intro store inside same
    obtain ⟨j, rfl⟩ := member base values store inside
    have equal : j=i := Fin.ext (Nat.add_left_cancel same)
    subst j
    rfl
  · exact ⟨entry base values i, covers base values i, rfl⟩

structure Trace (base : Nat) (values : Fin n → BitVec 32) where
  before : ByteMemory.Bytes
  aligned : base%4=0
  bounded : base+4*n ≤ 2^64
  schedule : List ByteMemory.Store
  remaining : List (List ByteMemory.Store)
  execution : ThreadgroupWrites.Executes (programs base values) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (values : Fin n → BitVec 32) (bounded : 4*n ≤ 2^64) : Trace 0 values :=
  let stores := programs 0 values
  ⟨fun _ => 0, by decide, by simpa using bounded, stores.flatten, List.replicate stores.length [],
    ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {n base : Nat} {values : Fin n → BitVec 32}

def Trace.memory (trace : Trace base values) : ByteMemory.Bytes := ByteMemory.execute trace.schedule trace.before

theorem Trace.read_correct (trace : Trace base values) (i : Fin n) :
    ByteMemory.load32 trace.memory (base+4*i.val)=values i := by
  unfold Trace.memory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := trace.aligned; omega), show (base+4*i.val)/4=base/4+i.val by omega]
  exact stored base values _ _ _ trace.execution trace.completed i

theorem Trace.byte_correct (trace : Trace base values) (i : Fin n) (offset : Fin 4) :
    trace.memory (base+4*i.val+offset.val)=ByteMemory.byte (values i) offset.val := by
  have equal := congrArg (fun word => ByteMemory.byte word offset.val) (trace.read_correct i)
  rwa [ByteMemory.byte_load32 _ _ _ offset.isLt] at equal

end Inference.Contracts.Mlx.WordArrayWrites
