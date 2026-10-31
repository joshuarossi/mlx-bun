import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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
boot_rfl PRE_first_tail_x15_r0_body.patchB322 from PRE_first_tail_x15_r0_body.s1088 to PRE_first_tail_x15_r0_body.s1089 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1088).run PRE_first_tail_x15_r0_body.S1088 = some (PRE_first_tail_x15_r0_body.s1089, PRE_first_tail_x15_r0_body.S1089)
boot_rfl PRE_first_tail_x15_r0_body.k1089 from PRE_first_tail_x15_r0_body.s1089 to PRE_first_tail_x15_r0_body.s1090 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB322 ((nth? PRE_first_tail_x15_r0_body.ks 1089).getD 0) PRE_first_tail_x15_r0_body.s1089 PRE_first_tail_x15_r0_body.S1089 = some (PRE_first_tail_x15_r0_body.s1090, PRE_first_tail_x15_r0_body.S1090)
boot_rfl PRE_first_tail_x15_r0_body.stepA323 from PRE_first_tail_x15_r0_body.s1090 to PRE_first_tail_x15_r0_body.s1091 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1090).run PRE_first_tail_x15_r0_body.S1090 = some (PRE_first_tail_x15_r0_body.s1091, PRE_first_tail_x15_r0_body.S1091)
end Host.Load.Run.Tpl
