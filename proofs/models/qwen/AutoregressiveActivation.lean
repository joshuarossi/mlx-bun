import models.qwen.TokenActivation

namespace Inference.Models.Qwen.AutoregressiveActivation
open Contracts.Mlx TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000

structure State (p : Pipeline) (time : Nat) where
  logical : TokenAutoregressive.State p time
  storage : DecodeStorage.Storage p.graph.stages logical.cache

abbrev Schedules (p : Pipeline) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320) (storage : DecodeStorage.Storage p.graph.stages cache),
    TokenActivation.Execution p cache token (angles.value time) storage

def Schedules.fromStorage (p : Pipeline) (angles : TokenAutoregressive.Angles)
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) : Schedules p angles :=
  fun _ cache token storage => TokenActivation.Execution.fromStorage p cache token _ storage weights

def initial (p : Pipeline) (token : Fin 248320) : State p 0 :=
  let logical := TokenAutoregressive.initial p token
  ⟨logical, DecodeStorage.Storage.canonical p.graph.stages logical.cache⟩

theorem read_logits (execution : TokenActivation.Execution p cache token angle storage) :
    execution.logitsBuffer.read=(p.run cache token angle).1 := by
  funext i
  rw [ArrayStorage.BFBuffer.read_correct, execution.logits_eq]

-- Sampling consumes the output projection's actual BF16 readback. The
-- selected token and the attached cache stores then feed the next step.
-- Sampling's internal scratch execution is still its existing source model.
noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenActivation.Execution p before.logical.cache before.logical.token angle before.storage) : State p (time+1) := by
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb
  have tokenEq : GreedySampling.sample sampling execution.logitsBuffer.read=reference.token.val := by
    rw [read_logits]
    rfl
  have cacheEq : execution.run.2=reference.cache := rfl
  let logical : TokenAutoregressive.State p (time+1) := {
    token := ⟨GreedySampling.sample sampling execution.logitsBuffer.read, by rw [tokenEq]; exact reference.token.isLt⟩
    cache := execution.run.2
    cacheBound := by rw [cacheEq]; exact reference.cacheBound
    targetCache := reference.targetCache
    errorCache := reference.errorCache
    cacheError := by rw [cacheEq]; exact reference.cacheError
  }
  exact ⟨logical, execution.after⟩

private theorem state_eq (a b : TokenAutoregressive.State p time) (token : a.token=b.token) (cache : a.cache=b.cache)
    (target : a.targetCache=b.targetCache) (error : a.errorCache=b.errorCache) : a=b := by
  cases a
  cases b
  cases token
  cases cache
  cases target
  cases error
  rfl

theorem advance_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenActivation.Execution p before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb := by
  apply state_eq
  · apply Fin.ext
    simp only [advance, read_logits]
    rfl
  · rfl
  · rfl
  · rfl

theorem advance_storage (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenActivation.Execution p before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution).storage=execution.after := rfl

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p angles) :
    (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => initial p token
  | time+1, supported =>
    let before := run p parameters primitive sampling samplingPrimitive token angles schedules time (by omega)
    advance p parameters primitive sampling samplingPrimitive before (angles.value time) (angles.ranges time (by omega))
      supported (angles.target time) (angles.error time) (angles.accuracy time (by omega)) (angles.base time (by omega))
      (schedules time before.logical.cache before.logical.token before.storage)

theorem run_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (schedules : Schedules p angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles schedules steps supported).logical=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ time ih => simp only [run, advance_logical, ih, TokenAutoregressive.run]

theorem schedule_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (a b : Schedules p angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p parameters primitive sampling samplingPrimitive token angles a steps supported).logical=
      (run p parameters primitive sampling samplingPrimitive token angles b steps supported).logical := by
  rw [run_logical, run_logical]

theorem checkpoint_logical (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : Schedules p RopeInputConstruction.angles) (steps : Nat) (supported : steps ≤ 262144) :
    (run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) primitive sampling samplingPrimitive
      token RopeInputConstruction.angles schedules steps supported).logical=
      Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token steps supported :=
  run_logical p _ primitive sampling samplingPrimitive token RopeInputConstruction.angles schedules steps supported

end Inference.Models.Qwen.AutoregressiveActivation
