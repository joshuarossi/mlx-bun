import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.k388 from PRE_first_tail_x15_r0_body.s388 to PRE_first_tail_x15_r0_body.s389 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB115 ((nth? PRE_first_tail_x15_r0_body.ks 388).getD 0) PRE_first_tail_x15_r0_body.s388 PRE_first_tail_x15_r0_body.S388 = some (PRE_first_tail_x15_r0_body.s389, PRE_first_tail_x15_r0_body.S389)
boot_rfl PRE_first_tail_x15_r0_body.stepA116 from PRE_first_tail_x15_r0_body.s389 to PRE_first_tail_x15_r0_body.s390 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s389).run PRE_first_tail_x15_r0_body.S389 = some (PRE_first_tail_x15_r0_body.s390, PRE_first_tail_x15_r0_body.S390)
end Host.Load.Run.Tpl
