import kernels.copy.ScalarCopyQuadBodySemantics
import kernels.copy.ScalarCopyQuadInterleaving

namespace Inference.Kernels.Copy.ScalarCopyQuadSourceRefinement
open Contracts.Mlx ScalarCopyQuadSemantics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] ScalarCopyQuadSemantics.trace ScalarCopyQuadSemantics.copyTrace ScalarCopyQuadSemantics.run List.finRange

-- The selected BF16/N4 specialization of the exact parsed copy_s body.
-- Host extraction/header binding, template/dispatch selection, compiler and
-- atomic/coherent16-bit access/visibility remain explicit external boundaries.
variable {source destination : Nat} {before bodyAfter : HalfMemory.Bytes}
  {threads : List (Fin threadCount)} {events : List ScalarCopyQuadInterleaving.Event}
  {eventAfter : ScalarCopyQuadInterleaving.Machine}

theorem launch_refines (allocation : Allocation source destination)
    (execution : ScalarCopyQuadBodySemantics.Launch source destination threads before bodyAfter)
    (completed : threads.Perm (List.finRange threadCount)) : bodyAfter=(copyTrace allocation before).memory := by
  apply heap_eq destination count before _ _ (HalfMemory.load before source)
  · exact ScalarCopyQuadBodySemantics.execution_read allocation execution completed
  · exact (copyTrace allocation before).read_correct
  · intro b s separate o bound
    exact ScalarCopyQuadBodySemantics.execution_frame allocation execution separate o bound
  · intro b s separate o bound
    exact (copy_frame (copyTrace allocation before) separate o bound).trans
      (congrFun (copyTrace_before allocation before) _)

structure Agreement (source destination : Nat) (allocation : Allocation source destination)
    (before bodyAfter : HalfMemory.Bytes) (eventAfter : ScalarCopyQuadInterleaving.Machine) : Prop where
  parsed : ScalarCopySyntax.parseBody ScalarCopySyntax.sourceBody=some ScalarCopySyntax.body
  body_refines : bodyAfter=(copyTrace allocation before).memory
  event_refines : eventAfter.memory=(copyTrace allocation before).memory
  same_heap : bodyAfter=eventAfter.memory
  read : ∀ i : Fin count, HalfMemory.load eventAfter.memory (destination+2*i.val)=HalfMemory.load before source
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset<size,
    eventAfter.memory (base+offset)=before (base+offset)
  source_retained : HalfMemory.load eventAfter.memory source=HalfMemory.load before source

theorem joined (allocation : Allocation source destination)
    (bodyExecution : ScalarCopyQuadBodySemantics.Launch source destination threads before bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange threadCount))
    (eventExecution : ScalarCopyQuadInterleaving.Executes source destination
      (ScalarCopyQuadInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyQuadInterleaving.Completed eventAfter) :
    Agreement source destination allocation before bodyAfter eventAfter where
  parsed := ScalarCopySyntax.parsed_body
  body_refines := launch_refines allocation bodyExecution bodyCompleted
  event_refines := ScalarCopyQuadInterleaving.copy_refines allocation eventExecution eventCompleted
  same_heap := (launch_refines allocation bodyExecution bodyCompleted).trans
    (ScalarCopyQuadInterleaving.copy_refines allocation eventExecution eventCompleted).symm
  read := ScalarCopyQuadInterleaving.completed_read allocation eventExecution eventCompleted
  frame := fun _ _ separate => ScalarCopyQuadInterleaving.frame allocation eventExecution separate
  source_retained := ArrayFrame.half_congr before eventAfter.memory source 2 0
    (ScalarCopyQuadInterleaving.frame allocation eventExecution allocation.fresh) (by decide)

-- Construct the parsed body launch representative from just an arbitrary valid
-- completed separate-event schedule. No whole-thread atomicity premise.
theorem from_events (allocation : Allocation source destination)
    (eventExecution : ScalarCopyQuadInterleaving.Executes source destination
      (ScalarCopyQuadInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyQuadInterleaving.Completed eventAfter) :
    ∃ after, ScalarCopyQuadBodySemantics.Launch source destination (List.finRange threadCount) before after ∧
      Agreement source destination allocation before after eventAfter :=
  ⟨_,ScalarCopyQuadBodySemantics.launch_refines source destination allocation.destinationAligned _ before,
    joined allocation (ScalarCopyQuadBodySemantics.launch_refines source destination allocation.destinationAligned _ before)
      (List.Perm.refl _) eventExecution eventCompleted⟩

-- KV zero slabs use exactly this shape and actual initial zero scalar.
def zeroTrace (destination : Nat) (before : HalfMemory.Bytes) (aligned : destination%2=0) :
    CopyContiguous.Trace (blocks:=65536) destination (fun _ => (0 : BitVec 16)) :=
  CopyContiguous.Trace.canonical destination _ before aligned

theorem zeroTrace_before (destination : Nat) (before : HalfMemory.Bytes) (aligned : destination%2=0) :
    (zeroTrace destination before aligned).before=before := rfl
attribute [local irreducible] zeroTrace

-- This also identifies ANY completed old zero trace on the SAME initial heap,
-- not merely our selected schedule, with the actual source-backed execution.
theorem events_zero_eq (allocation : Allocation source destination)
    (eventExecution : ScalarCopyQuadInterleaving.Executes source destination
      (ScalarCopyQuadInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyQuadInterleaving.Completed eventAfter)
    (rawZero : HalfMemory.load before source=0)
    (old : CopyContiguous.Trace (blocks:=65536) destination (fun _ => (0 : BitVec 16)))
    (same : old.before=before) : eventAfter.memory=old.memory := by
  apply heap_eq destination count before _ _ 0
  · intro i
    exact (ScalarCopyQuadInterleaving.completed_read allocation eventExecution eventCompleted i).trans rawZero
  · exact old.read_correct
  · intro b s separate o bound
    exact ScalarCopyQuadInterleaving.frame allocation eventExecution separate o bound
  · intro b s separate o bound
    exact (copy_frame old separate o bound).trans (congrFun same _)

def zeroValues : Fin 1 → ArrayStorage.BF := fun _ => Model.zero FloatFormat.bfloat16 false

structure Checked (scalar : ArrayStorage.BFBuffer zeroValues)
    (destination : Nat) (allocation : Allocation scalar.base destination) where
  bodyAfter : HalfMemory.Bytes
  bodyExecution : ScalarCopyQuadBodySemantics.Launch scalar.base destination (List.finRange threadCount) scalar.bytes bodyAfter
  eventAfter : ScalarCopyQuadInterleaving.Machine
  events : List ScalarCopyQuadInterleaving.Event
  eventExecution : ScalarCopyQuadInterleaving.Executes scalar.base destination
    (ScalarCopyQuadInterleaving.initial scalar.bytes) events eventAfter
  eventCompleted : ScalarCopyQuadInterleaving.Completed eventAfter
  agreement : Agreement scalar.base destination allocation scalar.bytes bodyAfter eventAfter
  zero_eq : eventAfter.memory=(zeroTrace destination scalar.bytes allocation.destinationAligned).memory

private theorem zero_bits : ArrayStorage.bits (zeroValues 0)=0 := by decide +kernel

theorem scalar_zero (scalar : ArrayStorage.BFBuffer zeroValues) :
    HalfMemory.load scalar.bytes scalar.base=0 := by
  have h := scalar.attached (0 : Fin 1)
  simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero,zero_bits] using h

def canonical (scalar : ArrayStorage.BFBuffer zeroValues)
    (destination : Nat) (allocation : Allocation scalar.base destination) : Checked scalar destination allocation where
  bodyAfter := run scalar.base destination (indices (List.finRange threadCount)) scalar.bytes
  bodyExecution := ScalarCopyQuadBodySemantics.launch_refines _ _ allocation.destinationAligned _ _
  eventAfter := ScalarCopyQuadInterleaving.canonicalAfter scalar.base destination scalar.bytes
  events := (List.finRange count).flatMap ScalarCopyQuadInterleaving.threadEvents
  eventExecution := ScalarCopyQuadInterleaving.canonical_execution _ _ _
  eventCompleted := ScalarCopyQuadInterleaving.canonical_completed _ _ _
  agreement := joined allocation (ScalarCopyQuadBodySemantics.launch_refines _ _ allocation.destinationAligned _ _)
    (List.Perm.refl _) (ScalarCopyQuadInterleaving.canonical_execution _ _ _) (ScalarCopyQuadInterleaving.canonical_completed _ _ _)
  zero_eq := events_zero_eq allocation (ScalarCopyQuadInterleaving.canonical_execution _ _ _)
    (ScalarCopyQuadInterleaving.canonical_completed _ _ _) (scalar_zero scalar) _ (zeroTrace_before _ _ _)

end Inference.Kernels.Copy.ScalarCopyQuadSourceRefinement
