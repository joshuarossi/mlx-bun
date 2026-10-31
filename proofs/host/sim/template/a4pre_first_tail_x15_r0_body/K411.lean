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
boot_rfl PRE_first_tail_x15_r0_body.k1644 from PRE_first_tail_x15_r0_body.s1644 to PRE_first_tail_x15_r0_body.s1645 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB443 ((nth? PRE_first_tail_x15_r0_body.ks 1644).getD 0) PRE_first_tail_x15_r0_body.s1644 PRE_first_tail_x15_r0_body.S1644 = some (PRE_first_tail_x15_r0_body.s1645, PRE_first_tail_x15_r0_body.S1645)
boot_rfl PRE_first_tail_x15_r0_body.stepA444 from PRE_first_tail_x15_r0_body.s1645 to PRE_first_tail_x15_r0_body.s1646 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1645).run PRE_first_tail_x15_r0_body.S1645 = some (PRE_first_tail_x15_r0_body.s1646, PRE_first_tail_x15_r0_body.S1646)
boot_rfl PRE_first_tail_x15_r0_body.patchB444 from PRE_first_tail_x15_r0_body.s1646 to PRE_first_tail_x15_r0_body.s1647 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1646).run PRE_first_tail_x15_r0_body.S1646 = some (PRE_first_tail_x15_r0_body.s1647, PRE_first_tail_x15_r0_body.S1647)
boot_rfl PRE_first_tail_x15_r0_body.k1647 from PRE_first_tail_x15_r0_body.s1647 to PRE_first_tail_x15_r0_body.s1648 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB444 ((nth? PRE_first_tail_x15_r0_body.ks 1647).getD 0) PRE_first_tail_x15_r0_body.s1647 PRE_first_tail_x15_r0_body.S1647 = some (PRE_first_tail_x15_r0_body.s1648, PRE_first_tail_x15_r0_body.S1648)
end Host.Load.Run.Tpl
