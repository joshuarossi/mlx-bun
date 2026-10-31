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
boot_rfl PRE_first_tail_x15_r0.stepA6 from PRE_first_tail_x15_r0.s16 to PRE_first_tail_x15_r0.s17 : interpS (step PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.s16).run PRE_first_tail_x15_r0.S16 = some (PRE_first_tail_x15_r0.s17, PRE_first_tail_x15_r0.S17)
boot_rfl PRE_first_tail_x15_r0.k19 from PRE_first_tail_x15_r0.s19 to PRE_first_tail_x15_r0.s20 : runOk PRE_first_tail_x15_r0.F PRE_first_tail_x15_r0.okB6 ((nth? PRE_first_tail_x15_r0.ks 19).getD 0) PRE_first_tail_x15_r0.s19 PRE_first_tail_x15_r0.S19 = some (PRE_first_tail_x15_r0.s20, PRE_first_tail_x15_r0.S20)
end Host.Load.Run.Tpl
