import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.stepA177 from PRE_first_tail_x15_r0_body.s652 to PRE_first_tail_x15_r0_body.s653 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s652).run PRE_first_tail_x15_r0_body.S652 = some (PRE_first_tail_x15_r0_body.s653, PRE_first_tail_x15_r0_body.S653)
boot_rfl PRE_first_tail_x15_r0_body.patchB177 from PRE_first_tail_x15_r0_body.s653 to PRE_first_tail_x15_r0_body.s654 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s653).run PRE_first_tail_x15_r0_body.S653 = some (PRE_first_tail_x15_r0_body.s654, PRE_first_tail_x15_r0_body.S654)
boot_rfl PRE_first_tail_x15_r0_body.k654 from PRE_first_tail_x15_r0_body.s654 to PRE_first_tail_x15_r0_body.s655 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB177 ((nth? PRE_first_tail_x15_r0_body.ks 654).getD 0) PRE_first_tail_x15_r0_body.s654 PRE_first_tail_x15_r0_body.S654 = some (PRE_first_tail_x15_r0_body.s655, PRE_first_tail_x15_r0_body.S655)
boot_rfl PRE_first_tail_x15_r0_body.k655 from PRE_first_tail_x15_r0_body.s655 to PRE_first_tail_x15_r0_body.s656 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB177 ((nth? PRE_first_tail_x15_r0_body.ks 655).getD 0) PRE_first_tail_x15_r0_body.s655 PRE_first_tail_x15_r0_body.S655 = some (PRE_first_tail_x15_r0_body.s656, PRE_first_tail_x15_r0_body.S656)
end Host.Load.Run.Tpl
