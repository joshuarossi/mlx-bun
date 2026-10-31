import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.patchB297 from PRE_first_tail_x15_r0_body.s1004 to PRE_first_tail_x15_r0_body.s1005 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1004).run PRE_first_tail_x15_r0_body.S1004 = some (PRE_first_tail_x15_r0_body.s1005, PRE_first_tail_x15_r0_body.S1005)
boot_rfl PRE_first_tail_x15_r0_body.k1005 from PRE_first_tail_x15_r0_body.s1005 to PRE_first_tail_x15_r0_body.s1006 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB297 ((nth? PRE_first_tail_x15_r0_body.ks 1005).getD 0) PRE_first_tail_x15_r0_body.s1005 PRE_first_tail_x15_r0_body.S1005 = some (PRE_first_tail_x15_r0_body.s1006, PRE_first_tail_x15_r0_body.S1006)
boot_rfl PRE_first_tail_x15_r0_body.stepA298 from PRE_first_tail_x15_r0_body.s1006 to PRE_first_tail_x15_r0_body.s1007 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1006).run PRE_first_tail_x15_r0_body.S1006 = some (PRE_first_tail_x15_r0_body.s1007, PRE_first_tail_x15_r0_body.S1007)
boot_rfl PRE_first_tail_x15_r0_body.patchB298 from PRE_first_tail_x15_r0_body.s1007 to PRE_first_tail_x15_r0_body.s1008 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1007).run PRE_first_tail_x15_r0_body.S1007 = some (PRE_first_tail_x15_r0_body.s1008, PRE_first_tail_x15_r0_body.S1008)
end Host.Load.Run.Tpl
