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
boot_rfl PRE_first_tail_x15_r0_body.patchB373 from PRE_first_tail_x15_r0_body.s1384 to PRE_first_tail_x15_r0_body.s1385 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1384).run PRE_first_tail_x15_r0_body.S1384 = some (PRE_first_tail_x15_r0_body.s1385, PRE_first_tail_x15_r0_body.S1385)
boot_rfl PRE_first_tail_x15_r0_body.k1385 from PRE_first_tail_x15_r0_body.s1385 to PRE_first_tail_x15_r0_body.s1386 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB373 ((nth? PRE_first_tail_x15_r0_body.ks 1385).getD 0) PRE_first_tail_x15_r0_body.s1385 PRE_first_tail_x15_r0_body.S1385 = some (PRE_first_tail_x15_r0_body.s1386, PRE_first_tail_x15_r0_body.S1386)
boot_rfl PRE_first_tail_x15_r0_body.stepA374 from PRE_first_tail_x15_r0_body.s1386 to PRE_first_tail_x15_r0_body.s1387 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1386).run PRE_first_tail_x15_r0_body.S1386 = some (PRE_first_tail_x15_r0_body.s1387, PRE_first_tail_x15_r0_body.S1387)
boot_rfl PRE_first_tail_x15_r0_body.patchB374 from PRE_first_tail_x15_r0_body.s1387 to PRE_first_tail_x15_r0_body.s1388 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1387).run PRE_first_tail_x15_r0_body.S1387 = some (PRE_first_tail_x15_r0_body.s1388, PRE_first_tail_x15_r0_body.S1388)
end Host.Load.Run.Tpl
