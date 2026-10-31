import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.stepA206 from PRE_first_tail_x15_r0_body.s760 to PRE_first_tail_x15_r0_body.s761 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s760).run PRE_first_tail_x15_r0_body.S760 = some (PRE_first_tail_x15_r0_body.s761, PRE_first_tail_x15_r0_body.S761)
boot_rfl PRE_first_tail_x15_r0_body.patchB206 from PRE_first_tail_x15_r0_body.s761 to PRE_first_tail_x15_r0_body.s762 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s761).run PRE_first_tail_x15_r0_body.S761 = some (PRE_first_tail_x15_r0_body.s762, PRE_first_tail_x15_r0_body.S762)
boot_rfl PRE_first_tail_x15_r0_body.k762 from PRE_first_tail_x15_r0_body.s762 to PRE_first_tail_x15_r0_body.s763 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB206 ((nth? PRE_first_tail_x15_r0_body.ks 762).getD 0) PRE_first_tail_x15_r0_body.s762 PRE_first_tail_x15_r0_body.S762 = some (PRE_first_tail_x15_r0_body.s763, PRE_first_tail_x15_r0_body.S763)
boot_rfl PRE_first_tail_x15_r0_body.stepA207 from PRE_first_tail_x15_r0_body.s763 to PRE_first_tail_x15_r0_body.s764 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s763).run PRE_first_tail_x15_r0_body.S763 = some (PRE_first_tail_x15_r0_body.s764, PRE_first_tail_x15_r0_body.S764)
end Host.Load.Run.Tpl
