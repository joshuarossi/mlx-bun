import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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
boot_rfl PRE_first_tail_x15_r0_body.k1440 from PRE_first_tail_x15_r0_body.s1440 to PRE_first_tail_x15_r0_body.s1441 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB388 ((nth? PRE_first_tail_x15_r0_body.ks 1440).getD 0) PRE_first_tail_x15_r0_body.s1440 PRE_first_tail_x15_r0_body.S1440 = some (PRE_first_tail_x15_r0_body.s1441, PRE_first_tail_x15_r0_body.S1441)
boot_rfl PRE_first_tail_x15_r0_body.stepA389 from PRE_first_tail_x15_r0_body.s1441 to PRE_first_tail_x15_r0_body.s1442 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1441).run PRE_first_tail_x15_r0_body.S1441 = some (PRE_first_tail_x15_r0_body.s1442, PRE_first_tail_x15_r0_body.S1442)
boot_rfl PRE_first_tail_x15_r0_body.patchB389 from PRE_first_tail_x15_r0_body.s1442 to PRE_first_tail_x15_r0_body.s1443 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1442).run PRE_first_tail_x15_r0_body.S1442 = some (PRE_first_tail_x15_r0_body.s1443, PRE_first_tail_x15_r0_body.S1443)
boot_rfl PRE_first_tail_x15_r0_body.k1443 from PRE_first_tail_x15_r0_body.s1443 to PRE_first_tail_x15_r0_body.s1444 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB389 ((nth? PRE_first_tail_x15_r0_body.ks 1443).getD 0) PRE_first_tail_x15_r0_body.s1443 PRE_first_tail_x15_r0_body.S1443 = some (PRE_first_tail_x15_r0_body.s1444, PRE_first_tail_x15_r0_body.S1444)
end Host.Load.Run.Tpl
