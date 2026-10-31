import host.sim.template.a4pre_first_tail_x15_r0.H0
import host.sim.template.a4pre_first_tail_x15_r0.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0.stepA7 from PRE_first_tail_x15_r0.s20 to PRE_first_tail_x15_r0.s21 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s20).run PRE_first_tail_x15_r0.S20 = some (PRE_first_tail_x15_r0.s21, PRE_first_tail_x15_r0.S21)
boot_rfl PRE_first_tail_x15_r0.patchB7 from PRE_first_tail_x15_r0.s21 to PRE_first_tail_x15_r0.s22 : some (Host.Ts.Sim.Template.Bridge.slicePatch PRE_first_tail_x15_r0.s21 PRE_first_tail_x15_r0.S21) = some (PRE_first_tail_x15_r0.s22, PRE_first_tail_x15_r0.S22)
boot_rfl PRE_first_tail_x15_r0.k22 from PRE_first_tail_x15_r0.s22 to PRE_first_tail_x15_r0.s23 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB7 ((nth? PRE_first_tail_x15_r0.ks 22).getD 0) PRE_first_tail_x15_r0.s22 PRE_first_tail_x15_r0.S22 = some (PRE_first_tail_x15_r0.s23, PRE_first_tail_x15_r0.S23)
boot_rfl PRE_first_tail_x15_r0.stepA8 from PRE_first_tail_x15_r0.s23 to PRE_first_tail_x15_r0.s24 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s23).run PRE_first_tail_x15_r0.S23 = some (PRE_first_tail_x15_r0.s24, PRE_first_tail_x15_r0.S24)
end Host.Load.Run.Tpl
