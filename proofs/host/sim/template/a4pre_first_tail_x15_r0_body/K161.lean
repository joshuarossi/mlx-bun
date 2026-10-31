import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.k646 from PRE_first_tail_x15_r0_body.s646 to PRE_first_tail_x15_r0_body.s647 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB191 ((nth? PRE_first_tail_x15_r0_body.ks 646).getD 0) PRE_first_tail_x15_r0_body.s646 PRE_first_tail_x15_r0_body.S646 = some (PRE_first_tail_x15_r0_body.s647, PRE_first_tail_x15_r0_body.S647)
boot_rfl PRE_first_tail_x15_r0_body.stepA192 from PRE_first_tail_x15_r0_body.s647 to PRE_first_tail_x15_r0_body.s648 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s647).run PRE_first_tail_x15_r0_body.S647 = some (PRE_first_tail_x15_r0_body.s648, PRE_first_tail_x15_r0_body.S648)
end Host.Load.Run.Tpl
