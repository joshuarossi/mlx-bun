import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.k300 from PRE_first_tail_x15_r0_body.s300 to PRE_first_tail_x15_r0_body.s301 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB89 ((nth? PRE_first_tail_x15_r0_body.ks 300).getD 0) PRE_first_tail_x15_r0_body.s300 PRE_first_tail_x15_r0_body.S300 = some (PRE_first_tail_x15_r0_body.s301, PRE_first_tail_x15_r0_body.S301)
boot_rfl PRE_first_tail_x15_r0_body.stepA90 from PRE_first_tail_x15_r0_body.s301 to PRE_first_tail_x15_r0_body.s302 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s301).run PRE_first_tail_x15_r0_body.S301 = some (PRE_first_tail_x15_r0_body.s302, PRE_first_tail_x15_r0_body.S302)
end Host.Load.Run.Tpl
