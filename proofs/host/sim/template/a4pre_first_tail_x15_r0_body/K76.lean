import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.k304 from PRE_first_tail_x15_r0_body.s304 to PRE_first_tail_x15_r0_body.s305 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB90 ((nth? PRE_first_tail_x15_r0_body.ks 304).getD 0) PRE_first_tail_x15_r0_body.s304 PRE_first_tail_x15_r0_body.S304 = some (PRE_first_tail_x15_r0_body.s305, PRE_first_tail_x15_r0_body.S305)
boot_rfl PRE_first_tail_x15_r0_body.stepA91 from PRE_first_tail_x15_r0_body.s305 to PRE_first_tail_x15_r0_body.s306 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s305).run PRE_first_tail_x15_r0_body.S305 = some (PRE_first_tail_x15_r0_body.s306, PRE_first_tail_x15_r0_body.S306)
boot_rfl PRE_first_tail_x15_r0_body.patchB91 from PRE_first_tail_x15_r0_body.s306 to PRE_first_tail_x15_r0_body.s307 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s306).run PRE_first_tail_x15_r0_body.S306 = some (PRE_first_tail_x15_r0_body.s307, PRE_first_tail_x15_r0_body.S307)
boot_rfl PRE_first_tail_x15_r0_body.k307 from PRE_first_tail_x15_r0_body.s307 to PRE_first_tail_x15_r0_body.s308 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB91 ((nth? PRE_first_tail_x15_r0_body.ks 307).getD 0) PRE_first_tail_x15_r0_body.s307 PRE_first_tail_x15_r0_body.S307 = some (PRE_first_tail_x15_r0_body.s308, PRE_first_tail_x15_r0_body.S308)
end Host.Load.Run.Tpl
