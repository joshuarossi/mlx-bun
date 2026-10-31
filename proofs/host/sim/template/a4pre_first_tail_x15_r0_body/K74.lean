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
boot_rfl PRE_first_tail_x15_r0_body.k296 from PRE_first_tail_x15_r0_body.s296 to PRE_first_tail_x15_r0_body.s297 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB80 ((nth? PRE_first_tail_x15_r0_body.ks 296).getD 0) PRE_first_tail_x15_r0_body.s296 PRE_first_tail_x15_r0_body.S296 = some (PRE_first_tail_x15_r0_body.s297, PRE_first_tail_x15_r0_body.S297)
boot_rfl PRE_first_tail_x15_r0_body.stepA81 from PRE_first_tail_x15_r0_body.s297 to PRE_first_tail_x15_r0_body.s298 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s297).run PRE_first_tail_x15_r0_body.S297 = some (PRE_first_tail_x15_r0_body.s298, PRE_first_tail_x15_r0_body.S298)
boot_rfl PRE_first_tail_x15_r0_body.patchB81 from PRE_first_tail_x15_r0_body.s298 to PRE_first_tail_x15_r0_body.s299 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s298).run PRE_first_tail_x15_r0_body.S298 = some (PRE_first_tail_x15_r0_body.s299, PRE_first_tail_x15_r0_body.S299)
boot_rfl PRE_first_tail_x15_r0_body.k299 from PRE_first_tail_x15_r0_body.s299 to PRE_first_tail_x15_r0_body.s300 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB81 ((nth? PRE_first_tail_x15_r0_body.ks 299).getD 0) PRE_first_tail_x15_r0_body.s299 PRE_first_tail_x15_r0_body.S299 = some (PRE_first_tail_x15_r0_body.s300, PRE_first_tail_x15_r0_body.S300)
end Host.Load.Run.Tpl
