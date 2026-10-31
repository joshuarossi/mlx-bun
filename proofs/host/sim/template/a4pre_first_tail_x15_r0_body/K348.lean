import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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
boot_rfl PRE_first_tail_x15_r0_body.stepA376 from PRE_first_tail_x15_r0_body.s1392 to PRE_first_tail_x15_r0_body.s1393 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1392).run PRE_first_tail_x15_r0_body.S1392 = some (PRE_first_tail_x15_r0_body.s1393, PRE_first_tail_x15_r0_body.S1393)
boot_rfl PRE_first_tail_x15_r0_body.patchB376 from PRE_first_tail_x15_r0_body.s1393 to PRE_first_tail_x15_r0_body.s1394 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1393).run PRE_first_tail_x15_r0_body.S1393 = some (PRE_first_tail_x15_r0_body.s1394, PRE_first_tail_x15_r0_body.S1394)
boot_rfl PRE_first_tail_x15_r0_body.k1394 from PRE_first_tail_x15_r0_body.s1394 to PRE_first_tail_x15_r0_body.s1395 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB376 ((nth? PRE_first_tail_x15_r0_body.ks 1394).getD 0) PRE_first_tail_x15_r0_body.s1394 PRE_first_tail_x15_r0_body.S1394 = some (PRE_first_tail_x15_r0_body.s1395, PRE_first_tail_x15_r0_body.S1395)
boot_rfl PRE_first_tail_x15_r0_body.stepA377 from PRE_first_tail_x15_r0_body.s1395 to PRE_first_tail_x15_r0_body.s1396 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1395).run PRE_first_tail_x15_r0_body.S1395 = some (PRE_first_tail_x15_r0_body.s1396, PRE_first_tail_x15_r0_body.S1396)
end Host.Load.Run.Tpl
