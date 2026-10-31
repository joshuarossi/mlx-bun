import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.k60 from PRE_first_tail_x15_r0_body.s60 to PRE_first_tail_x15_r0_body.s61 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB16 ((nth? PRE_first_tail_x15_r0_body.ks 60).getD 0) PRE_first_tail_x15_r0_body.s60 PRE_first_tail_x15_r0_body.S60 = some (PRE_first_tail_x15_r0_body.s61, PRE_first_tail_x15_r0_body.S61)
boot_rfl PRE_first_tail_x15_r0_body.stepA17 from PRE_first_tail_x15_r0_body.s61 to PRE_first_tail_x15_r0_body.s62 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s61).run PRE_first_tail_x15_r0_body.S61 = some (PRE_first_tail_x15_r0_body.s62, PRE_first_tail_x15_r0_body.S62)
boot_rfl PRE_first_tail_x15_r0_body.patchB17 from PRE_first_tail_x15_r0_body.s62 to PRE_first_tail_x15_r0_body.s63 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s62).run PRE_first_tail_x15_r0_body.S62 = some (PRE_first_tail_x15_r0_body.s63, PRE_first_tail_x15_r0_body.S63)
boot_rfl PRE_first_tail_x15_r0_body.k63 from PRE_first_tail_x15_r0_body.s63 to PRE_first_tail_x15_r0_body.s64 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB17 ((nth? PRE_first_tail_x15_r0_body.ks 63).getD 0) PRE_first_tail_x15_r0_body.s63 PRE_first_tail_x15_r0_body.S63 = some (PRE_first_tail_x15_r0_body.s64, PRE_first_tail_x15_r0_body.S64)
end Host.Load.Run.Tpl
