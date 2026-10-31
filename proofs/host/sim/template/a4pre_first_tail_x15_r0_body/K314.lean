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
boot_rfl PRE_first_tail_x15_r0_body.patchB339 from PRE_first_tail_x15_r0_body.s1256 to PRE_first_tail_x15_r0_body.s1257 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1256).run PRE_first_tail_x15_r0_body.S1256 = some (PRE_first_tail_x15_r0_body.s1257, PRE_first_tail_x15_r0_body.S1257)
boot_rfl PRE_first_tail_x15_r0_body.k1257 from PRE_first_tail_x15_r0_body.s1257 to PRE_first_tail_x15_r0_body.s1258 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB339 ((nth? PRE_first_tail_x15_r0_body.ks 1257).getD 0) PRE_first_tail_x15_r0_body.s1257 PRE_first_tail_x15_r0_body.S1257 = some (PRE_first_tail_x15_r0_body.s1258, PRE_first_tail_x15_r0_body.S1258)
boot_rfl PRE_first_tail_x15_r0_body.k1258 from PRE_first_tail_x15_r0_body.s1258 to PRE_first_tail_x15_r0_body.s1259 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB339 ((nth? PRE_first_tail_x15_r0_body.ks 1258).getD 0) PRE_first_tail_x15_r0_body.s1258 PRE_first_tail_x15_r0_body.S1258 = some (PRE_first_tail_x15_r0_body.s1259, PRE_first_tail_x15_r0_body.S1259)
boot_rfl PRE_first_tail_x15_r0_body.stepA340 from PRE_first_tail_x15_r0_body.s1259 to PRE_first_tail_x15_r0_body.s1260 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1259).run PRE_first_tail_x15_r0_body.S1259 = some (PRE_first_tail_x15_r0_body.s1260, PRE_first_tail_x15_r0_body.S1260)
end Host.Load.Run.Tpl
