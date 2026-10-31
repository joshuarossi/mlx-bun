import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.k409 from PRE_first_tail_x15_r0_body.s409 to PRE_first_tail_x15_r0_body.s410 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB121 ((nth? PRE_first_tail_x15_r0_body.ks 409).getD 0) PRE_first_tail_x15_r0_body.s409 PRE_first_tail_x15_r0_body.S409 = some (PRE_first_tail_x15_r0_body.s410, PRE_first_tail_x15_r0_body.S410)
boot_rfl PRE_first_tail_x15_r0_body.stepA122 from PRE_first_tail_x15_r0_body.s410 to PRE_first_tail_x15_r0_body.s411 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s410).run PRE_first_tail_x15_r0_body.S410 = some (PRE_first_tail_x15_r0_body.s411, PRE_first_tail_x15_r0_body.S411)
boot_rfl PRE_first_tail_x15_r0_body.patchB122 from PRE_first_tail_x15_r0_body.s411 to PRE_first_tail_x15_r0_body.s412 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s411).run PRE_first_tail_x15_r0_body.S411 = some (PRE_first_tail_x15_r0_body.s412, PRE_first_tail_x15_r0_body.S412)
end Host.Load.Run.Tpl
