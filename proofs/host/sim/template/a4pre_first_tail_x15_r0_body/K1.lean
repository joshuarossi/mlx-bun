import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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
boot_rfl PRE_first_tail_x15_r0_body.stepA2 from PRE_first_tail_x15_r0_body.s4 to PRE_first_tail_x15_r0_body.s5 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s4).run PRE_first_tail_x15_r0_body.S4 = some (PRE_first_tail_x15_r0_body.s5, PRE_first_tail_x15_r0_body.S5)
boot_rfl PRE_first_tail_x15_r0_body.patchB2 from PRE_first_tail_x15_r0_body.s5 to PRE_first_tail_x15_r0_body.s6 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s5).run PRE_first_tail_x15_r0_body.S5 = some (PRE_first_tail_x15_r0_body.s6, PRE_first_tail_x15_r0_body.S6)
boot_rfl PRE_first_tail_x15_r0_body.k6 from PRE_first_tail_x15_r0_body.s6 to PRE_first_tail_x15_r0_body.s7 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB2 ((nth? PRE_first_tail_x15_r0_body.ks 6).getD 0) PRE_first_tail_x15_r0_body.s6 PRE_first_tail_x15_r0_body.S6 = some (PRE_first_tail_x15_r0_body.s7, PRE_first_tail_x15_r0_body.S7)
boot_rfl PRE_first_tail_x15_r0_body.stepA3 from PRE_first_tail_x15_r0_body.s7 to PRE_first_tail_x15_r0_body.s8 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s7).run PRE_first_tail_x15_r0_body.S7 = some (PRE_first_tail_x15_r0_body.s8, PRE_first_tail_x15_r0_body.S8)
end Host.Load.Run.Tpl
