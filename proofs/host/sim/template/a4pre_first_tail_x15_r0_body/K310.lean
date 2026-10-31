import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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
boot_rfl PRE_first_tail_x15_r0_body.stepA367 from PRE_first_tail_x15_r0_body.s1240 to PRE_first_tail_x15_r0_body.s1241 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1240).run PRE_first_tail_x15_r0_body.S1240 = some (PRE_first_tail_x15_r0_body.s1241, PRE_first_tail_x15_r0_body.S1241)
boot_rfl PRE_first_tail_x15_r0_body.patchB367 from PRE_first_tail_x15_r0_body.s1241 to PRE_first_tail_x15_r0_body.s1242 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1241).run PRE_first_tail_x15_r0_body.S1241 = some (PRE_first_tail_x15_r0_body.s1242, PRE_first_tail_x15_r0_body.S1242)
boot_rfl PRE_first_tail_x15_r0_body.k1242 from PRE_first_tail_x15_r0_body.s1242 to PRE_first_tail_x15_r0_body.s1243 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB367 ((nth? PRE_first_tail_x15_r0_body.ks 1242).getD 0) PRE_first_tail_x15_r0_body.s1242 PRE_first_tail_x15_r0_body.S1242 = some (PRE_first_tail_x15_r0_body.s1243, PRE_first_tail_x15_r0_body.S1243)
boot_rfl PRE_first_tail_x15_r0_body.stepA368 from PRE_first_tail_x15_r0_body.s1243 to PRE_first_tail_x15_r0_body.s1244 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1243).run PRE_first_tail_x15_r0_body.S1243 = some (PRE_first_tail_x15_r0_body.s1244, PRE_first_tail_x15_r0_body.S1244)
end Host.Load.Run.Tpl
