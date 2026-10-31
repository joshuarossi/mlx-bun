import host.sim.template.a4pre_first_tail_x15_r0.H1
import host.sim.template.a4pre_first_tail_x15_r0.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0.patchB12 from PRE_first_tail_x15_r0.s36 to PRE_first_tail_x15_r0.s37 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0.s36 PRE_first_tail_x15_r0.S36 (.var 1087)) = some (PRE_first_tail_x15_r0.s37, PRE_first_tail_x15_r0.S37)
boot_rfl PRE_first_tail_x15_r0.stepA13 from PRE_first_tail_x15_r0.s37 to PRE_first_tail_x15_r0.s38 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s37).run PRE_first_tail_x15_r0.S37 = some (PRE_first_tail_x15_r0.s38, PRE_first_tail_x15_r0.S38)
end Host.Load.Run.Tpl
