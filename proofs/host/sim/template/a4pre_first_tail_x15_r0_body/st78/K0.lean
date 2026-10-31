import host.sim.template.a4pre_first_tail_x15_r0_body.st78.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st78.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st78.k0 from PRE_first_tail_x15_r0_body.st78.s0 to PRE_first_tail_x15_r0_body.st78.s1 : runOk PRE_first_tail_x15_r0_body.st78.F PRE_first_tail_x15_r0_body.st78.okL ((nth? PRE_first_tail_x15_r0_body.st78.ks 0).getD 0) PRE_first_tail_x15_r0_body.st78.s0 PRE_first_tail_x15_r0_body.st78.S0 = some (PRE_first_tail_x15_r0_body.st78.s1, PRE_first_tail_x15_r0_body.st78.S1)
boot_rfl PRE_first_tail_x15_r0_body.st78.k1 from PRE_first_tail_x15_r0_body.st78.s1 to PRE_first_tail_x15_r0_body.st78.s2 : runOk PRE_first_tail_x15_r0_body.st78.F PRE_first_tail_x15_r0_body.st78.okL ((nth? PRE_first_tail_x15_r0_body.st78.ks 1).getD 0) PRE_first_tail_x15_r0_body.st78.s1 PRE_first_tail_x15_r0_body.st78.S1 = some (PRE_first_tail_x15_r0_body.st78.s2, PRE_first_tail_x15_r0_body.st78.S2)
boot_rfl PRE_first_tail_x15_r0_body.st78.k2 from PRE_first_tail_x15_r0_body.st78.s2 to PRE_first_tail_x15_r0_body.st78.s3 : runOk PRE_first_tail_x15_r0_body.st78.F PRE_first_tail_x15_r0_body.st78.okL ((nth? PRE_first_tail_x15_r0_body.st78.ks 2).getD 0) PRE_first_tail_x15_r0_body.st78.s2 PRE_first_tail_x15_r0_body.st78.S2 = some (PRE_first_tail_x15_r0_body.st78.s3, PRE_first_tail_x15_r0_body.st78.S3)
boot_rfl PRE_first_tail_x15_r0_body.st78.k3 from PRE_first_tail_x15_r0_body.st78.s3 to PRE_first_tail_x15_r0_body.st78.s4 : runOk PRE_first_tail_x15_r0_body.st78.F PRE_first_tail_x15_r0_body.st78.okL ((nth? PRE_first_tail_x15_r0_body.st78.ks 3).getD 0) PRE_first_tail_x15_r0_body.st78.s3 PRE_first_tail_x15_r0_body.st78.S3 = some (PRE_first_tail_x15_r0_body.st78.s4, PRE_first_tail_x15_r0_body.st78.S4)
end Host.Load.Run.Tpl
