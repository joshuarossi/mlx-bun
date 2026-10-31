import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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
boot_rfl PRE_first_tail_x15_r0_body.k1072 from PRE_first_tail_x15_r0_body.s1072 to PRE_first_tail_x15_r0_body.s1073 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB289 ((nth? PRE_first_tail_x15_r0_body.ks 1072).getD 0) PRE_first_tail_x15_r0_body.s1072 PRE_first_tail_x15_r0_body.S1072 = some (PRE_first_tail_x15_r0_body.s1073, PRE_first_tail_x15_r0_body.S1073)
boot_rfl PRE_first_tail_x15_r0_body.stepA290 from PRE_first_tail_x15_r0_body.s1073 to PRE_first_tail_x15_r0_body.s1074 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1073).run PRE_first_tail_x15_r0_body.S1073 = some (PRE_first_tail_x15_r0_body.s1074, PRE_first_tail_x15_r0_body.S1074)
boot_rfl PRE_first_tail_x15_r0_body.patchB290 from PRE_first_tail_x15_r0_body.s1074 to PRE_first_tail_x15_r0_body.s1075 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1074).run PRE_first_tail_x15_r0_body.S1074 = some (PRE_first_tail_x15_r0_body.s1075, PRE_first_tail_x15_r0_body.S1075)
boot_rfl PRE_first_tail_x15_r0_body.k1075 from PRE_first_tail_x15_r0_body.s1075 to PRE_first_tail_x15_r0_body.s1076 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB290 ((nth? PRE_first_tail_x15_r0_body.ks 1075).getD 0) PRE_first_tail_x15_r0_body.s1075 PRE_first_tail_x15_r0_body.S1075 = some (PRE_first_tail_x15_r0_body.s1076, PRE_first_tail_x15_r0_body.S1076)
end Host.Load.Run.Tpl
