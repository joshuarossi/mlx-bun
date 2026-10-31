import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.k657 from PRE_first_tail_x15_r0_body.s657 to PRE_first_tail_x15_r0_body.s658 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB194 ((nth? PRE_first_tail_x15_r0_body.ks 657).getD 0) PRE_first_tail_x15_r0_body.s657 PRE_first_tail_x15_r0_body.S657 = some (PRE_first_tail_x15_r0_body.s658, PRE_first_tail_x15_r0_body.S658)
boot_rfl PRE_first_tail_x15_r0_body.stepA195 from PRE_first_tail_x15_r0_body.s658 to PRE_first_tail_x15_r0_body.s659 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s658).run PRE_first_tail_x15_r0_body.S658 = some (PRE_first_tail_x15_r0_body.s659, PRE_first_tail_x15_r0_body.S659)
boot_rfl PRE_first_tail_x15_r0_body.patchB195 from PRE_first_tail_x15_r0_body.s659 to PRE_first_tail_x15_r0_body.s660 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s659).run PRE_first_tail_x15_r0_body.S659 = some (PRE_first_tail_x15_r0_body.s660, PRE_first_tail_x15_r0_body.S660)
end Host.Load.Run.Tpl
