import host.sim.template.a4pre_first_tail_x15_r0_body.H40
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
boot_rfl PRE_first_tail_x15_r0_body.k1296 from PRE_first_tail_x15_r0_body.s1296 to PRE_first_tail_x15_r0_body.s1297 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB383 ((nth? PRE_first_tail_x15_r0_body.ks 1296).getD 0) PRE_first_tail_x15_r0_body.s1296 PRE_first_tail_x15_r0_body.S1296 = some (PRE_first_tail_x15_r0_body.s1297, PRE_first_tail_x15_r0_body.S1297)
boot_rfl PRE_first_tail_x15_r0_body.stepA384 from PRE_first_tail_x15_r0_body.s1297 to PRE_first_tail_x15_r0_body.s1298 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1297).run PRE_first_tail_x15_r0_body.S1297 = some (PRE_first_tail_x15_r0_body.s1298, PRE_first_tail_x15_r0_body.S1298)
boot_rfl PRE_first_tail_x15_r0_body.patchB384 from PRE_first_tail_x15_r0_body.s1298 to PRE_first_tail_x15_r0_body.s1299 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1298).run PRE_first_tail_x15_r0_body.S1298 = some (PRE_first_tail_x15_r0_body.s1299, PRE_first_tail_x15_r0_body.S1299)
boot_rfl PRE_first_tail_x15_r0_body.k1299 from PRE_first_tail_x15_r0_body.s1299 to PRE_first_tail_x15_r0_body.s1300 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB384 ((nth? PRE_first_tail_x15_r0_body.ks 1299).getD 0) PRE_first_tail_x15_r0_body.s1299 PRE_first_tail_x15_r0_body.S1299 = some (PRE_first_tail_x15_r0_body.s1300, PRE_first_tail_x15_r0_body.S1300)
end Host.Load.Run.Tpl
