import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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
boot_rfl PRE_first_tail_x15_r0_body.k1372 from PRE_first_tail_x15_r0_body.s1372 to PRE_first_tail_x15_r0_body.s1373 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB370 ((nth? PRE_first_tail_x15_r0_body.ks 1372).getD 0) PRE_first_tail_x15_r0_body.s1372 PRE_first_tail_x15_r0_body.S1372 = some (PRE_first_tail_x15_r0_body.s1373, PRE_first_tail_x15_r0_body.S1373)
boot_rfl PRE_first_tail_x15_r0_body.k1373 from PRE_first_tail_x15_r0_body.s1373 to PRE_first_tail_x15_r0_body.s1374 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB370 ((nth? PRE_first_tail_x15_r0_body.ks 1373).getD 0) PRE_first_tail_x15_r0_body.s1373 PRE_first_tail_x15_r0_body.S1373 = some (PRE_first_tail_x15_r0_body.s1374, PRE_first_tail_x15_r0_body.S1374)
boot_rfl PRE_first_tail_x15_r0_body.stepA371 from PRE_first_tail_x15_r0_body.s1374 to PRE_first_tail_x15_r0_body.s1375 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1374).run PRE_first_tail_x15_r0_body.S1374 = some (PRE_first_tail_x15_r0_body.s1375, PRE_first_tail_x15_r0_body.S1375)
end Host.Load.Run.Tpl
