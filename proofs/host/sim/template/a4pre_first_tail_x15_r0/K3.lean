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
boot_rfl PRE_first_tail_x15_r0.k12 from PRE_first_tail_x15_r0.s12 to PRE_first_tail_x15_r0.s13 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB4 ((nth? PRE_first_tail_x15_r0.ks 12).getD 0) PRE_first_tail_x15_r0.s12 PRE_first_tail_x15_r0.S12 = some (PRE_first_tail_x15_r0.s13, PRE_first_tail_x15_r0.S13)
boot_rfl PRE_first_tail_x15_r0.stepA5 from PRE_first_tail_x15_r0.s13 to PRE_first_tail_x15_r0.s14 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s13).run PRE_first_tail_x15_r0.S13 = some (PRE_first_tail_x15_r0.s14, PRE_first_tail_x15_r0.S14)
boot_rfl PRE_first_tail_x15_r0.patchB5 from PRE_first_tail_x15_r0.s14 to PRE_first_tail_x15_r0.s15 : some (Host.Ts.Sim.Template.Bridge.lenPatch PRE_first_tail_x15_r0.s14 PRE_first_tail_x15_r0.S14 (.var 9)) = some (PRE_first_tail_x15_r0.s15, PRE_first_tail_x15_r0.S15)
boot_rfl PRE_first_tail_x15_r0.k15 from PRE_first_tail_x15_r0.s15 to PRE_first_tail_x15_r0.s16 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB5 ((nth? PRE_first_tail_x15_r0.ks 15).getD 0) PRE_first_tail_x15_r0.s15 PRE_first_tail_x15_r0.S15 = some (PRE_first_tail_x15_r0.s16, PRE_first_tail_x15_r0.S16)
end Host.Load.Run.Tpl
