import host.sim.template.a4pre_first_tail_x15_r0_body.st69.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st69.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st69.k0 from PRE_first_tail_x15_r0_body.st69.s0 to PRE_first_tail_x15_r0_body.st69.s1 : runOk PRE_first_tail_x15_r0_body.st69.F PRE_first_tail_x15_r0_body.st69.okL ((nth? PRE_first_tail_x15_r0_body.st69.ks 0).getD 0) PRE_first_tail_x15_r0_body.st69.s0 PRE_first_tail_x15_r0_body.st69.S0 = some (PRE_first_tail_x15_r0_body.st69.s1, PRE_first_tail_x15_r0_body.st69.S1)
boot_rfl PRE_first_tail_x15_r0_body.st69.k1 from PRE_first_tail_x15_r0_body.st69.s1 to PRE_first_tail_x15_r0_body.st69.s2 : runOk PRE_first_tail_x15_r0_body.st69.F PRE_first_tail_x15_r0_body.st69.okL ((nth? PRE_first_tail_x15_r0_body.st69.ks 1).getD 0) PRE_first_tail_x15_r0_body.st69.s1 PRE_first_tail_x15_r0_body.st69.S1 = some (PRE_first_tail_x15_r0_body.st69.s2, PRE_first_tail_x15_r0_body.st69.S2)
boot_rfl PRE_first_tail_x15_r0_body.st69.last from PRE_first_tail_x15_r0_body.st69.s2 to PRE_first_tail_x15_r0_body.st69.s3 : interpS (step PRE_first_tail_x15_r0_body.st69.F PRE_first_tail_x15_r0_body.st69.s2).run PRE_first_tail_x15_r0_body.st69.S2 = some (PRE_first_tail_x15_r0_body.st69.s3, PRE_first_tail_x15_r0_body.st69.S3)
end Host.Load.Run.Tpl
