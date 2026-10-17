import models.qwen.ResidualDeltaAllocation
import contracts.mlx.AllocatorRegions

namespace Inference.Models.Qwen.ResidualDeltaHighWater
open Contracts.Mlx Layers Kernels Kernels.Delta
set_option maxRecDepth 100000
set_option maxHeartbeats 2000000
attribute [local irreducible] ResidualDeltaConstruction.preparation ResidualDeltaStorageConstruction.preparation

def Before (cursor base size : Nat) : Prop := base+size≤cursor

theorem before_mono (ordered : first≤second) (bound : Before first base size) : Before second base size := Nat.le_trans bound ordered

theorem fresh (bound : Before cursor base size) : MemoryRegions.Disjoint cursor requested base size := Or.inr bound

structure Frontier where
  cursor : Nat
  aligned : cursor%16=0

def Frontier.next (frontier : Frontier) : Frontier where
  cursor := frontier.cursor+ResidualDeltaAllocation.bytes
  aligned := by have := frontier.aligned; dsimp [ResidualDeltaAllocation.bytes]; omega

variable {layer : ResidualDelta.Layer} {cache : DeltaNet.Cache} {input : Fin 5120 → ArrayStorage.BF}
  (origin : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache origin.bytes)
  (checkpoint : DecodeParameterMemory.DeltaStorage layer origin.bytes) (frontier : Frontier)
  (capacity : frontier.next.cursor≤2^64)
  (sourceBound : Before frontier.cursor origin.base 10240)
  (parameterBound : checkpoint.Protected (Before frontier.cursor))
  (cacheBound : DecodePreservation.StageProtected (Before frontier.cursor) (.delta layer) cache storage.storage)

def allocation : ResidualDeltaAllocation.Workspace origin storage checkpoint where
  base := frontier.cursor
  aligned := frontier.aligned
  bounded := capacity
  sourceFresh := fresh sourceBound
  parametersFresh := checkpoint.protected_mono (fun _ _ h => fresh h) parameterBound
  historyFresh := fresh cacheBound.1
  stateFresh := fresh cacheBound.2

def execution := (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).fromStorage

def deltaPlan := (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).deltaPlan

theorem source_linked : (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).entry.source.lhs=origin :=
  (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).source_linked

theorem cache_linked : (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).storage=storage.storage :=
  (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).cache_linked

theorem output_bound : Before frontier.next.cursor
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).outputBuffer.base 10240 := by
  change Before frontier.next.cursor (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).fromStorage.outputBuffer.base 10240
  rw [(allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).output_base]
  change frontier.cursor+4129248+10240≤frontier.cursor+4139488
  omega

theorem strong_cache_bases (source : ResidualDeltaStorageConstruction.Source layer cache input)
    (plan : ResidualDeltaStorageConstruction.Plan source) :
    (ResidualDeltaStorageConstruction.fromStorage source plan).afterCache.buffers.history.base=2*plan.preparation.convolution.tailBase ∧
    (ResidualDeltaStorageConstruction.fromStorage source plan).afterCache.buffers.recurrent.base=plan.recurrent.allocation.stateBase := ⟨rfl,rfl⟩

theorem cache_bases :
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.history.base=frontier.cursor+125120 ∧
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.recurrent.base=frontier.cursor+227808 := by
  have bases := strong_cache_bases
    (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).workspace.entry.strongSource
    (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).workspace.plan
  change (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.history.base=
      2*(((frontier.cursor+43200)+81920)/2) ∧
    (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.recurrent.base=frontier.cursor+227808 at bases
  have aligned := frontier.aligned
  exact ⟨bases.1.trans (by omega),bases.2⟩

theorem cache_bound :
    Before frontier.next.cursor (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.history.base 61440 ∧
    Before frontier.next.cursor (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).afterCache.buffers.recurrent.base 3145728 := by
  rw [(cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).1,
    (cache_bases origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).2]
  dsimp [Before,Frontier.next,ResidualDeltaAllocation.bytes]
  omega


private def cacheReindex {first second : DeltaNet.Cache} (equal : first=second) (stored : DeltaRegions.Storage first) : DeltaRegions.Storage second := by
  cases equal
  exact stored

private theorem cacheReindex_regions {first second : DeltaNet.Cache} (equal : first=second) (stored : DeltaRegions.Storage first)
    (property : Nat → Nat → Prop) :
    DecodePreservation.StageProtected (n := n) property (.delta layer) second (cacheReindex equal stored) ↔
      property stored.buffers.history.base 61440 ∧ property stored.buffers.recurrent.base 3145728 := by
  cases equal
  rfl

theorem afterStorage_regions (e : ResidualDeltaMemory.Execution layer cache input) (property : Nat → Nat → Prop) :
    DecodePreservation.StageProtected (n := n) property (.delta layer) (layer.cacheAfter cache (fun _ => input) 1)
      (DeltaMemoryStage.afterStorage e) ↔
    property e.afterCache.buffers.history.base 61440 ∧ property e.afterCache.buffers.recurrent.base 3145728 :=
  cacheReindex_regions e.cache_eq e.afterCache property

theorem stage_cache_bound (angle : Kernels.Attention.RopeAngles.Inputs) :
    DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
      (DecodeStage.cacheAfter (.delta layer) cache input angle)
      (DecodeParameterConstruction.stage (.delta layer) cache input angle origin storage checkpoint
        (deltaPlan origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound)).cacheAfter.storage :=
  (afterStorage_regions (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound) _).mpr
    (cache_bound origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound)

-- The original complete checkpoint keeps both its payloads and physical ranges.
def parametersAfter := (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).parametersAfter

theorem parameters_bound : (parametersAfter origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).Protected
    (Before frontier.next.cursor) :=
  ((allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).parametersAfter_regions _).mpr
    (checkpoint.protected_mono (fun _ _ bound => before_mono (by dsimp [Frontier.next]; omega) bound) parameterBound)

def globalParametersAfter (stages : List DecodeStage.Stage) (parameters : DecodeParameterMemory.Storage stages origin.bytes)
    (bound : DecodeParameterMemory.Protected stages parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Storage stages (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).outputBuffer.bytes :=
  DecodeParameterMemory.reframe stages parameters _ (DecodeParameterMemory.protected_mono stages parameters
    (fun _ _ h => (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).other_region (fresh h)) bound)

theorem globalParameters_bound (stages : List DecodeStage.Stage) (parameters : DecodeParameterMemory.Storage stages origin.bytes)
    (bound : DecodeParameterMemory.Protected stages parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Protected stages
      (globalParametersAfter origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound stages parameters bound)
      (Before frontier.next.cursor) :=
  (DecodeParameterMemory.reframe_protected stages parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono stages parameters
      (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) bound)

theorem cacheProtected_mono : (stages : List DecodeStage.Stage) → (caches : DecodeChain.Caches stages count) →
    (stored : DecodeFrame.Storage stages caches memory) → {first second : Nat → Nat → Prop} →
    (∀ base size, first base size → second base size) →
    DecodePreservation.Protected first stages caches memory stored → DecodePreservation.Protected second stages caches memory stored
  | [], _, _, _, _, _, _ => True.intro
  | stage::rest, caches, stored, _, _, implies, safe => by
    refine ⟨?_,cacheProtected_mono rest caches.2 stored.2 implies safe.2⟩
    cases stage <;> exact ⟨implies _ _ safe.1.1,implies _ _ safe.1.2⟩

def retainedAfter {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (bound : DecodePreservation.Protected (Before frontier.cursor) stages caches origin.bytes stored) :
    DecodeFrame.Storage stages caches (execution origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).outputBuffer.bytes :=
  DecodePreservation.reframe (Before frontier.cursor) origin.bytes _
    (fun _ _ h => (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).other_region (fresh h))
    stages caches stored bound

theorem retained_bound {count : Nat} (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (bound : DecodePreservation.Protected (Before frontier.cursor) stages caches origin.bytes stored) :
    DecodePreservation.Protected (Before frontier.next.cursor) stages caches _
      (retainedAfter origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound stages caches stored bound) :=
  DecodePreservation.preserves_geometry _ _ _ _ _ stages caches stored bound
    (cacheProtected_mono stages caches stored (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) bound)


def stageTrace (angle : Kernels.Attention.RopeAngles.Inputs) :=
  DecodeParameterConstruction.stage (.delta layer) cache input angle origin storage checkpoint
    (deltaPlan origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound)

theorem stage_safe_before (angle : Kernels.Attention.RopeAngles.Inputs) (bound : Before frontier.cursor base size) :
    (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle).Safe base size :=
  (allocation origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound).stage_safe angle (fresh bound)

theorem trace_buffer_base {kind : DecodeStage.Stage} {c : DecodeStage.Cache kind count} {x : Fin 5120 → ArrayStorage.BF}
    {a : Kernels.Attention.RopeAngles.Inputs} {source : ArrayStorage.BFBuffer x}
    {stored : DecodeFrame.StageBuffer kind c source.bytes} (trace : DecodeMemoryStage.Trace kind c x a source stored) :
    trace.buffer.base=(DecodeMemoryStage.outputBuffer kind c x a trace.execution).base := ArrayViews.reindex_base _ _

theorem stage_output_bound (angle : Kernels.Attention.RopeAngles.Inputs) : Before frontier.next.cursor
    (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle).buffer.base 10240 :=
  Eq.mpr (congrArg (fun base => Before frontier.next.cursor base 10240)
    (trace_buffer_base (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle)))
    (output_bound origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound)

def stageParametersAfter (angle : Kernels.Attention.RopeAngles.Inputs) (stages : List DecodeStage.Stage)
    (parameters : DecodeParameterMemory.Storage stages origin.bytes)
    (bound : DecodeParameterMemory.Protected stages parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Storage stages (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle).buffer.bytes :=
  DecodeParameterMemory.reframe stages parameters _ (DecodeParameterMemory.protected_mono stages parameters
    (fun _ _ h => (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle).other_region
      (stage_safe_before origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle h)) bound)

theorem stageParameters_bound (angle : Kernels.Attention.RopeAngles.Inputs) (stages : List DecodeStage.Stage)
    (parameters : DecodeParameterMemory.Storage stages origin.bytes)
    (bound : DecodeParameterMemory.Protected stages parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Protected stages
      (stageParametersAfter origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle stages parameters bound)
      (Before frontier.next.cursor) :=
  (DecodeParameterMemory.reframe_protected stages parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono stages parameters
      (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) bound)

def stageRetainedAfter {count : Nat} (angle : Kernels.Attention.RopeAngles.Inputs)
    (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (bound : DecodePreservation.Protected (Before frontier.cursor) stages caches origin.bytes stored) :=
  (stageTrace origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle).retained stages caches stored
    (cacheProtected_mono stages caches stored
      (fun _ _ h => stage_safe_before origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle h) bound)

theorem stageRetained_bound {count : Nat} (angle : Kernels.Attention.RopeAngles.Inputs)
    (stages : List DecodeStage.Stage) (caches : DecodeChain.Caches stages count)
    (stored : DecodeFrame.Storage stages caches origin.bytes)
    (bound : DecodePreservation.Protected (Before frontier.cursor) stages caches origin.bytes stored) :
    DecodePreservation.Protected (Before frontier.next.cursor) stages caches _
      (stageRetainedAfter origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle stages caches stored bound) :=
  DecodePreservation.preserves_geometry _ _ _ _ _ stages caches stored
    (cacheProtected_mono stages caches stored
      (fun _ _ h => stage_safe_before origin storage checkpoint frontier capacity sourceBound parameterBound cacheBound angle h) bound)
    (cacheProtected_mono stages caches stored (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) bound)


section BoundChain
variable {all rest : List DecodeStage.Stage} {layer : ResidualDelta.Layer} {tokens : Nat}
  (position : DecodeParameterConstruction.Cursor all (.delta layer::rest))
  (chainCache : DecodeChain.Caches (.delta layer::rest) tokens) (values : Fin 5120 → ArrayStorage.BF)
  (angle : Kernels.Attention.RopeAngles.Inputs) (source : ArrayStorage.BFBuffer values)
  (caches : DecodeFrame.Storage (.delta layer::rest) chainCache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)
  (capacity : frontier.next.cursor≤2^64) (sourceBound : Before frontier.cursor source.base 10240)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (.delta layer::rest) chainCache source.bytes caches)

theorem remaining_protected (position : DecodeParameterConstruction.Cursor all stages)
    (parameters : DecodeParameterMemory.Storage all memory) (bound : DecodeParameterMemory.Protected all parameters property) :
    DecodeParameterMemory.Protected stages (DecodeParameterConstruction.remainingParameters position parameters) property := by
  induction position with
  | root => exact bound
  | next previous ih => exact ih.2

def boundStep : DecodeParameterConstruction.StepPlan position chainCache values angle source caches parameters := by
  let selected := (DecodeParameterConstruction.remainingParameters position parameters).1
  have parameterBound : selected.Protected (Before frontier.cursor) := (remaining_protected position parameters parametersBound).1
  let workspace := allocation source caches.1 selected frontier capacity sourceBound parameterBound cachesBound.1
  exact ⟨workspace.deltaPlan,
    cacheProtected_mono rest chainCache.2 caches.2 (fun _ _ h => workspace.stage_safe angle (fresh h)) cachesBound.2,
    DecodeParameterMemory.protected_mono all parameters (fun _ _ h => workspace.stage_safe angle (fresh h)) parametersBound⟩

include parametersBound cachesBound in
theorem boundStep_output : Before frontier.next.cursor
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound).step.first.buffer.base 10240 :=
  stage_output_bound source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (remaining_protected position parameters parametersBound).1 cachesBound.1 angle

include parametersBound cachesBound in
theorem boundStep_updated : DecodePreservation.StageProtected (Before frontier.next.cursor) (.delta layer)
    (DecodeStage.cacheAfter (.delta layer) chainCache.1 values angle)
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound).step.first.cacheAfter.storage :=
  stage_cache_bound source caches.1 (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
    (remaining_protected position parameters parametersBound).1 cachesBound.1 angle

include parametersBound cachesBound in
theorem boundStep_parameters : DecodeParameterMemory.Protected all
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound).nextParameters
    (Before frontier.next.cursor) :=
  (DecodeParameterMemory.reframe_protected all parameters _ _ _).mpr
    (DecodeParameterMemory.protected_mono all parameters
      (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) parametersBound)

include parametersBound cachesBound in
theorem boundStep_retained : DecodePreservation.Protected (Before frontier.next.cursor) rest chainCache.2 _
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound).step.nextStorage :=
  DecodePreservation.preserves_geometry _ _ _ _ _ rest chainCache.2 caches.2
    (boundStep position chainCache values angle source caches parameters frontier capacity sourceBound parametersBound cachesBound).retained
    (cacheProtected_mono rest chainCache.2 caches.2 (fun _ _ h => before_mono (by dsimp [Frontier.next]; omega) h) cachesBound.2)

end BoundChain

end Inference.Models.Qwen.ResidualDeltaHighWater
