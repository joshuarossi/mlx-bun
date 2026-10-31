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
boot_rfl PRE_first_tail_x15_r0_body.patchB316 from PRE_first_tail_x15_r0_body.s1068 to PRE_first_tail_x15_r0_body.s1069 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1068).run PRE_first_tail_x15_r0_body.S1068 = some (PRE_first_tail_x15_r0_body.s1069, PRE_first_tail_x15_r0_body.S1069)
boot_rfl PRE_first_tail_x15_r0_body.k1069 from PRE_first_tail_x15_r0_body.s1069 to PRE_first_tail_x15_r0_body.s1070 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB316 ((nth? PRE_first_tail_x15_r0_body.ks 1069).getD 0) PRE_first_tail_x15_r0_body.s1069 PRE_first_tail_x15_r0_body.S1069 = some (PRE_first_tail_x15_r0_body.s1070, PRE_first_tail_x15_r0_body.S1070)
boot_rfl PRE_first_tail_x15_r0_body.stepA317 from PRE_first_tail_x15_r0_body.s1070 to PRE_first_tail_x15_r0_body.s1071 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1070).run PRE_first_tail_x15_r0_body.S1070 = some (PRE_first_tail_x15_r0_body.s1071, PRE_first_tail_x15_r0_body.S1071)
end Host.Load.Run.Tpl
