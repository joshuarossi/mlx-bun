import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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
boot_rfl PRE_first_tail_x15_r0_body.k950 from PRE_first_tail_x15_r0_body.s950 to PRE_first_tail_x15_r0_body.s951 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB256 ((nth? PRE_first_tail_x15_r0_body.ks 950).getD 0) PRE_first_tail_x15_r0_body.s950 PRE_first_tail_x15_r0_body.S950 = some (PRE_first_tail_x15_r0_body.s951, PRE_first_tail_x15_r0_body.S951)
boot_rfl PRE_first_tail_x15_r0_body.k951 from PRE_first_tail_x15_r0_body.s951 to PRE_first_tail_x15_r0_body.s952 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB256 ((nth? PRE_first_tail_x15_r0_body.ks 951).getD 0) PRE_first_tail_x15_r0_body.s951 PRE_first_tail_x15_r0_body.S951 = some (PRE_first_tail_x15_r0_body.s952, PRE_first_tail_x15_r0_body.S952)
end Host.Load.Run.Tpl
