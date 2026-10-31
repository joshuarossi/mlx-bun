import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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
boot_rfl PRE_first_tail_x15_r0_body.patchB74 from PRE_first_tail_x15_r0_body.s248 to PRE_first_tail_x15_r0_body.s249 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s248).run PRE_first_tail_x15_r0_body.S248 = some (PRE_first_tail_x15_r0_body.s249, PRE_first_tail_x15_r0_body.S249)
boot_rfl PRE_first_tail_x15_r0_body.k249 from PRE_first_tail_x15_r0_body.s249 to PRE_first_tail_x15_r0_body.s250 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB74 ((nth? PRE_first_tail_x15_r0_body.ks 249).getD 0) PRE_first_tail_x15_r0_body.s249 PRE_first_tail_x15_r0_body.S249 = some (PRE_first_tail_x15_r0_body.s250, PRE_first_tail_x15_r0_body.S250)
boot_rfl PRE_first_tail_x15_r0_body.stepA75 from PRE_first_tail_x15_r0_body.s250 to PRE_first_tail_x15_r0_body.s251 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s250).run PRE_first_tail_x15_r0_body.S250 = some (PRE_first_tail_x15_r0_body.s251, PRE_first_tail_x15_r0_body.S251)
end Host.Load.Run.Tpl
