import host.sim.template.a4pre_first_tail_x15_r0_suffix.H0
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_suffix.bodyStepA1 from PRE_first_tail_x15_r0_suffix.s1 to PRE_first_tail_x15_r0_suffix.s2 : interpS (step PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.s1).run PRE_first_tail_x15_r0_suffix.S1 = some (PRE_first_tail_x15_r0_suffix.s2, PRE_first_tail_x15_r0_suffix.S2)
boot_rfl PRE_first_tail_x15_r0_suffix.bodyStepA2 from PRE_first_tail_x15_r0_suffix.s5 to PRE_first_tail_x15_r0_suffix.s6 : interpS (step PRE_first_tail_x15_r0_suffix.F PRE_first_tail_x15_r0_suffix.s5).run PRE_first_tail_x15_r0_suffix.S5 = some (PRE_first_tail_x15_r0_suffix.s6, PRE_first_tail_x15_r0_suffix.S6)
boot_rfl PRE_first_tail_x15_r0_suffix.bodyPatchB2 from PRE_first_tail_x15_r0_suffix.s6 to PRE_first_tail_x15_r0_suffix.s7 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0_suffix.s6 PRE_first_tail_x15_r0_suffix.S6 (.var 9)) = some (PRE_first_tail_x15_r0_suffix.s7, PRE_first_tail_x15_r0_suffix.S7)
end Host.Load.Run.Tpl
