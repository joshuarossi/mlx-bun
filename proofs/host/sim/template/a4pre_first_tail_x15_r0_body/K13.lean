import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.k54 from PRE_first_tail_x15_r0_body.s54 to PRE_first_tail_x15_r0_body.s55 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB16 ((nth? PRE_first_tail_x15_r0_body.ks 54).getD 0) PRE_first_tail_x15_r0_body.s54 PRE_first_tail_x15_r0_body.S54 = some (PRE_first_tail_x15_r0_body.s55, PRE_first_tail_x15_r0_body.S55)
boot_rfl PRE_first_tail_x15_r0_body.stepA17 from PRE_first_tail_x15_r0_body.s55 to PRE_first_tail_x15_r0_body.s56 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s55).run PRE_first_tail_x15_r0_body.S55 = some (PRE_first_tail_x15_r0_body.s56, PRE_first_tail_x15_r0_body.S56)
end Host.Load.Run.Tpl
