import models.qwen.NormalizedAffineProjection
import models.qwen.DeltaCache
import kernels.delta.ConvolutionBounds

namespace Inference.Models.Qwen.DeltaInputRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (layer : Layer) : Prop where
  qkv : NormalizedAffineProjection.Parameters layer.qkv
  z : NormalizedAffineProjection.Parameters layer.z
  a : NormalizedAffineProjection.Parameters layer.a
  b : NormalizedAffineProjection.Parameters layer.b

structure Divisions (layer : Layer) : Prop where
  qkv : NormalizedAffineProjection.DivisionContract layer.qkv
  z : NormalizedAffineProjection.DivisionContract layer.z
  a : NormalizedAffineProjection.DivisionContract layer.a
  b : NormalizedAffineProjection.DivisionContract layer.b

structure ProjectionRanges (layer : Layer) (input : Nat → Fin 5120 → BF) : Prop where
  finite : ProjectionFinite layer input
  qkv : ∀ t c, |Model.toReal (layer.qkv.forward (input t) c)| ≤ (2 : ℝ)^(23 : Nat)
  z : ∀ t c, |Model.toReal (layer.z.forward (input t) c)| ≤ (2 : ℝ)^(23 : Nat)
  a : ∀ t c, |Model.toReal (layer.a.forward (input t) c)| ≤ (2 : ℝ)^(23 : Nat)
  b : ∀ t c, |Model.toReal (layer.b.forward (input t) c)| ≤ (2 : ℝ)^(23 : Nat)

theorem projections (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters layer) (divisions : Divisions layer)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat)) :
    (∀ t, norm.Finite (x t)) ∧ ProjectionRanges layer (fun t => norm.forward (x t)) := by
  have hq t := NormalizedAffineProjection.ranges norm layer.qkv parameters.qkv normDivision root divisions.qkv hw (x t) (hx t)
  have hz t := NormalizedAffineProjection.ranges norm layer.z parameters.z normDivision root divisions.z hw (x t) (hx t)
  have ha t := NormalizedAffineProjection.ranges norm layer.a parameters.a normDivision root divisions.a hw (x t) (hx t)
  have hb t := NormalizedAffineProjection.ranges norm layer.b parameters.b normDivision root divisions.b hw (x t) (hx t)
  exact ⟨fun t => (hq t).1,
    ⟨⟨fun t => (hq t).2.1, fun t => (ha t).2.1, fun t => (hb t).2.1, fun t => (hz t).2.1⟩,
      fun t c => ((hq t).2.2 c).2, fun t c => ((hz t).2.2 c).2,
      fun t c => ((ha t).2.2 c).2, fun t c => ((hb t).2.2 c).2⟩⟩

private theorem accumulator_range (i : Fin 5) :
    (DyadicBounds.ceiling i.val 34).isFinite = true ∧
      real (DyadicBounds.ceiling i.val 34) = (i.val : ℝ) * (2 : ℝ)^(34 : Nat) := by
  have h := DyadicBounds.ceiling_range i.val 34 (by have := i.isLt; omega) (by decide) (by decide)
  simpa only [zpow_ofNat] using h

def convolutionCap : BF := BFloat16DyadicBounds.ceiling 1 36
theorem convolutionCap_real : Model.toReal convolutionCap = (2 : ℝ)^(36 : Nat) := by
  simpa only [convolutionCap, Nat.cast_one, one_mul, zpow_ofNat] using
    (BFloat16DyadicBounds.ceiling_range 1 36 (by decide) (by decide) (by decide)).2

def convolutionProfile : ConvolutionBounds.Profile where
  inputCap := DyadicBounds.ceiling 1 34
  weightCap := 1
  productCap := DyadicBounds.ceiling 1 34
  accumulatorCap i := DyadicBounds.ceiling i.val 34
  storeCap := convolutionCap
  productFinite := (accumulator_range 1).1
  accumulatorFinite := fun i => (accumulator_range i).1
  storeFinite := (BFloat16DyadicBounds.ceiling_range 1 36 (by decide) (by decide) (by decide)).1
  zeroCapacity := by rw [(accumulator_range 0).2]; simp
  productCapacity := by rw [real_one, mul_one]
  stepCapacity := by
    intro i
    have hp : real (DyadicBounds.ceiling 1 34) = (2 : ℝ)^(34 : Nat) := by
      simpa only [Fin.val_one, Nat.cast_one, one_mul] using (accumulator_range 1).2
    rw [(accumulator_range ⟨i.val, by omega⟩).2, hp,
      (accumulator_range ⟨i.val+1, by omega⟩).2]
    simp only [Nat.cast_add, Nat.cast_one]
    ring_nf
    exact le_refl _
  storeCapacity := by rw [(accumulator_range 4).2, convolutionCap_real]; norm_num

theorem convolution (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF)
    (projection : ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1) :
    ConvolutionFinite layer cache input ∧
      ∀ t c, |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache input) t c)| ≤ (2 : ℝ)^(36 : Nat) := by
  have hw (t : Nat) (c : Fin 10240) (i : Fin 4) :
      Model.isFinite (State.Ssm.window (convData layer cache input) t c i) = true ∧
        |Model.toReal (State.Ssm.window (convData layer cache input) t c i)| ≤ real convolutionProfile.inputCap := by
    have hc : real convolutionProfile.inputCap = (2 : ℝ)^(34 : Nat) := by
      simpa only [convolutionProfile, Fin.val_one, Nat.cast_one, one_mul] using (accumulator_range 1).2
    rw [hc]
    unfold State.Ssm.window Convolution.window Convolution.joined
    split
    · exact history _ c
    · exact ⟨layer.qkv.forward_finite _ (projection.finite.qkv _) c, (projection.qkv _ c).trans (by norm_num)⟩
  have h (t : Nat) (c : Fin 10240) := convolutionProfile.ranges layer.recurrence.convolutionContracted
    (State.Ssm.window (convData layer cache input) t c) (layer.convolutionWeight c) (hw t c)
    (fun i => by simpa only [convolutionProfile, real_one] using weight c i)
  exact ⟨⟨fun i c => (history i c).1, fun c i => (weight c i).1,
      fun t c => (h t c).1, fun t c => (h t c).2.1⟩,
    fun t c => by simpa only [State.Ssm.convolved, convData, convolutionProfile, convolutionCap_real] using (h t c).2.2⟩

theorem history_after (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF)
    (projection : ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (steps : Nat) (i : Fin 3) (c : Fin 10240) :
    Model.isFinite ((DeltaCache.after layer cache input steps).history i c) = true ∧
      |Model.toReal ((DeltaCache.after layer cache input steps).history i c)| ≤ (2 : ℝ)^(34 : Nat) := by
  simp only [DeltaCache.after, Convolution.tail]
  unfold Convolution.joined
  split
  · exact history _ c
  · exact ⟨layer.qkv.forward_finite _ (projection.finite.qkv _) c, (projection.qkv _ c).trans (by norm_num)⟩

theorem convolution_accuracy (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters layer) (divisions : Divisions layer)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (target error : Nat → Fin 5120 → ℝ) (he : ∀ t i, |Model.toReal (x t i) - target t i| ≤ error t i)
    (cache : Cache) (targetCache errorCache : ReferenceCache) (cacheError : CacheError cache targetCache errorCache)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1)
    (t : Nat) (c : Fin 10240) :
    Model.isFinite (State.Ssm.convolved layer.recurrence (convData layer cache (fun s => norm.forward (x s))) t c) = true ∧
      |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache (fun s => norm.forward (x s))) t c)| ≤ (2 : ℝ)^(36 : Nat) ∧
      |Model.toReal (State.Ssm.convolved layer.recurrence (convData layer cache (fun s => norm.forward (x s))) t c) -
        State.Ssm.targetConv (targetConvData layer targetCache (fun s => norm.target (target s))) t c| ≤
        State.Ssm.convBudget layer.recurrence (convData layer cache (fun s => norm.forward (x s)))
          (targetConvData layer targetCache (fun s => norm.target (target s)))
          (convErrors layer errorCache (fun s => norm.forward (x s)) (fun s => norm.target (target s))
            (fun s => norm.errorBudget (x s) (target s) (error s))) t c := by
  have hp := projections norm layer parameters divisions normDivision root hw x hx
  have hv := convolution layer cache (fun s => norm.forward (x s)) hp.2 history weight
  have hi (s : Nat) := norm.forward_error (x s) (target s) (error s) (he s)
    (fun i => (hx s i).1) (fun i => (hw i).1) (hp.1 s)
  have hce := DeltaNet.convolution_input_error layer cache targetCache errorCache cacheError
    (fun s => norm.forward (x s)) (fun s => norm.target (target s))
    (fun s => norm.errorBudget (x s) (target s) (error s)) hi hp.2.finite
  have hcf := DeltaNet.convolution_finite layer cache (fun s => norm.forward (x s)) hp.2.finite hv.1
  exact ⟨hv.1.cast t c, hv.2 t c, State.Ssm.convolved_error layer.recurrence _ _ _ hcf hce t c⟩

end Inference.Models.Qwen.DeltaInputRanges
