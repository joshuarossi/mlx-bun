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
boot_rfl PRE_first_tail_x15_r0_body.k1008 from PRE_first_tail_x15_r0_body.s1008 to PRE_first_tail_x15_r0_body.s1009 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB298 ((nth? PRE_first_tail_x15_r0_body.ks 1008).getD 0) PRE_first_tail_x15_r0_body.s1008 PRE_first_tail_x15_r0_body.S1008 = some (PRE_first_tail_x15_r0_body.s1009, PRE_first_tail_x15_r0_body.S1009)
boot_rfl PRE_first_tail_x15_r0_body.stepA299 from PRE_first_tail_x15_r0_body.s1009 to PRE_first_tail_x15_r0_body.s1010 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1009).run PRE_first_tail_x15_r0_body.S1009 = some (PRE_first_tail_x15_r0_body.s1010, PRE_first_tail_x15_r0_body.S1010)
boot_rfl PRE_first_tail_x15_r0_body.patchB299 from PRE_first_tail_x15_r0_body.s1010 to PRE_first_tail_x15_r0_body.s1011 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1010).run PRE_first_tail_x15_r0_body.S1010 = some (PRE_first_tail_x15_r0_body.s1011, PRE_first_tail_x15_r0_body.S1011)
boot_rfl PRE_first_tail_x15_r0_body.k1011 from PRE_first_tail_x15_r0_body.s1011 to PRE_first_tail_x15_r0_body.s1012 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB299 ((nth? PRE_first_tail_x15_r0_body.ks 1011).getD 0) PRE_first_tail_x15_r0_body.s1011 PRE_first_tail_x15_r0_body.S1011 = some (PRE_first_tail_x15_r0_body.s1012, PRE_first_tail_x15_r0_body.S1012)
end Host.Load.Run.Tpl
