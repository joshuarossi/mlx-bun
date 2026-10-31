import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK1462 from PRE_first_tail_x15_r0_body.s1462 to PRE_first_tail_x15_r0_body.s1463 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1462).getD 0) PRE_first_tail_x15_r0_body.s1462 PRE_first_tail_x15_r0_body.S1462) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1463, PRE_first_tail_x15_r0_body.S1463)
end Host.Load.Run.Tpl
