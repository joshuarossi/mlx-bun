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
boot_rfl PRE_first_tail_x15_r0.stepA11 from PRE_first_tail_x15_r0.s32 to PRE_first_tail_x15_r0.s33 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s32).run PRE_first_tail_x15_r0.S32 = some (PRE_first_tail_x15_r0.s33, PRE_first_tail_x15_r0.S33)
boot_rfl PRE_first_tail_x15_r0.patchB11 from PRE_first_tail_x15_r0.s33 to PRE_first_tail_x15_r0.s34 : Host.Ts.Sim.Template.Bridge.newdataPatch PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s33 PRE_first_tail_x15_r0.S33 [] = some (PRE_first_tail_x15_r0.s34, PRE_first_tail_x15_r0.S34)
boot_rfl PRE_first_tail_x15_r0.k34 from PRE_first_tail_x15_r0.s34 to PRE_first_tail_x15_r0.s35 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB11 ((nth? PRE_first_tail_x15_r0.ks 34).getD 0) PRE_first_tail_x15_r0.s34 PRE_first_tail_x15_r0.S34 = some (PRE_first_tail_x15_r0.s35, PRE_first_tail_x15_r0.S35)
boot_rfl PRE_first_tail_x15_r0.stepA12 from PRE_first_tail_x15_r0.s35 to PRE_first_tail_x15_r0.s36 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s35).run PRE_first_tail_x15_r0.S35 = some (PRE_first_tail_x15_r0.s36, PRE_first_tail_x15_r0.S36)
end Host.Load.Run.Tpl
