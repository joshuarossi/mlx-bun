import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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
boot_rfl PRE_first_tail_x15_r0_body.stepA342 from PRE_first_tail_x15_r0_body.s1268 to PRE_first_tail_x15_r0_body.s1269 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1268).run PRE_first_tail_x15_r0_body.S1268 = some (PRE_first_tail_x15_r0_body.s1269, PRE_first_tail_x15_r0_body.S1269)
boot_rfl PRE_first_tail_x15_r0_body.patchB342 from PRE_first_tail_x15_r0_body.s1269 to PRE_first_tail_x15_r0_body.s1270 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1269).run PRE_first_tail_x15_r0_body.S1269 = some (PRE_first_tail_x15_r0_body.s1270, PRE_first_tail_x15_r0_body.S1270)
boot_rfl PRE_first_tail_x15_r0_body.k1270 from PRE_first_tail_x15_r0_body.s1270 to PRE_first_tail_x15_r0_body.s1271 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB342 ((nth? PRE_first_tail_x15_r0_body.ks 1270).getD 0) PRE_first_tail_x15_r0_body.s1270 PRE_first_tail_x15_r0_body.S1270 = some (PRE_first_tail_x15_r0_body.s1271, PRE_first_tail_x15_r0_body.S1271)
boot_rfl PRE_first_tail_x15_r0_body.stepA343 from PRE_first_tail_x15_r0_body.s1271 to PRE_first_tail_x15_r0_body.s1272 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1271).run PRE_first_tail_x15_r0_body.S1271 = some (PRE_first_tail_x15_r0_body.s1272, PRE_first_tail_x15_r0_body.S1272)
end Host.Load.Run.Tpl
