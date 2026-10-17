import kernels.copy.VectorCopyWideBodySemantics
import kernels.copy.VectorCopyWideInterleaving

namespace Inference.Kernels.Copy.VectorCopyWideSourceRefinement
open Contracts.Mlx VectorCopyWideSemantics
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {blocks : Nat}
attribute [local irreducible] copyTrace trace run List.finRange

-- Selected allocated BF16 copy_v/N4. Exact source-body byte binding, argument
-- binding/donation selection, compiler and atomic/coherent16bit visibility are
-- separate boundaries. The source is the CURRENT heap, not precomputed values.
variable (small : 4*blocks<2^32)
variable {source destination : Nat} {before bodyAfter : HalfMemory.Bytes}
    {threads : List (Fin blocks)} {events : List (VectorCopyWideInterleaving.Event (blocks:=blocks))}
    {eventAfter : VectorCopyWideInterleaving.Machine (blocks:=blocks)}

structure Agreement (source destination : Nat) (allocation : Allocation (blocks:=blocks) source destination)
    (before bodyAfter : HalfMemory.Bytes) (eventAfter : VectorCopyWideInterleaving.Machine (blocks:=blocks)) : Prop where
  parsed : VectorCopySyntax.parseBody VectorCopySyntax.sourceBody=some VectorCopySyntax.body
  body_refines : bodyAfter=(copyTrace allocation before).memory
  event_refines : eventAfter.memory=(copyTrace allocation before).memory
  same_heap : bodyAfter=eventAfter.memory
  read : ∀ i : Fin (4*blocks),
    HalfMemory.load eventAfter.memory (destination+2*i.val)=HalfMemory.load before (source+2*i.val)
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*(4*blocks)) base size → ∀ offset<size,
    eventAfter.memory (base+offset)=before (base+offset)
  source_retained : ∀ i : Fin (4*blocks),
    HalfMemory.load eventAfter.memory (source+2*i.val)=HalfMemory.load before (source+2*i.val)

include small in
theorem joined (allocation : Allocation (blocks:=blocks) source destination)
    (bodyExecution : VectorCopyWideBodySemantics.Launch (blocks:=blocks) source destination threads before bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange blocks))
    (eventExecution : VectorCopyWideInterleaving.Executes (blocks:=blocks) source destination
      (VectorCopyWideInterleaving.initial before) events eventAfter)
    (eventCompleted : VectorCopyWideInterleaving.Completed eventAfter) :
    Agreement source destination allocation before bodyAfter eventAfter where
  parsed := VectorCopySyntax.parsed_body
  body_refines := (VectorCopyWideBodySemantics.execution_refines small allocation bodyExecution bodyCompleted).2
  event_refines := VectorCopyWideInterleaving.copy_refines allocation eventExecution eventCompleted
  same_heap := ((VectorCopyWideBodySemantics.execution_refines small allocation bodyExecution bodyCompleted).2).trans
    (VectorCopyWideInterleaving.copy_refines allocation eventExecution eventCompleted).symm
  read := VectorCopyWideInterleaving.completed_read allocation eventExecution eventCompleted
  frame := fun _ _ region => VectorCopyWideInterleaving.frame allocation eventExecution region
  source_retained := fun i => ArrayFrame.half_congr before eventAfter.memory source (2*(4*blocks)) (2*i.val)
    (VectorCopyWideInterleaving.frame allocation eventExecution allocation.fresh) (by have := i.isLt; omega)

include small in
theorem from_events (allocation : Allocation (blocks:=blocks) source destination)
    (eventExecution : VectorCopyWideInterleaving.Executes (blocks:=blocks) source destination
      (VectorCopyWideInterleaving.initial before) events eventAfter)
    (eventCompleted : VectorCopyWideInterleaving.Completed eventAfter) :
    ∃ bodyAfter, VectorCopyWideBodySemantics.Launch (blocks:=blocks) source destination (List.finRange blocks) before bodyAfter ∧
      Agreement source destination allocation before bodyAfter eventAfter := by
  let bodyExecution := VectorCopyWideBodySemantics.launch_refines small source destination allocation.destinationAligned
    (List.finRange blocks) before
  exact ⟨_,bodyExecution,joined small allocation bodyExecution (List.Perm.refl _) eventExecution eventCompleted⟩

-- Concrete finite completing witnesses require only the allocation and initial
-- heap. No caller supplies a launch, output buffer, or desired output equality.
include small in
theorem canonical_agreement (allocation : Allocation (blocks:=blocks) source destination) (memory : HalfMemory.Bytes) :
    Agreement source destination allocation memory (run source destination (indices (List.finRange blocks)) memory)
      (VectorCopyWideInterleaving.canonicalAfter source destination memory) :=
  joined small allocation (VectorCopyWideBodySemantics.launch_refines small _ _ allocation.destinationAligned _ _) (List.Perm.refl _)
    (VectorCopyWideInterleaving.canonical_execution _ _ _) (VectorCopyWideInterleaving.canonical_completed _ _ _)

theorem native_cell (thread : Fin blocks) (offset : Fin 4) :
    (index thread offset).val/4=thread.val ∧ (index thread offset).val%4=offset.val := by
  have := offset.isLt
  dsimp only [index]
  omega

section Attached
variable {values : Fin (4*blocks) → ArrayStorage.BF} (sourceBuffer : ArrayStorage.BFBuffer values)
    (allocation : Allocation (blocks:=blocks) sourceBuffer.base destination)
    (bodyExecution : VectorCopyWideBodySemantics.Launch (blocks:=blocks) sourceBuffer.base destination threads sourceBuffer.bytes bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange blocks))
    (eventExecution : VectorCopyWideInterleaving.Executes (blocks:=blocks) sourceBuffer.base destination
      (VectorCopyWideInterleaving.initial (blocks:=blocks) sourceBuffer.bytes) events eventAfter)
    (eventCompleted : VectorCopyWideInterleaving.Completed eventAfter)

include small bodyExecution bodyCompleted eventExecution eventCompleted in
theorem attached_agreement : Agreement sourceBuffer.base destination allocation sourceBuffer.bytes bodyAfter eventAfter :=
  joined small allocation bodyExecution bodyCompleted eventExecution eventCompleted

include small allocation bodyExecution bodyCompleted in
theorem body_read (i : Fin (4*blocks)) : HalfMemory.load bodyAfter (destination+2*i.val)=ArrayStorage.bits (values i) :=
  (VectorCopyWideBodySemantics.execution_read small allocation bodyExecution bodyCompleted i).trans (sourceBuffer.attached i)

include small bodyExecution bodyCompleted in
theorem body_output_shared : bodyAfter=
    (VectorCopyWideInterleaving.outputBuffer sourceBuffer allocation eventExecution eventCompleted).bytes :=
  (joined small allocation bodyExecution bodyCompleted eventExecution eventCompleted).same_heap

end Attached
end Inference.Kernels.Copy.VectorCopyWideSourceRefinement
