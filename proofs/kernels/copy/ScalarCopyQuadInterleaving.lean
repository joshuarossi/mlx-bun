import kernels.copy.ScalarCopyQuadSemantics

namespace Inference.Kernels.Copy.ScalarCopyQuadInterleaving
open Contracts.Mlx ScalarCopyQuadSemantics
set_option maxRecDepth 10000
attribute [local irreducible] ScalarCopyQuadSemantics.trace ScalarCopyQuadSemantics.copyTrace ScalarCopyQuadSemantics.run List.finRange

-- Selected BF16 -> BF16, N=4, exactly 65536 invocations. Each load and
-- each 16-bit store is one model action. Native binding, compiler lowering,
-- atomic/coherent word accesses, dispatch completion and visibility remain
-- hardware/runtime boundaries; no general Metal concurrency model is claimed.
inductive Phase where
  | unread
  | loaded : BitVec 16 → Phase
  | done
  deriving DecidableEq

structure Machine where
  phase : Fin count → Phase
  memory : HalfMemory.Bytes

def update (state : Machine) (thread : Fin count) (phase : Phase) : Fin count → Phase :=
  fun other => if other=thread then phase else state.phase other

inductive Event where
  | load : Fin count → Event
  | store : Fin count → Event
  deriving DecidableEq

inductive Step (source destination : Nat) : Machine → Event → Machine → Prop where
  | load (ready : before.phase thread=.unread)
      (ordered : ∀ previous : Fin count, previous.val/4=thread.val/4 → previous.val<thread.val → before.phase previous=.done) :
      Step source destination before (.load thread)
        ⟨update before thread (.loaded (HalfMemory.load before.memory source)),before.memory⟩
  | store (ready : before.phase thread=.loaded value) :
      Step source destination before (.store thread)
        ⟨update before thread .done,HalfMemory.store before.memory (destination+2*thread.val) value⟩

inductive Executes (source destination : Nat) : Machine → List Event → Machine → Prop where
  | nil (state) : Executes source destination state [] state
  | cons : Step source destination before action middle →
      Executes source destination middle events after → Executes source destination before (action::events) after

def initial (memory : HalfMemory.Bytes) : Machine := ⟨fun _ => .unread,memory⟩
def Completed (state : Machine) : Prop := ∀ thread, state.phase thread=.done

variable {source destination : Nat} {before : HalfMemory.Bytes} {state after : Machine}
  {action : Event} {events : List Event}

structure Invariant (source destination : Nat) (before : HalfMemory.Bytes) (state : Machine) : Prop where
  registers : ∀ thread value, state.phase thread=.loaded value → value=HalfMemory.load before source
  stored : ∀ thread, state.phase thread=.done → ∀ offset < 2,
    state.memory (destination+2*thread.val+offset)=HalfMemory.byte (HalfMemory.load before source) offset
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset < size,
    state.memory (base+offset)=before (base+offset)

theorem initial_invariant (source destination : Nat) (memory : HalfMemory.Bytes) :
    Invariant source destination memory (initial memory) where
  registers := by intro thread value impossible; cases impossible
  stored := by intro thread impossible; cases impossible
  frame := by intros; rfl

theorem store_byte (memory : HalfMemory.Bytes) (base : Nat) (value : BitVec 16) (offset : Nat) (bound : offset<2) :
    HalfMemory.store memory base value (base+offset)=HalfMemory.byte value offset := by
  simp only [HalfMemory.store,ite_eq_left (show base≤base+offset ∧ base+offset<base+2 by omega),Nat.add_sub_cancel_left]

theorem store_other (memory : HalfMemory.Bytes) (written : Nat) (value : BitVec 16) {base size : Nat}
    (separate : MemoryRegions.Disjoint written 2 base size) (offset : Nat) (bound : offset<size) :
    HalfMemory.store memory written value (base+offset)=memory (base+offset) := by
  have outside : ¬(written≤base+offset ∧ base+offset<written+2) := by
    rcases separate with left|right <;> omega
  exact ite_eq_right outside

theorem store_frame (_allocation : Allocation source destination) (thread : Fin count)
    (memory : HalfMemory.Bytes) (value : BitVec 16) {base size : Nat}
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    HalfMemory.store memory (destination+2*thread.val) value (base+offset)=memory (base+offset) := by
  apply store_other memory _ value _ offset bound
  have := thread.isLt
  rcases separate with left|right
  · exact Or.inl (by omega)
  · exact Or.inr (by omega)

theorem Invariant.source_read (allocation : Allocation source destination)
    (invariant : Invariant source destination before state) : HalfMemory.load state.memory source=HalfMemory.load before source := by
  exact ArrayFrame.half_congr before state.memory source 2 0
    (fun offset bound => invariant.frame source 2 allocation.fresh offset bound) (by decide)

theorem step_invariant (allocation : Allocation source destination)
    (invariant : Invariant source destination before state) (step : Step source destination state action after) :
    Invariant source destination before after := by
  cases step with
  | @load thread ready ordered =>
    refine ⟨?_,?_,invariant.frame⟩
    · intro other value loaded
      by_cases same : other=thread
      · subst other
        have equal : HalfMemory.load state.memory source=value := Phase.loaded.inj (by simpa only [update,ite_true] using loaded)
        exact equal.symm.trans (invariant.source_read allocation)
      · exact invariant.registers other value (by simpa only [update,ite_eq_right same] using loaded)
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        simp only [update,ite_true] at done
        cases done
      · exact invariant.stored other (by simpa only [update,ite_eq_right same] using done) offset bound
  | @store thread value ready =>
    have value_eq := invariant.registers thread value ready
    refine ⟨?_,?_,?_⟩
    · intro other loadedValue loaded
      by_cases same : other=thread
      · subst other
        simp only [update,ite_true] at loaded
        cases loaded
      · exact invariant.registers other loadedValue (by simpa only [update,ite_eq_right same] using loaded)
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        exact (store_byte state.memory _ value offset bound).trans (congrArg (fun v => HalfMemory.byte v offset) value_eq)
      · exact (store_other state.memory _ value
          (no_interthread_overlap allocation thread other (Ne.symm same)) offset bound).trans
          (invariant.stored other (by simpa only [update,ite_eq_right same] using done) offset bound)
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
theorem completed_byte (thread : Fin count) (offset : Nat) (bound : offset<2) :
    after.memory (destination+2*thread.val+offset)=HalfMemory.byte (HalfMemory.load before source) offset :=
  (executes_invariant allocation execution (initial_invariant source destination before)).stored thread (completed thread) offset bound

include allocation execution completed in
theorem completed_read (thread : Fin count) :
    HalfMemory.load after.memory (destination+2*thread.val)=HalfMemory.load before source := by
  unfold HalfMemory.load
  rw [completed_byte allocation execution completed thread 1 (by decide),completed_byte allocation execution completed thread 0 (by decide)]
  exact HalfMemory.join_bytes _

include allocation execution in
theorem frame {base size : Nat} (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    after.memory (base+offset)=before (base+offset) :=
  (executes_invariant allocation execution (initial_invariant source destination before)).frame base size separate offset bound

-- Universal over every valid completed separate-action interleaving, including
-- schedules that load many registers before any stores occur.
include execution completed in
theorem refines : after.memory=(ScalarCopyQuadSemantics.trace allocation before).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let thread : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset := (address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*thread.val+offset=address := by dsimp [thread,offset]; omega
    have first := completed_byte allocation execution completed thread offset bound
    have second := congrArg (fun word => HalfMemory.byte word offset)
      ((ScalarCopyQuadSemantics.trace allocation before).read_correct thread)
    rw [HalfMemory.byte_load _ _ _ bound] at second
    rw [← atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have first := frame allocation execution outside 0 (by decide)
    have second := ScalarCopyQuadSemantics.frame allocation (List.finRange count) before outside 0 (by decide)
    rw [ScalarCopyQuadSemantics.canonical_refines allocation before] at second
    simpa only [Nat.add_zero] using first.trans second.symm


-- A concrete finite completion witnesses realizability of the event protocol.
theorem Executes.append {first second : List Event}
    (left : Executes source destination start first middle)
    (right : Executes source destination middle second finish) :
    Executes source destination start (first++second) finish := by
  induction left with
  | nil => exact right
  | cons step tail ih => exact .cons step (ih right)

def loadThread (source : Nat) (state : Machine) (thread : Fin count) : Machine :=
  ⟨update state thread (.loaded (HalfMemory.load state.memory source)),state.memory⟩

def finishThread (source destination : Nat) (state : Machine) (thread : Fin count) : Machine :=
  let loaded := loadThread source state thread
  ⟨update loaded thread .done,HalfMemory.store state.memory (destination+2*thread.val) (HalfMemory.load state.memory source)⟩

def threadEvents (thread : Fin count) : List Event := [.load thread,.store thread]

theorem finishThread_phase (thread other : Fin count) (state : Machine) :
    (finishThread source destination state thread).phase other=
      if other=thread then .done else state.phase other := by
  by_cases same : other=thread <;> simp [finishThread,loadThread,update,same]

theorem finishThread_exec (thread : Fin count) (state : Machine) (ready : state.phase thread=.unread)
    (ordered : ∀ previous : Fin count, previous.val/4=thread.val/4 → previous.val<thread.val → state.phase previous=.done) :
    Executes source destination state (threadEvents thread) (finishThread source destination state thread) :=
  .cons (.load ready ordered) (.cons (.store (by simp [update])) (.nil _))

def drain (source destination : Nat) : List (Fin count) → Machine → Machine
  | [], state => state
  | thread::rest, state => drain source destination rest (finishThread source destination state thread)

theorem drain_phase (threads : List (Fin count)) (state : Machine) (thread : Fin count) :
    (drain source destination threads state).phase thread=
      if thread∈threads then .done else state.phase thread := by
  induction threads generalizing state with
  | nil => simp [drain]
  | cons first rest ih =>
    rw [drain,ih,finishThread_phase]
    by_cases inRest : thread∈rest <;> by_cases same : thread=first <;> simp [inRest,same]

theorem drain_exec (threads : List (Fin count)) (state : Machine)
    (sorted : threads.Pairwise (fun a b => a.val<b.val))
    (ready : ∀ thread∈threads, state.phase thread=.unread)
    (ordered : ∀ thread∈threads, ∀ previous : Fin count,
      previous.val/4=thread.val/4 → previous.val<thread.val → previous∉threads → state.phase previous=.done) :
    Executes source destination state (threads.flatMap threadEvents) (drain source destination threads state) := by
  induction threads generalizing state with
  | nil => exact .nil _
  | cons first rest ih =>
    have order := (List.pairwise_cons.mp sorted).1
    have tailSorted := (List.pairwise_cons.mp sorted).2
    have firstOrdered : ∀ previous : Fin count, previous.val/4=first.val/4 → previous.val<first.val → state.phase previous=.done := by
      intro previous same less
      apply ordered first List.mem_cons_self previous same less
      intro member
      rcases List.mem_cons.mp member with equal|member
      · subst previous; omega
      · have := order previous member; omega
    exact (finishThread_exec first state (ready first List.mem_cons_self) firstOrdered).append
      (ih _ tailSorted
        (fun thread present => by
          rw [finishThread_phase]
          have different : thread≠first := by have := order thread present; intro same; subst thread; omega
          rw [ite_eq_right different]
          exact ready thread (List.mem_cons_of_mem _ present))
        (by
          intro thread present previous same less notIn
          rw [finishThread_phase]
          by_cases equal : previous=first
          · exact ite_eq_left equal
          · rw [ite_eq_right equal]
            exact ordered thread (List.mem_cons_of_mem _ present) previous same less
              (by simpa only [List.mem_cons,not_or] using And.intro equal notIn)))

def canonicalAfter (source destination : Nat) (memory : HalfMemory.Bytes) : Machine :=
  drain source destination (List.finRange count) (initial memory)

theorem canonical_execution (source destination : Nat) (memory : HalfMemory.Bytes) :
    Executes source destination (initial memory) ((List.finRange count).flatMap threadEvents)
      (canonicalAfter source destination memory) :=
  drain_exec _ _ (List.pairwise_lt_finRange count) (by intro thread present; rfl)
    (by intro thread present previous same less missing; exact False.elim (missing (List.mem_finRange previous)))

theorem canonical_completed (source destination : Nat) (memory : HalfMemory.Bytes) :
    Completed (canonicalAfter source destination memory) := by
  intro thread
  unfold canonicalAfter
  rw [drain_phase]
  simp only [List.mem_finRange,ite_true]

section Attachments
variable {value : ArrayStorage.BF} (sourceBuffer : ArrayStorage.BFBuffer (fun _ : Fin 1 => value))
  (allocation : Allocation sourceBuffer.base destination)
  (execution : Executes sourceBuffer.base destination (initial sourceBuffer.bytes) events after)
  (completed : Completed after)

def outputBuffer : ArrayStorage.BFBuffer (fun _ : Fin count => value) where
  bytes := after.memory
  base := destination
  aligned := allocation.destinationAligned
  bounded := allocation.destinationBounded
  attached := by
    intro thread
    exact (completed_read allocation execution completed thread).trans
      (by simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] using sourceBuffer.attached (0 : Fin 1))

def sourceAfter : ArrayStorage.BFBuffer (fun _ : Fin 1 => value) :=
  ArrayFrame.bf sourceBuffer after.memory (frame allocation execution allocation.fresh)

theorem source_output_shared :
    (sourceAfter sourceBuffer allocation execution).bytes=(outputBuffer sourceBuffer allocation execution completed).bytes := rfl

end Attachments

-- Same physical heap as the existing four-words-per-thread trace used by KV.
theorem copy_refines (allocation : Allocation source destination)
    (execution : Executes source destination (initial before) events after) (completed : Completed after) :
    after.memory=(ScalarCopyQuadSemantics.copyTrace allocation before).memory :=
  (refines allocation execution completed).trans (ScalarCopyQuadSemantics.copyTrace_eq allocation before).symm

end Inference.Kernels.Copy.ScalarCopyQuadInterleaving
