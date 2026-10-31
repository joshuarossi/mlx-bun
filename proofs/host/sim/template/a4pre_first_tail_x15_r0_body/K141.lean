import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.k564 from PRE_first_tail_x15_r0_body.s564 to PRE_first_tail_x15_r0_body.s565 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB152 ((nth? PRE_first_tail_x15_r0_body.ks 564).getD 0) PRE_first_tail_x15_r0_body.s564 PRE_first_tail_x15_r0_body.S564 = some (PRE_first_tail_x15_r0_body.s565, PRE_first_tail_x15_r0_body.S565)
boot_rfl PRE_first_tail_x15_r0_body.stepA153 from PRE_first_tail_x15_r0_body.s565 to PRE_first_tail_x15_r0_body.s566 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s565).run PRE_first_tail_x15_r0_body.S565 = some (PRE_first_tail_x15_r0_body.s566, PRE_first_tail_x15_r0_body.S566)
boot_rfl PRE_first_tail_x15_r0_body.patchB153 from PRE_first_tail_x15_r0_body.s566 to PRE_first_tail_x15_r0_body.s567 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s566).run PRE_first_tail_x15_r0_body.S566 = some (PRE_first_tail_x15_r0_body.s567, PRE_first_tail_x15_r0_body.S567)
boot_rfl PRE_first_tail_x15_r0_body.k567 from PRE_first_tail_x15_r0_body.s567 to PRE_first_tail_x15_r0_body.s568 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB153 ((nth? PRE_first_tail_x15_r0_body.ks 567).getD 0) PRE_first_tail_x15_r0_body.s567 PRE_first_tail_x15_r0_body.S567 = some (PRE_first_tail_x15_r0_body.s568, PRE_first_tail_x15_r0_body.S568)
end Host.Load.Run.Tpl
