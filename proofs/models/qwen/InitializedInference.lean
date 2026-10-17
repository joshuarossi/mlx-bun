import models.qwen.AutoregressiveTokenStorage
import models.qwen.InitialCacheMemory

namespace Inference.Models.Qwen.InitializedInference
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000

-- Initial cache buffers all refer to the shared memory left by the complete
-- sequence of zero-fill programs. The caller's
-- attached input token buffer supplies the first embedding index; later
-- indices come from the preceding sampler's uint32 stores.
def initial (p : Pipeline) (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) : AutoregressiveTokenStorage.State p 0 :=
  ⟨⟨TokenAutoregressive.initial p token, InitialCacheMemory.initialized p.graph.stages plan before⟩, index⟩

theorem initial_storage (p : Pipeline) (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) :
    (initial p token plan before index).device.storage=InitialCacheMemory.initialized p.graph.stages plan before := rfl

theorem initial_index_bytes (p : Pipeline) (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes)
    (index : Inference.State.TokenStorage.Buffer token) : (initial p token plan before index).index.bytes=index.bytes := rfl

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes) (index : Inference.State.TokenStorage.Buffer token)
    (angles : TokenAutoregressive.Angles) (schedules : AutoregressiveTokenStorage.Schedules p sampling angles) :
    (steps : Nat) → steps ≤ 262144 → AutoregressiveTokenStorage.State p steps
  | 0, _ => initial p token plan before index
  | time+1, supported =>
    let before := run p parameters primitive sampling samplingPrimitive token plan before index angles schedules time (by omega)
    AutoregressiveTokenStorage.advance p parameters primitive sampling samplingPrimitive before
      (angles.value time) (angles.ranges time (by omega)) supported
      (angles.target time) (angles.error time) (angles.accuracy time (by omega)) (angles.base time (by omega))
      (schedules time before.device.logical.cache before.device.logical.token before.device.storage before.index)

theorem run_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes) (index : Inference.State.TokenStorage.Buffer token)
    (angles : TokenAutoregressive.Angles) (schedules : AutoregressiveTokenStorage.Schedules p sampling angles)
    (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token plan before index angles schedules steps supported).device.logical=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ time ih => simp only [run, AutoregressiveTokenStorage.advance_logical, ih, TokenAutoregressive.run]

-- Both initial memory contents and all legal store schedules may vary.
-- Their initialized values and the complete emitted-token/cache result agree.
theorem initialization_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (first second : InitialCacheMemory.Plan p.graph.stages) (beforeFirst beforeSecond : ByteMemory.Bytes)
    (a b : Inference.State.TokenStorage.Buffer token) (angles : TokenAutoregressive.Angles)
    (left right : AutoregressiveTokenStorage.Schedules p sampling angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token first beforeFirst a angles left steps supported).device.logical=
      (run p parameters primitive sampling samplingPrimitive token second beforeSecond b angles right steps supported).device.logical := by
  rw [run_logical, run_logical]

theorem token_read (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes) (index : Inference.State.TokenStorage.Buffer token)
    (angles : TokenAutoregressive.Angles) (schedules : AutoregressiveTokenStorage.Schedules p sampling angles)
    (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token plan before index angles schedules steps supported).index.read=
      (TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported).token.val := by
  rw [Inference.State.TokenStorage.Buffer.read_correct, run_logical]

theorem checkpoint_logical (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (plan : InitialCacheMemory.Plan p.graph.stages) (before : ByteMemory.Bytes) (index : Inference.State.TokenStorage.Buffer token)
    (schedules : AutoregressiveTokenStorage.Schedules p sampling RopeInputConstruction.angles)
    (steps : Nat) (supported : steps ≤ 262144) :
    (run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
      token plan before index RopeInputConstruction.angles schedules steps supported).device.logical=
      Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token steps supported :=
  run_logical p _ primitive sampling samplingPrimitive token plan before index RopeInputConstruction.angles schedules steps supported

end Inference.Models.Qwen.InitializedInference
