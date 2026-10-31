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
boot_rfl PRE_first_tail_x15_r0_body.stepA351 from PRE_first_tail_x15_r0_body.s1300 to PRE_first_tail_x15_r0_body.s1301 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1300).run PRE_first_tail_x15_r0_body.S1300 = some (PRE_first_tail_x15_r0_body.s1301, PRE_first_tail_x15_r0_body.S1301)
boot_rfl PRE_first_tail_x15_r0_body.patchB351 from PRE_first_tail_x15_r0_body.s1301 to PRE_first_tail_x15_r0_body.s1302 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1301).run PRE_first_tail_x15_r0_body.S1301 = some (PRE_first_tail_x15_r0_body.s1302, PRE_first_tail_x15_r0_body.S1302)
boot_rfl PRE_first_tail_x15_r0_body.k1302 from PRE_first_tail_x15_r0_body.s1302 to PRE_first_tail_x15_r0_body.s1303 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB351 ((nth? PRE_first_tail_x15_r0_body.ks 1302).getD 0) PRE_first_tail_x15_r0_body.s1302 PRE_first_tail_x15_r0_body.S1302 = some (PRE_first_tail_x15_r0_body.s1303, PRE_first_tail_x15_r0_body.S1303)
boot_rfl PRE_first_tail_x15_r0_body.stepA352 from PRE_first_tail_x15_r0_body.s1303 to PRE_first_tail_x15_r0_body.s1304 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1303).run PRE_first_tail_x15_r0_body.S1303 = some (PRE_first_tail_x15_r0_body.s1304, PRE_first_tail_x15_r0_body.S1304)
end Host.Load.Run.Tpl
