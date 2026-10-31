import host.sim.template.a4pre_first_tail_x15_r0_body.H27
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.k889 from PRE_first_tail_x15_r0_body.s889 to PRE_first_tail_x15_r0_body.s890 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB240 ((nth? PRE_first_tail_x15_r0_body.ks 889).getD 0) PRE_first_tail_x15_r0_body.s889 PRE_first_tail_x15_r0_body.S889 = some (PRE_first_tail_x15_r0_body.s890, PRE_first_tail_x15_r0_body.S890)
boot_rfl PRE_first_tail_x15_r0_body.stepA241 from PRE_first_tail_x15_r0_body.s890 to PRE_first_tail_x15_r0_body.s891 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s890).run PRE_first_tail_x15_r0_body.S890 = some (PRE_first_tail_x15_r0_body.s891, PRE_first_tail_x15_r0_body.S891)
end Host.Load.Run.Tpl
