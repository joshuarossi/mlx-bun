import models.qwen.InitialKvSourceMemory
import models.qwen.KvPreservationSourceMemory

namespace Inference.Models.Qwen.KvInitialDispatchMemory
open Contracts.Mlx State Kernels.Copy
open KvSlicePreparationMemory
set_option maxRecDepth 10000
attribute [local irreducible] CopyContiguous.programs Copy2DMemory.programs CopyExecution.Trace.memory

-- Donation is an explicit identity branch, never inferred from handle disposal.
-- The allocated branch carries actual parsed-body and current-heap event runs.
inductive Preservation (source destination : Nat) (before after : ByteMemory.Bytes) : Prop where
  | donated (sameAddress : destination=source) (sameHeap : after=before) : Preservation source destination before after
  | copied (allocation : VectorCopySemantics.Allocation source destination)
      (body : VectorCopyBodySemantics.Launch source destination (List.finRange VectorCopySemantics.threadCount) before after)
      (events : VectorCopyInterleaving.Executes source destination (VectorCopyInterleaving.initial before) eventList eventAfter)
      (completed : VectorCopyInterleaving.Completed eventAfter)
      (shared : eventAfter.memory=after) : Preservation source destination before after

theorem preparation (p : Preparation before source) (aligned : source%2=0)
    (bounded : source+bytes≤2^64) : Preservation source p.destination before p.memory := by
  cases p with
  | donated => exact .donated rfl rfl
  | copied copy =>
    have equal := KvPreservationSourceMemory.canonical_body_heap copy aligned bounded
    have body := VectorCopyBodySemantics.launch_refines source copy.destination copy.aligned
      (List.finRange VectorCopySemantics.threadCount) before
    rw [equal] at body
    exact .copied (KvPreservationSourceMemory.allocation copy aligned bounded) body
      (VectorCopyInterleaving.canonical_execution _ _ _) (VectorCopyInterleaving.canonical_completed _ _ _)
      (KvPreservationSourceMemory.canonical_events_heap copy aligned bounded)

variable {cache : Kv.Cache Kv.BF 0} {key value : KvBytes.Row} (execution : KvInitialPairMemory.Execution cache key value)

def keySlice := KvInitialPairMemory.keys (cache:=cache) execution.zeros execution.allocation execution.keyShared

def valueSlice := KvInitialPairMemory.values (cache:=cache) execution.zeros execution.allocation execution.keyShared execution.valueShared

theorem key_preservation : Preservation execution.layout.keyBase (keySlice execution).preservation.destination
    execution.zeros.memory (keySlice execution).preservation.memory :=
  preparation _ execution.layout.keyAligned execution.layout.keyBound

theorem value_preservation : Preservation execution.layout.valueBase (valueSlice execution).preservation.destination
    (keySlice execution).memory (valueSlice execution).preservation.memory :=
  preparation _ execution.layout.valueAligned execution.layout.valueBound

theorem key_row_starts : (keySlice execution).appended.copy.before=(keySlice execution).preservation.memory :=
  (keySlice execution).appended_before

theorem value_row_starts : (valueSlice execution).appended.copy.before=(valueSlice execution).preservation.memory :=
  (valueSlice execution).appended_before

theorem final_heap : execution.after.memory=(valueSlice execution).appended.copy.memory := rfl

end Inference.Models.Qwen.KvInitialDispatchMemory
