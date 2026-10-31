import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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
boot_rfl PRE_first_tail_x15_r0_body.patchB68 from PRE_first_tail_x15_r0_body.s228 to PRE_first_tail_x15_r0_body.s229 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s228).run PRE_first_tail_x15_r0_body.S228 = some (PRE_first_tail_x15_r0_body.s229, PRE_first_tail_x15_r0_body.S229)
boot_rfl PRE_first_tail_x15_r0_body.k229 from PRE_first_tail_x15_r0_body.s229 to PRE_first_tail_x15_r0_body.s230 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB68 ((nth? PRE_first_tail_x15_r0_body.ks 229).getD 0) PRE_first_tail_x15_r0_body.s229 PRE_first_tail_x15_r0_body.S229 = some (PRE_first_tail_x15_r0_body.s230, PRE_first_tail_x15_r0_body.S230)
boot_rfl PRE_first_tail_x15_r0_body.stepA69 from PRE_first_tail_x15_r0_body.s230 to PRE_first_tail_x15_r0_body.s231 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s230).run PRE_first_tail_x15_r0_body.S230 = some (PRE_first_tail_x15_r0_body.s231, PRE_first_tail_x15_r0_body.S231)
end Host.Load.Run.Tpl
