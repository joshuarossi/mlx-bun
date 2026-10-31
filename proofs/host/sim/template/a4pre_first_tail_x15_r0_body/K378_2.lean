import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.patchB448 from PRE_first_tail_x15_r0_body.s1515 to PRE_first_tail_x15_r0_body.s1516 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1515).run PRE_first_tail_x15_r0_body.S1515 = some (PRE_first_tail_x15_r0_body.s1516, PRE_first_tail_x15_r0_body.S1516)
end Host.Load.Run.Tpl
