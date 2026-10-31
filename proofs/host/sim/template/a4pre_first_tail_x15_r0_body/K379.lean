import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.k1516 from PRE_first_tail_x15_r0_body.s1516 to PRE_first_tail_x15_r0_body.s1517 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB409 ((nth? PRE_first_tail_x15_r0_body.ks 1516).getD 0) PRE_first_tail_x15_r0_body.s1516 PRE_first_tail_x15_r0_body.S1516 = some (PRE_first_tail_x15_r0_body.s1517, PRE_first_tail_x15_r0_body.S1517)
boot_rfl PRE_first_tail_x15_r0_body.k1517 from PRE_first_tail_x15_r0_body.s1517 to PRE_first_tail_x15_r0_body.s1518 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB409 ((nth? PRE_first_tail_x15_r0_body.ks 1517).getD 0) PRE_first_tail_x15_r0_body.s1517 PRE_first_tail_x15_r0_body.S1517 = some (PRE_first_tail_x15_r0_body.s1518, PRE_first_tail_x15_r0_body.S1518)
boot_rfl PRE_first_tail_x15_r0_body.stepA410 from PRE_first_tail_x15_r0_body.s1518 to PRE_first_tail_x15_r0_body.s1519 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1518).run PRE_first_tail_x15_r0_body.S1518 = some (PRE_first_tail_x15_r0_body.s1519, PRE_first_tail_x15_r0_body.S1519)
end Host.Load.Run.Tpl
