import models.qwen.DecodeChainInitialRanges

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention Qwen38TrellisM1Max
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (g : Graph) : Prop where
  delta : ∀ i, ResidualDeltaInitialRanges.Parameters (g.delta i)
  attention : ∀ i, ResidualAttentionInitialRanges.Parameters (g.attention i)
  normalization : ∀ i, Model.isFinite (g.finalNorm.weight i) = true ∧ |Model.toReal (g.finalNorm.weight i)| ≤ 1
  output : NormalizedAffineProjection.Parameters g.output

structure Primitives (g : Graph) where
  delta : ∀ i, ResidualDeltaInitialRanges.Primitives (g.delta i)
  attention : ∀ i, ResidualAttentionInitialRanges.Primitives (g.attention i)
  normalization : DivisionDirectedBounds.Contract g.finalNorm.platform.divide
  root : RsqrtBounds.Envelope g.finalNorm.platform.rsqrt
  output : NormalizedAffineProjection.DivisionContract g.output

theorem chainParameters (g : Graph) (parameters : Parameters g) : DecodeChainInitialRanges.Parameters g.stages := by
  simp only [Graph.stages, DecodeChainInitialRanges.Parameters, DecodeStageInitialRanges.Parameters]
  repeat' apply And.intro
  all_goals first | exact parameters.delta _ | exact parameters.attention _ | trivial

def chainPrimitives (g : Graph) (primitive : Primitives g) : DecodeChainInitialRanges.Primitives g.stages := by
  simp only [Graph.stages, DecodeChainInitialRanges.Primitives, DecodeStageInitialRanges.Primitives]
  repeat' apply Prod.mk
  all_goals first | exact primitive.delta _ | exact primitive.attention _ | exact PUnit.unit

structure Result (g : Graph) (x : Row BF) (angle : RopeAngles.Inputs) where
  finite : g.Ranges (InitialState.caches g.stages) x angle
  output : ∀ i, Model.isFinite (g.forward (InitialState.caches g.stages) x angle i) = true ∧
    |Model.toReal (g.forward (InitialState.caches g.stages) x angle i)| ≤ (2 : ℝ)^(23 : Nat)

noncomputable def checked (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    Result g x angle := by
  let cp := chainParameters g parameters
  let pp := chainPrimitives g primitive
  have size : 0+g.stages.length ≤ 64 := by rw [g.layer_count]
  have nonempty : g.stages ≠ [] := by intro h; have hn := g.layer_count; rw [h] at hn; contradiction
  have finite := DecodeChainInitialRanges.ranges g.stages cp pp 0 size x hx angle ha position
  have next := DecodeChainInitialRanges.next_input g.stages cp pp 0 size x hx angle ha position
  have bound := DecodeChainInitialRanges.output_bounded g.stages cp pp 0 size nonempty x hx angle ha position
  have output := NormalizedAffineProjection.ranges g.finalNorm g.output parameters.output primitive.normalization
    primitive.root primitive.output parameters.normalization (g.hidden (InitialState.caches g.stages) x angle)
    (fun i => ⟨(next i).1, bound i⟩)
  exact ⟨⟨finite, fun i => (parameters.normalization i).1, output.1, output.2.1⟩, output.2.2⟩

theorem run_correct (g : Graph) (parameters : Parameters g) (primitive : Primitives g)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (ct ce : g.ReferenceCache 0) (hc : DecodeChain.CacheErrors g.stages (InitialState.caches g.stages) ct ce)
    (t e : Row ℝ) (hi : ∀ i, |Model.toReal (x i)-t i| ≤ e i)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal (g.forward (InitialState.caches g.stages) x angle i)-g.target ct t aim i| ≤
      g.budget (InitialState.caches g.stages) ct ce x t e angle aim ae (checked g parameters primitive x hx angle ha position).finite i) ∧
    DecodeChain.CacheErrors g.stages (DecodeChain.run g.stages (InitialState.caches g.stages) x angle).2
      (DecodeChain.targetRun g.stages ct t aim).2
      (DecodeChain.budgetRun g.stages (InitialState.caches g.stages) ct ce x t e angle aim ae
        (checked g parameters primitive x hx angle ha position).finite.chain).2 ∧
    (∀ i, Model.isFinite (g.forward (InitialState.caches g.stages) x angle i) = true) ∧
    DecodeChain.CachesFinite g.stages (DecodeChain.run g.stages (InitialState.caches g.stages) x angle).2 := by
  let h := checked g parameters primitive x hx angle ha position
  have chain := DecodeChainInitialRanges.run_correct g.stages (chainParameters g parameters) (chainPrimitives g primitive)
    0 (by rw [g.layer_count]) x hx angle ha position ct ce hc t e hi aim ae he hb
  refine ⟨fun i => ?_, chain.2.1, fun i => (h.output i).1, chain.2.2.2⟩
  apply g.output.forward_error _ _ _ _ h.finite.output i
  intro j
  exact g.finalNorm.forward_error (g.hidden (InitialState.caches g.stages) x angle) (g.targetHidden ct t aim)
    (g.hiddenBudget (InitialState.caches g.stages) ct ce x t e angle aim ae h.finite)
    chain.1 chain.2.2.1 h.finite.finalWeight h.finite.finalNorm j

end Inference.Models.Qwen.Qwen38TrellisM1MaxInitialRanges
