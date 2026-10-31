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
boot_rfl PRE_first_tail_x15_r0_body.patchB437 from PRE_first_tail_x15_r0_body.s1620 to PRE_first_tail_x15_r0_body.s1621 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1620).run PRE_first_tail_x15_r0_body.S1620 = some (PRE_first_tail_x15_r0_body.s1621, PRE_first_tail_x15_r0_body.S1621)
boot_rfl PRE_first_tail_x15_r0_body.k1621 from PRE_first_tail_x15_r0_body.s1621 to PRE_first_tail_x15_r0_body.s1622 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB437 ((nth? PRE_first_tail_x15_r0_body.ks 1621).getD 0) PRE_first_tail_x15_r0_body.s1621 PRE_first_tail_x15_r0_body.S1621 = some (PRE_first_tail_x15_r0_body.s1622, PRE_first_tail_x15_r0_body.S1622)
boot_rfl PRE_first_tail_x15_r0_body.stepA438 from PRE_first_tail_x15_r0_body.s1622 to PRE_first_tail_x15_r0_body.s1623 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1622).run PRE_first_tail_x15_r0_body.S1622 = some (PRE_first_tail_x15_r0_body.s1623, PRE_first_tail_x15_r0_body.S1623)
boot_rfl PRE_first_tail_x15_r0_body.patchB438 from PRE_first_tail_x15_r0_body.s1623 to PRE_first_tail_x15_r0_body.s1624 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1623).run PRE_first_tail_x15_r0_body.S1623 = some (PRE_first_tail_x15_r0_body.s1624, PRE_first_tail_x15_r0_body.S1624)
end Host.Load.Run.Tpl
