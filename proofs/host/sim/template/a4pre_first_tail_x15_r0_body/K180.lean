import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.k720 from PRE_first_tail_x15_r0_body.s720 to PRE_first_tail_x15_r0_body.s721 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB213 ((nth? PRE_first_tail_x15_r0_body.ks 720).getD 0) PRE_first_tail_x15_r0_body.s720 PRE_first_tail_x15_r0_body.S720 = some (PRE_first_tail_x15_r0_body.s721, PRE_first_tail_x15_r0_body.S721)
boot_rfl PRE_first_tail_x15_r0_body.stepA214 from PRE_first_tail_x15_r0_body.s721 to PRE_first_tail_x15_r0_body.s722 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s721).run PRE_first_tail_x15_r0_body.S721 = some (PRE_first_tail_x15_r0_body.s722, PRE_first_tail_x15_r0_body.S722)
end Host.Load.Run.Tpl
