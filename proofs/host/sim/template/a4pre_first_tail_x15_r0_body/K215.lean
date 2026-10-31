import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.k860 from PRE_first_tail_x15_r0_body.s860 to PRE_first_tail_x15_r0_body.s861 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB232 ((nth? PRE_first_tail_x15_r0_body.ks 860).getD 0) PRE_first_tail_x15_r0_body.s860 PRE_first_tail_x15_r0_body.S860 = some (PRE_first_tail_x15_r0_body.s861, PRE_first_tail_x15_r0_body.S861)
boot_rfl PRE_first_tail_x15_r0_body.stepA233 from PRE_first_tail_x15_r0_body.s861 to PRE_first_tail_x15_r0_body.s862 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s861).run PRE_first_tail_x15_r0_body.S861 = some (PRE_first_tail_x15_r0_body.s862, PRE_first_tail_x15_r0_body.S862)
end Host.Load.Run.Tpl
