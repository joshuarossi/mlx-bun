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
boot_rfl PRE_first_tail_x15_r0_body.stepA381 from PRE_first_tail_x15_r0_body.s1412 to PRE_first_tail_x15_r0_body.s1413 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1412).run PRE_first_tail_x15_r0_body.S1412 = some (PRE_first_tail_x15_r0_body.s1413, PRE_first_tail_x15_r0_body.S1413)
boot_rfl PRE_first_tail_x15_r0_body.patchB381 from PRE_first_tail_x15_r0_body.s1413 to PRE_first_tail_x15_r0_body.s1414 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1413).run PRE_first_tail_x15_r0_body.S1413 = some (PRE_first_tail_x15_r0_body.s1414, PRE_first_tail_x15_r0_body.S1414)
boot_rfl PRE_first_tail_x15_r0_body.k1414 from PRE_first_tail_x15_r0_body.s1414 to PRE_first_tail_x15_r0_body.s1415 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB381 ((nth? PRE_first_tail_x15_r0_body.ks 1414).getD 0) PRE_first_tail_x15_r0_body.s1414 PRE_first_tail_x15_r0_body.S1414 = some (PRE_first_tail_x15_r0_body.s1415, PRE_first_tail_x15_r0_body.S1415)
boot_rfl PRE_first_tail_x15_r0_body.stepA382 from PRE_first_tail_x15_r0_body.s1415 to PRE_first_tail_x15_r0_body.s1416 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1415).run PRE_first_tail_x15_r0_body.S1415 = some (PRE_first_tail_x15_r0_body.s1416, PRE_first_tail_x15_r0_body.S1416)
end Host.Load.Run.Tpl
