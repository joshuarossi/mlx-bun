import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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
boot_rfl PRE_first_tail_x15_r0_body.patchB355 from PRE_first_tail_x15_r0_body.s1200 to PRE_first_tail_x15_r0_body.s1201 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1200).run PRE_first_tail_x15_r0_body.S1200 = some (PRE_first_tail_x15_r0_body.s1201, PRE_first_tail_x15_r0_body.S1201)
boot_rfl PRE_first_tail_x15_r0_body.k1201 from PRE_first_tail_x15_r0_body.s1201 to PRE_first_tail_x15_r0_body.s1202 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB355 ((nth? PRE_first_tail_x15_r0_body.ks 1201).getD 0) PRE_first_tail_x15_r0_body.s1201 PRE_first_tail_x15_r0_body.S1201 = some (PRE_first_tail_x15_r0_body.s1202, PRE_first_tail_x15_r0_body.S1202)
boot_rfl PRE_first_tail_x15_r0_body.stepA356 from PRE_first_tail_x15_r0_body.s1202 to PRE_first_tail_x15_r0_body.s1203 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1202).run PRE_first_tail_x15_r0_body.S1202 = some (PRE_first_tail_x15_r0_body.s1203, PRE_first_tail_x15_r0_body.S1203)
end Host.Load.Run.Tpl
