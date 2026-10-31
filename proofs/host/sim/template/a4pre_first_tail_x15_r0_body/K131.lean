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
boot_rfl PRE_first_tail_x15_r0_body.k525 from PRE_first_tail_x15_r0_body.s525 to PRE_first_tail_x15_r0_body.s526 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB155 ((nth? PRE_first_tail_x15_r0_body.ks 525).getD 0) PRE_first_tail_x15_r0_body.s525 PRE_first_tail_x15_r0_body.S525 = some (PRE_first_tail_x15_r0_body.s526, PRE_first_tail_x15_r0_body.S526)
boot_rfl PRE_first_tail_x15_r0_body.stepA156 from PRE_first_tail_x15_r0_body.s526 to PRE_first_tail_x15_r0_body.s527 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s526).run PRE_first_tail_x15_r0_body.S526 = some (PRE_first_tail_x15_r0_body.s527, PRE_first_tail_x15_r0_body.S527)
boot_rfl PRE_first_tail_x15_r0_body.patchB156 from PRE_first_tail_x15_r0_body.s527 to PRE_first_tail_x15_r0_body.s528 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s527).run PRE_first_tail_x15_r0_body.S527 = some (PRE_first_tail_x15_r0_body.s528, PRE_first_tail_x15_r0_body.S528)
end Host.Load.Run.Tpl
