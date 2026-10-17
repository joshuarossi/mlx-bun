import contracts.mlx.RsqrtEpsilonBounds
import models.qwen.NormalizationUniformBounds

namespace Inference.Models.Qwen.NormalizationEpsilonBounds
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Independent adapter for actual 5120-wide normalization with the original
-- scalar function and exact BF16 output. Unlike the older universal envelope,
-- this premise requires no positive-subnormal behavior from the scalar rsqrt.
theorem ranges_wide (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (hw : ∀ i, Model.isFinite (norm.weight i)=true ∧ |Model.toReal (norm.weight i)|≤1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i)=true ∧ |Model.toReal (x i)|≤(2:ℝ)^(56:Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)|≤512 := by
  have h := RsqrtEpsilonBounds.uniform_ranges_wide NormalizationUniformBounds.profile
    norm.platform.divide norm.platform.divError norm.platform.division division norm.platform.rsqrt root
    (RmsNorm.expression norm.platform 5120) (RmsNorm.coverage norm.platform 5120)
    (Blocks.widenInput x) norm.weight
    (NormalizationRanges.widened x 56 (fun i => by simpa only [zpow_ofNat] using hx i))
    (fun i => by simpa only [NormalizationUniformBounds.profile,BFloat16Arithmetic.real_one] using hw i)
  change NormalizationExecution.Finite norm.platform.divide (Blocks.widenInput x) norm.weight
    (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120:Nat):Int)) Blocks.eps norm.platform.rsqrt ∧
      (∀ i, |real (NormalizationExecution.output norm.platform.divide (Blocks.widenInput x) norm.weight
        (RmsNorm.expression norm.platform 5120) (Float32.ofInt ((5120:Nat):Int)) Blocks.eps norm.platform.rsqrt i)|≤
        Model.toReal NormalizationUniformBounds.outputCap) at h
  rw [← NormalizationRanges.width_constructor] at h
  simpa only [NormalizationUniformBounds.outputCap_real] using
    NormalizationRanges.transfer norm x NormalizationUniformBounds.outputCap h.1 h.2

theorem ranges_wide_normal (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtEpsilonBounds.NormalEnvelope norm.platform.rsqrt 2)
    (hw : ∀ i, Model.isFinite (norm.weight i)=true ∧ |Model.toReal (norm.weight i)|≤1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i)=true ∧ |Model.toReal (x i)|≤(2:ℝ)^(56:Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)|≤512 :=
  ranges_wide norm division (RsqrtEpsilonBounds.from_normal root Blocks.eps_normal) hw x hx

end Inference.Models.Qwen.NormalizationEpsilonBounds
