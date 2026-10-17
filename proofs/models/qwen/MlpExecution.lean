import models.qwen.ResidualBlocks

namespace Inference.Models.Qwen.MlpExecution
open Contracts.Mlx ResidualBlocks
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- A proof-level implementation contract. Concrete instances must supply
-- their refinement proof; graph composition introduces no runtime checks.
-- The reference MLP already has its real-valued numerical-error theorem.
structure Implementation where
  Trace : WrittenLayers.GateDown → (Nat → BitVec 16) → Type
  forward : (mlp : WrittenLayers.GateDown) → (input : Nat → BitVec 16) → Trace mlp input → Fin 5120 → BF
  refines : ∀ mlp input execution, forward mlp input execution=mlp.forward input
  canonical : ∀ mlp input, Trace mlp input

abbrev ResidualTrace (impl : Implementation) (block : Mlp) (x update : Fin 5120 → BF) :=
  impl.Trace block.mlp (block.inputBits x update)

def residualForward (impl : Implementation) (block : Mlp) (x update : Fin 5120 → BF)
    (execution : ResidualTrace impl block x update) : Fin 5120 → BF :=
  ElementwiseAdd.forward (residual x update) (impl.forward block.mlp (block.inputBits x update) execution)

theorem residual_eq (impl : Implementation) (block : Mlp) (x update : Fin 5120 → BF)
    (execution : ResidualTrace impl block x update) : residualForward impl block x update execution=block.forward x update := by
  unfold residualForward
  rw [impl.refines]
  rfl

theorem forward_error (impl : Implementation) (mlp : WrittenLayers.GateDown) (input : Nat → BitVec 16)
    (execution : impl.Trace mlp input) (target error : Fin 5120 → ℝ)
    (hi : ∀ i, |Numerics.real (Kernels.Trellis.GateUpExecution.widen (input i.val))-target i| ≤ error i)
    (hf : TrellisMlp.Finite mlp input) (column : Fin 5120) :
    |Model.toReal (impl.forward mlp input execution column)-mlp.target target column| ≤ TrellisMlp.budget mlp input target error hf column := by
  rw [impl.refines]
  exact TrellisMlp.forward_error mlp input target error hi hf column

end Inference.Models.Qwen.MlpExecution
