import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK1625 from PRE_first_tail_x15_r0_body.s1625 to PRE_first_tail_x15_r0_body.s1626 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1625).getD 0) PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.S1625) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1626, PRE_first_tail_x15_r0_body.S1626)
end Host.Load.Run.Tpl
