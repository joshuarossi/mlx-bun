import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.k88 from PRE_first_tail_x15_r0_body.s88 to PRE_first_tail_x15_r0_body.s89 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB24 ((nth? PRE_first_tail_x15_r0_body.ks 88).getD 0) PRE_first_tail_x15_r0_body.s88 PRE_first_tail_x15_r0_body.S88 = some (PRE_first_tail_x15_r0_body.s89, PRE_first_tail_x15_r0_body.S89)
boot_rfl PRE_first_tail_x15_r0_body.k89 from PRE_first_tail_x15_r0_body.s89 to PRE_first_tail_x15_r0_body.s90 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB24 ((nth? PRE_first_tail_x15_r0_body.ks 89).getD 0) PRE_first_tail_x15_r0_body.s89 PRE_first_tail_x15_r0_body.S89 = some (PRE_first_tail_x15_r0_body.s90, PRE_first_tail_x15_r0_body.S90)
boot_rfl PRE_first_tail_x15_r0_body.stepA25 from PRE_first_tail_x15_r0_body.s90 to PRE_first_tail_x15_r0_body.s91 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s90).run PRE_first_tail_x15_r0_body.S90 = some (PRE_first_tail_x15_r0_body.s91, PRE_first_tail_x15_r0_body.S91)
boot_rfl PRE_first_tail_x15_r0_body.patchB25 from PRE_first_tail_x15_r0_body.s91 to PRE_first_tail_x15_r0_body.s92 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s91).run PRE_first_tail_x15_r0_body.S91 = some (PRE_first_tail_x15_r0_body.s92, PRE_first_tail_x15_r0_body.S92)
end Host.Load.Run.Tpl
