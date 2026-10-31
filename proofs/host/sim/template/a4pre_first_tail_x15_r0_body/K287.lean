import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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
boot_rfl PRE_first_tail_x15_r0_body.stepA340 from PRE_first_tail_x15_r0_body.s1148 to PRE_first_tail_x15_r0_body.s1149 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1148).run PRE_first_tail_x15_r0_body.S1148 = some (PRE_first_tail_x15_r0_body.s1149, PRE_first_tail_x15_r0_body.S1149)
boot_rfl PRE_first_tail_x15_r0_body.k1151 from PRE_first_tail_x15_r0_body.s1151 to PRE_first_tail_x15_r0_body.s1152 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB340 ((nth? PRE_first_tail_x15_r0_body.ks 1151).getD 0) PRE_first_tail_x15_r0_body.s1151 PRE_first_tail_x15_r0_body.S1151 = some (PRE_first_tail_x15_r0_body.s1152, PRE_first_tail_x15_r0_body.S1152)
end Host.Load.Run.Tpl
