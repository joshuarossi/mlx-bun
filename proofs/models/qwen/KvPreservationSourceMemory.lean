import state.KvSlicePreparationMemory
import kernels.copy.VectorCopySourceRefinement

namespace Inference.Models.Qwen.KvPreservationSourceMemory
open Contracts.Mlx State Kernels.Copy
open KvSlicePreparationMemory
set_option maxRecDepth 10000

variable {before : ByteMemory.Bytes} {source : Nat} (copied : Copy before source)

-- Native donation eligibility is separate. This adapter concerns the allocated
-- contiguous preservation branch; all reads use the exact pre-copy heap.
theorem allocation (sourceAligned : source%2=0) (sourceBounded : source+bytes≤2^64) :
    VectorCopySemantics.Allocation source copied.destination where
  sourceAligned := sourceAligned
  sourceBounded := sourceBounded
  destinationAligned := copied.aligned
  destinationBounded := copied.bounded
  fresh := copied.separate

theorem events_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes≤2^64)
    (execution : VectorCopyInterleaving.Executes source copied.destination
      (VectorCopyInterleaving.initial before) events after)
    (completed : VectorCopyInterleaving.Completed after) : after.memory=copied.memory :=
  VectorCopyInterleaving.trace_eq (allocation copied sourceAligned sourceBounded)
    execution completed copied.trace copied.initial

theorem canonical_events_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes≤2^64) :
    (VectorCopyInterleaving.canonicalAfter source copied.destination before).memory=copied.memory :=
  events_heap copied sourceAligned sourceBounded
    (VectorCopyInterleaving.canonical_execution _ _ _) (VectorCopyInterleaving.canonical_completed _ _ _)

theorem canonical_body_heap (sourceAligned : source%2=0) (sourceBounded : source+bytes≤2^64) :
    VectorCopySemantics.run source copied.destination
      (VectorCopySemantics.indices (List.finRange VectorCopySemantics.threadCount)) before=copied.memory :=
  (VectorCopySourceRefinement.canonical_agreement (allocation copied sourceAligned sourceBounded) before).same_heap.trans
    (canonical_events_heap copied sourceAligned sourceBounded)

end Inference.Models.Qwen.KvPreservationSourceMemory
