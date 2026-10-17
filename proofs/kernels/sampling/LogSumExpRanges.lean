import kernels.sampling.LogSumExpLoopRanges
import kernels.sampling.LogSumExpMergeRanges
import contracts.mlx.BFloat16ConversionBounds
import contracts.mlx.BFloat16DyadicBounds

namespace Inference.Kernels.Sampling.LogSumExpRanges
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Logical source model for the 1024-thread looped BF16 kernel. Native
-- pipeline size, SIMD execution, barriers, memory and compiler attachment
-- remain explicit correspondence obligations. Reduction coverage is checked.
structure Platform where
  scalar : Attention.SdpaUpdate.Platform
  maximumTree : Reduction.Tree 32
  maximumCoverage : (Reduction.leaves maximumTree).Perm (List.finRange 32)
  sumTree : Reduction.Tree 32
  sumCoverage : (Reduction.leaves sumTree).Perm (List.finRange 32)
  log : Float32 → Float32

structure Primitives (p : Platform) : Prop where
  exp : Attention.SdpaExponentRanges.Primitive p.scalar
  padding : LogSumExpExponentRanges.PaddingPrimitive p.scalar
  logarithm : ∀ x, x.isFinite = true → 1 ≤ real x → real x ≤ (2 : ℝ)^(18 : Nat) →
    (p.log x).isFinite = true ∧ |real (p.log x)| ≤ 32

def groupState (p : Platform) (input : Fin 248320 → Float32) (group : Fin 32) : LogSumExpBlockRanges.State :=
  LogSumExpMergeRanges.merge p.scalar
    (fun lane => LogSumExpLoopRanges.localState p.scalar input (LogSumExpLayout.threadAt group lane))
    p.maximumTree p.sumTree
def totalState (p : Platform) (input : Fin 248320 → Float32) : LogSumExpBlockRanges.State :=
  LogSumExpMergeRanges.merge p.scalar (groupState p input) p.maximumTree p.sumTree
def finish (p : Platform) (state : LogSumExpBlockRanges.State) : BF :=
  if Model.isInf (model state.maximum) then BFloat16.narrow state.maximum
  else BFloat16.narrow (FlushToZero.add (p.log state.normalizer) state.maximum)
def source (p : Platform) (input : Fin 248320 → Float32) : BF := finish p (totalState p input)
def value (p : Platform) (logits : Fin 248320 → BF) : BF := source p (fun i => BFloat16.widen (logits i))

structure Trace (p : Platform) (input : Fin 248320 → Float32) : Prop where
  loops : ∀ thread, LogSumExpLoopRanges.Trace p.scalar input thread 61 (by decide)
  groups : ∀ group, LogSumExpMergeRanges.Trace p.scalar
    (fun lane => LogSumExpLoopRanges.localState p.scalar input (LogSumExpLayout.threadAt group lane))
    p.maximumTree p.sumTree
  total : LogSumExpMergeRanges.Trace p.scalar (groupState p input) p.maximumTree p.sumTree
  logarithm : (p.log (totalState p input).normalizer).isFinite = true
  addition : (FlushToZero.flush (p.log (totalState p input).normalizer) +
    FlushToZero.flush (totalState p input).maximum).isFinite = true

theorem ranges (p : Platform) (primitive : Primitives p) (input : Fin 248320 → Float32)
    (hi : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Trace p input ∧ LogSumExpBlockRanges.Bounds (totalState p input) 249856 ∧
      Model.isFinite (source p input) = true ∧ |Model.toReal (source p input)| ≤ (2 : ℝ)^(24 : Nat) := by
  have perThread thread := LogSumExpLoopRanges.local_ranges p.scalar primitive.exp primitive.padding input hi thread
  have group group := LogSumExpMergeRanges.ranges p.scalar primitive.exp
    (fun lane => LogSumExpLoopRanges.localState p.scalar input (LogSumExpLayout.threadAt group lane))
    244 (by decide) (fun lane => (perThread (LogSumExpLayout.threadAt group lane)).2)
    p.maximumTree p.sumTree p.maximumCoverage p.sumCoverage
  have total := LogSumExpMergeRanges.ranges p.scalar primitive.exp (groupState p input) 7808 (by decide)
    (fun i => (group i).2) p.maximumTree p.sumTree p.maximumCoverage p.sumCoverage
  have hlog := primitive.logarithm (totalState p input).normalizer total.2.normalizerFinite total.2.lower
    (total.2.upper.trans (by norm_num))
  have cap := DyadicBounds.ceiling_range 1 24 (by decide) (by decide) (by decide)
  have hadd := Float32Bounds.add_range (p.log (totalState p input).normalizer) (totalState p input).maximum
    (DyadicBounds.ceiling 1 24) hlog.1 total.2.maximumFinite cap.1 (by
      rw [cap.2]
      have hb := add_le_add hlog.2 total.2.maximumBound
      norm_num at hb ⊢
      exact hb.trans (by norm_num))
  have bcap := BFloat16DyadicBounds.ceiling_range 1 24 (by decide) (by decide) (by decide)
  have narrow := BFloat16ConversionBounds.narrow_range
    (FlushToZero.add (p.log (totalState p input).normalizer) (totalState p input).maximum)
    (BFloat16DyadicBounds.ceiling 1 24) (FlushToZero.finite_flush _ hadd.1) bcap.1
    (hadd.2.trans_eq (cap.2.trans bcap.2.symm))
  have hn : Model.isInf (model (totalState p input).maximum) = false :=
    Model.isInf_eq_false_of_isFinite_eq_true _ (by rw [finite_model]; exact total.2.maximumFinite)
  refine ⟨⟨fun t => (perThread t).1, fun g => (group g).1, total.1, hlog.1, hadd.1⟩, total.2, ?_⟩
  simpa only [source, finish, hn, Bool.false_eq_true, ite_false, bcap.2, Nat.cast_one, one_mul, zpow_ofNat] using narrow

theorem bf16_ranges (p : Platform) (primitive : Primitives p) (logits : Fin 248320 → BF)
    (hi : ∀ i, Model.isFinite (logits i) = true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    Trace p (fun i => BFloat16.widen (logits i)) ∧
      Model.isFinite (value p logits) = true ∧ |Model.toReal (value p logits)| ≤ (2 : ℝ)^(24 : Nat) := by
  have h := ranges p primitive (fun i => BFloat16.widen (logits i)) (fun i =>
    ⟨BFloat16.widen_finite _ (hi i).1, by rw [BFloat16.widen_real _ (hi i).1]; exact (hi i).2⟩)
  exact ⟨h.1, h.2.2⟩

end Inference.Kernels.Sampling.LogSumExpRanges
