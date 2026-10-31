import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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
boot_rfl PRE_first_tail_x15_r0_body.k1036 from PRE_first_tail_x15_r0_body.s1036 to PRE_first_tail_x15_r0_body.s1037 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB279 ((nth? PRE_first_tail_x15_r0_body.ks 1036).getD 0) PRE_first_tail_x15_r0_body.s1036 PRE_first_tail_x15_r0_body.S1036 = some (PRE_first_tail_x15_r0_body.s1037, PRE_first_tail_x15_r0_body.S1037)
boot_rfl PRE_first_tail_x15_r0_body.k1037 from PRE_first_tail_x15_r0_body.s1037 to PRE_first_tail_x15_r0_body.s1038 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB279 ((nth? PRE_first_tail_x15_r0_body.ks 1037).getD 0) PRE_first_tail_x15_r0_body.s1037 PRE_first_tail_x15_r0_body.S1037 = some (PRE_first_tail_x15_r0_body.s1038, PRE_first_tail_x15_r0_body.S1038)
boot_rfl PRE_first_tail_x15_r0_body.stepA280 from PRE_first_tail_x15_r0_body.s1038 to PRE_first_tail_x15_r0_body.s1039 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1038).run PRE_first_tail_x15_r0_body.S1038 = some (PRE_first_tail_x15_r0_body.s1039, PRE_first_tail_x15_r0_body.S1039)
boot_rfl PRE_first_tail_x15_r0_body.patchB280 from PRE_first_tail_x15_r0_body.s1039 to PRE_first_tail_x15_r0_body.s1040 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1039).run PRE_first_tail_x15_r0_body.S1039 = some (PRE_first_tail_x15_r0_body.s1040, PRE_first_tail_x15_r0_body.S1040)
end Host.Load.Run.Tpl
