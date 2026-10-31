import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.patchB421 from PRE_first_tail_x15_r0_body.s1424 to PRE_first_tail_x15_r0_body.s1425 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1424).run PRE_first_tail_x15_r0_body.S1424 = some (PRE_first_tail_x15_r0_body.s1425, PRE_first_tail_x15_r0_body.S1425)
end Host.Load.Run.Tpl
