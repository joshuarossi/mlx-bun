import kernels.delta.Decay
import kernels.delta.SoftplusRanges
import contracts.mlx.NativeMultiplication

namespace Inference.Kernels.Delta.DecayRanges
open Contracts.Mlx Contracts.Mlx.Numerics Decay
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Profile where
  aLogCap : Float32
  aCap : BF
  dtCap : BF
  biasedCap : BF
  softCap : BF
  scaleCap : Float32
  argumentCap : Float32
  biasedFinite : Model.isFinite biasedCap = true
  softFinite : Model.isFinite softCap = true
  argumentFinite : argumentCap.isFinite = true
  biasedCapacity : Model.toReal aCap + Model.toReal dtCap ≤ Model.toReal biasedCap
  softCapacity : Model.toReal biasedCap + 1 ≤ Model.toReal softCap
  argumentCapacity : real scaleCap * Model.toReal softCap ≤ real argumentCap

-- Each property here concerns a single scalar exp or log1p call. All
-- composite finiteness obligations in Decay.Finite are derived below.
structure PrimitiveRanges (p : Platform) (profile : Profile) : Prop where
  softplus : SoftplusRanges.PrimitiveRanges p.expBF p.log1pBF
  scale : ∀ x, x.isFinite = true → |real x| ≤ real profile.aLogCap →
    (p.exp x).isFinite = true ∧ |real (p.exp x)| ≤ real profile.scaleCap
  nonpositive : ∀ x, x.isFinite = true → real x ≤ 0 →
    (p.exp x).isFinite = true ∧ (0 ≤ real (p.exp x) ∧ real (p.exp x) ≤ 1)

theorem ranges (p : Platform) (profile : Profile) (primitive : PrimitiveRanges p profile)
    (aLog : Float32) (a dt : BF)
    (hl : aLog.isFinite = true ∧ |real aLog| ≤ real profile.aLogCap)
    (ha : Model.isFinite a = true ∧ |Model.toReal a| ≤ Model.toReal profile.aCap)
    (hd : Model.isFinite dt = true ∧ |Model.toReal dt| ≤ Model.toReal profile.dtCap) :
    Decay.Finite p aLog a dt ∧ (0 ≤ real (value p aLog a dt) ∧ real (value p aLog a dt) ≤ 1) := by
  have hb := BFloat16Bounds.add_range a dt profile.biasedCap ha.1 hd.1 profile.biasedFinite
    ((add_le_add ha.2 hd.2).trans profile.biasedCapacity)
  have hs := SoftplusRanges.ranges p.expBF p.log1pBF primitive.softplus (biased a dt)
    profile.biasedCap profile.softCap (BFloat16Arithmetic.finite_flush _ hb.1) profile.softFinite hb.2 profile.softCapacity
  have he := primitive.scale aLog hl.1 hl.2
  have hn : |real (-p.exp aLog)| ≤ real profile.scaleCap := by
    rw [Negation.real_neg _ he.1, abs_neg]
    exact he.2
  have hw : |real (BFloat16.widen (soft p a dt))| ≤ Model.toReal profile.softCap := by
    rw [soft, BFloat16.widen_real _ hs.2.1]
    exact hs.2.2.2
  have hm := NativeMultiplication.range (-p.exp aLog) (BFloat16.widen (soft p a dt)) profile.argumentCap
    (Negation.finite_neg _ he.1) (BFloat16.widen_finite _ hs.2.1) profile.argumentFinite
    ((mul_le_mul hn hw (abs_nonneg _) ((abs_nonneg _).trans hn)).trans profile.argumentCapacity)
  have argumentFinite : (argument p aLog a dt).isFinite = true := FlushToZero.finite_flush _ hm.1
  have nonpositive : real (argument p aLog a dt) ≤ 0 := by
    apply FlushToZero.mul_nonpositive _ _ _ _ hm.1
    · rw [Negation.real_neg _ he.1]
      exact neg_nonpos.mpr (p.exponential.nonnegative aLog hl.1 he.1)
    · rw [soft, BFloat16.widen_real _ hs.2.1]
      exact hs.2.2.1
  have ho := primitive.nonpositive _ argumentFinite nonpositive
  exact ⟨⟨hl.1, ha.1, hd.1, hb.1, hs.1, he.1, hm.1, ho.1⟩, ho.2⟩

theorem accuracy (p : Platform) (profile : Profile) (primitive : PrimitiveRanges p profile)
    (aLog : Float32) (a dt : BF)
    (hl : aLog.isFinite = true ∧ |real aLog| ≤ real profile.aLogCap)
    (ha : Model.isFinite a = true ∧ |Model.toReal a| ≤ Model.toReal profile.aCap)
    (hd : Model.isFinite dt = true ∧ |Model.toReal dt| ≤ Model.toReal profile.dtCap) :
    |real (value p aLog a dt) - Gates.decay (real aLog) (Model.toReal a + Model.toReal dt)| ≤ budget p aLog a dt :=
  value_error p aLog a dt (ranges p profile primitive aLog a dt hl ha hd).1

end Inference.Kernels.Delta.DecayRanges
