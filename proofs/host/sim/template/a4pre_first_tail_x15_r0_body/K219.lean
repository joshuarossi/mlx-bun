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
boot_rfl PRE_first_tail_x15_r0_body.patchB237 from PRE_first_tail_x15_r0_body.s876 to PRE_first_tail_x15_r0_body.s877 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s876).run PRE_first_tail_x15_r0_body.S876 = some (PRE_first_tail_x15_r0_body.s877, PRE_first_tail_x15_r0_body.S877)
boot_rfl PRE_first_tail_x15_r0_body.k877 from PRE_first_tail_x15_r0_body.s877 to PRE_first_tail_x15_r0_body.s878 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB237 ((nth? PRE_first_tail_x15_r0_body.ks 877).getD 0) PRE_first_tail_x15_r0_body.s877 PRE_first_tail_x15_r0_body.S877 = some (PRE_first_tail_x15_r0_body.s878, PRE_first_tail_x15_r0_body.S878)
boot_rfl PRE_first_tail_x15_r0_body.stepA238 from PRE_first_tail_x15_r0_body.s878 to PRE_first_tail_x15_r0_body.s879 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s878).run PRE_first_tail_x15_r0_body.S878 = some (PRE_first_tail_x15_r0_body.s879, PRE_first_tail_x15_r0_body.S879)
end Host.Load.Run.Tpl
