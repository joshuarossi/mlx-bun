import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.k0 from PRE_first_tail_x15_r0_body.s0 to PRE_first_tail_x15_r0_body.s1 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB0 ((nth? PRE_first_tail_x15_r0_body.ks 0).getD 0) PRE_first_tail_x15_r0_body.s0 PRE_first_tail_x15_r0_body.S0 = some (PRE_first_tail_x15_r0_body.s1, PRE_first_tail_x15_r0_body.S1)
boot_rfl PRE_first_tail_x15_r0_body.stepA1 from PRE_first_tail_x15_r0_body.s1 to PRE_first_tail_x15_r0_body.s2 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1).run PRE_first_tail_x15_r0_body.S1 = some (PRE_first_tail_x15_r0_body.s2, PRE_first_tail_x15_r0_body.S2)
boot_rfl PRE_first_tail_x15_r0_body.patchB1 from PRE_first_tail_x15_r0_body.s2 to PRE_first_tail_x15_r0_body.s3 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s2).run PRE_first_tail_x15_r0_body.S2 = some (PRE_first_tail_x15_r0_body.s3, PRE_first_tail_x15_r0_body.S3)
boot_rfl PRE_first_tail_x15_r0_body.k3 from PRE_first_tail_x15_r0_body.s3 to PRE_first_tail_x15_r0_body.s4 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB1 ((nth? PRE_first_tail_x15_r0_body.ks 3).getD 0) PRE_first_tail_x15_r0_body.s3 PRE_first_tail_x15_r0_body.S3 = some (PRE_first_tail_x15_r0_body.s4, PRE_first_tail_x15_r0_body.S4)
end Host.Load.Run.Tpl
