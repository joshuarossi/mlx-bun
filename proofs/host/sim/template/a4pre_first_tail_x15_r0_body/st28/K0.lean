import host.sim.template.a4pre_first_tail_x15_r0_body.st28.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st28.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st28.k0 from PRE_first_tail_x15_r0_body.st28.s0 to PRE_first_tail_x15_r0_body.st28.s1 : runOk PRE_first_tail_x15_r0_body.st28.F PRE_first_tail_x15_r0_body.st28.okL ((nth? PRE_first_tail_x15_r0_body.st28.ks 0).getD 0) PRE_first_tail_x15_r0_body.st28.s0 PRE_first_tail_x15_r0_body.st28.S0 = some (PRE_first_tail_x15_r0_body.st28.s1, PRE_first_tail_x15_r0_body.st28.S1)
boot_rfl PRE_first_tail_x15_r0_body.st28.last from PRE_first_tail_x15_r0_body.st28.s1 to PRE_first_tail_x15_r0_body.st28.s2 : interpS (step PRE_first_tail_x15_r0_body.st28.F PRE_first_tail_x15_r0_body.st28.s1).run PRE_first_tail_x15_r0_body.st28.S1 = some (PRE_first_tail_x15_r0_body.st28.s2, PRE_first_tail_x15_r0_body.st28.S2)
end Host.Load.Run.Tpl
