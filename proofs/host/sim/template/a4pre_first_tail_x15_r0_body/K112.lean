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
boot_rfl PRE_first_tail_x15_r0_body.k449 from PRE_first_tail_x15_r0_body.s449 to PRE_first_tail_x15_r0_body.s450 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB121 ((nth? PRE_first_tail_x15_r0_body.ks 449).getD 0) PRE_first_tail_x15_r0_body.s449 PRE_first_tail_x15_r0_body.S449 = some (PRE_first_tail_x15_r0_body.s450, PRE_first_tail_x15_r0_body.S450)
boot_rfl PRE_first_tail_x15_r0_body.stepA122 from PRE_first_tail_x15_r0_body.s450 to PRE_first_tail_x15_r0_body.s451 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s450).run PRE_first_tail_x15_r0_body.S450 = some (PRE_first_tail_x15_r0_body.s451, PRE_first_tail_x15_r0_body.S451)
boot_rfl PRE_first_tail_x15_r0_body.patchB122 from PRE_first_tail_x15_r0_body.s451 to PRE_first_tail_x15_r0_body.s452 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s451).run PRE_first_tail_x15_r0_body.S451 = some (PRE_first_tail_x15_r0_body.s452, PRE_first_tail_x15_r0_body.S452)
end Host.Load.Run.Tpl
