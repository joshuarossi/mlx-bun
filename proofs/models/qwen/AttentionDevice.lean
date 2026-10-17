import models.qwen.AttentionExecution
import kernels.attention.SdpaDispatchedDevice
import state.KvDevice
import models.qwen.AttentionReadStorage
import kernels.attention.OutputGateDevice
import layers.AffineDevice

namespace Inference.Models.Qwen.AttentionDevice
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 10000

structure Execution (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) where
  storage : State.KvAllocation.Storage cache
  heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle
  updated : State.KvDevice.Execution storage (layer.heads input angle).key (layer.heads input angle).value
  keySource : updated.keys.source=heads.keySource
  valueSource : updated.values.source=heads.valueSource
  attention : SdpaLoads.Execution layer.attention layer.mergeContracted layer.architectureSuffix
    (layer.heads input angle).query (State.KvBytes.cacheAfter updated.toKvBytes).keys (State.KvBytes.cacheAfter updated.toKvBytes).values
  inputBuffers : attention.storage=AttentionReadStorage.fromCache layer input angle heads updated
  gate : OutputGateDevice.Execution layer.gate attention.output (layer.heads input angle).gate
  gateInput : gate.storage.source=attention.outputBuffer
  gateProjection : gate.storage.gate=heads.gateBuffer
  projection : Layers.AffineDevice.Execution (groups := 1280) layer.output gate.output
  projectionInput : projection.inputStorage=gate.outputBuffer

def Execution.fromHeads (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache)
    (heads : AttentionHeadsDevice.Execution layer.projections layer.preparation input angle)
    (weights : Layers.AffineDevice.Storage layer.output) : Execution layer input angle cache :=
  let updated := State.KvSources.fromSources storage (layer.heads input angle).key (layer.heads input angle).value heads.keySource heads.valueSource
  let inputs := AttentionReadStorage.fromCache layer input angle heads updated
  let attention := SdpaLoads.Execution.fromStorage layer.attention layer.mergeContracted layer.architectureSuffix
    (layer.heads input angle).query (State.KvBytes.cacheAfter updated.toKvBytes).keys (State.KvBytes.cacheAfter updated.toKvBytes).values inputs
  let gateStorage : OutputGateDevice.Storage attention.output (layer.heads input angle).gate :=
    ⟨attention.outputBuffer, heads.gateBuffer⟩
  let gate := OutputGateDevice.Execution.fromStorage layer.gate attention.output (layer.heads input angle).gate gateStorage
  let projection := Layers.AffineDevice.Execution.fromStorage (groups := 1280) layer.output gate.output weights gate.outputBuffer (by decide)
  ⟨storage, heads, updated, rfl, rfl, attention, rfl, gate, rfl, rfl, projection,
    Layers.AffineDevice.Execution.input_fromStorage _ _ _⟩

def Execution.fromBuffers (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache) (source : ArrayStorage.BFBuffer input)
    (weights : AttentionAffine.Weights layer.projections) (outputWeights : Layers.AffineDevice.Storage layer.output) :
    Execution layer input angle cache :=
  Execution.fromHeads layer input angle cache storage
    (AttentionHeadsDevice.Execution.fromStorage layer.projections layer.preparation input angle source weights) outputWeights

def Execution.fromStorage (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (storage : State.KvAllocation.Storage cache) : Execution layer input angle cache :=
  Execution.fromBuffers layer input angle cache storage (ArrayStorage.BFBuffer.canonical _ (by decide))
    (AttentionAffine.Weights.canonical layer.projections)
    (Layers.AffineDevice.Storage.canonical _ (by decide) (by decide) (by decide))

def Execution.canonical (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) : Execution layer input angle cache :=
  Execution.fromStorage layer input angle cache (State.KvAllocation.Storage.canonical cache)

def read (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) : Fin 24 → Fin 256 → BF :=
  execution.attention.output

theorem read_eq (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    read layer input angle cache execution=layer.read input angle cache := by
  funext head i
  unfold read
  rw [execution.attention.output_eq, State.KvBytes.cacheAfter_eq]
  rfl

def merged (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) : Fin 6144 → BF := execution.gate.output

theorem merged_eq (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    merged layer input angle cache execution=layer.merged input angle cache := by
  unfold merged
  rw [execution.gate.output_eq]
  funext i
  change OutputGate.forward layer.gate (read layer input angle cache execution (Attention.headIndex i) (Attention.coordinate i))
    ((layer.heads input angle).gate (Attention.headIndex i) (Attention.coordinate i))=_
  rw [read_eq]
  rfl

def forward (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) : Fin 5120 → BF :=
  execution.projection.output

theorem forward_eq (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    forward layer input angle cache execution=layer.forward input angle cache := by
  unfold forward
  rw [execution.projection.output_eq]
  change layer.output.forward (merged layer input angle cache execution)=_
  rw [merged_eq]
  rfl

def inputStorage (execution : Execution layer input angle cache) : ArrayStorage.BFBuffer input := execution.heads.projections.source

def outputStorage (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    ArrayStorage.BFBuffer (forward layer input angle cache execution) := execution.projection.outputBuffer

theorem attention_key_bytes (execution : Execution layer input angle cache) :
    execution.attention.storage.keys.bytes=execution.updated.toKvBytes.keys.memory := by
  rw [execution.inputBuffers]
  rfl

theorem attention_value_bytes (execution : Execution layer input angle cache) :
    execution.attention.storage.values.bytes=execution.updated.toKvBytes.values.memory := by
  rw [execution.inputBuffers]
  rfl

theorem gate_input_bytes (execution : Execution layer input angle cache) (head : Fin 24) :
    (execution.gate.storage.source head).bytes=execution.attention.kernel.output.memory := by
  rw [execution.gateInput]
  rfl

theorem projection_input_bytes (execution : Execution layer input angle cache) :
    execution.projection.inputStorage.bytes=execution.gate.stores.memory :=
  congrArg ArrayStorage.BFBuffer.bytes execution.projectionInput

-- Attention consumes and returns the same appended bytes. KV traces include
-- zero fill, concurrent growth copies, donation/vector-copy preservation and
-- the strided slice update. Allocator, dispatch/visibility and compiler
-- correspondence must still implement these translated execution models.
def run (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) : (Fin 5120 → BF) × State.Kv.Cache BF (n+1) :=
  (forward layer input angle cache execution, State.KvBytes.cacheAfter execution.updated.toKvBytes)

theorem run_eq (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    run layer input angle cache execution=(layer.forward input angle cache, layer.cacheAfter input angle cache) := by
  unfold run
  rw [forward_eq, State.KvBytes.cacheAfter_eq]
  rfl

def storageAfter (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    State.KvAllocation.Storage (layer.cacheAfter input angle cache) := execution.updated.after

theorem storage_keys (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    (storageAfter layer input angle cache execution).keys=execution.updated.toKvBytes.keys.memory := rfl

theorem storage_values (layer : Attention.Layer) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs)
    (cache : State.Kv.Cache BF n) (execution : Execution layer input angle cache) :
    (storageAfter layer input angle cache execution).values=execution.updated.toKvBytes.values.memory := rfl

def implementation : AttentionExecution.Implementation where
  Trace := Execution
  run := run
  refines := run_eq
  canonical := Execution.canonical

theorem forward_error (layer : Attention.Layer) (input : Fin 5120 → BF) (target error : Fin 5120 → ℝ)
    (angle : RopeAngles.Inputs) (angleTarget angleError : RopeAngles.Target)
    (cache : State.Kv.Cache BF n) (cacheTarget cacheError : State.Kv.Cache ℝ n) (execution : Execution layer input angle cache)
    (hi : ∀ i, |Model.toReal (input i)-target i| ≤ error i) (hc : State.Kv.Error cache cacheTarget cacheError)
    (hcf : State.Kv.Finite cache) (hf : layer.Finite input angle cache)
    (ha : RopeAngles.InputError angle angleTarget angleError) (hb : 0 ≤ angleTarget.base) (i : Fin 5120) :
    |Model.toReal (forward layer input angle cache execution i)-layer.target target angleTarget cacheTarget i| ≤
      layer.budget input target error angle angleTarget angleError cache cacheTarget cacheError i := by
  rw [forward_eq]
  exact layer.forward_error input target error angle angleTarget angleError cache cacheTarget cacheError hi hc hcf hf ha hb i

end Inference.Models.Qwen.AttentionDevice
