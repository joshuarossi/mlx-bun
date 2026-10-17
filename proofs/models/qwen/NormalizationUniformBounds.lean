import models.qwen.NormalizationRanges
import contracts.mlx.NormalizationUniform

namespace Inference.Models.Qwen.NormalizationUniformBounds
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 9
theorem outputCap_real : Model.toReal outputCap = 512 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 9 (by decide) (by decide) (by decide)).2
  norm_num only [Nat.cast_one, one_mul, zpow_ofNat] at h
  exact h

-- Loaded main-normalization gains are bounded by one. The scalar-primitive
-- contracts and this parameter premise are kept separate from loader binding.
def profile : NormalizationUniform.Profile 5120 where
  positive := by decide
  widthLog := 13
  widthLogBound := by decide
  widthBound := by decide
  normalizedExponent := 9
  normalizedPositive := by decide
  normalizedBound := by decide
  rootCapacity := by decide
  eps := Blocks.eps
  epsFinite := Blocks.eps_finite
  epsNormal := Blocks.eps_normal
  epsBound := by rw [Blocks.eps_value]; norm_num
  smallCapacity := by rw [Blocks.eps_value]; norm_num
  weightCap := BFloat16Arithmetic.one
  outputCap := outputCap
  outputFinite := (BFloat16DyadicBounds.ceiling_range 1 9 (by decide) (by decide) (by decide)).1
  outputCapacity := by rw [BFloat16Arithmetic.real_one, outputCap_real]; norm_num

theorem ranges (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(50 : Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ 512 := by
  have h := NormalizationUniform.ranges profile norm.platform.divide norm.platform.divError norm.platform.division
    division norm.platform.rsqrt root (RmsNorm.expression norm.platform 5120) (RmsNorm.coverage norm.platform 5120)
    (Blocks.widenInput x) norm.weight
    (NormalizationRanges.widened x 50 (fun i => by simpa only [zpow_ofNat] using hx i))
    (fun i => by simpa only [profile, BFloat16Arithmetic.real_one] using hw i)
  change NormalizationExecution.Finite norm.platform.divide (Blocks.widenInput x) norm.weight
    (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120 : Nat) : Int)) Blocks.eps norm.platform.rsqrt ∧
      (∀ i, |real (NormalizationExecution.output norm.platform.divide (Blocks.widenInput x) norm.weight
        (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120 : Nat) : Int)) Blocks.eps norm.platform.rsqrt i)| ≤ Model.toReal outputCap) at h
  rw [← NormalizationRanges.width_constructor] at h
  simpa only [outputCap_real] using NormalizationRanges.transfer norm x outputCap h.1 h.2

theorem ranges_wide (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ 512 := by
  have h := NormalizationUniform.ranges_wide profile norm.platform.divide norm.platform.divError norm.platform.division
    division norm.platform.rsqrt root (RmsNorm.expression norm.platform 5120) (RmsNorm.coverage norm.platform 5120)
    (Blocks.widenInput x) norm.weight
    (NormalizationRanges.widened x 56 (fun i => by simpa only [zpow_ofNat] using hx i))
    (fun i => by simpa only [profile, BFloat16Arithmetic.real_one] using hw i)
  change NormalizationExecution.Finite norm.platform.divide (Blocks.widenInput x) norm.weight
    (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120 : Nat) : Int)) Blocks.eps norm.platform.rsqrt ∧
      (∀ i, |real (NormalizationExecution.output norm.platform.divide (Blocks.widenInput x) norm.weight
        (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120 : Nat) : Int)) Blocks.eps norm.platform.rsqrt i)| ≤ Model.toReal outputCap) at h
  rw [← NormalizationRanges.width_constructor] at h
  simpa only [outputCap_real] using NormalizationRanges.transfer norm x outputCap h.1 h.2

end Inference.Models.Qwen.NormalizationUniformBounds
