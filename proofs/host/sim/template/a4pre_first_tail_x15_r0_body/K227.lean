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
boot_rfl PRE_first_tail_x15_r0_body.k910 from PRE_first_tail_x15_r0_body.s910 to PRE_first_tail_x15_r0_body.s911 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB269 ((nth? PRE_first_tail_x15_r0_body.ks 910).getD 0) PRE_first_tail_x15_r0_body.s910 PRE_first_tail_x15_r0_body.S910 = some (PRE_first_tail_x15_r0_body.s911, PRE_first_tail_x15_r0_body.S911)
boot_rfl PRE_first_tail_x15_r0_body.stepA270 from PRE_first_tail_x15_r0_body.s911 to PRE_first_tail_x15_r0_body.s912 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s911).run PRE_first_tail_x15_r0_body.S911 = some (PRE_first_tail_x15_r0_body.s912, PRE_first_tail_x15_r0_body.S912)
end Host.Load.Run.Tpl
