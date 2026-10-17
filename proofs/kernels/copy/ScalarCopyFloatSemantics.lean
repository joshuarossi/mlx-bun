import contracts.mlx.ArrayFrame
import contracts.mlx.CopyFloatContiguous

set_option maxRecDepth 10000

namespace Inference.Kernels.Copy.ScalarCopyFloatSemantics
open Contracts.Mlx
attribute [local irreducible] WordArrayWrites.programs List.finRange

-- Raw32 copy events for selected FP32 -> FP32 copy_s, N=2.
-- Two such events form one of the 393216 native thread bodies.
def count : Nat := 786432

def event (source destination : Nat) (memory : ByteMemory.Bytes) (thread : Fin count) : ByteMemory.Store :=
  ⟨destination/4+thread.val, ByteMemory.load32 memory source⟩

-- Each output-store event reads the CURRENT heap before issuing its store. No scalar
-- value or expected output is an execution input.
def run (source destination : Nat) : List (Fin count) → ByteMemory.Bytes → ByteMemory.Bytes
  | [], memory => memory
  | thread::rest, memory =>
      run source destination rest (ByteMemory.execute [event source destination memory thread] memory)

def stores (source destination : Nat) : List (Fin count) → ByteMemory.Bytes → List ByteMemory.Store
  | [], _ => []
  | thread::rest, memory =>
      let write := event source destination memory thread
      write :: stores source destination rest (ByteMemory.execute [write] memory)

theorem run_stores (source destination : Nat) (threads : List (Fin count)) (memory : ByteMemory.Bytes) :
    run source destination threads memory=ByteMemory.execute (stores source destination threads memory) memory := by
  induction threads generalizing memory with
  | nil => rfl
  | cons thread rest ih => exact ih _

structure Allocation (source destination : Nat) : Prop where
  sourceAligned : source%4=0
  sourceBounded : source+4≤2^64
  destinationAligned : destination%4=0
  destinationBounded : destination+4*count≤2^64
  fresh : MemoryRegions.Disjoint destination (4*count) source 4

theorem event_inside (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (thread : Fin count) :
    MemoryRegions.Inside32 destination (4*count) [event source destination memory thread] := by
  intro write member
  have eq := List.mem_singleton.mp member
  subst write
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [event]
  omega

theorem event_preserves_source (allocation : Allocation source destination)
    (memory : ByteMemory.Bytes) (thread : Fin count) :
    ByteMemory.load32 (ByteMemory.execute [event source destination memory thread] memory) source=
      ByteMemory.load32 memory source := by
  have same := MemoryRegions.execute32_other _ memory (event_inside allocation memory thread) allocation.fresh
  simpa only [Nat.add_zero] using ArrayFrame.word_congr memory _ source 4 0 same (by omega)

theorem stores_eq (allocation : Allocation source destination)
    (threads : List (Fin count)) (memory : ByteMemory.Bytes) :
    stores source destination threads memory=
      threads.map (WordArrayWrites.entry destination (fun _ => ByteMemory.load32 memory source)) := by
  induction threads generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    simp only [stores, List.map_cons]
    congr 1
    rw [ih, event_preserves_source allocation memory thread]

theorem stores_inside (allocation : Allocation source destination)
    (threads : List (Fin count)) (memory : ByteMemory.Bytes) :
    MemoryRegions.Inside32 destination (4*count) (stores source destination threads memory) := by
  rw [stores_eq allocation]
  intro write member
  obtain ⟨thread, _, rfl⟩ := List.mem_map.mp member
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [WordArrayWrites.entry]
  omega

theorem frame (allocation : Allocation source destination) (threads : List (Fin count))
    (memory : ByteMemory.Bytes) (separate : MemoryRegions.Disjoint destination (4*count) other size)
    (offset : Nat) (bound : offset<size) :
    run source destination threads memory (other+offset)=memory (other+offset) := by
  rw [run_stores]
  exact MemoryRegions.execute32_other _ memory (stores_inside allocation threads memory) separate offset bound

theorem scalar_retained (allocation : Allocation source destination) (threads : List (Fin count))
    (memory : ByteMemory.Bytes) :
    ByteMemory.load32 (run source destination threads memory) source=ByteMemory.load32 memory source := by
  simpa only [Nat.add_zero] using ArrayFrame.word_congr memory _ source 4 0
    (frame allocation threads memory allocation.fresh) (by omega)

theorem no_output_overlap (_allocation : Allocation source destination)
    (first second : Fin count) (different : first≠second) :
    MemoryRegions.Disjoint (destination+4*first.val) 4 (destination+4*second.val) 4 := by
  have differentValues : first.val≠second.val := fun equal => different (Fin.ext equal)
  unfold MemoryRegions.Disjoint
  omega

def trace (allocation : Allocation source destination) (memory : ByteMemory.Bytes) :
    WordArrayWrites.Trace destination (fun _ : Fin count => ByteMemory.load32 memory source) where
  before := memory
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  schedule := (WordArrayWrites.programs destination (fun _ : Fin count => ByteMemory.load32 memory source)).flatten
  remaining := List.replicate count []
  execution := by
    simpa only [WordArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical (WordArrayWrites.programs destination (fun _ : Fin count => ByteMemory.load32 memory source))
  completed := by
    simpa only [WordArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical_barrier (WordArrayWrites.programs destination (fun _ : Fin count => ByteMemory.load32 memory source))

private theorem singleton_flatten {α β : Type} (f : α → β) (xs : List α) :
    (xs.map (fun x => [f x])).flatten=xs.map f := by
  induction xs with
  | nil => rfl
  | cons head rest ih => simp only [List.map_cons, List.flatten_cons, List.singleton_append, ih]

theorem trace_memory (allocation : Allocation source destination) (memory : ByteMemory.Bytes) :
    (trace allocation memory).memory=ByteMemory.execute (WordArrayWrites.programs destination (fun _ : Fin count => ByteMemory.load32 memory source)).flatten memory := rfl

theorem canonical_refines (allocation : Allocation source destination) (memory : ByteMemory.Bytes) :
    run source destination (List.finRange count) memory=(trace allocation memory).memory := by
  rw [run_stores, stores_eq allocation]
  rw [trace_memory, WordArrayWrites.programs, singleton_flatten]

theorem canonical_read (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (thread : Fin count) :
    ByteMemory.load32 (run source destination (List.finRange count) memory) (destination+4*thread.val)=
      ByteMemory.load32 memory source := by
  rw [canonical_refines allocation memory]
  exact (trace allocation memory).read_correct thread

-- Completion is supplied by actual coverage of dispatched thread IDs, not by
-- a final-value premise. Any permutation (and even repeated covered threads)
-- has the same readback because every dynamic load sees the retained scalar.
theorem completed_read (allocation : Allocation source destination)
    (threads : List (Fin count)) (covered : ∀ thread, thread∈threads)
    (memory : ByteMemory.Bytes) (thread : Fin count) :
    ByteMemory.load32 (run source destination threads memory) (destination+4*thread.val)=
      ByteMemory.load32 memory source := by
  rw [run_stores, stores_eq allocation, ByteMemory.execute_bytes_load32 _ _ _ (by
    have := allocation.destinationAligned; omega)]
  apply MemoryCells.written_value
  · intro write member _
    obtain ⟨_, _, rfl⟩ := List.mem_map.mp member
    rfl
  · exact ⟨WordArrayWrites.entry destination (fun _ => ByteMemory.load32 memory source) thread,
      List.mem_map.mpr ⟨thread, covered thread, rfl⟩, by
        have := allocation.destinationAligned
        dsimp only [WordArrayWrites.entry]
        omega⟩

theorem permutation_read (allocation : Allocation source destination)
    (threads : List (Fin count)) (completed : threads.Perm (List.finRange count))
    (memory : ByteMemory.Bytes) (thread : Fin count) :
    ByteMemory.load32 (run source destination threads memory) (destination+4*thread.val)=
      ByteMemory.load32 memory source :=
  completed_read allocation threads (fun i => completed.mem_iff.mpr (List.mem_finRange i)) memory thread


def threadCount : Nat := 393216

def index (thread : Fin threadCount) (offset : Fin 2) : Fin count :=
  ⟨2*thread.val+offset.val,by have := thread.isLt; have := offset.isLt; dsimp [count,threadCount] at *; omega⟩

def indices (threads : List (Fin threadCount)) : List (Fin count) :=
  threads.flatMap (fun thread => [index thread 0,index thread 1])

theorem indices_covered (threads : List (Fin threadCount)) (completed : threads.Perm (List.finRange threadCount))
    (i : Fin count) : i∈indices threads := by
  let thread : Fin threadCount := ⟨i.val/2,by have := i.isLt; dsimp [count,threadCount] at *; omega⟩
  have present := completed.mem_iff.mpr (List.mem_finRange thread)
  apply List.mem_flatMap.mpr
  refine ⟨thread,present,?_⟩
  have cases : i=index thread 0 ∨ i=index thread 1 := by
    dsimp [index,thread]
    by_cases even : i.val%2=0
    · left; apply Fin.ext; change i.val=2*(i.val/2)+0; omega
    · right; apply Fin.ext; change i.val=2*(i.val/2)+1; omega
  rcases cases with equal|equal
  · exact List.mem_cons.mpr (Or.inl equal)
  · exact List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl equal)))

theorem dispatch :
    ¬786432<2^16 ∧ max 1 (8/4 : Nat)=2 ∧ (786432+2-1)/2=threadCount ∧ 786432<2^32 := by decide

theorem native_index (thread : Fin threadCount) :
    2*thread.val+2≤count ∧ 2*thread.val+2<2^32 := by
  have := thread.isLt
  dsimp [count,threadCount] at *
  omega



attribute [local irreducible] CopyFloatContiguous.programs

def floatTrace (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (value : Float32) :
    CopyFloatContiguous.Trace destination (fun _ : Fin (2*threadCount) => value) :=
  CopyFloatContiguous.Trace.canonical destination _ memory allocation.destinationAligned

theorem copyFloat_frame {blocks base : Nat} {values : Fin (2*blocks) → Float32}
    (copied : CopyFloatContiguous.Trace base values)
    (separate : MemoryRegions.Disjoint base (4*(2*blocks)) other size) (offset : Nat) (bound : offset<size) :
    copied.memory (other+offset)=copied.before (other+offset) := by
  apply MemoryRegions.execute32_other copied.schedule copied.before _ separate offset bound
  intro write member
  have original := (ThreadgroupWrites.completed_schedule copied.execution copied.completed).mem_iff.mp member
  obtain ⟨thread,off,rfl⟩ := CopyFloatContiguous.member base values write original
  have bounded := (CopyFloatContiguous.index thread off).isLt
  have aligned := copied.aligned
  dsimp only [CopyFloatContiguous.entry]
  omega

theorem floatTrace_before (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (value : Float32) :
    (floatTrace allocation memory value).before=memory := rfl

attribute [local irreducible] floatTrace

theorem floatTrace_frame (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (value : Float32)
    (separate : MemoryRegions.Disjoint destination (4*count) other size) (offset : Nat) (bound : offset<size) :
    (floatTrace allocation memory value).memory (other+offset)=memory (other+offset) := by
  have frame := copyFloat_frame (floatTrace allocation memory value) separate offset bound
  rw [floatTrace_before] at frame
  exact frame

-- Raw same-type copies preserve all32bits. FloatBuffer's decoded attachment
-- alone cannot justify re-encoding arbitrary NaN payloads, so the raw source
-- representation is an explicit INITIAL attachment in this bridge.
theorem float_refines (allocation : Allocation source destination)
    (threads : List (Fin threadCount)) (completed : threads.Perm (List.finRange threadCount))
    (memory : ByteMemory.Bytes) (value : Float32)
    (raw : ByteMemory.load32 memory source=FloatMemory.bits value) :
    run source destination (indices threads) memory=(floatTrace allocation memory value).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+4*count
  · let i : Fin count := ⟨(address-destination)/4,by omega⟩
    let offset := (address-destination)%4
    have bound : offset<4 := by dsimp [offset]; omega
    have atAddress : destination+4*i.val+offset=address := by dsimp [i,offset]; omega
    have left := congrArg (fun word => ByteMemory.byte word offset)
      (completed_read allocation (indices threads) (indices_covered threads completed) memory i)
    have right := congrArg (fun word => ByteMemory.byte word offset) ((floatTrace allocation memory value).raw_read i)
    rw [ByteMemory.byte_load32 _ _ _ bound,raw] at left
    rw [ByteMemory.byte_load32 _ _ _ bound] at right
    rw [←atAddress]
    exact left.trans right.symm
  · have separate : MemoryRegions.Disjoint destination (4*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    simpa only [Nat.add_zero] using
      (frame allocation (indices threads) memory separate 0 (by decide)).trans
        (floatTrace_frame allocation memory value separate 0 (by decide)).symm

theorem run_append (source destination : Nat) (first second : List (Fin count)) (memory : ByteMemory.Bytes) :
    run source destination (first++second) memory=run source destination second (run source destination first memory) := by
  induction first generalizing memory with
  | nil => rfl
  | cons head rest ih => exact ih _

-- Scalar/vector dispatch uses a runtime pipeline limit, not a fixed1024.
def groupWidth (maxThreads : Nat) : Nat := min maxThreads threadCount

theorem groupWidth_bounds (maxThreads : Nat) (positive : 0<maxThreads) :
    0<groupWidth maxThreads ∧ groupWidth maxThreads≤maxThreads ∧ groupWidth maxThreads≤threadCount := by
  unfold groupWidth
  have : 0<threadCount := by decide
  omega

theorem footprint : 4*count=3145728 := rfl

end Inference.Kernels.Copy.ScalarCopyFloatSemantics
