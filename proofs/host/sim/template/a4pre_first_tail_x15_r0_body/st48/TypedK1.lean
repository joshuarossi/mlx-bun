import host.sim.template.a4pre_first_tail_x15_r0_body.st48.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.st48.H0
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st48.bodyK1 from PRE_first_tail_x15_r0_body.st48.s1 to PRE_first_tail_x15_r0_body.st48.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st48.F (PRE_first_tail_x15_r0_body.st48.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st48.ks 1).getD 0) PRE_first_tail_x15_r0_body.st48.s1 PRE_first_tail_x15_r0_body.st48.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st48.s2, PRE_first_tail_x15_r0_body.st48.S2)
end Host.Load.Run.Tpl
