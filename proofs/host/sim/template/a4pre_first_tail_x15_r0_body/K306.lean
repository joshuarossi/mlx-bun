import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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
boot_rfl PRE_first_tail_x15_r0_body.k1225 from PRE_first_tail_x15_r0_body.s1225 to PRE_first_tail_x15_r0_body.s1226 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB362 ((nth? PRE_first_tail_x15_r0_body.ks 1225).getD 0) PRE_first_tail_x15_r0_body.s1225 PRE_first_tail_x15_r0_body.S1225 = some (PRE_first_tail_x15_r0_body.s1226, PRE_first_tail_x15_r0_body.S1226)
boot_rfl PRE_first_tail_x15_r0_body.stepA363 from PRE_first_tail_x15_r0_body.s1226 to PRE_first_tail_x15_r0_body.s1227 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1226).run PRE_first_tail_x15_r0_body.S1226 = some (PRE_first_tail_x15_r0_body.s1227, PRE_first_tail_x15_r0_body.S1227)
boot_rfl PRE_first_tail_x15_r0_body.patchB363 from PRE_first_tail_x15_r0_body.s1227 to PRE_first_tail_x15_r0_body.s1228 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1227).run PRE_first_tail_x15_r0_body.S1227 = some (PRE_first_tail_x15_r0_body.s1228, PRE_first_tail_x15_r0_body.S1228)
end Host.Load.Run.Tpl
