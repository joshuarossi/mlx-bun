import models.qwen.NormalizationEpsilonBounds
import models.qwen.AttentionHeadEpsilonRanges
import models.qwen.DeltaHeadEnergyEpsilonRanges
import models.qwen.DeltaOutputEpsilonRanges
import models.qwen.ResidualDeltaDecodeRanges
import models.qwen.ResidualAttentionSequenceRanges

-- Reached-range composition for ORIGINAL stages. These records deliberately
-- do not inhabit the old universal-rsqrt Primitives types. Checkpoint weights,
-- scalar divide/exp/trig/max behavior and cache/input invariants stay explicit.
namespace Inference.Models.Qwen.ReachedStageRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 10000

namespace Affine
open Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds NormalizedAffineProjection
theorem range3 (norm : Blocks.Norm) (projection : Projection3 10 rows)
    (parameters : Parameters3 projection profile3)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  have hn := NormalizationEpsilonBounds.ranges_wide norm normDivision root hw x hx
  have hp := Layers.AffineVerifyLinearShiftedBounds.range3 projection profile3 parameters projectDivision (norm.forward x)
    (fun i => ⟨norm.forward_finite x hn.1 i, by simpa only [profile3, show (2 : ℝ)^(9 : Int) = 512 from by norm_num] using hn.2 i⟩)
  exact ⟨hn.1, hp.1, fun row => ⟨projection.forward_finite _ hp.1 row,
    by simpa only [profile3, outputCap_real] using hp.2 row⟩⟩

theorem range4 (norm : Blocks.Norm) (projection : Projection4 10 rows)
    (parameters : Parameters4 projection profile4)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  have hn := NormalizationEpsilonBounds.ranges_wide norm normDivision root hw x hx
  have hp := Layers.AffineVerifyLinearShiftedBounds.range4 projection profile4 parameters projectDivision (norm.forward x)
    (fun i => ⟨norm.forward_finite x hn.1 i, by simpa only [profile4, show (2 : ℝ)^(9 : Int) = 512 from by norm_num] using hn.2 i⟩)
  exact ⟨hn.1, hp.1, fun row => ⟨projection.forward_finite _ hp.1 row,
    by simpa only [profile4, outputCap_real] using hp.2 row⟩⟩

theorem ranges (norm : Blocks.Norm) (projection : Projection 10 rows)
    (parameters : Parameters projection)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2) (projectDivision : DivisionContract projection)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  cases projection with
  | bits3 p => exact range3 norm p parameters normDivision root projectDivision hw x hx
  | bits4 p => exact range4 norm p parameters normDivision root projectDivision hw x hx


end Affine

namespace DeltaProjection
open DeltaNet DeltaInputRanges
theorem projections (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters layer) (divisions : Divisions layer)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat)) :
    (∀ t, norm.Finite (x t)) ∧ ProjectionRanges layer (fun t => norm.forward (x t)) := by
  have hq t := Affine.ranges norm layer.qkv parameters.qkv normDivision root divisions.qkv hw (x t) (hx t)
  have hz t := Affine.ranges norm layer.z parameters.z normDivision root divisions.z hw (x t) (hx t)
  have ha t := Affine.ranges norm layer.a parameters.a normDivision root divisions.a hw (x t) (hx t)
  have hb t := Affine.ranges norm layer.b parameters.b normDivision root divisions.b hw (x t) (hx t)
  exact ⟨fun t => (hq t).1,
    ⟨⟨fun t => (hq t).2.1, fun t => (ha t).2.1, fun t => (hb t).2.1, fun t => (hz t).2.1⟩,
      fun t c => ((hq t).2.2 c).2, fun t c => ((hz t).2.2 c).2,
      fun t c => ((ha t).2.2 c).2, fun t c => ((hb t).2.2 c).2⟩⟩


end DeltaProjection

namespace DeltaRecurrence
open Kernels.Delta DeltaNet DeltaDecodeRecurrenceRanges
theorem from_projections (layer : Layer) (headParameters : DeltaHeadEnergy.Parameters layer)
    (gateParameters : DeltaGateRanges.Parameters layer)
    (headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs)
    (division : DivisionDirectedBounds.Contract layer.recurrence.heads.divide)
    (root : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt Blocks.eps (17/16))
    (native : ∀ x, x.isFinite = true → layer.recurrence.heads.divide x (Float32.ofInt 128) =
      FlushToZero.div x (Float32.ofInt 128))
    (decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile)
    (beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs)
    (cache : Cache) (input : Nat → Fin 5120 → BF) (projection : DeltaInputRanges.ProjectionRanges layer input)
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (weight : ∀ c i, Model.isFinite (layer.convolutionWeight c i) = true ∧ |Model.toReal (layer.convolutionWeight c i)| ≤ 1)
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144) : Result layer cache input time := by
  have conv := DeltaInputRanges.convolution layer cache input projection history weight
  exact ranges layer cache input time supported
    (DeltaHeadEnergyEpsilonRanges.from_convolution layer headParameters headExp division root native cache input 0
      (fun c => ⟨conv.1.cast 0 c, conv.2 0 c⟩))
    (DeltaGateRanges.ranges layer gateParameters decay beta input projection 0) stateFinite stateBound

end DeltaRecurrence

namespace DeltaMix
open Kernels.Delta DeltaNet DeltaDecodeRanges
open DeltaInitialRanges (normalizedInput)
structure Primitives (norm : Blocks.Norm) (layer : Layer) where
  normalizationDivision : DivisionDirectedBounds.Contract norm.platform.divide
  normalizationRoot : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2
  projections : DeltaInputRanges.Divisions layer
  headExp : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.heads.expAbs
  headDivision : DivisionDirectedBounds.Contract layer.recurrence.heads.divide
  decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay DeltaGateRanges.profile
  beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs
  gatedDivision : DivisionDirectedBounds.Contract layer.gated.divide
  gatedRoot : RsqrtEpsilonBounds.Envelope layer.gated.rsqrt Blocks.eps 2
  gatedExp : Kernels.StableSigmoidRanges.ExponentialRange layer.gated.expAbs
  output : DeltaOutputRanges.Divisions layer.out

  headRootTight : RsqrtEpsilonBounds.Envelope layer.recurrence.heads.rsqrt Blocks.eps (17/16)
  headDivisionNative : ∀ x, x.isFinite=true → layer.recurrence.heads.divide x (Float32.ofInt 128)=FlushToZero.div x (Float32.ofInt 128)

theorem ranges (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer) (primitive : Primitives norm layer)
    (cache : Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t i, Model.isFinite (x t i) = true ∧ |Model.toReal (x t i)| ≤ (2 : ℝ)^(56 : Nat))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144) : Result norm layer cache x time := by
  have hp := DeltaProjection.projections norm layer parameters.projections primitive.projections
    primitive.normalizationDivision primitive.normalizationRoot parameters.normalization x hx
  have hc := DeltaInputRanges.convolution layer cache (normalizedInput norm x) hp.2 history parameters.convolution
  have headParameters : DeltaHeadEnergy.Parameters layer := ⟨parameters.heads, parameters.keyScale⟩
  have hr := DeltaRecurrence.from_projections layer headParameters parameters.gates primitive.headExp
    primitive.headDivision primitive.headRootTight primitive.headDivisionNative primitive.decay primitive.beta
    cache (normalizedInput norm x) hp.2 history parameters.convolution stateFinite stateBound supported
  have hg := DeltaOutputEpsilonRanges.gated_wide layer cache (normalizedInput norm x) 0 parameters.heads parameters.gated
    hp.2 hr.finite hr.output primitive.gatedDivision primitive.gatedRoot primitive.gatedExp
  have ho := DeltaOutputRanges.project layer.out parameters.output primitive.output
    (merged layer cache (normalizedInput norm x) 0) hg.2
  exact ⟨hp.1, ⟨hp.2.finite, hc.1, hr.finite, hg.1, ho.1⟩, fun i => (ho.2 i).2, hr.state,
    fun i c => DeltaInputRanges.history_after layer cache (normalizedInput norm x) hp.2 history 1 i c⟩


end DeltaMix

namespace Mlp
open ResidualBlocks ResidualMlpRanges
structure Primitives (b : Mlp) where
  division : DivisionDirectedBounds.Contract b.norm.platform.divide
  root : RsqrtEpsilonBounds.Envelope b.norm.platform.rsqrt Blocks.eps 2
  expAbs : BF → BF
  expError : BF → ℝ
  selected : b.mlp.activation = .split expAbs
  exponential : Kernels.Trellis.GateUpSplitTail.ExpAbsContract expAbs expError
  expRange : Kernels.Trellis.SigmoidRanges.ExponentialRange expAbs

noncomputable def checked (b : Mlp) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update) : Result b stage x update := by
  have ha i := residual_ranges stage hs x update hx hu i
  have hn := NormalizationEpsilonBounds.ranges_wide b.norm primitive.division primitive.root parameters.normalization
    (residual x update) (fun i => ⟨(ha i).1.cast, (ha i).2.trans (residual_ceiling stage hs)⟩)
  have hi : TrellisMlpRanges.InputBound (b.inputBits x update) := packed_bound (b.normalized x update)
    (fun i => ⟨b.norm.forward_finite _ hn.1 i, hn.2 i⟩)
  let hf : b.Finite x update := {
    addition := fun i => (ha i).1
    normalization := hn.1
    mlp := TrellisMlpRanges.finite b.mlp parameters.mlp _ hi primitive.expAbs primitive.expError
      primitive.selected primitive.exponential primitive.expRange }
  have hm := TrellisMlpRanges.ranges b.mlp parameters.mlp _ hi primitive.expAbs primitive.expError
    primitive.selected primitive.exponential primitive.expRange
  have capacity : Model.toReal (residualCap stage) + Model.toReal TrellisMlpRanges.outputCap ≤ Model.toReal (outputCap stage) := by
    rw [(residualCap_range stage hs).2, TrellisMlpRanges.outputCap_range.2, (outputCap_range stage hs).2]
    push_cast
    norm_num
    linarith
  let bounds : ElementwiseAdd.Bounds (residual x update) (b.branch x update) := {
    leftBound := fun _ => Model.toReal (residualCap stage)
    rightBound := fun _ => Model.toReal TrellisMlpRanges.outputCap
    leftFinite := fun i => (ha i).1.cast
    rightFinite := fun i => TrellisMlp.forward_finite b.mlp _ hf.mlp i
    leftMagnitude := fun i => (ha i).2
    rightMagnitude := hm.2
    capacity := fun _ => capacity.trans (BFloat16Bounds.ceiling_max _ (outputCap_range stage hs).1) }
  refine ⟨hf, bounds, fun i => ?_⟩
  have ho := BFloat16Bounds.add_range (residual x update i) (b.branch x update i) (outputCap stage)
    (bounds.leftFinite i) (bounds.rightFinite i) (outputCap_range stage hs).1
    ((add_le_add (bounds.leftMagnitude i) (bounds.rightMagnitude i)).trans capacity)
  simpa only [Mlp.forward, ElementwiseAdd.forward, (outputCap_range stage hs).2] using ho.2

theorem next_input (b : Mlp) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x update : Fin 5120 → BF)
    (hx : InputBound stage x) (hu : UpdateBound update) : InputBound (stage+1) (b.forward x update) := by
  let h := checked b parameters primitive stage hs x update hx hu
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold inputCeiling
  push_cast
  norm_num
  linarith


end Mlp

namespace DeltaResidual
open ResidualDelta Kernels.Delta ResidualDeltaDecodeRanges
structure Primitives (b : Layer) where
  mixer : DeltaMix.Primitives b.inputNorm b.mixer
  suffix : Mlp.Primitives b.suffix

noncomputable def checked (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144) : Result b stage time cache x := by
  have hcap : ResidualMlpRanges.inputCeiling stage ≤ (2 : ℝ)^(56 : Nat) := by
    have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
    unfold ResidualMlpRanges.inputCeiling
    push_cast
    norm_num
    linarith
  have mixer := DeltaMix.ranges b.inputNorm b.mixer parameters.mixer primitive.mixer cache x
    (fun t i => ⟨(hx t i).1, (hx t i).2.trans hcap⟩) history stateFinite stateBound supported
  have update : ResidualMlpRanges.UpdateBound (b.mixed cache x 0) :=
    fun i => ⟨b.mixer.forward_finite _ _ 0 mixer.finite i, mixer.output i⟩
  let suffix := Mlp.checked b.suffix parameters.suffix primitive.suffix stage hs
    (x 0) (b.mixed cache x 0) (hx 0) update
  exact ⟨⟨fun t i => (hx t i).1, fun i => (parameters.mixer.normalization i).1,
    mixer.normalization, mixer.finite, suffix.finite⟩, suffix.addition, suffix.output, mixer.recurrent, mixer.history⟩

theorem next_input (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (cache : DeltaNet.Cache) (x : Nat → Fin 5120 → BF)
    (hx : ∀ t, ResidualMlpRanges.InputBound stage (x t))
    (history : ∀ i c, Model.isFinite (cache.history i c) = true ∧ |Model.toReal (cache.history i c)| ≤ (2 : ℝ)^(34 : Nat))
    (stateFinite : ∀ h v i, (cache.recurrent h v i).isFinite = true)
    (stateBound : ∀ h v, RecurrenceStability.magnitude (fun i => real (cache.recurrent h v i)) ≤ RecurrenceEnvelope.bound time)
    (supported : time+1 ≤ 262144) : ResidualMlpRanges.InputBound (stage+1) (b.forward cache x 0) := by
  let h := checked b parameters primitive stage hs cache x hx history stateFinite stateBound supported
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold ResidualMlpRanges.inputCeiling
  push_cast
  norm_num
  linarith


end DeltaResidual

namespace AttentionProjection
open AttentionHeads AttentionInputRanges
theorem projections (norm : Blocks.Norm) (p : Projections) (parameters : Parameters p) (divisions : Divisions p)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ Projected p (norm.forward x) := by
  have hq := Affine.ranges norm p.q parameters.q normDivision root divisions.q hw x hx
  have hk := Affine.ranges norm p.k parameters.k normDivision root divisions.k hw x hx
  have hv := Affine.ranges norm p.v parameters.v normDivision root divisions.v hw x hx
  exact ⟨hq.1, ⟨⟨hq.2.1, hk.2.1, hv.2.1⟩,
    fun h i => (hq.2.2 (queryIndex h i)).2, fun h i => (hk.2.2 (kvIndex h i)).2,
    fun h i => (hv.2.2 (kvIndex h i)).2, fun h i => (hq.2.2 (gateIndex h i)).2⟩⟩


end AttentionProjection

namespace AttentionHeadsReached
open AttentionHeads Kernels.Attention
structure Primitives (prep : Preparation) : Prop where
  queryDivision : DivisionDirectedBounds.Contract prep.qNorm.platform.divide
  queryRoot : RsqrtEpsilonBounds.Envelope prep.qNorm.platform.rsqrt Blocks.eps 2
  keyDivision : DivisionDirectedBounds.Contract prep.kNorm.platform.divide
  keyRoot : RsqrtEpsilonBounds.Envelope prep.kNorm.platform.rsqrt Blocks.eps 2
  angleDivision : DivisionBounds.Contract prep.angles.divide
  frequency : RopeAnglesRanges.Exp2Range prep.angles
  rotation : RopeRanges.TrigRanges prep.rotation
  zeroDomain : ∀ theta, theta.isFinite = true → real theta = 0 → prep.rotation.domain theta

theorem ranges (prep : Preparation) (parameters : AttentionInitialHeadsRanges.Parameters prep)
    (primitive : Primitives prep) (domain : AttentionSequenceHeadsRanges.AngleDomain prep)
    (p : Projections) (input : Fin 5120 → BF) (projection : AttentionInputRanges.Projected p input)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) :
    AttentionInitialHeadsRanges.Result prep p input angle := by
  have hn := AttentionHeadEpsilonRanges.head_norms prep p input projection primitive.queryDivision primitive.queryRoot
    primitive.keyDivision primitive.keyRoot parameters.query parameters.key
  have hang i := RopeAnglesRanges.ranges prep.angles primitive.angleDivision primitive.frequency angle ha i
  have htheta i := RopeAngles.value_finite prep.angles angle i (hang i).1
  have hq h i := RopeRanges.ranges prep.rotation primitive.rotation
    (Rope.headInputs ((prep.normalized (p.forward input)).query h) (RopeAngles.value prep.angles angle) i)
    ⟨hn.finite.query h _, hn.query h _⟩ ⟨hn.finite.query h _, hn.query h _⟩ (htheta i)
    (domain _ (htheta i) (hang i).2)
  have hk h i := RopeRanges.ranges prep.rotation primitive.rotation
    (Rope.headInputs ((prep.normalized (p.forward input)).key h) (RopeAngles.value prep.angles angle) i)
    ⟨hn.finite.key h _, hn.key h _⟩ ⟨hn.finite.key h _, hn.key h _⟩ (htheta i)
    (domain _ (htheta i) (hang i).2)
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

end AttentionHeadsReached

namespace AttentionMix
open Attention Kernels.Attention AttentionSequenceRanges
structure Primitives (norm : Blocks.Norm) (layer : Layer) where
  normalization : DivisionDirectedBounds.Contract norm.platform.divide
  root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2
  projections : AttentionInputRanges.Divisions layer.projections
  heads : AttentionHeadsReached.Primitives layer.preparation
  attention : SdpaInitialRanges.Primitives layer.attention
  gate : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.gate.expAbs
  output : DeltaOutputRanges.Divisions layer.output

  angleDomain : AttentionSequenceHeadsRanges.AngleDomain layer.preparation
  attentionDivision : DivisionDirectedBounds.Contract layer.attention.normalization.divide

theorem ranges (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer)
    (primitive : Primitives norm layer) (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (steps : Nat) (bound : steps+1 ≤ 262144) (cache : Cache BF steps)
    (cacheKeys : ∀ h t i, Model.isFinite (cache.keys h t i) = true ∧ |Model.toReal (cache.keys h t i)| ≤ 1024)
    (cacheValues : ∀ h t i, Model.isFinite (cache.values h t i) = true ∧
      |Model.toReal (cache.values h t i)| ≤ (2 : ℝ)^(23 : Nat)) : Result norm layer x angle cache := by
  have proj := AttentionProjection.projections norm layer.projections parameters.projections primitive.projections
    primitive.normalization primitive.root parameters.normalization x hx
  have heads := AttentionHeadsReached.ranges layer.preparation parameters.heads primitive.heads primitive.angleDomain
    layer.projections (norm.forward x) proj.2 angle ha
  have keys h t i : Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).keys h t i) = true ∧
      |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).keys h t i)| ≤ 1024 := by
    unfold Layer.cacheAfter State.Kv.append State.Kv.appendRows
    dsimp only
    split
    · exact cacheKeys h _ i
    · exact ⟨heads.finite.key h i, heads.key h i⟩
  have values h t i : Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).values h t i) = true ∧
      |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).values h t i)| ≤ (2 : ℝ)^(23 : Nat) := by
    unfold Layer.cacheAfter State.Kv.append State.Kv.appendRows
    dsimp only
    split
    · exact cacheValues h _ i
    · exact ⟨heads.finite.value h i, heads.value h i⟩
  have attention : SdpaSequenceRanges.Primitives layer.attention :=
    ⟨primitive.attention.maximum, primitive.attention.exponential, primitive.attentionDivision⟩
  have read h := SdpaDispatched.ranges layer.attention attention layer.mergeContracted layer.architectureSuffix (steps+1) (by omega) bound
    ((layer.heads (norm.forward x) angle).query h)
    ((layer.cacheAfter (norm.forward x) angle cache).keys (SdpaScore.kvHead h))
    ((layer.cacheAfter (norm.forward x) angle cache).values (SdpaScore.kvHead h))
    (fun i => ⟨heads.finite.query h i, heads.query h i⟩) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h))
  have gated h i := OutputGateRanges.ranges layer.gate primitive.gate (layer.read (norm.forward x) angle cache h i)
    ((layer.heads (norm.forward x) angle).gate h i) SdpaTwoPassRanges.outputCap
    (SdpaDispatched.forward_finite _ _ _ _ _ _ (read h).1 i) (heads.finite.gate h i) SdpaTwoPassRanges.outputCap_range.1
    (by rw [SdpaTwoPassRanges.outputCap_range.2]; exact (read h).2 i)
  have output := DeltaOutputRanges.project layer.output parameters.output primitive.output (layer.merged (norm.forward x) angle cache)
    (fun i => ⟨(gated (headIndex i) (coordinate i)).2.2.1, by
      have h := (gated (headIndex i) (coordinate i)).2.2.2
      rw [SdpaTwoPassRanges.outputCap_range.2] at h
      exact h.trans (by norm_num)⟩)
  exact ⟨proj.1, ⟨proj.2.finite, heads.preparation,
    fun h => (read h).1,
    fun h i => (gated h i).1, fun h i => (gated h i).2.1, output.1⟩, output.2, keys, values⟩

end AttentionMix

namespace AttentionResidual
open ResidualAttention Kernels.Attention ResidualAttentionSequenceRanges
structure Primitives (b : Layer) where
  mixer : AttentionMix.Primitives b.inputNorm b.mixer
  suffix : Mlp.Primitives b.suffix

noncomputable def checked (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (hc : CacheBound cache) (supported : steps+1 ≤ 262144) : Result b stage x angle cache := by
  have hcap : ResidualMlpRanges.inputCeiling stage ≤ (2 : ℝ)^(56 : Nat) := by
    have h : (stage : ℝ) ≤ 63 := by exact_mod_cast (show stage ≤ 63 by omega)
    unfold ResidualMlpRanges.inputCeiling
    push_cast
    norm_num
    linarith
  have mixer := AttentionMix.ranges b.inputNorm b.mixer parameters.mixer primitive.mixer x
    (fun i => ⟨(hx i).1, (hx i).2.trans hcap⟩) angle ha steps supported cache hc.keys hc.values
  let suffix := Mlp.checked b.suffix parameters.suffix primitive.suffix stage hs x (b.mixed x angle cache) hx mixer.output
  exact ⟨⟨fun i => (hx i).1, fun i => (parameters.mixer.normalization i).1, mixer.normalization, mixer.finite, suffix.finite⟩,
    suffix.addition, suffix.output, ⟨mixer.keys, mixer.values⟩⟩

theorem next_input (b : Layer) (parameters : Parameters b) (primitive : Primitives b)
    (stage : Nat) (hs : stage < 64) (x : Fin 5120 → BF) (hx : ResidualMlpRanges.InputBound stage x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (cache : Cache BF steps) (hc : CacheBound cache) (supported : steps+1 ≤ 262144) :
    ResidualMlpRanges.InputBound (stage+1) (b.forward x angle cache) := by
  let h := checked b parameters primitive stage hs x hx angle ha cache hc supported
  intro i
  refine ⟨ElementwiseAdd.forward_finite _ _ h.addition i, (h.output i).trans ?_⟩
  unfold ResidualMlpRanges.inputCeiling
  push_cast
  norm_num
  linarith


end AttentionResidual

end Inference.Models.Qwen.ReachedStageRanges
