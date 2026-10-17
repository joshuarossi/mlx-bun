import models.qwen.DeltaInputRanges
import kernels.delta.DecayRanges
import kernels.trellis.SigmoidRanges

namespace Inference.Models.Qwen.DeltaGateRanges
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Delta DeltaNet
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

private theorem bf (e : Int) (lo : -133 ≤ e) (hi : e ≤ 119) :
    Model.isFinite (BFloat16DyadicBounds.ceiling 1 e) = true ∧ Model.toReal (BFloat16DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using BFloat16DyadicBounds.ceiling_range 1 e (by decide) lo hi
private theorem fp (e : Int) (lo : -149 ≤ e) (hi : e ≤ 100) :
    (DyadicBounds.ceiling 1 e).isFinite = true ∧ real (DyadicBounds.ceiling 1 e) = (2 : ℝ)^e := by
  simpa only [Nat.cast_one, one_mul] using DyadicBounds.ceiling_range 1 e (by decide) lo hi

def profile : DecayRanges.Profile where
  aLogCap := DyadicBounds.ceiling 1 3
  aCap := BFloat16DyadicBounds.ceiling 1 34
  dtCap := BFloat16DyadicBounds.ceiling 1 5
  biasedCap := BFloat16DyadicBounds.ceiling 1 35
  softCap := BFloat16DyadicBounds.ceiling 1 36
  scaleCap := DyadicBounds.ceiling 1 12
  argumentCap := DyadicBounds.ceiling 1 48
  biasedFinite := (bf 35 (by decide) (by decide)).1
  softFinite := (bf 36 (by decide) (by decide)).1
  argumentFinite := (fp 48 (by decide) (by decide)).1
  biasedCapacity := by rw [(bf 34 (by decide) (by decide)).2, (bf 5 (by decide) (by decide)).2, (bf 35 (by decide) (by decide)).2]; norm_num
  softCapacity := by rw [(bf 35 (by decide) (by decide)).2, (bf 36 (by decide) (by decide)).2]; norm_num
  argumentCapacity := by rw [(fp 12 (by decide) (by decide)).2, (bf 36 (by decide) (by decide)).2, (fp 48 (by decide) (by decide)).2]; norm_num

structure Parameters (layer : Layer) : Prop where
  aLog : ∀ h, Model.isFinite (layer.aLog h) = true ∧ |Model.toReal (layer.aLog h)| ≤ 8
  dtBias : ∀ h, Model.isFinite (layer.dtBias h) = true ∧ |Model.toReal (layer.dtBias h)| ≤ 32

structure Ranges (layer : Layer) (input : Nat → Fin 5120 → BF) (t : Nat) : Prop where
  finite : State.Ssm.GateFinite layer.recurrence (gates layer input) t
  decay : ∀ h, 0 ≤ real (Decay.value layer.recurrence.gates.decay (BFloat16.widen (layer.aLog h))
    (layer.a.forward (input t) h) (layer.dtBias h)) ∧
      real (Decay.value layer.recurrence.gates.decay (BFloat16.widen (layer.aLog h))
        (layer.a.forward (input t) h) (layer.dtBias h)) ≤ 1
  beta : ∀ h, 0 ≤ Model.toReal (Kernels.Trellis.GateUpSplitTail.sigmoidValue layer.recurrence.gates.expAbs
    (layer.b.forward (input t) h)) ∧
      Model.toReal (Kernels.Trellis.GateUpSplitTail.sigmoidValue layer.recurrence.gates.expAbs
        (layer.b.forward (input t) h)) ≤ 1

theorem ranges (layer : Layer) (parameters : Parameters layer)
    (decay : DecayRanges.PrimitiveRanges layer.recurrence.gates.decay profile)
    (beta : Kernels.Trellis.SigmoidRanges.ExponentialRange layer.recurrence.gates.expAbs)
    (input : Nat → Fin 5120 → BF) (projection : DeltaInputRanges.ProjectionRanges layer input) (t : Nat) :
    Ranges layer input t := by
  have haLog (h : Fin 48) : (BFloat16.widen (layer.aLog h)).isFinite = true ∧
      |real (BFloat16.widen (layer.aLog h))| ≤ real profile.aLogCap := by
    refine ⟨BFloat16.widen_finite _ (parameters.aLog h).1, ?_⟩
    rw [BFloat16.widen_real _ (parameters.aLog h).1, profile, (fp 3 (by decide) (by decide)).2]
    norm_num
    exact (parameters.aLog h).2
  have ha (h : Fin 48) : Model.isFinite (layer.a.forward (input t) h) = true ∧
      |Model.toReal (layer.a.forward (input t) h)| ≤ Model.toReal profile.aCap := by
    refine ⟨layer.a.forward_finite _ (projection.finite.a t) h, ?_⟩
    rw [profile, (bf 34 (by decide) (by decide)).2]
    exact (projection.a t h).trans (by norm_num)
  have hdt (h : Fin 48) : Model.isFinite (layer.dtBias h) = true ∧
      |Model.toReal (layer.dtBias h)| ≤ Model.toReal profile.dtCap := by
    norm_num only [profile, (bf 5 (by decide) (by decide)).2, zpow_ofNat]
    exact parameters.dtBias h
  have hd h := DecayRanges.ranges layer.recurrence.gates.decay profile decay (BFloat16.widen (layer.aLog h))
    (layer.a.forward (input t) h) (layer.dtBias h) (haLog h) (ha h) (hdt h)
  have hb h := Kernels.Trellis.SigmoidRanges.ranges layer.recurrence.gates.expAbs layer.recurrence.gates.expAbsError
    layer.recurrence.gates.exponential beta (layer.b.forward (input t) h)
    (layer.b.forward_finite _ (projection.finite.b t) h)
  exact ⟨⟨fun h => (parameters.aLog h).1, fun h => layer.b.forward_finite _ (projection.finite.b t) h,
    fun h => (hd h).1, fun h => (hb h).1⟩, fun h => (hd h).2, fun h => (hb h).2.2⟩

end Inference.Models.Qwen.DeltaGateRanges
