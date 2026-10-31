import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.k917 from PRE_first_tail_x15_r0_body.s917 to PRE_first_tail_x15_r0_body.s918 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB271 ((nth? PRE_first_tail_x15_r0_body.ks 917).getD 0) PRE_first_tail_x15_r0_body.s917 PRE_first_tail_x15_r0_body.S917 = some (PRE_first_tail_x15_r0_body.s918, PRE_first_tail_x15_r0_body.S918)
boot_rfl PRE_first_tail_x15_r0_body.stepA272 from PRE_first_tail_x15_r0_body.s918 to PRE_first_tail_x15_r0_body.s919 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s918).run PRE_first_tail_x15_r0_body.S918 = some (PRE_first_tail_x15_r0_body.s919, PRE_first_tail_x15_r0_body.S919)
end Host.Load.Run.Tpl
