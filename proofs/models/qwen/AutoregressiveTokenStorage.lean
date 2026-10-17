import models.qwen.AutoregressiveDevice
import layers.QuantizedEmbeddingIndex

namespace Inference.Models.Qwen.AutoregressiveTokenStorage
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000

structure State (p : Pipeline) (time : Nat) where
  device : AutoregressiveDevice.State p time
  index : Inference.State.TokenStorage.Buffer device.logical.token

abbrev Schedules (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320) (storage : DecodeStorage.Storage p.graph.stages cache)
    (_index : Inference.State.TokenStorage.Buffer token), TokenDevice.Execution p sampling cache token (angles.value time) storage

def Schedules.fromStorage (p : Pipeline) (sampling : LogSumExpRanges.Platform) (angles : TokenAutoregressive.Angles)
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) : Schedules p sampling angles :=
  fun _ cache token storage index =>
    let embedding := Layers.QuantizedEmbeddingIndex.Execution.fromStorage p.embedding token index weights
    let inference := TokenActivation.Execution.fromEmbedding p cache token _ storage embedding.embedding
    TokenDevice.Execution.fromInference p sampling cache token _ storage inference

def initial (p : Pipeline) (token : Fin 248320) : State p 0 :=
  ⟨AutoregressiveDevice.initial p token, Inference.State.TokenStorage.Buffer.canonical token⟩

-- This view exposes the exact raw token loads used by all three embedding
-- gathers. Their store programs are proved equal to those in the execution.
def embeddingTrace (index : Inference.State.TokenStorage.Buffer token)
    (execution : TokenDevice.Execution p sampling cache token angle storage) : Layers.QuantizedEmbeddingIndex.Execution p.embedding token :=
  ⟨index, execution.inference.embedding⟩

theorem embedding_packed (index : Inference.State.TokenStorage.Buffer token)
    (execution : TokenDevice.Execution p sampling cache token angle storage) :
    ThreadgroupWrites.Executes
      (WordArrayWrites.programs 0 (Layers.QuantizedEmbeddingIndex.packedLoads execution.inference.embedding.storage index))
      execution.inference.embedding.take.packed.schedule execution.inference.embedding.take.packed.remaining :=
  (embeddingTrace index execution).packed_trace

noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.device.logical.cache before.device.logical.token angle before.device.storage) : State p (time+1) :=
  let device := AutoregressiveDevice.advance p parameters primitive sampling samplingPrimitive before.device angle ha supported aim ae he hb execution
  let index := Inference.State.TokenStorage.Buffer.fromRead device.logical.token execution.selection.selection.output.memory 0
    (by decide) (by decide)
    (AutoregressiveDevice.advance_token_read p parameters primitive sampling samplingPrimitive before.device angle ha supported aim ae he hb execution).symm
  ⟨device, index⟩

theorem advance_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.device.logical.cache before.device.logical.token angle before.device.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).device.logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.device.logical angle ha supported aim ae he hb :=
  AutoregressiveDevice.advance_logical p parameters primitive sampling samplingPrimitive before.device angle ha supported aim ae he hb execution

theorem advance_index_bytes (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenDevice.Execution p sampling before.device.logical.cache before.device.logical.token angle before.device.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).index.bytes=
      execution.selection.selection.output.memory := rfl

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) :
    (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => initial p token
  | time+1, supported =>
    let before := run p parameters primitive sampling samplingPrimitive token angles schedules time (by omega)
    advance p parameters primitive sampling samplingPrimitive before (angles.value time) (angles.ranges time (by omega))
      supported (angles.target time) (angles.error time) (angles.accuracy time (by omega)) (angles.base time (by omega))
      (schedules time before.device.logical.cache before.device.logical.token before.device.storage before.index)

theorem run_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p sampling angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles schedules steps supported).device.logical=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ time ih => simp only [run, advance_logical, ih, TokenAutoregressive.run]

theorem schedule_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (a b : Schedules p sampling angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles a steps supported).device.logical=
      (run p parameters primitive sampling samplingPrimitive token angles b steps supported).device.logical := by
  rw [run_logical, run_logical]

theorem checkpoint_logical (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : Schedules p sampling RopeInputConstruction.angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
      token RopeInputConstruction.angles schedules steps supported).device.logical=
      Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token steps supported :=
  run_logical p _ primitive sampling samplingPrimitive token RopeInputConstruction.angles schedules steps supported

end Inference.Models.Qwen.AutoregressiveTokenStorage
