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
boot_rfl PRE_first_tail_x15_r0_body.patchB134 from PRE_first_tail_x15_r0_body.s452 to PRE_first_tail_x15_r0_body.s453 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s452).run PRE_first_tail_x15_r0_body.S452 = some (PRE_first_tail_x15_r0_body.s453, PRE_first_tail_x15_r0_body.S453)
boot_rfl PRE_first_tail_x15_r0_body.k453 from PRE_first_tail_x15_r0_body.s453 to PRE_first_tail_x15_r0_body.s454 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB134 ((nth? PRE_first_tail_x15_r0_body.ks 453).getD 0) PRE_first_tail_x15_r0_body.s453 PRE_first_tail_x15_r0_body.S453 = some (PRE_first_tail_x15_r0_body.s454, PRE_first_tail_x15_r0_body.S454)
boot_rfl PRE_first_tail_x15_r0_body.stepA135 from PRE_first_tail_x15_r0_body.s454 to PRE_first_tail_x15_r0_body.s455 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s454).run PRE_first_tail_x15_r0_body.S454 = some (PRE_first_tail_x15_r0_body.s455, PRE_first_tail_x15_r0_body.S455)
boot_rfl PRE_first_tail_x15_r0_body.patchB135 from PRE_first_tail_x15_r0_body.s455 to PRE_first_tail_x15_r0_body.s456 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s455).run PRE_first_tail_x15_r0_body.S455 = some (PRE_first_tail_x15_r0_body.s456, PRE_first_tail_x15_r0_body.S456)
end Host.Load.Run.Tpl
