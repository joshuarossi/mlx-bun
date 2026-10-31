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
boot_rfl PRE_first_tail_x15_r0_body.k240 from PRE_first_tail_x15_r0_body.s240 to PRE_first_tail_x15_r0_body.s241 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB71 ((nth? PRE_first_tail_x15_r0_body.ks 240).getD 0) PRE_first_tail_x15_r0_body.s240 PRE_first_tail_x15_r0_body.S240 = some (PRE_first_tail_x15_r0_body.s241, PRE_first_tail_x15_r0_body.S241)
boot_rfl PRE_first_tail_x15_r0_body.stepA72 from PRE_first_tail_x15_r0_body.s241 to PRE_first_tail_x15_r0_body.s242 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s241).run PRE_first_tail_x15_r0_body.S241 = some (PRE_first_tail_x15_r0_body.s242, PRE_first_tail_x15_r0_body.S242)
boot_rfl PRE_first_tail_x15_r0_body.patchB72 from PRE_first_tail_x15_r0_body.s242 to PRE_first_tail_x15_r0_body.s243 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s242).run PRE_first_tail_x15_r0_body.S242 = some (PRE_first_tail_x15_r0_body.s243, PRE_first_tail_x15_r0_body.S243)
boot_rfl PRE_first_tail_x15_r0_body.k243 from PRE_first_tail_x15_r0_body.s243 to PRE_first_tail_x15_r0_body.s244 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB72 ((nth? PRE_first_tail_x15_r0_body.ks 243).getD 0) PRE_first_tail_x15_r0_body.s243 PRE_first_tail_x15_r0_body.S243 = some (PRE_first_tail_x15_r0_body.s244, PRE_first_tail_x15_r0_body.S244)
end Host.Load.Run.Tpl
