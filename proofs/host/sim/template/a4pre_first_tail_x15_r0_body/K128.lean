import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.stepA139 from PRE_first_tail_x15_r0_body.s512 to PRE_first_tail_x15_r0_body.s513 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s512).run PRE_first_tail_x15_r0_body.S512 = some (PRE_first_tail_x15_r0_body.s513, PRE_first_tail_x15_r0_body.S513)
boot_rfl PRE_first_tail_x15_r0_body.k515 from PRE_first_tail_x15_r0_body.s515 to PRE_first_tail_x15_r0_body.s516 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB139 ((nth? PRE_first_tail_x15_r0_body.ks 515).getD 0) PRE_first_tail_x15_r0_body.s515 PRE_first_tail_x15_r0_body.S515 = some (PRE_first_tail_x15_r0_body.s516, PRE_first_tail_x15_r0_body.S516)
end Host.Load.Run.Tpl
