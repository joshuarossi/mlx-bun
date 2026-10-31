import host.sim.template.a4pre_first_tail_x15_r0_body.st21.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.st21.H0
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st21.bodyK0 from PRE_first_tail_x15_r0_body.st21.s0 to PRE_first_tail_x15_r0_body.st21.s1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st21.F (PRE_first_tail_x15_r0_body.st21.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st21.ks 0).getD 0) PRE_first_tail_x15_r0_body.st21.s0 PRE_first_tail_x15_r0_body.st21.S0) = fun _ _ => some (PRE_first_tail_x15_r0_body.st21.s1, PRE_first_tail_x15_r0_body.st21.S1)
end Host.Load.Run.Tpl
