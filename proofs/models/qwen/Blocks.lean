import layers.Normalization
import models.qwen.WrittenLayers
import contracts.mlx.ElementwiseAdd

namespace Inference.Models.Qwen.Blocks
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Trellis
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open WrittenLayers
open Layers
set_option maxHeartbeats 2000000
set_option maxRecDepth 10000

-- Constants of the selected 5120-wide Qwen graph. These proofs use Lean's
-- logical float model, never native floating-point evaluation.
def width : Float32 := Float32.ofBits 0x45a00000
def eps : Float32 := Float32.ofBits 0x358637bd
noncomputable def idealEps : ℝ := 1 / 1000000
noncomputable def epsError : ℝ := 1 / 10^14

theorem width_value : real width = 5120 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 10485760 (-11) (by decide)) = 5120
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 10485760 * ((2 : ℝ)^11)⁻¹ = 5120
  norm_num

theorem width_finite : width.isFinite = true := by decide +kernel

theorem width_domain : Division.DivisorDomain width := by
  unfold Division.DivisorDomain
  rw [width_value]
  norm_num

theorem eps_value : real eps = (8796093 : ℝ) / 2^43 := by
  rw [real_unpack]
  change Model.unpackedToReal (.finite .positive 8796093 (-43) (by decide)) = _
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  change 8796093 * ((2 : ℝ)^43)⁻¹ = 8796093 / 8796093022208
  norm_num

theorem eps_finite : eps.isFinite = true := by decide +kernel

theorem eps_accuracy : |real eps - idealEps| ≤ epsError := by
  rw [eps_value]
  norm_num [idealEps, epsError]

theorem eps_normal : FlushToZero.threshold < real eps := by
  rw [eps_value]
  norm_num [FlushToZero.threshold]

-- QwenAttentionLayer.forwardMlp and QwenDeltaLayer.forwardMlp both use the
-- loaded normalization weight directly, followed by GateDownMLP and a bf16
-- residual add. Weight-file loading and the mixer half remain separate.
-- This module describes standalone normalization. The fused residual
-- schedule is modeled in ResidualBlocks; recurrent heads are modeled in Ssm.
structure Norm where
  platform : RmsNorm.Platform
  weight : Fin 5120 → BFloat16Arithmetic.Value
  scratch : M1Max.WordMemory
  base : Nat

def widenInput (input : Fin 5120 → BFloat16Arithmetic.Value) : Fin 5120 → Float32 :=
  fun i => BFloat16.widen (input i)

def Norm.forward (norm : Norm) (input : Fin 5120 → BFloat16Arithmetic.Value) : Fin 5120 → BFloat16Arithmetic.Value :=
  Layers.Normalization.value norm.platform (widenInput input) norm.weight false width eps norm.scratch norm.base

noncomputable def Norm.target (norm : Norm) (input : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  Contracts.Mlx.Normalization.rmsNorm input (fun i => Model.toReal (norm.weight i)) idealEps

def Norm.Finite (norm : Norm) (input : Fin 5120 → BFloat16Arithmetic.Value) : Prop :=
  NormalizationExecution.Finite norm.platform.divide (widenInput input) norm.weight
    (RmsNorm.expression norm.platform 5120) width eps norm.platform.rsqrt

noncomputable def Norm.errorBudget (norm : Norm) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) : Fin 5120 → ℝ :=
  Layers.Normalization.errorBudget norm.platform (widenInput input) norm.weight false width eps
    idealEps epsError ideal inputError

theorem Norm.forward_finite (norm : Norm) (input : Fin 5120 → BFloat16Arithmetic.Value) (hf : norm.Finite input) (i : Fin 5120) :
    Model.isFinite (norm.forward input i) = true :=
  Layers.Normalization.value_finite norm.platform (widenInput input) norm.weight false width eps hf norm.scratch norm.base i

theorem Norm.forward_error (norm : Norm) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (input i) - ideal i| ≤ inputError i)
    (hx : ∀ i, Model.isFinite (input i) = true) (hw : ∀ i, Model.isFinite (norm.weight i) = true)
    (hf : norm.Finite input) (i : Fin 5120) :
    |Model.toReal (norm.forward input i) - norm.target ideal i| ≤ norm.errorBudget input ideal inputError i := by
  apply Layers.Normalization.value_error norm.platform (widenInput input) norm.weight false width eps idealEps epsError
    (by norm_num [idealEps]) eps_accuracy ideal inputError _ hw _ hf norm.scratch norm.base i
  · intro j
    change |real (BFloat16.widen (input j)) - ideal j| ≤ inputError j
    rw [BFloat16.widen_real _ (hx j)]
    exact hi j
  · intro j
    simp [Layers.Normalization.PreparationFinite]

def packed (input : Fin 5120 → BFloat16Arithmetic.Value) (index : Nat) : BitVec 16 :=
  if h : index < 5120 then (input ⟨index, h⟩).bits else 0

theorem packed_read (input : Fin 5120 → BFloat16Arithmetic.Value) (i : Fin 5120) (hf : Model.isFinite (input i) = true) :
    GateUpExecution.widen (packed input i.val) = BFloat16.widen (input i) := by
  let bits : Fin 5120 → BitVec 16 := fun j => (input j).bits
  have hr : packed input i.val = bits i := by
    change (if h : i.val < 5120 then bits ⟨i.val, h⟩ else (0 : BitVec 16)) = bits i
    rw [dite_eq_left i.isLt]
  rw [hr]
  change Float32.ofBits ⟨(input i).bits.setWidth 32 <<< 16⟩ = _
  exact (BFloat16.widen_bits _ hf).symm

theorem packed_real (input : Fin 5120 → BFloat16Arithmetic.Value) (i : Fin 5120) (hf : Model.isFinite (input i) = true) :
    real (GateUpExecution.widen (packed input i.val)) = Model.toReal (input i) := by
  rw [packed_read input i hf, BFloat16.widen_real _ hf]

structure MlpBlock where
  norm : Norm
  mlp : GateDown

def MlpBlock.inputBits (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value) : Nat → BitVec 16 :=
  packed (block.norm.forward input)

def MlpBlock.branch (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value) : Fin 5120 → BFloat16Arithmetic.Value :=
  block.mlp.forward (block.inputBits input)

def MlpBlock.forward (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value) : Fin 5120 → BFloat16Arithmetic.Value :=
  ElementwiseAdd.forward input (block.branch input)

noncomputable def MlpBlock.target (block : MlpBlock) (input : Fin 5120 → ℝ) (i : Fin 5120) : ℝ :=
  input i + block.mlp.target (block.norm.target input) i

-- Software obligations live here, separately from the primitive hardware
-- profiles. The gate proof is constructed by the previously checked tail
-- theorems; finite-range obligations still need model-wide discharge.
structure MlpBlock.KernelProof (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value) where
  inputFinite : ∀ i, Model.isFinite (input i) = true
  weightFinite : ∀ i, Model.isFinite (block.norm.weight i) = true
  normFinite : block.norm.Finite input
  gate : HiddenContract block.mlp.activation block.mlp.gatePlatform block.mlp.gate block.mlp.up (block.inputBits input)
  downFinite : TrellisCodebookDown.Finite block.mlp.downPlatform block.mlp.down (block.mlp.intermediate (block.inputBits input))

noncomputable def MlpBlock.branchError (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (proof : block.KernelProof input) : Fin 5120 → ℝ :=
  block.mlp.errorBudget (block.inputBits input) (block.norm.target ideal)
    (block.norm.errorBudget input ideal inputError) proof.gate

theorem MlpBlock.branch_error (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (input i) - ideal i| ≤ inputError i)
    (proof : block.KernelProof input) (i : Fin 5120) :
    |Model.toReal (block.branch input i) - block.mlp.target (block.norm.target ideal) i| ≤ block.branchError input ideal inputError proof i := by
  apply GateDown.forward_error block.mlp (block.inputBits input) (block.norm.target ideal)
    (block.norm.errorBudget input ideal inputError) _ proof.gate proof.downFinite i
  intro j
  change |real (GateUpExecution.widen (packed (block.norm.forward input) j.val)) - _| ≤ _
  rw [packed_real _ j (block.norm.forward_finite input proof.normFinite j)]
  exact block.norm.forward_error input ideal inputError hi proof.inputFinite proof.weightFinite proof.normFinite j

private theorem magnitude_of_error (value target error : ℝ) (h : |value - target| ≤ error) : |value| ≤ |target| + error := by
  calc
    _ = |(value - target) + target| := by congr 1; ring
    _ ≤ |value - target| + |target| := abs_add_le _ _
    _ ≤ error + |target| := add_le_add h (le_refl _)
    _ = |target| + error := add_comm _ _

-- Overflow is derived from the incoming error/range contracts; it is not
-- a promise that the residual instruction happened to return a finite value.
noncomputable def MlpBlock.residualBounds (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (input i) - ideal i| ≤ inputError i)
    (proof : block.KernelProof input)
    (capacity : ∀ i, (|ideal i| + inputError i) + (|block.mlp.target (block.norm.target ideal) i| +
      block.branchError input ideal inputError proof i) ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) :
    ElementwiseAdd.Bounds input (block.branch input) where
  leftBound i := |ideal i| + inputError i
  rightBound i := |block.mlp.target (block.norm.target ideal) i| + block.branchError input ideal inputError proof i
  leftFinite := proof.inputFinite
  rightFinite := block.mlp.forward_finite (block.inputBits input) proof.downFinite
  leftMagnitude i := magnitude_of_error _ _ _ (hi i)
  rightMagnitude i := magnitude_of_error _ _ _ (block.branch_error input ideal inputError hi proof i)
  capacity := capacity

noncomputable def MlpBlock.errorBudget (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (proof : block.KernelProof input) : Fin 5120 → ℝ :=
  ElementwiseAdd.budget input (block.branch input) inputError (block.branchError input ideal inputError proof)

theorem MlpBlock.forward_error (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (input i) - ideal i| ≤ inputError i)
    (proof : block.KernelProof input)
    (capacity : ∀ i, (|ideal i| + inputError i) + (|block.mlp.target (block.norm.target ideal) i| +
      block.branchError input ideal inputError proof i) ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) (i : Fin 5120) :
    |Model.toReal (block.forward input i) - block.target ideal i| ≤ block.errorBudget input ideal inputError proof i :=
  ElementwiseAdd.forward_error input (block.branch input) (block.residualBounds input ideal inputError hi proof capacity)
    ideal (block.mlp.target (block.norm.target ideal)) inputError (block.branchError input ideal inputError proof)
    hi (block.branch_error input ideal inputError hi proof) i

theorem MlpBlock.forward_finite (block : MlpBlock) (input : Fin 5120 → BFloat16Arithmetic.Value)
    (ideal inputError : Fin 5120 → ℝ) (hi : ∀ i, |Model.toReal (input i) - ideal i| ≤ inputError i)
    (proof : block.KernelProof input)
    (capacity : ∀ i, (|ideal i| + inputError i) + (|block.mlp.target (block.norm.target ideal) i| +
      block.branchError input ideal inputError proof i) ≤ Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)) (i : Fin 5120) :
    Model.isFinite (block.forward input i) = true :=
  ElementwiseAdd.forward_finite input (block.branch input) (block.residualBounds input ideal inputError hi proof capacity) i

end Inference.Models.Qwen.Blocks
