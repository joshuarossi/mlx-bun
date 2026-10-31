import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.patchB127 from PRE_first_tail_x15_r0_body.s428 to PRE_first_tail_x15_r0_body.s429 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s428).run PRE_first_tail_x15_r0_body.S428 = some (PRE_first_tail_x15_r0_body.s429, PRE_first_tail_x15_r0_body.S429)
boot_rfl PRE_first_tail_x15_r0_body.k429 from PRE_first_tail_x15_r0_body.s429 to PRE_first_tail_x15_r0_body.s430 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB127 ((nth? PRE_first_tail_x15_r0_body.ks 429).getD 0) PRE_first_tail_x15_r0_body.s429 PRE_first_tail_x15_r0_body.S429 = some (PRE_first_tail_x15_r0_body.s430, PRE_first_tail_x15_r0_body.S430)
boot_rfl PRE_first_tail_x15_r0_body.stepA128 from PRE_first_tail_x15_r0_body.s430 to PRE_first_tail_x15_r0_body.s431 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s430).run PRE_first_tail_x15_r0_body.S430 = some (PRE_first_tail_x15_r0_body.s431, PRE_first_tail_x15_r0_body.S431)
boot_rfl PRE_first_tail_x15_r0_body.patchB128 from PRE_first_tail_x15_r0_body.s431 to PRE_first_tail_x15_r0_body.s432 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s431).run PRE_first_tail_x15_r0_body.S431 = some (PRE_first_tail_x15_r0_body.s432, PRE_first_tail_x15_r0_body.S432)
end Host.Load.Run.Tpl
