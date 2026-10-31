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
boot_rfl PRE_first_tail_x15_r0_body.stepA66 from PRE_first_tail_x15_r0_body.s220 to PRE_first_tail_x15_r0_body.s221 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s220).run PRE_first_tail_x15_r0_body.S220 = some (PRE_first_tail_x15_r0_body.s221, PRE_first_tail_x15_r0_body.S221)
boot_rfl PRE_first_tail_x15_r0_body.patchB66 from PRE_first_tail_x15_r0_body.s221 to PRE_first_tail_x15_r0_body.s222 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s221).run PRE_first_tail_x15_r0_body.S221 = some (PRE_first_tail_x15_r0_body.s222, PRE_first_tail_x15_r0_body.S222)
boot_rfl PRE_first_tail_x15_r0_body.k222 from PRE_first_tail_x15_r0_body.s222 to PRE_first_tail_x15_r0_body.s223 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB66 ((nth? PRE_first_tail_x15_r0_body.ks 222).getD 0) PRE_first_tail_x15_r0_body.s222 PRE_first_tail_x15_r0_body.S222 = some (PRE_first_tail_x15_r0_body.s223, PRE_first_tail_x15_r0_body.S223)
boot_rfl PRE_first_tail_x15_r0_body.stepA67 from PRE_first_tail_x15_r0_body.s223 to PRE_first_tail_x15_r0_body.s224 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s223).run PRE_first_tail_x15_r0_body.S223 = some (PRE_first_tail_x15_r0_body.s224, PRE_first_tail_x15_r0_body.S224)
end Host.Load.Run.Tpl
