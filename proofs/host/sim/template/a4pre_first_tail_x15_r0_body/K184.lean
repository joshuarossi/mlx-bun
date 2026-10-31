import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.stepA218 from PRE_first_tail_x15_r0_body.s736 to PRE_first_tail_x15_r0_body.s737 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s736).run PRE_first_tail_x15_r0_body.S736 = some (PRE_first_tail_x15_r0_body.s737, PRE_first_tail_x15_r0_body.S737)
boot_rfl PRE_first_tail_x15_r0_body.patchB218 from PRE_first_tail_x15_r0_body.s737 to PRE_first_tail_x15_r0_body.s738 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s737).run PRE_first_tail_x15_r0_body.S737 = some (PRE_first_tail_x15_r0_body.s738, PRE_first_tail_x15_r0_body.S738)
boot_rfl PRE_first_tail_x15_r0_body.k738 from PRE_first_tail_x15_r0_body.s738 to PRE_first_tail_x15_r0_body.s739 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB218 ((nth? PRE_first_tail_x15_r0_body.ks 738).getD 0) PRE_first_tail_x15_r0_body.s738 PRE_first_tail_x15_r0_body.S738 = some (PRE_first_tail_x15_r0_body.s739, PRE_first_tail_x15_r0_body.S739)
boot_rfl PRE_first_tail_x15_r0_body.stepA219 from PRE_first_tail_x15_r0_body.s739 to PRE_first_tail_x15_r0_body.s740 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s739).run PRE_first_tail_x15_r0_body.S739 = some (PRE_first_tail_x15_r0_body.s740, PRE_first_tail_x15_r0_body.S740)
end Host.Load.Run.Tpl
