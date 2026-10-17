import kernels.GatedRmsNorm
import kernels.StableSigmoidRanges
import contracts.mlx.NormalizationUniform

namespace Inference.Kernels.GatedRmsNormRanges
open Contracts.Mlx Contracts.Mlx.Numerics GatedRmsNorm
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem normalization_wide (p : Platform) (profile : NormalizationUniform.Profile 128)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (x weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal profile.weightCap) :
    NormFinite p x weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (normalized p x weight (Float32.ofInt 128) profile.eps i) = true ∧
        |Model.toReal (normalized p x weight (Float32.ofInt 128) profile.eps i)| ≤ Model.toReal profile.outputCap := by
  have hi (i : Fin 128) : (input x i).isFinite = true ∧ |real (input x i)| ≤ (2 : ℝ)^(56 : Nat) := by
    refine ⟨BFloat16.widen_finite _ (hx i).1, ?_⟩
    rw [input, BFloat16.widen_real _ (hx i).1]
    exact (hx i).2
  have h := NormalizationUniform.ranges_wide profile p.divide p.divError p.division division p.rsqrt root (expression p)
    (Delta.SiluRmsHeads.expression_coverage p.contracted p.reduction.tree p.reduction.coverage) (input x) weight hi hw
  refine ⟨h.1, ?_⟩
  intro i
  have hf := normalized_finite p x weight (Float32.ofInt 128) profile.eps h.1 i
  refine ⟨hf, ?_⟩
  have hb := h.2 i
  change |real (BFloat16.widen (normalized p x weight (Float32.ofInt 128) profile.eps i))| ≤ _ at hb
  rwa [BFloat16.widen_real _ hf] at hb

theorem normalization (p : Platform) (profile : NormalizationUniform.Profile 128)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (x weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal profile.weightCap) :
    NormFinite p x weight (Float32.ofInt 128) profile.eps ∧
      ∀ i, Model.isFinite (normalized p x weight (Float32.ofInt 128) profile.eps i) = true ∧
        |Model.toReal (normalized p x weight (Float32.ofInt 128) profile.eps i)| ≤ Model.toReal profile.outputCap :=
  normalization_wide p profile division root x weight
    (fun i => ⟨(hx i).1, (hx i).2.trans (by norm_num)⟩) hw

structure TailProfile where
  gateCap : Float32
  upCap : BF
  productCap : Float32
  storeCap : BF
  gateFinite : gateCap.isFinite = true
  productFinite : productCap.isFinite = true
  storeFinite : Model.isFinite storeCap = true
  productCapacity : real gateCap * Model.toReal upCap ≤ real productCap
  storeCapacity : real productCap ≤ Model.toReal storeCap

theorem tail_ranges (p : Platform) (profile : TailProfile)
    (exponential : StableSigmoidRanges.ExponentialRange p.expAbs)
    (gate up : Float32) (hg : gate.isFinite = true ∧ |real gate| ≤ real profile.gateCap)
    (hu : up.isFinite = true ∧ |real up| ≤ Model.toReal profile.upCap) :
    TailFinite p gate up ∧ |Model.toReal (tail p gate up)| ≤ Model.toReal profile.storeCap := by
  have hs := StableSigmoidRanges.ranges p.expAbs p.expAbsError p.exponential exponential gate hg.1
  have ha := NativeMultiplication.range gate (StableSigmoid.value p.expAbs gate) profile.gateCap hg.1 hs.2.1 profile.gateFinite (by
    rw [abs_of_nonneg hs.2.2.1]
    exact (mul_le_of_le_one_right (abs_nonneg _) hs.2.2.2).trans hg.2)
  have hp := NativeMultiplication.range (silu p gate) up profile.productCap (FlushToZero.finite_flush _ ha.1) hu.1 profile.productFinite
    ((mul_le_mul ha.2 hu.2 (abs_nonneg _) ((abs_nonneg _).trans ha.2)).trans profile.productCapacity)
  have hc := BFloat16ConversionBounds.narrow_range (product p gate up) profile.storeCap (FlushToZero.finite_flush _ hp.1)
    profile.storeFinite (hp.2.trans profile.storeCapacity)
  exact ⟨⟨hg.1, hs.1, ha.1, hp.1, hc.1⟩, hc.2⟩

theorem ranges_wide (p : Platform) (norm : NormalizationUniform.Profile 128) (tailProfile : TailProfile)
    (capacity : Model.toReal norm.outputCap ≤ Model.toReal tailProfile.upCap)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (exponential : StableSigmoidRanges.ExponentialRange p.expAbs)
    (x gate weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal norm.weightCap)
    (hg : ∀ i, Model.isFinite (gate i) = true ∧ |Model.toReal (gate i)| ≤ real tailProfile.gateCap) :
    NormFinite p x weight (Float32.ofInt 128) norm.eps ∧
      ∀ i, TailFinite p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight (Float32.ofInt 128) norm.eps i)) ∧
        Model.isFinite (value p x gate weight (Float32.ofInt 128) norm.eps i) = true ∧
        |Model.toReal (value p x gate weight (Float32.ofInt 128) norm.eps i)| ≤ Model.toReal tailProfile.storeCap := by
  have hn := normalization_wide p norm division root x weight hx hw
  refine ⟨hn.1, ?_⟩
  intro i
  have hgate : (BFloat16.widen (gate i)).isFinite = true ∧ |real (BFloat16.widen (gate i))| ≤ real tailProfile.gateCap := by
    exact ⟨BFloat16.widen_finite _ (hg i).1, by rw [BFloat16.widen_real _ (hg i).1]; exact (hg i).2⟩
  have hup : (BFloat16.widen (normalized p x weight (Float32.ofInt 128) norm.eps i)).isFinite = true ∧
      |real (BFloat16.widen (normalized p x weight (Float32.ofInt 128) norm.eps i))| ≤ Model.toReal tailProfile.upCap := by
    exact ⟨BFloat16.widen_finite _ (hn.2 i).1,
      by rw [BFloat16.widen_real _ (hn.2 i).1]; exact (hn.2 i).2.trans capacity⟩
  have ht := tail_ranges p tailProfile exponential _ _ hgate hup
  exact ⟨ht.1, ht.1.cast, ht.2⟩

theorem ranges (p : Platform) (norm : NormalizationUniform.Profile 128) (tailProfile : TailProfile)
    (capacity : Model.toReal norm.outputCap ≤ Model.toReal tailProfile.upCap)
    (division : DivisionDirectedBounds.Contract p.divide) (root : RsqrtBounds.Envelope p.rsqrt)
    (exponential : StableSigmoidRanges.ExponentialRange p.expAbs)
    (x gate weight : Fin 128 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ Model.toReal norm.weightCap)
    (hg : ∀ i, Model.isFinite (gate i) = true ∧ |Model.toReal (gate i)| ≤ real tailProfile.gateCap) :
    NormFinite p x weight (Float32.ofInt 128) norm.eps ∧
      ∀ i, TailFinite p (BFloat16.widen (gate i)) (BFloat16.widen (normalized p x weight (Float32.ofInt 128) norm.eps i)) ∧
        Model.isFinite (value p x gate weight (Float32.ofInt 128) norm.eps i) = true ∧
        |Model.toReal (value p x gate weight (Float32.ofInt 128) norm.eps i)| ≤ Model.toReal tailProfile.storeCap :=
  ranges_wide p norm tailProfile capacity division root exponential x gate weight
    (fun i => ⟨(hx i).1, (hx i).2.trans (by norm_num)⟩) hw hg

end Inference.Kernels.GatedRmsNormRanges
