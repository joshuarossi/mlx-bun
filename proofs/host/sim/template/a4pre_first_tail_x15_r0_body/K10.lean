import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.k40 from PRE_first_tail_x15_r0_body.s40 to PRE_first_tail_x15_r0_body.s41 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB11 ((nth? PRE_first_tail_x15_r0_body.ks 40).getD 0) PRE_first_tail_x15_r0_body.s40 PRE_first_tail_x15_r0_body.S40 = some (PRE_first_tail_x15_r0_body.s41, PRE_first_tail_x15_r0_body.S41)
boot_rfl PRE_first_tail_x15_r0_body.stepA12 from PRE_first_tail_x15_r0_body.s41 to PRE_first_tail_x15_r0_body.s42 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s41).run PRE_first_tail_x15_r0_body.S41 = some (PRE_first_tail_x15_r0_body.s42, PRE_first_tail_x15_r0_body.S42)
boot_rfl PRE_first_tail_x15_r0_body.patchB12 from PRE_first_tail_x15_r0_body.s42 to PRE_first_tail_x15_r0_body.s43 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s42).run PRE_first_tail_x15_r0_body.S42 = some (PRE_first_tail_x15_r0_body.s43, PRE_first_tail_x15_r0_body.S43)
boot_rfl PRE_first_tail_x15_r0_body.k43 from PRE_first_tail_x15_r0_body.s43 to PRE_first_tail_x15_r0_body.s44 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB12 ((nth? PRE_first_tail_x15_r0_body.ks 43).getD 0) PRE_first_tail_x15_r0_body.s43 PRE_first_tail_x15_r0_body.S43 = some (PRE_first_tail_x15_r0_body.s44, PRE_first_tail_x15_r0_body.S44)
end Host.Load.Run.Tpl
