import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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
boot_rfl PRE_first_tail_x15_r0_body.patchB304 from PRE_first_tail_x15_r0_body.s1028 to PRE_first_tail_x15_r0_body.s1029 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1028).run PRE_first_tail_x15_r0_body.S1028 = some (PRE_first_tail_x15_r0_body.s1029, PRE_first_tail_x15_r0_body.S1029)
boot_rfl PRE_first_tail_x15_r0_body.k1029 from PRE_first_tail_x15_r0_body.s1029 to PRE_first_tail_x15_r0_body.s1030 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB304 ((nth? PRE_first_tail_x15_r0_body.ks 1029).getD 0) PRE_first_tail_x15_r0_body.s1029 PRE_first_tail_x15_r0_body.S1029 = some (PRE_first_tail_x15_r0_body.s1030, PRE_first_tail_x15_r0_body.S1030)
boot_rfl PRE_first_tail_x15_r0_body.stepA305 from PRE_first_tail_x15_r0_body.s1030 to PRE_first_tail_x15_r0_body.s1031 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1030).run PRE_first_tail_x15_r0_body.S1030 = some (PRE_first_tail_x15_r0_body.s1031, PRE_first_tail_x15_r0_body.S1031)
boot_rfl PRE_first_tail_x15_r0_body.patchB305 from PRE_first_tail_x15_r0_body.s1031 to PRE_first_tail_x15_r0_body.s1032 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1031).run PRE_first_tail_x15_r0_body.S1031 = some (PRE_first_tail_x15_r0_body.s1032, PRE_first_tail_x15_r0_body.S1032)
end Host.Load.Run.Tpl
