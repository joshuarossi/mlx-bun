import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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
boot_rfl PRE_first_tail_x15_r0_body.k12 from PRE_first_tail_x15_r0_body.s12 to PRE_first_tail_x15_r0_body.s13 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB4 ((nth? PRE_first_tail_x15_r0_body.ks 12).getD 0) PRE_first_tail_x15_r0_body.s12 PRE_first_tail_x15_r0_body.S12 = some (PRE_first_tail_x15_r0_body.s13, PRE_first_tail_x15_r0_body.S13)
boot_rfl PRE_first_tail_x15_r0_body.stepA5 from PRE_first_tail_x15_r0_body.s13 to PRE_first_tail_x15_r0_body.s14 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s13).run PRE_first_tail_x15_r0_body.S13 = some (PRE_first_tail_x15_r0_body.s14, PRE_first_tail_x15_r0_body.S14)
end Host.Load.Run.Tpl
