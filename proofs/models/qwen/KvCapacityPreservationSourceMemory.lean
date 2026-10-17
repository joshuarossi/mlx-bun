import state.KvSliceCapacityPreparation
import kernels.copy.VectorCopyWideBodySemantics
import kernels.copy.VectorCopyWideSemantics
import kernels.copy.VectorCopyWideInterleaving
namespace Inference.Models.Qwen.KvCapacityPreservationSourceMemory
open Contracts.Mlx State Kernels.Copy KvSliceCapacityPreparation
set_option maxRecDepth 10000
variable {capacity : Nat} {before : ByteMemory.Bytes} {source : Nat} (copied : Copy capacity before source)

theorem allocation (sourceAligned : source%2=0) (sourceBounded : source+bytes capacity≤2^64) :
    VectorCopyWideSemantics.Allocation (blocks:=capacity*256) source copied.destination where
  sourceAligned := sourceAligned
  sourceBounded := sourceBounded
  destinationAligned := copied.aligned
  destinationBounded := copied.bounded
  fresh := copied.separate

theorem events_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes capacity≤2^64)
    (execution : VectorCopyWideInterleaving.Executes (blocks:=capacity*256) source copied.destination
      (VectorCopyWideInterleaving.initial before) events after)
    (completed : VectorCopyWideInterleaving.Completed after) : after.memory=copied.memory :=
  VectorCopyWideInterleaving.trace_eq (allocation copied sourceAligned sourceBounded)
    execution completed copied.trace copied.initial

theorem canonical_events_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes capacity≤2^64) :
    (VectorCopyWideInterleaving.canonicalAfter (blocks:=capacity*256) source copied.destination before).memory=copied.memory :=
  events_heap copied sourceAligned sourceBounded
    (VectorCopyWideInterleaving.canonical_execution _ _ _) (VectorCopyWideInterleaving.canonical_completed _ _ _)

theorem canonical_run_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes capacity≤2^64) :
    VectorCopyWideSemantics.run (blocks:=capacity*256) source copied.destination
      (VectorCopyWideSemantics.indices (List.finRange (capacity*256))) before=copied.memory :=
  (VectorCopyWideSemantics.threads_refine (allocation copied sourceAligned sourceBounded)
    (List.finRange (capacity*256)) (List.Perm.refl _) before).trans
    (VectorCopyWideSemantics.copyTrace_eq (allocation copied sourceAligned sourceBounded) before copied.trace copied.initial)

theorem selected_index_bound (supported : n+1≤262144) : 4*(KvAllocation.capacity (n+1)*256)<2^32 := by
  have bound := KvAllocation.supported_capacity (n+1) supported
  omega

-- The body runs the actual parsed vector grammar; separate-action events may
-- interleave loads/stores more broadly, but their final heap is the same.
theorem body_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes capacity≤2^64)
    (small : 4*(capacity*256)<2^32)
    (execution : VectorCopyWideBodySemantics.Launch (blocks:=capacity*256) source copied.destination threads before after)
    (completed : threads.Perm (List.finRange (capacity*256))) : after=copied.memory :=
  VectorCopyWideBodySemantics.execution_trace_eq small (allocation copied sourceAligned sourceBounded)
    execution completed copied.trace copied.initial

inductive Preservation (capacity source destination : Nat) (before after : ByteMemory.Bytes) : Prop where
  | donated (sameAddress : destination=source) (sameHeap : after=before) : Preservation capacity source destination before after
  | copied (allocation : VectorCopyWideSemantics.Allocation (blocks:=capacity*256) source destination)
      (body : VectorCopyWideBodySemantics.Launch (blocks:=capacity*256) source destination (List.finRange (capacity*256)) before after)
      (events : VectorCopyWideInterleaving.Executes (blocks:=capacity*256) source destination
        (VectorCopyWideInterleaving.initial before) eventList eventAfter)
      (completed : VectorCopyWideInterleaving.Completed eventAfter)
      (shared : eventAfter.memory=after) : Preservation capacity source destination before after

theorem preparation (prepared : Preparation capacity before source) (aligned : source%2=0)
    (bounded : source+bytes capacity≤2^64) (small : 4*(capacity*256)<2^32) :
    Preservation capacity source prepared.destination before prepared.memory := by
  cases prepared with
  | donated => exact .donated rfl rfl
  | copied copied =>
    have body := VectorCopyWideBodySemantics.launch_refines small source copied.destination copied.aligned
      (List.finRange (capacity*256)) before
    rw [canonical_run_heap copied aligned bounded] at body
    exact .copied (allocation copied aligned bounded) body
      (VectorCopyWideInterleaving.canonical_execution _ _ _) (VectorCopyWideInterleaving.canonical_completed _ _ _)
      (canonical_events_heap copied aligned bounded)
end Inference.Models.Qwen.KvCapacityPreservationSourceMemory
