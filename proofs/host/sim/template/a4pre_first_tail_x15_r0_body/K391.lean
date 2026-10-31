import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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
boot_rfl PRE_first_tail_x15_r0_body.k1564 from PRE_first_tail_x15_r0_body.s1564 to PRE_first_tail_x15_r0_body.s1565 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB422 ((nth? PRE_first_tail_x15_r0_body.ks 1564).getD 0) PRE_first_tail_x15_r0_body.s1564 PRE_first_tail_x15_r0_body.S1564 = some (PRE_first_tail_x15_r0_body.s1565, PRE_first_tail_x15_r0_body.S1565)
boot_rfl PRE_first_tail_x15_r0_body.stepA423 from PRE_first_tail_x15_r0_body.s1565 to PRE_first_tail_x15_r0_body.s1566 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1565).run PRE_first_tail_x15_r0_body.S1565 = some (PRE_first_tail_x15_r0_body.s1566, PRE_first_tail_x15_r0_body.S1566)
boot_rfl PRE_first_tail_x15_r0_body.patchB423 from PRE_first_tail_x15_r0_body.s1566 to PRE_first_tail_x15_r0_body.s1567 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1566).run PRE_first_tail_x15_r0_body.S1566 = some (PRE_first_tail_x15_r0_body.s1567, PRE_first_tail_x15_r0_body.S1567)
boot_rfl PRE_first_tail_x15_r0_body.k1567 from PRE_first_tail_x15_r0_body.s1567 to PRE_first_tail_x15_r0_body.s1568 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB423 ((nth? PRE_first_tail_x15_r0_body.ks 1567).getD 0) PRE_first_tail_x15_r0_body.s1567 PRE_first_tail_x15_r0_body.S1567 = some (PRE_first_tail_x15_r0_body.s1568, PRE_first_tail_x15_r0_body.S1568)
end Host.Load.Run.Tpl
