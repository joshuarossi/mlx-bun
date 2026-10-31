import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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
boot_rfl PRE_first_tail_x15_r0_body.k924 from PRE_first_tail_x15_r0_body.s924 to PRE_first_tail_x15_r0_body.s925 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB273 ((nth? PRE_first_tail_x15_r0_body.ks 924).getD 0) PRE_first_tail_x15_r0_body.s924 PRE_first_tail_x15_r0_body.S924 = some (PRE_first_tail_x15_r0_body.s925, PRE_first_tail_x15_r0_body.S925)
boot_rfl PRE_first_tail_x15_r0_body.stepA274 from PRE_first_tail_x15_r0_body.s925 to PRE_first_tail_x15_r0_body.s926 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s925).run PRE_first_tail_x15_r0_body.S925 = some (PRE_first_tail_x15_r0_body.s926, PRE_first_tail_x15_r0_body.S926)
boot_rfl PRE_first_tail_x15_r0_body.patchB274 from PRE_first_tail_x15_r0_body.s926 to PRE_first_tail_x15_r0_body.s927 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s926).run PRE_first_tail_x15_r0_body.S926 = some (PRE_first_tail_x15_r0_body.s927, PRE_first_tail_x15_r0_body.S927)
boot_rfl PRE_first_tail_x15_r0_body.k927 from PRE_first_tail_x15_r0_body.s927 to PRE_first_tail_x15_r0_body.s928 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB274 ((nth? PRE_first_tail_x15_r0_body.ks 927).getD 0) PRE_first_tail_x15_r0_body.s927 PRE_first_tail_x15_r0_body.S927 = some (PRE_first_tail_x15_r0_body.s928, PRE_first_tail_x15_r0_body.S928)
end Host.Load.Run.Tpl
