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
boot_rfl PRE_first_tail_x15_r0_body.patchB6 from PRE_first_tail_x15_r0_body.s20 to PRE_first_tail_x15_r0_body.s21 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s20).run PRE_first_tail_x15_r0_body.S20 = some (PRE_first_tail_x15_r0_body.s21, PRE_first_tail_x15_r0_body.S21)
boot_rfl PRE_first_tail_x15_r0_body.k21 from PRE_first_tail_x15_r0_body.s21 to PRE_first_tail_x15_r0_body.s22 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB6 ((nth? PRE_first_tail_x15_r0_body.ks 21).getD 0) PRE_first_tail_x15_r0_body.s21 PRE_first_tail_x15_r0_body.S21 = some (PRE_first_tail_x15_r0_body.s22, PRE_first_tail_x15_r0_body.S22)
boot_rfl PRE_first_tail_x15_r0_body.k22 from PRE_first_tail_x15_r0_body.s22 to PRE_first_tail_x15_r0_body.s23 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB6 ((nth? PRE_first_tail_x15_r0_body.ks 22).getD 0) PRE_first_tail_x15_r0_body.s22 PRE_first_tail_x15_r0_body.S22 = some (PRE_first_tail_x15_r0_body.s23, PRE_first_tail_x15_r0_body.S23)
boot_rfl PRE_first_tail_x15_r0_body.stepA7 from PRE_first_tail_x15_r0_body.s23 to PRE_first_tail_x15_r0_body.s24 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s23).run PRE_first_tail_x15_r0_body.S23 = some (PRE_first_tail_x15_r0_body.s24, PRE_first_tail_x15_r0_body.S24)
end Host.Load.Run.Tpl
