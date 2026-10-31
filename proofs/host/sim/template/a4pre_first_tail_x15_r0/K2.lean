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
boot_rfl PRE_first_tail_x15_r0.patchB3 from PRE_first_tail_x15_r0.s8 to PRE_first_tail_x15_r0.s9 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0.s8 PRE_first_tail_x15_r0.S8 (.var 9)) = some (PRE_first_tail_x15_r0.s9, PRE_first_tail_x15_r0.S9)
boot_rfl PRE_first_tail_x15_r0.k9 from PRE_first_tail_x15_r0.s9 to PRE_first_tail_x15_r0.s10 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB3 ((nth? PRE_first_tail_x15_r0.ks 9).getD 0) PRE_first_tail_x15_r0.s9 PRE_first_tail_x15_r0.S9 = some (PRE_first_tail_x15_r0.s10, PRE_first_tail_x15_r0.S10)
boot_rfl PRE_first_tail_x15_r0.stepA4 from PRE_first_tail_x15_r0.s10 to PRE_first_tail_x15_r0.s11 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s10).run PRE_first_tail_x15_r0.S10 = some (PRE_first_tail_x15_r0.s11, PRE_first_tail_x15_r0.S11)
boot_rfl PRE_first_tail_x15_r0.patchB4 from PRE_first_tail_x15_r0.s11 to PRE_first_tail_x15_r0.s12 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0.s11 PRE_first_tail_x15_r0.S11 (.var 9)) = some (PRE_first_tail_x15_r0.s12, PRE_first_tail_x15_r0.S12)
end Host.Load.Run.Tpl
