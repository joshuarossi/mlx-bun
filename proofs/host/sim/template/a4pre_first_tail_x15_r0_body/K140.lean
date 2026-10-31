import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.patchB166 from PRE_first_tail_x15_r0_body.s560 to PRE_first_tail_x15_r0_body.s561 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s560).run PRE_first_tail_x15_r0_body.S560 = some (PRE_first_tail_x15_r0_body.s561, PRE_first_tail_x15_r0_body.S561)
boot_rfl PRE_first_tail_x15_r0_body.k561 from PRE_first_tail_x15_r0_body.s561 to PRE_first_tail_x15_r0_body.s562 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB166 ((nth? PRE_first_tail_x15_r0_body.ks 561).getD 0) PRE_first_tail_x15_r0_body.s561 PRE_first_tail_x15_r0_body.S561 = some (PRE_first_tail_x15_r0_body.s562, PRE_first_tail_x15_r0_body.S562)
boot_rfl PRE_first_tail_x15_r0_body.stepA167 from PRE_first_tail_x15_r0_body.s562 to PRE_first_tail_x15_r0_body.s563 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s562).run PRE_first_tail_x15_r0_body.S562 = some (PRE_first_tail_x15_r0_body.s563, PRE_first_tail_x15_r0_body.S563)
boot_rfl PRE_first_tail_x15_r0_body.patchB167 from PRE_first_tail_x15_r0_body.s563 to PRE_first_tail_x15_r0_body.s564 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s563).run PRE_first_tail_x15_r0_body.S563 = some (PRE_first_tail_x15_r0_body.s564, PRE_first_tail_x15_r0_body.S564)
end Host.Load.Run.Tpl
