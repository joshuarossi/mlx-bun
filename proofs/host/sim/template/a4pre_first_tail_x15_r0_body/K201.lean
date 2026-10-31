import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.k805 from PRE_first_tail_x15_r0_body.s805 to PRE_first_tail_x15_r0_body.s806 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB238 ((nth? PRE_first_tail_x15_r0_body.ks 805).getD 0) PRE_first_tail_x15_r0_body.s805 PRE_first_tail_x15_r0_body.S805 = some (PRE_first_tail_x15_r0_body.s806, PRE_first_tail_x15_r0_body.S806)
boot_rfl PRE_first_tail_x15_r0_body.stepA239 from PRE_first_tail_x15_r0_body.s806 to PRE_first_tail_x15_r0_body.s807 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s806).run PRE_first_tail_x15_r0_body.S806 = some (PRE_first_tail_x15_r0_body.s807, PRE_first_tail_x15_r0_body.S807)
boot_rfl PRE_first_tail_x15_r0_body.patchB239 from PRE_first_tail_x15_r0_body.s807 to PRE_first_tail_x15_r0_body.s808 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s807).run PRE_first_tail_x15_r0_body.S807 = some (PRE_first_tail_x15_r0_body.s808, PRE_first_tail_x15_r0_body.S808)
end Host.Load.Run.Tpl
