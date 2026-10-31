import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.patchB49 from PRE_first_tail_x15_r0_body.s164 to PRE_first_tail_x15_r0_body.s165 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s164).run PRE_first_tail_x15_r0_body.S164 = some (PRE_first_tail_x15_r0_body.s165, PRE_first_tail_x15_r0_body.S165)
boot_rfl PRE_first_tail_x15_r0_body.k165 from PRE_first_tail_x15_r0_body.s165 to PRE_first_tail_x15_r0_body.s166 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB49 ((nth? PRE_first_tail_x15_r0_body.ks 165).getD 0) PRE_first_tail_x15_r0_body.s165 PRE_first_tail_x15_r0_body.S165 = some (PRE_first_tail_x15_r0_body.s166, PRE_first_tail_x15_r0_body.S166)
boot_rfl PRE_first_tail_x15_r0_body.stepA50 from PRE_first_tail_x15_r0_body.s166 to PRE_first_tail_x15_r0_body.s167 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s166).run PRE_first_tail_x15_r0_body.S166 = some (PRE_first_tail_x15_r0_body.s167, PRE_first_tail_x15_r0_body.S167)
boot_rfl PRE_first_tail_x15_r0_body.patchB50 from PRE_first_tail_x15_r0_body.s167 to PRE_first_tail_x15_r0_body.s168 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s167).run PRE_first_tail_x15_r0_body.S167 = some (PRE_first_tail_x15_r0_body.s168, PRE_first_tail_x15_r0_body.S168)
end Host.Load.Run.Tpl
