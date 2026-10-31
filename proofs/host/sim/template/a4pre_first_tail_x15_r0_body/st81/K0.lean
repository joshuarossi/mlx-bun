import host.sim.template.a4pre_first_tail_x15_r0_body.st81.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.st81.Ok
import host.sim.Chunk
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.st81.k0 from PRE_first_tail_x15_r0_body.st81.s0 to PRE_first_tail_x15_r0_body.st81.s1 : runOk PRE_first_tail_x15_r0_body.st81.F PRE_first_tail_x15_r0_body.st81.okL ((nth? PRE_first_tail_x15_r0_body.st81.ks 0).getD 0) PRE_first_tail_x15_r0_body.st81.s0 PRE_first_tail_x15_r0_body.st81.S0 = some (PRE_first_tail_x15_r0_body.st81.s1, PRE_first_tail_x15_r0_body.st81.S1)
boot_rfl PRE_first_tail_x15_r0_body.st81.k1 from PRE_first_tail_x15_r0_body.st81.s1 to PRE_first_tail_x15_r0_body.st81.s2 : runOk PRE_first_tail_x15_r0_body.st81.F PRE_first_tail_x15_r0_body.st81.okL ((nth? PRE_first_tail_x15_r0_body.st81.ks 1).getD 0) PRE_first_tail_x15_r0_body.st81.s1 PRE_first_tail_x15_r0_body.st81.S1 = some (PRE_first_tail_x15_r0_body.st81.s2, PRE_first_tail_x15_r0_body.st81.S2)
boot_rfl PRE_first_tail_x15_r0_body.st81.last from PRE_first_tail_x15_r0_body.st81.s2 to PRE_first_tail_x15_r0_body.st81.s3 : interpS (step PRE_first_tail_x15_r0_body.st81.F PRE_first_tail_x15_r0_body.st81.s2).run PRE_first_tail_x15_r0_body.st81.S2 = some (PRE_first_tail_x15_r0_body.st81.s3, PRE_first_tail_x15_r0_body.st81.S3)
end Host.Load.Run.Tpl
