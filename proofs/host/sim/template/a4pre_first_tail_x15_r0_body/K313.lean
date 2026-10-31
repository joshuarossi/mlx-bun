import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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
boot_rfl PRE_first_tail_x15_r0_body.k1252 from PRE_first_tail_x15_r0_body.s1252 to PRE_first_tail_x15_r0_body.s1253 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB370 ((nth? PRE_first_tail_x15_r0_body.ks 1252).getD 0) PRE_first_tail_x15_r0_body.s1252 PRE_first_tail_x15_r0_body.S1252 = some (PRE_first_tail_x15_r0_body.s1253, PRE_first_tail_x15_r0_body.S1253)
boot_rfl PRE_first_tail_x15_r0_body.stepA371 from PRE_first_tail_x15_r0_body.s1253 to PRE_first_tail_x15_r0_body.s1254 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1253).run PRE_first_tail_x15_r0_body.S1253 = some (PRE_first_tail_x15_r0_body.s1254, PRE_first_tail_x15_r0_body.S1254)
end Host.Load.Run.Tpl
