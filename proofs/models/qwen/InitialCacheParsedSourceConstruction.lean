import models.qwen.InitialRecurrentSource
import models.qwen.InitialCacheSourceConstruction

namespace Inference.Models.Qwen.InitialCacheParsedSourceConstruction
open Contracts.Mlx DecodeStage Kernels.Copy
set_option maxRecDepth 100000
attribute [local irreducible] List.finRange ScalarCopySemantics.run ScalarCopyFloatSemantics.run
  InitialHistorySource.canonicalAfter InitialRecurrentSource.canonicalAfter Qwen38TrellisM1Max.Graph.stages

-- This constructs executions in the selected parsed-body/event models, not
-- native allocator/upload/compiler/hardware correctness. BF16 uses N=1; FP32
-- uses N=2. Both finite completed event schedules are derived, never inputs.

-- These are both original source buffers on ONE heap. The extra raw FP32
-- attachment is intentionally stronger than FloatBuffer's decode attachment.
structure Sources where
  history : ArrayStorage.BFBuffer InitialStorage.historyZero
  recurrent : ArrayStorage.FloatBuffer InitialStorage.recurrentZero
  shared : recurrent.bytes=history.bytes
  raw : ByteMemory.load32 history.bytes recurrent.base=0

def Sources.reframe (s : Sources) (memory : ByteMemory.Bytes)
    (historySame : ∀ offset<2, memory (s.history.base+offset)=s.history.bytes (s.history.base+offset))
    (recurrentSame : ∀ offset<4, memory (s.recurrent.base+offset)=s.history.bytes (s.recurrent.base+offset)) : Sources where
  history := ArrayFrame.bf s.history memory historySame
  recurrent := ArrayFrame.fp s.recurrent memory (fun offset bound =>
    (recurrentSame offset bound).trans (congrFun s.shared _).symm)
  shared := rfl
  raw := by
    have equal := ArrayFrame.word_congr s.history.bytes memory s.recurrent.base 4 0 recurrentSame (by omega)
    have preserved : ByteMemory.load32 memory s.recurrent.base=ByteMemory.load32 s.history.bytes s.recurrent.base := by
      simpa only [Nat.add_zero] using equal
    exact preserved.trans s.raw

theorem Sources.reframe_history_base (s : Sources) (memory : ByteMemory.Bytes) (hs rs) :
    (s.reframe memory hs rs).history.base=s.history.base := rfl
theorem Sources.reframe_recurrent_base (s : Sources) (memory : ByteMemory.Bytes) (hs rs) :
    (s.reframe memory hs rs).recurrent.base=s.recurrent.base := rfl
theorem Sources.reframe_history_bytes (s : Sources) (memory : ByteMemory.Bytes) (hs rs) :
    (s.reframe memory hs rs).history.bytes=memory := rfl
theorem Sources.reframe_recurrent_bytes (s : Sources) (memory : ByteMemory.Bytes) (hs rs) :
    (s.reframe memory hs rs).recurrent.bytes=memory := rfl

def StageSafe (s : Sources) (plan : InitialCacheMemory.DeltaPlan) : Prop :=
  (MemoryRegions.Disjoint plan.layout.historyBase 61440 s.history.base 2 ∧
    MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 s.history.base 2) ∧
  (MemoryRegions.Disjoint plan.layout.historyBase 61440 s.recurrent.base 4 ∧
    MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 s.recurrent.base 4)

def historyMemory (s : Sources) (plan : InitialCacheMemory.DeltaPlan) : ByteMemory.Bytes :=
  InitialHistorySource.canonicalAfter s.history plan.layout

def afterHistory (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) : Sources :=
  s.reframe (historyMemory s plan)
    (InitialHistorySource.other_region s.history plan.layout safe.1.1
      (InitialHistorySource.canonical_execution s.history plan.layout) safe.1.1)
    (InitialHistorySource.other_region s.history plan.layout safe.1.1
      (InitialHistorySource.canonical_execution s.history plan.layout) safe.2.1)

theorem afterHistory_history_base (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterHistory s plan safe).history.base=s.history.base := Sources.reframe_history_base s _ _ _
theorem afterHistory_recurrent_base (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterHistory s plan safe).recurrent.base=s.recurrent.base := Sources.reframe_recurrent_base s _ _ _
theorem afterHistory_recurrent_bytes (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterHistory s plan safe).recurrent.bytes=historyMemory s plan := Sources.reframe_recurrent_bytes s _ _ _
attribute [local irreducible] afterHistory

def stageMemory (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) : ByteMemory.Bytes :=
  InitialRecurrentSource.canonicalAfter (afterHistory s plan safe).recurrent plan.layout

theorem Sources.raw_recurrent (s : Sources) : ByteMemory.load32 s.recurrent.bytes s.recurrent.base=0 :=
  (congrArg (fun memory => ByteMemory.load32 memory s.recurrent.base) s.shared).trans s.raw

def afterRecurrent (middle : Sources) (layout : InitialStorageRegions.Layout)
    (safe : MemoryRegions.Disjoint layout.recurrentBase 3145728 middle.history.base 2 ∧
      MemoryRegions.Disjoint layout.recurrentBase 3145728 middle.recurrent.base 4) : Sources :=
  middle.reframe (InitialRecurrentSource.canonicalAfter middle.recurrent layout)
    (fun offset bound => (InitialRecurrentSource.other_region middle.recurrent layout safe.2
      (InitialRecurrentSource.canonical_execution middle.recurrent layout) safe.1 offset bound).trans (congrFun middle.shared _))
    (fun offset bound => (InitialRecurrentSource.other_region middle.recurrent layout safe.2
      (InitialRecurrentSource.canonical_execution middle.recurrent layout) safe.2 offset bound).trans (congrFun middle.shared _))

theorem afterRecurrent_history_base (middle : Sources) (layout : InitialStorageRegions.Layout) (safe) :
    (afterRecurrent middle layout safe).history.base=middle.history.base := Sources.reframe_history_base middle _ _ _
theorem afterRecurrent_recurrent_base (middle : Sources) (layout : InitialStorageRegions.Layout) (safe) :
    (afterRecurrent middle layout safe).recurrent.base=middle.recurrent.base := Sources.reframe_recurrent_base middle _ _ _
theorem afterRecurrent_history_bytes (middle : Sources) (layout : InitialStorageRegions.Layout) (safe) :
    (afterRecurrent middle layout safe).history.bytes=InitialRecurrentSource.canonicalAfter middle.recurrent layout := Sources.reframe_history_bytes middle _ _ _
attribute [local irreducible] afterRecurrent

def afterStage (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) : Sources :=
  afterRecurrent (afterHistory s plan safe) plan.layout
    ⟨Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 base 2)
        (afterHistory_history_base s plan safe)) safe.1.2,
      Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 base 4)
        (afterHistory_recurrent_base s plan safe)) safe.2.2⟩

theorem afterStage_history_base (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterStage s plan safe).history.base=s.history.base :=
  (afterRecurrent_history_base _ _ _).trans (afterHistory_history_base s plan safe)
theorem afterStage_recurrent_base (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterStage s plan safe).recurrent.base=s.recurrent.base :=
  (afterRecurrent_recurrent_base _ _ _).trans (afterHistory_recurrent_base s plan safe)
theorem afterStage_history_bytes (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterStage s plan safe).history.bytes=stageMemory s plan safe := afterRecurrent_history_bytes _ _ _
attribute [local irreducible] afterStage

theorem stage_eq (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    stageMemory s plan safe=InitialStorageRegions.memory plan.trace plan.layout s.history.bytes := by
  have recurrent := InitialRecurrentSource.canonical_afterRecurrent_eq (afterHistory s plan safe).recurrent
    plan.layout (Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint plan.layout.recurrentBase 3145728 base 4)
      (afterHistory_recurrent_base s plan safe)) safe.2.2) (afterHistory s plan safe).raw_recurrent plan.trace
  have history := InitialHistorySource.canonical_afterHistory_eq s.history plan.layout safe.1.1 plan.trace
  rw [afterHistory_recurrent_bytes] at recurrent
  exact recurrent.trans (congrArg (ByteMemory.execute (InitialStorageRegions.recurrentStores plan.trace plan.layout)) history)

def Safe (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) : Prop :=
  TokenInitializationMemory.CacheSafe stages plan s.history.base 2 ∧
  TokenInitializationMemory.CacheSafe stages plan s.recurrent.base 4

theorem safe_rebase {stages : List Stage} {plan : InitialCacheMemory.Plan stages} {s next : Sources}
    (historyBase : next.history.base=s.history.base) (recurrentBase : next.recurrent.base=s.recurrent.base)
    (safe : Safe stages plan s) : Safe stages plan next :=
  ⟨Eq.mpr (congrArg (fun base => TokenInitializationMemory.CacheSafe stages plan base 2) historyBase) safe.1,
    Eq.mpr (congrArg (fun base => TokenInitializationMemory.CacheSafe stages plan base 4) recurrentBase) safe.2⟩

theorem afterStage_eq (s : Sources) (plan : InitialCacheMemory.DeltaPlan) (safe : StageSafe s plan) :
    (afterStage s plan safe).history.bytes=InitialStorageRegions.memory plan.trace plan.layout s.history.bytes :=
  (afterStage_history_bytes s plan safe).trans (stage_eq s plan safe)

inductive Executes : (stages : List Stage) → InitialCacheMemory.Plan stages → Sources → Sources → Prop where
  | nil (s) : Executes [] ⟨⟩ s s
  | delta {layer : ResidualDelta.Layer} {rest : List Stage}
      {plan : InitialCacheMemory.Plan (.delta layer::rest)} {s after : Sources} (safe : StageSafe s plan.1)
      (history : InitialCacheSourceConstruction.HistoryChecked s.history plan.1 safe.1)
      (recurrent : InitialRecurrentSource.Checked (afterHistory s plan.1 safe).recurrent plan.1.layout
        (Eq.mpr (congrArg (fun base => MemoryRegions.Disjoint plan.1.layout.recurrentBase 3145728 base 4)
          (afterHistory_recurrent_base s plan.1 safe)) safe.2.2)
        (afterHistory s plan.1 safe).raw_recurrent)
      (tail : Executes rest plan.2 (afterStage s plan.1 safe) after) : Executes (.delta layer::rest) plan s after
  | attention {layer : ResidualAttention.Layer} {rest : List Stage}
      {plan : InitialCacheMemory.Plan (.attention layer::rest)} {s after : Sources}
      (tail : Executes rest plan.2 s after) : Executes (.attention layer::rest) plan s after

structure Result (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) where
  after : Sources
  historyBase : after.history.base=s.history.base
  recurrentBase : after.recurrent.base=s.recurrent.base
  heap_eq : after.history.bytes=InitialCacheMemory.execute stages plan s.history.bytes
  execution : Executes stages plan s after

def construct : (stages : List Stage) → (plan : InitialCacheMemory.Plan stages) → (s : Sources) → Safe stages plan s → Result stages plan s
  | [], _, s, _ => ⟨s,rfl,rfl,rfl,.nil s⟩
  | .delta _::rest, plan, s, safe =>
      let stageSafe : StageSafe s plan.1 := ⟨safe.1.1,safe.2.1⟩
      let next := afterStage s plan.1 stageSafe
      let nextSafe : Safe rest plan.2 next := safe_rebase (afterStage_history_base s plan.1 stageSafe)
        (afterStage_recurrent_base s plan.1 stageSafe) ⟨safe.1.2,safe.2.2⟩
      let tail := construct rest plan.2 next nextSafe
      ⟨tail.after, tail.historyBase.trans (afterStage_history_base s plan.1 stageSafe),
        tail.recurrentBase.trans (afterStage_recurrent_base s plan.1 stageSafe),
        tail.heap_eq.trans (congrArg (InitialCacheMemory.execute rest plan.2) (afterStage_eq s plan.1 stageSafe)),
        .delta stageSafe (InitialCacheSourceConstruction.history_checked s.history plan.1 safe.1.1)
          (InitialRecurrentSource.checked _ _ _ _) tail.execution⟩
  | .attention _::rest, plan, s, safe =>
      let tail := construct rest plan.2 s ⟨safe.1.2,safe.2.2⟩
      ⟨tail.after,tail.historyBase,tail.recurrentBase,tail.heap_eq,.attention tail.execution⟩

def run (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) (safe : Safe stages plan s) : Sources :=
  (construct stages plan s safe).after

theorem run_eq (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) (safe : Safe stages plan s) :
    (run stages plan s safe).history.bytes=InitialCacheMemory.execute stages plan s.history.bytes :=
  (construct stages plan s safe).heap_eq

theorem run_history_base (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) (safe : Safe stages plan s) :
    (run stages plan s safe).history.base=s.history.base := (construct stages plan s safe).historyBase

theorem run_recurrent_base (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) (safe : Safe stages plan s) :
    (run stages plan s safe).recurrent.base=s.recurrent.base := (construct stages plan s safe).recurrentBase

theorem checked (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources) (safe : Safe stages plan s) :
    Executes stages plan s (run stages plan s safe) := (construct stages plan s safe).execution

theorem run_frame (stages : List Stage) (plan : InitialCacheMemory.Plan stages) (s : Sources)
    (safe : Safe stages plan s) (protectedRegions : TokenInitializationMemory.CacheSafe stages plan other size)
    (offset : Nat) (bound : offset<size) :
    (run stages plan s safe).history.bytes (other+offset)=s.history.bytes (other+offset) := by
  rw [run_eq]
  exact TokenInitializationMemory.cache_frame stages plan s.history.bytes protectedRegions offset bound

section Workspace
variable {p : TokenInference.Pipeline} {token : Fin 248320}
    (scalars : InitialScalarConstruction.Workspace) (initialHeap : ByteMemory.Bytes)
    (w : TokenInitializationAllocation.Workspace p.graph.stages)
    (separate : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages)
      scalars.base InitialScalarConstruction.bytes)

-- Both buffers originate in the explicit two-store scalar construction, then
-- are retained through the actual token write before any cache launch begins.
def entrySources : Sources where
  history := scalars.historyAfterToken initialHeap (token:=token) w separate
  recurrent := scalars.recurrentAfterToken initialHeap (token:=token) w separate
  shared := rfl
  raw := scalars.recurrentAfterToken_raw initialHeap w separate

theorem entrySources_history_base : (entrySources scalars initialHeap w separate (token:=token)).history.base=scalars.base :=
  scalars.historyAfterToken_base initialHeap w separate

theorem entrySources_recurrent_base : (entrySources scalars initialHeap w separate (token:=token)).recurrent.base=scalars.base+4 := rfl

theorem entrySources_history_bytes : (entrySources scalars initialHeap w separate (token:=token)).history.bytes=
    (w.plan (token:=token) (initialHeap:=scalars.memory initialHeap)).tokenWrite.memory :=
  scalars.historyAfterToken_bytes initialHeap w separate

theorem entrySafe : Safe p.graph.stages w.caches (entrySources scalars initialHeap w separate (token:=token)) := by
  unfold Safe
  rw [entrySources_history_base,entrySources_recurrent_base]
  exact ⟨w.cache_safe (scalars.tokenWorkspaceFresh initialHeap w separate),
    w.cache_safe (scalars.recurrentTokenFresh w separate)⟩

def initializedSources : Sources :=
  run p.graph.stages w.caches (entrySources scalars initialHeap w separate (token:=token))
    (entrySafe scalars initialHeap w separate)

theorem initialize_eq : (initializedSources scalars initialHeap w separate (token:=token)).history.bytes=
    (w.plan (token:=token) (initialHeap:=scalars.memory initialHeap)).memory :=
  (run_eq p.graph.stages w.caches _ (entrySafe scalars initialHeap w separate)).trans
    (congrArg (InitialCacheMemory.execute p.graph.stages w.caches)
      (entrySources_history_bytes scalars initialHeap w separate))

theorem initialize_checked : Executes p.graph.stages w.caches (entrySources scalars initialHeap w separate (token:=token))
    (initializedSources scalars initialHeap w separate (token:=token)) :=
  checked _ _ _ _

theorem initialize_history_base : (initializedSources scalars initialHeap w separate (token:=token)).history.base=scalars.base :=
  (run_history_base p.graph.stages w.caches _ (entrySafe scalars initialHeap w separate)).trans
    (entrySources_history_base scalars initialHeap w separate)

theorem initialize_recurrent_base : (initializedSources scalars initialHeap w separate (token:=token)).recurrent.base=scalars.base+4 :=
  (run_recurrent_base p.graph.stages w.caches _ (entrySafe scalars initialHeap w separate)).trans
    (entrySources_recurrent_base scalars initialHeap w separate)

theorem initialize_raw : ByteMemory.load32 (initializedSources scalars initialHeap w separate (token:=token)).history.bytes (scalars.base+4)=0 := by
  have raw := (initializedSources scalars initialHeap w separate (token:=token)).raw
  rw [initialize_recurrent_base] at raw
  exact raw

theorem initialize_frame
    (scalarSafe : MemoryRegions.Disjoint scalars.base InitialScalarConstruction.bytes other size)
    (cacheSafe : MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) other size)
    (offset : Nat) (bound : offset<size) :
    (initializedSources scalars initialHeap w separate (token:=token)).history.bytes (other+offset)=initialHeap (other+offset) :=
  (run_frame p.graph.stages w.caches _ (entrySafe scalars initialHeap w separate)
    (w.cache_safe cacheSafe) offset bound).trans
    (scalars.prefix_other_region initialHeap w separate scalarSafe cacheSafe offset bound)

def parameters (original : TokenParameterMemory.Storage p initialHeap)
    (safe : original.Protected (fun base size =>
      MemoryRegions.Disjoint scalars.base InitialScalarConstruction.bytes base size ∧
      MemoryRegions.Disjoint w.base (TokenInitializationAllocation.bytes p.graph.stages) base size)) :
    TokenParameterMemory.Storage p (initializedSources scalars initialHeap w separate (token:=token)).history.bytes :=
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
      (initializedSources scalars initialHeap w separate (token:=token)).history.bytes :=
  (initialize_eq scalars initialHeap w separate).symm

theorem launch_counts : TokenInitializationAllocation.deltaCount p.graph.stages=48 :=
  TokenInitializationAllocation.graph_delta_count p.graph

end Workspace
end Inference.Models.Qwen.InitialCacheParsedSourceConstruction
