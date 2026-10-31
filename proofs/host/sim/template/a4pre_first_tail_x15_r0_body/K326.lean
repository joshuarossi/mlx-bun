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
boot_rfl PRE_first_tail_x15_r0_body.stepA386 from PRE_first_tail_x15_r0_body.s1304 to PRE_first_tail_x15_r0_body.s1305 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1304).run PRE_first_tail_x15_r0_body.S1304 = some (PRE_first_tail_x15_r0_body.s1305, PRE_first_tail_x15_r0_body.S1305)
boot_rfl PRE_first_tail_x15_r0_body.patchB386 from PRE_first_tail_x15_r0_body.s1305 to PRE_first_tail_x15_r0_body.s1306 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1305).run PRE_first_tail_x15_r0_body.S1305 = some (PRE_first_tail_x15_r0_body.s1306, PRE_first_tail_x15_r0_body.S1306)
boot_rfl PRE_first_tail_x15_r0_body.k1306 from PRE_first_tail_x15_r0_body.s1306 to PRE_first_tail_x15_r0_body.s1307 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB386 ((nth? PRE_first_tail_x15_r0_body.ks 1306).getD 0) PRE_first_tail_x15_r0_body.s1306 PRE_first_tail_x15_r0_body.S1306 = some (PRE_first_tail_x15_r0_body.s1307, PRE_first_tail_x15_r0_body.S1307)
boot_rfl PRE_first_tail_x15_r0_body.stepA387 from PRE_first_tail_x15_r0_body.s1307 to PRE_first_tail_x15_r0_body.s1308 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1307).run PRE_first_tail_x15_r0_body.S1307 = some (PRE_first_tail_x15_r0_body.s1308, PRE_first_tail_x15_r0_body.S1308)
end Host.Load.Run.Tpl
