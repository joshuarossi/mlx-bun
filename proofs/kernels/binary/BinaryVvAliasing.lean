import kernels.binary.BinaryVvSourceRefinement

namespace Inference.Kernels.Binary.BinaryVvAliasing
open Contracts.Mlx BinaryVvBody BinaryVvInterleaving
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange

-- Exact whole-buffer aliased or disjoint whole span. Shifted overlaps are not
-- admitted. Native donation eligibility/ownership is not inferred by this
-- geometry contract. Parsed source, builtin and coherence boundaries are the
-- same as in the imported fresh-destination proof.
structure Allocation (left right destination : Nat) : Prop where
  leftAligned : left%2=0
  rightAligned : right%2=0
  destinationAligned : destination%2=0
  leftBounded : left+2*count≤2^64
  rightBounded : right+2*count≤2^64
  destinationBounded : destination+2*count≤2^64
  leftSafe : left=destination ∨ MemoryRegions.Disjoint destination (2*count) left (2*count)
  rightSafe : right=destination ∨ MemoryRegions.Disjoint destination (2*count) right (2*count)

structure Invariant (left right destination : Nat) (before : HalfMemory.Bytes) (state : BinaryVvInterleaving.Machine) : Prop where
  registers : ∀ thread operand value, state.registers thread operand=some value →
    value=HalfMemory.load before (sources left right operand+2*thread.val)
  stored : ∀ thread, state.done thread=true → ∀ offset < 2,
    state.memory (destination+2*thread.val+offset)=HalfMemory.byte (BinaryVvBody.value left right before thread) offset
  unfinished : ∀ thread, state.done thread=false → ∀ offset < 2,
    state.memory (destination+2*thread.val+offset)=before (destination+2*thread.val+offset)
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset < size,
    state.memory (base+offset)=before (base+offset)

variable {left right destination : Nat} {before : HalfMemory.Bytes} {state after : BinaryVvInterleaving.Machine}
  {event : Event} {events : List Event}

theorem initial_invariant (left right destination : Nat) (before : HalfMemory.Bytes) :
    Invariant left right destination before (BinaryVvInterleaving.initial before) where
  registers:=by intro thread operand value impossible; cases impossible
  stored:=by intro thread impossible; cases impossible
  unfinished:=by intros; rfl
  frame:=by intros; rfl

theorem sources_safe (allocation : Allocation left right destination) (operand : Fin 2) :
    sources left right operand=destination ∨
      MemoryRegions.Disjoint destination (2*count) (sources left right operand) (2*count) := by
  unfold sources
  split
  · exact allocation.leftSafe
  · exact allocation.rightSafe

-- Aliased input reads require only that their OWN destination cell has not
-- stored yet. Other threads can already have completed their stores.
theorem source_read (allocation : Allocation left right destination)
    (invariant : Invariant left right destination before state) (thread : Fin count) (operand : Fin 2)
    (unfinished : state.done thread=false) :
    HalfMemory.load state.memory (sources left right operand+2*thread.val)=
      HalfMemory.load before (sources left right operand+2*thread.val) := by
  rcases sources_safe allocation operand with aliased|fresh
  · rw [aliased]
    unfold HalfMemory.load
    rw [invariant.unfinished thread unfinished 1 (by decide),invariant.unfinished thread unfinished 0 (by decide)]
  · exact ArrayFrame.half_congr before state.memory (sources left right operand) (2*count) (2*thread.val)
      (invariant.frame _ _ fresh) (by have := thread.isLt; omega)

theorem step_invariant (allocation : Allocation left right destination)
    (invariant : Invariant left right destination before state)
    (actual : Step left right destination state event after) : Invariant left right destination before after := by
  cases actual with
  | @load _ thread operand ready unfinished =>
    refine ⟨?_,invariant.stored,invariant.unfinished,invariant.frame⟩
    intro other op value loaded
    by_cases same : other=thread ∧ op=operand
    · obtain ⟨sameThread,sameOp⟩:=same
      subst other
      subst op
      have equal := Option.some.inj (show some (HalfMemory.load state.memory (sources left right operand+2*thread.val))=some value by
        simpa [loadCell] using loaded)
      exact equal.symm.trans (source_read allocation invariant thread operand unfinished)
    · exact invariant.registers other op value (by simpa only [loadCell,ite_eq_right same] using loaded)
  | @store x y _ thread first second unfinished =>
    have xeq:=invariant.registers thread 0 x first
    have yeq:=invariant.registers thread 1 y second
    have result_eq : combine x y=BinaryVvBody.value left right before thread := by rw [xeq,yeq]; rfl
    refine ⟨invariant.registers,?_,?_,?_⟩
    · intro other done offset bound
      by_cases same : other=thread
      · subst other
        exact (Copy.VectorCopyInterleaving.store_byte state.memory _ (combine x y) offset bound).trans
          (congrArg (fun v => HalfMemory.byte v offset) result_eq)
      · exact (Copy.VectorCopyInterleaving.store_other state.memory _ (combine x y)
          (BinaryVvInterleaving.no_interthread_overlap thread other (Ne.symm same)) offset bound).trans
          (invariant.stored other (by simpa only [storeCell,ite_eq_right same] using done) offset bound)
    · intro other pending offset bound
      by_cases same : other=thread
      · subst other
        simp only [storeCell,ite_true,Bool.true_eq_false] at pending
      · exact (Copy.VectorCopyInterleaving.store_other state.memory _ (combine x y)
          (BinaryVvInterleaving.no_interthread_overlap thread other (Ne.symm same)) offset bound).trans
          (invariant.unfinished other (by simpa only [storeCell,ite_eq_right same] using pending) offset bound)
    · intro base size separate offset bound
      exact (BinaryVvInterleaving.store_frame thread state x y separate offset bound).trans
        (invariant.frame base size separate offset bound)

theorem executes_invariant (allocation : Allocation left right destination)
    (actual : Executes left right destination state events after)
    (invariant : Invariant left right destination before state) : Invariant left right destination before after := by
  induction actual with
  | nil => exact invariant
  | cons step rest ih => exact ih (step_invariant allocation invariant step)

variable (allocation : Allocation left right destination)
  (actual : Executes left right destination (BinaryVvInterleaving.initial before) events after) (completed : Completed after)

include allocation actual completed in
theorem completed_byte (thread : Fin count) (offset : Nat) (bound : offset<2) :
    after.memory (destination+2*thread.val+offset)=HalfMemory.byte (BinaryVvBody.value left right before thread) offset :=
  (executes_invariant allocation actual (initial_invariant left right destination before)).stored thread (completed thread) offset bound

include allocation actual completed in
theorem completed_read (thread : Fin count) :
    HalfMemory.load after.memory (destination+2*thread.val)=BinaryVvBody.value left right before thread := by
  unfold HalfMemory.load
  rw [completed_byte allocation actual completed thread 1 (by decide),completed_byte allocation actual completed thread 0 (by decide)]
  exact HalfMemory.join_bytes _

include allocation actual in
theorem frame {base size : Nat} (separate : MemoryRegions.Disjoint destination (2*count) base size) (offset : Nat) (bound : offset<size) :
    after.memory (base+offset)=before (base+offset) :=
  (executes_invariant allocation actual (initial_invariant left right destination before)).frame base size separate offset bound

variable {valuesLeft valuesRight : Fin count → BFloatAddSource.BF}

theorem allocationFromBuffers (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat)
    (aligned : destination%2=0) (bounded : destination+10240≤2^64)
    (leftSafe : input.lhs.base=destination ∨ MemoryRegions.Disjoint destination 10240 input.lhs.base 10240)
    (rightSafe : input.rhs.base=destination ∨ MemoryRegions.Disjoint destination 10240 input.rhs.base 10240) :
    Allocation input.lhs.base input.rhs.base destination :=
  ⟨input.lhs.aligned,input.rhs.aligned,aligned,input.lhs.bounded,input.rhs.bounded,bounded,leftSafe,rightSafe⟩

-- Same existing trace can be consumed even when it overwrites either input.
-- The execution record already establishes its own independence/coverage.
theorem refines_existing (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination)
    (actual : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) : after.memory=existing.trace.memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let thread : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset:=(address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*thread.val+offset=address := by dsimp [thread,offset]; omega
    have first:=completed_byte allocation actual completed thread offset bound
    rw [BinaryVvSourceRefinement.initial_value input thread] at first
    have second:=congrArg (fun bits => HalfMemory.byte bits offset) (existing.buffer.attached thread)
    rw [show existing.buffer.base=destination from existingBase,HalfMemory.byte_load _ _ _ bound] at second
    rw [←atAddress]
    exact first.trans second.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by unfold MemoryRegions.Disjoint; omega
    have first:=frame allocation actual outside 0 (by decide)
    have second:=existing.other_region (base:=address) (size:=1) (by simpa only [existingBase] using outside) 0 (by decide)
    simpa only [Nat.add_zero] using first.trans second.symm

def output (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (actual : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) : ArrayStorage.BFBuffer (ElementwiseAdd.forward valuesLeft valuesRight) where
  bytes:=after.memory
  base:=destination
  aligned:=allocation.destinationAligned
  bounded:=allocation.destinationBounded
  attached:=fun thread => (completed_read allocation actual completed thread).trans (BinaryVvSourceRefinement.initial_value input thread)

def binary (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination) : BinaryMemory.Execution input BFloatAddSource.operation :=
  BinaryMemory.fromBuffers input BFloatAddSource.operation (destination/2)
    (by have := allocation.destinationAligned; have := allocation.destinationBounded; omega)
    (by
      rcases allocation.leftSafe with aliased|fresh
      · exact Or.inl (congrArg (fun base => base/2) aliased)
      · exact Or.inr (by simpa only [show 2*(destination/2)=destination by have := allocation.destinationAligned; omega]
          using MemoryRegions.disjoint_symm fresh))
    (by
      rcases allocation.rightSafe with aliased|fresh
      · exact Or.inl (congrArg (fun base => base/2) aliased)
      · exact Or.inr (by simpa only [show 2*(destination/2)=destination by have := allocation.destinationAligned; omega]
          using MemoryRegions.disjoint_symm fresh))

theorem binary_base (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination) : 2*(binary input allocation).base=destination := by
  change 2*(destination/2)=destination
  have := allocation.destinationAligned
  omega

theorem run_refines_existing (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination)
    (threads : List (Fin count)) (permutation : threads.Perm (List.finRange count)) :
    BinaryVvBody.run input.lhs.base input.rhs.base destination threads input.lhs.bytes=existing.trace.memory := by
  have actual:=drain_exec (left:=input.lhs.base) (right:=input.rhs.base) (destination:=destination)
    threads (BinaryVvInterleaving.initial input.lhs.bytes)
    (permutation.nodup_iff.mpr (List.nodup_finRange _)) (by intros; rfl) (by intros; rfl)
  have complete : Completed (drain input.lhs.base input.rhs.base destination threads (BinaryVvInterleaving.initial input.lhs.bytes)) := by
    intro thread
    rw [drain_done,ite_eq_left (permutation.mem_iff.mpr (List.mem_finRange thread))]
  have equal:=refines_existing input allocation existing existingBase actual complete
  rw [drain_memory] at equal
  exact equal

theorem any_launch (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination)
    {bodyAfter : HalfMemory.Bytes} (actual : Launch input.lhs.base input.rhs.base destination threads input.lhs.bytes bodyAfter)
    (permutation : threads.Perm (List.finRange count)) : bodyAfter=existing.trace.memory :=
  (launch_eq_run actual).trans (run_refines_existing input allocation existing existingBase threads permutation)

theorem canonical_launch (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination) :
    Launch input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes existing.trace.memory := by
  rw [←run_refines_existing input allocation existing existingBase (List.finRange count) (.refl _)]
  exact launch _ _ _ _ _

structure Checked (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat) where
  bodyAfter : HalfMemory.Bytes
  bodyExecution : Launch input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes bodyAfter
  eventAfter : BinaryVvInterleaving.Machine
  eventExecution : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes)
    ((List.finRange count).flatMap cellEvents) eventAfter
  completed : Completed eventAfter

def checked (input : BinaryMemory.Input valuesLeft valuesRight) (destination : Nat) : Checked input destination where
  bodyAfter:=BinaryVvBody.run input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes
  bodyExecution:=launch _ _ _ _ _
  eventAfter:=canonicalAfter input.lhs.base input.rhs.base destination input.lhs.bytes
  eventExecution:=canonical_execution _ _ _ _
  completed:=canonical_completed _ _ _ _

theorem checked_eq_existing (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (existing : BinaryMemory.Execution input BFloatAddSource.operation) (existingBase : 2*existing.base=destination) :
    (checked input destination).bodyAfter=existing.trace.memory ∧ (checked input destination).eventAfter.memory=existing.trace.memory :=
  ⟨any_launch input allocation existing existingBase (checked input destination).bodyExecution (.refl _),
    refines_existing input allocation existing existingBase (checked input destination).eventExecution (checked input destination).completed⟩

theorem from_events (input : BinaryMemory.Input valuesLeft valuesRight)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (actual : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (completed : Completed after) :
    Launch input.lhs.base input.rhs.base destination (List.finRange count) input.lhs.bytes after.memory := by
  rw [refines_existing input allocation (binary input allocation) (binary_base input allocation) actual completed]
  exact canonical_launch input allocation (binary input allocation) (binary_base input allocation)

-- The general frame retains arbitrary caches/parameters outside the output.
-- An aliased operand itself is the updated result, not a retained old buffer.
def retained {n : Nat} {values : Fin n → ArrayStorage.BF}
    (source : ArrayStorage.BFBuffer values) (input : BinaryMemory.Input valuesLeft valuesRight)
    (shared : source.bytes=input.lhs.bytes)
    (allocation : Allocation input.lhs.base input.rhs.base destination)
    (actual : Executes input.lhs.base input.rhs.base destination (BinaryVvInterleaving.initial input.lhs.bytes) events after)
    (separate : MemoryRegions.Disjoint destination 10240 source.base (2*n)) : ArrayStorage.BFBuffer values :=
  ArrayFrame.bf source after.memory (by
    intro offset bound
    exact (frame allocation actual separate offset bound).trans (congrFun shared _).symm)

theorem leftAllocation (input : BinaryMemory.Input valuesLeft valuesRight)
    (rightSafe : input.rhs.base=input.lhs.base ∨ MemoryRegions.Disjoint input.lhs.base 10240 input.rhs.base 10240) :
    Allocation input.lhs.base input.rhs.base input.lhs.base :=
  allocationFromBuffers input input.lhs.base input.lhs.aligned input.lhs.bounded (Or.inl rfl) rightSafe

theorem rightAllocation (input : BinaryMemory.Input valuesLeft valuesRight)
    (leftSafe : input.lhs.base=input.rhs.base ∨ MemoryRegions.Disjoint input.rhs.base 10240 input.lhs.base 10240) :
    Allocation input.lhs.base input.rhs.base input.rhs.base :=
  allocationFromBuffers input input.rhs.base input.rhs.aligned input.rhs.bounded leftSafe (Or.inl rfl)

theorem safe_excludes_shifted {source destination : Nat} (offset : Nat) (positive : 0<offset) (inside : offset<10240)
    (shifted : source=destination+offset) :
    ¬(source=destination ∨ MemoryRegions.Disjoint destination 10240 source 10240) := by
  intro safe
  rcases safe with same|separate
  · omega
  · unfold MemoryRegions.Disjoint at separate
    omega

end Inference.Kernels.Binary.BinaryVvAliasing
