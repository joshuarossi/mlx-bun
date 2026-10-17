import kernels.delta.SiluRmsHeads
import kernels.trellis.SigmoidRanges
import contracts.mlx.NormalizationUniform

namespace Inference.Kernels.Delta.SiluRmsHeadsRanges
open Contracts.Mlx Contracts.Mlx.Numerics SiluRmsHeads
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem activation (p : Platform) (exponential : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (x cap : BF) (hx : Model.isFinite x = true) (hc : Model.isFinite cap = true)
    (bound : |Model.toReal x| ≤ Model.toReal cap) :
    ActivationFinite p x ∧ Model.isFinite (activate p x) = true ∧ |Model.toReal (activate p x)| ≤ Model.toReal cap := by
  have h := Trellis.SigmoidRanges.product p.expAbs p.expAbsError p.exponential exponential x cap hx hc bound
  exact ⟨⟨hx, h.1, h.2.1⟩, BFloat16Arithmetic.finite_flush _ h.2.1, h.2.2⟩

private theorem input_cap : Model.isFinite (BFloat16DyadicBounds.ceiling 1 50) = true ∧
    Model.toReal (BFloat16DyadicBounds.ceiling 1 50) = (2 : ℝ)^(50 : Nat) := by
  simpa only [Nat.cast_one, one_mul, zpow_ofNat] using
    BFloat16DyadicBounds.ceiling_range 1 50 (by decide) (by decide) (by decide)

theorem normalized (p : Platform) (profile : NormalizationUniform.Profile 128)
    (exponential : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (input weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal profile.weightCap) :
    (∀ i, ActivationFinite p (input i)) ∧ NormFinite p input weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i) = true ∧
        |Model.toReal (SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i)| ≤ Model.toReal profile.outputCap := by
  have ha i := activation p exponential (input i) (BFloat16DyadicBounds.ceiling 1 50)
    (hx i).1 input_cap.1 (by rw [input_cap.2]; exact (hx i).2)
  have hi (i : Fin 128) : (activated p input i).isFinite = true ∧ |real (activated p input i)| ≤ (2 : ℝ)^(50 : Nat) := by
    refine ⟨BFloat16.widen_finite _ (ha i).2.1, ?_⟩
    rw [activated, BFloat16.widen_real _ (ha i).2.1]
    exact (ha i).2.2.trans_eq input_cap.2
  have hn := NormalizationUniform.ranges profile p.divide p.divError p.division division p.rsqrt root
    (expression p.contracted p.reduction.tree) (expression_coverage _ _ p.reduction.coverage)
    (activated p input) weight hi hw
  refine ⟨fun i => (ha i).1, hn.1, ?_⟩
  intro i
  have hf := normalized_finite p input weight (Float32.ofInt 128) profile.eps hn.1 i
  refine ⟨hf, ?_⟩
  have h := hn.2 i
  change |real (BFloat16.widen (SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i))| ≤ _ at h
  rwa [BFloat16.widen_real _ hf] at h

theorem accuracy (p : Platform) (profile : NormalizationUniform.Profile 128)
    (exponential : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (input weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i) = true ∧ |Model.toReal (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal profile.weightCap)
    (idealEps epsError : ℝ) (positive : 0 < idealEps) (epsBound : |real profile.eps - idealEps| ≤ epsError)
    (target error : Fin 128 → ℝ) (he : ∀ i, |Model.toReal (input i) - target i| ≤ error i) (i : Fin 128) :
    |Model.toReal (SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i) -
      Normalization.rmsNorm (fun j => silu (target j)) (fun j => Model.toReal (weight j)) idealEps i| ≤
      inputBudget p input weight (Float32.ofInt 128) profile.eps idealEps epsError target error i := by
  have h := normalized p profile exponential division root input weight hx hw
  exact normalized_input_error p input weight (Float32.ofInt 128) profile.eps idealEps epsError positive epsBound
    h.2.1 h.1 target error he i

end Inference.Kernels.Delta.SiluRmsHeadsRanges
