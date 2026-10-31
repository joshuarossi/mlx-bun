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
boot_rfl PRE_first_tail_x15_r0_body.stepA436 from PRE_first_tail_x15_r0_body.s1616 to PRE_first_tail_x15_r0_body.s1617 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1616).run PRE_first_tail_x15_r0_body.S1616 = some (PRE_first_tail_x15_r0_body.s1617, PRE_first_tail_x15_r0_body.S1617)
boot_rfl PRE_first_tail_x15_r0_body.patchB436 from PRE_first_tail_x15_r0_body.s1617 to PRE_first_tail_x15_r0_body.s1618 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1617).run PRE_first_tail_x15_r0_body.S1617 = some (PRE_first_tail_x15_r0_body.s1618, PRE_first_tail_x15_r0_body.S1618)
boot_rfl PRE_first_tail_x15_r0_body.k1618 from PRE_first_tail_x15_r0_body.s1618 to PRE_first_tail_x15_r0_body.s1619 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB436 ((nth? PRE_first_tail_x15_r0_body.ks 1618).getD 0) PRE_first_tail_x15_r0_body.s1618 PRE_first_tail_x15_r0_body.S1618 = some (PRE_first_tail_x15_r0_body.s1619, PRE_first_tail_x15_r0_body.S1619)
boot_rfl PRE_first_tail_x15_r0_body.stepA437 from PRE_first_tail_x15_r0_body.s1619 to PRE_first_tail_x15_r0_body.s1620 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1619).run PRE_first_tail_x15_r0_body.S1619 = some (PRE_first_tail_x15_r0_body.s1620, PRE_first_tail_x15_r0_body.S1620)
end Host.Load.Run.Tpl
