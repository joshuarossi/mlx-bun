import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_suffix.bodyK4 from PRE_first_tail_x15_r0_suffix.s4 to PRE_first_tail_x15_r0_suffix.s5 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_suffix.F (PRE_first_tail_x15_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_suffix.ks 4).getD 0) PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.S4) =
    fun _ _ => some (PRE_first_tail_x15_r0_suffix.s5, PRE_first_tail_x15_r0_suffix.S5)
end Host.Load.Run.Tpl
