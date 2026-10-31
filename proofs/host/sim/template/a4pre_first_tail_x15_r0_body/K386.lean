import host.sim.template.a4pre_first_tail_x15_r0_body.H48
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
boot_rfl PRE_first_tail_x15_r0_body.patchB417 from PRE_first_tail_x15_r0_body.s1544 to PRE_first_tail_x15_r0_body.s1545 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1544).run PRE_first_tail_x15_r0_body.S1544 = some (PRE_first_tail_x15_r0_body.s1545, PRE_first_tail_x15_r0_body.S1545)
boot_rfl PRE_first_tail_x15_r0_body.k1545 from PRE_first_tail_x15_r0_body.s1545 to PRE_first_tail_x15_r0_body.s1546 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB417 ((nth? PRE_first_tail_x15_r0_body.ks 1545).getD 0) PRE_first_tail_x15_r0_body.s1545 PRE_first_tail_x15_r0_body.S1545 = some (PRE_first_tail_x15_r0_body.s1546, PRE_first_tail_x15_r0_body.S1546)
boot_rfl PRE_first_tail_x15_r0_body.k1546 from PRE_first_tail_x15_r0_body.s1546 to PRE_first_tail_x15_r0_body.s1547 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB417 ((nth? PRE_first_tail_x15_r0_body.ks 1546).getD 0) PRE_first_tail_x15_r0_body.s1546 PRE_first_tail_x15_r0_body.S1546 = some (PRE_first_tail_x15_r0_body.s1547, PRE_first_tail_x15_r0_body.S1547)
boot_rfl PRE_first_tail_x15_r0_body.stepA418 from PRE_first_tail_x15_r0_body.s1547 to PRE_first_tail_x15_r0_body.s1548 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1547).run PRE_first_tail_x15_r0_body.S1547 = some (PRE_first_tail_x15_r0_body.s1548, PRE_first_tail_x15_r0_body.S1548)
end Host.Load.Run.Tpl
