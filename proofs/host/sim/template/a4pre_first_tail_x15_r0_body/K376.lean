import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.stepA406 from PRE_first_tail_x15_r0_body.s1504 to PRE_first_tail_x15_r0_body.s1505 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1504).run PRE_first_tail_x15_r0_body.S1504 = some (PRE_first_tail_x15_r0_body.s1505, PRE_first_tail_x15_r0_body.S1505)
boot_rfl PRE_first_tail_x15_r0_body.patchB406 from PRE_first_tail_x15_r0_body.s1505 to PRE_first_tail_x15_r0_body.s1506 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1505).run PRE_first_tail_x15_r0_body.S1505 = some (PRE_first_tail_x15_r0_body.s1506, PRE_first_tail_x15_r0_body.S1506)
boot_rfl PRE_first_tail_x15_r0_body.k1506 from PRE_first_tail_x15_r0_body.s1506 to PRE_first_tail_x15_r0_body.s1507 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB406 ((nth? PRE_first_tail_x15_r0_body.ks 1506).getD 0) PRE_first_tail_x15_r0_body.s1506 PRE_first_tail_x15_r0_body.S1506 = some (PRE_first_tail_x15_r0_body.s1507, PRE_first_tail_x15_r0_body.S1507)
boot_rfl PRE_first_tail_x15_r0_body.stepA407 from PRE_first_tail_x15_r0_body.s1507 to PRE_first_tail_x15_r0_body.s1508 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1507).run PRE_first_tail_x15_r0_body.S1507 = some (PRE_first_tail_x15_r0_body.s1508, PRE_first_tail_x15_r0_body.S1508)
end Host.Load.Run.Tpl
