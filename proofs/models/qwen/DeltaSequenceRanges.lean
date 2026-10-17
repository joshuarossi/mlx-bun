import models.qwen.DeltaInitialRanges
import models.qwen.DeltaSequenceRecurrenceRanges

namespace Inference.Models.Qwen.DeltaSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open DeltaInitialRanges (normalizedInput)

structure Parameters (norm : Blocks.Norm) (layer : Layer) : Prop extends DeltaInitialRanges.Parameters norm layer where
  keyScale : ∀ i, |Model.toReal (layer.headParams.kScale i)| ≤ (23/256 : ℝ)

structure Primitives (norm : Blocks.Norm) (layer : Layer) extends DeltaInitialRanges.Primitives norm layer where
  headRootTight : RsqrtRelativeBounds.Envelope layer.recurrence.heads.rsqrt (17/16)
  headDivisionNative : ∀ x, x.isFinite = true → layer.recurrence.heads.divide x (Float32.ofInt 128) =
    FlushToZero.div x (Float32.ofInt 128)

structure Result (norm : Blocks.Norm) (layer : Layer) (cache : Cache) (x : Nat → Fin 5120 → BF) (time : Nat) : Prop where
  normalization : ∀ t, norm.Finite (x t)
  finite : layer.Finite cache (normalizedInput norm x) time
  output : ∀ i, |Model.toReal (layer.forward cache (normalizedInput norm x) time i)| ≤ (2 : ℝ)^(44 : Nat)
  recurrent : ∀ h v,
    (∀ i, ((DeltaCache.after layer cache (normalizedInput norm x) (time+1)).recurrent h v i).isFinite = true) ∧
      RecurrenceStability.magnitude (fun i => real
        ((DeltaCache.after layer cache (normalizedInput norm x) (time+1)).recurrent h v i)) ≤ 9*(2 : ℝ)^(55 : Nat)
  history : ∀ i c, Model.isFinite ((DeltaCache.after layer cache (normalizedInput norm x) (time+1)).history i c) = true ∧
    |Model.toReal ((DeltaCache.after layer cache (normalizedInput norm x) (time+1)).history i c)| ≤ (2 : ℝ)^(34 : Nat)

theorem ranges (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer) (primitive : Primitives norm layer)
    (cache : Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateZero : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) = 0)
    (time : Nat) (bound : time+1 ≤ 262144) : Result norm layer cache x time := by
  have hp := DeltaInputRanges.projections norm layer parameters.projections primitive.projections
    primitive.normalizationDivision primitive.normalizationRoot parameters.normalization x hx
  have hc := DeltaInputRanges.convolution layer cache (normalizedInput norm x) hp.2 history parameters.convolution
  have headParameters : DeltaHeadEnergy.Parameters layer := ⟨parameters.heads, parameters.keyScale⟩
  have hr := DeltaSequenceRecurrenceRanges.from_projections layer headParameters parameters.gates primitive.headExp
    primitive.headDivision primitive.headRootTight primitive.headDivisionNative primitive.decay primitive.beta
    cache (normalizedInput norm x) hp.2 history parameters.convolution stateFinite stateZero time bound
  have hg := DeltaOutputRanges.gated_wide layer cache (normalizedInput norm x) time parameters.heads parameters.gated
    hp.2 hr.finite hr.output primitive.gatedDivision primitive.gatedRoot primitive.gatedExp
  have ho := DeltaOutputRanges.project layer.out parameters.output primitive.output
    (merged layer cache (normalizedInput norm x) time) hg.2
  exact ⟨hp.1, ⟨hp.2.finite, hc.1, hr.finite, hg.1, ho.1⟩, fun i => (ho.2 i).2,
    hr.state (time+1) (le_refl _),
    fun i c => DeltaInputRanges.history_after layer cache (normalizedInput norm x) hp.2 history (time+1) i c⟩

-- This composes the existing mathematical specification and error budgets
-- at every supported sequence position, including the returned cache.
theorem accuracy (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer) (primitive : Primitives norm layer)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (cacheError : CacheError cache targetCache errorCache)
    (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateZero : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) = 0)
    (target error : Nat → Fin 5120 → ℝ) (he : ∀ t i, |Model.toReal (x t i)-target t i| ≤ error t i)
    (time : Nat) (bound : time+1 ≤ 262144) :
    (∀ i, Model.isFinite (layer.forward cache (normalizedInput norm x) time i) = true ∧
      |Model.toReal (layer.forward cache (normalizedInput norm x) time i)| ≤ (2 : ℝ)^(44 : Nat) ∧
      |Model.toReal (layer.forward cache (normalizedInput norm x) time i) -
        layer.target Blocks.idealEps targetCache (fun t => norm.target (target t)) time i| ≤
        layer.budget Blocks.idealEps Blocks.epsError cache targetCache errorCache (normalizedInput norm x)
          (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) time i) ∧
    CacheError (DeltaCache.after layer cache (normalizedInput norm x) (time+1))
      (DeltaCache.targetAfter layer Blocks.idealEps targetCache (fun t => norm.target (target t)) (time+1))
      (DeltaCache.budgetAfter layer Blocks.idealEps Blocks.epsError cache targetCache errorCache (normalizedInput norm x)
        (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) (time+1)) := by
  have h := ranges norm layer parameters primitive cache x hx history stateFinite stateZero time bound
  have hi t := norm.forward_error (x t) (target t) (error t) (he t) (fun i => (hx t i).1)
    (fun i => (parameters.normalization i).1) (h.normalization t)
  have epsPositive : 0 < Blocks.idealEps := by norm_num [Blocks.idealEps]
  have epsError : |real layer.headParams.eps - Blocks.idealEps| ≤ Blocks.epsError := by
    rw [parameters.heads.eps]
    exact Blocks.eps_accuracy
  refine ⟨fun i => ⟨layer.forward_finite _ _ time h.finite i, h.output i, ?_⟩, ?_⟩
  · exact layer.forward_error Blocks.idealEps Blocks.epsError epsPositive epsError cache targetCache errorCache cacheError
      (normalizedInput norm x) (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) hi time h.finite i
  · exact DeltaCache.after_error layer Blocks.idealEps Blocks.epsError epsPositive epsError cache targetCache errorCache cacheError
      (normalizedInput norm x) (fun t => norm.target (target t)) (fun t => norm.errorBudget (x t) (target t) (error t)) hi
      h.finite.projections h.finite.convolution time h.finite.recurrence

end Inference.Models.Qwen.DeltaSequenceRanges
