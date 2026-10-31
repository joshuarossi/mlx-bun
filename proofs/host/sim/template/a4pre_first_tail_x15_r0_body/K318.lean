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
boot_rfl PRE_first_tail_x15_r0_body.patchB343 from PRE_first_tail_x15_r0_body.s1272 to PRE_first_tail_x15_r0_body.s1273 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1272).run PRE_first_tail_x15_r0_body.S1272 = some (PRE_first_tail_x15_r0_body.s1273, PRE_first_tail_x15_r0_body.S1273)
boot_rfl PRE_first_tail_x15_r0_body.k1273 from PRE_first_tail_x15_r0_body.s1273 to PRE_first_tail_x15_r0_body.s1274 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB343 ((nth? PRE_first_tail_x15_r0_body.ks 1273).getD 0) PRE_first_tail_x15_r0_body.s1273 PRE_first_tail_x15_r0_body.S1273 = some (PRE_first_tail_x15_r0_body.s1274, PRE_first_tail_x15_r0_body.S1274)
boot_rfl PRE_first_tail_x15_r0_body.stepA344 from PRE_first_tail_x15_r0_body.s1274 to PRE_first_tail_x15_r0_body.s1275 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1274).run PRE_first_tail_x15_r0_body.S1274 = some (PRE_first_tail_x15_r0_body.s1275, PRE_first_tail_x15_r0_body.S1275)
boot_rfl PRE_first_tail_x15_r0_body.patchB344 from PRE_first_tail_x15_r0_body.s1275 to PRE_first_tail_x15_r0_body.s1276 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1275).run PRE_first_tail_x15_r0_body.S1275 = some (PRE_first_tail_x15_r0_body.s1276, PRE_first_tail_x15_r0_body.S1276)
end Host.Load.Run.Tpl
