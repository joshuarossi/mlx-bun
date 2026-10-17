import models.qwen.DecodeChainSequenceRanges

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention Qwen38TrellisM1Max
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (g : Graph) : Prop where
  delta : ∀ i, ResidualDeltaDecodeRanges.Parameters (g.delta i)
  attention : ∀ i, ResidualAttentionSequenceRanges.Parameters (g.attention i)
  normalization : ∀ i, Model.isFinite (g.finalNorm.weight i) = true ∧ |Model.toReal (g.finalNorm.weight i)| ≤ 1
  output : NormalizedAffineProjection.Parameters g.output

structure Primitives (g : Graph) where
  delta : ∀ i, ResidualDeltaDecodeRanges.Primitives (g.delta i)
  attention : ∀ i, ResidualAttentionSequenceRanges.Primitives (g.attention i)
  normalization : DivisionDirectedBounds.Contract g.finalNorm.platform.divide
  root : RsqrtBounds.Envelope g.finalNorm.platform.rsqrt
  output : NormalizedAffineProjection.DivisionContract g.output

theorem chainParameters (g : Graph) (parameters : Parameters g) : DecodeChainSequenceRanges.Parameters g.stages := by
  simp only [Graph.stages, DecodeChainSequenceRanges.Parameters, DecodeStageSequenceRanges.Parameters]
  repeat' apply And.intro
  all_goals first | exact parameters.delta _ | exact parameters.attention _ | trivial

def chainPrimitives (g : Graph) (primitive : Primitives g) : DecodeChainSequenceRanges.Primitives g.stages := by
  simp only [Graph.stages, DecodeChainSequenceRanges.Primitives, DecodeStageSequenceRanges.Primitives]
  repeat' apply Prod.mk
  all_goals first | exact primitive.delta _ | exact primitive.attention _ | exact PUnit.unit

structure Result (g : Graph) (cache : g.Cache time) (x : Row BF) (angle : RopeAngles.Inputs) where
  finite : g.Ranges cache x angle
  output : ∀ i, Model.isFinite (g.forward cache x angle i) = true ∧
    |Model.toReal (g.forward cache x angle i)| ≤ (2 : ℝ)^(23 : Nat)
  cacheBound : DecodeChainSequenceRanges.CachesBound g.stages (DecodeChain.run g.stages cache x angle).2

noncomputable def checked (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (cache : g.Cache time) (hc : DecodeChainSequenceRanges.CachesBound g.stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    Result g cache x angle := by
  let cp := chainParameters g parameters
  let pp := chainPrimitives g primitive
  have size : 0+g.stages.length ≤ 64 := by rw [g.layer_count]
  have nonempty : g.stages ≠ [] := by intro h; have hn := g.layer_count; rw [h] at hn; contradiction
  have finite := DecodeChainSequenceRanges.ranges g.stages cp pp 0 size cache hc x hx angle ha supported
  have next := DecodeChainSequenceRanges.next_input g.stages cp pp 0 size cache hc x hx angle ha supported
  have bound := DecodeChainSequenceRanges.output_bounded g.stages cp pp 0 size nonempty cache hc x hx angle ha supported
  have output := NormalizedAffineProjection.ranges g.finalNorm g.output parameters.output primitive.normalization
    primitive.root primitive.output parameters.normalization (g.hidden cache x angle) (fun i => ⟨(next i).1, bound i⟩)
  exact ⟨⟨finite, fun i => (parameters.normalization i).1, output.1, output.2.1⟩, output.2.2,
    DecodeChainSequenceRanges.next_cache g.stages cp pp 0 size cache hc x hx angle ha supported⟩

theorem run_correct (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (cache : g.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound g.stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144)
    (ct ce : g.ReferenceCache time) (hc : DecodeChain.CacheErrors g.stages cache ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (g.forward cache x angle i)-g.target ct t aim i| ≤
      g.budget cache ct ce x t e angle aim ae
        (checked g parameters primitive cache cacheBound x hx angle ha supported).finite i) ∧
    DecodeChain.CacheErrors g.stages (DecodeChain.run g.stages cache x angle).2 (DecodeChain.targetRun g.stages ct t aim).2
      (DecodeChain.budgetRun g.stages cache ct ce x t e angle aim ae
        (checked g parameters primitive cache cacheBound x hx angle ha supported).finite.chain).2 ∧
    (∀ i, Model.isFinite (g.forward cache x angle i) = true) ∧
    DecodeChain.CachesFinite g.stages (DecodeChain.run g.stages cache x angle).2 := by
  let h := checked g parameters primitive cache cacheBound x hx angle ha supported
  have chain := DecodeChainSequenceRanges.run_correct g.stages (chainParameters g parameters) (chainPrimitives g primitive)
    0 (by rw [g.layer_count]) cache cacheBound x hx angle ha supported ct ce hc t e hi aim ae he hb
  refine ⟨fun i => ?_, chain.2.1, fun i => (h.output i).1, chain.2.2.2⟩
  apply g.output.forward_error _ _ _ _ h.finite.output i
  intro j
  exact g.finalNorm.forward_error (g.hidden cache x angle) (g.targetHidden ct t aim)
    (g.hiddenBudget cache ct ce x t e angle aim ae h.finite)
    chain.1 chain.2.2.1 h.finite.finalWeight h.finite.finalNorm j

end Inference.Models.Qwen.Qwen38TrellisM1MaxSequenceRanges
