import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.k593 from PRE_first_tail_x15_r0_body.s593 to PRE_first_tail_x15_r0_body.s594 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB160 ((nth? PRE_first_tail_x15_r0_body.ks 593).getD 0) PRE_first_tail_x15_r0_body.s593 PRE_first_tail_x15_r0_body.S593 = some (PRE_first_tail_x15_r0_body.s594, PRE_first_tail_x15_r0_body.S594)
boot_rfl PRE_first_tail_x15_r0_body.stepA161 from PRE_first_tail_x15_r0_body.s594 to PRE_first_tail_x15_r0_body.s595 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s594).run PRE_first_tail_x15_r0_body.S594 = some (PRE_first_tail_x15_r0_body.s595, PRE_first_tail_x15_r0_body.S595)
boot_rfl PRE_first_tail_x15_r0_body.patchB161 from PRE_first_tail_x15_r0_body.s595 to PRE_first_tail_x15_r0_body.s596 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s595).run PRE_first_tail_x15_r0_body.S595 = some (PRE_first_tail_x15_r0_body.s596, PRE_first_tail_x15_r0_body.S596)
end Host.Load.Run.Tpl
