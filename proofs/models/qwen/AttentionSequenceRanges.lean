import models.qwen.AttentionInitialRanges
import models.qwen.AttentionSequenceHeadsRanges
import kernels.attention.SdpaSequenceRanges

namespace Inference.Models.Qwen.AttentionSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics Attention Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

abbrev Parameters := AttentionInitialRanges.Parameters

structure Primitives (norm : Blocks.Norm) (layer : Layer) extends AttentionInitialRanges.Primitives norm layer where
  angleDomain : AttentionSequenceHeadsRanges.AngleDomain layer.preparation
  attentionDivision : DivisionDirectedBounds.Contract layer.attention.normalization.divide

structure Result (norm : Blocks.Norm) (layer : Layer) (x : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : Cache BF steps) : Prop where
  normalization : norm.Finite x
  finite : layer.Finite (norm.forward x) angle cache
  output : ∀ i, Model.isFinite (layer.forward (norm.forward x) angle cache i) = true ∧
    |Model.toReal (layer.forward (norm.forward x) angle cache i)| ≤ (2 : ℝ)^(44 : Nat)
  keys : ∀ h t i, Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).keys h t i) = true ∧
    |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).keys h t i)| ≤ 1024
  values : ∀ h t i, Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).values h t i) = true ∧
    |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).values h t i)| ≤ (2 : ℝ)^(23 : Nat)

theorem ranges (norm : Blocks.Norm) (layer : Layer) (parameters : Parameters norm layer)
    (primitive : Primitives norm layer) (x : Fin 5120 → BF)
    (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (steps : Nat) (bound : steps+1 ≤ 262144) (cache : Cache BF steps)
    (cacheKeys : ∀ h t i, Model.isFinite (cache.keys h t i) = true ∧ |Model.toReal (cache.keys h t i)| ≤ 1024)
    (cacheValues : ∀ h t i, Model.isFinite (cache.values h t i) = true ∧
      |Model.toReal (cache.values h t i)| ≤ (2 : ℝ)^(23 : Nat)) : Result norm layer x angle cache := by
  have proj := AttentionInputRanges.projections norm layer.projections parameters.projections primitive.projections
    primitive.normalization primitive.root parameters.normalization x hx
  have heads := AttentionSequenceHeadsRanges.ranges layer.preparation parameters.heads primitive.heads primitive.angleDomain
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

end Inference.Models.Qwen.AttentionSequenceRanges
