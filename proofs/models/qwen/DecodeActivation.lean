import models.qwen.ResidualDeltaDevice
import models.qwen.ResidualAttentionDevice
import models.qwen.DecodeStorage

namespace Inference.Models.Qwen.DecodeActivation
open Contracts.Mlx DecodeStage DecodeChain Kernels.Attention
set_option maxRecDepth 10000

def StageExecution : (stage : Stage) → Cache stage n → Row BF → RopeAngles.Inputs → Type
  | .delta layer, cache, input, _ => ResidualDeltaDevice.Execution layer input cache
  | .attention layer, cache, input, angle => ResidualAttentionDevice.Execution layer input angle cache

def stageOutput : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    StageExecution stage cache input angle → Row BF
  | .delta _, _, _, _, execution => execution.output
  | .attention _, _, _, _, execution => execution.output

def stageInput : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    StageExecution stage cache input angle → ArrayStorage.BFBuffer input
  | .delta _, _, _, _, execution => execution.normalization.source
  | .attention _, _, _, _, execution => execution.normalization.source

def stageBefore : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    StageExecution stage cache input angle → DecodeStorage.StageStorage stage cache
  | .delta _, _, _, _, execution => execution.mixer.storage
  | .attention _, _, _, _, execution => execution.mixer.storage

theorem stage_eq (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : StageExecution stage cache input angle) : stageOutput stage cache input angle execution=forward stage cache input angle := by
  cases stage with
  | delta layer => exact execution.output_eq
  | attention layer => exact execution.output_eq

def stageOutputBuffer : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (execution : StageExecution stage cache input angle) → ArrayStorage.BFBuffer (stageOutput stage cache input angle execution)
  | .delta _, _, _, _, execution => execution.outputBuffer
  | .attention _, _, _, _, execution => execution.outputBuffer

def stageForwardBuffer (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : StageExecution stage cache input angle) : ArrayStorage.BFBuffer (forward stage cache input angle) :=
  ArrayViews.reindex (stage_eq stage cache input angle execution) (stageOutputBuffer stage cache input angle execution)

theorem stage_forward_bytes (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (execution : StageExecution stage cache input angle) :
    (stageForwardBuffer stage cache input angle execution).bytes=(stageOutputBuffer stage cache input angle execution).bytes :=
  ArrayViews.reindex_bytes _ _

private def reindexStorage {stage : Stage} {a b : Cache stage n} (equal : a=b)
    (storage : DecodeStorage.StageStorage stage a) : DecodeStorage.StageStorage stage b := by
  cases equal
  exact storage

def stageAfter : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    StageExecution stage cache input angle → DecodeStorage.StageStorage stage (cacheAfter stage cache input angle)
  | .delta _, _, _, _, execution => reindexStorage execution.cache_eq execution.storageAfter
  | .attention _, _, _, _, execution => reindexStorage execution.cache_eq execution.storageAfter

-- Both the original residual input and the input to normalization must be
-- the preceding stage's buffer. These are identities, not fit checks.
structure StageTrace (stage : Stage) (cache : Cache stage n) (input : Row BF) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.StageStorage stage cache) (source : ArrayStorage.BFBuffer input) where
  execution : StageExecution stage cache input angle
  before : stageBefore stage cache input angle execution=storage
  inputBuffer : stageInput stage cache input angle execution=source

def StageTrace.fromStorage : (stage : Stage) → (cache : Cache stage n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : DecodeStorage.StageStorage stage cache) → (source : ArrayStorage.BFBuffer input) → StageTrace stage cache input angle storage source
  | .delta layer, cache, input, _, storage, source =>
      ⟨ResidualDeltaDevice.Execution.fromStorage layer input cache storage source,
        ResidualDeltaDevice.Execution.fromStorage_cache _ _ _ _ _, ResidualDeltaDevice.Execution.fromStorage_input _ _ _ _ _⟩
  | .attention layer, cache, input, angle, storage, source =>
      ⟨ResidualAttentionDevice.Execution.fromStorage layer input angle cache storage source,
        ResidualAttentionDevice.Execution.fromStorage_cache _ _ _ _ _ _, ResidualAttentionDevice.Execution.fromStorage_input _ _ _ _ _ _⟩

theorem StageTrace.input_bytes (trace : StageTrace stage cache input angle storage source) :
    (stageInput stage cache input angle trace.execution).bytes=source.bytes := congrArg ArrayStorage.BFBuffer.bytes trace.inputBuffer

def ChainTrace : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → RopeAngles.Inputs →
    DecodeStorage.Storage stages cache → ArrayStorage.BFBuffer input → Type
  | [], _, _, _, _, _ => PUnit
  | stage::rest, cache, input, angle, storage, source =>
      (first : StageTrace stage cache.1 input angle storage.1 source) ×
        ChainTrace rest cache.2 (forward stage cache.1 input angle) angle storage.2
          (stageForwardBuffer stage cache.1 input angle first.execution)

def ChainTrace.fromStorage : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : DecodeStorage.Storage stages cache) → (source : ArrayStorage.BFBuffer input) → ChainTrace stages cache input angle storage source
  | [], _, _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, storage, source =>
      let first := StageTrace.fromStorage stage cache.1 input angle storage.1 source
      ⟨first, ChainTrace.fromStorage rest cache.2 (forward stage cache.1 input angle) angle storage.2
        (stageForwardBuffer stage cache.1 input angle first.execution)⟩

def outputBuffer : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : DecodeStorage.Storage stages cache) → (source : ArrayStorage.BFBuffer input) → ChainTrace stages cache input angle storage source →
      ArrayStorage.BFBuffer (DecodeChain.run stages cache input angle).1
  | [], _, _, _, _, source, _ => source
  | stage::rest, cache, input, angle, storage, _, trace =>
      outputBuffer rest cache.2 (forward stage cache.1 input angle) angle storage.2
        (stageForwardBuffer stage cache.1 input angle trace.1.execution) trace.2

def after : (stages : List Stage) → (cache : Caches stages n) → (input : Row BF) → (angle : RopeAngles.Inputs) →
    (storage : DecodeStorage.Storage stages cache) → (source : ArrayStorage.BFBuffer input) → ChainTrace stages cache input angle storage source →
      DecodeStorage.Storage stages (DecodeChain.run stages cache input angle).2
  | [], _, _, _, _, _, _ => ⟨⟩
  | stage::rest, cache, input, angle, storage, _, trace =>
      ⟨stageAfter stage cache.1 input angle trace.1.execution,
        after rest cache.2 (forward stage cache.1 input angle) angle storage.2
          (stageForwardBuffer stage cache.1 input angle trace.1.execution) trace.2⟩

theorem output_read (stages : List Stage) (cache : Caches stages n) (input : Row BF) (angle : RopeAngles.Inputs)
    (storage : DecodeStorage.Storage stages cache) (source : ArrayStorage.BFBuffer input)
    (trace : ChainTrace stages cache input angle storage source) (i : Fin 5120) :
    (outputBuffer stages cache input angle storage source trace).read i=(DecodeChain.run stages cache input angle).1 i :=
  ArrayStorage.BFBuffer.read_correct _ _

theorem next_input_bytes (stage next : Stage) (rest : List Stage) (cache : Caches (stage::next::rest) n)
    (input : Row BF) (angle : RopeAngles.Inputs) (storage : DecodeStorage.Storage (stage::next::rest) cache)
    (source : ArrayStorage.BFBuffer input) (trace : ChainTrace (stage::next::rest) cache input angle storage source) :
    (stageInput next cache.2.1 (forward stage cache.1 input angle) angle trace.2.1.execution).bytes=
      (stageOutputBuffer stage cache.1 input angle trace.1.execution).bytes := by
  rw [trace.2.1.inputBuffer]
  exact stage_forward_bytes stage cache.1 input angle trace.1.execution

end Inference.Models.Qwen.DecodeActivation
