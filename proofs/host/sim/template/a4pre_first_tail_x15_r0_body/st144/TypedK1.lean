import host.sim.template.a4pre_first_tail_x15_r0_body.st144.TypedOk
import host.sim.template.a4pre_first_tail_x15_r0_body.st144.H0
import host.sim.template.BootEq
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

boot_rfl PRE_first_tail_x15_r0_body.st144.bodyK1F from PRE_first_tail_x15_r0_body.st144.s1 to PRE_first_tail_x15_r0_body.st144.s2 :
  (fun (bytes : List Byte) (rows : Nat) => runOkS PRE_first_tail_x15_r0_body.st144.F (PRE_first_tail_x15_r0_body.st144.bodyOkLN bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st144.ks 1).getD 0) PRE_first_tail_x15_r0_body.st144.s1 PRE_first_tail_x15_r0_body.st144.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st144.s2, PRE_first_tail_x15_r0_body.st144.S2)
theorem PRE_first_tail_x15_r0_body.st144.bodyK1 :
  (fun (bytes : List Byte) (rows : Nat) => runOk PRE_first_tail_x15_r0_body.st144.F (PRE_first_tail_x15_r0_body.st144.bodyOkL bytes rows)
    ((nth? PRE_first_tail_x15_r0_body.st144.ks 1).getD 0) PRE_first_tail_x15_r0_body.st144.s1 PRE_first_tail_x15_r0_body.st144.S1) = fun _ _ => some (PRE_first_tail_x15_r0_body.st144.s2, PRE_first_tail_x15_r0_body.st144.S2) :=
  runOk_fun_of_runOkS PRE_first_tail_x15_r0_body.st144.bodyOkLN_ok PRE_first_tail_x15_r0_body.st144.bodyK1F
end Host.Load.Run.Tpl
