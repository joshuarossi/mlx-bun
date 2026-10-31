import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.patchB118 from PRE_first_tail_x15_r0_body.s436 to PRE_first_tail_x15_r0_body.s437 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s436).run PRE_first_tail_x15_r0_body.S436 = some (PRE_first_tail_x15_r0_body.s437, PRE_first_tail_x15_r0_body.S437)
boot_rfl PRE_first_tail_x15_r0_body.k437 from PRE_first_tail_x15_r0_body.s437 to PRE_first_tail_x15_r0_body.s438 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB118 ((nth? PRE_first_tail_x15_r0_body.ks 437).getD 0) PRE_first_tail_x15_r0_body.s437 PRE_first_tail_x15_r0_body.S437 = some (PRE_first_tail_x15_r0_body.s438, PRE_first_tail_x15_r0_body.S438)
boot_rfl PRE_first_tail_x15_r0_body.k438 from PRE_first_tail_x15_r0_body.s438 to PRE_first_tail_x15_r0_body.s439 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB118 ((nth? PRE_first_tail_x15_r0_body.ks 438).getD 0) PRE_first_tail_x15_r0_body.s438 PRE_first_tail_x15_r0_body.S438 = some (PRE_first_tail_x15_r0_body.s439, PRE_first_tail_x15_r0_body.S439)
boot_rfl PRE_first_tail_x15_r0_body.stepA119 from PRE_first_tail_x15_r0_body.s439 to PRE_first_tail_x15_r0_body.s440 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s439).run PRE_first_tail_x15_r0_body.S439 = some (PRE_first_tail_x15_r0_body.s440, PRE_first_tail_x15_r0_body.S440)
end Host.Load.Run.Tpl
