import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.k1420 from PRE_first_tail_x15_r0_body.s1420 to PRE_first_tail_x15_r0_body.s1421 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB383 ((nth? PRE_first_tail_x15_r0_body.ks 1420).getD 0) PRE_first_tail_x15_r0_body.s1420 PRE_first_tail_x15_r0_body.S1420 = some (PRE_first_tail_x15_r0_body.s1421, PRE_first_tail_x15_r0_body.S1421)
boot_rfl PRE_first_tail_x15_r0_body.stepA384 from PRE_first_tail_x15_r0_body.s1421 to PRE_first_tail_x15_r0_body.s1422 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1421).run PRE_first_tail_x15_r0_body.S1421 = some (PRE_first_tail_x15_r0_body.s1422, PRE_first_tail_x15_r0_body.S1422)
boot_rfl PRE_first_tail_x15_r0_body.patchB384 from PRE_first_tail_x15_r0_body.s1422 to PRE_first_tail_x15_r0_body.s1423 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1422).run PRE_first_tail_x15_r0_body.S1422 = some (PRE_first_tail_x15_r0_body.s1423, PRE_first_tail_x15_r0_body.S1423)
boot_rfl PRE_first_tail_x15_r0_body.k1423 from PRE_first_tail_x15_r0_body.s1423 to PRE_first_tail_x15_r0_body.s1424 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB384 ((nth? PRE_first_tail_x15_r0_body.ks 1423).getD 0) PRE_first_tail_x15_r0_body.s1423 PRE_first_tail_x15_r0_body.S1423 = some (PRE_first_tail_x15_r0_body.s1424, PRE_first_tail_x15_r0_body.S1424)
end Host.Load.Run.Tpl
