import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.patchB17 from PRE_first_tail_x15_r0_body.s56 to PRE_first_tail_x15_r0_body.s57 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s56).run PRE_first_tail_x15_r0_body.S56 = some (PRE_first_tail_x15_r0_body.s57, PRE_first_tail_x15_r0_body.S57)
boot_rfl PRE_first_tail_x15_r0_body.k57 from PRE_first_tail_x15_r0_body.s57 to PRE_first_tail_x15_r0_body.s58 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB17 ((nth? PRE_first_tail_x15_r0_body.ks 57).getD 0) PRE_first_tail_x15_r0_body.s57 PRE_first_tail_x15_r0_body.S57 = some (PRE_first_tail_x15_r0_body.s58, PRE_first_tail_x15_r0_body.S58)
boot_rfl PRE_first_tail_x15_r0_body.stepA18 from PRE_first_tail_x15_r0_body.s58 to PRE_first_tail_x15_r0_body.s59 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s58).run PRE_first_tail_x15_r0_body.S58 = some (PRE_first_tail_x15_r0_body.s59, PRE_first_tail_x15_r0_body.S59)
boot_rfl PRE_first_tail_x15_r0_body.patchB18 from PRE_first_tail_x15_r0_body.s59 to PRE_first_tail_x15_r0_body.s60 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s59).run PRE_first_tail_x15_r0_body.S59 = some (PRE_first_tail_x15_r0_body.s60, PRE_first_tail_x15_r0_body.S60)
end Host.Load.Run.Tpl
