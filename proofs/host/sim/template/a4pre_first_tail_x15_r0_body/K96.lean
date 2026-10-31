import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.k385 from PRE_first_tail_x15_r0_body.s385 to PRE_first_tail_x15_r0_body.s386 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB114 ((nth? PRE_first_tail_x15_r0_body.ks 385).getD 0) PRE_first_tail_x15_r0_body.s385 PRE_first_tail_x15_r0_body.S385 = some (PRE_first_tail_x15_r0_body.s386, PRE_first_tail_x15_r0_body.S386)
boot_rfl PRE_first_tail_x15_r0_body.stepA115 from PRE_first_tail_x15_r0_body.s386 to PRE_first_tail_x15_r0_body.s387 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s386).run PRE_first_tail_x15_r0_body.S386 = some (PRE_first_tail_x15_r0_body.s387, PRE_first_tail_x15_r0_body.S387)
boot_rfl PRE_first_tail_x15_r0_body.patchB115 from PRE_first_tail_x15_r0_body.s387 to PRE_first_tail_x15_r0_body.s388 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s387).run PRE_first_tail_x15_r0_body.S387 = some (PRE_first_tail_x15_r0_body.s388, PRE_first_tail_x15_r0_body.S388)
end Host.Load.Run.Tpl
