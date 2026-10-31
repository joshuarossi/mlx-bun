import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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
boot_rfl PRE_first_tail_x15_r0_body.patchB125 from PRE_first_tail_x15_r0_body.s464 to PRE_first_tail_x15_r0_body.s465 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s464).run PRE_first_tail_x15_r0_body.S464 = some (PRE_first_tail_x15_r0_body.s465, PRE_first_tail_x15_r0_body.S465)
boot_rfl PRE_first_tail_x15_r0_body.k465 from PRE_first_tail_x15_r0_body.s465 to PRE_first_tail_x15_r0_body.s466 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB125 ((nth? PRE_first_tail_x15_r0_body.ks 465).getD 0) PRE_first_tail_x15_r0_body.s465 PRE_first_tail_x15_r0_body.S465 = some (PRE_first_tail_x15_r0_body.s466, PRE_first_tail_x15_r0_body.S466)
boot_rfl PRE_first_tail_x15_r0_body.stepA126 from PRE_first_tail_x15_r0_body.s466 to PRE_first_tail_x15_r0_body.s467 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s466).run PRE_first_tail_x15_r0_body.S466 = some (PRE_first_tail_x15_r0_body.s467, PRE_first_tail_x15_r0_body.S467)
boot_rfl PRE_first_tail_x15_r0_body.patchB126 from PRE_first_tail_x15_r0_body.s467 to PRE_first_tail_x15_r0_body.s468 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s467).run PRE_first_tail_x15_r0_body.S467 = some (PRE_first_tail_x15_r0_body.s468, PRE_first_tail_x15_r0_body.S468)
end Host.Load.Run.Tpl
