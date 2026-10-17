import models.qwen.DecodeStorage

namespace Inference.Models.Qwen.AutoregressiveStorage
open TokenInference Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000

abbrev implementation := DecodeStorage.implementation

structure State (p : Pipeline) (time : Nat) where
  logical : TokenAutoregressive.State p time
  storage : DecodeStorage.Storage p.graph.stages logical.cache

abbrev Schedules (p : Pipeline) (angles : TokenAutoregressive.Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320) (storage : DecodeStorage.Storage p.graph.stages cache),
    DecodeStorage.PipelineTrace p cache token (angles.value time) storage

def Schedules.canonical (p : Pipeline) (angles : TokenAutoregressive.Angles) : Schedules p angles :=
  fun _ cache token storage => DecodeStorage.ChainTrace.canonical p.graph.stages cache (p.embedding.forward token) _ storage

noncomputable def initial (p : Pipeline) (token : Fin 248320) : State p 0 :=
  let logical := TokenAutoregressive.initial p token
  ⟨logical, DecodeStorage.Storage.canonical p.graph.stages logical.cache⟩

-- The numerical state still carries its proved bounds and error envelopes.
-- The attached bytes now travel with it; the next trace must use those same
-- bytes at every Delta and attention stage.
noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (trace : DecodeStorage.PipelineTrace p before.logical.cache before.logical.token angle before.storage) : State p (time+1) :=
  let execution := DecodeStorage.pipelineTrace p before.logical.cache before.logical.token angle before.storage trace
  let logical := AutoregressiveImplementation.advance implementation p parameters primitive sampling samplingPrimitive
    before.logical angle ha supported aim ae he hb execution
  ⟨logical, DecodeStorage.pipelineAfter p before.logical.cache before.logical.token angle before.storage trace⟩

theorem advance_logical (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (trace : DecodeStorage.PipelineTrace p before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb trace).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical angle ha supported aim ae he hb :=
  AutoregressiveImplementation.advance_eq implementation p parameters primitive sampling samplingPrimitive
    before.logical angle ha supported aim ae he hb _

theorem advance_storage (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (trace : DecodeStorage.PipelineTrace p before.logical.cache before.logical.token angle before.storage) :
    (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb trace).storage=
      DecodeStorage.pipelineAfter p before.logical.cache before.logical.token angle before.storage trace := rfl

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

end Inference.Models.Qwen.AutoregressiveStorage
