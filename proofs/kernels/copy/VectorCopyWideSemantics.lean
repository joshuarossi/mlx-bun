import contracts.mlx.ArrayFrame
import contracts.mlx.CopyContiguous

set_option maxRecDepth 100000

namespace Inference.Kernels.Copy.VectorCopyWideSemantics
open Contracts.Mlx
attribute [local irreducible] HalfArrayWrites.programs List.finRange

-- Selected BF16 copy_v, N=4, 65536 native threads, 262144 indexed cells.
-- Allocated-copy source/destination regions are disjoint. The separate donated
-- route retains the original heap and buffer without issuing these stores.
variable {blocks : Nat}
local notation "count" => (4*blocks)
local notation "threadCount" => blocks

def event (source destination : Nat) (memory : HalfMemory.Bytes) (thread : Fin count) : HalfMemory.Store :=
  ⟨destination/2+thread.val, HalfMemory.load memory (source+2*thread.val)⟩

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
  sourceBounded : source+2*count≤2^64
  destinationAligned : destination%2=0
  destinationBounded : destination+2*count≤2^64
  fresh : MemoryRegions.Disjoint destination (2*count) source (2*count)

theorem event_inside (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) (thread : Fin count) :
    MemoryRegions.Inside16 destination (2*count) [event source destination memory thread] := by
  intro write member
  have eq := List.mem_singleton.mp member
  subst write
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [event]
  omega

theorem event_preserves_source (allocation : Allocation (blocks:=blocks) source destination)
    (memory : HalfMemory.Bytes) (thread readIndex : Fin count) :
    HalfMemory.load (HalfMemory.execute [event source destination memory thread] memory) (source+2*readIndex.val)=
      HalfMemory.load memory (source+2*readIndex.val) := by
  have same := MemoryRegions.execute16_other _ memory (event_inside allocation memory thread) allocation.fresh
  exact ArrayFrame.half_congr memory _ source (2*count) (2*readIndex.val) same (by have := readIndex.isLt; omega)

theorem stores_eq (allocation : Allocation (blocks:=blocks) source destination)
    (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    stores source destination threads memory=
      threads.map (HalfArrayWrites.entry destination (fun i => HalfMemory.load memory (source+2*i.val))) := by
  induction threads generalizing memory with
  | nil => rfl
  | cons thread rest ih =>
    simp only [stores, List.map_cons]
    congr 1
    rw [ih]
    apply List.map_congr_left
    intro i _
    have read := event_preserves_source allocation memory thread i
    exact congrArg (fun value => (⟨destination/2+i.val,value⟩ : HalfMemory.Store)) read

theorem stores_inside (allocation : Allocation (blocks:=blocks) source destination)
    (threads : List (Fin count)) (memory : HalfMemory.Bytes) :
    MemoryRegions.Inside16 destination (2*count) (stores source destination threads memory) := by
  rw [stores_eq allocation]
  intro write member
  obtain ⟨thread, _, rfl⟩ := List.mem_map.mp member
  have := allocation.destinationAligned
  have := thread.isLt
  dsimp only [HalfArrayWrites.entry]
  omega

theorem frame (allocation : Allocation (blocks:=blocks) source destination) (threads : List (Fin count))
    (memory : HalfMemory.Bytes) (separate : MemoryRegions.Disjoint destination (2*count) other size)
    (offset : Nat) (bound : offset<size) :
    run source destination threads memory (other+offset)=memory (other+offset) := by
  rw [run_stores]
  exact MemoryRegions.execute16_other _ memory (stores_inside allocation threads memory) separate offset bound

theorem source_retained (allocation : Allocation (blocks:=blocks) source destination) (threads : List (Fin count))
    (memory : HalfMemory.Bytes) (i : Fin count) :
    HalfMemory.load (run source destination threads memory) (source+2*i.val)=HalfMemory.load memory (source+2*i.val) :=
  ArrayFrame.half_congr memory _ source (2*count) (2*i.val)
    (frame allocation threads memory allocation.fresh) (by have := i.isLt; omega)

theorem no_interthread_overlap (_allocation : Allocation (blocks:=blocks) source destination)
    (first second : Fin count) (different : first≠second) :
    MemoryRegions.Disjoint (destination+2*first.val) 2 (destination+2*second.val) 2 := by
  have differentValues : first.val≠second.val := fun equal => different (Fin.ext equal)
  unfold MemoryRegions.Disjoint
  omega

def trace (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    HalfArrayWrites.Trace destination (fun i : Fin count => HalfMemory.load memory (source+2*i.val)) where
  before := memory
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  schedule := (HalfArrayWrites.programs destination (fun i : Fin count => HalfMemory.load memory (source+2*i.val))).flatten
  remaining := List.replicate count []
  execution := by
    simpa only [HalfArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical (HalfArrayWrites.programs destination (fun i : Fin count => HalfMemory.load memory (source+2*i.val)))
  completed := by
    simpa only [HalfArrayWrites.programs, List.length_map, List.length_finRange] using
      ThreadgroupWrites.canonical_barrier (HalfArrayWrites.programs destination (fun i : Fin count => HalfMemory.load memory (source+2*i.val)))

private theorem singleton_flatten {α β : Type} (f : α → β) (xs : List α) :
    (xs.map (fun x => [f x])).flatten=xs.map f := by
  induction xs with
  | nil => rfl
  | cons head rest ih => simp only [List.map_cons, List.flatten_cons, List.singleton_append, ih]

theorem trace_memory (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    (trace allocation memory).memory=HalfMemory.execute (HalfArrayWrites.programs destination (fun i : Fin count => HalfMemory.load memory (source+2*i.val))).flatten memory := rfl

theorem canonical_refines (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    run source destination (List.finRange count) memory=(trace allocation memory).memory := by
  rw [run_stores, stores_eq allocation]
  rw [trace_memory, HalfArrayWrites.programs, singleton_flatten]

theorem canonical_read (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination (List.finRange count) memory) (destination+2*thread.val)=
      HalfMemory.load memory (source+2*thread.val) := by
  rw [canonical_refines allocation memory]
  exact (trace allocation memory).read_correct thread

theorem event_address (allocation : Allocation (blocks:=blocks) source destination)
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    2*(event source destination memory thread).word=destination+2*thread.val ∧
      destination+2*thread.val+2≤2^64 := by
  have := allocation.destinationAligned
  have := allocation.destinationBounded
  have := thread.isLt
  dsimp only [event]
  omega

theorem signed_local (i : Nat) (reached : i≤4) :
    i<2^31 ∧ i+1<2^31 ∧ (BitVec.ofNat 32 i).toNat=i := by
  refine ⟨by omega, by omega, ?_⟩
  rw [BitVec.toNat_ofNat]
  exact Nat.mod_eq_of_lt (by omega)

-- Completion is supplied by actual coverage of dispatched thread IDs, not by
-- a final-value premise. Any permutation (and even repeated covered threads)
-- has the same readback because every dynamic indexed load sees the retained input cell.
theorem completed_read (allocation : Allocation (blocks:=blocks) source destination)
    (threads : List (Fin count)) (covered : ∀ thread, thread∈threads)
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination threads memory) (destination+2*thread.val)=
      HalfMemory.load memory (source+2*thread.val) := by
  rw [run_stores, stores_eq allocation, HalfMemory.execute_load _ _ _ (by
    have := allocation.destinationAligned; omega)]
  apply MemoryCells.written_value
  · intro write member same
    obtain ⟨j, _, rfl⟩ := List.mem_map.mp member
    have equal : j=thread := Fin.ext (by dsimp [HalfArrayWrites.entry] at same; omega)
    subst j
    rfl
  · exact ⟨HalfArrayWrites.entry destination (fun i => HalfMemory.load memory (source+2*i.val)) thread,
      List.mem_map.mpr ⟨thread, covered thread, rfl⟩, by
        have := allocation.destinationAligned
        dsimp only [HalfArrayWrites.entry]
        omega⟩

theorem permutation_read (allocation : Allocation (blocks:=blocks) source destination)
    (threads : List (Fin count)) (completed : threads.Perm (List.finRange count))
    (memory : HalfMemory.Bytes) (thread : Fin count) :
    HalfMemory.load (run source destination threads memory) (destination+2*thread.val)=
      HalfMemory.load memory (source+2*thread.val) :=
  completed_read allocation threads (fun i => completed.mem_iff.mpr (List.mem_finRange i)) memory thread



def index (thread : Fin threadCount) (offset : Fin 4) : Fin count :=
  ⟨4*thread.val+offset.val,by have := thread.isLt; have := offset.isLt; omega⟩

theorem index_unique (a b : Fin threadCount) (i j : Fin 4) (same : index a i=index b j) : a=b ∧ i=j := by
  have equal := congrArg Fin.val same
  have := i.isLt
  have := j.isLt
  dsimp only [index] at equal
  constructor <;> apply Fin.ext <;> omega

theorem native_no_overlap (allocation : Allocation (blocks:=blocks) source destination)
    (first second : Fin threadCount) (i j : Fin 4) (different : first≠second) :
    MemoryRegions.Disjoint (destination+2*(index first i).val) 2 (destination+2*(index second j).val) 2 :=
  no_interthread_overlap allocation _ _ (fun same => different (index_unique first second i j same).1)

def indices (threads : List (Fin threadCount)) : List (Fin count) :=
  threads.flatMap (fun thread => (List.finRange 4).map (index thread))

theorem indices_covered (threads : List (Fin threadCount)) (completed : threads.Perm (List.finRange threadCount))
    (i : Fin count) : i∈indices threads := by
  let thread : Fin threadCount := ⟨i.val/4,by have := i.isLt; omega⟩
  let offset : Fin 4 := ⟨i.val%4,by omega⟩
  have present := completed.mem_iff.mpr (List.mem_finRange thread)
  apply List.mem_flatMap.mpr
  refine ⟨thread,present,List.mem_map.mpr ⟨offset,List.mem_finRange offset,?_⟩⟩
  apply Fin.ext
  dsimp [index,CopyContiguous.index,thread,offset]
  omega

theorem source_address (allocation : Allocation (blocks:=blocks) source destination) (i : Fin count) :
    (source+2*i.val)%2=0 ∧ source+2*i.val+2≤2^64 := by
  have := allocation.sourceAligned
  have := allocation.sourceBounded
  have := i.isLt
  omega

private theorem copy_inside {blocks base : Nat} {values : Fin (4*blocks) → BitVec 16}
    (copied : CopyContiguous.Trace base values) : MemoryRegions.Inside16 base (2*(4*blocks)) copied.schedule := by
  intro write member
  have original := (ThreadgroupWrites.completed_schedule copied.execution copied.completed).mem_iff.mp member
  obtain ⟨thread,off,rfl⟩ := CopyContiguous.member base values write original
  have bounded := (CopyContiguous.index thread off).isLt
  have aligned := copied.aligned
  dsimp only [CopyContiguous.entry]
  omega

theorem copy_frame {blocks base : Nat} {values : Fin (4*blocks) → BitVec 16}
    (copied : CopyContiguous.Trace base values)
    (separate : MemoryRegions.Disjoint base (2*(4*blocks)) other size) (offset : Nat) (bound : offset<size) :
    copied.memory (other+offset)=copied.before (other+offset) :=
  MemoryRegions.execute16_other _ _ (copy_inside copied) separate offset bound

attribute [local irreducible] CopyContiguous.programs

def copyTrace (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    CopyContiguous.Trace destination (CopyContiguous.vectorValues (blocks:=threadCount) memory source) :=
  CopyContiguous.Trace.canonical destination _ memory allocation.destinationAligned

theorem copyTrace_before (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    (copyTrace allocation memory).before=memory := rfl
attribute [local irreducible] copyTrace

theorem copyTrace_frame (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes)
    (separate : MemoryRegions.Disjoint destination (2*count) other size) (offset : Nat) (bound : offset<size) :
    (copyTrace allocation memory).memory (other+offset)=memory (other+offset) := by
  have same := copy_frame (copyTrace allocation memory) separate offset bound
  rw [copyTrace_before] at same
  exact same

theorem copy_refines (allocation : Allocation (blocks:=blocks) source destination)
    (cells : List (Fin count)) (covered : ∀ i, i∈cells) (memory : HalfMemory.Bytes) :
    run source destination cells memory=(copyTrace allocation memory).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let i : Fin count := ⟨(address-destination)/2,by omega⟩
    let off := (address-destination)%2
    have bound : off<2 := by dsimp [off]; omega
    have atAddress : destination+2*i.val+off=address := by dsimp [i,off]; omega
    have actual := congrArg (fun word => HalfMemory.byte word off) (completed_read allocation cells covered memory i)
    have modeled := congrArg (fun word => HalfMemory.byte word off) ((copyTrace allocation memory).read_correct i)
    rw [HalfMemory.byte_load _ _ _ bound] at actual modeled
    rw [←atAddress]
    exact actual.trans modeled.symm
  · have separate : MemoryRegions.Disjoint destination (2*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    simpa only [Nat.add_zero] using (frame allocation cells memory separate 0 (by omega)).trans
      (copyTrace_frame allocation memory separate 0 (by omega)).symm

theorem threads_refine (allocation : Allocation (blocks:=blocks) source destination) (threads : List (Fin threadCount))
    (completed : threads.Perm (List.finRange threadCount)) (memory : HalfMemory.Bytes) :
    run source destination (indices threads) memory=(copyTrace allocation memory).memory :=
  copy_refines allocation _ (indices_covered threads completed) memory

-- Any legal completed old preservation trace, not only the chosen canonical
-- schedule, denotes the same allocated-copy heap on this exact initial heap.
theorem copyTrace_eq (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes)
    (copied : CopyContiguous.Trace destination (CopyContiguous.vectorValues (blocks:=threadCount) memory source))
    (initial : copied.before=memory) : (copyTrace allocation memory).memory=copied.memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let i : Fin count := ⟨(address-destination)/2,by omega⟩
    let off := (address-destination)%2
    have bound : off<2 := by dsimp [off]; omega
    have atAddress : destination+2*i.val+off=address := by dsimp [i,off]; omega
    have actual := congrArg (fun word => HalfMemory.byte word off) ((copyTrace allocation memory).read_correct i)
    have modeled := congrArg (fun word => HalfMemory.byte word off) (copied.read_correct i)
    rw [HalfMemory.byte_load _ _ _ bound] at actual modeled
    rw [←atAddress]
    exact actual.trans modeled.symm
  · have separate : MemoryRegions.Disjoint destination (2*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have actual := copyTrace_frame allocation memory separate 0 (by omega)
    have modeled := copy_frame copied separate 0 (by omega)
    rw [initial] at modeled
    simpa only [Nat.add_zero] using actual.trans modeled.symm

def outputBuffer {values : Fin count → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values)
    (allocation : Allocation (blocks:=blocks) source.base destination) : ArrayStorage.BFBuffer values where
  bytes := (copyTrace allocation source.bytes).memory
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := fun i => ((copyTrace allocation source.bytes).read_correct i).trans (source.attached i)

-- Donation is an explicit identity route, not an overlapping allocated copy.
-- Native donation eligibility/branch selection belongs to the host boundary.
def donated {values : Fin count → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values) : ArrayStorage.BFBuffer values := source

theorem donated_bytes {values : Fin count → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values) :
    (donated source).bytes=source.bytes := rfl

theorem donated_base {values : Fin count → ArrayStorage.BF} (source : ArrayStorage.BFBuffer values) :
    (donated source).base=source.base := rfl

end Inference.Kernels.Copy.VectorCopyWideSemantics
