import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.patchB212 from PRE_first_tail_x15_r0_body.s716 to PRE_first_tail_x15_r0_body.s717 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s716).run PRE_first_tail_x15_r0_body.S716 = some (PRE_first_tail_x15_r0_body.s717, PRE_first_tail_x15_r0_body.S717)
boot_rfl PRE_first_tail_x15_r0_body.k717 from PRE_first_tail_x15_r0_body.s717 to PRE_first_tail_x15_r0_body.s718 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB212 ((nth? PRE_first_tail_x15_r0_body.ks 717).getD 0) PRE_first_tail_x15_r0_body.s717 PRE_first_tail_x15_r0_body.S717 = some (PRE_first_tail_x15_r0_body.s718, PRE_first_tail_x15_r0_body.S718)
boot_rfl PRE_first_tail_x15_r0_body.stepA213 from PRE_first_tail_x15_r0_body.s718 to PRE_first_tail_x15_r0_body.s719 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s718).run PRE_first_tail_x15_r0_body.S718 = some (PRE_first_tail_x15_r0_body.s719, PRE_first_tail_x15_r0_body.S719)
boot_rfl PRE_first_tail_x15_r0_body.patchB213 from PRE_first_tail_x15_r0_body.s719 to PRE_first_tail_x15_r0_body.s720 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s719).run PRE_first_tail_x15_r0_body.S719 = some (PRE_first_tail_x15_r0_body.s720, PRE_first_tail_x15_r0_body.S720)
end Host.Load.Run.Tpl
