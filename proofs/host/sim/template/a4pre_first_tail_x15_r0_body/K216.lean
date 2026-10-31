import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.stepA256 from PRE_first_tail_x15_r0_body.s864 to PRE_first_tail_x15_r0_body.s865 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s864).run PRE_first_tail_x15_r0_body.S864 = some (PRE_first_tail_x15_r0_body.s865, PRE_first_tail_x15_r0_body.S865)
boot_rfl PRE_first_tail_x15_r0_body.k867 from PRE_first_tail_x15_r0_body.s867 to PRE_first_tail_x15_r0_body.s868 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB256 ((nth? PRE_first_tail_x15_r0_body.ks 867).getD 0) PRE_first_tail_x15_r0_body.s867 PRE_first_tail_x15_r0_body.S867 = some (PRE_first_tail_x15_r0_body.s868, PRE_first_tail_x15_r0_body.S868)
end Host.Load.Run.Tpl
