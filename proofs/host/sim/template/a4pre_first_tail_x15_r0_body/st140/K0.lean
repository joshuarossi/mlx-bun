import host.sim.template.a4pre_first_tail_x15_r0_body.st140.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st140.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st140.k0 from PRE_first_tail_x15_r0_body.st140.s0 to PRE_first_tail_x15_r0_body.st140.s1 : runOk PRE_first_tail_x15_r0_body.st140.F PRE_first_tail_x15_r0_body.st140.okL ((nth? PRE_first_tail_x15_r0_body.st140.ks 0).getD 0) PRE_first_tail_x15_r0_body.st140.s0 PRE_first_tail_x15_r0_body.st140.S0 = some (PRE_first_tail_x15_r0_body.st140.s1, PRE_first_tail_x15_r0_body.st140.S1)
boot_rfl PRE_first_tail_x15_r0_body.st140.last from PRE_first_tail_x15_r0_body.st140.s1 to PRE_first_tail_x15_r0_body.st140.s2 : interpS (step PRE_first_tail_x15_r0_body.st140.F PRE_first_tail_x15_r0_body.st140.s1).run PRE_first_tail_x15_r0_body.st140.S1 = some (PRE_first_tail_x15_r0_body.st140.s2, PRE_first_tail_x15_r0_body.st140.S2)
end Host.Load.Run.Tpl
