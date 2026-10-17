import kernels.copy.ScalarCopyFloatSemantics

namespace Inference.Kernels.Copy.ScalarCopyFloatInterleaving
open Contracts.Mlx ScalarCopyFloatSemantics
set_option maxRecDepth 10000
attribute [local irreducible] ScalarCopyFloatSemantics.trace ScalarCopyFloatSemantics.floatTrace ScalarCopyFloatSemantics.run List.finRange

-- Selected FP32 -> FP32, N=2, exactly393216 invocations. Each load and
-- each32-bit store is one model action. Native binding, compiler lowering,
-- atomic/coherent32-bit word accesses, dispatch completion and visibility remain
-- hardware/runtime boundaries; no general Metal concurrency model is claimed.
inductive Phase where
  | unread
  | loaded : BitVec 32 → Phase
  | done
  deriving DecidableEq

structure Machine where
  phase : Fin count → Phase
  memory : ByteMemory.Bytes

def update (state : Machine) (thread : Fin count) (phase : Phase) : Fin count → Phase :=
  fun other => if other=thread then phase else state.phase other

inductive Event where
  | load : Fin threadCount → Fin 2 → Event
  | store : Fin threadCount → Fin 2 → Event
  deriving DecidableEq

-- The second loop iteration cannot load before the first store completes.
-- Registers are indexed by logical output cells, without claiming a physical
-- register allocation. Readiness enforces each native thread's N=2 ordering.
inductive Step (source destination : Nat) : Machine → Event → Machine → Prop where
  | load (ready : before.phase (index thread off)=.unread)
      (ordered : off.val=0 ∨ before.phase (index thread 0)=.done) :
      Step source destination before (.load thread off)
        ⟨update before (index thread off) (.loaded (ByteMemory.load32 before.memory source)),before.memory⟩
  | store (ready : before.phase (index thread off)=.loaded value) :
      Step source destination before (.store thread off)
        ⟨update before (index thread off) .done,
          ByteMemory.store32 before.memory (destination+4*(index thread off).val) value⟩

inductive Executes (source destination : Nat) : Machine → List Event → Machine → Prop where
  | nil (state) : Executes source destination state [] state
  | cons : Step source destination before action middle →
      Executes source destination middle events after → Executes source destination before (action::events) after

def initial (memory : ByteMemory.Bytes) : Machine := ⟨fun _ => .unread,memory⟩
def Completed (state : Machine) : Prop := ∀ thread, state.phase thread=.done

variable {source destination : Nat} {before : ByteMemory.Bytes} {state after : Machine}
  {action : Event} {events : List Event}

structure Invariant (source destination : Nat) (before : ByteMemory.Bytes) (state : Machine) : Prop where
  registers : ∀ thread value, state.phase thread=.loaded value → value=ByteMemory.load32 before source
  stored : ∀ thread, state.phase thread=.done → ∀ offset < 4,
    state.memory (destination+4*thread.val+offset)=ByteMemory.byte (ByteMemory.load32 before source) offset
  frame : ∀ base size, MemoryRegions.Disjoint destination (4*count) base size → ∀ offset < size,
    state.memory (base+offset)=before (base+offset)

theorem initial_invariant (source destination : Nat) (memory : ByteMemory.Bytes) :
    Invariant source destination memory (initial memory) where
  registers := by intro thread value impossible; cases impossible
  stored := by intro thread impossible; cases impossible
  frame := by intros; rfl

theorem store_byte (memory : ByteMemory.Bytes) (base : Nat) (value : BitVec 32) (offset : Nat) (bound : offset<4) :
    ByteMemory.store32 memory base value (base+offset)=ByteMemory.byte value offset := by
  simp only [ByteMemory.store32,ite_eq_left (show base≤base+offset ∧ base+offset<base+4 by omega),Nat.add_sub_cancel_left]

theorem store_other (memory : ByteMemory.Bytes) (written : Nat) (value : BitVec 32) {base size : Nat}
    (separate : MemoryRegions.Disjoint written 4 base size) (offset : Nat) (bound : offset<size) :
    ByteMemory.store32 memory written value (base+offset)=memory (base+offset) := by
  have outside : ¬(written≤base+offset ∧ base+offset<written+4) := by
    rcases separate with left|right <;> omega
  exact ite_eq_right outside

theorem store_frame (_allocation : Allocation source destination) (thread : Fin count)
    (memory : ByteMemory.Bytes) (value : BitVec 32) {base size : Nat}
    (separate : MemoryRegions.Disjoint destination (4*count) base size) (offset : Nat) (bound : offset<size) :
    ByteMemory.store32 memory (destination+4*thread.val) value (base+offset)=memory (base+offset) := by
  apply store_other memory _ value _ offset bound
  have := thread.isLt
  rcases separate with left|right
  · exact Or.inl (by omega)
  · exact Or.inr (by omega)

theorem Invariant.source_read (allocation : Allocation source destination)
    (invariant : Invariant source destination before state) : ByteMemory.load32 state.memory source=ByteMemory.load32 before source := by
  exact ArrayFrame.word_congr before state.memory source 4 0
    (fun offset bound => invariant.frame source 4 allocation.fresh offset bound) (by decide)

theorem step_invariant (allocation : Allocation source destination)
    (invariant : Invariant source destination before state) (step : Step source destination state action after) :
    Invariant source destination before after := by
  cases step with
  | @load nativeThread off ready ordered =>
    let thread := index nativeThread off
    refine ⟨?_,?_,invariant.frame⟩
    · intro other value loaded
      by_cases same : other=thread
      · subst other
        have equal : ByteMemory.load32 state.memory source=value := Phase.loaded.inj (by simpa only [thread,update,ite_true] using loaded)
        exact equal.symm.trans (invariant.source_read allocation)
      · exact invariant.registers other value (by simpa only [thread,update,ite_eq_right same] using loaded)
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        simp only [thread,update,ite_true] at done
        cases done
      · exact invariant.stored other (by simpa only [thread,update,ite_eq_right same] using done) offset bound
  | @store nativeThread off value ready =>
    let thread := index nativeThread off
    have value_eq := invariant.registers thread value ready
    refine ⟨?_,?_,?_⟩
    · intro other loadedValue loaded
      by_cases same : other=thread
      · subst other
        simp only [thread,update,ite_true] at loaded
        cases loaded
      · exact invariant.registers other loadedValue (by simpa only [thread,update,ite_eq_right same] using loaded)
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        exact (store_byte state.memory _ value offset bound).trans (congrArg (fun v => ByteMemory.byte v offset) value_eq)
      · exact (store_other state.memory _ value
          (no_output_overlap allocation thread other (Ne.symm same)) offset bound).trans
          (invariant.stored other (by simpa only [thread,update,ite_eq_right same] using done) offset bound)
    · intro base size separate offset bound
      exact (store_frame allocation thread state.memory value separate offset bound).trans
        (invariant.frame base size separate offset bound)

theorem executes_invariant (allocation : Allocation source destination)
    (execution : Executes source destination state events after)
    (invariant : Invariant source destination before state) : Invariant source destination before after := by
  induction execution with
  | nil => exact invariant
  | cons step rest ih => exact ih (step_invariant allocation invariant step)

variable (allocation : Allocation source destination)
  (execution : Executes source destination (initial before) events after) (completed : Completed after)

include allocation execution completed in
theorem completed_byte (thread : Fin count) (offset : Nat) (bound : offset<4) :
    after.memory (destination+4*thread.val+offset)=ByteMemory.byte (ByteMemory.load32 before source) offset :=
  (executes_invariant allocation execution (initial_invariant source destination before)).stored thread (completed thread) offset bound

include allocation execution completed in
theorem completed_read (thread : Fin count) :
    ByteMemory.load32 after.memory (destination+4*thread.val)=ByteMemory.load32 before source := by
  unfold ByteMemory.load32
  rw [completed_byte allocation execution completed thread 0 (by decide),completed_byte allocation execution completed thread 1 (by decide),
    completed_byte allocation execution completed thread 2 (by decide),completed_byte allocation execution completed thread 3 (by decide)]
  exact ByteMemory.join_bytes _

include allocation execution in
theorem frame {base size : Nat} (separate : MemoryRegions.Disjoint destination (4*count) base size) (offset : Nat) (bound : offset<size) :
    after.memory (base+offset)=before (base+offset) :=
  (executes_invariant allocation execution (initial_invariant source destination before)).frame base size separate offset bound

-- Universal over every valid completed separate-action interleaving, including
-- schedules that load many registers before any stores occur.
include execution completed in
theorem refines : after.memory=(ScalarCopyFloatSemantics.trace allocation before).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+4*count
  · let thread : Fin count := ⟨(address-destination)/4,by omega⟩
    let offset := (address-destination)%4
    have bound : offset<4 := by dsimp [offset]; omega
    have atAddress : destination+4*thread.val+offset=address := by dsimp [thread,offset]; omega
    have first := completed_byte allocation execution completed thread offset bound
    have second := congrArg (fun word => ByteMemory.byte word offset)
      ((ScalarCopyFloatSemantics.trace allocation before).read_correct thread)
    rw [ByteMemory.byte_load32 _ _ _ bound] at second
    rw [← atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (4*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have first := frame allocation execution outside 0 (by decide)
    have second := ScalarCopyFloatSemantics.frame allocation (List.finRange count) before outside 0 (by decide)
    rw [ScalarCopyFloatSemantics.canonical_refines allocation before] at second
    simpa only [Nat.add_zero] using first.trans second.symm





include execution completed in
theorem float_refines (value : Float32) (raw : ByteMemory.load32 before source=FloatMemory.bits value) :
    after.memory=(floatTrace allocation before value).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+4*count
  · let i : Fin count := ⟨(address-destination)/4,by omega⟩
    let offset := (address-destination)%4
    have bound : offset<4 := by dsimp [offset]; omega
    have atAddress : destination+4*i.val+offset=address := by dsimp [i,offset]; omega
    have left := completed_byte allocation execution completed i offset bound
    have right := congrArg (fun word => ByteMemory.byte word offset) ((floatTrace allocation before value).raw_read i)
    rw [ByteMemory.byte_load32 _ _ _ bound] at right
    rw [raw] at left
    rw [←atAddress]
    exact left.trans right.symm
  · have separate : MemoryRegions.Disjoint destination (4*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    simpa only [Nat.add_zero] using
      (frame allocation execution separate 0 (by decide)).trans
        (floatTrace_frame allocation before value separate 0 (by decide)).symm

-- The protocol is realizable without any final-value hypothesis.
theorem Executes.append {first second : List Event}
    (left : Executes source destination start first middle)
    (right : Executes source destination middle second finish) :
    Executes source destination start (first++second) finish := by
  induction left with
  | nil => exact right
  | cons step tail ih => exact .cons step (ih right)

theorem index_unique (a b : Fin threadCount) (i j : Fin 2) (same : index a i=index b j) : a=b ∧ i=j := by
  have sameValues := congrArg Fin.val same
  have := i.isLt
  have := j.isLt
  dsimp only [index] at sameValues
  constructor <;> apply Fin.ext <;> omega

def finishOutput (source destination : Nat) (state : Machine) (thread : Fin threadCount) (off : Fin 2) : Machine :=
  let loaded : Machine := ⟨update state (index thread off) (.loaded (ByteMemory.load32 state.memory source)),state.memory⟩
  ⟨update loaded (index thread off) .done,
    ByteMemory.store32 state.memory (destination+4*(index thread off).val) (ByteMemory.load32 state.memory source)⟩

def pairEvents (thread : Fin threadCount) (off : Fin 2) : List Event := [.load thread off,.store thread off]

theorem finishOutput_phase (thread : Fin threadCount) (off : Fin 2) (other : Fin count) (state : Machine) :
    (finishOutput source destination state thread off).phase other=
      if other=index thread off then .done else state.phase other := by
  by_cases same : other=index thread off <;> simp [finishOutput,update,same]

theorem finishOutput_exec (thread : Fin threadCount) (off : Fin 2) (state : Machine)
    (ready : state.phase (index thread off)=.unread)
    (ordered : off.val=0 ∨ state.phase (index thread 0)=.done) :
    Executes source destination state (pairEvents thread off) (finishOutput source destination state thread off) :=
  .cons (.load ready ordered) (.cons (.store (by simp [update])) (.nil _))

def finishThread (source destination : Nat) (state : Machine) (thread : Fin threadCount) : Machine :=
  finishOutput source destination (finishOutput source destination state thread 0) thread 1

def threadEvents (thread : Fin threadCount) : List Event := pairEvents thread 0++pairEvents thread 1

theorem finishThread_phase (thread : Fin threadCount) (other : Fin count) (state : Machine) :
    (finishThread source destination state thread).phase other=
      if other=index thread 0 ∨ other=index thread 1 then .done else state.phase other := by
  simp only [finishThread,finishOutput_phase]
  by_cases first : other=index thread 0 <;> by_cases second : other=index thread 1 <;> simp [first,second]

theorem finishThread_exec (thread : Fin threadCount) (state : Machine)
    (ready : ∀ off, state.phase (index thread off)=.unread) :
    Executes source destination state (threadEvents thread) (finishThread source destination state thread) := by
  have different : index thread 1≠index thread 0 := by
    intro same
    have impossible := (index_unique thread thread 1 0 same).2
    cases impossible
  exact (finishOutput_exec thread 0 state (ready 0) (Or.inl rfl)).append
    (finishOutput_exec thread 1 _
      (by rw [finishOutput_phase,ite_eq_right different]; exact ready 1)
      (Or.inr (by rw [finishOutput_phase,ite_eq_left rfl])))

def drain (source destination : Nat) : List (Fin threadCount) → Machine → Machine
  | [], state => state
  | thread::rest, state => drain source destination rest (finishThread source destination state thread)

theorem drain_phase (threads : List (Fin threadCount)) (state : Machine) (word : Fin count) :
    (drain source destination threads state).phase word=
      if word∈indices threads then .done else state.phase word := by
  induction threads generalizing state with
  | nil => simp [drain,indices]
  | cons thread rest ih =>
    rw [drain,ih,finishThread_phase]
    have union : word∈indices (thread::rest) ↔ word=index thread 0 ∨ word=index thread 1 ∨ word∈indices rest := by
      simp [indices]
    simp only [union]
    by_cases present : word∈indices rest <;> by_cases first : word=index thread 0 <;>
      by_cases second : word=index thread 1 <;> simp [present,first,second]

theorem drain_exec (threads : List (Fin threadCount)) (state : Machine) (unique : threads.Nodup)
    (ready : ∀ thread∈threads, ∀ off, state.phase (index thread off)=.unread) :
    Executes source destination state (threads.flatMap threadEvents) (drain source destination threads state) := by
  induction threads generalizing state with
  | nil => exact .nil _
  | cons first rest ih =>
    have notIn := (List.nodup_cons.mp unique).1
    have tailUnique := (List.nodup_cons.mp unique).2
    exact (finishThread_exec first state (ready first List.mem_cons_self)).append
      (ih _ tailUnique (fun thread present off => by
        rw [finishThread_phase]
        have different : thread≠first := by intro equal; subst thread; exact notIn present
        have firstDifferent : index thread off≠index first 0 := fun same => different (index_unique _ _ _ _ same).1
        have secondDifferent : index thread off≠index first 1 := fun same => different (index_unique _ _ _ _ same).1
        rw [ite_eq_right (by simp only [firstDifferent,secondDifferent,or_self,not_false_eq_true])]
        exact ready thread (List.mem_cons_of_mem _ present) off))

def canonicalAfter (source destination : Nat) (memory : ByteMemory.Bytes) : Machine :=
  drain source destination (List.finRange threadCount) (initial memory)

theorem canonical_execution (source destination : Nat) (memory : ByteMemory.Bytes) :
    Executes source destination (initial memory) ((List.finRange threadCount).flatMap threadEvents)
      (canonicalAfter source destination memory) :=
  drain_exec _ _ (List.nodup_finRange threadCount) (by intro thread present off; rfl)

theorem canonical_completed (source destination : Nat) (memory : ByteMemory.Bytes) :
    Completed (canonicalAfter source destination memory) := by
  intro word
  unfold canonicalAfter
  rw [drain_phase]
  exact ite_eq_left (indices_covered _ (List.Perm.refl _) word)

section Attached
variable {value : Float32} (sourceBuffer : ArrayStorage.FloatBuffer (fun _ : Fin 1 => value))
  (allocation : Allocation sourceBuffer.base destination)
  (raw : ByteMemory.load32 sourceBuffer.bytes sourceBuffer.base=FloatMemory.bits value)
  (execution : Executes sourceBuffer.base destination (initial sourceBuffer.bytes) events after)
  (completed : Completed after)

def outputBuffer : ArrayStorage.FloatBuffer (fun _ : Fin count => value) where
  bytes := after.memory
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := by
    intro word
    unfold FloatMemory.load
    rw [completed_read allocation execution completed word,raw,FloatMemory.decode_bits]

def sourceAfter : ArrayStorage.FloatBuffer (fun _ : Fin 1 => value) :=
  ArrayFrame.fp sourceBuffer after.memory (frame allocation execution allocation.fresh)

theorem source_output_shared : (sourceAfter sourceBuffer allocation execution).bytes=
    (outputBuffer sourceBuffer allocation raw execution completed).bytes := rfl

end Attached
end Inference.Kernels.Copy.ScalarCopyFloatInterleaving
