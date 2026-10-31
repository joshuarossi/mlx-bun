import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.stepA34 from PRE_first_tail_x15_r0_body.s124 to PRE_first_tail_x15_r0_body.s125 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s124).run PRE_first_tail_x15_r0_body.S124 = some (PRE_first_tail_x15_r0_body.s125, PRE_first_tail_x15_r0_body.S125)
boot_rfl PRE_first_tail_x15_r0_body.patchB34 from PRE_first_tail_x15_r0_body.s125 to PRE_first_tail_x15_r0_body.s126 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s125).run PRE_first_tail_x15_r0_body.S125 = some (PRE_first_tail_x15_r0_body.s126, PRE_first_tail_x15_r0_body.S126)
boot_rfl PRE_first_tail_x15_r0_body.k126 from PRE_first_tail_x15_r0_body.s126 to PRE_first_tail_x15_r0_body.s127 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB34 ((nth? PRE_first_tail_x15_r0_body.ks 126).getD 0) PRE_first_tail_x15_r0_body.s126 PRE_first_tail_x15_r0_body.S126 = some (PRE_first_tail_x15_r0_body.s127, PRE_first_tail_x15_r0_body.S127)
boot_rfl PRE_first_tail_x15_r0_body.stepA35 from PRE_first_tail_x15_r0_body.s127 to PRE_first_tail_x15_r0_body.s128 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s127).run PRE_first_tail_x15_r0_body.S127 = some (PRE_first_tail_x15_r0_body.s128, PRE_first_tail_x15_r0_body.S128)
end Host.Load.Run.Tpl
