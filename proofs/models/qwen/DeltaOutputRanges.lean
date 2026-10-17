import models.qwen.DeltaInitialRecurrenceRanges
import kernels.GatedRmsNormRanges

namespace Inference.Models.Qwen.DeltaOutputRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
abbrev BF := DeltaNet.BF

private theorem bf (e : Int) (lo : -133 ≤ e) (hi : e ≤ 119) :
    Model.isFinite (BFloat16DyadicBounds.ceiling 1 e) = true ∧ Model.toReal (BFloat16DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using BFloat16DyadicBounds.ceiling_range 1 e (by decide) lo hi
private theorem fp (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 e (by decide) lo hi

def normProfile : NormalizationUniform.Profile 128 where
  positive := by decide
  widthLog := 7
  widthLogBound := by decide
  widthBound := by decide
  normalizedExponent := 6
  normalizedPositive := by decide
  normalizedBound := by decide
  rootCapacity := by decide
  eps := Blocks.eps
  epsFinite := Blocks.eps_finite
  epsNormal := Blocks.eps_normal
  epsBound := by rw [Blocks.eps_value]; norm_num
  smallCapacity := by rw [Blocks.eps_value]; norm_num
  weightCap := BFloat16DyadicBounds.ceiling 1 1
  outputCap := BFloat16DyadicBounds.ceiling 1 7
  outputFinite := (bf 7 (by decide) (by decide)).1
  outputCapacity := by rw [(bf 1 (by decide) (by decide)).2, (bf 7 (by decide) (by decide)).2]; norm_num

def tailProfile : Kernels.GatedRmsNormRanges.TailProfile where
  gateCap := DyadicBounds.ceiling 1 23
  upCap := normProfile.outputCap
  productCap := DyadicBounds.ceiling 1 30
  storeCap := BFloat16DyadicBounds.ceiling 1 30
  gateFinite := (fp 23 (by decide) (by decide)).1
  productFinite := (fp 30 (by decide) (by decide)).1
  storeFinite := (bf 30 (by decide) (by decide)).1
  productCapacity := by rw [normProfile, (fp 23 (by decide) (by decide)).2, (bf 7 (by decide) (by decide)).2, (fp 30 (by decide) (by decide)).2]; norm_num
  storeCapacity := by rw [(fp 30 (by decide) (by decide)).2, (bf 30 (by decide) (by decide)).2]

theorem gated_wide (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat)
    (parameters : DeltaHeadRanges.Parameters layer)
    (weight : ∀ i, Model.isFinite (layer.normWeight i) = true ∧ |Model.toReal (layer.normWeight i)| ≤ 2)
    (projection : DeltaInputRanges.ProjectionRanges layer input)
    (recurrence : RecurrentFinite layer cache input time)
    (recurrentBound : ∀ h v, |Model.toReal (recurrentOutput layer cache input time h v)| ≤ (2 : ℝ)^(56 : Nat))
    (division : DivisionDirectedBounds.Contract layer.gated.divide) (root : RsqrtBounds.Envelope layer.gated.rsqrt)
    (exponential : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs) :
    GatedFinite layer cache input time ∧ ∀ i, Model.isFinite (merged layer cache input time i) = true ∧
      |Model.toReal (merged layer cache input time i)| ≤ (2 : ℝ)^(30 : Nat) := by
  have h head := Kernels.GatedRmsNormRanges.ranges_wide layer.gated normProfile tailProfile (le_refl _)
    division root exponential (recurrentOutput layer cache input time head) (zHead layer input time head) layer.normWeight
    (fun i => ⟨recurrence.cast head i, recurrentBound head i⟩)
    (fun i => by norm_num only [normProfile, (bf 1 (by decide) (by decide)).2, zpow_ofNat]; exact weight i)
    (fun i => ⟨layer.z.forward_finite _ (projection.finite.z time) _, by
      simpa only [zHead, tailProfile, (fp 23 (by decide) (by decide)).2, zpow_ofNat] using projection.z time (channel head i)⟩)
  have hg : GatedFinite layer cache input time := by
    constructor
    · intro head
      rw [parameters.width, parameters.eps]
      exact (h head).1
    · intro head i
      rw [parameters.width, parameters.eps]
      exact ((h head).2 i).1
  refine ⟨hg, fun i => ⟨merged_finite layer cache input time hg i, ?_⟩⟩
  unfold merged gatedOutput
  rw [parameters.width, parameters.eps]
  simpa only [normProfile, tailProfile, (bf 30 (by decide) (by decide)).2, zpow_ofNat] using
    ((h (headOf i)).2 (valueOf i)).2.2

theorem gated (layer : Layer) (cache : Cache) (input : Nat → Fin 5120 → BF) (time : Nat)
    (parameters : DeltaHeadRanges.Parameters layer)
    (weight : ∀ i, Model.isFinite (layer.normWeight i) = true ∧ |Model.toReal (layer.normWeight i)| ≤ 2)
    (projection : DeltaInputRanges.ProjectionRanges layer input)
    (recurrence : RecurrentFinite layer cache input time)
    (recurrentBound : ∀ h v, |Model.toReal (recurrentOutput layer cache input time h v)| ≤ (2 : ℝ)^(50 : Nat))
    (division : DivisionDirectedBounds.Contract layer.gated.divide) (root : RsqrtBounds.Envelope layer.gated.rsqrt)
    (exponential : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs) :
    GatedFinite layer cache input time ∧ ∀ i, Model.isFinite (merged layer cache input time i) = true ∧
      |Model.toReal (merged layer cache input time i)| ≤ (2 : ℝ)^(30 : Nat) :=
  gated_wide layer cache input time parameters weight projection recurrence
    (fun h v => (recurrentBound h v).trans (by norm_num)) division root exponential

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 44
theorem outputCap_real : Model.toReal outputCap = (2 : ℝ)^(44 : Nat) := by
  simpa only [outputCap, zpow_ofNat] using (bf 44 (by decide) (by decide)).2

def profile3 : Profile 12 36 3 where
  inputExponent := 30
  scaleExponent := -4
  biasExponent := -1
  tileExponent := 29
  inputLower := by decide
  inputUpper := by decide
  tileLower := by decide
  tileUpper := by decide
  scaled := by decide
  biased := by decide
  size := by decide
  outputCap := outputCap
  outputFinite := (bf 44 (by decide) (by decide)).1
  capacity := by rw [outputCap_real]; norm_num
def profile4 : Profile 12 32 4 where
  inputExponent := 30
  scaleExponent := -4
  biasExponent := -1
  tileExponent := 30
  inputLower := by decide
  inputUpper := by decide
  tileLower := by decide
  tileUpper := by decide
  scaled := by decide
  biased := by decide
  size := by decide
  outputCap := outputCap
  outputFinite := (bf 44 (by decide) (by decide)).1
  capacity := by rw [outputCap_real]; norm_num

def Parameters : Projection 12 5120 → Prop
  | .bits3 p => Parameters3 p profile3
  | .bits4 p => Parameters4 p profile4
def Divisions : Projection 12 5120 → Prop
  | .bits3 p => DivisionDirectedBounds.Contract p.platform.tile.divide
  | .bits4 p => DivisionDirectedBounds.Contract p.platform.tile.divide

theorem project (projection : Projection 12 5120) (parameters : Parameters projection) (division : Divisions projection)
    (input : Fin 6144 → BF) (hx : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ (2 : ℝ)^(30 : Nat)) :
    projection.Finite input ∧ ∀ i, Model.isFinite (projection.forward input i) = true ∧
      |Model.toReal (projection.forward input i)| ≤ (2 : ℝ)^(44 : Nat) := by
  cases projection with
  | bits3 p =>
    have h := Layers.AffineVerifyLinearShiftedBounds.range3 p profile3 parameters division input
      (fun i => by simpa only [profile3, zpow_ofNat] using hx i)
    exact ⟨h.1, fun i => ⟨p.forward_finite _ h.1 i, by simpa only [Projection.forward, profile3, outputCap_real] using h.2 i⟩⟩
  | bits4 p =>
    have h := Layers.AffineVerifyLinearShiftedBounds.range4 p profile4 parameters division input
      (fun i => by simpa only [profile4, zpow_ofNat] using hx i)
    exact ⟨h.1, fun i => ⟨p.forward_finite _ h.1 i, by simpa only [Projection.forward, profile4, outputCap_real] using h.2 i⟩⟩

end Inference.Models.Qwen.DeltaOutputRanges
