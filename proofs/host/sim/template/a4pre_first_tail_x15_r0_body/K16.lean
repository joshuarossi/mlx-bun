import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.stepA18 from PRE_first_tail_x15_r0_body.s64 to PRE_first_tail_x15_r0_body.s65 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s64).run PRE_first_tail_x15_r0_body.S64 = some (PRE_first_tail_x15_r0_body.s65, PRE_first_tail_x15_r0_body.S65)
boot_rfl PRE_first_tail_x15_r0_body.patchB18 from PRE_first_tail_x15_r0_body.s65 to PRE_first_tail_x15_r0_body.s66 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s65).run PRE_first_tail_x15_r0_body.S65 = some (PRE_first_tail_x15_r0_body.s66, PRE_first_tail_x15_r0_body.S66)
boot_rfl PRE_first_tail_x15_r0_body.k66 from PRE_first_tail_x15_r0_body.s66 to PRE_first_tail_x15_r0_body.s67 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB18 ((nth? PRE_first_tail_x15_r0_body.ks 66).getD 0) PRE_first_tail_x15_r0_body.s66 PRE_first_tail_x15_r0_body.S66 = some (PRE_first_tail_x15_r0_body.s67, PRE_first_tail_x15_r0_body.S67)
boot_rfl PRE_first_tail_x15_r0_body.stepA19 from PRE_first_tail_x15_r0_body.s67 to PRE_first_tail_x15_r0_body.s68 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s67).run PRE_first_tail_x15_r0_body.S67 = some (PRE_first_tail_x15_r0_body.s68, PRE_first_tail_x15_r0_body.S68)
end Host.Load.Run.Tpl
