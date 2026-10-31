import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK1225 from PRE_first_tail_x15_r0_body.s1225 to PRE_first_tail_x15_r0_body.s1226 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 1225).getD 0) PRE_first_tail_x15_r0_body.s1225 PRE_first_tail_x15_r0_body.S1225) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s1226, PRE_first_tail_x15_r0_body.S1226)
end Host.Load.Run.Tpl
