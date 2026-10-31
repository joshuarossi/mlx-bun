import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.stepA289 from PRE_first_tail_x15_r0_body.s976 to PRE_first_tail_x15_r0_body.s977 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s976).run PRE_first_tail_x15_r0_body.S976 = some (PRE_first_tail_x15_r0_body.s977, PRE_first_tail_x15_r0_body.S977)
boot_rfl PRE_first_tail_x15_r0_body.patchB289 from PRE_first_tail_x15_r0_body.s977 to PRE_first_tail_x15_r0_body.s978 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s977).run PRE_first_tail_x15_r0_body.S977 = some (PRE_first_tail_x15_r0_body.s978, PRE_first_tail_x15_r0_body.S978)
boot_rfl PRE_first_tail_x15_r0_body.k978 from PRE_first_tail_x15_r0_body.s978 to PRE_first_tail_x15_r0_body.s979 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB289 ((nth? PRE_first_tail_x15_r0_body.ks 978).getD 0) PRE_first_tail_x15_r0_body.s978 PRE_first_tail_x15_r0_body.S978 = some (PRE_first_tail_x15_r0_body.s979, PRE_first_tail_x15_r0_body.S979)
boot_rfl PRE_first_tail_x15_r0_body.stepA290 from PRE_first_tail_x15_r0_body.s979 to PRE_first_tail_x15_r0_body.s980 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s979).run PRE_first_tail_x15_r0_body.S979 = some (PRE_first_tail_x15_r0_body.s980, PRE_first_tail_x15_r0_body.S980)
end Host.Load.Run.Tpl
