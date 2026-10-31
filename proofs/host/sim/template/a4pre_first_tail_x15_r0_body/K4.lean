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
boot_rfl PRE_first_tail_x15_r0_body.k17 from PRE_first_tail_x15_r0_body.s17 to PRE_first_tail_x15_r0_body.s18 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB5 ((nth? PRE_first_tail_x15_r0_body.ks 17).getD 0) PRE_first_tail_x15_r0_body.s17 PRE_first_tail_x15_r0_body.S17 = some (PRE_first_tail_x15_r0_body.s18, PRE_first_tail_x15_r0_body.S18)
boot_rfl PRE_first_tail_x15_r0_body.k18 from PRE_first_tail_x15_r0_body.s18 to PRE_first_tail_x15_r0_body.s19 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB5 ((nth? PRE_first_tail_x15_r0_body.ks 18).getD 0) PRE_first_tail_x15_r0_body.s18 PRE_first_tail_x15_r0_body.S18 = some (PRE_first_tail_x15_r0_body.s19, PRE_first_tail_x15_r0_body.S19)
boot_rfl PRE_first_tail_x15_r0_body.stepA6 from PRE_first_tail_x15_r0_body.s19 to PRE_first_tail_x15_r0_body.s20 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s19).run PRE_first_tail_x15_r0_body.S19 = some (PRE_first_tail_x15_r0_body.s20, PRE_first_tail_x15_r0_body.S20)
end Host.Load.Run.Tpl
