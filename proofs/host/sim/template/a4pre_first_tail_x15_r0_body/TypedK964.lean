import host.sim.template.a4pre_first_tail_x15_r0_body.H30
import host.sim.template.a4pre_first_tail_x15_r0_body.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.bodyK964 from PRE_first_tail_x15_r0_body.s964 to PRE_first_tail_x15_r0_body.s965 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.F (PRE_first_tail_x15_r0_body.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_body.ks 964).getD 0) PRE_first_tail_x15_r0_body.s964 PRE_first_tail_x15_r0_body.S964) =
    fun _ _ => some (PRE_first_tail_x15_r0_body.s965, PRE_first_tail_x15_r0_body.S965)
end Host.Load.Run.Tpl
