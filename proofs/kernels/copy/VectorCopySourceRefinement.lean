import kernels.copy.VectorCopyBodySemantics
import kernels.copy.VectorCopyInterleaving

namespace Inference.Kernels.Copy.VectorCopySourceRefinement
open Contracts.Mlx VectorCopySemantics
set_option maxRecDepth 10000
attribute [local irreducible] copyTrace trace run List.finRange

-- Selected allocated BF16 copy_v/N4. Exact source-body byte binding, argument
-- binding/donation selection, compiler and atomic/coherent16bit visibility are
-- separate boundaries. The source is the CURRENT heap, not precomputed values.
variable {source destination : Nat} {before bodyAfter : HalfMemory.Bytes}
    {threads : List (Fin threadCount)} {events : List VectorCopyInterleaving.Event}
    {eventAfter : VectorCopyInterleaving.Machine}

structure Agreement (source destination : Nat) (allocation : Allocation source destination)
    (before bodyAfter : HalfMemory.Bytes) (eventAfter : VectorCopyInterleaving.Machine) : Prop where
  parsed : VectorCopySyntax.parseBody VectorCopySyntax.sourceBody=some VectorCopySyntax.body
  body_refines : bodyAfter=(copyTrace allocation before).memory
  event_refines : eventAfter.memory=(copyTrace allocation before).memory
  same_heap : bodyAfter=eventAfter.memory
  read : ∀ i : Fin count,
    HalfMemory.load eventAfter.memory (destination+2*i.val)=HalfMemory.load before (source+2*i.val)
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset<size,
    eventAfter.memory (base+offset)=before (base+offset)
  source_retained : ∀ i : Fin count,
    HalfMemory.load eventAfter.memory (source+2*i.val)=HalfMemory.load before (source+2*i.val)

theorem joined (allocation : Allocation source destination)
    (bodyExecution : VectorCopyBodySemantics.Launch source destination threads before bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange threadCount))
    (eventExecution : VectorCopyInterleaving.Executes source destination
      (VectorCopyInterleaving.initial before) events eventAfter)
    (eventCompleted : VectorCopyInterleaving.Completed eventAfter) :
    Agreement source destination allocation before bodyAfter eventAfter where
  parsed := VectorCopySyntax.parsed_body
  body_refines := (VectorCopyBodySemantics.execution_refines allocation bodyExecution bodyCompleted).2
  event_refines := VectorCopyInterleaving.copy_refines allocation eventExecution eventCompleted
  same_heap := ((VectorCopyBodySemantics.execution_refines allocation bodyExecution bodyCompleted).2).trans
    (VectorCopyInterleaving.copy_refines allocation eventExecution eventCompleted).symm
  read := VectorCopyInterleaving.completed_read allocation eventExecution eventCompleted
  frame := fun _ _ region => VectorCopyInterleaving.frame allocation eventExecution region
  source_retained := fun i => ArrayFrame.half_congr before eventAfter.memory source (2*count) (2*i.val)
    (VectorCopyInterleaving.frame allocation eventExecution allocation.fresh) (by have := i.isLt; omega)

theorem from_events (allocation : Allocation source destination)
    (eventExecution : VectorCopyInterleaving.Executes source destination
      (VectorCopyInterleaving.initial before) events eventAfter)
    (eventCompleted : VectorCopyInterleaving.Completed eventAfter) :
    ∃ bodyAfter, VectorCopyBodySemantics.Launch source destination (List.finRange threadCount) before bodyAfter ∧
      Agreement source destination allocation before bodyAfter eventAfter := by
  let bodyExecution := VectorCopyBodySemantics.launch_refines source destination allocation.destinationAligned
    (List.finRange threadCount) before
  exact ⟨_,bodyExecution,joined allocation bodyExecution (List.Perm.refl _) eventExecution eventCompleted⟩

-- Concrete finite completing witnesses require only the allocation and initial
-- heap. No caller supplies a launch, output buffer, or desired output equality.
theorem canonical_agreement (allocation : Allocation source destination) (memory : HalfMemory.Bytes) :
    Agreement source destination allocation memory (run source destination (indices (List.finRange threadCount)) memory)
      (VectorCopyInterleaving.canonicalAfter source destination memory) :=
  joined allocation (VectorCopyBodySemantics.launch_refines _ _ allocation.destinationAligned _ _) (List.Perm.refl _)
    (VectorCopyInterleaving.canonical_execution _ _ _) (VectorCopyInterleaving.canonical_completed _ _ _)

theorem native_cell (thread : Fin threadCount) (offset : Fin 4) :
    (index thread offset).val/4=thread.val ∧ (index thread offset).val%4=offset.val := by
  have := offset.isLt
  dsimp only [index]
  omega

section Attached
variable {values : Fin count → ArrayStorage.BF} (sourceBuffer : ArrayStorage.BFBuffer values)
    (allocation : Allocation sourceBuffer.base destination)
    (bodyExecution : VectorCopyBodySemantics.Launch sourceBuffer.base destination threads sourceBuffer.bytes bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange threadCount))
    (eventExecution : VectorCopyInterleaving.Executes sourceBuffer.base destination
      (VectorCopyInterleaving.initial sourceBuffer.bytes) events eventAfter)
    (eventCompleted : VectorCopyInterleaving.Completed eventAfter)

include bodyExecution bodyCompleted eventExecution eventCompleted in
theorem attached_agreement : Agreement sourceBuffer.base destination allocation sourceBuffer.bytes bodyAfter eventAfter :=
  joined allocation bodyExecution bodyCompleted eventExecution eventCompleted

include allocation bodyExecution bodyCompleted in
theorem body_read (i : Fin count) : HalfMemory.load bodyAfter (destination+2*i.val)=ArrayStorage.bits (values i) :=
  (VectorCopyBodySemantics.execution_read allocation bodyExecution bodyCompleted i).trans (sourceBuffer.attached i)

include bodyExecution bodyCompleted in
theorem body_output_shared : bodyAfter=
    (VectorCopyInterleaving.outputBuffer sourceBuffer allocation eventExecution eventCompleted).bytes :=
  (joined allocation bodyExecution bodyCompleted eventExecution eventCompleted).same_heap

end Attached
end Inference.Kernels.Copy.VectorCopySourceRefinement
