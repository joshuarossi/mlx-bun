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
boot_rfl PRE_first_tail_x15_r0_body.k184 from PRE_first_tail_x15_r0_body.s184 to PRE_first_tail_x15_r0_body.s185 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB50 ((nth? PRE_first_tail_x15_r0_body.ks 184).getD 0) PRE_first_tail_x15_r0_body.s184 PRE_first_tail_x15_r0_body.S184 = some (PRE_first_tail_x15_r0_body.s185, PRE_first_tail_x15_r0_body.S185)
boot_rfl PRE_first_tail_x15_r0_body.stepA51 from PRE_first_tail_x15_r0_body.s185 to PRE_first_tail_x15_r0_body.s186 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s185).run PRE_first_tail_x15_r0_body.S185 = some (PRE_first_tail_x15_r0_body.s186, PRE_first_tail_x15_r0_body.S186)
boot_rfl PRE_first_tail_x15_r0_body.patchB51 from PRE_first_tail_x15_r0_body.s186 to PRE_first_tail_x15_r0_body.s187 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s186).run PRE_first_tail_x15_r0_body.S186 = some (PRE_first_tail_x15_r0_body.s187, PRE_first_tail_x15_r0_body.S187)
boot_rfl PRE_first_tail_x15_r0_body.k187 from PRE_first_tail_x15_r0_body.s187 to PRE_first_tail_x15_r0_body.s188 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB51 ((nth? PRE_first_tail_x15_r0_body.ks 187).getD 0) PRE_first_tail_x15_r0_body.s187 PRE_first_tail_x15_r0_body.S187 = some (PRE_first_tail_x15_r0_body.s188, PRE_first_tail_x15_r0_body.S188)
end Host.Load.Run.Tpl
