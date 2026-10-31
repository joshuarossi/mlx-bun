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
boot_rfl PRE_first_tail_x15_r0_body.k560 from PRE_first_tail_x15_r0_body.s560 to PRE_first_tail_x15_r0_body.s561 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB151 ((nth? PRE_first_tail_x15_r0_body.ks 560).getD 0) PRE_first_tail_x15_r0_body.s560 PRE_first_tail_x15_r0_body.S560 = some (PRE_first_tail_x15_r0_body.s561, PRE_first_tail_x15_r0_body.S561)
boot_rfl PRE_first_tail_x15_r0_body.stepA152 from PRE_first_tail_x15_r0_body.s561 to PRE_first_tail_x15_r0_body.s562 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s561).run PRE_first_tail_x15_r0_body.S561 = some (PRE_first_tail_x15_r0_body.s562, PRE_first_tail_x15_r0_body.S562)
end Host.Load.Run.Tpl
