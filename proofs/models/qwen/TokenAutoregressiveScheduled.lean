import models.qwen.TokenInferenceScheduled

namespace Inference.Models.Qwen.TokenAutoregressiveScheduled
open TokenInference TokenAutoregressive Kernels.Attention Kernels.Sampling
set_option maxRecDepth 10000

-- Executions may choose any legal completed schedule for every MLP. Their
-- dependent inputs are the actual cache and emitted token at that step.
abbrev Schedules (p : Pipeline) (angles : Angles) :=
  ∀ (time : Nat) (cache : p.graph.Cache time) (token : Fin 248320),
    TokenInferenceScheduled.Execution p cache token (angles.value time)

def Schedules.canonical (p : Pipeline) (angles : Angles) : Schedules p angles :=
  fun _ cache token => TokenInferenceScheduled.Execution.canonical p cache token _

private theorem state_eq (a b : State p time) (token : a.token=b.token) (cache : a.cache=b.cache)
    (target : a.targetCache=b.targetCache) (error : a.errorCache=b.errorCache) : a=b := by
  cases a
  cases b
  cases token
  cases cache
  cases target
  cases error
  rfl

noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenInferenceScheduled.Execution p before.cache before.token angle) : State p (time+1) := by
  let output := TokenInferenceScheduled.run p before.cache before.token angle execution
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb
  have tokenEq : GreedySampling.sample sampling output.1=reference.token.val := by
    dsimp only [output]
    rw [TokenInferenceScheduled.run_eq]
    rfl
  have cacheEq : output.2=reference.cache := by
    dsimp only [output]
    rw [TokenInferenceScheduled.run_eq]
    rfl
  exact {
    token := ⟨GreedySampling.sample sampling output.1, by rw [tokenEq]; exact reference.token.isLt⟩
    cache := output.2
    cacheBound := by rw [cacheEq]; exact reference.cacheBound
    targetCache := reference.targetCache
    errorCache := reference.errorCache
    cacheError := by rw [cacheEq]; exact reference.cacheError
  }

theorem advance_eq (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base)
    (execution : TokenInferenceScheduled.Execution p before.cache before.token angle) :
    advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb execution=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb := by
  apply state_eq
  · apply Fin.ext
    simp only [advance, TokenInferenceScheduled.run_eq]
    rfl
  · simp only [advance, TokenInferenceScheduled.run_eq]
    rfl
  · rfl
  · rfl

noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (schedules : Schedules p angles) :
    (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => TokenAutoregressive.initial p token
  | t+1, supported =>
    let before := run p parameters primitive sampling samplingPrimitive token angles schedules t (by omega)
    advance p parameters primitive sampling samplingPrimitive before
      (angles.value t) (angles.ranges t (by omega)) supported (angles.target t) (angles.error t)
      (angles.accuracy t (by omega)) (angles.base t (by omega)) (schedules t before.cache before.token)

theorem run_eq (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (schedules : Schedules p angles) (steps : Nat) (supported : steps ≤ 262144) :
    run p parameters primitive sampling samplingPrimitive token angles schedules steps supported=
      TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles steps supported := by
  induction steps with
  | zero => rfl
  | succ t ih =>
    simp only [run, advance_eq, ih, TokenAutoregressive.run]

theorem schedule_independent (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (a b : Schedules p angles) (steps : Nat) (supported : steps ≤ 262144) :
    run p parameters primitive sampling samplingPrimitive token angles a steps supported=
      run p parameters primitive sampling samplingPrimitive token angles b steps supported := by
  rw [run_eq, run_eq]

end Inference.Models.Qwen.TokenAutoregressiveScheduled
