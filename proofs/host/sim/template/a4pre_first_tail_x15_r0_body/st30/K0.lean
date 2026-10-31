import host.sim.template.a4pre_first_tail_x15_r0_body.st30.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st30.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st30.k0 from PRE_first_tail_x15_r0_body.st30.s0 to PRE_first_tail_x15_r0_body.st30.s1 : runOk PRE_first_tail_x15_r0_body.st30.F PRE_first_tail_x15_r0_body.st30.okL ((nth? PRE_first_tail_x15_r0_body.st30.ks 0).getD 0) PRE_first_tail_x15_r0_body.st30.s0 PRE_first_tail_x15_r0_body.st30.S0 = some (PRE_first_tail_x15_r0_body.st30.s1, PRE_first_tail_x15_r0_body.st30.S1)
boot_rfl PRE_first_tail_x15_r0_body.st30.k1 from PRE_first_tail_x15_r0_body.st30.s1 to PRE_first_tail_x15_r0_body.st30.s2 : runOk PRE_first_tail_x15_r0_body.st30.F PRE_first_tail_x15_r0_body.st30.okL ((nth? PRE_first_tail_x15_r0_body.st30.ks 1).getD 0) PRE_first_tail_x15_r0_body.st30.s1 PRE_first_tail_x15_r0_body.st30.S1 = some (PRE_first_tail_x15_r0_body.st30.s2, PRE_first_tail_x15_r0_body.st30.S2)
boot_rfl PRE_first_tail_x15_r0_body.st30.last from PRE_first_tail_x15_r0_body.st30.s2 to PRE_first_tail_x15_r0_body.st30.s3 : interpS (step PRE_first_tail_x15_r0_body.st30.F PRE_first_tail_x15_r0_body.st30.s2).run PRE_first_tail_x15_r0_body.st30.S2 = some (PRE_first_tail_x15_r0_body.st30.s3, PRE_first_tail_x15_r0_body.st30.S3)
end Host.Load.Run.Tpl
