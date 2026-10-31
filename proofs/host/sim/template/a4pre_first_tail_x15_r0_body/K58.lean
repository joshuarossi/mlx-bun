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
boot_rfl PRE_first_tail_x15_r0_body.k232 from PRE_first_tail_x15_r0_body.s232 to PRE_first_tail_x15_r0_body.s233 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB62 ((nth? PRE_first_tail_x15_r0_body.ks 232).getD 0) PRE_first_tail_x15_r0_body.s232 PRE_first_tail_x15_r0_body.S232 = some (PRE_first_tail_x15_r0_body.s233, PRE_first_tail_x15_r0_body.S233)
boot_rfl PRE_first_tail_x15_r0_body.stepA63 from PRE_first_tail_x15_r0_body.s233 to PRE_first_tail_x15_r0_body.s234 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s233).run PRE_first_tail_x15_r0_body.S233 = some (PRE_first_tail_x15_r0_body.s234, PRE_first_tail_x15_r0_body.S234)
boot_rfl PRE_first_tail_x15_r0_body.patchB63 from PRE_first_tail_x15_r0_body.s234 to PRE_first_tail_x15_r0_body.s235 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s234).run PRE_first_tail_x15_r0_body.S234 = some (PRE_first_tail_x15_r0_body.s235, PRE_first_tail_x15_r0_body.S235)
boot_rfl PRE_first_tail_x15_r0_body.k235 from PRE_first_tail_x15_r0_body.s235 to PRE_first_tail_x15_r0_body.s236 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB63 ((nth? PRE_first_tail_x15_r0_body.ks 235).getD 0) PRE_first_tail_x15_r0_body.s235 PRE_first_tail_x15_r0_body.S235 = some (PRE_first_tail_x15_r0_body.s236, PRE_first_tail_x15_r0_body.S236)
end Host.Load.Run.Tpl
