import models.qwen.AttentionInputRanges
import kernels.attention.RopeRanges
import kernels.attention.RopeAnglesRanges

namespace Inference.Models.Qwen.AttentionInitialHeadsRanges
open Contracts.Mlx Contracts.Mlx.Numerics AttentionHeads Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

structure Parameters (prep : Preparation) : Prop where
  query : ∀ i, Model.isFinite (prep.qNorm.weight i) = true ∧ |Model.toReal (prep.qNorm.weight i)| ≤ 4
  key : ∀ i, Model.isFinite (prep.kNorm.weight i) = true ∧ |Model.toReal (prep.kNorm.weight i)| ≤ 4
structure Primitives (prep : Preparation) : Prop where
  queryDivision : DivisionDirectedBounds.Contract prep.qNorm.platform.divide
  queryRoot : RsqrtBounds.Envelope prep.qNorm.platform.rsqrt
  keyDivision : DivisionDirectedBounds.Contract prep.kNorm.platform.divide
  keyRoot : RsqrtBounds.Envelope prep.kNorm.platform.rsqrt
  angleDivision : DivisionBounds.Contract prep.angles.divide
  frequency : RopeAnglesRanges.Exp2Range prep.angles
  rotation : RopeRanges.TrigRanges prep.rotation
  zeroDomain : ∀ theta, theta.isFinite = true → real theta = 0 → prep.rotation.domain theta

structure Result (prep : Preparation) (p : Projections) (input : Fin 5120 → BF) (angle : RopeAngles.Inputs) : Prop where
  preparation : prep.Finite (p.forward input) angle
  finite : AttentionHeads.Finite (prep.forward (p.forward input) angle)
  query : ∀ h i, |Model.toReal ((prep.forward (p.forward input) angle).query h i)| ≤ 1024
  key : ∀ h i, |Model.toReal ((prep.forward (p.forward input) angle).key h i)| ≤ 1024
  value : ∀ h i, |Model.toReal ((prep.forward (p.forward input) angle).value h i)| ≤ (2 : ℝ)^(23 : Nat)
  gate : ∀ h i, |Model.toReal ((prep.forward (p.forward input) angle).gate h i)| ≤ (2 : ℝ)^(23 : Nat)

theorem ranges (prep : Preparation) (parameters : Parameters prep) (primitive : Primitives prep)
    (p : Projections) (input : Fin 5120 → BF) (projection : AttentionInputRanges.Projected p input)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    Result prep p input angle := by
  have hn := AttentionInputRanges.head_norms prep p input projection primitive.queryDivision primitive.queryRoot
    primitive.keyDivision primitive.keyRoot parameters.query parameters.key
  have hang i := RopeAnglesRanges.ranges prep.angles primitive.angleDivision primitive.frequency angle ha i
  have htheta i := RopeAngles.value_finite prep.angles angle i (hang i).1
  have hz i := RopeAnglesRanges.zero_position prep.angles primitive.angleDivision primitive.frequency angle ha position i
  have hq h i := RopeRanges.ranges prep.rotation primitive.rotation
    (Rope.headInputs ((prep.normalized (p.forward input)).query h) (RopeAngles.value prep.angles angle) i)
    ⟨hn.finite.query h _, hn.query h _⟩ ⟨hn.finite.query h _, hn.query h _⟩ (htheta i)
    (primitive.zeroDomain _ (htheta i) (hz i))
  have hk h i := RopeRanges.ranges prep.rotation primitive.rotation
    (Rope.headInputs ((prep.normalized (p.forward input)).key h) (RopeAngles.value prep.angles angle) i)
    ⟨hn.finite.key h _, hn.key h _⟩ ⟨hn.finite.key h _, hn.key h _⟩ (htheta i)
    (primitive.zeroDomain _ (htheta i) (hz i))
  have hf : prep.Finite (p.forward input) angle := {
    qWeight := fun i => (parameters.query i).1
    kWeight := fun i => (parameters.key i).1
    qNorm := hn.qNorm
    kNorm := hn.kNorm
    angleRange := fun i => (hang i).1
    qRotation := fun h i => ⟨(hq h i).1.inputs.domain, (hq h i).1.inputs.sine, (hq h i).1.inputs.cosine,
      (hq h i).1.inputs.product, (hq h i).1.arithmetic, (hq h i).1.cast⟩
    kRotation := fun h i => ⟨(hk h i).1.inputs.domain, (hk h i).1.inputs.sine, (hk h i).1.inputs.cosine,
      (hk h i).1.inputs.product, (hk h i).1.arithmetic, (hk h i).1.cast⟩ }
  refine ⟨hf, prep.forward_finite _ angle (p.forward_finite input projection.finite) hf, ?_, ?_, projection.value, projection.gate⟩
  · intro h i
    change |Model.toReal (Rope.head prep.rotation _ _ i)| ≤ 1024
    unfold Rope.head
    split
    · exact (hq h _).2 _
    · exact (hn.query h i).trans (by norm_num)
  · intro h i
    change |Model.toReal (Rope.head prep.rotation _ _ i)| ≤ 1024
    unfold Rope.head
    split
    · exact (hk h _).2 _
    · exact (hn.key h i).trans (by norm_num)

end Inference.Models.Qwen.AttentionInitialHeadsRanges
