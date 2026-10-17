import models.qwen.ResidualDelta
import models.qwen.DeltaInitialRanges
import models.qwen.ResidualMlpRanges

namespace Inference.Models.Qwen.ResidualDeltaInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics ResidualDelta
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

structure Parameters (b : Layer) : Prop where
  mixer : DeltaInitialRanges.Parameters b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Parameters b.suffix
structure Primitives (b : Layer) where
  mixer : DeltaInitialRanges.Primitives b.inputNorm b.mixer
  suffix : ResidualMlpRanges.Primitives b.suffix

structure Result (b : Layer) (stage : Nat) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF) where
  finite : b.Finite cache x 0
  addition : ElementwiseAdd.Bounds (ResidualBlocks.residual (x 0) (b.mixed cache x 0))
    (b.suffix.branch (x 0) (b.mixed cache x 0))
  output : ∀ i, |Model.toReal (b.forward cache x 0 i)| ≤ (stage+1 : Nat) * (2 : ℝ)^(50 : Nat)
  recurrent : ∀ h v i, ((b.cacheAfter cache x 1).recurrent h v i).isFinite = true ∧
    |real ((b.cacheAfter cache x 1).recurrent h v i)| ≤ (2 : ℝ)^(41 : Nat)
  history : ∀ i c, Model.isFinite ((b.cacheAfter cache x 1).history i c) = true ∧
    |Model.toReal ((b.cacheAfter cache x 1).history i c)| ≤ (2 : ℝ)^(34 : Nat)

-- One complete residual Delta layer, from raw hidden input through its MLP
-- and final residual store, with no intermediate-finiteness premises.
noncomputable def checked (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1) :
    Result b stage cache x := by
  have hcap : ResidualMlpRanges.inputCeiling stage ≤ (2 : ℝ)^(56 : Nat) := by
    have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
    unfold ResidualMlpRanges.inputCeiling
    push_cast
    norm_num
    linarith
  have hm := DeltaInitialRanges.ranges b.inputNorm b.mixer parameters.mixer primitive.mixer cache x
    (fun t i => ⟨(hx t i).1, (hx t i).2.trans hcap⟩) history state
  have hu : ResidualMlpRanges.UpdateBound (b.mixed cache x 0) := fun i =>
    ⟨b.mixer.forward_finite _ _ 0 hm.finite i, hm.output i⟩
  let suffix := ResidualMlpRanges.checked b.suffix parameters.suffix primitive.suffix stage hs
    (x 0) (b.mixed cache x 0) (hx 0) hu
  exact ⟨⟨fun t i => (hx t i).1, fun i => (parameters.mixer.normalization i).1,
    hm.normalization, hm.finite, suffix.finite⟩, suffix.addition, suffix.output, hm.recurrent, hm.history⟩

theorem next_input (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1) :
    ResidualMlpRanges.InputBound (stage+1) (b.forward cache x 0) := by
  let h := checked b parameters primitive stage hs cache x hx history state
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold ResidualMlpRanges.inputCeiling
  push_cast
  norm_num
  linarith

theorem accuracy (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (state : ∀ h v i, (cache.recurrent h v i).isFinite = true ∧ |real (cache.recurrent h v i)| ≤ 1)
    (targetCache errorCache : DeltaNet.ReferenceCache) (hc : DeltaNet.CacheError cache targetCache errorCache)
    (target error : Nat → Fin 5120 → ℝ) (hi : ∀ t i, |Model.toReal (x t i)-target t i| ≤ error t i) :
    (∀ i, |Model.toReal (b.forward cache x 0 i)-b.target targetCache target 0 i| ≤
      b.budget cache targetCache errorCache x target error 0 (checked b parameters primitive stage hs cache x hx history state).finite i) ∧
    DeltaNet.CacheError (b.cacheAfter cache x 1) (b.targetCacheAfter targetCache target 1)
      (b.cacheBudget cache targetCache errorCache x target error 1) := by
  let h := checked b parameters primitive stage hs cache x hx history state
  refine ⟨fun i => ?_, b.cache_error cache targetCache errorCache hc x target error hi 0 h.finite⟩
  exact b.suffix.forward_error_of_bounds (x 0) (b.mixed cache x 0) (target 0) (b.mixedTarget targetCache target 0)
    (error 0) (b.mixedBudget cache targetCache errorCache x target error 0) (hi 0)
    (b.mixed_error cache targetCache errorCache hc x target error hi 0 h.finite) h.finite.suffix h.addition i

end Inference.Models.Qwen.ResidualDeltaInitialRanges
