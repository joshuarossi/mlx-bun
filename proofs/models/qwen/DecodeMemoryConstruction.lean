import models.qwen.DecodeMemoryChain
import models.qwen.ResidualDeltaConstruction
import models.qwen.ResidualAttentionConstruction

namespace Inference.Models.Qwen.DecodeMemoryConstruction
open Contracts.Mlx DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

structure DeltaPlan (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF)
    (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.StageBuffer (n := n) (.delta layer) cache source.bytes) where
  data : ResidualDeltaConstruction.InputData layer input
  sourceLinked : data.source=source
  parameters : DeltaParameterMemory.Storage layer.mixer (ResidualDeltaConstruction.normalized data).source.lhs.bytes
  frames : ResidualDeltaConstruction.EntryFrames (ResidualDeltaConstruction.normalized data) storage.storage parameters
  allocation : ResidualDeltaConstruction.EntryPlan (ResidualDeltaConstruction.normalized data) storage.storage parameters frames

theorem attention_entry_source (data : ResidualAttentionConstruction.EntryStorage layer input) :
    data.entry.source.lhs=data.source := rfl

theorem attention_front_entry {entry : AttentionNormalizedMemory.Execution layer input}
    (front : ResidualAttentionConstruction.PrefixPlan entry angle) : front.build.entry=entry := rfl

theorem attention_input_front {front : ResidualAttentionMemory.Prefix layer input angle}
    (c : ResidualAttentionConstruction.CachePlan front cache) : c.input.front=front := rfl

theorem attention_input_storage {front : ResidualAttentionMemory.Prefix layer input angle}
    (c : ResidualAttentionConstruction.CachePlan front cache) : c.input.storage=c.storage := rfl

attribute [local irreducible] ResidualAttentionConstruction.CachePlan.input
  ResidualAttentionConstruction.ReadPlan.gates ResidualAttentionConstruction.ReadPlan.residual
  ResidualAttentionConstruction.TailPlan.weightsBefore ResidualAttentionConstruction.SuffixPlan.normBeforeTail
  ResidualAttentionConstruction.SuffixPlan.parametersBeforeTail
  ResidualAttentionConstruction.EntryStorage.entry
  ResidualAttentionConstruction.PrefixPlan.build ResidualAttentionConstruction.tail
  ResidualAttentionConstruction.DispatchPlan.attention ResidualAttentionConstruction.ReadPlan.input

section AttentionPlans
variable {layer : ResidualAttention.Layer} {n : Nat} {cache : State.Kv.Cache State.Kv.BF n}
  {input : Row BF} {angle : RopeAngles.Inputs}

structure AttentionSuffix {s : ResidualAttentionConstruction.Input layer cache input angle}
    {r : ResidualAttentionConstruction.ReadPlan s} {d : ResidualAttentionConstruction.DispatchPlan r}
    (tail : ResidualAttentionConstruction.TailPlan r d) (a : ResidualAttentionConstruction.TailAllocation tail) where
  parameters : ResidualAttentionConstruction.SuffixPlan tail a
  allocation : ResidualAttentionConstruction.SuffixAllocation parameters
  keys : ResidualMlpConstruction.RegionsSafe allocation
    (ResidualAttentionConstruction.tail tail a).afterCache.layout.keyBase (State.KvRegions.bytes (n+1))
  values : ResidualMlpConstruction.RegionsSafe allocation
    (ResidualAttentionConstruction.tail tail a).afterCache.layout.valueBase (State.KvRegions.bytes (n+1))

structure AttentionBody (s : ResidualAttentionConstruction.Input layer cache input angle) where
  readPlan : ResidualAttentionConstruction.ReadPlan s
  dispatch : ResidualAttentionConstruction.DispatchPlan readPlan
  tail : ResidualAttentionConstruction.TailPlan readPlan dispatch
  allocation : ResidualAttentionConstruction.TailAllocation tail
  finish : AttentionSuffix tail allocation

structure AttentionPlan (layer : ResidualAttention.Layer) (cache : State.Kv.Cache State.Kv.BF n) (input : Row BF)
    (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.StageBuffer (.attention layer) cache source.bytes) where
  data : ResidualAttentionConstruction.EntryStorage layer input
  sourceLinked : data.source=source
  front : ResidualAttentionConstruction.PrefixPlan data.entry angle
  caches : ResidualAttentionConstruction.CachePlan front.build cache
  cacheLinked : caches.storage=storage.storage
  body : AttentionBody caches.input

end AttentionPlans

-- A concrete stage sum of raw storage/allocation plans, never a supplied
-- completed stage execution or an arithmetic-output certificate.
def StagePlan : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → DecodeFrame.StageBuffer stage cache source.bytes → Type
  | .delta layer, cache, input, _, source, storage => DeltaPlan layer cache input source storage
  | .attention layer, cache, input, angle, source, storage => AttentionPlan layer cache input angle source storage

def stage : (kind : Stage) → (cache : Cache kind n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.StageBuffer kind cache source.bytes) →
    StagePlan kind cache input angle source storage → DecodeMemoryStage.Trace kind cache input angle source storage
  | .delta _, _, _, _, _, storage, plan => {
    execution := ResidualDeltaConstruction.fromStorage plan.data storage.storage plan.parameters plan.frames plan.allocation
    inputLinked := (ResidualDeltaConstruction.normalized_source plan.data).trans plan.sourceLinked
    cacheLinked := rfl }
  | .attention _, _, _, _, _, _, plan => {
    execution := ResidualAttentionConstruction.fromStorage plan.data plan.front plan.caches plan.body.readPlan plan.body.dispatch
      plan.body.tail plan.body.allocation plan.body.finish.parameters plan.body.finish.allocation plan.body.finish.keys plan.body.finish.values
    inputLinked := (congrArg (fun front => front.entry.source.lhs) (attention_input_front plan.caches)).trans
      ((congrArg (fun entry => entry.source.lhs) (attention_front_entry plan.front)).trans
      ((attention_entry_source plan.data).trans plan.sourceLinked))
    cacheLinked := (attention_input_storage plan.caches).trans plan.cacheLinked }

structure StepPlan (kind : Stage) (rest : List Stage) (cache : Caches (kind::rest) n)
    (input : Row BF) (angle : RopeAngles.Inputs) (source : ArrayStorage.BFBuffer input)
    (storage : DecodeFrame.Storage (kind::rest) cache source.bytes) where
  first : StagePlan kind cache.1 input angle source storage.1
  retained : DecodePreservation.Protected (stage kind cache.1 input angle source storage.1 first).Safe
    rest cache.2 source.bytes storage.2

def StepPlan.step (plan : StepPlan kind rest cache input angle source storage) :
    DecodeMemoryChain.Step kind rest cache input angle source storage :=
  ⟨stage kind cache.1 input angle source storage.1 plan.first,plan.retained⟩

-- The next plan is indexed by the actual predecessor's output buffer and
-- its derived reframe of every untouched cache.
def ChainPlan : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → DecodeFrame.Storage stages cache source.bytes → Type
  | [], _, _, _, _, _ => PUnit
  | kind::rest, cache, input, angle, source, storage =>
    (first : StepPlan kind rest cache input angle source storage) ×
      ChainPlan rest cache.2 (forward kind cache.1 input angle) angle first.step.first.buffer first.step.nextStorage

def chain : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    ChainPlan stages cache input angle source storage → DecodeMemoryChain.Trace stages cache input angle source storage
  | [], _, _, _, _, _, _ => ⟨⟩
  | kind::rest, cache, input, angle, _, _, plan =>
    ⟨plan.1.step,chain rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.2⟩

-- These premises only protect each newly updated cache's physical regions
-- from later writes. No cache value or final arithmetic equality is assumed.
def CacheRegions : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    ChainPlan stages cache input angle source storage → Prop
  | [], _, _, _, _, _, _ => True
  | kind::rest, cache, input, angle, _, _, plan =>
    DecodePreservation.StageProtected
      (DecodeMemoryChain.Safe rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage
        (chain rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.2))
      kind (cacheAfter kind cache.1 input angle) plan.1.step.first.cacheAfter.storage ∧
    CacheRegions rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.2

theorem cacheSafe : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (source : ArrayStorage.BFBuffer input) → (storage : DecodeFrame.Storage stages cache source.bytes) →
    (plan : ChainPlan stages cache input angle source storage) → CacheRegions stages cache input angle source storage plan →
    DecodeMemoryChain.CacheSafe stages cache input angle source storage (chain stages cache input angle source storage plan)
  | [], _, _, _, _, _, _, _ => True.intro
  | kind::rest, cache, input, angle, _, _, plan, safe =>
    ⟨safe.1,cacheSafe rest cache.2 (forward kind cache.1 input angle) angle plan.1.step.first.buffer plan.1.step.nextStorage plan.2 safe.2⟩

variable (stages : List Stage) (cache : Caches stages n) (input : Row BF) (angle : RopeAngles.Inputs)
  (source : ArrayStorage.BFBuffer input) (storage : DecodeFrame.Storage stages cache source.bytes)
  (plan : ChainPlan stages cache input angle source storage)

def outputBuffer : ArrayStorage.BFBuffer (DecodeChain.run stages cache input angle).1 :=
  DecodeMemoryChain.outputBuffer stages cache input angle source storage (chain stages cache input angle source storage plan)

def after (safe : CacheRegions stages cache input angle source storage plan) :
    DecodeFrame.Storage stages (DecodeChain.run stages cache input angle).2
      (outputBuffer stages cache input angle source storage plan).bytes :=
  DecodeMemoryChain.after stages cache input angle source storage (chain stages cache input angle source storage plan)
    (cacheSafe stages cache input angle source storage plan safe)

def readResult (safe : CacheRegions stages cache input angle source storage plan) : Row BF × Caches stages (n+1) :=
  DecodeMemoryChain.readResult stages cache input angle source storage (chain stages cache input angle source storage plan)
    (cacheSafe stages cache input angle source storage plan safe)

theorem read_result_eq (safe : CacheRegions stages cache input angle source storage plan) :
    readResult stages cache input angle source storage plan safe=DecodeChain.run stages cache input angle :=
  DecodeMemoryChain.read_result_eq stages cache input angle source storage (chain stages cache input angle source storage plan)
    (cacheSafe stages cache input angle source storage plan safe)

end Inference.Models.Qwen.DecodeMemoryConstruction
