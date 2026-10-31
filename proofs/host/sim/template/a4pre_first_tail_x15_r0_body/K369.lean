import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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
boot_rfl PRE_first_tail_x15_r0_body.k1476 from PRE_first_tail_x15_r0_body.s1476 to PRE_first_tail_x15_r0_body.s1477 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB398 ((nth? PRE_first_tail_x15_r0_body.ks 1476).getD 0) PRE_first_tail_x15_r0_body.s1476 PRE_first_tail_x15_r0_body.S1476 = some (PRE_first_tail_x15_r0_body.s1477, PRE_first_tail_x15_r0_body.S1477)
boot_rfl PRE_first_tail_x15_r0_body.stepA399 from PRE_first_tail_x15_r0_body.s1477 to PRE_first_tail_x15_r0_body.s1478 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1477).run PRE_first_tail_x15_r0_body.S1477 = some (PRE_first_tail_x15_r0_body.s1478, PRE_first_tail_x15_r0_body.S1478)
boot_rfl PRE_first_tail_x15_r0_body.patchB399 from PRE_first_tail_x15_r0_body.s1478 to PRE_first_tail_x15_r0_body.s1479 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1478).run PRE_first_tail_x15_r0_body.S1478 = some (PRE_first_tail_x15_r0_body.s1479, PRE_first_tail_x15_r0_body.S1479)
boot_rfl PRE_first_tail_x15_r0_body.k1479 from PRE_first_tail_x15_r0_body.s1479 to PRE_first_tail_x15_r0_body.s1480 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB399 ((nth? PRE_first_tail_x15_r0_body.ks 1479).getD 0) PRE_first_tail_x15_r0_body.s1479 PRE_first_tail_x15_r0_body.S1479 = some (PRE_first_tail_x15_r0_body.s1480, PRE_first_tail_x15_r0_body.S1480)
end Host.Load.Run.Tpl
