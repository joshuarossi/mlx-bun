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
boot_rfl PRE_first_tail_x15_r0_body.k1020 from PRE_first_tail_x15_r0_body.s1020 to PRE_first_tail_x15_r0_body.s1021 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB275 ((nth? PRE_first_tail_x15_r0_body.ks 1020).getD 0) PRE_first_tail_x15_r0_body.s1020 PRE_first_tail_x15_r0_body.S1020 = some (PRE_first_tail_x15_r0_body.s1021, PRE_first_tail_x15_r0_body.S1021)
boot_rfl PRE_first_tail_x15_r0_body.stepA276 from PRE_first_tail_x15_r0_body.s1021 to PRE_first_tail_x15_r0_body.s1022 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1021).run PRE_first_tail_x15_r0_body.S1021 = some (PRE_first_tail_x15_r0_body.s1022, PRE_first_tail_x15_r0_body.S1022)
end Host.Load.Run.Tpl
