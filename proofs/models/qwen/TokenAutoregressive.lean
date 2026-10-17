import models.qwen.TokenSampledSequenceRanges

namespace Inference.Models.Qwen.TokenAutoregressive
open Contracts.Mlx Contracts.Mlx.Numerics TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Proof fields describe the cache used by the following call. The token
-- value is the actual greedy result; no run-time acceptance check is added.
-- The mathematical reference consumes those same tokens. Agreement with
-- an independently generated exact-real sequence additionally needs the
-- per-step winner margins from TokenSampledSequenceRanges.target_winner.
structure State (p : Pipeline) (time : Nat) where
  token : Fin 248320
  cache : p.graph.Cache time
  cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache
  targetCache : p.graph.ReferenceCache time
  errorCache : p.graph.ReferenceCache time
  cacheError : DecodeChain.CacheErrors p.graph.stages cache targetCache errorCache

def initial (p : Pipeline) (token : Fin 248320) : State p 0 where
  token := token
  cache := InitialState.caches p.graph.stages
  cacheBound := DecodeChainSequenceRanges.initial p.graph.stages
  targetCache := InitialState.references p.graph.stages
  errorCache := InitialState.references p.graph.stages
  cacheError := InitialState.caches_error p.graph.stages

noncomputable def advance (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) : State p (time+1) := by
  let output := TokenSampledSequenceRanges.run p sampling before.cache before.token angle
  let error := TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound
    before.targetCache before.errorCache before.token angle ha supported aim ae
  have correct := TokenSampledSequenceRanges.run_correct p parameters primitive sampling samplingPrimitive
    before.cache before.cacheBound before.targetCache before.errorCache before.cacheError before.token angle ha supported aim ae he hb
  have tokenBound : output.1 < 248320 := by
    obtain ⟨selected, same, _, _⟩ := correct.2.2.2.2.2
    change (TokenSampledSequenceRanges.run p sampling before.cache before.token angle).1 < 248320
    rw [same]
    exact selected.isLt
  exact ⟨⟨output.1, tokenBound⟩, output.2, correct.2.2.1,
    (p.targetRun before.targetCache before.token aim).2, error.2, correct.2.1⟩

theorem advance_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (before : State p time) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    let next := advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token angle
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token aim).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token angle ha supported aim ae).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits next.token) ∧
    (∀ i, GreedySampling.score sampling logits next.token = GreedySampling.score sampling logits i → next.token.val ≤ i.val) := by
  have correct := TokenSampledSequenceRanges.run_correct p parameters primitive sampling samplingPrimitive
    before.cache before.cacheBound before.targetCache before.errorCache before.cacheError before.token angle ha supported aim ae he hb
  obtain ⟨selected, same, largest, tie⟩ := correct.2.2.2.2.2
  have token : (advance p parameters primitive sampling samplingPrimitive before angle ha supported aim ae he hb).token = selected :=
    Fin.ext same
  dsimp only
  rw [token]
  exact ⟨correct.1, correct.2.2.2.1, correct.2.2.2.2.1, largest, tie⟩

structure Angles where
  value : Nat → RopeAngles.Inputs
  target : Nat → RopeAngles.Target
  error : Nat → RopeAngles.Target
  ranges : ∀ t, t < 262144 → RopeAnglesRanges.InputsBound (value t)
  accuracy : ∀ t, t < 262144 → RopeAngles.InputError (value t) (target t) (error t)
  base : ∀ t, t < 262144 → 0 ≤ (target t).base

-- The recurrence contains the selected token and actual returned cache.
-- The State type carries the inductively constructed range and error proofs
-- through every call; it assumes neither intermediate finiteness nor a
-- fixed externally supplied token sequence.
noncomputable def run (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) : (steps : Nat) → steps ≤ 262144 → State p steps
  | 0, _ => initial p token
  | t+1, supported =>
    advance p parameters primitive sampling samplingPrimitive
      (run p parameters primitive sampling samplingPrimitive token angles t (by omega))
      (angles.value t) (angles.ranges t (by omega)) supported (angles.target t) (angles.error t)
      (angles.accuracy t (by omega)) (angles.base t (by omega))

theorem run_step (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p parameters primitive sampling samplingPrimitive token angles time (by omega)
    let after := run p parameters primitive sampling samplingPrimitive token angles (time+1) supported
    after.token.val = (TokenSampledSequenceRanges.run p sampling before.cache before.token (angles.value time)).1 ∧
      after.cache = (p.run before.cache before.token (angles.value time)).2 := ⟨rfl, rfl⟩

theorem run_invariant (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time ≤ 262144) :
    let state := run p parameters primitive sampling samplingPrimitive token angles time supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.cache ∧
      DecodeChain.CacheErrors p.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages state.cache := by
  let state := run p parameters primitive sampling samplingPrimitive token angles time supported
  exact ⟨state.cacheBound, state.cacheError, DecodeChainSequenceRanges.caches_finite _ _ state.cacheBound⟩

theorem run_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p parameters primitive sampling samplingPrimitive token angles time (by omega)
    let after := run p parameters primitive sampling samplingPrimitive token angles (time+1) supported
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (angles.value time)
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (angles.target time)).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (angles.value time) (angles.ranges time (by omega)) supported
          (angles.target time) (angles.error time)).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token = GreedySampling.score sampling logits i → after.token.val ≤ i.val) :=
  advance_correct p parameters primitive sampling samplingPrimitive
    (run p parameters primitive sampling samplingPrimitive token angles time (by omega))
    (angles.value time) (angles.ranges time (by omega)) supported (angles.target time) (angles.error time)
    (angles.accuracy time (by omega)) (angles.base time (by omega))

end Inference.Models.Qwen.TokenAutoregressive
