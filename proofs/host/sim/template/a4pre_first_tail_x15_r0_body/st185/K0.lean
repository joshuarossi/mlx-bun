import host.sim.template.a4pre_first_tail_x15_r0_body.st185.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st185.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st185.k0 from PRE_first_tail_x15_r0_body.st185.s0 to PRE_first_tail_x15_r0_body.st185.s1 : runOk PRE_first_tail_x15_r0_body.st185.F PRE_first_tail_x15_r0_body.st185.okL ((nth? PRE_first_tail_x15_r0_body.st185.ks 0).getD 0) PRE_first_tail_x15_r0_body.st185.s0 PRE_first_tail_x15_r0_body.st185.S0 = some (PRE_first_tail_x15_r0_body.st185.s1, PRE_first_tail_x15_r0_body.st185.S1)
boot_rfl PRE_first_tail_x15_r0_body.st185.last from PRE_first_tail_x15_r0_body.st185.s1 to PRE_first_tail_x15_r0_body.st185.s2 : interpS (step PRE_first_tail_x15_r0_body.st185.F PRE_first_tail_x15_r0_body.st185.s1).run PRE_first_tail_x15_r0_body.st185.S1 = some (PRE_first_tail_x15_r0_body.st185.s2, PRE_first_tail_x15_r0_body.st185.S2)
end Host.Load.Run.Tpl
