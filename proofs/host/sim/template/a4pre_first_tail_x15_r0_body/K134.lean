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
boot_rfl PRE_first_tail_x15_r0_body.k536 from PRE_first_tail_x15_r0_body.s536 to PRE_first_tail_x15_r0_body.s537 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB145 ((nth? PRE_first_tail_x15_r0_body.ks 536).getD 0) PRE_first_tail_x15_r0_body.s536 PRE_first_tail_x15_r0_body.S536 = some (PRE_first_tail_x15_r0_body.s537, PRE_first_tail_x15_r0_body.S537)
boot_rfl PRE_first_tail_x15_r0_body.stepA146 from PRE_first_tail_x15_r0_body.s537 to PRE_first_tail_x15_r0_body.s538 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s537).run PRE_first_tail_x15_r0_body.S537 = some (PRE_first_tail_x15_r0_body.s538, PRE_first_tail_x15_r0_body.S538)
boot_rfl PRE_first_tail_x15_r0_body.patchB146 from PRE_first_tail_x15_r0_body.s538 to PRE_first_tail_x15_r0_body.s539 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s538).run PRE_first_tail_x15_r0_body.S538 = some (PRE_first_tail_x15_r0_body.s539, PRE_first_tail_x15_r0_body.S539)
boot_rfl PRE_first_tail_x15_r0_body.k539 from PRE_first_tail_x15_r0_body.s539 to PRE_first_tail_x15_r0_body.s540 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB146 ((nth? PRE_first_tail_x15_r0_body.ks 539).getD 0) PRE_first_tail_x15_r0_body.s539 PRE_first_tail_x15_r0_body.S539 = some (PRE_first_tail_x15_r0_body.s540, PRE_first_tail_x15_r0_body.S540)
end Host.Load.Run.Tpl
