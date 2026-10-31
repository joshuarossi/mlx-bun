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
boot_rfl PRE_first_tail_x15_r0.k28 from PRE_first_tail_x15_r0.s28 to PRE_first_tail_x15_r0.s29 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB9 ((nth? PRE_first_tail_x15_r0.ks 28).getD 0) PRE_first_tail_x15_r0.s28 PRE_first_tail_x15_r0.S28 = some (PRE_first_tail_x15_r0.s29, PRE_first_tail_x15_r0.S29)
boot_rfl PRE_first_tail_x15_r0.stepA10 from PRE_first_tail_x15_r0.s29 to PRE_first_tail_x15_r0.s30 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s29).run PRE_first_tail_x15_r0.S29 = some (PRE_first_tail_x15_r0.s30, PRE_first_tail_x15_r0.S30)
boot_rfl PRE_first_tail_x15_r0.patchB10 from PRE_first_tail_x15_r0.s30 to PRE_first_tail_x15_r0.s31 : some (Host.Ts.Sim.Template.Bridge.ptrPatch PRE_first_tail_x15_r0.s30 PRE_first_tail_x15_r0.S30 2673472 0) = some (PRE_first_tail_x15_r0.s31, PRE_first_tail_x15_r0.S31)
boot_rfl PRE_first_tail_x15_r0.k31 from PRE_first_tail_x15_r0.s31 to PRE_first_tail_x15_r0.s32 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB10 ((nth? PRE_first_tail_x15_r0.ks 31).getD 0) PRE_first_tail_x15_r0.s31 PRE_first_tail_x15_r0.S31 = some (PRE_first_tail_x15_r0.s32, PRE_first_tail_x15_r0.S32)
end Host.Load.Run.Tpl
