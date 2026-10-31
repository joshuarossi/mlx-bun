import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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
boot_rfl PRE_first_tail_x15_r0_body.stepA432 from PRE_first_tail_x15_r0_body.s1600 to PRE_first_tail_x15_r0_body.s1601 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1600).run PRE_first_tail_x15_r0_body.S1600 = some (PRE_first_tail_x15_r0_body.s1601, PRE_first_tail_x15_r0_body.S1601)
boot_rfl PRE_first_tail_x15_r0_body.patchB432 from PRE_first_tail_x15_r0_body.s1601 to PRE_first_tail_x15_r0_body.s1602 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1601).run PRE_first_tail_x15_r0_body.S1601 = some (PRE_first_tail_x15_r0_body.s1602, PRE_first_tail_x15_r0_body.S1602)
boot_rfl PRE_first_tail_x15_r0_body.k1602 from PRE_first_tail_x15_r0_body.s1602 to PRE_first_tail_x15_r0_body.s1603 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB432 ((nth? PRE_first_tail_x15_r0_body.ks 1602).getD 0) PRE_first_tail_x15_r0_body.s1602 PRE_first_tail_x15_r0_body.S1602 = some (PRE_first_tail_x15_r0_body.s1603, PRE_first_tail_x15_r0_body.S1603)
boot_rfl PRE_first_tail_x15_r0_body.k1603 from PRE_first_tail_x15_r0_body.s1603 to PRE_first_tail_x15_r0_body.s1604 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB432 ((nth? PRE_first_tail_x15_r0_body.ks 1603).getD 0) PRE_first_tail_x15_r0_body.s1603 PRE_first_tail_x15_r0_body.S1603 = some (PRE_first_tail_x15_r0_body.s1604, PRE_first_tail_x15_r0_body.S1604)
end Host.Load.Run.Tpl
