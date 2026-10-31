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
boot_rfl PRE_first_tail_x15_r0_body.patchB350 from PRE_first_tail_x15_r0_body.s1184 to PRE_first_tail_x15_r0_body.s1185 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1184).run PRE_first_tail_x15_r0_body.S1184 = some (PRE_first_tail_x15_r0_body.s1185, PRE_first_tail_x15_r0_body.S1185)
boot_rfl PRE_first_tail_x15_r0_body.k1185 from PRE_first_tail_x15_r0_body.s1185 to PRE_first_tail_x15_r0_body.s1186 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB350 ((nth? PRE_first_tail_x15_r0_body.ks 1185).getD 0) PRE_first_tail_x15_r0_body.s1185 PRE_first_tail_x15_r0_body.S1185 = some (PRE_first_tail_x15_r0_body.s1186, PRE_first_tail_x15_r0_body.S1186)
boot_rfl PRE_first_tail_x15_r0_body.stepA351 from PRE_first_tail_x15_r0_body.s1186 to PRE_first_tail_x15_r0_body.s1187 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1186).run PRE_first_tail_x15_r0_body.S1186 = some (PRE_first_tail_x15_r0_body.s1187, PRE_first_tail_x15_r0_body.S1187)
boot_rfl PRE_first_tail_x15_r0_body.patchB351 from PRE_first_tail_x15_r0_body.s1187 to PRE_first_tail_x15_r0_body.s1188 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1187).run PRE_first_tail_x15_r0_body.S1187 = some (PRE_first_tail_x15_r0_body.s1188, PRE_first_tail_x15_r0_body.S1188)
end Host.Load.Run.Tpl
