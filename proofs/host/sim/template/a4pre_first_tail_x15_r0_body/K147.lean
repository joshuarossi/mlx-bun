import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.k588 from PRE_first_tail_x15_r0_body.s588 to PRE_first_tail_x15_r0_body.s589 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB174 ((nth? PRE_first_tail_x15_r0_body.ks 588).getD 0) PRE_first_tail_x15_r0_body.s588 PRE_first_tail_x15_r0_body.S588 = some (PRE_first_tail_x15_r0_body.s589, PRE_first_tail_x15_r0_body.S589)
boot_rfl PRE_first_tail_x15_r0_body.stepA175 from PRE_first_tail_x15_r0_body.s589 to PRE_first_tail_x15_r0_body.s590 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s589).run PRE_first_tail_x15_r0_body.S589 = some (PRE_first_tail_x15_r0_body.s590, PRE_first_tail_x15_r0_body.S590)
boot_rfl PRE_first_tail_x15_r0_body.patchB175 from PRE_first_tail_x15_r0_body.s590 to PRE_first_tail_x15_r0_body.s591 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s590).run PRE_first_tail_x15_r0_body.S590 = some (PRE_first_tail_x15_r0_body.s591, PRE_first_tail_x15_r0_body.S591)
boot_rfl PRE_first_tail_x15_r0_body.k591 from PRE_first_tail_x15_r0_body.s591 to PRE_first_tail_x15_r0_body.s592 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB175 ((nth? PRE_first_tail_x15_r0_body.ks 591).getD 0) PRE_first_tail_x15_r0_body.s591 PRE_first_tail_x15_r0_body.S591 = some (PRE_first_tail_x15_r0_body.s592, PRE_first_tail_x15_r0_body.S592)
end Host.Load.Run.Tpl
