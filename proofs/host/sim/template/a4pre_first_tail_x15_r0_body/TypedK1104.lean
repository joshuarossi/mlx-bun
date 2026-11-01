import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK1104F from PRE_first_tail_x15_r0_body.s1104 to PRE_first_tail_x15_r0_body.s1105 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1104).getD 0) PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.S1104) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1105, PRE_first_tail_x15_r0_body.S1105)
theorem PRE_first_tail_x15_r0_body.bodyK1104 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1104).getD 0) PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.S1104) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1105, PRE_first_tail_x15_r0_body.S1105) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x15_r0_body.bodyK1104F
end Host.Load.Run.Tpl
