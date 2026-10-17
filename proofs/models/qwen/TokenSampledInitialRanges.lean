import models.qwen.TokenInitialRanges
import kernels.sampling.GreedySampling

namespace Inference.Models.Qwen.TokenSampledInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics TokenInference Kernels.Attention Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

def logits (p : Pipeline) (token : Fin 248320) (angle : RopeAngles.Inputs) : Fin 248320 → GreedySampling.BF :=
  (p.run (InitialState.caches p.graph.stages) token angle).1
def run (p : Pipeline) (sampling : LogSumExpRanges.Platform) (token : Fin 248320) (angle : RopeAngles.Inputs) :
    Nat × p.graph.Cache 1 :=
  let output := p.run (InitialState.caches p.graph.stages) token angle
  (GreedySampling.sample sampling output.1, output.2)

noncomputable def budget (p : Pipeline) (parameters : TokenInitialRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (aim ae : RopeAngles.Target) : (Fin 248320 → ℝ) × p.graph.ReferenceCache 1 :=
  p.budgetRun (InitialState.caches p.graph.stages) (InitialState.references p.graph.stages)
    (InitialState.references p.graph.stages) token angle aim ae
    (TokenInitialRanges.checked p parameters primitive token angle ha position)

-- Complete first-token logical source path through normalization and the
-- two selection kernels, retaining every cache error. Source/native and
-- scalar conformance are separate obligations; later tokens are not covered.
theorem run_correct (p : Pipeline) (parameters : TokenInitialRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (position : real angle.position = 0) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (logits p token angle i) -
      (p.targetRun (InitialState.references p.graph.stages) token aim).1 i| ≤
      (budget p parameters primitive token angle ha position aim ae).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (run p sampling token angle).2
      (p.targetRun (InitialState.references p.graph.stages) token aim).2
      (budget p parameters primitive token angle ha position aim ae).2 ∧
    DecodeChain.CachesFinite p.graph.stages (run p sampling token angle).2 ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits p token angle i)) ∧
    (∀ i, (NormalizedScores.value (logits p token angle i)
      (LogSumExpRanges.value sampling (logits p token angle))).isFinite = true) ∧
    ∃ selected : Fin 248320, (run p sampling token angle).1 = selected.val ∧
      (∀ i, GreedySampling.score sampling (logits p token angle) i ≤
        GreedySampling.score sampling (logits p token angle) selected) ∧
      (∀ i, GreedySampling.score sampling (logits p token angle) selected =
        GreedySampling.score sampling (logits p token angle) i → selected.val ≤ i.val) := by
  have numeric := TokenInitialRanges.run_correct p parameters primitive token angle ha position aim ae he hb
  have selection := GreedySampling.correct sampling samplingPrimitive (logits p token angle) numeric.2.2.1
  exact ⟨numeric.1, numeric.2.1, numeric.2.2.2, selection.1, selection.2⟩

-- Agreement with the exact-real quantized-model winner requires its margin
-- to exceed the proved arithmetic errors. This theorem supplies the complete
-- first-token error expressions; it does not assert that a checkpoint meets
-- the margin for every token.
theorem target_winner (p : Pipeline) (parameters : TokenInitialRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (position : real angle.position = 0) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) (winner : Fin 248320)
    (margin : ∀ i, i ≠ winner →
      (p.targetRun (InitialState.references p.graph.stages) token aim).1 i +
        GreedySampling.error sampling (logits p token angle)
          (budget p parameters primitive token angle ha position aim ae).1 i <
      (p.targetRun (InitialState.references p.graph.stages) token aim).1 winner -
        GreedySampling.error sampling (logits p token angle)
          (budget p parameters primitive token angle ha position aim ae).1 winner) :
    (run p sampling token angle).1 = winner.val := by
  have numeric := TokenInitialRanges.run_correct p parameters primitive token angle ha position aim ae he hb
  exact GreedySampling.target_winner sampling samplingPrimitive (logits p token angle) numeric.2.2.1
    _ _ numeric.1 winner margin

end Inference.Models.Qwen.TokenSampledInitialRanges
