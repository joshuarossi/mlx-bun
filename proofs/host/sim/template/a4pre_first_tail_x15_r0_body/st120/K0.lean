import host.sim.template.a4pre_first_tail_x15_r0_body.st120.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st120.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st120.k0 from PRE_first_tail_x15_r0_body.st120.s0 to PRE_first_tail_x15_r0_body.st120.s1 : runOk PRE_first_tail_x15_r0_body.st120.F PRE_first_tail_x15_r0_body.st120.okL ((nth? PRE_first_tail_x15_r0_body.st120.ks 0).getD 0) PRE_first_tail_x15_r0_body.st120.s0 PRE_first_tail_x15_r0_body.st120.S0 = some (PRE_first_tail_x15_r0_body.st120.s1, PRE_first_tail_x15_r0_body.st120.S1)
boot_rfl PRE_first_tail_x15_r0_body.st120.k1 from PRE_first_tail_x15_r0_body.st120.s1 to PRE_first_tail_x15_r0_body.st120.s2 : runOk PRE_first_tail_x15_r0_body.st120.F PRE_first_tail_x15_r0_body.st120.okL ((nth? PRE_first_tail_x15_r0_body.st120.ks 1).getD 0) PRE_first_tail_x15_r0_body.st120.s1 PRE_first_tail_x15_r0_body.st120.S1 = some (PRE_first_tail_x15_r0_body.st120.s2, PRE_first_tail_x15_r0_body.st120.S2)
boot_rfl PRE_first_tail_x15_r0_body.st120.k2 from PRE_first_tail_x15_r0_body.st120.s2 to PRE_first_tail_x15_r0_body.st120.s3 : runOk PRE_first_tail_x15_r0_body.st120.F PRE_first_tail_x15_r0_body.st120.okL ((nth? PRE_first_tail_x15_r0_body.st120.ks 2).getD 0) PRE_first_tail_x15_r0_body.st120.s2 PRE_first_tail_x15_r0_body.st120.S2 = some (PRE_first_tail_x15_r0_body.st120.s3, PRE_first_tail_x15_r0_body.st120.S3)
boot_rfl PRE_first_tail_x15_r0_body.st120.k3 from PRE_first_tail_x15_r0_body.st120.s3 to PRE_first_tail_x15_r0_body.st120.s4 : runOk PRE_first_tail_x15_r0_body.st120.F PRE_first_tail_x15_r0_body.st120.okL ((nth? PRE_first_tail_x15_r0_body.st120.ks 3).getD 0) PRE_first_tail_x15_r0_body.st120.s3 PRE_first_tail_x15_r0_body.st120.S3 = some (PRE_first_tail_x15_r0_body.st120.s4, PRE_first_tail_x15_r0_body.st120.S4)
end Host.Load.Run.Tpl
