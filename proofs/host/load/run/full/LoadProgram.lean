import host.load.run.full.ChoiceStates
import host.load.ProgramCommand
namespace Host.Load.Run.Full
open Host.Load Host.Mlx Host.Mlx.FfiEval Host.Ts
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
load_program code : parameterChoice.graph, Extract.parameterTensors parameterChoice, (CSrv.val ⟨[]⟩)
set_option maxRecDepth 1000000 in
theorem load_program_nodes : code.length = 2075 := by rfl
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
theorem checkpoint_leaves : (code.filter fun n => match n.op with | .load _ _ => true | _ => false).length = 1655 := by rfl
end Host.Load.Run.Full
