import models.qwen.DecodeImplementation
import models.qwen.TokenAutoregressive

namespace Inference.Models.Qwen.AutoregressiveImplementation
open TokenInference TokenAutoregressive Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Schedules (impl : DecodeImplementation.Implementation) (p : Pipeline) (angles : Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320),
    DecodeImplementation.PipelineTrace impl p cache token (angles.value time)

def Schedules.canonical (impl : DecodeImplementation.Implementation) (p : Pipeline) (angles : Angles) : Schedules impl p angles :=
  fun _ cache token => DecodeImplementation.ChainTrace.canonical impl p.graph.stages cache (p.embedding.forward token) _

private theorem state_eq (a b : State p time) (token : a.token=b.token) (cache : a.cache=b.cache)
    (target : a.targetCache=b.targetCache) (error : a.errorCache=b.errorCache) : a=b := by
  cases a
  cases b
  cases token
  cases cache
  cases target
  cases error
  rfl

noncomputable def advance (impl : DecodeImplementation.Implementation) (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : DecodeImplementation.PipelineTrace impl p before.cache before.token angle) : State p (time+1) := by
  let output := DecodeImplementation.pipeline impl p before.cache before.token angle execution
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb
  have tokenEq : GreedySampling.sample sampling output.1=reference.token.val := by
    dsimp only [output]
    rw [DecodeImplementation.pipeline_eq]
    rfl
  have cacheEq : output.2=reference.cache := by
    dsimp only [output]
    rw [DecodeImplementation.pipeline_eq]
    rfl
  exact {
    token := ⟨GreedySampling.sample sampling output.1, by rw [tokenEq]; exact reference.token.isLt⟩
    cache := output.2
    cacheBound := by rw [cacheEq]; exact reference.cacheBound
    targetCache := reference.targetCache
    errorCache := reference.errorCache
    cacheError := by rw [cacheEq]; exact reference.cacheError
  }

theorem advance_eq (impl : DecodeImplementation.Implementation) (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : DecodeImplementation.PipelineTrace impl p before.cache before.token angle) :
    advance impl p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb := by
  apply state_eq
  · apply Fin.ext
    simp only [advance, DecodeImplementation.pipeline_eq]
    rfl
  · simp only [advance, DecodeImplementation.pipeline_eq]
    rfl
  · rfl
  · rfl

noncomputable def run (impl : DecodeImplementation.Implementation) (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (schedules : Schedules impl p angles) :
    (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => TokenAutoregressive.initial p token
  | t+1, supported =>
    let before := run impl p parameters primitive sampling samplingPrimitive token angles schedules t (by omega)
    advance impl p parameters primitive sampling samplingPrimitive before (angles.value t) (angles.ranges t (by omega))
      supported (angles.target t) (angles.error t) (angles.accuracy t (by omega)) (angles.base t (by omega))
        (schedules t before.cache before.token)

theorem run_eq (impl : DecodeImplementation.Implementation) (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (schedules : Schedules impl p angles) (steps : Nat) (supported : steps ≤ 262144) :
    run impl p parameters primitive sampling samplingPrimitive token angles schedules steps supported=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ t ih => simp only [run, advance_eq, ih, TokenAutoregressive.run]

theorem run_correct (impl : DecodeImplementation.Implementation) (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (schedules : Schedules impl p angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run impl p parameters primitive sampling samplingPrimitive token angles schedules time (by omega)
    let after := run impl p parameters primitive sampling samplingPrimitive token angles schedules (time+1) supported
    let logits := (DecodeImplementation.pipeline impl p before.cache before.token (angles.value time)
      (schedules time before.cache before.token)).1
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (angles.target time)).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (angles.value time) (angles.ranges time (by omega)) supported
          (angles.target time) (angles.error time)).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => Contracts.Mlx.BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite=true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token=GreedySampling.score sampling logits i → after.token.val ≤ i.val) := by
  dsimp only
  rw [DecodeImplementation.pipeline_eq]
  simp only [run_eq]
  simpa only [TokenSampledSequenceRanges.logits] using
    TokenAutoregressive.run_correct p parameters primitive sampling samplingPrimitive token angles time supported

end Inference.Models.Qwen.AutoregressiveImplementation
