import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK385F from PRE_first_tail_x15_r0_body.s385 to PRE_first_tail_x15_r0_body.s386 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 385).getD 0) PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.S385) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s386, PRE_first_tail_x15_r0_body.S386)
theorem PRE_first_tail_x15_r0_body.bodyK385 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 385).getD 0) PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.S385) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s386, PRE_first_tail_x15_r0_body.S386) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x15_r0_body.bodyK385F
end Host.Load.Run.Tpl
