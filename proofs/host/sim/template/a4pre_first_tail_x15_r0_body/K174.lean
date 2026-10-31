import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.k696 from PRE_first_tail_x15_r0_body.s696 to PRE_first_tail_x15_r0_body.s697 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB206 ((nth? PRE_first_tail_x15_r0_body.ks 696).getD 0) PRE_first_tail_x15_r0_body.s696 PRE_first_tail_x15_r0_body.S696 = some (PRE_first_tail_x15_r0_body.s697, PRE_first_tail_x15_r0_body.S697)
boot_rfl PRE_first_tail_x15_r0_body.stepA207 from PRE_first_tail_x15_r0_body.s697 to PRE_first_tail_x15_r0_body.s698 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s697).run PRE_first_tail_x15_r0_body.S697 = some (PRE_first_tail_x15_r0_body.s698, PRE_first_tail_x15_r0_body.S698)
end Host.Load.Run.Tpl
