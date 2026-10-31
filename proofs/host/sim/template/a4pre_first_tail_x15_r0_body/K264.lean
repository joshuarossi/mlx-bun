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
boot_rfl PRE_first_tail_x15_r0_body.k1056 from PRE_first_tail_x15_r0_body.s1056 to PRE_first_tail_x15_r0_body.s1057 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB312 ((nth? PRE_first_tail_x15_r0_body.ks 1056).getD 0) PRE_first_tail_x15_r0_body.s1056 PRE_first_tail_x15_r0_body.S1056 = some (PRE_first_tail_x15_r0_body.s1057, PRE_first_tail_x15_r0_body.S1057)
boot_rfl PRE_first_tail_x15_r0_body.stepA313 from PRE_first_tail_x15_r0_body.s1057 to PRE_first_tail_x15_r0_body.s1058 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1057).run PRE_first_tail_x15_r0_body.S1057 = some (PRE_first_tail_x15_r0_body.s1058, PRE_first_tail_x15_r0_body.S1058)
boot_rfl PRE_first_tail_x15_r0_body.patchB313 from PRE_first_tail_x15_r0_body.s1058 to PRE_first_tail_x15_r0_body.s1059 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058).run PRE_first_tail_x15_r0_body.S1058 = some (PRE_first_tail_x15_r0_body.s1059, PRE_first_tail_x15_r0_body.S1059)
boot_rfl PRE_first_tail_x15_r0_body.k1059 from PRE_first_tail_x15_r0_body.s1059 to PRE_first_tail_x15_r0_body.s1060 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB313 ((nth? PRE_first_tail_x15_r0_body.ks 1059).getD 0) PRE_first_tail_x15_r0_body.s1059 PRE_first_tail_x15_r0_body.S1059 = some (PRE_first_tail_x15_r0_body.s1060, PRE_first_tail_x15_r0_body.S1060)
end Host.Load.Run.Tpl
