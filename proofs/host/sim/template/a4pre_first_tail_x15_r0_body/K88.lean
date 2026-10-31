import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.patchB95 from PRE_first_tail_x15_r0_body.s352 to PRE_first_tail_x15_r0_body.s353 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s352).run PRE_first_tail_x15_r0_body.S352 = some (PRE_first_tail_x15_r0_body.s353, PRE_first_tail_x15_r0_body.S353)
boot_rfl PRE_first_tail_x15_r0_body.k353 from PRE_first_tail_x15_r0_body.s353 to PRE_first_tail_x15_r0_body.s354 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB95 ((nth? PRE_first_tail_x15_r0_body.ks 353).getD 0) PRE_first_tail_x15_r0_body.s353 PRE_first_tail_x15_r0_body.S353 = some (PRE_first_tail_x15_r0_body.s354, PRE_first_tail_x15_r0_body.S354)
boot_rfl PRE_first_tail_x15_r0_body.stepA96 from PRE_first_tail_x15_r0_body.s354 to PRE_first_tail_x15_r0_body.s355 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s354).run PRE_first_tail_x15_r0_body.S354 = some (PRE_first_tail_x15_r0_body.s355, PRE_first_tail_x15_r0_body.S355)
boot_rfl PRE_first_tail_x15_r0_body.patchB96 from PRE_first_tail_x15_r0_body.s355 to PRE_first_tail_x15_r0_body.s356 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s355).run PRE_first_tail_x15_r0_body.S355 = some (PRE_first_tail_x15_r0_body.s356, PRE_first_tail_x15_r0_body.S356)
end Host.Load.Run.Tpl
