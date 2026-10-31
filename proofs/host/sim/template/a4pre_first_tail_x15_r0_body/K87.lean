import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.stepA94 from PRE_first_tail_x15_r0_body.s348 to PRE_first_tail_x15_r0_body.s349 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s348).run PRE_first_tail_x15_r0_body.S348 = some (PRE_first_tail_x15_r0_body.s349, PRE_first_tail_x15_r0_body.S349)
boot_rfl PRE_first_tail_x15_r0_body.patchB94 from PRE_first_tail_x15_r0_body.s349 to PRE_first_tail_x15_r0_body.s350 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s349).run PRE_first_tail_x15_r0_body.S349 = some (PRE_first_tail_x15_r0_body.s350, PRE_first_tail_x15_r0_body.S350)
boot_rfl PRE_first_tail_x15_r0_body.k350 from PRE_first_tail_x15_r0_body.s350 to PRE_first_tail_x15_r0_body.s351 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB94 ((nth? PRE_first_tail_x15_r0_body.ks 350).getD 0) PRE_first_tail_x15_r0_body.s350 PRE_first_tail_x15_r0_body.S350 = some (PRE_first_tail_x15_r0_body.s351, PRE_first_tail_x15_r0_body.S351)
boot_rfl PRE_first_tail_x15_r0_body.stepA95 from PRE_first_tail_x15_r0_body.s351 to PRE_first_tail_x15_r0_body.s352 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s351).run PRE_first_tail_x15_r0_body.S351 = some (PRE_first_tail_x15_r0_body.s352, PRE_first_tail_x15_r0_body.S352)
end Host.Load.Run.Tpl
