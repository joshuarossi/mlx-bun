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
boot_rfl PRE_first_tail_x15_r0_body.k1024 from PRE_first_tail_x15_r0_body.s1024 to PRE_first_tail_x15_r0_body.s1025 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB276 ((nth? PRE_first_tail_x15_r0_body.ks 1024).getD 0) PRE_first_tail_x15_r0_body.s1024 PRE_first_tail_x15_r0_body.S1024 = some (PRE_first_tail_x15_r0_body.s1025, PRE_first_tail_x15_r0_body.S1025)
boot_rfl PRE_first_tail_x15_r0_body.stepA277 from PRE_first_tail_x15_r0_body.s1025 to PRE_first_tail_x15_r0_body.s1026 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1025).run PRE_first_tail_x15_r0_body.S1025 = some (PRE_first_tail_x15_r0_body.s1026, PRE_first_tail_x15_r0_body.S1026)
boot_rfl PRE_first_tail_x15_r0_body.patchB277 from PRE_first_tail_x15_r0_body.s1026 to PRE_first_tail_x15_r0_body.s1027 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1026).run PRE_first_tail_x15_r0_body.S1026 = some (PRE_first_tail_x15_r0_body.s1027, PRE_first_tail_x15_r0_body.S1027)
boot_rfl PRE_first_tail_x15_r0_body.k1027 from PRE_first_tail_x15_r0_body.s1027 to PRE_first_tail_x15_r0_body.s1028 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB277 ((nth? PRE_first_tail_x15_r0_body.ks 1027).getD 0) PRE_first_tail_x15_r0_body.s1027 PRE_first_tail_x15_r0_body.S1027 = some (PRE_first_tail_x15_r0_body.s1028, PRE_first_tail_x15_r0_body.S1028)
end Host.Load.Run.Tpl
