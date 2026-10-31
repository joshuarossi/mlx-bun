import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.stepA184 from PRE_first_tail_x15_r0_body.s680 to PRE_first_tail_x15_r0_body.s681 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s680).run PRE_first_tail_x15_r0_body.S680 = some (PRE_first_tail_x15_r0_body.s681, PRE_first_tail_x15_r0_body.S681)
boot_rfl PRE_first_tail_x15_r0_body.patchB184 from PRE_first_tail_x15_r0_body.s681 to PRE_first_tail_x15_r0_body.s682 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s681).run PRE_first_tail_x15_r0_body.S681 = some (PRE_first_tail_x15_r0_body.s682, PRE_first_tail_x15_r0_body.S682)
boot_rfl PRE_first_tail_x15_r0_body.k682 from PRE_first_tail_x15_r0_body.s682 to PRE_first_tail_x15_r0_body.s683 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB184 ((nth? PRE_first_tail_x15_r0_body.ks 682).getD 0) PRE_first_tail_x15_r0_body.s682 PRE_first_tail_x15_r0_body.S682 = some (PRE_first_tail_x15_r0_body.s683, PRE_first_tail_x15_r0_body.S683)
boot_rfl PRE_first_tail_x15_r0_body.k683 from PRE_first_tail_x15_r0_body.s683 to PRE_first_tail_x15_r0_body.s684 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB184 ((nth? PRE_first_tail_x15_r0_body.ks 683).getD 0) PRE_first_tail_x15_r0_body.s683 PRE_first_tail_x15_r0_body.S683 = some (PRE_first_tail_x15_r0_body.s684, PRE_first_tail_x15_r0_body.S684)
end Host.Load.Run.Tpl
