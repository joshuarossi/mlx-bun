import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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
boot_rfl PRE_first_tail_x15_r0_body.stepA347 from PRE_first_tail_x15_r0_body.s1172 to PRE_first_tail_x15_r0_body.s1173 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1172).run PRE_first_tail_x15_r0_body.S1172 = some (PRE_first_tail_x15_r0_body.s1173, PRE_first_tail_x15_r0_body.S1173)
boot_rfl PRE_first_tail_x15_r0_body.patchB347 from PRE_first_tail_x15_r0_body.s1173 to PRE_first_tail_x15_r0_body.s1174 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1173).run PRE_first_tail_x15_r0_body.S1173 = some (PRE_first_tail_x15_r0_body.s1174, PRE_first_tail_x15_r0_body.S1174)
boot_rfl PRE_first_tail_x15_r0_body.k1174 from PRE_first_tail_x15_r0_body.s1174 to PRE_first_tail_x15_r0_body.s1175 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB347 ((nth? PRE_first_tail_x15_r0_body.ks 1174).getD 0) PRE_first_tail_x15_r0_body.s1174 PRE_first_tail_x15_r0_body.S1174 = some (PRE_first_tail_x15_r0_body.s1175, PRE_first_tail_x15_r0_body.S1175)
boot_rfl PRE_first_tail_x15_r0_body.stepA348 from PRE_first_tail_x15_r0_body.s1175 to PRE_first_tail_x15_r0_body.s1176 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1175).run PRE_first_tail_x15_r0_body.S1175 = some (PRE_first_tail_x15_r0_body.s1176, PRE_first_tail_x15_r0_body.S1176)
end Host.Load.Run.Tpl
