import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.stepA296 from PRE_first_tail_x15_r0_body.s1000 to PRE_first_tail_x15_r0_body.s1001 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1000).run PRE_first_tail_x15_r0_body.S1000 = some (PRE_first_tail_x15_r0_body.s1001, PRE_first_tail_x15_r0_body.S1001)
boot_rfl PRE_first_tail_x15_r0_body.patchB296 from PRE_first_tail_x15_r0_body.s1001 to PRE_first_tail_x15_r0_body.s1002 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001).run PRE_first_tail_x15_r0_body.S1001 = some (PRE_first_tail_x15_r0_body.s1002, PRE_first_tail_x15_r0_body.S1002)
boot_rfl PRE_first_tail_x15_r0_body.k1002 from PRE_first_tail_x15_r0_body.s1002 to PRE_first_tail_x15_r0_body.s1003 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB296 ((nth? PRE_first_tail_x15_r0_body.ks 1002).getD 0) PRE_first_tail_x15_r0_body.s1002 PRE_first_tail_x15_r0_body.S1002 = some (PRE_first_tail_x15_r0_body.s1003, PRE_first_tail_x15_r0_body.S1003)
boot_rfl PRE_first_tail_x15_r0_body.stepA297 from PRE_first_tail_x15_r0_body.s1003 to PRE_first_tail_x15_r0_body.s1004 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1003).run PRE_first_tail_x15_r0_body.S1003 = some (PRE_first_tail_x15_r0_body.s1004, PRE_first_tail_x15_r0_body.S1004)
end Host.Load.Run.Tpl
