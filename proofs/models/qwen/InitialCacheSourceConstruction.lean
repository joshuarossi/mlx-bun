import models.qwen.InitialScalarConstruction

namespace Inference.Models.Qwen.InitialCacheSourceConstruction
open Contracts.Mlx DecodeStage Kernels.Copy
set_option maxRecDepth 100000
attribute [local irreducible] List.finRange ScalarCopySemantics.run Qwen38TrellisM1Max.Graph.stages

-- Every history invocation is constructed from the scalar on its CURRENT heap.
-- Recurrent initialization is still the existing modeled FP32 schedule. Native
-- scalar creation/upload, dispatch binding, compiler and hardware remain outside
-- this heap construction; no caller supplies per-layer executions or buffers.
def historyMemory (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan) :
    ByteMemory.Bytes := InitialHistorySource.canonicalAfter source plan.layout

def stageMemory (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan) :
    ByteMemory.Bytes := InitialHistorySource.recurrentSuffix plan.layout (after:=historyMemory source plan) plan.trace

theorem historyExecution (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan) :
    ScalarCopyBodySemantics.Launch source.base plan.layout.historyBase (List.finRange ScalarCopySemantics.count)
      source.bytes (historyMemory source plan) := InitialHistorySource.canonical_execution source plan.layout

theorem historyEvents (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan) :
    ScalarCopyInterleaving.Executes source.base plan.layout.historyBase (ScalarCopyInterleaving.initial source.bytes)
      ((List.finRange ScalarCopySemantics.count).flatMap ScalarCopyInterleaving.threadEvents)
      (ScalarCopyInterleaving.canonicalAfter source.base plan.layout.historyBase source.bytes) :=
  ScalarCopyInterleaving.canonical_execution _ _ _

theorem historyCompleted (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan) :
    ScalarCopyInterleaving.Completed (ScalarCopyInterleaving.canonicalAfter source.base plan.layout.historyBase source.bytes) :=
  ScalarCopyInterleaving.canonical_completed _ _ _

variable (source : ArrayStorage.BFBuffer InitialStorage.historyZero) (plan : InitialCacheMemory.DeltaPlan)
    (safe : MemoryRegions.Disjoint plan.layout.historyBase 61440 source.base 2 ∧
      MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 source.base 2)

include safe in
theorem stage_eq : stageMemory source plan=InitialStorageRegions.memory plan.trace plan.layout source.bytes :=
  InitialHistorySource.initializer_memory_eq source plan.layout safe.1
    (historyExecution source plan) (List.Perm.refl _) plan.trace

include safe in
theorem stage_frame (historySeparate : MemoryRegions.Disjoint plan.layout.historyBase 61440 other size)
    (recurrentSeparate : MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 other size)
    (offset : Nat) (bound : offset<size) : stageMemory source plan (other+offset)=source.bytes (other+offset) :=
  InitialHistorySource.recurrentSuffix_frame source plan.layout safe.1 (historyExecution source plan)
    plan.trace historySeparate recurrentSeparate offset bound

def afterStage : ArrayStorage.BFBuffer InitialStorage.historyZero :=
  ArrayFrame.bf source (stageMemory source plan) (stage_frame source plan safe safe.1 safe.2)

theorem afterStage_base : (afterStage source plan safe).base=source.base := rfl
theorem afterStage_bytes : (afterStage source plan safe).bytes=stageMemory source plan := rfl

-- The scalar reattachment above is derived through actual writes. Each recursive
-- call consumes that exact buffer and heap, with the same physical scalar base.
def run : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) →
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero) →
    TokenInitializationMemory.CacheSafe stages plan source.base 2 → ArrayStorage.BFBuffer InitialStorage.historyZero
  | [], _, source, _ => source
  | .delta _::rest, plan, source, safe =>
      run rest plan.2 (afterStage source plan.1 safe.1) safe.2
  | .attention _::rest, plan, source, safe => run rest plan.2 source safe.2

theorem run_base (stages : List Stage) (plan : InitialCacheMemory.Plan stages)
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (safe : TokenInitializationMemory.CacheSafe stages plan source.base 2) :
    (run stages plan source safe).base=source.base := by
  induction stages generalizing source with
  | nil => rfl
  | cons stage rest ih =>
      cases stage with
      | delta _ => exact (ih _ _ _).trans (afterStage_base source plan.1 safe.1)
      | attention _ => exact ih _ _ _

theorem run_eq (stages : List Stage) (plan : InitialCacheMemory.Plan stages)
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (safe : TokenInitializationMemory.CacheSafe stages plan source.base 2) :
    (run stages plan source safe).bytes=InitialCacheMemory.execute stages plan source.bytes := by
  induction stages generalizing source with
  | nil => rfl
  | cons stage rest ih =>
      cases stage with
      | delta _ =>
          exact (ih _ _ _).trans (congrArg (InitialCacheMemory.execute rest plan.2) (stage_eq source plan.1 safe.1))
      | attention _ => exact ih _ _ _

structure HistoryChecked (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (plan : InitialCacheMemory.DeltaPlan)
    (safe : MemoryRegions.Disjoint plan.layout.historyBase 61440 source.base 2 ∧
      MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 source.base 2) : Prop where
  body : ScalarCopyBodySemantics.Launch source.base plan.layout.historyBase (List.finRange ScalarCopySemantics.count)
    source.bytes (historyMemory source plan)
  events : ScalarCopyInterleaving.Executes source.base plan.layout.historyBase (ScalarCopyInterleaving.initial source.bytes)
    ((List.finRange ScalarCopySemantics.count).flatMap ScalarCopyInterleaving.threadEvents)
    (ScalarCopyInterleaving.canonicalAfter source.base plan.layout.historyBase source.bytes)
  completed : ScalarCopyInterleaving.Completed
    (ScalarCopyInterleaving.canonicalAfter source.base plan.layout.historyBase source.bytes)
  agreement : ScalarCopySourceRefinement.Agreement source.base plan.layout.historyBase
    (InitialHistorySource.allocation source plan.layout safe.1) source.bytes (historyMemory source plan)
    (ScalarCopyInterleaving.canonicalAfter source.base plan.layout.historyBase source.bytes)

theorem history_checked (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (plan : InitialCacheMemory.DeltaPlan)
    (safe : MemoryRegions.Disjoint plan.layout.historyBase 61440 source.base 2 ∧
      MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 source.base 2) : HistoryChecked source plan safe where
  body := historyExecution source plan
  events := historyEvents source plan
  completed := historyCompleted source plan
  agreement := ScalarCopySourceRefinement.joined (InitialHistorySource.allocation source plan.layout safe.1)
    (historyExecution source plan) (List.Perm.refl _) (historyEvents source plan) (historyCompleted source plan)

-- Recursive evidence for all constructed parsed-body launches and their matching
-- completed separate-action executions, not a family of caller witnesses.
def Checked : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) →
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero) →
    TokenInitializationMemory.CacheSafe stages plan source.base 2 → Prop
  | [], _, _, _ => True
  | .delta _::rest, plan, source, safe =>
      HistoryChecked source plan.1 safe.1 ∧
      Checked rest plan.2 (afterStage source plan.1 safe.1) safe.2
  | .attention _::rest, plan, source, safe => Checked rest plan.2 source safe.2

theorem checked (stages : List Stage) (plan : InitialCacheMemory.Plan stages)
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (safe : TokenInitializationMemory.CacheSafe stages plan source.base 2) : Checked stages plan source safe := by
  induction stages generalizing source with
  | nil => trivial
  | cons stage rest ih =>
      cases stage with
      | delta _ =>
          exact ⟨history_checked source plan.1 safe.1, ih _ _ _⟩
      | attention _ => exact ih _ _ _

theorem run_frame (stages : List Stage) (plan : InitialCacheMemory.Plan stages)
    (source : ArrayStorage.BFBuffer InitialStorage.historyZero)
    (safe : TokenInitializationMemory.CacheSafe stages plan source.base 2)
    (protectedRegions : TokenInitializationMemory.CacheSafe stages plan other size)
    (offset : Nat) (bound : offset<size) :
    (run stages plan source safe).bytes (other+offset)=source.bytes (other+offset) := by
  rw [run_eq]
  exact TokenInitializationMemory.cache_frame stages plan source.bytes protectedRegions offset bound

section Workspace
variable {p : TokenInference.Pipeline} {token : Fin 248320}
    (scalars : InitialScalarConstruction.Workspace) (initialHeap : ByteMemory.Bytes)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages)
      scalars.base InitialScalarConstruction.bytes)

def entryScalar : ArrayStorage.BFBuffer InitialStorage.historyZero :=
  scalars.historyAfterToken initialHeap (token:=token) w separate

theorem sourceSafe : TokenInitializationMemory.CacheSafe p.graph.stages w.caches
    (entryScalar scalars initialHeap w separate (token:=token)).base 2 := by
  rw [show (entryScalar scalars initialHeap w separate (token:=token)).base=scalars.base from
    scalars.historyAfterToken_base initialHeap w separate]
  exact w.cache_safe (scalars.tokenWorkspaceFresh initialHeap w separate)

def initializedScalar : ArrayStorage.BFBuffer InitialStorage.historyZero :=
  run p.graph.stages w.caches (entryScalar scalars initialHeap w separate (token:=token))
    (sourceSafe scalars initialHeap w separate)

theorem initialize_eq : (initializedScalar scalars initialHeap w separate (token:=token)).bytes=
    (w.plan (token:=token) (initialHeap:=scalars.memory initialHeap)).memory :=
  (run_eq p.graph.stages w.caches _ (sourceSafe scalars initialHeap w separate)).trans
    (congrArg (InitialCacheMemory.execute p.graph.stages w.caches)
      (scalars.historyAfterToken_bytes initialHeap w separate))

theorem initialize_checked : Checked p.graph.stages w.caches
    (entryScalar scalars initialHeap w separate (token:=token)) (sourceSafe scalars initialHeap w separate) :=
  checked _ _ _ _

theorem initialize_frame
    (scalarSafe : MemoryRegions.Disjoint scalars.base InitialScalarConstruction.bytes other size)
    (cacheSafe : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) other size)
    (offset : Nat) (bound : offset<size) :
    (initializedScalar scalars initialHeap w separate (token:=token)).bytes (other+offset)=initialHeap (other+offset) :=
  (run_frame p.graph.stages w.caches _ (sourceSafe scalars initialHeap w separate)
    (w.cache_safe cacheSafe) offset bound).trans
    (scalars.prefix_other_region initialHeap w separate scalarSafe cacheSafe offset bound)

def parameters (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (fun base size =>
      MemoryRegions.Disjoint scalars.base InitialScalarConstruction.bytes base size ∧
      MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) base size)) :
    TokenParameterMemory.Storage p (initializedScalar scalars initialHeap w separate (token:=token)).bytes :=
  original.reframe _ (original.protected_mono
    (fun _ _ region => initialize_frame scalars initialHeap w separate region.1 region.2) safe)

theorem parameters_regions (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (fun base size =>
      MemoryRegions.Disjoint scalars.base InitialScalarConstruction.bytes base size ∧
      MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) base size))
    (property : Nat → Nat → Prop) :
    (parameters scalars initialHeap w separate (token:=token) original safe).Protected property ↔ original.Protected property :=
  original.reframe_protected _ _ property

theorem initialized_state_heap :
    (w.plan (token:=token) (initialHeap:=scalars.memory initialHeap)).state.index.bytes=
      (initializedScalar scalars initialHeap w separate (token:=token)).bytes :=
  (initialize_eq scalars initialHeap w separate).symm

-- Qwen's existing graph count identifies all48 Delta launches in this recursive
-- constructor. Attention stages have empty KV and introduce no zero-copy stores.
theorem history_launch_count : TokenInitializationAllocation.deltaCount p.graph.stages=48 :=
  TokenInitializationAllocation.graph_delta_count p.graph

end Workspace
end Inference.Models.Qwen.InitialCacheSourceConstruction
