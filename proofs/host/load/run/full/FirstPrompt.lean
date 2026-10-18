import host.load.run.full.FirstInputs
import host.mlx.FfiInput
namespace Host.Load.Run.Full
open Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Ts
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

theorem prompt_node (table : List F64) :
    firstFfiGraph table promptCarrier.node = some ⟨.data [235, 37, 0, 0] [1, 1] 7, []⟩ := by rfl

variable {C : Inference.Contracts.Mlx.M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

theorem prompt_value (env : FfiEval.Env InKey) (table : List F64) :
    evalR M K env (firstFfiGraph table) promptCarrier.node = some (promptIds 9707) := by
  have cg := cgLeaves_none (firstFfiGraph table) promptCarrier.node _ (prompt_node table) (by rfl)
  rw [evalR_eq, prompt_node, cg]
  exact prompt_data

end Host.Load.Run.Full
