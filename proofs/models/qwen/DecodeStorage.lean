import models.qwen.Qwen38TrellisM1MaxDevice

namespace Inference.Models.Qwen.DecodeStorage
open DecodeStage DecodeChain TokenInference Kernels.Attention
set_option maxRecDepth 10000

abbrev implementation := Qwen38TrellisM1MaxDevice.implementation

-- KV and Delta recurrent-state bytes travel beside the logical graph cache.
-- Each stage consumes its previous buffers and returns its actual stores.
def StageStorage : (stage : Stage) → Cache stage n → Type
  | .delta _, cache => DeltaDevice.Storage cache
  | .attention _, cache => State.KvAllocation.Storage cache

def Storage : (stages : List Stage) → Caches stages n → Type
  | [], _ => PUnit
  | stage::rest, cache => StageStorage stage cache.1 × Storage rest cache.2

def Storage.canonical : (stages : List Stage) → (cache : Caches stages n) → Storage stages cache
  | [], _ => ⟨⟩
  | .delta _::rest, cache => ⟨DeltaDevice.Storage.canonical cache.1, Storage.canonical rest cache.2⟩
  | .attention _::rest, cache => ⟨State.KvAllocation.Storage.canonical cache.1, Storage.canonical rest cache.2⟩

private def reindex (a b : State.Kv.Cache BF n) (equal : a=b) (storage : State.KvAllocation.Storage a) :
    State.KvAllocation.Storage b := by
  cases equal
  exact storage

private theorem reindex_keys (a b : State.Kv.Cache BF n) (equal : a=b) (storage : State.KvAllocation.Storage a) :
    (reindex a b equal storage).keys=storage.keys := by cases equal; rfl

private theorem reindex_values (a b : State.Kv.Cache BF n) (equal : a=b) (storage : State.KvAllocation.Storage a) :
    (reindex a b equal storage).values=storage.values := by cases equal; rfl

def Before : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    DecodeImplementation.StageTrace implementation stage cache input angle → StageStorage stage cache → Prop
  | .delta _, _, _, _, execution, storage => execution.1.storage=storage
  | .attention _, _, _, _, execution, storage => execution.1.storage=storage

structure StageTrace (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (storage : StageStorage stage cache) where
  execution : DecodeImplementation.StageTrace implementation stage cache input angle
  before : Before stage cache input angle execution storage

def StageTrace.canonical : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : StageStorage stage cache) → StageTrace stage cache input angle storage
  | .delta layer, cache, input, _, storage =>
      let first := DeltaDevice.Execution.fromStorage layer.mixer (layer.inputNorm.forward input) cache storage
      let mixed := DeltaExecution.mixed implementation.delta layer input cache first
      ⟨⟨first, implementation.mlp.canonical layer.suffix.mlp (layer.suffix.inputBits input mixed)⟩, rfl⟩
  | .attention layer, cache, input, angle, storage =>
      let first := AttentionDevice.Execution.fromStorage layer.mixer (layer.inputNorm.forward input) angle cache storage
      let mixed := AttentionExecution.mixed implementation.attention layer input angle cache first
      ⟨⟨first, implementation.mlp.canonical layer.suffix.mlp (layer.suffix.inputBits input mixed)⟩, rfl⟩

def stageAfter : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : DecodeImplementation.StageTrace implementation stage cache input angle) →
      StageStorage stage (DecodeImplementation.stageCache implementation stage cache input angle execution)
  | .delta layer, cache, input, _, execution =>
      DeltaDevice.storageAfter layer.mixer (layer.inputNorm.forward input) cache execution.1
  | .attention layer, cache, input, angle, execution =>
      reindex (layer.cacheAfter input angle cache)
        (AttentionExecution.cacheAfter implementation.attention layer input angle cache execution.1)
        (AttentionExecution.cache_eq implementation.attention layer input angle cache execution.1).symm
        (AttentionDevice.storageAfter layer.mixer (layer.inputNorm.forward input) angle cache execution.1)

theorem before_recurrent (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF)
    (angle : RopeAngles.Inputs) (storage : DeltaDevice.Storage cache)
    (trace : StageTrace (.delta layer) (n := n) cache input angle storage) : trace.execution.1.storage.recurrent.bytes=storage.recurrent.bytes :=
  congrArg (fun s : DeltaDevice.Storage cache => s.recurrent.bytes) trace.before

theorem after_recurrent (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF)
    (angle : RopeAngles.Inputs) (execution : DecodeImplementation.StageTrace implementation (.delta layer) (n := n) cache input angle) :
    (stageAfter (.delta layer) cache input angle execution).recurrent.bytes=execution.1.recurrence.stores.stateMemory := rfl

theorem before_history (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF)
    (angle : RopeAngles.Inputs) (storage : DeltaDevice.Storage cache)
    (trace : StageTrace (.delta layer) (n := n) cache input angle storage) : trace.execution.1.storage.history.bytes=storage.history.bytes :=
  congrArg (fun s : DeltaDevice.Storage cache => s.history.bytes) trace.before

theorem after_history (layer : ResidualDelta.Layer) (cache : DeltaNet.Cache) (input : Row BF)
    (angle : RopeAngles.Inputs) (execution : DecodeImplementation.StageTrace implementation (.delta layer) (n := n) cache input angle) :
    (stageAfter (.delta layer) cache input angle execution).history.bytes=
      execution.1.convolution.convolution.convolution.tail.memory := rfl

theorem before_keys (layer : ResidualAttention.Layer) (cache : State.Kv.Cache BF n) (input : Row BF)
    (angle : RopeAngles.Inputs) (storage : State.KvAllocation.Storage cache)
    (trace : StageTrace (.attention layer) cache input angle storage) : trace.execution.1.storage.keys=storage.keys :=
  congrArg State.KvAllocation.Storage.keys trace.before

theorem before_values (layer : ResidualAttention.Layer) (cache : State.Kv.Cache BF n) (input : Row BF)
    (angle : RopeAngles.Inputs) (storage : State.KvAllocation.Storage cache)
    (trace : StageTrace (.attention layer) cache input angle storage) : trace.execution.1.storage.values=storage.values :=
  congrArg State.KvAllocation.Storage.values trace.before

theorem after_keys (layer : ResidualAttention.Layer) (cache : State.Kv.Cache BF n) (input : Row BF)
    (angle : RopeAngles.Inputs) (execution : DecodeImplementation.StageTrace implementation (.attention layer) cache input angle) :
    (stageAfter (.attention layer) cache input angle execution).keys=execution.1.updated.toKvBytes.keys.memory := by
  exact reindex_keys (layer.cacheAfter input angle cache)
    (AttentionExecution.cacheAfter implementation.attention layer input angle cache execution.1)
    (AttentionExecution.cache_eq implementation.attention layer input angle cache execution.1).symm
    (AttentionDevice.storageAfter layer.mixer (layer.inputNorm.forward input) angle cache execution.1)

theorem after_values (layer : ResidualAttention.Layer) (cache : State.Kv.Cache BF n) (input : Row BF)
    (angle : RopeAngles.Inputs) (execution : DecodeImplementation.StageTrace implementation (.attention layer) cache input angle) :
    (stageAfter (.attention layer) cache input angle execution).values=execution.1.updated.toKvBytes.values.memory := by
  exact reindex_values (layer.cacheAfter input angle cache)
    (AttentionExecution.cacheAfter implementation.attention layer input angle cache execution.1)
    (AttentionExecution.cache_eq implementation.attention layer input angle cache execution.1).symm
    (AttentionDevice.storageAfter layer.mixer (layer.inputNorm.forward input) angle cache execution.1)

def ChainTrace : (stages : List Stage) → (cache : Caches stages n) → Row BF → RopeAngles.Inputs → Storage stages cache → Type
  | [], _, _, _, _ => PUnit
  | stage::rest, cache, input, angle, storage =>
      (first : StageTrace stage cache.1 input angle storage.1) ×
        ChainTrace rest cache.2 (DecodeImplementation.stageForward implementation stage cache.1 input angle first.execution) angle storage.2

def ChainTrace.canonical : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : Storage stages cache) → ChainTrace stages cache input angle storage
  | [], _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, storage =>
      let first := StageTrace.canonical stage cache.1 input angle storage.1
      ⟨first, ChainTrace.canonical rest cache.2
        (DecodeImplementation.stageForward implementation stage cache.1 input angle first.execution) angle storage.2⟩

def forget : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : Storage stages cache) → ChainTrace stages cache input angle storage →
      DecodeImplementation.ChainTrace implementation stages cache input angle
  | [], _, _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, storage, trace =>
      ⟨trace.1.execution, forget rest cache.2
        (DecodeImplementation.stageForward implementation stage cache.1 input angle trace.1.execution) angle storage.2 trace.2⟩

def after : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : Storage stages cache) → (trace : ChainTrace stages cache input angle storage) →
      Storage stages (DecodeImplementation.chain implementation stages cache input angle (forget stages cache input angle storage trace)).2
  | [], _, _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, storage, trace =>
      ⟨stageAfter stage cache.1 input angle trace.1.execution,
        after rest cache.2 (DecodeImplementation.stageForward implementation stage cache.1 input angle trace.1.execution) angle storage.2 trace.2⟩

abbrev PipelineTrace (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : Storage p.graph.stages cache) := ChainTrace p.graph.stages cache (p.embedding.forward token) angle storage

def pipelineTrace (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : Storage p.graph.stages cache) (trace : PipelineTrace p cache token angle storage) :
    DecodeImplementation.PipelineTrace implementation p cache token angle :=
  forget p.graph.stages cache (p.embedding.forward token) angle storage trace

def pipelineAfter (p : Pipeline) (cache : p.graph.Cache n) (token : Fin 248320) (angle : RopeAngles.Inputs)
    (storage : Storage p.graph.stages cache) (trace : PipelineTrace p cache token angle storage) :
    Storage p.graph.stages (DecodeImplementation.pipeline implementation p cache token angle (pipelineTrace p cache token angle storage trace)).2 :=
  after p.graph.stages cache (p.embedding.forward token) angle storage trace

end Inference.Models.Qwen.DecodeStorage
