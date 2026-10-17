import models.qwen.DeltaOutputRanges

namespace Inference.Models.Qwen.DeltaInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (norm : Blocks.Norm) (layer : Layer) : Prop where
  projections : DeltaInputRanges.Parameters layer
  heads : DeltaHeadRanges.Parameters layer
  gates : DeltaGateRanges.Parameters layer
  output : DeltaOutputRanges.Parameters layer.out
  normalization : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1
  convolution : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1
  gated : ∀ i, Model.isFinite (layer.normWeight i) = true ∧ |Model.toReal (layer.normWeight i)| ≤ 2

-- These are scalar instruction contracts and the already-selected execution
-- schedules, not assumptions about an entire kernel's mathematical output.
structure Primitives (norm : Blocks.Norm) (layer : Layer) where
  normalizationDivision : DivisionDirectedBounds.Contract norm.platform.divide
  normalizationRoot : RsqrtBounds.Envelope norm.platform.rsqrt
  projections : DeltaInputRanges.Divisions layer
  headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs
  headDivision : DivisionDirectedBounds.Contract layer.recurrence.heads.divide
  headRoot : RsqrtBounds.Envelope layer.recurrence.heads.rsqrt
  decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile
  beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs
  gatedDivision : DivisionDirectedBounds.Contract layer.gated.divide
  gatedRoot : RsqrtBounds.Envelope layer.gated.rsqrt
  gatedExp : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs
  output : DeltaOutputRanges.Divisions layer.out

def normalizedInput (norm : Blocks.Norm) (x : Nat → Fin 5120 → BF) : Nat → Fin 5120 → BF :=
  fun t => norm.forward (x t)

structure Result (norm : Blocks.Norm) (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) : Prop where
  normalization : ∀ t, norm.Finite (x t)
  finite : layer.Finite cache (normalizedInput norm x) 0
  output : ∀ i, |Model.toReal (layer.forward cache (normalizedInput norm x) 0 i)| ≤ (2 : ℝ)^(44 : Nat)
  recurrent : ∀ h v i, ((DeltaCache.after layer cache (normalizedInput norm x) 1).recurrent h v i).isFinite = true ∧
    |real ((DeltaCache.after layer cache (normalizedInput norm x) 1).recurrent h v i)| ≤ (2 : ℝ)^(41 : Nat)
  history : ∀ i c, Model.isFinite ((DeltaCache.after layer cache (normalizedInput norm x) 1).history i c) = true ∧
    |Model.toReal ((DeltaCache.after layer cache (normalizedInput norm x) 1).history i c)| ≤ (2 : ℝ)^(34 : Nat)

theorem ranges (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer) (primitive : Primitives norm layer)
    (cache : Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1) :
    Result norm layer cache x := by
  have hp := DeltaInputRanges.projections norm layer parameters.projections primitive.projections
    primitive.normalizationDivision primitive.normalizationRoot parameters.normalization x hx
  have hc := DeltaInputRanges.convolution layer cache (normalizedInput norm x) hp.2 history parameters.convolution
  have hr := DeltaInitialRecurrenceRanges.from_projections layer parameters.heads parameters.gates primitive.headExp
    primitive.headDivision primitive.headRoot primitive.decay primitive.beta cache (normalizedInput norm x) hp.2 history parameters.convolution state
  have hg := DeltaOutputRanges.gated layer cache (normalizedInput norm x) 0 parameters.heads parameters.gated hp.2 hr.1
    (fun h v => (hr.2.1 h v).trans (by norm_num)) primitive.gatedDivision primitive.gatedRoot primitive.gatedExp
  have ho := DeltaOutputRanges.project layer.out parameters.output primitive.output (merged layer cache (normalizedInput norm x) 0) hg.2
  exact ⟨hp.1, ⟨hp.2.finite, hc.1, hr.1, hg.1, ho.1⟩, fun i => (ho.2 i).2, hr.2.2,
    fun i c => DeltaInputRanges.history_after layer cache (normalizedInput norm x) hp.2 history 1 i c⟩

-- Compose numerical error as well as ranges. The supplied cache and input
-- errors are propagated through normalization, all five projections, all
-- Delta kernels, the output gate, and every returned cache coordinate.
theorem accuracy (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer) (primitive : Primitives norm layer)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (cacheError : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1)
    (target error : Nat → Fin 5120 → ℝ) (he : ∀ t i, |Model.toReal (x t i)-target t i| ≤ error t i) :
    (∀ i, Model.isFinite (layer.forward cache (normalizedInput norm x) 0 i) = true ∧
      |Model.toReal (layer.forward cache (normalizedInput norm x) 0 i)| ≤ (2 : ℝ)^(44 : Nat) ∧
      |Model.toReal (layer.forward cache (normalizedInput norm x) 0 i) -
        layer.target Blocks.idealEps targetCache (fun t => norm.target (target t)) 0 i| ≤
        layer.budget Blocks.idealEps Blocks.epsError cache targetCache errorCache (normalizedInput norm x)
          (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) 0 i) ∧
    CacheError (DeltaCache.after layer cache (normalizedInput norm x) 1)
      (DeltaCache.targetAfter layer Blocks.idealEps targetCache (fun t => norm.target (target t)) 1)
      (DeltaCache.budgetAfter layer Blocks.idealEps Blocks.epsError cache targetCache errorCache (normalizedInput norm x)
        (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) 1) := by
  have h := ranges norm layer parameters primitive cache x hx history state
  have hi t := norm.forward_error (x t) (target t) (error t) (he t) (fun i => (hx t i).1)
    (fun i => (parameters.normalization i).1) (h.normalization t)
  have epsPositive : 0 < Blocks.idealEps := by norm_num [Blocks.idealEps]
  have epsError : |real layer.headParams.eps - Blocks.idealEps| ≤ Blocks.epsError := by
    rw [parameters.heads.eps]
    exact Blocks.eps_accuracy
  refine ⟨fun i => ⟨layer.forward_finite _ _ 0 h.finite i, h.output i, ?_⟩, ?_⟩
  · exact layer.forward_error Blocks.idealEps Blocks.epsError epsPositive epsError cache targetCache errorCache cacheError
      (normalizedInput norm x) (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) hi 0 h.finite i
  · exact DeltaCache.after_error layer Blocks.idealEps Blocks.epsError epsPositive epsError cache targetCache errorCache cacheError
      (normalizedInput norm x) (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) hi
      h.finite.projections h.finite.convolution 0 h.finite.recurrence

end Inference.Models.Qwen.DeltaInitialRanges
