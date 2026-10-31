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
boot_rfl PRE_first_tail_x15_r0_body.patchB311 from PRE_first_tail_x15_r0_body.s1052 to PRE_first_tail_x15_r0_body.s1053 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1052).run PRE_first_tail_x15_r0_body.S1052 = some (PRE_first_tail_x15_r0_body.s1053, PRE_first_tail_x15_r0_body.S1053)
boot_rfl PRE_first_tail_x15_r0_body.k1053 from PRE_first_tail_x15_r0_body.s1053 to PRE_first_tail_x15_r0_body.s1054 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB311 ((nth? PRE_first_tail_x15_r0_body.ks 1053).getD 0) PRE_first_tail_x15_r0_body.s1053 PRE_first_tail_x15_r0_body.S1053 = some (PRE_first_tail_x15_r0_body.s1054, PRE_first_tail_x15_r0_body.S1054)
boot_rfl PRE_first_tail_x15_r0_body.stepA312 from PRE_first_tail_x15_r0_body.s1054 to PRE_first_tail_x15_r0_body.s1055 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1054).run PRE_first_tail_x15_r0_body.S1054 = some (PRE_first_tail_x15_r0_body.s1055, PRE_first_tail_x15_r0_body.S1055)
boot_rfl PRE_first_tail_x15_r0_body.patchB312 from PRE_first_tail_x15_r0_body.s1055 to PRE_first_tail_x15_r0_body.s1056 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1055).run PRE_first_tail_x15_r0_body.S1055 = some (PRE_first_tail_x15_r0_body.s1056, PRE_first_tail_x15_r0_body.S1056)
end Host.Load.Run.Tpl
