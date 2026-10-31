import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.patchB134 from PRE_first_tail_x15_r0_body.s496 to PRE_first_tail_x15_r0_body.s497 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s496).run PRE_first_tail_x15_r0_body.S496 = some (PRE_first_tail_x15_r0_body.s497, PRE_first_tail_x15_r0_body.S497)
boot_rfl PRE_first_tail_x15_r0_body.k497 from PRE_first_tail_x15_r0_body.s497 to PRE_first_tail_x15_r0_body.s498 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB134 ((nth? PRE_first_tail_x15_r0_body.ks 497).getD 0) PRE_first_tail_x15_r0_body.s497 PRE_first_tail_x15_r0_body.S497 = some (PRE_first_tail_x15_r0_body.s498, PRE_first_tail_x15_r0_body.S498)
boot_rfl PRE_first_tail_x15_r0_body.stepA135 from PRE_first_tail_x15_r0_body.s498 to PRE_first_tail_x15_r0_body.s499 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s498).run PRE_first_tail_x15_r0_body.S498 = some (PRE_first_tail_x15_r0_body.s499, PRE_first_tail_x15_r0_body.S499)
boot_rfl PRE_first_tail_x15_r0_body.patchB135 from PRE_first_tail_x15_r0_body.s499 to PRE_first_tail_x15_r0_body.s500 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s499).run PRE_first_tail_x15_r0_body.S499 = some (PRE_first_tail_x15_r0_body.s500, PRE_first_tail_x15_r0_body.S500)
end Host.Load.Run.Tpl
