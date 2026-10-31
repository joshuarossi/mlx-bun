import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.k120 from PRE_first_tail_x15_r0_body.s120 to PRE_first_tail_x15_r0_body.s121 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB32 ((nth? PRE_first_tail_x15_r0_body.ks 120).getD 0) PRE_first_tail_x15_r0_body.s120 PRE_first_tail_x15_r0_body.S120 = some (PRE_first_tail_x15_r0_body.s121, PRE_first_tail_x15_r0_body.S121)
boot_rfl PRE_first_tail_x15_r0_body.stepA33 from PRE_first_tail_x15_r0_body.s121 to PRE_first_tail_x15_r0_body.s122 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s121).run PRE_first_tail_x15_r0_body.S121 = some (PRE_first_tail_x15_r0_body.s122, PRE_first_tail_x15_r0_body.S122)
boot_rfl PRE_first_tail_x15_r0_body.patchB33 from PRE_first_tail_x15_r0_body.s122 to PRE_first_tail_x15_r0_body.s123 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s122).run PRE_first_tail_x15_r0_body.S122 = some (PRE_first_tail_x15_r0_body.s123, PRE_first_tail_x15_r0_body.S123)
boot_rfl PRE_first_tail_x15_r0_body.k123 from PRE_first_tail_x15_r0_body.s123 to PRE_first_tail_x15_r0_body.s124 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB33 ((nth? PRE_first_tail_x15_r0_body.ks 123).getD 0) PRE_first_tail_x15_r0_body.s123 PRE_first_tail_x15_r0_body.S123 = some (PRE_first_tail_x15_r0_body.s124, PRE_first_tail_x15_r0_body.S124)
end Host.Load.Run.Tpl
