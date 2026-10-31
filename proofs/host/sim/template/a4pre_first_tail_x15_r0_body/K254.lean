import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.k1016 from PRE_first_tail_x15_r0_body.s1016 to PRE_first_tail_x15_r0_body.s1017 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB274 ((nth? PRE_first_tail_x15_r0_body.ks 1016).getD 0) PRE_first_tail_x15_r0_body.s1016 PRE_first_tail_x15_r0_body.S1016 = some (PRE_first_tail_x15_r0_body.s1017, PRE_first_tail_x15_r0_body.S1017)
boot_rfl PRE_first_tail_x15_r0_body.stepA275 from PRE_first_tail_x15_r0_body.s1017 to PRE_first_tail_x15_r0_body.s1018 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1017).run PRE_first_tail_x15_r0_body.S1017 = some (PRE_first_tail_x15_r0_body.s1018, PRE_first_tail_x15_r0_body.S1018)
boot_rfl PRE_first_tail_x15_r0_body.patchB275 from PRE_first_tail_x15_r0_body.s1018 to PRE_first_tail_x15_r0_body.s1019 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1018).run PRE_first_tail_x15_r0_body.S1018 = some (PRE_first_tail_x15_r0_body.s1019, PRE_first_tail_x15_r0_body.S1019)
boot_rfl PRE_first_tail_x15_r0_body.k1019 from PRE_first_tail_x15_r0_body.s1019 to PRE_first_tail_x15_r0_body.s1020 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB275 ((nth? PRE_first_tail_x15_r0_body.ks 1019).getD 0) PRE_first_tail_x15_r0_body.s1019 PRE_first_tail_x15_r0_body.S1019 = some (PRE_first_tail_x15_r0_body.s1020, PRE_first_tail_x15_r0_body.S1020)
end Host.Load.Run.Tpl
