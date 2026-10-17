import kernels.copy.ScalarCopyFloatBodySemantics
import kernels.copy.ScalarCopyFloatInterleaving

namespace Inference.Kernels.Copy.ScalarCopyFloatSourceRefinement
open Contracts.Mlx ScalarCopyFloatSemantics
set_option maxRecDepth 10000
attribute [local irreducible] trace floatTrace run List.finRange

-- Parsed N=2 float->float bodies and arbitrary separate-event schedules meet
-- on one heap. Signature/dispatch binding, same-type cast interpretation,
-- compiler lowering, coherent word accesses and completion stay external.
variable {source destination : Nat} {before bodyAfter : ByteMemory.Bytes}
  {threads : List (Fin threadCount)} {events : List ScalarCopyFloatInterleaving.Event}
  {eventAfter : ScalarCopyFloatInterleaving.Machine}

structure Agreement (source destination : Nat) (allocation : Allocation source destination)
    (before bodyAfter : ByteMemory.Bytes) (eventAfter : ScalarCopyFloatInterleaving.Machine) (value : Float32) : Prop where
  parsed : ScalarCopySyntax.parseBody ScalarCopySyntax.sourceBody=some ScalarCopySyntax.body
  body_refines : bodyAfter=(floatTrace allocation before value).memory
  event_refines : eventAfter.memory=(floatTrace allocation before value).memory
  same_heap : bodyAfter=eventAfter.memory
  read : ∀ word : Fin count,
    ByteMemory.load32 eventAfter.memory (destination+4*word.val)=ByteMemory.load32 before source
  frame : ∀ base size, MemoryRegions.Disjoint destination (4*count) base size → ∀ offset < size,
    eventAfter.memory (base+offset)=before (base+offset)
  source_retained : ByteMemory.load32 eventAfter.memory source=ByteMemory.load32 before source

-- Both execution witnesses may have ANY permitted completed ordering. The
-- scalar's raw representation is attached to the INITIAL heap, not an output.
theorem joined (allocation : Allocation source destination)
    (bodyExecution : ScalarCopyFloatBodySemantics.Launch source destination threads before bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange threadCount))
    (eventExecution : ScalarCopyFloatInterleaving.Executes source destination
      (ScalarCopyFloatInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyFloatInterleaving.Completed eventAfter)
    (value : Float32) (raw : ByteMemory.load32 before source=FloatMemory.bits value) :
    Agreement source destination allocation before bodyAfter eventAfter value where
  parsed := ScalarCopySyntax.parsed_body
  body_refines := (ScalarCopyFloatBodySemantics.execution_refines allocation bodyExecution bodyCompleted value raw).2
  event_refines := ScalarCopyFloatInterleaving.float_refines allocation eventExecution eventCompleted value raw
  same_heap := ((ScalarCopyFloatBodySemantics.execution_refines allocation bodyExecution bodyCompleted value raw).2).trans
    (ScalarCopyFloatInterleaving.float_refines allocation eventExecution eventCompleted value raw).symm
  read := ScalarCopyFloatInterleaving.completed_read allocation eventExecution eventCompleted
  frame := fun _ _ separate => ScalarCopyFloatInterleaving.frame allocation eventExecution separate
  source_retained := ArrayFrame.word_congr before eventAfter.memory source 4 0
    (ScalarCopyFloatInterleaving.frame allocation eventExecution allocation.fresh) (by decide)

-- No caller supplies a thread-atomic execution: construct a parsed-body
-- representative for every completed event execution and prove agreement.
theorem from_events (allocation : Allocation source destination)
    (eventExecution : ScalarCopyFloatInterleaving.Executes source destination
      (ScalarCopyFloatInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyFloatInterleaving.Completed eventAfter)
    (value : Float32) (raw : ByteMemory.load32 before source=FloatMemory.bits value) :
    ∃ bodyAfter, ScalarCopyFloatBodySemantics.Launch source destination (List.finRange threadCount) before bodyAfter ∧
      Agreement source destination allocation before bodyAfter eventAfter value := by
  let bodyExecution := ScalarCopyFloatBodySemantics.launch_refines source destination allocation.destinationAligned
    (List.finRange threadCount) before
  exact ⟨_,bodyExecution,joined allocation bodyExecution (List.Perm.refl _) eventExecution eventCompleted value raw⟩

-- The four-event protocol for one invocation is exactly the two current-heap
-- reads/stores of the full parsed N=2 body, with four-byte pointer arithmetic.
theorem isolated_thread (allocation : Allocation source destination) (memory : ByteMemory.Bytes) (thread : Fin threadCount) :
    ScalarCopySyntax.parseBody ScalarCopySyntax.sourceBody=some ScalarCopySyntax.body ∧
    ScalarCopyFloatBodySemantics.Statements source destination ScalarCopySyntax.body
      (ScalarCopyFloatBodySemantics.initial memory thread) (ScalarCopyFloatBodySemantics.final source destination memory thread) ∧
    ScalarCopyFloatInterleaving.Executes source destination (ScalarCopyFloatInterleaving.initial memory)
      (ScalarCopyFloatInterleaving.threadEvents thread)
      (ScalarCopyFloatInterleaving.finishThread source destination (ScalarCopyFloatInterleaving.initial memory) thread) ∧
    (ScalarCopyFloatInterleaving.finishThread source destination (ScalarCopyFloatInterleaving.initial memory) thread).memory=
      (ScalarCopyFloatBodySemantics.final source destination memory thread).memory := by
  refine ⟨ScalarCopySyntax.parsed_body,
    ScalarCopyFloatBodySemantics.body_execution source destination allocation.destinationAligned memory thread,
    ScalarCopyFloatInterleaving.finishThread_exec thread _ (by intro off; rfl),?_⟩
  rw [ScalarCopyFloatBodySemantics.final_memory]
  rw [run,run,run]
  dsimp only [ScalarCopyFloatInterleaving.finishThread,ScalarCopyFloatInterleaving.finishOutput,
    ScalarCopyFloatInterleaving.initial,ByteMemory.execute,event]
  have first : 4*(destination/4+(index thread 0).val)=destination+4*(index thread 0).val := by
    have := allocation.destinationAligned
    omega
  have second : 4*(destination/4+(index thread 1).val)=destination+4*(index thread 1).val := by
    have := allocation.destinationAligned
    omega
  rw [first,second]

section Attached
variable {value : Float32} (sourceBuffer : ArrayStorage.FloatBuffer (fun _ : Fin 1 => value))
  (allocation : Allocation sourceBuffer.base destination)
  (raw : ByteMemory.load32 sourceBuffer.bytes sourceBuffer.base=FloatMemory.bits value)
  (bodyExecution : ScalarCopyFloatBodySemantics.Launch sourceBuffer.base destination threads sourceBuffer.bytes bodyAfter)
  (bodyCompleted : threads.Perm (List.finRange threadCount))
  (eventExecution : ScalarCopyFloatInterleaving.Executes sourceBuffer.base destination
    (ScalarCopyFloatInterleaving.initial sourceBuffer.bytes) events eventAfter)
  (eventCompleted : ScalarCopyFloatInterleaving.Completed eventAfter)

include raw bodyExecution bodyCompleted eventExecution eventCompleted in
theorem attached_agreement : Agreement sourceBuffer.base destination allocation sourceBuffer.bytes bodyAfter eventAfter value :=
  joined allocation bodyExecution bodyCompleted eventExecution eventCompleted value raw

include allocation raw bodyExecution bodyCompleted in
theorem body_read (word : Fin count) : FloatMemory.load bodyAfter (destination+4*word.val)=value := by
  unfold FloatMemory.load
  rw [ScalarCopyFloatBodySemantics.execution_raw_read allocation bodyExecution bodyCompleted word,raw,FloatMemory.decode_bits]

include bodyExecution bodyCompleted in
theorem body_output_shared : bodyAfter=
    (ScalarCopyFloatInterleaving.outputBuffer sourceBuffer allocation raw eventExecution eventCompleted).bytes :=
  (joined allocation bodyExecution bodyCompleted eventExecution eventCompleted value raw).same_heap

end Attached
end Inference.Kernels.Copy.ScalarCopyFloatSourceRefinement
