import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.stepA167 from PRE_first_tail_x15_r0_body.s616 to PRE_first_tail_x15_r0_body.s617 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s616).run PRE_first_tail_x15_r0_body.S616 = some (PRE_first_tail_x15_r0_body.s617, PRE_first_tail_x15_r0_body.S617)
boot_rfl PRE_first_tail_x15_r0_body.patchB167 from PRE_first_tail_x15_r0_body.s617 to PRE_first_tail_x15_r0_body.s618 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s617).run PRE_first_tail_x15_r0_body.S617 = some (PRE_first_tail_x15_r0_body.s618, PRE_first_tail_x15_r0_body.S618)
boot_rfl PRE_first_tail_x15_r0_body.k618 from PRE_first_tail_x15_r0_body.s618 to PRE_first_tail_x15_r0_body.s619 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB167 ((nth? PRE_first_tail_x15_r0_body.ks 618).getD 0) PRE_first_tail_x15_r0_body.s618 PRE_first_tail_x15_r0_body.S618 = some (PRE_first_tail_x15_r0_body.s619, PRE_first_tail_x15_r0_body.S619)
boot_rfl PRE_first_tail_x15_r0_body.stepA168 from PRE_first_tail_x15_r0_body.s619 to PRE_first_tail_x15_r0_body.s620 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s619).run PRE_first_tail_x15_r0_body.S619 = some (PRE_first_tail_x15_r0_body.s620, PRE_first_tail_x15_r0_body.S620)
end Host.Load.Run.Tpl
