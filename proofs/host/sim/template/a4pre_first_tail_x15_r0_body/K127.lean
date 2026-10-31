import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.stepA151 from PRE_first_tail_x15_r0_body.s508 to PRE_first_tail_x15_r0_body.s509 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s508).run PRE_first_tail_x15_r0_body.S508 = some (PRE_first_tail_x15_r0_body.s509, PRE_first_tail_x15_r0_body.S509)
boot_rfl PRE_first_tail_x15_r0_body.patchB151 from PRE_first_tail_x15_r0_body.s509 to PRE_first_tail_x15_r0_body.s510 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s509).run PRE_first_tail_x15_r0_body.S509 = some (PRE_first_tail_x15_r0_body.s510, PRE_first_tail_x15_r0_body.S510)
boot_rfl PRE_first_tail_x15_r0_body.k510 from PRE_first_tail_x15_r0_body.s510 to PRE_first_tail_x15_r0_body.s511 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB151 ((nth? PRE_first_tail_x15_r0_body.ks 510).getD 0) PRE_first_tail_x15_r0_body.s510 PRE_first_tail_x15_r0_body.S510 = some (PRE_first_tail_x15_r0_body.s511, PRE_first_tail_x15_r0_body.S511)
boot_rfl PRE_first_tail_x15_r0_body.stepA152 from PRE_first_tail_x15_r0_body.s511 to PRE_first_tail_x15_r0_body.s512 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s511).run PRE_first_tail_x15_r0_body.S511 = some (PRE_first_tail_x15_r0_body.s512, PRE_first_tail_x15_r0_body.S512)
end Host.Load.Run.Tpl
