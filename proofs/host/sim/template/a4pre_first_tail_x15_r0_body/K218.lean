import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.stepA236 from PRE_first_tail_x15_r0_body.s872 to PRE_first_tail_x15_r0_body.s873 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s872).run PRE_first_tail_x15_r0_body.S872 = some (PRE_first_tail_x15_r0_body.s873, PRE_first_tail_x15_r0_body.S873)
boot_rfl PRE_first_tail_x15_r0_body.patchB236 from PRE_first_tail_x15_r0_body.s873 to PRE_first_tail_x15_r0_body.s874 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s873).run PRE_first_tail_x15_r0_body.S873 = some (PRE_first_tail_x15_r0_body.s874, PRE_first_tail_x15_r0_body.S874)
boot_rfl PRE_first_tail_x15_r0_body.k874 from PRE_first_tail_x15_r0_body.s874 to PRE_first_tail_x15_r0_body.s875 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB236 ((nth? PRE_first_tail_x15_r0_body.ks 874).getD 0) PRE_first_tail_x15_r0_body.s874 PRE_first_tail_x15_r0_body.S874 = some (PRE_first_tail_x15_r0_body.s875, PRE_first_tail_x15_r0_body.S875)
boot_rfl PRE_first_tail_x15_r0_body.stepA237 from PRE_first_tail_x15_r0_body.s875 to PRE_first_tail_x15_r0_body.s876 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s875).run PRE_first_tail_x15_r0_body.S875 = some (PRE_first_tail_x15_r0_body.s876, PRE_first_tail_x15_r0_body.S876)
end Host.Load.Run.Tpl
