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
boot_rfl PRE_first_tail_x15_r0_body.k504 from PRE_first_tail_x15_r0_body.s504 to PRE_first_tail_x15_r0_body.s505 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB149 ((nth? PRE_first_tail_x15_r0_body.ks 504).getD 0) PRE_first_tail_x15_r0_body.s504 PRE_first_tail_x15_r0_body.S504 = some (PRE_first_tail_x15_r0_body.s505, PRE_first_tail_x15_r0_body.S505)
boot_rfl PRE_first_tail_x15_r0_body.stepA150 from PRE_first_tail_x15_r0_body.s505 to PRE_first_tail_x15_r0_body.s506 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s505).run PRE_first_tail_x15_r0_body.S505 = some (PRE_first_tail_x15_r0_body.s506, PRE_first_tail_x15_r0_body.S506)
boot_rfl PRE_first_tail_x15_r0_body.patchB150 from PRE_first_tail_x15_r0_body.s506 to PRE_first_tail_x15_r0_body.s507 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s506).run PRE_first_tail_x15_r0_body.S506 = some (PRE_first_tail_x15_r0_body.s507, PRE_first_tail_x15_r0_body.S507)
boot_rfl PRE_first_tail_x15_r0_body.k507 from PRE_first_tail_x15_r0_body.s507 to PRE_first_tail_x15_r0_body.s508 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB150 ((nth? PRE_first_tail_x15_r0_body.ks 507).getD 0) PRE_first_tail_x15_r0_body.s507 PRE_first_tail_x15_r0_body.S507 = some (PRE_first_tail_x15_r0_body.s508, PRE_first_tail_x15_r0_body.S508)
end Host.Load.Run.Tpl
