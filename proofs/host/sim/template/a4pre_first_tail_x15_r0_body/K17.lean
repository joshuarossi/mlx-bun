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
boot_rfl PRE_first_tail_x15_r0_body.patchB19 from PRE_first_tail_x15_r0_body.s68 to PRE_first_tail_x15_r0_body.s69 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s68).run PRE_first_tail_x15_r0_body.S68 = some (PRE_first_tail_x15_r0_body.s69, PRE_first_tail_x15_r0_body.S69)
boot_rfl PRE_first_tail_x15_r0_body.k69 from PRE_first_tail_x15_r0_body.s69 to PRE_first_tail_x15_r0_body.s70 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB19 ((nth? PRE_first_tail_x15_r0_body.ks 69).getD 0) PRE_first_tail_x15_r0_body.s69 PRE_first_tail_x15_r0_body.S69 = some (PRE_first_tail_x15_r0_body.s70, PRE_first_tail_x15_r0_body.S70)
boot_rfl PRE_first_tail_x15_r0_body.stepA20 from PRE_first_tail_x15_r0_body.s70 to PRE_first_tail_x15_r0_body.s71 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s70).run PRE_first_tail_x15_r0_body.S70 = some (PRE_first_tail_x15_r0_body.s71, PRE_first_tail_x15_r0_body.S71)
boot_rfl PRE_first_tail_x15_r0_body.patchB20 from PRE_first_tail_x15_r0_body.s71 to PRE_first_tail_x15_r0_body.s72 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s71).run PRE_first_tail_x15_r0_body.S71 = some (PRE_first_tail_x15_r0_body.s72, PRE_first_tail_x15_r0_body.S72)
end Host.Load.Run.Tpl
