import kernels.binary.BinaryVvBody
import contracts.mlx.ArrayFrame
import kernels.copy.VectorCopyInterleaving

namespace Inference.Kernels.Binary.BinaryVvInterleaving
open Contracts.Mlx BinaryVvBody
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The two input loads are separate model events and may occur in either order.
-- Every store consumes both captured registers. 16-bit coherent accesses,
-- dispatch completion/visibility and physical builtin Add remain boundaries.
structure Machine where
  registers : Fin count → Fin 2 → Option (BitVec 16)
  done : Fin count → Bool
  memory : HalfMemory.Bytes

def sources (left right : Nat) (operand : Fin 2) : Nat := if operand.val=0 then left else right

def loadCell (left right : Nat) (state : Machine) (thread : Fin count) (operand : Fin 2) : Machine :=
  {state with registers:=fun other op =>
    if other=thread ∧ op=operand then some (HalfMemory.load state.memory (sources left right operand+2*thread.val))
    else state.registers other op}

def combine (x y : BitVec 16) : BitVec 16 :=
  ArrayStorage.bits (BFloatAddSource.operation (Model.ofBits x) (Model.ofBits y))

def storeCell (destination : Nat) (state : Machine) (thread : Fin count) (x y : BitVec 16) : Machine :=
  { state with done := (fun other => if other=thread then true else state.done other), memory := HalfMemory.store state.memory (destination+2*thread.val) (combine x y) }

inductive Event where
  | load : Fin count → Fin 2 → Event
  | store : Fin count → Event
  deriving DecidableEq

inductive Step (left right destination : Nat) : Machine → Event → Machine → Prop where
  | load (ready : before.registers thread operand=none) (unfinished : before.done thread=false) :
    Step left right destination before (.load thread operand) (loadCell left right before thread operand)
  | store (first : before.registers thread 0=some x) (second : before.registers thread 1=some y)
      (unfinished : before.done thread=false) :
    Step left right destination before (.store thread) (storeCell destination before thread x y)

inductive Executes (left right destination : Nat) : Machine → List Event → Machine → Prop where
  | nil (state) : Executes left right destination state [] state
  | cons : Step left right destination before action middle →
    Executes left right destination middle actions after → Executes left right destination before (action::actions) after

def initial (memory : HalfMemory.Bytes) : Machine := ⟨fun _ _ => none,fun _ => false,memory⟩
def Completed (state : Machine) : Prop := ∀ thread, state.done thread=true

structure Allocation (left right destination : Nat) : Prop where
  leftAligned : left%2=0
  rightAligned : right%2=0
  destinationAligned : destination%2=0
  leftBounded : left+2*count≤2^64
  rightBounded : right+2*count≤2^64
  destinationBounded : destination+2*count≤2^64
  leftFresh : MemoryRegions.Disjoint destination (2*count) left (2*count)
  rightFresh : MemoryRegions.Disjoint destination (2*count) right (2*count)

structure Invariant (left right destination : Nat) (before : HalfMemory.Bytes) (state : Machine) : Prop where
  registers : ∀ thread operand value, state.registers thread operand=some value →
    value=HalfMemory.load before (sources left right operand+2*thread.val)
  stored : ∀ thread, state.done thread=true → ∀ offset < 2,
    state.memory (destination+2*thread.val+offset)=HalfMemory.byte (BinaryVvBody.value left right before thread) offset
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset < size,
    state.memory (base+offset)=before (base+offset)

variable {left right destination : Nat} {before : HalfMemory.Bytes} {state after : Machine} {event : Event} {events : List Event}

theorem initial_invariant (left right destination : Nat) (before : HalfMemory.Bytes) :
    Invariant left right destination before (initial before) where
  registers := by intro thread operand value impossible; cases impossible
  stored := by intro thread impossible; cases impossible
  frame := by intros; rfl

theorem sources_fresh (allocation : Allocation left right destination) (operand : Fin 2) :
    MemoryRegions.Disjoint destination (2*count) (sources left right operand) (2*count) := by
  unfold sources
  split
  · exact allocation.leftFresh
  · exact allocation.rightFresh

theorem source_read (allocation : Allocation left right destination)
    (invariant : Invariant left right destination before state) (thread : Fin count) (operand : Fin 2) :
    HalfMemory.load state.memory (sources left right operand+2*thread.val)=
      HalfMemory.load before (sources left right operand+2*thread.val) :=
  ArrayFrame.half_congr before state.memory (sources left right operand) (2*count) (2*thread.val)
    (invariant.frame _ _ (sources_fresh allocation operand)) (by have := thread.isLt; omega)

theorem store_frame (thread : Fin count) (state : Machine) (x y : BitVec 16) {base size : Nat}
    (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    (storeCell destination state thread x y).memory (base+offset)=state.memory (base+offset) := by
  have small : MemoryRegions.Disjoint (destination+2*thread.val) 2 base size := by
    have := thread.isLt
    rcases separate with first|second
    · exact Or.inl (by omega)
    · exact Or.inr (by omega)
  exact Copy.VectorCopyInterleaving.store_other state.memory _ (combine x y) small offset bound

theorem step_invariant (allocation : Allocation left right destination)
    (invariant : Invariant left right destination before state)
    (step : Step left right destination state event after) : Invariant left right destination before after := by
  cases step with
  | @load _ thread operand ready unfinished =>
    refine ⟨?_,invariant.stored,invariant.frame⟩
    intro other op value loaded
    by_cases same : other=thread ∧ op=operand
    · obtain ⟨sameThread,sameOp⟩ := same
      subst other
      subst op
      have equal := Option.some.inj (show some (HalfMemory.load state.memory (sources left right operand+2*thread.val))=some value by
        simpa [loadCell] using loaded)
      exact equal.symm.trans (source_read allocation invariant thread operand)
    · exact invariant.registers other op value (by simpa only [loadCell,ite_eq_right same] using loaded)
  | @store x y _ thread first second unfinished =>
    have xeq := invariant.registers thread 0 x first
    have yeq := invariant.registers thread 1 y second
    have result_eq : combine x y=BinaryVvBody.value left right before thread := by
      rw [xeq,yeq]
      rfl
    refine ⟨invariant.registers,?_,?_⟩
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        exact (Copy.VectorCopyInterleaving.store_byte state.memory _ (combine x y) offset bound).trans
          (congrArg (fun v => HalfMemory.byte v offset) result_eq)
      · have different : thread.val≠other.val := fun equal => same (Fin.ext equal).symm
        have separate : MemoryRegions.Disjoint (destination+2*thread.val) 2 (destination+2*other.val) 2 := by
          unfold MemoryRegions.Disjoint
          omega
        exact (Copy.VectorCopyInterleaving.store_other state.memory _ (combine x y) separate offset bound).trans
          (invariant.stored other (by simpa only [storeCell,ite_eq_right same] using done) offset bound)
    · intro base size separate offset bound
      exact (store_frame thread state x y separate offset bound).trans (invariant.frame base size separate offset bound)

theorem executes_invariant (allocation : Allocation left right destination)
    (execution : Executes left right destination state events after)
    (invariant : Invariant left right destination before state) : Invariant left right destination before after := by
  induction execution with
  | nil => exact invariant
  | cons step rest ih => exact ih (step_invariant allocation invariant step)

variable (allocation : Allocation left right destination)
  (execution : Executes left right destination (initial before) events after) (completed : Completed after)

include allocation execution completed in
theorem completed_byte (thread : Fin count) (offset : Nat) (bound : offset<2) :
    after.memory (destination+2*thread.val+offset)=HalfMemory.byte (BinaryVvBody.value left right before thread) offset :=
  (executes_invariant allocation execution (initial_invariant left right destination before)).stored thread (completed thread) offset bound

include allocation execution completed in
theorem completed_read (thread : Fin count) :
    HalfMemory.load after.memory (destination+2*thread.val)=BinaryVvBody.value left right before thread := by
  unfold HalfMemory.load
  rw [completed_byte allocation execution completed thread 1 (by decide),completed_byte allocation execution completed thread 0 (by decide)]
  exact HalfMemory.join_bytes _

include allocation execution in
theorem frame {base size : Nat} (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    after.memory (base+offset)=before (base+offset) :=
  (executes_invariant allocation execution (initial_invariant left right destination before)).frame base size separate offset bound

theorem Executes.append {first second : List Event}
    (firstExec : Executes left right destination start first middle)
    (secondExec : Executes left right destination middle second finish) :
    Executes left right destination start (first++second) finish := by
  induction firstExec with
  | nil => exact secondExec
  | cons step rest ih => exact .cons step (ih secondExec)

def finishCell (left right destination : Nat) (state : Machine) (thread : Fin count) : Machine :=
  let first:=loadCell left right state thread 0
  let second:=loadCell left right first thread 1
  storeCell destination second thread
    (HalfMemory.load state.memory (left+2*thread.val)) (HalfMemory.load state.memory (right+2*thread.val))

def cellEvents (thread : Fin count) : List Event := [.load thread 0,.load thread 1,.store thread]

theorem finishCell_memory (state : Machine) (thread : Fin count) :
    (finishCell left right destination state thread).memory=
      HalfMemory.store state.memory (destination+2*thread.val) (BinaryVvBody.value left right state.memory thread) := rfl

theorem finishCell_done (state : Machine) (thread other : Fin count) :
    (finishCell left right destination state thread).done other=if other=thread then true else state.done other := rfl

theorem finishCell_other (state : Machine) (thread other : Fin count) (different : other≠thread) (op : Fin 2) :
    (finishCell left right destination state thread).registers other op=state.registers other op := by
  simp [finishCell,storeCell,loadCell,different]

theorem finishCell_exec (state : Machine) (thread : Fin count)
    (ready : ∀ op, state.registers thread op=none) (unfinished : state.done thread=false) :
    Executes left right destination state (cellEvents thread) (finishCell left right destination state thread) := by
  refine .cons (.load (ready 0) unfinished) (.cons (.load ?_ unfinished) (.cons (.store ?_ ?_ unfinished) (.nil _)))
  · simpa only [loadCell,Fin.zero_eta,Fin.isValue,one_ne_zero,and_false,ite_false] using ready 1
  · simp [loadCell,sources]
  · simp [loadCell,sources]

def drain (left right destination : Nat) : List (Fin count) → Machine → Machine
  | [], state => state
  | thread::rest, state => drain left right destination rest (finishCell left right destination state thread)

theorem drain_done (threads : List (Fin count)) (state : Machine) (thread : Fin count) :
    (drain left right destination threads state).done thread=if thread∈threads then true else state.done thread := by
  induction threads generalizing state with
  | nil => simp [drain]
  | cons first rest ih =>
    rw [drain,ih,finishCell_done]
    by_cases inRest : thread∈rest <;> by_cases same : thread=first <;> simp [inRest,same]

theorem drain_exec (threads : List (Fin count)) (state : Machine) (unique : threads.Nodup)
    (ready : ∀ thread∈threads, ∀ op, state.registers thread op=none)
    (unfinished : ∀ thread∈threads, state.done thread=false) :
    Executes left right destination state (threads.flatMap cellEvents) (drain left right destination threads state) := by
  induction threads generalizing state with
  | nil => exact .nil _
  | cons first rest ih =>
    have nodup:=List.nodup_cons.mp unique
    apply (finishCell_exec state first (ready first List.mem_cons_self) (unfinished first List.mem_cons_self)).append
    apply ih _ nodup.2
    · intro other member op
      have different : other≠first := by intro same; subst other; exact nodup.1 member
      rw [finishCell_other _ _ _ different]
      exact ready other (List.mem_cons_of_mem first member) op
    · intro other member
      have different : other≠first := by intro same; subst other; exact nodup.1 member
      rw [finishCell_done,ite_eq_right different]
      exact unfinished other (List.mem_cons_of_mem first member)

theorem drain_memory (threads : List (Fin count)) (state : Machine) :
    (drain left right destination threads state).memory=BinaryVvBody.run left right destination threads state.memory := by
  induction threads generalizing state with
  | nil => rfl
  | cons first rest ih => rw [drain,ih,finishCell_memory]; rfl

def canonicalAfter (left right destination : Nat) (before : HalfMemory.Bytes) : Machine :=
  drain left right destination (List.finRange count) (initial before)

theorem canonical_execution (left right destination : Nat) (before : HalfMemory.Bytes) :
    Executes left right destination (initial before) ((List.finRange count).flatMap cellEvents) (canonicalAfter left right destination before) :=
  drain_exec _ _ (List.nodup_finRange _) (by intros; rfl) (by intros; rfl)

theorem canonical_completed (left right destination : Nat) (before : HalfMemory.Bytes) :
    Completed (canonicalAfter left right destination before) := by
  intro thread
  rw [canonicalAfter,drain_done,ite_eq_left (List.mem_finRange thread)]

theorem addresses (allocation : Allocation left right destination) (thread : Fin count) :
    left+2*thread.val+2≤2^64 ∧ right+2*thread.val+2≤2^64 ∧ destination+2*thread.val+2≤2^64 ∧
      (left+2*thread.val)%2=0 ∧ (right+2*thread.val)%2=0 ∧ (destination+2*thread.val)%2=0 := by
  have := allocation.leftBounded
  have := allocation.rightBounded
  have := allocation.destinationBounded
  have := allocation.leftAligned
  have := allocation.rightAligned
  have := allocation.destinationAligned
  have := thread.isLt
  omega

theorem no_interthread_overlap (first second : Fin count) (different : first≠second) :
    MemoryRegions.Disjoint (destination+2*first.val) 2 (destination+2*second.val) 2 := by
  have distinct : first.val≠second.val := fun same => different (Fin.ext same)
  unfold MemoryRegions.Disjoint
  omega

end Inference.Kernels.Binary.BinaryVvInterleaving
