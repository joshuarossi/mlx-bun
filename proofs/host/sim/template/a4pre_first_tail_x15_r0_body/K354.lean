import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.patchB382 from PRE_first_tail_x15_r0_body.s1416 to PRE_first_tail_x15_r0_body.s1417 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1416).run PRE_first_tail_x15_r0_body.S1416 = some (PRE_first_tail_x15_r0_body.s1417, PRE_first_tail_x15_r0_body.S1417)
boot_rfl PRE_first_tail_x15_r0_body.k1417 from PRE_first_tail_x15_r0_body.s1417 to PRE_first_tail_x15_r0_body.s1418 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB382 ((nth? PRE_first_tail_x15_r0_body.ks 1417).getD 0) PRE_first_tail_x15_r0_body.s1417 PRE_first_tail_x15_r0_body.S1417 = some (PRE_first_tail_x15_r0_body.s1418, PRE_first_tail_x15_r0_body.S1418)
boot_rfl PRE_first_tail_x15_r0_body.stepA383 from PRE_first_tail_x15_r0_body.s1418 to PRE_first_tail_x15_r0_body.s1419 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1418).run PRE_first_tail_x15_r0_body.S1418 = some (PRE_first_tail_x15_r0_body.s1419, PRE_first_tail_x15_r0_body.S1419)
boot_rfl PRE_first_tail_x15_r0_body.patchB383 from PRE_first_tail_x15_r0_body.s1419 to PRE_first_tail_x15_r0_body.s1420 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1419).run PRE_first_tail_x15_r0_body.S1419 = some (PRE_first_tail_x15_r0_body.s1420, PRE_first_tail_x15_r0_body.S1420)
end Host.Load.Run.Tpl
