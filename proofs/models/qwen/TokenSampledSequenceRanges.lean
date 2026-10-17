import models.qwen.TokenSequenceRanges
import kernels.sampling.GreedySampling

namespace Inference.Models.Qwen.TokenSampledSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def logits (p : Pipeline) (cache : p.graph.Cache time) (token : Fin 248320) (angle : RopeAngles.Inputs) : Fin 248320 → GreedySampling.BF :=
  (p.run cache token angle).1
def run (p : Pipeline) (sampling : LogSumExpRanges.Platform) (cache : p.graph.Cache time)
    (token : Fin 248320) (angle : RopeAngles.Inputs) : Nat × p.graph.Cache (time+1) :=
  let output := p.run cache token angle
  (GreedySampling.sample sampling output.1, output.2)

noncomputable def budget (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (aim ae : RopeAngles.Target) : (Fin 248320 → ℝ) × p.graph.ReferenceCache (time+1) :=
  p.budgetRun cache ct ce token angle aim ae (TokenSequenceRanges.checked p parameters primitive cache cacheBound token angle ha supported)

theorem run_correct (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (logits p cache token angle i)-(p.targetRun ct token aim).1 i| ≤
      (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (run p sampling cache token angle).2 (p.targetRun ct token aim).2
      (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).2 ∧
    DecodeChainSequenceRanges.CachesBound p.graph.stages (run p sampling cache token angle).2 ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits p cache token angle i)) ∧
    (∀ i, (NormalizedScores.value (logits p cache token angle i)
      (LogSumExpRanges.value sampling (logits p cache token angle))).isFinite = true) ∧
    ∃ selected : Fin 248320, (run p sampling cache token angle).1 = selected.val ∧
      (∀ i, GreedySampling.score sampling (logits p cache token angle) i ≤ GreedySampling.score sampling (logits p cache token angle) selected) ∧
      (∀ i, GreedySampling.score sampling (logits p cache token angle) selected = GreedySampling.score sampling (logits p cache token angle) i →
        selected.val ≤ i.val) := by
  have numeric := TokenSequenceRanges.run_correct p parameters primitive cache cacheBound ct ce hc token angle ha supported aim ae he hb
  have selection := GreedySampling.correct sampling samplingPrimitive (logits p cache token angle) numeric.2.2.1
  exact ⟨numeric.1, numeric.2.1, numeric.2.2.2, selection.1, selection.2⟩

theorem target_winner (p : Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) (winner : Fin 248320)
    (margin : ∀ i, i ≠ winner →
      (p.targetRun ct token aim).1 i + GreedySampling.error sampling (logits p cache token angle)
        (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 i <
      (p.targetRun ct token aim).1 winner - GreedySampling.error sampling (logits p cache token angle)
        (budget p parameters primitive cache cacheBound ct ce token angle ha supported aim ae).1 winner) :
    (run p sampling cache token angle).1 = winner.val := by
  have numeric := TokenSequenceRanges.run_correct p parameters primitive cache cacheBound ct ce hc token angle ha supported aim ae he hb
  exact GreedySampling.target_winner sampling samplingPrimitive (logits p cache token angle) numeric.2.2.1 _ _ numeric.1 winner margin

end Inference.Models.Qwen.TokenSampledSequenceRanges
