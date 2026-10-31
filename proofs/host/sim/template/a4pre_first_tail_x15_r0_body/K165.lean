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
boot_rfl PRE_first_tail_x15_r0_body.k660 from PRE_first_tail_x15_r0_body.s660 to PRE_first_tail_x15_r0_body.s661 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB195 ((nth? PRE_first_tail_x15_r0_body.ks 660).getD 0) PRE_first_tail_x15_r0_body.s660 PRE_first_tail_x15_r0_body.S660 = some (PRE_first_tail_x15_r0_body.s661, PRE_first_tail_x15_r0_body.S661)
boot_rfl PRE_first_tail_x15_r0_body.stepA196 from PRE_first_tail_x15_r0_body.s661 to PRE_first_tail_x15_r0_body.s662 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s661).run PRE_first_tail_x15_r0_body.S661 = some (PRE_first_tail_x15_r0_body.s662, PRE_first_tail_x15_r0_body.S662)
boot_rfl PRE_first_tail_x15_r0_body.patchB196 from PRE_first_tail_x15_r0_body.s662 to PRE_first_tail_x15_r0_body.s663 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s662).run PRE_first_tail_x15_r0_body.S662 = some (PRE_first_tail_x15_r0_body.s663, PRE_first_tail_x15_r0_body.S663)
boot_rfl PRE_first_tail_x15_r0_body.k663 from PRE_first_tail_x15_r0_body.s663 to PRE_first_tail_x15_r0_body.s664 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB196 ((nth? PRE_first_tail_x15_r0_body.ks 663).getD 0) PRE_first_tail_x15_r0_body.s663 PRE_first_tail_x15_r0_body.S663 = some (PRE_first_tail_x15_r0_body.s664, PRE_first_tail_x15_r0_body.S664)
end Host.Load.Run.Tpl
