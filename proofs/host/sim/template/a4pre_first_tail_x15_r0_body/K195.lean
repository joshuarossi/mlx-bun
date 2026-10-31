import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.patchB231 from PRE_first_tail_x15_r0_body.s780 to PRE_first_tail_x15_r0_body.s781 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s780).run PRE_first_tail_x15_r0_body.S780 = some (PRE_first_tail_x15_r0_body.s781, PRE_first_tail_x15_r0_body.S781)
boot_rfl PRE_first_tail_x15_r0_body.k781 from PRE_first_tail_x15_r0_body.s781 to PRE_first_tail_x15_r0_body.s782 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB231 ((nth? PRE_first_tail_x15_r0_body.ks 781).getD 0) PRE_first_tail_x15_r0_body.s781 PRE_first_tail_x15_r0_body.S781 = some (PRE_first_tail_x15_r0_body.s782, PRE_first_tail_x15_r0_body.S782)
boot_rfl PRE_first_tail_x15_r0_body.stepA232 from PRE_first_tail_x15_r0_body.s782 to PRE_first_tail_x15_r0_body.s783 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s782).run PRE_first_tail_x15_r0_body.S782 = some (PRE_first_tail_x15_r0_body.s783, PRE_first_tail_x15_r0_body.S783)
end Host.Load.Run.Tpl
