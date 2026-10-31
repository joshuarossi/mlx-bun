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
boot_rfl PRE_first_tail_x15_r0_body.patchB159 from PRE_first_tail_x15_r0_body.s588 to PRE_first_tail_x15_r0_body.s589 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s588).run PRE_first_tail_x15_r0_body.S588 = some (PRE_first_tail_x15_r0_body.s589, PRE_first_tail_x15_r0_body.S589)
boot_rfl PRE_first_tail_x15_r0_body.k589 from PRE_first_tail_x15_r0_body.s589 to PRE_first_tail_x15_r0_body.s590 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB159 ((nth? PRE_first_tail_x15_r0_body.ks 589).getD 0) PRE_first_tail_x15_r0_body.s589 PRE_first_tail_x15_r0_body.S589 = some (PRE_first_tail_x15_r0_body.s590, PRE_first_tail_x15_r0_body.S590)
boot_rfl PRE_first_tail_x15_r0_body.stepA160 from PRE_first_tail_x15_r0_body.s590 to PRE_first_tail_x15_r0_body.s591 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s590).run PRE_first_tail_x15_r0_body.S590 = some (PRE_first_tail_x15_r0_body.s591, PRE_first_tail_x15_r0_body.S591)
end Host.Load.Run.Tpl
