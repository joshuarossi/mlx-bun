import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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
boot_rfl PRE_first_tail_x15_r0_body.k253 from PRE_first_tail_x15_r0_body.s253 to PRE_first_tail_x15_r0_body.s254 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB75 ((nth? PRE_first_tail_x15_r0_body.ks 253).getD 0) PRE_first_tail_x15_r0_body.s253 PRE_first_tail_x15_r0_body.S253 = some (PRE_first_tail_x15_r0_body.s254, PRE_first_tail_x15_r0_body.S254)
boot_rfl PRE_first_tail_x15_r0_body.stepA76 from PRE_first_tail_x15_r0_body.s254 to PRE_first_tail_x15_r0_body.s255 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s254).run PRE_first_tail_x15_r0_body.S254 = some (PRE_first_tail_x15_r0_body.s255, PRE_first_tail_x15_r0_body.S255)
boot_rfl PRE_first_tail_x15_r0_body.patchB76 from PRE_first_tail_x15_r0_body.s255 to PRE_first_tail_x15_r0_body.s256 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s255).run PRE_first_tail_x15_r0_body.S255 = some (PRE_first_tail_x15_r0_body.s256, PRE_first_tail_x15_r0_body.S256)
end Host.Load.Run.Tpl
