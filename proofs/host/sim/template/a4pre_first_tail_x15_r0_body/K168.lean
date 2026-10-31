import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.stepA182 from PRE_first_tail_x15_r0_body.s672 to PRE_first_tail_x15_r0_body.s673 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s672).run PRE_first_tail_x15_r0_body.S672 = some (PRE_first_tail_x15_r0_body.s673, PRE_first_tail_x15_r0_body.S673)
boot_rfl PRE_first_tail_x15_r0_body.patchB182 from PRE_first_tail_x15_r0_body.s673 to PRE_first_tail_x15_r0_body.s674 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s673).run PRE_first_tail_x15_r0_body.S673 = some (PRE_first_tail_x15_r0_body.s674, PRE_first_tail_x15_r0_body.S674)
boot_rfl PRE_first_tail_x15_r0_body.k674 from PRE_first_tail_x15_r0_body.s674 to PRE_first_tail_x15_r0_body.s675 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB182 ((nth? PRE_first_tail_x15_r0_body.ks 674).getD 0) PRE_first_tail_x15_r0_body.s674 PRE_first_tail_x15_r0_body.S674 = some (PRE_first_tail_x15_r0_body.s675, PRE_first_tail_x15_r0_body.S675)
boot_rfl PRE_first_tail_x15_r0_body.k675 from PRE_first_tail_x15_r0_body.s675 to PRE_first_tail_x15_r0_body.s676 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB182 ((nth? PRE_first_tail_x15_r0_body.ks 675).getD 0) PRE_first_tail_x15_r0_body.s675 PRE_first_tail_x15_r0_body.S675 = some (PRE_first_tail_x15_r0_body.s676, PRE_first_tail_x15_r0_body.S676)
end Host.Load.Run.Tpl
