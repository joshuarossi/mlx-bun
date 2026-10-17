import kernels.attention.OutputGate
import kernels.trellis.SigmoidRanges

namespace Inference.Kernels.Attention.OutputGateRanges
open Contracts.Mlx OutputGate
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem ranges (p : Platform) (primitive : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (attention gate cap : BF) (ha : Model.isFinite attention = true) (hg : Model.isFinite gate = true)
    (hc : Model.isFinite cap = true) (bound : |Model.toReal attention| ≤ Model.toReal cap) :
    Valid p gate ∧ ProductFinite p attention gate ∧ Model.isFinite (forward p attention gate) = true ∧
      |Model.toReal (forward p attention gate)| ≤ Model.toReal cap := by
  have hs := Trellis.SigmoidRanges.ranges p.expAbs p.expError p.exponential primitive gate hg
  have hp := BFloat16Bounds.mul_range attention (sigmoid p gate) cap ha hs.2.1 hc (by
    change |Model.toReal attention| * |Model.toReal (Trellis.GateUpSplitTail.sigmoidValue p.expAbs gate)| ≤ _
    rw [abs_of_nonneg hs.2.2.1]
    exact (mul_le_of_le_one_right (abs_nonneg _) hs.2.2.2).trans bound)
  exact ⟨hs.1, hp.1, BFloat16Arithmetic.finite_flush _ hp.1, hp.2⟩

theorem accuracy (p : Platform) (primitive : Trellis.SigmoidRanges.ExponentialRange p.expAbs)
    (attention gate cap : BF) (ha : Model.isFinite attention = true) (hg : Model.isFinite gate = true)
    (hc : Model.isFinite cap = true) (bound : |Model.toReal attention| ≤ Model.toReal cap)
    (targetAttention targetGate errorAttention errorGate : ℝ)
    (ea : |Model.toReal attention - targetAttention| ≤ errorAttention)
    (eg : |Model.toReal gate - targetGate| ≤ errorGate) :
    |Model.toReal (forward p attention gate) - target targetAttention targetGate| ≤
      budget p attention gate targetAttention errorAttention errorGate := by
  have h := ranges p primitive attention gate cap ha hg hc bound
  exact forward_error p attention gate targetAttention targetGate errorAttention errorGate ha hg h.1 h.2.1 ea eg

end Inference.Kernels.Attention.OutputGateRanges
