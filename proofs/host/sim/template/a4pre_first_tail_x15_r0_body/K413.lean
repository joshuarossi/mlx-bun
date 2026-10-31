import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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
boot_rfl PRE_first_tail_x15_r0_body.patchB446 from PRE_first_tail_x15_r0_body.s1652 to PRE_first_tail_x15_r0_body.s1653 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1652).run PRE_first_tail_x15_r0_body.S1652 = some (PRE_first_tail_x15_r0_body.s1653, PRE_first_tail_x15_r0_body.S1653)
boot_rfl PRE_first_tail_x15_r0_body.k1653 from PRE_first_tail_x15_r0_body.s1653 to PRE_first_tail_x15_r0_body.s1654 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB446 ((nth? PRE_first_tail_x15_r0_body.ks 1653).getD 0) PRE_first_tail_x15_r0_body.s1653 PRE_first_tail_x15_r0_body.S1653 = some (PRE_first_tail_x15_r0_body.s1654, PRE_first_tail_x15_r0_body.S1654)
boot_rfl PRE_first_tail_x15_r0_body.stepA447 from PRE_first_tail_x15_r0_body.s1654 to PRE_first_tail_x15_r0_body.s1655 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1654).run PRE_first_tail_x15_r0_body.S1654 = some (PRE_first_tail_x15_r0_body.s1655, PRE_first_tail_x15_r0_body.S1655)
end Host.Load.Run.Tpl
