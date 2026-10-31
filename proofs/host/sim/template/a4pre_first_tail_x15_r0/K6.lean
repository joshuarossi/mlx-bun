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
boot_rfl PRE_first_tail_x15_r0.patchB8 from PRE_first_tail_x15_r0.s24 to PRE_first_tail_x15_r0.s25 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0.s24 PRE_first_tail_x15_r0.S24 (.var 1087)) = some (PRE_first_tail_x15_r0.s25, PRE_first_tail_x15_r0.S25)
boot_rfl PRE_first_tail_x15_r0.k25 from PRE_first_tail_x15_r0.s25 to PRE_first_tail_x15_r0.s26 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB8 ((nth? PRE_first_tail_x15_r0.ks 25).getD 0) PRE_first_tail_x15_r0.s25 PRE_first_tail_x15_r0.S25 = some (PRE_first_tail_x15_r0.s26, PRE_first_tail_x15_r0.S26)
boot_rfl PRE_first_tail_x15_r0.stepA9 from PRE_first_tail_x15_r0.s26 to PRE_first_tail_x15_r0.s27 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s26).run PRE_first_tail_x15_r0.S26 = some (PRE_first_tail_x15_r0.s27, PRE_first_tail_x15_r0.S27)
boot_rfl PRE_first_tail_x15_r0.patchB9 from PRE_first_tail_x15_r0.s27 to PRE_first_tail_x15_r0.s28 : some (Host.Ts.Sim.Template.Bridge.typedPatch PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s27 PRE_first_tail_x15_r0.S27 21) = some (PRE_first_tail_x15_r0.s28, PRE_first_tail_x15_r0.S28)
end Host.Load.Run.Tpl
