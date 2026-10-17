import kernels.copy.ScalarCopyBodySemantics
import kernels.copy.ScalarCopyInterleaving

namespace Inference.Kernels.Copy.ScalarCopySourceRefinement
open Contracts.Mlx ScalarCopySemantics
set_option maxRecDepth 10000

-- This joins the parsed selected BF16/N=1 body semantics and its separate
-- load/store event abstraction. The host byte-binding check, template/dispatch
-- selection, compiler correctness, and Metal visibility are external boundaries.
variable {source destination : Nat} {before bodyAfter : HalfMemory.Bytes}
  {threads : List (Fin count)} {events : List ScalarCopyInterleaving.Event}
  {eventAfter : ScalarCopyInterleaving.Machine}

-- Any completed parsed-body launch, not only the exhibited canonical run.
theorem launch_refines (allocation : Allocation source destination)
    (execution : ScalarCopyBodySemantics.Launch source destination threads before bodyAfter)
    (completed : threads.Perm (List.finRange count)) : bodyAfter=(trace allocation before).memory := by
  funext address
  by_cases inside : destination≤address ∧ address<destination+2*count
  · let thread : Fin count := ⟨(address-destination)/2,by omega⟩
    let offset := (address-destination)%2
    have bound : offset<2 := by dsimp [offset]; omega
    have atAddress : destination+2*thread.val+offset=address := by dsimp [thread,offset]; omega
    have left := congrArg (fun word => HalfMemory.byte word offset)
      (ScalarCopyBodySemantics.execution_read allocation execution completed thread)
    have right := congrArg (fun word => HalfMemory.byte word offset)
      ((trace allocation before).read_correct thread)
    rw [HalfMemory.byte_load _ _ _ bound] at left right
    rw [← atAddress]
    exact left.trans right.symm
  · have outside : MemoryRegions.Disjoint destination (2*count) address 1 := by
      unfold MemoryRegions.Disjoint
      omega
    have left := ScalarCopyBodySemantics.execution_frame allocation execution outside 0 (by decide)
    have right := ScalarCopySemantics.frame allocation (List.finRange count) before outside 0 (by decide)
    rw [canonical_refines allocation before] at right
    simpa only [Nat.add_zero] using left.trans right.symm

structure Agreement (source destination : Nat) (allocation : Allocation source destination) (before bodyAfter : HalfMemory.Bytes)
    (eventAfter : ScalarCopyInterleaving.Machine) : Prop where
  parsed : ScalarCopySyntax.parseBody ScalarCopySyntax.sourceBody=some ScalarCopySyntax.body
  body_refines : bodyAfter=(trace allocation before).memory
  event_refines : eventAfter.memory=(trace allocation before).memory
  same_heap : bodyAfter=eventAfter.memory
  read : ∀ thread : Fin count,
    HalfMemory.load eventAfter.memory (destination+2*thread.val)=HalfMemory.load before source
  frame : ∀ base size, MemoryRegions.Disjoint destination (2*count) base size → ∀ offset < size,
    eventAfter.memory (base+offset)=before (base+offset)
  source_retained : HalfMemory.load eventAfter.memory source=HalfMemory.load before source

-- All result equalities are derived from the two execution relations and their
-- completion conditions. Neither execution receives the desired scalar value.
theorem joined (allocation : Allocation source destination)
    (bodyExecution : ScalarCopyBodySemantics.Launch source destination threads before bodyAfter)
    (bodyCompleted : threads.Perm (List.finRange count))
    (eventExecution : ScalarCopyInterleaving.Executes source destination
      (ScalarCopyInterleaving.initial before) events eventAfter)
    (eventCompleted : ScalarCopyInterleaving.Completed eventAfter) :
    Agreement (allocation:=allocation) source destination before bodyAfter eventAfter where
  parsed := ScalarCopySyntax.parsed_body
  body_refines := launch_refines allocation bodyExecution bodyCompleted
  event_refines := ScalarCopyInterleaving.refines allocation eventExecution eventCompleted
  same_heap := (launch_refines allocation bodyExecution bodyCompleted).trans
    (ScalarCopyInterleaving.refines allocation eventExecution eventCompleted).symm
  read := ScalarCopyInterleaving.completed_read allocation eventExecution eventCompleted
  frame := fun _ _ separate => ScalarCopyInterleaving.frame allocation eventExecution separate
  source_retained := ArrayFrame.half_congr before eventAfter.memory source 2 0
    (ScalarCopyInterleaving.frame allocation eventExecution allocation.fresh) (by decide)

-- An isolated load/store pair has the same heap effect as executing the full
-- parsed specialization body from that thread's current heap.
theorem isolated_pair (allocation : Allocation source destination) (memory : HalfMemory.Bytes) (thread : Fin count) :
    ScalarCopySyntax.parseBody ScalarCopySyntax.sourceBody=some ScalarCopySyntax.body ∧
    ScalarCopyBodySemantics.Statements source destination ScalarCopySyntax.body
      (ScalarCopyBodySemantics.initial memory thread) (ScalarCopyBodySemantics.final source destination memory thread) ∧
    ScalarCopyInterleaving.Executes source destination (ScalarCopyInterleaving.initial memory)
      (ScalarCopyInterleaving.threadEvents thread)
      (ScalarCopyInterleaving.finishThread source destination (ScalarCopyInterleaving.initial memory) thread) ∧
    (ScalarCopyInterleaving.finishThread source destination (ScalarCopyInterleaving.initial memory) thread).memory=
      (ScalarCopyBodySemantics.final source destination memory thread).memory := by
  refine ⟨ScalarCopySyntax.parsed_body,ScalarCopyBodySemantics.body_execution source destination allocation.destinationAligned memory thread,
    ScalarCopyInterleaving.finishThread_exec thread _ rfl,?_⟩
  change HalfMemory.store memory (destination+2*thread.val) (HalfMemory.load memory source)=
    HalfMemory.execute [event source destination memory thread] memory
  dsimp only [HalfMemory.execute]
  rw [(event_address allocation memory thread).1]
  rfl

section Attached
variable {value : ArrayStorage.BF} (scalar : ArrayStorage.BFBuffer (fun _ : Fin 1 => value))
  (allocation : Allocation scalar.base destination)
  (bodyExecution : ScalarCopyBodySemantics.Launch scalar.base destination threads scalar.bytes bodyAfter)
  (bodyCompleted : threads.Perm (List.finRange count))
  (eventExecution : ScalarCopyInterleaving.Executes scalar.base destination
    (ScalarCopyInterleaving.initial scalar.bytes) events eventAfter)
  (eventCompleted : ScalarCopyInterleaving.Completed eventAfter)

-- The source is the original attached buffer on the actual executing heap.
include bodyExecution bodyCompleted eventExecution eventCompleted in
theorem attached_agreement : Agreement (allocation:=allocation) scalar.base destination scalar.bytes bodyAfter eventAfter :=
  joined allocation bodyExecution bodyCompleted eventExecution eventCompleted

include allocation bodyExecution bodyCompleted in
theorem body_read (thread : Fin count) : HalfMemory.load bodyAfter (destination+2*thread.val)=ArrayStorage.bits value :=
  (ScalarCopyBodySemantics.execution_read allocation bodyExecution bodyCompleted thread).trans
    (by simpa only [Fin.val_zero,Nat.mul_zero,Nat.add_zero] using scalar.attached (0 : Fin 1))

include bodyExecution bodyCompleted in
theorem body_output_shared : bodyAfter=
    (ScalarCopyInterleaving.outputBuffer scalar allocation eventExecution eventCompleted).bytes :=
  (joined allocation bodyExecution bodyCompleted eventExecution eventCompleted).same_heap

end Attached
end Inference.Kernels.Copy.ScalarCopySourceRefinement
