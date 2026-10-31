import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.a4pre_first_tail_x15_r0_suffix.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_suffix.k4 from PRE_first_tail_x15_r0_suffix.s4 to PRE_first_tail_x15_r0_suffix.s5 : runOk PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.okB1 ((nth? PRE_first_tail_x15_r0_suffix.ks 4).getD 0) PRE_first_tail_x15_r0_suffix.s4 PRE_first_tail_x15_r0_suffix.S4 = some (PRE_first_tail_x15_r0_suffix.s5, PRE_first_tail_x15_r0_suffix.S5)
boot_rfl PRE_first_tail_x15_r0_suffix.stepA2 from PRE_first_tail_x15_r0_suffix.s5 to PRE_first_tail_x15_r0_suffix.s6 : interpS (step PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.s5).run PRE_first_tail_x15_r0_suffix.S5 = some (PRE_first_tail_x15_r0_suffix.s6, PRE_first_tail_x15_r0_suffix.S6)
boot_rfl PRE_first_tail_x15_r0_suffix.patchB2 from PRE_first_tail_x15_r0_suffix.s6 to PRE_first_tail_x15_r0_suffix.s7 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0_suffix.s6 PRE_first_tail_x15_r0_suffix.S6 (.var 9)) = some (PRE_first_tail_x15_r0_suffix.s7, PRE_first_tail_x15_r0_suffix.S7)
boot_rfl PRE_first_tail_x15_r0_suffix.k7 from PRE_first_tail_x15_r0_suffix.s7 to PRE_first_tail_x15_r0_suffix.s8 : runOk PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.okB2 ((nth? PRE_first_tail_x15_r0_suffix.ks 7).getD 0) PRE_first_tail_x15_r0_suffix.s7 PRE_first_tail_x15_r0_suffix.S7 = some (PRE_first_tail_x15_r0_suffix.s8, PRE_first_tail_x15_r0_suffix.S8)
end Host.Load.Run.Tpl
