import contracts.mlx.ArrayFrame
import contracts.mlx.CopyContiguous

set_option maxRecDepth 10000

namespace Inference.Kernels.Copy.ScalarCopyQuadSemantics
open Contracts.Mlx
attribute [local irreducible] List.finRange

-- This is the selected BF16 -> BF16, N=1 copy_s dispatch. The native else
-- branch has no size guard: the launch must contain exactly these threads.
def count : Nat := 262144

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

theorem signed_local (i : Nat) (reached : i≤4) :
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

def threadCount : Nat := 65536

def index (thread : Fin threadCount) (off : Fin 4) : Fin count :=
  ⟨4*thread.val+off.val,by have := thread.isLt; have := off.isLt; unfold threadCount count at *; omega⟩

def indices (threads : List (Fin threadCount)) : List (Fin count) :=
  threads.flatMap (fun thread => (List.finRange 4).map (index thread))

theorem native_index (thread : Fin threadCount) :
    4*thread.val+4≤count ∧ 4*thread.val+4<2^32 := by
  have := thread.isLt
  unfold threadCount count at *
  omega

theorem native_uint32 (thread : Fin threadCount) (off : Fin 4) :
    ((BitVec.ofNat 32 thread.val)*4+BitVec.ofNat 32 off.val).toNat=(index thread off).val := by
  have h := native_index thread
  have o := off.isLt
  have small : thread.val<2^32 := by omega
  have smallOff : off.val<2^32 := by omega
  have product : thread.val*4<2^32 := by omega
  have total : thread.val*4+off.val<2^32 := by omega
  simp only [BitVec.toNat_add,BitVec.toNat_mul,BitVec.toNat_ofNat]
  change ((thread.val%2^32*4)%2^32+off.val%2^32)%2^32=4*thread.val+off.val
  rw [Nat.mod_eq_of_lt small,Nat.mod_eq_of_lt smallOff,Nat.mod_eq_of_lt product,Nat.mod_eq_of_lt total]
  omega

theorem dispatch_shape : count=262144 ∧ threadCount=65536 ∧ (count+4-1)/4=threadCount ∧
    2*count=524288 ∧ 2<count ∧ count<2^32 := by decide

-- The host clamps runtime pipeline max threads. Its actual hardware value is
-- not inferred from the source or assumed to be a fixed workgroup width.
def groupWidth (runtimeMax : Nat) : Nat := min runtimeMax threadCount

theorem groupWidth_bounds (runtimeMax : Nat) (positive : 0<runtimeMax) :
    0<groupWidth runtimeMax ∧ groupWidth runtimeMax≤threadCount ∧ groupWidth runtimeMax≤runtimeMax := by
  unfold groupWidth threadCount
  omega

theorem index_unique (a b : Fin threadCount) (i j : Fin 4) (same : index a i=index b j) : a=b ∧ i=j := by
  have h := congrArg Fin.val same
  have := i.isLt; have := j.isLt
  simp only [index] at h
  constructor <;> apply Fin.ext <;> omega

theorem indices_covered (threads : List (Fin threadCount)) (covered : ∀ t, t∈threads) (i : Fin count) :
    i∈indices threads := by
  let thread : Fin threadCount := ⟨i.val/4,by have := i.isLt; unfold count threadCount at *; omega⟩
  let off : Fin 4 := ⟨i.val%4,by omega⟩
  have same : index thread off=i := by apply Fin.ext; dsimp [index,thread,off]; omega
  exact List.mem_flatMap.mpr ⟨thread,covered thread,List.mem_map.mpr ⟨off,List.mem_finRange off,same⟩⟩

theorem copy_inside (base : Nat) (values : Fin (4*blocks) → BitVec 16)
    (schedule : List HalfMemory.Store) (remaining : List (List HalfMemory.Store))
    (execution : ThreadgroupWrites.Executes (CopyContiguous.programs base values) schedule remaining)
    (completed : ThreadgroupWrites.AtBarrier remaining) (aligned : base%2=0) : MemoryRegions.Inside16 base (2*(4*blocks)) schedule := by
  intro write member
  obtain ⟨thread,off,rfl⟩ := CopyContiguous.member base values write
    ((ThreadgroupWrites.completed_schedule execution completed).mem_iff.mp member)
  have := (CopyContiguous.index thread off).isLt
  dsimp only [CopyContiguous.entry]
  omega

def copyTrace (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    CopyContiguous.Trace (blocks:=65536) destination (fun _ => HalfMemory.load memory source) :=
  CopyContiguous.Trace.canonical destination _ memory allocation.destinationAligned

theorem copy_frame {blocks base : Nat} {values : Fin (4*blocks) → BitVec 16} (t : CopyContiguous.Trace base values)
    (separate : MemoryRegions.Disjoint base (2*(4*blocks)) other size) (offset : Nat) (bound : offset<size) :
    t.memory (other+offset)=t.before (other+offset) :=
  MemoryRegions.execute16_other _ _ (copy_inside base values _ _ t.execution t.completed t.aligned) separate offset bound

theorem heap_eq (base n : Nat) (initial left right : HalfMemory.Bytes) (value : BitVec 16)
    (left_read : ∀ i : Fin n, HalfMemory.load left (base+2*i.val)=value)
    (right_read : ∀ i : Fin n, HalfMemory.load right (base+2*i.val)=value)
    (left_frame : ∀ b s, MemoryRegions.Disjoint base (2*n) b s → ∀ o<s, left (b+o)=initial (b+o))
    (right_frame : ∀ b s, MemoryRegions.Disjoint base (2*n) b s → ∀ o<s, right (b+o)=initial (b+o)) : left=right := by
  funext address
  by_cases inside : base≤address ∧ address<base+2*n
  · let i : Fin n := ⟨(address-base)/2,by omega⟩
    let off := (address-base)%2
    have bound : off<2 := by dsimp [off]; omega
    have atAddress : base+2*i.val+off=address := by dsimp [i,off]; omega
    have first := congrArg (fun word => HalfMemory.byte word off) (left_read i)
    have second := congrArg (fun word => HalfMemory.byte word off) (right_read i)
    rw [HalfMemory.byte_load _ _ _ bound] at first second
    rw [←atAddress]
    exact first.trans second.symm
  · have separate : MemoryRegions.Disjoint base (2*n) address 1 := by unfold MemoryRegions.Disjoint; omega
    simpa only [Nat.add_zero] using (left_frame address 1 separate 0 (by decide)).trans
      (right_frame address 1 separate 0 (by decide)).symm

theorem trace_before (a : Allocation source destination) (memory : HalfMemory.Bytes) : (trace a memory).before=memory := rfl
theorem copyTrace_before (a : Allocation source destination) (memory : HalfMemory.Bytes) : (copyTrace a memory).before=memory := rfl
attribute [local irreducible] trace copyTrace

-- Exact heap equality, not a fresh attachment or desired-value premise.
theorem copyTrace_eq (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    (copyTrace allocation memory).memory=(trace allocation memory).memory := by
  apply heap_eq destination count memory _ _ (HalfMemory.load memory source)
  · exact (copyTrace allocation memory).read_correct
  · exact (trace allocation memory).read_correct
  · intro b s separate o bound
    exact (copy_frame (copyTrace allocation memory) separate o bound).trans
      (congrFun (copyTrace_before allocation memory) _)
  · intro b s separate o bound
    have h := frame allocation (List.finRange count) memory separate o bound
    rw [canonical_refines allocation memory] at h
    exact h

end Inference.Kernels.Copy.ScalarCopyQuadSemantics
