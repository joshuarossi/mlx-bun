import models.qwen.AttentionInitialStageConstruction
import models.qwen.DecodeInitialMemoryChain
import models.qwen.DecodeHighWaterConstruction

namespace Inference.Models.Qwen.DecodeInitialConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
open ResidualDeltaHighWater (Frontier Before before_mono cacheProtected_mono remaining_protected)
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

def stageBytes : Stage → Nat
  | .delta _ => ResidualDeltaAllocation.bytes
  | .attention layer => AttentionInitialWorkspaceConstruction.bytes (layer:=layer)

theorem stage_aligned (stage : Stage) : stageBytes stage%16=0 := by
  cases stage with
  | delta layer => change 4139488%16=0; decide +kernel
  | attention layer => exact AttentionInitialStageConstruction.bytes_aligned layer

def next (frontier : Frontier) (stage : Stage) : Frontier where
  cursor := frontier.cursor+stageBytes stage
  aligned := by rw [Nat.add_mod,frontier.aligned,stage_aligned]

def bytes : List Stage → Nat
  | [] => 0
  | stage::rest => stageBytes stage+bytes rest

theorem bytes_aligned (stages : List Stage) : bytes stages%16=0 := by
  induction stages with
  | nil => rfl
  | cons stage rest ih => simp only [bytes,Nat.add_mod,stage_aligned,ih,Nat.zero_add,Nat.zero_mod]

variable {all rest : List Stage} {kind : Stage}
  (position : DecodeParameterConstruction.Cursor all (kind::rest))
  (cache : Caches (kind::rest) 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage (kind::rest) cache source.bytes)
  (parameters : DecodeParameterMemory.Storage all source.bytes) (frontier : Frontier)

-- A concrete execution, with bounds derived by the kernel/layer constructors.
-- No output equality or already-completed launch is supplied by the caller.
structure Step where
  first : DecodeInitialMemoryStage.Trace kind cache.1 input angle source storage.1
  safeBefore : ∀ base size, Before frontier.cursor base size → first.Safe base size
  outputBound : Before (next frontier kind).cursor first.buffer.base 10240
  updatedBound : DecodePreservation.StageProtected (Before (next frontier kind).cursor) kind
    (cacheAfter kind cache.1 input angle) first.cacheAfter.storage

section Attention
variable {layer : ResidualAttention.Layer}
  (position : DecodeParameterConstruction.Cursor all (.attention layer::rest))
  (cache : Caches (.attention layer::rest) 0)
  (storage : DecodeFrame.Storage (.attention layer::rest) cache source.bytes)

def attentionWorkspace (capacity : (next frontier (.attention layer)).cursor≤2^64)
    (sourceBound : Before frontier.cursor source.base 10240)
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
    (dispatch : DecodeHighWaterConstruction.Dispatch (.attention layer)) :
    AttentionInitialWorkspaceConstruction.Workspace
      (DecodeParameterConstruction.attentionSource layer cache.1 input source storage.1
        (DecodeParameterConstruction.remainingParameters position parameters).1) where
  base := frontier.cursor
  aligned := frontier.aligned
  bounded := capacity
  sourceBefore := sourceBound
  parametersBefore := (remaining_protected position parameters parametersBound).1
  queryDispatch := dispatch.1
  keyDispatch := dispatch.2

end Attention

def step (capacity : (next frontier kind).cursor≤2^64)
    (sourceBound : Before frontier.cursor source.base 10240)
    (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
    (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)
    (dispatch : DecodeHighWaterConstruction.Dispatch kind) (keyCopied valueCopied : Bool) :
    Step cache input angle source storage frontier := by
  cases kind with
  | delta layer =>
    let old := ResidualDeltaHighWater.boundStep position cache input angle source storage parameters frontier
      capacity sourceBound parametersBound cachesBound
    refine {
      first := DecodeInitialMemoryStage.delta old.step.first
      safeBefore := ?_
      outputBound := ?_
      updatedBound := ?_ }
    · intro base size bound
      exact ResidualDeltaHighWater.stage_safe_before source storage.1
        (DecodeParameterConstruction.remainingParameters position parameters).1 frontier capacity sourceBound
        (remaining_protected position parameters parametersBound).1 cachesBound.1 angle bound
    · exact ResidualDeltaHighWater.boundStep_output position cache input angle source storage parameters frontier
        capacity sourceBound parametersBound cachesBound
    · exact ResidualDeltaHighWater.boundStep_updated position cache input angle source storage parameters frontier
        capacity sourceBound parametersBound cachesBound
  | attention layer =>
    let workspace := attentionWorkspace (position:=position) (cache:=cache) (input:=input)
      (source:=source) (storage:=storage) (parameters:=parameters) (frontier:=frontier)
      capacity sourceBound parametersBound dispatch
    exact {
      first := AttentionInitialStageConstruction.trace workspace angle keyCopied valueCopied
      safeBefore := fun _ _ bound => AttentionInitialStageConstruction.safe workspace angle keyCopied valueCopied bound
      outputBound := AttentionInitialStageConstruction.output_bound workspace angle keyCopied valueCopied
      updatedBound := AttentionInitialStageConstruction.cache_bound workspace angle keyCopied valueCopied }

section Continuity
variable {cache input angle source storage frontier}
variable (result : Step cache input angle source storage frontier)
  (parametersBound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor))
  (cachesBound : DecodePreservation.Protected (Before frontier.cursor) (kind::rest) cache source.bytes storage)

def Step.chainStep : DecodeInitialMemoryChain.Step kind rest cache input angle source storage where
  first := result.first
  retainedSafe := cacheProtected_mono rest cache.2 storage.2 (fun _ _ bound => result.safeBefore _ _ bound) cachesBound.2

def Step.nextParameters : DecodeParameterMemory.Storage all result.first.buffer.bytes :=
  DecodeParameterMemory.reframe all parameters _ (DecodeParameterMemory.protected_mono all parameters
    (fun _ _ bound => result.first.other_region (result.safeBefore _ _ bound)) parametersBound)

theorem Step.parameter_regions (property : Nat → Nat → Prop) :
    DecodeParameterMemory.Protected all (result.nextParameters parameters parametersBound) property ↔
      DecodeParameterMemory.Protected all parameters property :=
  DecodeParameterMemory.reframe_protected all parameters _ _ property

theorem Step.parameters_bound : DecodeParameterMemory.Protected all (result.nextParameters parameters parametersBound)
    (Before (next frontier kind).cursor) :=
  (result.parameter_regions parameters parametersBound _).mpr
    (DecodeParameterMemory.protected_mono all parameters (fun _ _ bound =>
      before_mono (Nat.le_add_right _ _) bound) parametersBound)

theorem Step.retained_bound : DecodePreservation.Protected (Before (next frontier kind).cursor) rest cache.2
    result.first.buffer.bytes (result.chainStep cachesBound).nextStorage :=
  DecodePreservation.preserves_geometry result.first.Safe (Before (next frontier kind).cursor) source.bytes result.first.buffer.bytes
    (fun _ _ safe => result.first.other_region safe) rest cache.2 storage.2
    (result.chainStep cachesBound).retainedSafe
    (cacheProtected_mono rest cache.2 storage.2 (fun _ _ bound => before_mono (Nat.le_add_right _ _) bound) cachesBound.2)

end Continuity

section Result
variable {stages : List Stage}
  (cache : Caches stages 0) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (frontier : Frontier)

structure Result where
  trace : DecodeInitialMemoryChain.Trace stages cache input angle source storage
  safeBefore : ∀ base size, Before frontier.cursor base size →
    DecodeInitialMemoryChain.Safe stages cache input angle source storage trace base size
  cacheSafe : DecodeInitialMemoryChain.CacheSafe stages cache input angle source storage trace
  outputBound : Before (frontier.cursor+bytes stages)
    (DecodeInitialMemoryChain.outputBuffer stages cache input angle source storage trace).base 10240
  cachesBound : DecodePreservation.Protected (Before (frontier.cursor+bytes stages)) stages
    (DecodeChain.run stages cache input angle).2 _
    (DecodeInitialMemoryChain.after stages cache input angle source storage trace cacheSafe)

end Result

theorem next_cursor (frontier : Frontier) (stage : Stage) :
    (next frontier stage).cursor=frontier.cursor+stageBytes stage := rfl

-- Every node is built from the previous node's actual heap and the same
-- original parameter bundle. The cache safety premises are derived from the
-- fresh workspace order, rather than supplied as completed layer executions.
def build : (stages : List Stage) → (position : DecodeParameterConstruction.Cursor all stages) →
    (cache : Caches stages 0) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (parameters : DecodeParameterMemory.Storage all source.bytes) → (frontier : Frontier) →
    frontier.cursor+bytes stages≤2^64 → Before frontier.cursor source.base 10240 →
    DecodeParameterMemory.Protected all parameters (Before frontier.cursor) →
    DecodePreservation.Protected (Before frontier.cursor) stages cache source.bytes storage →
    DecodeHighWaterConstruction.Dispatches stages → Bool → Bool →
    Result cache input angle source storage frontier
  | [], _, _, _, _, _, _, _, _, _, sourceBound, _, _, _, _, _ => {
      trace := ⟨⟩
      safeBefore := fun _ _ _ => trivial
      cacheSafe := trivial
      outputBound := by simpa only [DecodeInitialMemoryChain.outputBuffer,bytes,Nat.add_zero] using sourceBound
      cachesBound := trivial }
  | kind::rest, position, cache, input, angle, source, storage, parameters, frontier, capacity, sourceBound, parametersBound, cachesBound, dispatch, keyCopied, valueCopied => by
    have headCapacity : (next frontier kind).cursor≤2^64 := by
      rw [next_cursor]
      change frontier.cursor+(stageBytes kind+bytes rest)≤2^64 at capacity
      omega
    let first := step position cache input angle source storage parameters frontier headCapacity sourceBound parametersBound cachesBound dispatch.1 keyCopied valueCopied
    let head := first.chainStep cachesBound
    have tailCapacity : (next frontier kind).cursor+bytes rest≤2^64 := by
      rw [next_cursor]
      simpa only [bytes,Nat.add_assoc] using capacity
    let tail := build rest (.next position) cache.2 (forward kind cache.1 input angle) angle
      first.first.buffer head.nextStorage (first.nextParameters parameters parametersBound)
      (next frontier kind) tailCapacity first.outputBound (first.parameters_bound parameters parametersBound)
      (first.retained_bound cachesBound) dispatch.2 keyCopied valueCopied
    have headSurvives : DecodePreservation.StageProtected
        (DecodeInitialMemoryChain.Safe rest cache.2 (forward kind cache.1 input angle) angle
          first.first.buffer head.nextStorage tail.trace)
        kind (cacheAfter kind cache.1 input angle) first.first.cacheAfter.storage :=
      DecodeHighWaterConstruction.stage_mono kind _ _ (fun _ _ bound => tail.safeBefore _ _ bound) first.updatedBound
    refine {
      trace := ⟨head,tail.trace⟩
      safeBefore := ?_
      cacheSafe := ⟨headSurvives,tail.cacheSafe⟩
      outputBound := ?_
      cachesBound := ?_ }
    · intro base size bound
      exact ⟨first.safeBefore base size bound,tail.safeBefore base size
        (before_mono (by rw [next_cursor]; omega) bound)⟩
    · have bound := tail.outputBound
      rw [next_cursor] at bound
      simpa only [DecodeInitialMemoryChain.outputBuffer,head,Step.chainStep,bytes,Nat.add_assoc] using bound
    · constructor
      · exact DecodePreservation.stage_preserves_geometry _ _ _ _
          (fun base size safe => DecodeInitialMemoryChain.other_region rest cache.2 (forward kind cache.1 input angle) angle
            first.first.buffer head.nextStorage tail.trace base size safe)
          kind (cacheAfter kind cache.1 input angle) first.first.cacheAfter headSurvives
          (DecodeHighWaterConstruction.stage_mono kind _ _ (fun _ _ bound => before_mono
            (by rw [next_cursor]; dsimp [bytes]; omega) bound) first.updatedBound)
      · have bound := tail.cachesBound
        rw [next_cursor] at bound
        simpa only [DecodeInitialMemoryChain.after,DecodeInitialMemoryChain.outputBuffer,head,Step.chainStep,
          DecodeChain.run,bytes,Nat.add_assoc] using bound

section Derived
variable {stages : List Stage} {cache : Caches stages 0} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage stages cache source.bytes} {frontier : Frontier}
  (result : Result cache input angle source storage frontier)

def Result.outputBuffer : ArrayStorage.BFBuffer (DecodeChain.run stages cache input angle).1 :=
  DecodeInitialMemoryChain.outputBuffer stages cache input angle source storage result.trace

def Result.after : DecodeFrame.Storage stages (DecodeChain.run stages cache input angle).2 result.outputBuffer.bytes :=
  DecodeInitialMemoryChain.after stages cache input angle source storage result.trace result.cacheSafe

def Result.endFrontier (_result : Result cache input angle source storage frontier) : Frontier where
  cursor := frontier.cursor+bytes stages
  aligned := by rw [Nat.add_mod,frontier.aligned,bytes_aligned]

theorem Result.other_region {base size : Nat} (bound : Before frontier.cursor base size) (offset : Nat) (inside : offset<size) :
    result.outputBuffer.bytes (base+offset)=source.bytes (base+offset) :=
  DecodeInitialMemoryChain.other_region stages cache input angle source storage result.trace
    base size (result.safeBefore base size bound) offset inside

theorem Result.read_result : DecodeInitialMemoryChain.readResult stages cache input angle source storage
    result.trace result.cacheSafe=DecodeChain.run stages cache input angle :=
  DecodeInitialMemoryChain.read_result_eq stages cache input angle source storage result.trace result.cacheSafe

def Result.parametersAfter (parameters : DecodeParameterMemory.Storage all source.bytes)
    (bound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Storage all result.outputBuffer.bytes :=
  DecodeParameterMemory.reframe all parameters _ (DecodeParameterMemory.protected_mono all parameters
    (fun _ _ inside => result.other_region inside) bound)

theorem Result.parameters_regions (parameters : DecodeParameterMemory.Storage all source.bytes)
    (bound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) (property : Nat → Nat → Prop) :
    DecodeParameterMemory.Protected all (result.parametersAfter parameters bound) property ↔
      DecodeParameterMemory.Protected all parameters property :=
  DecodeParameterMemory.reframe_protected all parameters _ _ property

theorem Result.parameters_bound (parameters : DecodeParameterMemory.Storage all source.bytes)
    (bound : DecodeParameterMemory.Protected all parameters (Before frontier.cursor)) :
    DecodeParameterMemory.Protected all (result.parametersAfter parameters bound) (Before result.endFrontier.cursor) :=
  (result.parameters_regions parameters bound _).mpr
    (DecodeParameterMemory.protected_mono all parameters (fun _ _ region => before_mono (Nat.le_add_right _ _) region) bound)

end Derived

end Inference.Models.Qwen.DecodeInitialConstruction
