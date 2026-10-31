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
boot_rfl PRE_first_tail_x15_r0_body.patchB389 from PRE_first_tail_x15_r0_body.s1316 to PRE_first_tail_x15_r0_body.s1317 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1316).run PRE_first_tail_x15_r0_body.S1316 = some (PRE_first_tail_x15_r0_body.s1317, PRE_first_tail_x15_r0_body.S1317)
boot_rfl PRE_first_tail_x15_r0_body.k1317 from PRE_first_tail_x15_r0_body.s1317 to PRE_first_tail_x15_r0_body.s1318 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB389 ((nth? PRE_first_tail_x15_r0_body.ks 1317).getD 0) PRE_first_tail_x15_r0_body.s1317 PRE_first_tail_x15_r0_body.S1317 = some (PRE_first_tail_x15_r0_body.s1318, PRE_first_tail_x15_r0_body.S1318)
boot_rfl PRE_first_tail_x15_r0_body.stepA390 from PRE_first_tail_x15_r0_body.s1318 to PRE_first_tail_x15_r0_body.s1319 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1318).run PRE_first_tail_x15_r0_body.S1318 = some (PRE_first_tail_x15_r0_body.s1319, PRE_first_tail_x15_r0_body.S1319)
boot_rfl PRE_first_tail_x15_r0_body.patchB390 from PRE_first_tail_x15_r0_body.s1319 to PRE_first_tail_x15_r0_body.s1320 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1319).run PRE_first_tail_x15_r0_body.S1319 = some (PRE_first_tail_x15_r0_body.s1320, PRE_first_tail_x15_r0_body.S1320)
end Host.Load.Run.Tpl
