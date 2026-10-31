import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.stepA43 from PRE_first_tail_x15_r0_body.s156 to PRE_first_tail_x15_r0_body.s157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s156).run PRE_first_tail_x15_r0_body.S156 = some (PRE_first_tail_x15_r0_body.s157, PRE_first_tail_x15_r0_body.S157)
boot_rfl PRE_first_tail_x15_r0_body.patchB43 from PRE_first_tail_x15_r0_body.s157 to PRE_first_tail_x15_r0_body.s158 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s157).run PRE_first_tail_x15_r0_body.S157 = some (PRE_first_tail_x15_r0_body.s158, PRE_first_tail_x15_r0_body.S158)
boot_rfl PRE_first_tail_x15_r0_body.k158 from PRE_first_tail_x15_r0_body.s158 to PRE_first_tail_x15_r0_body.s159 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB43 ((nth? PRE_first_tail_x15_r0_body.ks 158).getD 0) PRE_first_tail_x15_r0_body.s158 PRE_first_tail_x15_r0_body.S158 = some (PRE_first_tail_x15_r0_body.s159, PRE_first_tail_x15_r0_body.S159)
boot_rfl PRE_first_tail_x15_r0_body.stepA44 from PRE_first_tail_x15_r0_body.s159 to PRE_first_tail_x15_r0_body.s160 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s159).run PRE_first_tail_x15_r0_body.S159 = some (PRE_first_tail_x15_r0_body.s160, PRE_first_tail_x15_r0_body.S160)
end Host.Load.Run.Tpl
