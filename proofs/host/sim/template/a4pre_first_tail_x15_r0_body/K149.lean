import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.stepA177 from PRE_first_tail_x15_r0_body.s596 to PRE_first_tail_x15_r0_body.s597 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s596).run PRE_first_tail_x15_r0_body.S596 = some (PRE_first_tail_x15_r0_body.s597, PRE_first_tail_x15_r0_body.S597)
boot_rfl PRE_first_tail_x15_r0_body.patchB177 from PRE_first_tail_x15_r0_body.s597 to PRE_first_tail_x15_r0_body.s598 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s597).run PRE_first_tail_x15_r0_body.S597 = some (PRE_first_tail_x15_r0_body.s598, PRE_first_tail_x15_r0_body.S598)
boot_rfl PRE_first_tail_x15_r0_body.k598 from PRE_first_tail_x15_r0_body.s598 to PRE_first_tail_x15_r0_body.s599 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB177 ((nth? PRE_first_tail_x15_r0_body.ks 598).getD 0) PRE_first_tail_x15_r0_body.s598 PRE_first_tail_x15_r0_body.S598 = some (PRE_first_tail_x15_r0_body.s599, PRE_first_tail_x15_r0_body.S599)
boot_rfl PRE_first_tail_x15_r0_body.stepA178 from PRE_first_tail_x15_r0_body.s599 to PRE_first_tail_x15_r0_body.s600 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s599).run PRE_first_tail_x15_r0_body.S599 = some (PRE_first_tail_x15_r0_body.s600, PRE_first_tail_x15_r0_body.S600)
end Host.Load.Run.Tpl
