import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.stepA216 from PRE_first_tail_x15_r0_body.s728 to PRE_first_tail_x15_r0_body.s729 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s728).run PRE_first_tail_x15_r0_body.S728 = some (PRE_first_tail_x15_r0_body.s729, PRE_first_tail_x15_r0_body.S729)
boot_rfl PRE_first_tail_x15_r0_body.k731 from PRE_first_tail_x15_r0_body.s731 to PRE_first_tail_x15_r0_body.s732 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB216 ((nth? PRE_first_tail_x15_r0_body.ks 731).getD 0) PRE_first_tail_x15_r0_body.s731 PRE_first_tail_x15_r0_body.S731 = some (PRE_first_tail_x15_r0_body.s732, PRE_first_tail_x15_r0_body.S732)
end Host.Load.Run.Tpl
