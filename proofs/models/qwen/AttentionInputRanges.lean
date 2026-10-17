import models.qwen.AttentionHeads
import models.qwen.NormalizedAffineProjection

namespace Inference.Models.Qwen.AttentionInputRanges
open Contracts.Mlx Contracts.Mlx.Numerics AttentionHeads
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

structure Parameters (p : Projections) : Prop where
  q : NormalizedAffineProjection.Parameters p.q
  k : NormalizedAffineProjection.Parameters p.k
  v : NormalizedAffineProjection.Parameters p.v
structure Divisions (p : Projections) : Prop where
  q : NormalizedAffineProjection.DivisionContract p.q
  k : NormalizedAffineProjection.DivisionContract p.k
  v : NormalizedAffineProjection.DivisionContract p.v

structure Projected (p : Projections) (input : Fin 5120 → BF) : Prop where
  finite : p.Finite input
  query : ∀ h i, |Model.toReal ((p.forward input).query h i)| ≤ (2 : ℝ)^(23 : Nat)
  key : ∀ h i, |Model.toReal ((p.forward input).key h i)| ≤ (2 : ℝ)^(23 : Nat)
  value : ∀ h i, |Model.toReal ((p.forward input).value h i)| ≤ (2 : ℝ)^(23 : Nat)
  gate : ∀ h i, |Model.toReal ((p.forward input).gate h i)| ≤ (2 : ℝ)^(23 : Nat)

theorem projections (norm : Blocks.Norm) (p : Projections) (parameters : Parameters p) (divisions : Divisions p)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ Projected p (norm.forward x) := by
  have hq := NormalizedAffineProjection.ranges norm p.q parameters.q normDivision root divisions.q hw x hx
  have hk := NormalizedAffineProjection.ranges norm p.k parameters.k normDivision root divisions.k hw x hx
  have hv := NormalizedAffineProjection.ranges norm p.v parameters.v normDivision root divisions.v hw x hx
  exact ⟨hq.1, ⟨⟨hq.2.1, hk.2.1, hv.2.1⟩,
    fun h i => (hq.2.2 (queryIndex h i)).2, fun h i => (hk.2.2 (kvIndex h i)).2,
    fun h i => (hv.2.2 (kvIndex h i)).2, fun h i => (hq.2.2 (gateIndex h i)).2⟩⟩

theorem width_constructor : AttentionHeads.width = Float32.ofInt ((256 : Nat) : Int) := by decide +kernel
def weightCap : BF := BFloat16DyadicBounds.ceiling 1 2
def outputCap : BF := BFloat16DyadicBounds.ceiling 1 8
theorem weightCap_real : Model.toReal weightCap = 4 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 2 (by decide) (by decide) (by decide)).2
  exact h.trans (by norm_num)
theorem outputCap_real : Model.toReal outputCap = 256 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 8 (by decide) (by decide) (by decide)).2
  exact h.trans (by norm_num)

def normProfile : NormalizationUniform.Profile 256 where
  positive := by decide
  widthLog := 8
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
  weightCap := weightCap
  outputCap := outputCap
  outputFinite := (BFloat16DyadicBounds.ceiling_range 1 8 (by decide) (by decide) (by decide)).1
  outputCapacity := by rw [weightCap_real, outputCap_real]; norm_num

theorem norm_ranges (norm : AttentionHeads.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 4)
    (x : Fin 256 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(23 : Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ 256 := by
  have h := NormalizationUniform.ranges normProfile norm.platform.divide norm.platform.divError norm.platform.division
    division norm.platform.rsqrt root (RmsNorm.expression norm.platform 256) (RmsNorm.coverage norm.platform 256)
    (fun i => BFloat16.widen (x i)) norm.weight
    (fun i => ⟨BFloat16.widen_finite _ (hx i).1, by
      rw [BFloat16.widen_real _ (hx i).1]; exact (hx i).2.trans (by norm_num)⟩)
    (fun i => by simpa only [normProfile, weightCap_real] using hw i)
  change NormalizationExecution.Finite norm.platform.divide (fun i => BFloat16.widen (x i)) norm.weight
    (RmsNorm.expression norm.platform 256) (Float32.ofInt ((256 : Nat) : Int)) Blocks.eps norm.platform.rsqrt ∧
      (∀ i, |real (NormalizationExecution.output norm.platform.divide (fun j => BFloat16.widen (x j)) norm.weight
        (RmsNorm.expression norm.platform 256) (Float32.ofInt ((256 : Nat) : Int)) Blocks.eps norm.platform.rsqrt i)| ≤ Model.toReal outputCap) at h
  rw [← width_constructor] at h
  refine ⟨h.1, fun i => ?_⟩
  rw [← BFloat16.widen_real _ (norm.forward_finite x h.1 i)]
  unfold AttentionHeads.Norm.forward Layers.Normalization.value
  simp only [Layers.Normalization.prepare, Bool.false_eq_true, ite_false]
  unfold RmsNorm.value
  rw [RmsNorm.inverse_correct]
  simpa only [outputCap_real, NormalizationExecution.output, NormalizationExecution.normalized] using h.2 i

structure Normalized (prep : Preparation) (x : Heads BF) : Prop where
  qNorm : ∀ h, prep.qNorm.Finite (x.query h)
  kNorm : ∀ h, prep.kNorm.Finite (x.key h)
  finite : AttentionHeads.Finite (prep.normalized x)
  query : ∀ h i, |Model.toReal ((prep.normalized x).query h i)| ≤ 256
  key : ∀ h i, |Model.toReal ((prep.normalized x).key h i)| ≤ 256

theorem head_norms (prep : Preparation) (p : Projections) (input : Fin 5120 → BF) (projection : Projected p input)
    (qDivision : DivisionDirectedBounds.Contract prep.qNorm.platform.divide) (qRoot : RsqrtBounds.Envelope prep.qNorm.platform.rsqrt)
    (kDivision : DivisionDirectedBounds.Contract prep.kNorm.platform.divide) (kRoot : RsqrtBounds.Envelope prep.kNorm.platform.rsqrt)
    (qw : ∀ i, Model.isFinite (prep.qNorm.weight i) = true ∧ |Model.toReal (prep.qNorm.weight i)| ≤ 4)
    (kw : ∀ i, Model.isFinite (prep.kNorm.weight i) = true ∧ |Model.toReal (prep.kNorm.weight i)| ≤ 4) :
    Normalized prep (p.forward input) := by
  have hf := p.forward_finite input projection.finite
  have hq h := norm_ranges prep.qNorm qDivision qRoot qw _ (fun i => ⟨hf.query h i, projection.query h i⟩)
  have hk h := norm_ranges prep.kNorm kDivision kRoot kw _ (fun i => ⟨hf.key h i, projection.key h i⟩)
  exact ⟨fun h => (hq h).1, fun h => (hk h).1,
    ⟨fun h i => prep.qNorm.forward_finite _ (hq h).1 i, fun h i => prep.kNorm.forward_finite _ (hk h).1 i, hf.value, hf.gate⟩,
    fun h i => (hq h).2 i, fun h i => (hk h).2 i⟩

end Inference.Models.Qwen.AttentionInputRanges
