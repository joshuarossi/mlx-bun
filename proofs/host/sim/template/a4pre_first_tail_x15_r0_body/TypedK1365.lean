import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK1365F from PRE_first_tail_x15_r0_body.s1365 to PRE_first_tail_x15_r0_body.s1366 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.F (Host.Ts.Sim.Compose.VWFrames.bodyOkN bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1365).getD 0) PRE_first_tail_x15_r0_body.s1365 PRE_first_tail_x15_r0_body.S1365) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1366, PRE_first_tail_x15_r0_body.S1366)
theorem PRE_first_tail_x15_r0_body.bodyK1365 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1365).getD 0) PRE_first_tail_x15_r0_body.s1365 PRE_first_tail_x15_r0_body.S1365) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1366, PRE_first_tail_x15_r0_body.S1366) :=
  runOk_fun_of_runOkS Host.Ts.Sim.Compose.VWFrames.bodyOkN_ok PRE_first_tail_x15_r0_body.bodyK1365F
end Host.Load.Run.Tpl
