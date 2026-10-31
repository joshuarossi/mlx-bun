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
boot_rfl PRE_first_tail_x15_r0_body.patchB159 from PRE_first_tail_x15_r0_body.s536 to PRE_first_tail_x15_r0_body.s537 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s536).run PRE_first_tail_x15_r0_body.S536 = some (PRE_first_tail_x15_r0_body.s537, PRE_first_tail_x15_r0_body.S537)
boot_rfl PRE_first_tail_x15_r0_body.k537 from PRE_first_tail_x15_r0_body.s537 to PRE_first_tail_x15_r0_body.s538 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB159 ((nth? PRE_first_tail_x15_r0_body.ks 537).getD 0) PRE_first_tail_x15_r0_body.s537 PRE_first_tail_x15_r0_body.S537 = some (PRE_first_tail_x15_r0_body.s538, PRE_first_tail_x15_r0_body.S538)
boot_rfl PRE_first_tail_x15_r0_body.stepA160 from PRE_first_tail_x15_r0_body.s538 to PRE_first_tail_x15_r0_body.s539 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s538).run PRE_first_tail_x15_r0_body.S538 = some (PRE_first_tail_x15_r0_body.s539, PRE_first_tail_x15_r0_body.S539)
end Host.Load.Run.Tpl
