import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.k606 from PRE_first_tail_x15_r0_body.s606 to PRE_first_tail_x15_r0_body.s607 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB179 ((nth? PRE_first_tail_x15_r0_body.ks 606).getD 0) PRE_first_tail_x15_r0_body.s606 PRE_first_tail_x15_r0_body.S606 = some (PRE_first_tail_x15_r0_body.s607, PRE_first_tail_x15_r0_body.S607)
boot_rfl PRE_first_tail_x15_r0_body.stepA180 from PRE_first_tail_x15_r0_body.s607 to PRE_first_tail_x15_r0_body.s608 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s607).run PRE_first_tail_x15_r0_body.S607 = some (PRE_first_tail_x15_r0_body.s608, PRE_first_tail_x15_r0_body.S608)
end Host.Load.Run.Tpl
