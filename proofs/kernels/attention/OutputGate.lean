import kernels.trellis.GateUpSplitTail
import kernels.trellis.SwiGLUStability

namespace Inference.Kernels.Attention.OutputGate
open Contracts.Mlx.BFloat16Arithmetic
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Trellis
abbrev BF := Value

-- MLX unary_ops.h Sigmoid uses BF16 abs/exp, 1+exp, reciprocal and
-- subtraction. Qwen then multiplies the BF16 attention output by that BF16
-- sigmoid. There is no additional multiplication by the gate itself.
structure Platform where
  expAbs : BF → BF
  expError : BF → ℝ
  exponential : GateUpSplitTail.ExpAbsContract expAbs expError

def Valid (p : Platform) (gate : BF) : Prop :=
  GateUpSplitTail.SigmoidFinite p.expAbs gate ∨ p.expAbs gate = Model.posInf FloatFormat.bfloat16
def sigmoid (p : Platform) (gate : BF) : BF := GateUpSplitTail.sigmoidValue p.expAbs gate
def forward (p : Platform) (attention gate : BF) : BF := mul attention (sigmoid p gate)
noncomputable def target (attention gate : ℝ) : ℝ := attention * GateUpTail.sigmoid gate
noncomputable def sigmoidBudget (p : Platform) (gate : BF) : ℝ :=
  if Model.isFinite (p.expAbs gate) then GateUpSplitTail.sigmoidBudget p.expAbs p.expError gate
  else 1/(1+Real.exp (|Model.toReal gate|))

theorem sigmoid_finite (p : Platform) (gate : BF) (hv : Valid p gate) : Model.isFinite (sigmoid p gate) = true := by
  rcases hv with hf | hi
  · exact GateUpSplitTail.sigmoid_finite p.expAbs p.expError p.exponential gate hf
  · unfold sigmoid
    rw [GateUpSplitTail.sigmoid_of_exp_inf _ _ hi]
    split
    · decide
    · exact finite_one

theorem sigmoid_error (p : Platform) (gate : BF) (hg : Model.isFinite gate = true) (hv : Valid p gate) :
    |Model.toReal (sigmoid p gate) - GateUpTail.sigmoid (Model.toReal gate)| ≤ sigmoidBudget p gate := by
  rcases hv with hf | hi
  · simpa only [sigmoid, sigmoidBudget, hf.hExp, Bool.true_eq, ite_true] using
      GateUpSplitTail.sigmoid_error p.expAbs p.expError p.exponential gate hf
  · have hn : Model.isFinite (p.expAbs gate) = false := by rw [hi]; decide
    simpa only [sigmoid, sigmoidBudget, hn, Bool.false_eq_true, ite_false] using
      (GateUpSplitTail.sigmoid_overflow_error p.expAbs gate hg hi).le

theorem sigmoid_target_error (p : Platform) (gate : BF) (targetGate errorGate : ℝ)
    (hg : Model.isFinite gate = true) (hv : Valid p gate)
    (he : |Model.toReal gate - targetGate| ≤ errorGate) :
    |Model.toReal (sigmoid p gate) - GateUpTail.sigmoid targetGate| ≤ sigmoidBudget p gate + errorGate/4 := by
  have hl := (SwiGLUStability.sigmoid_lipschitz targetGate (Model.toReal gate)).trans
    (mul_le_mul_of_nonneg_left he (by norm_num : (0 : ℝ) ≤ 1/4))
  have hs := sigmoid_error p gate hg hv
  calc
    _ = |(Model.toReal (sigmoid p gate) - GateUpTail.sigmoid (Model.toReal gate)) +
      (GateUpTail.sigmoid (Model.toReal gate) - GateUpTail.sigmoid targetGate)| := by congr 1; ring
    _ ≤ _ := by have h := (abs_add_le _ _).trans (add_le_add hs hl); linarith

def ProductFinite (p : Platform) (attention gate : BF) : Prop :=
  Model.isFinite (Model.mul (flush attention) (flush (sigmoid p gate))) = true
noncomputable def budget (p : Platform) (attention gate : BF) (targetAttention errorAttention errorGate : ℝ) : ℝ :=
  mulBudget attention (sigmoid p gate) + errorAttention * |Model.toReal (sigmoid p gate)| +
    |targetAttention| * (sigmoidBudget p gate + errorGate/4)

theorem forward_error (p : Platform) (attention gate : BF) (targetAttention targetGate errorAttention errorGate : ℝ)
    (ha : Model.isFinite attention = true) (hg : Model.isFinite gate = true)
    (hv : Valid p gate) (hf : ProductFinite p attention gate)
    (ea : |Model.toReal attention - targetAttention| ≤ errorAttention)
    (eg : |Model.toReal gate - targetGate| ≤ errorGate) :
    |Model.toReal (forward p attention gate) - target targetAttention targetGate| ≤
      budget p attention gate targetAttention errorAttention errorGate := by
  have hm := mul_error attention (sigmoid p gate) ha (sigmoid_finite p gate hv) hf
  have he := mul_le_mul_of_nonneg_right ea (abs_nonneg (Model.toReal (sigmoid p gate)))
  have hs := mul_le_mul_of_nonneg_left (sigmoid_target_error p gate targetGate errorGate hg hv eg) (abs_nonneg targetAttention)
  rw [← abs_mul] at he hs
  unfold budget target
  calc
    _ = |((Model.toReal (forward p attention gate) - Model.toReal attention * Model.toReal (sigmoid p gate)) +
      (Model.toReal attention - targetAttention) * Model.toReal (sigmoid p gate)) +
      targetAttention * (Model.toReal (sigmoid p gate) - GateUpTail.sigmoid targetGate)| := by congr 1; ring
    _ ≤ _ := (abs_add_le _ _).trans (add_le_add ((abs_add_le _ _).trans (add_le_add hm he)) hs)

theorem forward_finite (p : Platform) (attention gate : BF) (hf : ProductFinite p attention gate) :
    Model.isFinite (forward p attention gate) = true := finite_flush _ hf

end Inference.Kernels.Attention.OutputGate
