import models.qwen.Attention
import models.qwen.AttentionInitialHeadsRanges
import models.qwen.DeltaOutputRanges
import kernels.attention.SdpaInitialRanges
import kernels.attention.OutputGateRanges

namespace Inference.Models.Qwen.AttentionInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics Attention Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (norm : Blocks.Norm) (layer : Layer) : Prop where
  normalization : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1
  projections : AttentionInputRanges.Parameters layer.projections
  heads : AttentionInitialHeadsRanges.Parameters layer.preparation
  output : DeltaOutputRanges.Parameters layer.output

structure Primitives (norm : Blocks.Norm) (layer : Layer) where
  normalization : DivisionDirectedBounds.Contract norm.platform.divide
  root : RsqrtBounds.Envelope norm.platform.rsqrt
  projections : AttentionInputRanges.Divisions layer.projections
  heads : AttentionInitialHeadsRanges.Primitives layer.preparation
  attention : SdpaInitialRanges.Primitives layer.attention
  gate : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.gate.expAbs
  output : DeltaOutputRanges.Divisions layer.output

structure Result (norm : Blocks.Norm) (layer : Layer) (x : Fin 5120 → BF)
    (angle : RopeAngles.Inputs) (cache : Cache BF 0) : Prop where
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
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (cache : Cache BF 0) : Result norm layer x angle cache := by
  have proj := AttentionInputRanges.projections norm layer.projections parameters.projections primitive.projections
    primitive.normalization primitive.root parameters.normalization x hx
  have heads := AttentionInitialHeadsRanges.ranges layer.preparation parameters.heads primitive.heads
    layer.projections (norm.forward x) proj.2 angle ha position
  have keys h t i : Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).keys h t i) = true ∧
      |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).keys h t i)| ≤ 1024 := by
    simpa only [Layer.cacheAfter, Layer.heads, State.Kv.append, State.Kv.appendRows, Nat.not_lt_zero, dite_false] using
      And.intro (heads.finite.key h i) (heads.key h i)
  have values h t i : Model.isFinite ((layer.cacheAfter (norm.forward x) angle cache).values h t i) = true ∧
      |Model.toReal ((layer.cacheAfter (norm.forward x) angle cache).values h t i)| ≤ (2 : ℝ)^(23 : Nat) := by
    simpa only [Layer.cacheAfter, Layer.heads, State.Kv.append, State.Kv.appendRows, Nat.not_lt_zero, dite_false] using
      And.intro (heads.finite.value h i) (heads.value h i)
  have read h := SdpaInitialRanges.ranges layer.attention primitive.attention ((layer.heads (norm.forward x) angle).query h)
    ((layer.cacheAfter (norm.forward x) angle cache).keys (SdpaScore.kvHead h))
    ((layer.cacheAfter (norm.forward x) angle cache).values (SdpaScore.kvHead h))
    (fun i => ⟨heads.finite.query h i, heads.query h i⟩) (keys (SdpaScore.kvHead h)) (values (SdpaScore.kvHead h))
  have readExecution h i : layer.read (norm.forward x) angle cache h i =
      SdpaVector.forward layer.attention ((layer.heads (norm.forward x) angle).query h)
        ((layer.cacheAfter (norm.forward x) angle cache).keys (SdpaScore.kvHead h))
        ((layer.cacheAfter (norm.forward x) angle cache).values (SdpaScore.kvHead h)) i := by
    unfold Layer.read
    rw [SdpaDispatched.forward_single]
  have gated h i := OutputGateRanges.ranges layer.gate primitive.gate (layer.read (norm.forward x) angle cache h i)
    ((layer.heads (norm.forward x) angle).gate h i) SdpaInitialRanges.outputCap
    (by rw [readExecution]; exact SdpaVector.forward_finite _ _ _ _ (read h).1 i) (heads.finite.gate h i) SdpaInitialRanges.outputCap_range.1
    (by rw [SdpaInitialRanges.outputCap_range.2, readExecution]; exact (read h).2 i)
  have output := DeltaOutputRanges.project layer.output parameters.output primitive.output (layer.merged (norm.forward x) angle cache)
    (fun i => ⟨(gated (headIndex i) (coordinate i)).2.2.1, by
      have h := (gated (headIndex i) (coordinate i)).2.2.2
      rw [SdpaInitialRanges.outputCap_range.2] at h
      exact h.trans (by norm_num)⟩)
  exact ⟨proj.1, ⟨proj.2.finite, heads.preparation,
    fun h => SdpaDispatched.finite_single layer.attention layer.mergeContracted layer.architectureSuffix _ _ _ (read h).1,
    fun h i => (gated h i).1, fun h i => (gated h i).2.1, output.1⟩, output.2, keys, values⟩

end Inference.Models.Qwen.AttentionInitialRanges
