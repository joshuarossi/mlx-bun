import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.stepA126 from PRE_first_tail_x15_r0_body.s424 to PRE_first_tail_x15_r0_body.s425 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s424).run PRE_first_tail_x15_r0_body.S424 = some (PRE_first_tail_x15_r0_body.s425, PRE_first_tail_x15_r0_body.S425)
boot_rfl PRE_first_tail_x15_r0_body.patchB126 from PRE_first_tail_x15_r0_body.s425 to PRE_first_tail_x15_r0_body.s426 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s425).run PRE_first_tail_x15_r0_body.S425 = some (PRE_first_tail_x15_r0_body.s426, PRE_first_tail_x15_r0_body.S426)
boot_rfl PRE_first_tail_x15_r0_body.k426 from PRE_first_tail_x15_r0_body.s426 to PRE_first_tail_x15_r0_body.s427 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB126 ((nth? PRE_first_tail_x15_r0_body.ks 426).getD 0) PRE_first_tail_x15_r0_body.s426 PRE_first_tail_x15_r0_body.S426 = some (PRE_first_tail_x15_r0_body.s427, PRE_first_tail_x15_r0_body.S427)
boot_rfl PRE_first_tail_x15_r0_body.stepA127 from PRE_first_tail_x15_r0_body.s427 to PRE_first_tail_x15_r0_body.s428 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s427).run PRE_first_tail_x15_r0_body.S427 = some (PRE_first_tail_x15_r0_body.s428, PRE_first_tail_x15_r0_body.S428)
end Host.Load.Run.Tpl
