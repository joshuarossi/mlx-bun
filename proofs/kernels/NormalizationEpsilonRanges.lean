import contracts.mlx.RsqrtEpsilonBounds
import kernels.delta.SiluRmsHeadsRanges
import kernels.delta.SiluRmsHeadsEnergy
import kernels.GatedRmsNormRanges

-- Every conclusion concerns the original platform/function and exact output.
-- A completed rsqrt is used only inside the existing mathematical lemma;
-- reached-denominator equality transports the result back before export.
namespace Inference.Kernels.NormalizationEpsilonRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

namespace Silu
open Delta.SiluRmsHeads

theorem normalized (p : Platform) (profile : NormalizationUniform.Profile 128)
    (exponential : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (division : DivisionDirectedBounds.Contract p.divide)
    (root : RsqrtEpsilonBounds.Envelope p.rsqrt profile.eps 2)
    (input weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i)=true ∧ |Model.toReal (input i)|≤(2:ℝ)^(50:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤Model.toReal profile.weightCap) :
    (∀ i, ActivationFinite p (input i)) ∧ NormFinite p input weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (Delta.SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i)=true ∧
        |Model.toReal (Delta.SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i)|≤Model.toReal profile.outputCap := by
  have cap := BFloat16DyadicBounds.ceiling_range 1 50 (by decide) (by decide) (by decide)
  have capReal : Model.toReal (BFloat16DyadicBounds.ceiling 1 50)=(2:ℝ)^(50:Nat) := by
    simpa only [Nat.cast_one,one_mul,zpow_ofNat] using cap.2
  have ha i := Delta.SiluRmsHeadsRanges.activation p exponential (input i) (BFloat16DyadicBounds.ceiling 1 50)
    (hx i).1 cap.1 (by rw [capReal]; exact (hx i).2)
  have hi (i : Fin 128) : (activated p input i).isFinite=true ∧ |real (activated p input i)|≤(2:ℝ)^(56:Nat) := by
    refine ⟨BFloat16.widen_finite _ (ha i).2.1,?_⟩
    rw [activated,BFloat16.widen_real _ (ha i).2.1]
    exact (ha i).2.2.trans (by rw [capReal]; norm_num)
  have hn := RsqrtEpsilonBounds.uniform_ranges_wide profile p.divide p.divError p.division division p.rsqrt root
    (expression p.contracted p.reduction.tree) (expression_coverage _ _ p.reduction.coverage) (activated p input) weight hi hw
  refine ⟨fun i => (ha i).1,hn.1,?_⟩
  intro i
  have hf := normalized_finite p input weight (Float32.ofInt 128) profile.eps hn.1 i
  refine ⟨hf,?_⟩
  have h := hn.2 i
  change |real (BFloat16.widen (Delta.SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i))|≤_ at h
  rwa [BFloat16.widen_real _ hf] at h

theorem normalized_normal (p : Platform) (profile : NormalizationUniform.Profile 128)
    (exponential : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtEpsilonBounds.NormalEnvelope p.rsqrt 2)
    (input weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i)=true ∧ |Model.toReal (input i)|≤(2:ℝ)^(50:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤Model.toReal profile.weightCap) :
    (∀ i, ActivationFinite p (input i)) ∧ NormFinite p input weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (Delta.SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i)=true ∧
        |Model.toReal (Delta.SiluRmsHeads.normalized p input weight (Float32.ofInt 128) profile.eps i)|≤Model.toReal profile.outputCap :=
  normalized p profile exponential division (RsqrtEpsilonBounds.from_normal root profile.epsNormal) input weight hx hw

end Silu

namespace Gated
open GatedRmsNorm

theorem normalization_wide (p : Platform) (profile : NormalizationUniform.Profile 128)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtEpsilonBounds.Envelope p.rsqrt profile.eps 2)
    (input weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i)=true ∧ |Model.toReal (input i)|≤(2:ℝ)^(56:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤Model.toReal profile.weightCap) :
    NormFinite p input weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (normalized p input weight (Float32.ofInt 128) profile.eps i)=true ∧
        |Model.toReal (normalized p input weight (Float32.ofInt 128) profile.eps i)|≤Model.toReal profile.outputCap := by
  have hi (i : Fin 128) : (GatedRmsNorm.input input i).isFinite=true ∧
      |real (GatedRmsNorm.input input i)|≤(2:ℝ)^(56:Nat) := by
    refine ⟨BFloat16.widen_finite _ (hx i).1,?_⟩
    rw [GatedRmsNorm.input,BFloat16.widen_real _ (hx i).1]
    exact (hx i).2
  have hn := RsqrtEpsilonBounds.uniform_ranges_wide profile p.divide p.divError p.division division p.rsqrt root
    (expression p) (Delta.SiluRmsHeads.expression_coverage p.contracted p.reduction.tree p.reduction.coverage)
    (GatedRmsNorm.input input) weight hi hw
  refine ⟨hn.1,?_⟩
  intro i
  have hf := normalized_finite p input weight (Float32.ofInt 128) profile.eps hn.1 i
  refine ⟨hf,?_⟩
  have hb := hn.2 i
  change |real (BFloat16.widen (normalized p input weight (Float32.ofInt 128) profile.eps i))|≤_ at hb
  rwa [BFloat16.widen_real _ hf] at hb

theorem ranges_wide (p : Platform) (norm : NormalizationUniform.Profile 128) (tailProfile : GatedRmsNormRanges.TailProfile)
    (capacity : Model.toReal norm.outputCap≤Model.toReal tailProfile.upCap)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtEpsilonBounds.Envelope p.rsqrt norm.eps 2)
    (exponential : StableSigmoidRanges.ExponentialRange p.expAbs) (input gate weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (input i)=true ∧ |Model.toReal (input i)|≤(2:ℝ)^(56:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤Model.toReal norm.weightCap)
    (hg : ∀ i, Model.isFinite (gate i)=true ∧ |Model.toReal (gate i)|≤real tailProfile.gateCap) :
    NormFinite p input weight (Float32.ofInt 128) norm.eps ∧
      ∀ i, TailFinite p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p input weight (Float32.ofInt 128) norm.eps i)) ∧
        Model.isFinite (value p input gate weight (Float32.ofInt 128) norm.eps i)=true ∧
        |Model.toReal (value p input gate weight (Float32.ofInt 128) norm.eps i)|≤Model.toReal tailProfile.storeCap := by
  have hn := normalization_wide p norm division root input weight hx hw
  refine ⟨hn.1,?_⟩
  intro i
  have hgate : (BFloat16.widen (gate i)).isFinite=true ∧ |real (BFloat16.widen (gate i))|≤real tailProfile.gateCap :=
    ⟨BFloat16.widen_finite _ (hg i).1,by rw [BFloat16.widen_real _ (hg i).1]; exact (hg i).2⟩
  have hup : (BFloat16.widen (normalized p input weight (Float32.ofInt 128) norm.eps i)).isFinite=true ∧
      |real (BFloat16.widen (normalized p input weight (Float32.ofInt 128) norm.eps i))|≤Model.toReal tailProfile.upCap :=
    ⟨BFloat16.widen_finite _ (hn.2 i).1,by rw [BFloat16.widen_real _ (hn.2 i).1]; exact (hn.2 i).2.trans capacity⟩
  have ht := GatedRmsNormRanges.tail_ranges p tailProfile exponential _ _ hgate hup
  exact ⟨ht.1,ht.1.cast,ht.2⟩

end Gated

namespace Energy
open Delta.SiluRmsHeads
open scoped BigOperators

theorem normalizer_bounds (p : Platform) (input : Fin 128 → Float32) (width eps : Float32)
    (hf : NormalizationExecution.ReductionFinite p.divide input (expression p.contracted p.reduction.tree) width eps)
    (hx : ∀ i, (input i).isFinite=true ∧ |real (input i)|≤(2:ℝ)^(50:Nat))
    (epsilonLower : (2:ℝ)^(-21:Int)≤real eps)
    (native : p.divide (NormalizationExecution.sum input (expression p.contracted p.reduction.tree)) width=
      FlushToZero.div (NormalizationExecution.sum input (expression p.contracted p.reduction.tree)) width)
    (root : RsqrtEpsilonBounds.Envelope p.rsqrt eps (17/16)) :
    let inverse := NormalizationExecution.normalizer p.divide input (expression p.contracted p.reduction.tree) width eps p.rsqrt
    inverse.isFinite=true ∧ |real inverse|≤(2:ℝ)^(12:Nat) ∧
      real inverse^2*(∑ i : Fin 128, (real (input i))^2)≤(36992/255:ℝ) := by
  have h := Delta.SiluRmsHeadsEnergy.normalizer_bounds p.divide (RsqrtEpsilonBounds.complete p.rsqrt eps)
    input p.contracted p.reduction.tree p.reduction.coverage width eps hf hx epsilonLower native
    (RsqrtEpsilonBounds.complete_relative root (by norm_num))
  dsimp only at h ⊢
  rw [RsqrtEpsilonBounds.normalizer_eq p.divide p.divError p.division input
    (expression p.contracted p.reduction.tree) width eps hf p.rsqrt] at h
  exact h

theorem normalized_energy (p : Platform) (input weight : Fin 128 → BF) (width eps : Float32) (scale : ℝ)
    (hf : NormalizationExecution.ReductionFinite p.divide (activated p input) (expression p.contracted p.reduction.tree) width eps)
    (hx : ∀ i, (activated p input i).isFinite=true ∧ |real (activated p input i)|≤(2:ℝ)^(50:Nat))
    (hw : ∀ i, Model.isFinite (weight i)=true ∧ |Model.toReal (weight i)|≤scale)
    (sb : scale≤1) (epsilonLower : (2:ℝ)^(-21:Int)≤real eps)
    (native : p.divide (NormalizationExecution.sum (activated p input) (expression p.contracted p.reduction.tree)) width=
      FlushToZero.div (NormalizationExecution.sum (activated p input) (expression p.contracted p.reduction.tree)) width)
    (root : RsqrtEpsilonBounds.Envelope p.rsqrt eps (17/16)) :
    (∀ i, Model.isFinite (Delta.SiluRmsHeads.normalized p input weight width eps i)=true) ∧
      (∑ i : Fin 128, Model.toReal (Delta.SiluRmsHeads.normalized p input weight width eps i)^2)≤
        (9/8:ℝ)*(17/16:ℝ)^2*scale^2*(36992/255:ℝ)+1152*(2:ℝ)^(-120:Int) := by
  have hn := normalizer_bounds p (activated p input) width eps hf hx epsilonLower native root
  exact Delta.SiluRmsHeadsEnergy.stored_energy (activated p input) _ weight scale hx hn.1 hn.2.1 hw sb hn.2.2

end Energy
end Inference.Kernels.NormalizationEpsilonRanges
