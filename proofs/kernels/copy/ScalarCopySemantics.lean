import contracts.mlx.ArrayFrame

set_option maxRecDepth 100000

namespace Inference.Kernels.Copy.ScalarCopySemantics
open Contracts.Mlx

-- This is the selected BF16 -> BF16, N=1 copy_s dispatch. The native else
-- branch has no size guard: the launch must contain exactly these threads.
def count : Nat := 30720

def event (source destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin count) : HalfMemory.Store :=
  ⟨destination/2+thread.val, HalfMemory.load memory source⟩

-- Each invocation reads the CURRENT heap before issuing its store. No scalar
-- value or expected output is an execution input.
def run (source destination : Nat) : List (Fin count) → HalfMemory.Bytes → HalfMemory.Bytes
  | [], memory => memory
  | thread::rest, memory =>
      run source destination rest (HalfMemory.execute [event source destination memory thread] memory)

def stores (source destination : Nat) : List (Fin count) → HalfMemory.Bytes → List HalfMemory.Store
  | [], _ => []
  | thread::rest, memory =>
      let write := event source destination memory thread
      write :: stores source destination rest (HalfMemory.execute [write] memory)

theorem run_stores (source destination : Nat) (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    run source destination threads memory=HalfMemory.execute (stores source destination threads memory) memory := by
  induction threads generalizing memory with
  | nil => rfl
  | cons thread rest ih => exact ih _

structure Allocation (source destination : Nat) : Prop where
  sourceAligned : source%2=0
  sourceBounded : source+2≤2^64
  destinationAligned : destination%2=0
  destinationBounded : destination+2*count≤2^64
  fresh : MemoryRegions.Disjoint destination (2*count) source 2

theorem event_inside (allocation : Allocation source destination) (memory : HalfMemory.Bytes) (thread : Fin count) :
    MemoryRegions.Inside16 destination (2*count) [event source destination memory thread] := by
  intro write member
  have eq := List.mem_singleton.mp member
  subst write
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [event]
  omega

theorem event_preserves_source (allocation : Allocation source destination)
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (HalfMemory.execute [event source destination memory thread] memory) source=
      HalfMemory.load memory source := by
  have same := MemoryRegions.execute16_other _ memory (event_inside allocation memory thread) allocation.fresh
  simpa only [Nat.add_zero] using ArrayFrame.half_congr memory _ source 2 0 same (by omega)

theorem stores_eq (allocation : Allocation source destination)
    (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    stores source destination threads memory=
      threads.map (HalfArrayWrites.entry destination (fun _ => HalfMemory.load memory source)) := by
  induction threads generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    simp only [stores, List.map_cons]
    congr 1
    rw [ih, event_preserves_source allocation memory thread]

theorem stores_inside (allocation : Allocation source destination)
    (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    MemoryRegions.Inside16 destination (2*count) (stores source destination threads memory) := by
  rw [stores_eq allocation]
  intro write member
  obtain ⟨thread, _, rfl⟩ := List.mem_map.mp member
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [HalfArrayWrites.entry]
  omega

theorem frame (allocation : Allocation source destination) (threads : List (Fin count))
    (memory : HalfMemory.Bytes) (separate : MemoryRegions.Disjoint destination (2*count) other size)
    (offset : Nat) (bound : offset<size) :
    run source destination threads memory (other+offset)=memory (other+offset) := by
  rw [run_stores]
  exact MemoryRegions.execute16_other _ memory (stores_inside allocation threads memory) separate offset bound

theorem scalar_retained (allocation : Allocation source destination) (threads : List (Fin count))
    (memory : HalfMemory.Bytes) :
    HalfMemory.load (run source destination threads memory) source=HalfMemory.load memory source := by
  simpa only [Nat.add_zero] using ArrayFrame.half_congr memory _ source 2 0
    (frame allocation threads memory allocation.fresh) (by omega)

theorem no_interthread_overlap (_allocation : Allocation source destination)
    (first second : Fin count) (different : first≠second) :
    MemoryRegions.Disjoint (destination+2*first.val) 2 (destination+2*second.val) 2 := by
  have differentValues : first.val≠second.val := fun equal => different (Fin.ext equal)
  unfold MemoryRegions.Disjoint
  omega

theorem index_arithmetic (thread : Fin count) :
    thread.val<2^32 ∧ thread.val*1<2^32 ∧ thread.val*1+0=thread.val ∧
      (thread.val*1+0)%2^32=thread.val ∧ (0:Nat)+1<2^31 := by
  have := thread.isLt
  dsimp only [count] at *
  omega

def trace (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    HalfArrayWrites.Trace destination (fun _ : Fin count => HalfMemory.load memory source) where
  before := memory
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  schedule := (HalfArrayWrites.programs destination (fun _ : Fin count => HalfMemory.load memory source)).flatten
  remaining := List.replicate count []
  execution := by
    simpa only [HalfArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical (HalfArrayWrites.programs destination (fun _ : Fin count => HalfMemory.load memory source))
  completed := by
    simpa only [HalfArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical_barrier (HalfArrayWrites.programs destination (fun _ : Fin count => HalfMemory.load memory source))

private theorem singleton_flatten {α β : Type} (f : α → β) (xs : List α) :
    (xs.map (fun x => [f x])).flatten=xs.map f := by
  induction xs with
  | nil => rfl
  | cons head rest ih => simp only [List.map_cons, List.flatten_cons, List.singleton_append, ih]

theorem trace_memory (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    (trace allocation memory).memory=HalfMemory.execute (HalfArrayWrites.programs destination (fun _ : Fin count => HalfMemory.load memory source)).flatten memory := rfl

theorem canonical_refines (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    run source destination (List.finRange count) memory=(trace allocation memory).memory := by
  rw [run_stores, stores_eq allocation]
  rw [trace_memory, HalfArrayWrites.programs, singleton_flatten]

theorem canonical_read (allocation : Allocation source destination) (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination (List.finRange count) memory) (destination+2*thread.val)=
      HalfMemory.load memory source := by
  rw [canonical_refines allocation memory]
  exact (trace allocation memory).read_correct thread

theorem event_address (allocation : Allocation source destination)
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    2*(event source destination memory thread).word=destination+2*thread.val ∧
      destination+2*thread.val+2≤2^64 := by
  have := allocation.destinationAligned
  have := allocation.destinationBounded
  have := thread.isLt
  dsimp only [event]
  omega

theorem uint32_index (thread : Fin count) :
    ((BitVec.ofNat 32 thread.val)*1+0).toNat=thread.val := by
  have small : thread.val<4294967296 := by have := (index_arithmetic thread).1; omega
  simp [BitVec.toNat_ofNat, Nat.mod_eq_of_lt small]

theorem signed_local (i : Nat) (reached : i≤1) :
    i<2^31 ∧ i+1<2^31 ∧ (BitVec.ofNat 32 i).toNat=i := by
  refine ⟨by omega, by omega, ?_⟩
  rw [BitVec.toNat_ofNat]
  exact Nat.mod_eq_of_lt (by omega)

-- Completion is supplied by actual coverage of dispatched thread IDs, not by
-- a final-value premise. Any permutation (and even repeated covered threads)
-- has the same readback because every dynamic load sees the retained scalar.
theorem completed_read (allocation : Allocation source destination)
    (threads : List (Fin count)) (covered : ∀ thread, thread∈threads)
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination threads memory) (destination+2*thread.val)=
      HalfMemory.load memory source := by
  rw [run_stores, stores_eq allocation, HalfMemory.execute_load _ _ _ (by
    have := allocation.destinationAligned; omega)]
  apply MemoryCells.written_value
  · intro write member _
    obtain ⟨_, _, rfl⟩ := List.mem_map.mp member
    rfl
  · exact ⟨HalfArrayWrites.entry destination (fun _ => HalfMemory.load memory source) thread,
      List.mem_map.mpr ⟨thread, covered thread, rfl⟩, by
        have := allocation.destinationAligned
        dsimp only [HalfArrayWrites.entry]
        omega⟩

theorem permutation_read (allocation : Allocation source destination)
    (threads : List (Fin count)) (completed : threads.Perm (List.finRange count))
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination threads memory) (destination+2*thread.val)=
      HalfMemory.load memory source :=
  completed_read allocation threads (fun i => completed.mem_iff.mpr (List.mem_finRange i)) memory thread

end Inference.Kernels.Copy.ScalarCopySemantics
