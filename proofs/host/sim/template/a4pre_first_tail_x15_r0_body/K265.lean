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
boot_rfl PRE_first_tail_x15_r0_body.stepA314 from PRE_first_tail_x15_r0_body.s1060 to PRE_first_tail_x15_r0_body.s1061 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1060).run PRE_first_tail_x15_r0_body.S1060 = some (PRE_first_tail_x15_r0_body.s1061, PRE_first_tail_x15_r0_body.S1061)
boot_rfl PRE_first_tail_x15_r0_body.patchB314 from PRE_first_tail_x15_r0_body.s1061 to PRE_first_tail_x15_r0_body.s1062 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1061).run PRE_first_tail_x15_r0_body.S1061 = some (PRE_first_tail_x15_r0_body.s1062, PRE_first_tail_x15_r0_body.S1062)
boot_rfl PRE_first_tail_x15_r0_body.k1062 from PRE_first_tail_x15_r0_body.s1062 to PRE_first_tail_x15_r0_body.s1063 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB314 ((nth? PRE_first_tail_x15_r0_body.ks 1062).getD 0) PRE_first_tail_x15_r0_body.s1062 PRE_first_tail_x15_r0_body.S1062 = some (PRE_first_tail_x15_r0_body.s1063, PRE_first_tail_x15_r0_body.S1063)
boot_rfl PRE_first_tail_x15_r0_body.stepA315 from PRE_first_tail_x15_r0_body.s1063 to PRE_first_tail_x15_r0_body.s1064 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1063).run PRE_first_tail_x15_r0_body.S1063 = some (PRE_first_tail_x15_r0_body.s1064, PRE_first_tail_x15_r0_body.S1064)
end Host.Load.Run.Tpl
