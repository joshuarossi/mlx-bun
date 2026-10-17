import models.qwen.TrellisMlpScheduled
import models.qwen.ResidualBlocks

namespace Inference.Models.Qwen.ResidualMlpScheduled
open Contracts.Mlx Contracts.Mlx.Numerics ResidualBlocks
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

abbrev Execution (block : Mlp) (x update : Fin 5120 → BF) :=
  TrellisMlpScheduled.Execution block.mlp (block.inputBits x update)

-- A concrete logical placement witnesses that the execution contract is
-- inhabited. Relating an allocation in a compiled kernel to it remains a
-- separate native-layout obligation.
def Execution.canonical (block : Mlp) (x update : Fin 5120 → BF) : Execution block x update :=
  TrellisMlpScheduled.Execution.canonical block.mlp (block.inputBits x update) (fun _ => 0)
    (4*(block.mlp.gatePlatform.base/4+4096)) (Or.inl (by omega))

def branch (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update) : Fin 5120 → BF :=
  TrellisMlpScheduled.forward block.mlp (block.inputBits x update) execution

theorem branch_eq (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update) :
    branch block x update execution=block.branch x update := by
  funext i
  exact TrellisMlpScheduled.forward_eq block.mlp (block.inputBits x update) execution i

def forward (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update) : Fin 5120 → BF :=
  ElementwiseAdd.forward (residual x update) (branch block x update execution)

theorem forward_eq (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update) :
    forward block x update execution=block.forward x update := by
  unfold forward
  rw [branch_eq]
  rfl

theorem forward_error (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update)
    (targetX targetUpdate errorX errorUpdate : Fin 5120 → ℝ)
    (hx : ∀ i, |Model.toReal (x i)-targetX i| ≤ errorX i)
    (hu : ∀ i, |Model.toReal (update i)-targetUpdate i| ≤ errorUpdate i)
    (hf : block.Finite x update) (bounds : ElementwiseAdd.Bounds (residual x update) (block.branch x update))
    (i : Fin 5120) :
    |Model.toReal (forward block x update execution i)-block.target targetX targetUpdate i| ≤
      block.budget x update targetX targetUpdate errorX errorUpdate hf i := by
  rw [forward_eq]
  exact block.forward_error_of_bounds x update targetX targetUpdate errorX errorUpdate hx hu hf bounds i

theorem forward_finite (block : Mlp) (x update : Fin 5120 → BF) (execution : Execution block x update)
    (bounds : ElementwiseAdd.Bounds (residual x update) (block.branch x update)) (i : Fin 5120) :
    Model.isFinite (forward block x update execution i)=true := by
  rw [forward_eq]
  exact ElementwiseAdd.forward_finite _ _ bounds i

end Inference.Models.Qwen.ResidualMlpScheduled
