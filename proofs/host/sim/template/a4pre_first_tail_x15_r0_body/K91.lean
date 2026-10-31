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
boot_rfl PRE_first_tail_x15_r0_body.stepA99 from PRE_first_tail_x15_r0_body.s364 to PRE_first_tail_x15_r0_body.s365 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s364).run PRE_first_tail_x15_r0_body.S364 = some (PRE_first_tail_x15_r0_body.s365, PRE_first_tail_x15_r0_body.S365)
boot_rfl PRE_first_tail_x15_r0_body.patchB99 from PRE_first_tail_x15_r0_body.s365 to PRE_first_tail_x15_r0_body.s366 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s365).run PRE_first_tail_x15_r0_body.S365 = some (PRE_first_tail_x15_r0_body.s366, PRE_first_tail_x15_r0_body.S366)
boot_rfl PRE_first_tail_x15_r0_body.k366 from PRE_first_tail_x15_r0_body.s366 to PRE_first_tail_x15_r0_body.s367 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB99 ((nth? PRE_first_tail_x15_r0_body.ks 366).getD 0) PRE_first_tail_x15_r0_body.s366 PRE_first_tail_x15_r0_body.S366 = some (PRE_first_tail_x15_r0_body.s367, PRE_first_tail_x15_r0_body.S367)
boot_rfl PRE_first_tail_x15_r0_body.k367 from PRE_first_tail_x15_r0_body.s367 to PRE_first_tail_x15_r0_body.s368 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB99 ((nth? PRE_first_tail_x15_r0_body.ks 367).getD 0) PRE_first_tail_x15_r0_body.s367 PRE_first_tail_x15_r0_body.S367 = some (PRE_first_tail_x15_r0_body.s368, PRE_first_tail_x15_r0_body.S368)
end Host.Load.Run.Tpl
