import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.TypedOk
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_suffix.bodyK7 from PRE_first_tail_x15_r0_suffix.s7 to PRE_first_tail_x15_r0_suffix.s8 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_suffix.F (PRE_first_tail_x15_r0_suffix.bodyOkB bytes rows) ((nth? PRE_first_tail_x15_r0_suffix.ks 7).getD 0) PRE_first_tail_x15_r0_suffix.s7 PRE_first_tail_x15_r0_suffix.S7) =
    fun _ _ => some (PRE_first_tail_x15_r0_suffix.s8, PRE_first_tail_x15_r0_suffix.S8)
end Host.Load.Run.Tpl
