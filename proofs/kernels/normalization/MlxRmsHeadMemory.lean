import kernels.normalization.MlxRmsHeadPointers

namespace Inference.Kernels.Normalization.MlxRmsHeadMemory
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
attribute [local irreducible] List.finRange RmsHeadsMemory.produced

variable {heads base : Nat} {values : Fin heads → Fin 256 → ArrayStorage.BF} {weight : Fin 256 → ArrayStorage.BF}
  (input : RmsHeadsMemory.Input values weight base)

def floatCache (registers : RmsHeadReads.Registers) : MlxRmsHeadRegisters.Registers :=
  fun i => BFloat16.widen (Model.ofBits (registers i))

def captureSource (contracted : Bool) (head : Fin heads) (thread : Fin 64) (memory : HalfMemory.Bytes) :
    Option MlxRmsHeadRegisters.State := do
  let start ←MlxRmsHeadSyntax.parseBranch MlxRmsHeadSyntax.sourceBranchBody
  if ((thread.val*4)%2^32+4)%2^32≤256 ∧ start=0 then
    let x ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceX "x" base head.val 256 thread.val 1
    pure (MlxRmsHeadRegisters.captured contracted x memory)
  else none

theorem capture_execution (input : RmsHeadsMemory.Input values weight base) (headBound : heads≤2^32) (contracted : Bool) (head : Fin heads) (thread : Fin 64)
    (memory : HalfMemory.Bytes) :
    ∃ after, captureSource (base:=base) contracted head thread memory=some after ∧
      MlxRmsHeadRegisters.Captures contracted (base+2*(head.val*256+thread.val*4)) memory
        (List.finRange 4) MlxRmsHeadRegisters.initial after ∧
      ∀ i, after.registers i=floatCache (RmsHeadReads.read base memory head thread) i := by
  let source := base+2*(head.val*256+thread.val*4)
  refine ⟨MlxRmsHeadRegisters.captured contracted source memory,?_,
    MlxRmsHeadRegisters.canonical _ _ _ _ _,?_⟩
  · unfold captureSource
    rw [MlxRmsHeadSyntax.parsed_branch]
    have pointer := (MlxRmsHeadPointers.selected_pointers input headBound head thread).1
    simp [pointer,source]
    exact (Nat.mod_le _ _).trans (MlxRmsHeadHostSelection.full_block thread)
  · intro i
    rw [MlxRmsHeadRegisters.captured_register]
    unfold MlxRmsHeadRegisters.loaded floatCache RmsHeadReads.read
    rw [RmsHeadReads.native_address]
    congr 3
    dsimp only [source]
    omega

def inverseWords {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (head : Fin heads) : M1Max.WordMemory :=
  fun word => FloatMemory.load (execution.inverse head).memory (4*word)

theorem inverse_read {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (head : Fin heads) :
    inverseWords input execution head 0=execution.factor head := (execution.factorRead head).symm

def outputSource {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (head : Fin heads) (thread : Fin 64)
    (i : Fin 4) (registers : RmsHeadReads.Registers) (memory : HalfMemory.Bytes) : Option HalfMemory.Bytes := do
  let start ←MlxRmsHeadSyntax.parseBranch MlxRmsHeadSyntax.sourceBranchBody
  if ((thread.val*4)%2^32+4)%2^32≤256 ∧ start=0 then
    let w ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceW "w" input.weight.base head.val 256 thread.val 1
    let out ←MlxRmsPointerSource.execute MlxRmsPointerSource.sourceOut "out" base head.val 256 thread.val 1
    MlxRmsHeadRegisters.outputSource w out (inverseWords input execution head) 0 (floatCache registers) i memory
  else none

-- Raw cache values are established by capture ownership. Current weights are
-- preserved outside all donated head rows, even when other rows interleave.
theorem output_execution {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (headBound : heads≤2^32)
    (head : Fin heads) (thread : Fin 64) (i : Fin 4) (registers : RmsHeadReads.Registers)
    (memory : HalfMemory.Bytes)
    (captured : ∀ j, registers j=ArrayStorage.bits (values head (RmsHeadReads.coordinate thread j)))
    (weights : ∀ offset < 512, memory (input.weight.base+offset)=input.source.memory (input.weight.base+offset)) :
    outputSource input execution head thread i registers memory=some
      (HalfMemory.store memory (base+2*(head.val*256+thread.val*4+i.val))
        (ArrayStorage.bits (RmsHeadsMemory.produced input execution.factor head (RmsHeadReads.coordinate thread i)))) := by
  have pointers := MlxRmsHeadPointers.selected_pointers input headBound head thread
  have full := MlxRmsHeadHostSelection.unsigned_full_block thread
  unfold outputSource
  rw [MlxRmsHeadSyntax.parsed_branch]
  simp only [full,pointers.2.1,pointers.2.2]
  change MlxRmsHeadRegisters.outputSource (input.weight.base+2*(thread.val*4))
    (base+2*(head.val*256+thread.val*4)) (inverseWords input execution head) 0 (floatCache registers) i memory=_
  rw [MlxRmsHeadRegisters.output_execution]
  have weightRead : HalfMemory.load memory (input.weight.base+2*(RmsHeadReads.coordinate thread i).val)=
      ArrayStorage.bits (weight (RmsHeadReads.coordinate thread i)) := by
    rw [ArrayFrame.half_congr input.source.memory memory input.weight.base 512
      (2*(RmsHeadReads.coordinate thread i).val) weights (by have := (RmsHeadReads.coordinate thread i).isLt; omega)]
    rw [←input.shared]
    exact input.weight.attached _
  have shifted : input.weight.base+2*(thread.val*4)+2*i.val=
      input.weight.base+2*(RmsHeadReads.coordinate thread i).val := by dsimp [RmsHeadReads.coordinate]; omega
  have outputShift : base+2*(head.val*256+thread.val*4)+2*i.val=base+2*(head.val*256+thread.val*4+i.val) := by omega
  unfold MlxRmsHeadRegisters.outputCell
  rw [shifted,weightRead,inverse_read input execution head]
  simp only [floatCache,captured,RmsHeadsMemory.produced,ArrayStorage.BFBuffer.read_correct,RmsNormMemory.operation,outputShift]
  rfl

-- Membership exposes both the store address and its proved value; source
-- refinement never takes an output oracle or a completed-memory equality.
theorem store_member {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (store : HalfMemory.Store)
    (member : store∈execution.stores.schedule) :
    ∃ head : Fin heads, ∃ col : Fin 256,
      store.word=base/2+head.val*256+col.val ∧
      store.value=ArrayStorage.bits (RmsHeadsMemory.produced input execution.factor head col) := by
  have original := (ThreadgroupWrites.completed_schedule execution.stores.execution execution.stores.completed).mem_iff.mp member
  obtain ⟨head,member⟩ := MultiOutputWrites.member (execution.geometry.layout (RmsHeadsMemory.produced input execution.factor)) store original
  obtain ⟨thread,offset,rfl⟩ := CopyContiguous.member _ _ store member
  refine ⟨head,CopyContiguous.index thread offset,?_,rfl⟩
  have := execution.geometry.aligned
  dsimp only [CopyContiguous.entry,RmsHeadStores.Geometry.layout,RmsHeadReads.layout]
  omega


structure Invariant {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (state : RmsHeadReads.Machine heads) : Prop where
  captured : ReadBeforeOverwrite.Valid (RmsHeadReads.layout heads base) (RmsHeadReads.read base) input.source.memory state
  weights : ∀ offset < 512, state.memory (input.weight.base+offset)=input.source.memory (input.weight.base+offset)

theorem initial_invariant {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) :
    Invariant input execution (ReadBeforeOverwrite.initial input.source.memory) :=
  ⟨ReadBeforeOverwrite.initial_valid,by intros; rfl⟩

theorem preserve {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps)
    {before after : RmsHeadReads.Machine heads} {event : ReadBeforeOverwrite.Event heads 64}
    (step : ReadBeforeOverwrite.Step (RmsHeadReads.layout heads base) (RmsHeadReads.read base) before event after)
    (valid : Invariant input execution before) : Invariant input execution after := by
  refine ⟨ReadBeforeOverwrite.step_valid (RmsHeadReads.read_local heads base) step valid.captured,?_⟩
  cases step with
  | capture head thread pending => exact valid.weights
  | write head store ready inside =>
    intro offset bound
    exact (MemoryProjection.half_misses store inside
      (RmsHeadReads.group_separate execution.weightSeparate head) offset bound before.memory).trans (valid.weights offset bound)

inductive Step {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) :
    RmsHeadReads.Machine heads → ReadBeforeOverwrite.Event heads 64 → RmsHeadReads.Machine heads → Prop where
  | capture (before : RmsHeadReads.Machine heads) (head : Fin heads) (thread : Fin 64)
      (pending : before.registers head thread=none) (afterRegisters : MlxRmsHeadRegisters.State)
      (source : captureSource (base:=base) p.contracted head thread before.memory=some afterRegisters)
      (cells : MlxRmsHeadRegisters.Captures p.contracted (base+2*(head.val*256+thread.val*4)) before.memory
        (List.finRange 4) MlxRmsHeadRegisters.initial afterRegisters)
      (cache : ∀ i, afterRegisters.registers i=floatCache (RmsHeadReads.read base before.memory head thread) i) :
      Step execution before (.capture head thread) (ReadBeforeOverwrite.capture (RmsHeadReads.read base) before head thread)
  | write (before : RmsHeadReads.Machine heads) (head : Fin heads) (store : HalfMemory.Store)
      (thread : Fin 64) (i : Fin 4) (registers : RmsHeadReads.Registers)
      (captured : before.registers head thread=some registers)
      (ready : ReadBeforeOverwrite.Ready before head)
      (inside : (RmsHeadReads.layout heads base).base head≤2*store.word ∧
        2*store.word+2≤(RmsHeadReads.layout heads base).base head+512)
      (source : outputSource input execution head thread i registers before.memory=
        some (HalfMemory.store before.memory (2*store.word) store.value)) :
      Step execution before (.write head store) (ReadBeforeOverwrite.write before store)

inductive Executes {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) :
    RmsHeadReads.Machine heads → List (ReadBeforeOverwrite.Event heads 64) → RmsHeadReads.Machine heads → Prop where
  | done (before) : Executes execution before [] before
  | next (step : Step input execution before event middle)
      (rest : Executes execution middle events after) : Executes execution before (event::events) after

theorem step_source {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (headBound : heads≤2^32)
    {before after : RmsHeadReads.Machine heads} {event : ReadBeforeOverwrite.Event heads 64}
    (step : ReadBeforeOverwrite.Step (RmsHeadReads.layout heads base) (RmsHeadReads.read base) before event after)
    (valid : Invariant input execution before)
    (member : ∀ head store, event=.write head store → store∈execution.stores.schedule) :
    Step input execution before event after := by
  cases step with
  | capture head thread pending =>
    obtain ⟨registers,source,cells,cache⟩ := capture_execution input headBound p.contracted head thread before.memory
    exact .capture before head thread pending registers source cells cache
  | write head store ready inside =>
    obtain ⟨row,col,address,value⟩ := store_member input execution store (member head store rfl)
    have aligned := execution.geometry.aligned
    have rowAddress : 2*store.word=base+row.val*512+2*col.val := by omega
    have sameHead : row=head := by
      apply Fin.ext
      have := col.isLt
      dsimp only [RmsHeadReads.layout] at inside
      omega
    subst row
    let thread := RmsHeadReads.reader col
    let i := RmsHeadReads.offset col
    have coord : RmsHeadReads.coordinate thread i=col := RmsHeadReads.coordinate_inverse col
    cases cached : before.registers head thread with
    | none => exact False.elim (ready thread cached)
    | some registers =>
      have original := valid.captured.registers head thread registers cached
      have bits (j : Fin 4) : registers j=ArrayStorage.bits (values head (RmsHeadReads.coordinate thread j)) := by
        rw [original]
        exact input.source.read_correct head thread j
      have parsed := output_execution input execution headBound head thread i registers before.memory bits valid.weights
      have exactAddress : base+2*(head.val*256+thread.val*4+i.val)=2*store.word := by
        have same := congrArg Fin.val coord
        dsimp only [RmsHeadReads.coordinate] at same
        omega
      rw [coord,exactAddress,←value] at parsed
      exact .write before head store thread i registers cached ready inside parsed

theorem trace_source {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (headBound : heads≤2^32)
    {before after : RmsHeadReads.Machine heads} {events : List (ReadBeforeOverwrite.Event heads 64)}
    (run : ReadBeforeOverwrite.Executes (RmsHeadReads.layout heads base) (RmsHeadReads.read base) before events after)
    (valid : Invariant input execution before)
    (members : ∀ head store, ReadBeforeOverwrite.Event.write head store∈events → store∈execution.stores.schedule) :
    Executes input execution before events after := by
  induction run with
  | done before => exact .done before
  | @next before middle after event events step run ih =>
    refine .next (step_source input execution headBound step valid ?_) (ih (preserve input execution step valid) ?_)
    · intro head store same
      apply members head store
      rw [←same]
      exact List.mem_cons_self
    · intro head store member
      exact members head store (List.mem_cons_of_mem _ member)

-- Exact current-heap simulation of every capture/write event in the existing
-- ownership trace. Cache construction is parsed before donation; later stores
-- read those caches and the preserved current weights, never overwritten x.
theorem checked {p : RmsNorm.Platform} {width eps : Float32}
    (execution : RmsHeadsMemory.Execution input p width eps) (headBound : heads≤2^32) :
    Executes input execution (ReadBeforeOverwrite.initial input.source.memory) execution.reads.events execution.reads.after ∧
      execution.reads.after.memory=execution.stores.memory := by
  refine ⟨trace_source input execution headBound ?_ (initial_invariant input execution) ?_,execution.memory⟩
  · simpa only [execution.initial] using execution.reads.execution
  · intro head store member
    have present : store∈execution.reads.events.filterMap ReadBeforeOverwrite.storeProjection :=
      List.mem_filterMap.mpr ⟨.write head store,member,rfl⟩
    rw [execution.storeSchedule] at present
    exact present

end Inference.Kernels.Normalization.MlxRmsHeadMemory
