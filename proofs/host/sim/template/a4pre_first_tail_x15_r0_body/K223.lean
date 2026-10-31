import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.k894 from PRE_first_tail_x15_r0_body.s894 to PRE_first_tail_x15_r0_body.s895 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB264 ((nth? PRE_first_tail_x15_r0_body.ks 894).getD 0) PRE_first_tail_x15_r0_body.s894 PRE_first_tail_x15_r0_body.S894 = some (PRE_first_tail_x15_r0_body.s895, PRE_first_tail_x15_r0_body.S895)
boot_rfl PRE_first_tail_x15_r0_body.stepA265 from PRE_first_tail_x15_r0_body.s895 to PRE_first_tail_x15_r0_body.s896 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s895).run PRE_first_tail_x15_r0_body.S895 = some (PRE_first_tail_x15_r0_body.s896, PRE_first_tail_x15_r0_body.S896)
end Host.Load.Run.Tpl
