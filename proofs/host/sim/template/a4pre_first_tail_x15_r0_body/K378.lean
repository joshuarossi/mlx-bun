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
boot_rfl PRE_first_tail_x15_r0_body.k1513 from PRE_first_tail_x15_r0_body.s1513 to PRE_first_tail_x15_r0_body.s1514 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB408 ((nth? PRE_first_tail_x15_r0_body.ks 1513).getD 0) PRE_first_tail_x15_r0_body.s1513 PRE_first_tail_x15_r0_body.S1513 = some (PRE_first_tail_x15_r0_body.s1514, PRE_first_tail_x15_r0_body.S1514)
boot_rfl PRE_first_tail_x15_r0_body.stepA409 from PRE_first_tail_x15_r0_body.s1514 to PRE_first_tail_x15_r0_body.s1515 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1514).run PRE_first_tail_x15_r0_body.S1514 = some (PRE_first_tail_x15_r0_body.s1515, PRE_first_tail_x15_r0_body.S1515)
boot_rfl PRE_first_tail_x15_r0_body.patchB409 from PRE_first_tail_x15_r0_body.s1515 to PRE_first_tail_x15_r0_body.s1516 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1515).run PRE_first_tail_x15_r0_body.S1515 = some (PRE_first_tail_x15_r0_body.s1516, PRE_first_tail_x15_r0_body.S1516)
end Host.Load.Run.Tpl
