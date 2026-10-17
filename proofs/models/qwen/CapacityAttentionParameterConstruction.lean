import models.qwen.DecodeParameterConstruction
import models.qwen.CopiedAttentionCapacityFactory
import models.qwen.CapacityAttentionDecodeChain
namespace Inference.Models.Qwen.CapacityAttentionParameterConstruction
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
variable {n : Nat}

variable {layer : ResidualAttention.Layer} {cache : State.Kv.Cache State.Kv.BF n}
  {input : Row BF} {angle : RopeAngles.Inputs} {source : ArrayStorage.BFBuffer input}
  {storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes}
  {parameters : DecodeParameterMemory.AttentionStorage layer source.bytes}
  (plan : CopiedAttentionCapacityFactory.Plan layer cache input angle source storage.storage storage.shared parameters)

theorem attentionSafe : AttentionGateCopyCapacityStageCache.Safe (CopiedAttentionCapacityFactory.stage plan) :=
  ⟨plan.keysNormal,plan.valuesNormal⟩

theorem attentionCache :
    AttentionGateCopyCapacityStageCache.before (CopiedAttentionCapacityFactory.stage plan) (attentionSafe plan)=storage.storage := by
  cases storage with
  | mk storage shared =>
    cases storage with
    | mk layout memory keys values =>
      cases shared
      rfl

def StagePlan : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → DecodeFrame.StageBuffer kind cache source.bytes →
    DecodeParameterMemory.StageStorage kind source.bytes → Type
  | .delta layer, cache, input, _, source, storage, parameters => DecodeParameterConstruction.DeltaPlan layer cache input source storage parameters
  | .attention layer, cache, input, angle, source, storage, parameters =>
    CopiedAttentionCapacityFactory.Plan layer cache input angle source storage.storage storage.shared parameters

def stage : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.StageBuffer kind cache source.bytes) →
    (parameters : DecodeParameterMemory.StageStorage kind source.bytes) →
    StagePlan kind cache input angle source storage parameters → CapacityAttentionDecodeStage.Trace kind cache input angle source storage
  | .delta _, _, _, _, _, _, _, plan => {
    execution := ⟨DecodeParameterConstruction.deltaSource plan.entry _ plan.frames,plan.allocation⟩
    inputLinked := (ResidualDeltaStorageConstruction.source_linked _ plan.allocation).trans plan.entry.sourceLinked
    cacheLinked := ResidualDeltaStorageConstruction.cache_linked _ plan.allocation }
  | .attention _, _, _, _, _, _, _, plan => {
    execution := ⟨CopiedAttentionCapacityFactory.stage plan,attentionSafe plan⟩
    inputLinked := CopiedAttentionCapacityFactory.input_source plan
    cacheLinked := attentionCache plan }

-- The cursor selects a positional suffix of one fixed complete parameter bundle.
inductive Cursor : List Stage → List Stage → Type
  | root : Cursor stages stages
  | next : Cursor all (kind::rest) → Cursor all rest

def remainingParameters : (cursor : Cursor all stages) → DecodeParameterMemory.Storage all memory → DecodeParameterMemory.Storage stages memory
  | .root, parameters => parameters
  | .next cursor, parameters => (remainingParameters cursor parameters).2

-- Every write protects the complete bundle, including already consumed stages.
-- The next heap attachment is derived, never supplied by the next stage.
structure StepPlan (cursor : Cursor all (kind::rest)) (cache : Caches (kind::rest) n)
    (input : Row BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.Storage (kind::rest) cache source.bytes) (parameters : DecodeParameterMemory.Storage all source.bytes) where
  first : StagePlan kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1
  retained : DecodePreservation.Protected (stage kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 first).Safe
    rest cache.2 source.bytes storage.2
  parametersSafe : DecodeParameterMemory.Protected all parameters
    (stage kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 first).Safe

variable {all : List Stage} {kind : Stage} {rest : List Stage} {cursor : Cursor all (kind::rest)}
  {cache : Caches (kind::rest) n} {input : Row BF} {angle : RopeAngles.Inputs}
  {source : ArrayStorage.BFBuffer input} {storage : DecodeFrame.Storage (kind::rest) cache source.bytes}
  {parameters : DecodeParameterMemory.Storage all source.bytes}

def StepPlan.step (plan : StepPlan cursor cache input angle source storage parameters) :
    CapacityAttentionDecodeChain.Step kind rest cache input angle source storage :=
  ⟨stage kind cache.1 input angle source storage.1 (remainingParameters cursor parameters).1 plan.first,plan.retained⟩

theorem StepPlan.parameterFrame (plan : StepPlan cursor cache input angle source storage parameters) :
    DecodeParameterMemory.Protected all parameters (fun base size => ∀ offset < size,
      plan.step.first.buffer.bytes (base+offset)=source.bytes (base+offset)) :=
  DecodeParameterMemory.protected_mono all parameters
    (fun _ _ safe => plan.step.first.other_region safe) plan.parametersSafe

def StepPlan.nextParameters (plan : StepPlan cursor cache input angle source storage parameters) :
    DecodeParameterMemory.Storage all plan.step.first.buffer.bytes :=
  DecodeParameterMemory.reframe all parameters _ plan.parameterFrame

def ChainPlan : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    DecodeFrame.Storage stages cache source.bytes → DecodeParameterMemory.Storage all source.bytes → Type
  | [], _, _, _, _, _, _, _ => PUnit
  | kind::rest, cursor, cache, input, angle, source, storage, parameters =>
    (first : StepPlan cursor cache input angle source storage parameters) ×
      ChainPlan rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
        first.step.first.buffer first.step.nextStorage first.nextParameters

def chain : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → CapacityAttentionDecodeChain.Trace stages cache input angle source storage
  | [], _, _, _, _, _, _, _, _ => ⟨⟩
  | kind::rest, cursor, cache, input, angle, _, _, _, plan =>
    ⟨plan.1.step,chain rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2⟩


def finalParameters : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) →
    DecodeParameterMemory.Storage all (CapacityAttentionDecodeChain.outputBuffer stages cache input angle source storage
      (chain stages cursor cache input angle source storage parameters plan)).bytes
  | [], _, _, _, _, _, _, parameters, _ => parameters
  | kind::rest, cursor, cache, input, angle, _, _, _, plan =>
    finalParameters rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2

theorem finalParameters_regions : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) → (property : Nat → Nat → Prop) →
    DecodeParameterMemory.Protected all (finalParameters stages cursor cache input angle source storage parameters plan) property ↔
      DecodeParameterMemory.Protected all parameters property
  | [], _, _, _, _, _, _, _, _, _ => Iff.rfl
  | kind::rest, cursor, cache, input, angle, _, _, parameters, plan, property =>
    (finalParameters_regions rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle
      plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2 property).trans
      (DecodeParameterMemory.reframe_protected all parameters _ plan.1.parameterFrame property)

def CacheRegions : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    ChainPlan stages cursor cache input angle source storage parameters → Prop
  | [], _, _, _, _, _, _, _, _ => True
  | kind::rest, cursor, cache, input, angle, _, _, _, plan =>
    DecodePreservation.StageProtected
      (CapacityAttentionDecodeChain.Safe rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage
        (chain rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2))
      kind (cacheAfter kind cache.1 input angle) plan.1.step.first.cacheAfter.storage ∧
    CacheRegions rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2

theorem cacheSafe : (stages : List Stage) → (cursor : Cursor all stages) → (cache : Caches stages n) →
    (input : Row BF) → (angle : RopeAngles.Inputs) → (source : ArrayStorage.BFBuffer input) →
    (storage : DecodeFrame.Storage stages cache source.bytes) → (parameters : DecodeParameterMemory.Storage all source.bytes) →
    (plan : ChainPlan stages cursor cache input angle source storage parameters) → CacheRegions stages cursor cache input angle source storage parameters plan →
    CapacityAttentionDecodeChain.CacheSafe stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan)
  | [], _, _, _, _, _, _, _, _, _ => True.intro
  | kind::rest, cursor, cache, input, angle, _, _, _, plan, safe =>
    ⟨safe.1,cacheSafe rest (.next cursor) cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.1.nextParameters plan.2 safe.2⟩

section Result
variable (stages : List Stage) (cursor : Cursor all stages) (cache : Caches stages n)
  (input : Row BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
  (storage : DecodeFrame.Storage stages cache source.bytes) (parameters : DecodeParameterMemory.Storage all source.bytes)
  (plan : ChainPlan stages cursor cache input angle source storage parameters)

def outputBuffer := CapacityAttentionDecodeChain.outputBuffer stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan)

def after (safe : CacheRegions stages cursor cache input angle source storage parameters plan) :=
  CapacityAttentionDecodeChain.after stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan)
    (cacheSafe stages cursor cache input angle source storage parameters plan safe)

def readResult (safe : CacheRegions stages cursor cache input angle source storage parameters plan) :=
  CapacityAttentionDecodeChain.readResult stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan)
    (cacheSafe stages cursor cache input angle source storage parameters plan safe)

theorem read_result_eq (safe : CacheRegions stages cursor cache input angle source storage parameters plan) :
    readResult stages cursor cache input angle source storage parameters plan safe=DecodeChain.run stages cache input angle :=
  CapacityAttentionDecodeChain.read_result_eq stages cache input angle source storage (chain stages cursor cache input angle source storage parameters plan)
    (cacheSafe stages cursor cache input angle source storage parameters plan safe)
end Result

end Inference.Models.Qwen.CapacityAttentionParameterConstruction
