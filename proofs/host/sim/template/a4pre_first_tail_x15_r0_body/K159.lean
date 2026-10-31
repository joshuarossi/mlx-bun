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
boot_rfl PRE_first_tail_x15_r0_body.stepA172 from PRE_first_tail_x15_r0_body.s636 to PRE_first_tail_x15_r0_body.s637 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s636).run PRE_first_tail_x15_r0_body.S636 = some (PRE_first_tail_x15_r0_body.s637, PRE_first_tail_x15_r0_body.S637)
boot_rfl PRE_first_tail_x15_r0_body.patchB172 from PRE_first_tail_x15_r0_body.s637 to PRE_first_tail_x15_r0_body.s638 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s637).run PRE_first_tail_x15_r0_body.S637 = some (PRE_first_tail_x15_r0_body.s638, PRE_first_tail_x15_r0_body.S638)
boot_rfl PRE_first_tail_x15_r0_body.k638 from PRE_first_tail_x15_r0_body.s638 to PRE_first_tail_x15_r0_body.s639 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB172 ((nth? PRE_first_tail_x15_r0_body.ks 638).getD 0) PRE_first_tail_x15_r0_body.s638 PRE_first_tail_x15_r0_body.S638 = some (PRE_first_tail_x15_r0_body.s639, PRE_first_tail_x15_r0_body.S639)
boot_rfl PRE_first_tail_x15_r0_body.stepA173 from PRE_first_tail_x15_r0_body.s639 to PRE_first_tail_x15_r0_body.s640 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s639).run PRE_first_tail_x15_r0_body.S639 = some (PRE_first_tail_x15_r0_body.s640, PRE_first_tail_x15_r0_body.S640)
end Host.Load.Run.Tpl
