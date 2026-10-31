import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.k881 from PRE_first_tail_x15_r0_body.s881 to PRE_first_tail_x15_r0_body.s882 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB238 ((nth? PRE_first_tail_x15_r0_body.ks 881).getD 0) PRE_first_tail_x15_r0_body.s881 PRE_first_tail_x15_r0_body.S881 = some (PRE_first_tail_x15_r0_body.s882, PRE_first_tail_x15_r0_body.S882)
boot_rfl PRE_first_tail_x15_r0_body.stepA239 from PRE_first_tail_x15_r0_body.s882 to PRE_first_tail_x15_r0_body.s883 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s882).run PRE_first_tail_x15_r0_body.S882 = some (PRE_first_tail_x15_r0_body.s883, PRE_first_tail_x15_r0_body.S883)
boot_rfl PRE_first_tail_x15_r0_body.patchB239 from PRE_first_tail_x15_r0_body.s883 to PRE_first_tail_x15_r0_body.s884 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s883).run PRE_first_tail_x15_r0_body.S883 = some (PRE_first_tail_x15_r0_body.s884, PRE_first_tail_x15_r0_body.S884)
end Host.Load.Run.Tpl
