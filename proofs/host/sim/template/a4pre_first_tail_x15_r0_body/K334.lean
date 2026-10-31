import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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
boot_rfl PRE_first_tail_x15_r0_body.patchB361 from PRE_first_tail_x15_r0_body.s1336 to PRE_first_tail_x15_r0_body.s1337 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1336).run PRE_first_tail_x15_r0_body.S1336 = some (PRE_first_tail_x15_r0_body.s1337, PRE_first_tail_x15_r0_body.S1337)
boot_rfl PRE_first_tail_x15_r0_body.k1337 from PRE_first_tail_x15_r0_body.s1337 to PRE_first_tail_x15_r0_body.s1338 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB361 ((nth? PRE_first_tail_x15_r0_body.ks 1337).getD 0) PRE_first_tail_x15_r0_body.s1337 PRE_first_tail_x15_r0_body.S1337 = some (PRE_first_tail_x15_r0_body.s1338, PRE_first_tail_x15_r0_body.S1338)
boot_rfl PRE_first_tail_x15_r0_body.stepA362 from PRE_first_tail_x15_r0_body.s1338 to PRE_first_tail_x15_r0_body.s1339 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1338).run PRE_first_tail_x15_r0_body.S1338 = some (PRE_first_tail_x15_r0_body.s1339, PRE_first_tail_x15_r0_body.S1339)
end Host.Load.Run.Tpl
