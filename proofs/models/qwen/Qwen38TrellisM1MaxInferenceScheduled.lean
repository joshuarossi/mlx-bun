import models.qwen.TokenAutoregressiveScheduled

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxInferenceScheduled
open Contracts.Mlx Kernels.Sampling TokenInference
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- The entry uses the proved checkpoint parameter attachments and constructed
-- position inputs. Scheduled Trellis storage is refined inside the loop;
-- the existing primitive and native-correspondence obligations still apply.
noncomputable def run (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : TokenAutoregressiveScheduled.Schedules p RopeInputConstruction.angles)
    (steps : Nat) (supported : steps ≤ 262144) : TokenAutoregressive.State p steps :=
  TokenAutoregressiveScheduled.run p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive token RopeInputConstruction.angles schedules steps supported

theorem run_eq (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : TokenAutoregressiveScheduled.Schedules p RopeInputConstruction.angles)
    (steps : Nat) (supported : steps ≤ 262144) :
    run p encoded binding primitive sampling samplingPrimitive token schedules steps supported=
      Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token steps supported :=
  TokenAutoregressiveScheduled.run_eq p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive token RopeInputConstruction.angles schedules steps supported

theorem step_correct (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : TokenAutoregressiveScheduled.Schedules p RopeInputConstruction.angles)
    (time : Nat) (supported : time+1 ≤ 262144) :
    let parameters := CheckpointDictionaryBinding.pipeline_parameters p encoded binding
    let before := run p encoded binding primitive sampling samplingPrimitive token schedules time (by omega)
    let after := run p encoded binding primitive sampling samplingPrimitive token schedules (time+1) supported
    let logits := (TokenInferenceScheduled.run p before.cache before.token (RopeInputConstruction.angles.value time)
      (schedules time before.cache before.token)).1
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (RopeInputConstruction.target time)).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (RopeInputConstruction.inputs time) (RopeInputConstruction.inputs_bound time (by omega))
          supported (RopeInputConstruction.target time) RopeInputConstruction.error).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite=true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token=GreedySampling.score sampling logits i → after.token.val ≤ i.val) := by
  dsimp only
  rw [TokenInferenceScheduled.run_eq]
  simp only [run_eq]
  simpa only [TokenSampledSequenceRanges.logits, RopeInputConstruction.angles] using
    Qwen38TrellisM1MaxInference.step_correct p encoded binding primitive sampling samplingPrimitive token time supported

theorem output_bound (p : Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (schedules : TokenAutoregressiveScheduled.Schedules p RopeInputConstruction.angles)
    (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p encoded binding primitive sampling samplingPrimitive token schedules time (by omega)
    let logits := (TokenInferenceScheduled.run p before.cache before.token (RopeInputConstruction.angles.value time)
      (schedules time before.cache before.token)).1
    ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^18 := by
  dsimp only
  rw [TokenInferenceScheduled.run_eq]
  simp only [run_eq]
  simpa only [TokenSampledSequenceRanges.logits, RopeInputConstruction.angles] using
    Qwen38TrellisM1MaxMagnitude.inference_output p encoded binding primitive sampling samplingPrimitive token time supported

end Inference.Models.Qwen.Qwen38TrellisM1MaxInferenceScheduled
