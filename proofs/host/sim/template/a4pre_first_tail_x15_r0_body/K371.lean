import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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
boot_rfl PRE_first_tail_x15_r0_body.k1484 from PRE_first_tail_x15_r0_body.s1484 to PRE_first_tail_x15_r0_body.s1485 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB400 ((nth? PRE_first_tail_x15_r0_body.ks 1484).getD 0) PRE_first_tail_x15_r0_body.s1484 PRE_first_tail_x15_r0_body.S1484 = some (PRE_first_tail_x15_r0_body.s1485, PRE_first_tail_x15_r0_body.S1485)
boot_rfl PRE_first_tail_x15_r0_body.stepA401 from PRE_first_tail_x15_r0_body.s1485 to PRE_first_tail_x15_r0_body.s1486 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1485).run PRE_first_tail_x15_r0_body.S1485 = some (PRE_first_tail_x15_r0_body.s1486, PRE_first_tail_x15_r0_body.S1486)
boot_rfl PRE_first_tail_x15_r0_body.patchB401 from PRE_first_tail_x15_r0_body.s1486 to PRE_first_tail_x15_r0_body.s1487 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1486).run PRE_first_tail_x15_r0_body.S1486 = some (PRE_first_tail_x15_r0_body.s1487, PRE_first_tail_x15_r0_body.S1487)
boot_rfl PRE_first_tail_x15_r0_body.k1487 from PRE_first_tail_x15_r0_body.s1487 to PRE_first_tail_x15_r0_body.s1488 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB401 ((nth? PRE_first_tail_x15_r0_body.ks 1487).getD 0) PRE_first_tail_x15_r0_body.s1487 PRE_first_tail_x15_r0_body.S1487 = some (PRE_first_tail_x15_r0_body.s1488, PRE_first_tail_x15_r0_body.S1488)
end Host.Load.Run.Tpl
