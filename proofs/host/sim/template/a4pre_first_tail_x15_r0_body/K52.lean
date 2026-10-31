import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.k208 from PRE_first_tail_x15_r0_body.s208 to PRE_first_tail_x15_r0_body.s209 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB56 ((nth? PRE_first_tail_x15_r0_body.ks 208).getD 0) PRE_first_tail_x15_r0_body.s208 PRE_first_tail_x15_r0_body.S208 = some (PRE_first_tail_x15_r0_body.s209, PRE_first_tail_x15_r0_body.S209)
boot_rfl PRE_first_tail_x15_r0_body.stepA57 from PRE_first_tail_x15_r0_body.s209 to PRE_first_tail_x15_r0_body.s210 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s209).run PRE_first_tail_x15_r0_body.S209 = some (PRE_first_tail_x15_r0_body.s210, PRE_first_tail_x15_r0_body.S210)
boot_rfl PRE_first_tail_x15_r0_body.patchB57 from PRE_first_tail_x15_r0_body.s210 to PRE_first_tail_x15_r0_body.s211 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s210).run PRE_first_tail_x15_r0_body.S210 = some (PRE_first_tail_x15_r0_body.s211, PRE_first_tail_x15_r0_body.S211)
boot_rfl PRE_first_tail_x15_r0_body.k211 from PRE_first_tail_x15_r0_body.s211 to PRE_first_tail_x15_r0_body.s212 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB57 ((nth? PRE_first_tail_x15_r0_body.ks 211).getD 0) PRE_first_tail_x15_r0_body.s211 PRE_first_tail_x15_r0_body.S211 = some (PRE_first_tail_x15_r0_body.s212, PRE_first_tail_x15_r0_body.S212)
end Host.Load.Run.Tpl
