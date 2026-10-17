import models.qwen.Blocks
import models.qwen.TrellisMlp
import kernels.ResidualRmsNorm

namespace Inference.Models.Qwen.ResidualBlocks
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Layers WrittenLayers
abbrev BF := BFloat16Arithmetic.Value

-- QwenResidualDeltaLayer and QwenResidualAttentionLayer both use this exact
-- suffix: float32 residual add, bf16 store, RMS normalization, Trellis MLP,
-- and a final bf16 residual add. The mixer is composed separately.
structure Mlp where
  norm : Blocks.Norm
  mlp : GateDown

def residual (x update : Fin 5120 → BF) : Fin 5120 → BF :=
  fun i => Kernels.ResidualRmsNorm.residual (x i) (update i)

def Mlp.normalized (b : Mlp) (x update : Fin 5120 → BF) : Fin 5120 → BF :=
  Kernels.ResidualRmsNorm.normalized b.norm.platform x update b.norm.weight Blocks.width Blocks.eps b.norm.scratch b.norm.base

def Mlp.inputBits (b : Mlp) (x update : Fin 5120 → BF) : Nat → BitVec 16 := Blocks.packed (b.normalized x update)
def Mlp.branch (b : Mlp) (x update : Fin 5120 → BF) : Fin 5120 → BF := b.mlp.forward (b.inputBits x update)
def Mlp.forward (b : Mlp) (x update : Fin 5120 → BF) : Fin 5120 → BF :=
  ElementwiseAdd.forward (residual x update) (b.branch x update)

noncomputable def residualTarget (x update : Fin 5120 → ℝ) : Fin 5120 → ℝ := fun i => x i + update i
noncomputable def Mlp.normalizedTarget (b : Mlp) (x update : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  b.norm.target (residualTarget x update)
noncomputable def Mlp.branchTarget (b : Mlp) (x update : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  b.mlp.target (b.normalizedTarget x update)
noncomputable def Mlp.target (b : Mlp) (x update : Fin 5120 → ℝ) (i : Fin 5120) : ℝ :=
  residualTarget x update i + b.branchTarget x update i

structure Mlp.Finite (b : Mlp) (x update : Fin 5120 → BF) where
  addition : ∀ i, Kernels.ResidualRmsNorm.AddFinite (x i) (update i)
  normalization : Kernels.ResidualRmsNorm.NormFinite b.norm.platform x update b.norm.weight Blocks.width Blocks.eps
  mlp : TrellisMlp.Finite b.mlp (b.inputBits x update)

noncomputable def residualBudget (x update : Fin 5120 → BF) (errorX errorUpdate : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  fun i => Kernels.ResidualRmsNorm.residualBudget (x i) (update i) + errorX i + errorUpdate i

noncomputable def Mlp.normalizedBudget (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  Kernels.ResidualRmsNorm.normalizedBudget b.norm.platform x update b.norm.weight Blocks.width Blocks.eps
    Blocks.idealEps Blocks.epsError targetX targetUpdate errorX errorUpdate

noncomputable def Mlp.branchBudget (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ) (hf : b.Finite x update) : Fin 5120 → ℝ :=
  TrellisMlp.budget b.mlp (b.inputBits x update) (b.normalizedTarget targetX targetUpdate)
    (b.normalizedBudget x update targetX targetUpdate errorX errorUpdate) hf.mlp

noncomputable def Mlp.budget (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ) (hf : b.Finite x update) : Fin 5120 → ℝ :=
  ElementwiseAdd.budget (residual x update) (b.branch x update) (residualBudget x update errorX errorUpdate)
    (b.branchBudget x update targetX targetUpdate errorX errorUpdate hf)

theorem residual_error (x update : Fin 5120 → BF) (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : ∀ i, Kernels.ResidualRmsNorm.AddFinite (x i) (update i)) (i : Fin 5120) :
    |Model.toReal (residual x update i) - residualTarget targetX targetUpdate i| ≤ residualBudget x update errorX errorUpdate i :=
  Kernels.ResidualRmsNorm.residual_input_error _ _ (hf i) _ _ _ _ (hx i) (hu i)

theorem Mlp.normalized_finite (b : Mlp) (x update : Fin 5120 → BF) (hf : b.Finite x update) (i : Fin 5120) :
    Model.isFinite (b.normalized x update i) = true :=
  RmsNorm.value_finite b.norm.platform (Kernels.ResidualRmsNorm.residualInput x update) b.norm.weight
    Blocks.width Blocks.eps hf.normalization b.norm.scratch b.norm.base i

theorem Mlp.normalized_error (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (i : Fin 5120) :
    |Model.toReal (b.normalized x update i) - b.normalizedTarget targetX targetUpdate i| ≤
      b.normalizedBudget x update targetX targetUpdate errorX errorUpdate i :=
  Kernels.ResidualRmsNorm.normalized_input_error b.norm.platform x update b.norm.weight Blocks.width Blocks.eps
    Blocks.idealEps Blocks.epsError (by norm_num [Blocks.idealEps]) Blocks.eps_accuracy hf.addition hf.normalization
    targetX targetUpdate errorX errorUpdate hx hu b.norm.scratch b.norm.base i

theorem Mlp.branch_error (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (i : Fin 5120) :
    |Model.toReal (b.branch x update i) - b.branchTarget targetX targetUpdate i| ≤
      b.branchBudget x update targetX targetUpdate errorX errorUpdate hf i := by
  apply TrellisMlp.forward_error b.mlp (b.inputBits x update) (b.normalizedTarget targetX targetUpdate)
    (b.normalizedBudget x update targetX targetUpdate errorX errorUpdate) _ hf.mlp i
  intro j
  change |real (GateUpExecution.widen (Blocks.packed (b.normalized x update) j.val)) - _| ≤ _
  rw [Blocks.packed_real _ j (b.normalized_finite x update hf j)]
  exact b.normalized_error x update targetX targetUpdate errorX errorUpdate hx hu hf j

private theorem magnitude (value target error : ℝ) (h : |value - target| ≤ error) : |value| ≤ |target| + error := by
  calc
    _ = |(value - target) + target| := by congr 1; ring
    _ ≤ |value - target| + |target| := abs_add_le _ _
    _ ≤ error + |target| := add_le_add h (le_refl _)
    _ = |target| + error := add_comm _ _

-- This is an explicit software range condition on the derived error bounds,
-- not an assumed successful add or an assumed whole-MLP accuracy theorem.
def Mlp.Capacity (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ) (hf : b.Finite x update) : Prop :=
  ∀ i, (|residualTarget targetX targetUpdate i| + residualBudget x update errorX errorUpdate i) +
    (|b.branchTarget targetX targetUpdate i| + b.branchBudget x update targetX targetUpdate errorX errorUpdate hf i) ≤
    Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)

noncomputable def Mlp.bounds (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (hc : b.Capacity x update targetX targetUpdate errorX errorUpdate hf) :
    ElementwiseAdd.Bounds (residual x update) (b.branch x update) where
  leftBound i := |residualTarget targetX targetUpdate i| + residualBudget x update errorX errorUpdate i
  rightBound i := |b.branchTarget targetX targetUpdate i| + b.branchBudget x update targetX targetUpdate errorX errorUpdate hf i
  leftFinite i := (hf.addition i).cast
  rightFinite := TrellisMlp.forward_finite b.mlp (b.inputBits x update) hf.mlp
  leftMagnitude i := magnitude _ _ _ (residual_error x update targetX targetUpdate errorX errorUpdate hx hu hf.addition i)
  rightMagnitude i := magnitude _ _ _ (b.branch_error x update targetX targetUpdate errorX errorUpdate hx hu hf i)
  capacity := hc

theorem Mlp.forward_error (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (hc : b.Capacity x update targetX targetUpdate errorX errorUpdate hf) (i : Fin 5120) :
    |Model.toReal (b.forward x update i) - b.target targetX targetUpdate i| ≤ b.budget x update targetX targetUpdate errorX errorUpdate hf i :=
  ElementwiseAdd.forward_error _ _ (b.bounds x update targetX targetUpdate errorX errorUpdate hx hu hf hc)
    (residualTarget targetX targetUpdate) (b.branchTarget targetX targetUpdate) (residualBudget x update errorX errorUpdate)
    (b.branchBudget x update targetX targetUpdate errorX errorUpdate hf)
    (residual_error x update targetX targetUpdate errorX errorUpdate hx hu hf.addition)
    (b.branch_error x update targetX targetUpdate errorX errorUpdate hx hu hf) i

-- Direct operand ranges can establish the final addition independently of
-- the accumulated error budget. This is used by the model-wide range proof.
theorem Mlp.forward_error_of_bounds (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (bounds : ElementwiseAdd.Bounds (residual x update) (b.branch x update)) (i : Fin 5120) :
    |Model.toReal (b.forward x update i) - b.target targetX targetUpdate i| ≤ b.budget x update targetX targetUpdate errorX errorUpdate hf i :=
  ElementwiseAdd.forward_error _ _ bounds
    (residualTarget targetX targetUpdate) (b.branchTarget targetX targetUpdate) (residualBudget x update errorX errorUpdate)
    (b.branchBudget x update targetX targetUpdate errorX errorUpdate hf)
    (residual_error x update targetX targetUpdate errorX errorUpdate hx hu hf.addition)
    (b.branch_error x update targetX targetUpdate errorX errorUpdate hx hu hf) i

theorem Mlp.forward_finite (b : Mlp) (x update : Fin 5120 → BF)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i) - targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i) - targetUpdate i| ≤ errorUpdate i)
    (hf : b.Finite x update) (hc : b.Capacity x update targetX targetUpdate errorX errorUpdate hf) (i : Fin 5120) :
    Model.isFinite (b.forward x update i) = true :=
  ElementwiseAdd.forward_finite _ _ (b.bounds x update targetX targetUpdate errorX errorUpdate hx hu hf hc) i

end Inference.Models.Qwen.ResidualBlocks
