import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.patchB205 from PRE_first_tail_x15_r0_body.s692 to PRE_first_tail_x15_r0_body.s693 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s692).run PRE_first_tail_x15_r0_body.S692 = some (PRE_first_tail_x15_r0_body.s693, PRE_first_tail_x15_r0_body.S693)
boot_rfl PRE_first_tail_x15_r0_body.k693 from PRE_first_tail_x15_r0_body.s693 to PRE_first_tail_x15_r0_body.s694 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB205 ((nth? PRE_first_tail_x15_r0_body.ks 693).getD 0) PRE_first_tail_x15_r0_body.s693 PRE_first_tail_x15_r0_body.S693 = some (PRE_first_tail_x15_r0_body.s694, PRE_first_tail_x15_r0_body.S694)
boot_rfl PRE_first_tail_x15_r0_body.stepA206 from PRE_first_tail_x15_r0_body.s694 to PRE_first_tail_x15_r0_body.s695 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s694).run PRE_first_tail_x15_r0_body.S694 = some (PRE_first_tail_x15_r0_body.s695, PRE_first_tail_x15_r0_body.S695)
boot_rfl PRE_first_tail_x15_r0_body.patchB206 from PRE_first_tail_x15_r0_body.s695 to PRE_first_tail_x15_r0_body.s696 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s695).run PRE_first_tail_x15_r0_body.S695 = some (PRE_first_tail_x15_r0_body.s696, PRE_first_tail_x15_r0_body.S696)
end Host.Load.Run.Tpl
