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
boot_rfl PRE_first_tail_x15_r0_body.k1468 from PRE_first_tail_x15_r0_body.s1468 to PRE_first_tail_x15_r0_body.s1469 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB396 ((nth? PRE_first_tail_x15_r0_body.ks 1468).getD 0) PRE_first_tail_x15_r0_body.s1468 PRE_first_tail_x15_r0_body.S1468 = some (PRE_first_tail_x15_r0_body.s1469, PRE_first_tail_x15_r0_body.S1469)
boot_rfl PRE_first_tail_x15_r0_body.k1469 from PRE_first_tail_x15_r0_body.s1469 to PRE_first_tail_x15_r0_body.s1470 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB396 ((nth? PRE_first_tail_x15_r0_body.ks 1469).getD 0) PRE_first_tail_x15_r0_body.s1469 PRE_first_tail_x15_r0_body.S1469 = some (PRE_first_tail_x15_r0_body.s1470, PRE_first_tail_x15_r0_body.S1470)
boot_rfl PRE_first_tail_x15_r0_body.stepA397 from PRE_first_tail_x15_r0_body.s1470 to PRE_first_tail_x15_r0_body.s1471 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1470).run PRE_first_tail_x15_r0_body.S1470 = some (PRE_first_tail_x15_r0_body.s1471, PRE_first_tail_x15_r0_body.S1471)
boot_rfl PRE_first_tail_x15_r0_body.patchB397 from PRE_first_tail_x15_r0_body.s1471 to PRE_first_tail_x15_r0_body.s1472 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1471).run PRE_first_tail_x15_r0_body.S1471 = some (PRE_first_tail_x15_r0_body.s1472, PRE_first_tail_x15_r0_body.S1472)
end Host.Load.Run.Tpl
