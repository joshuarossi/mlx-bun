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
boot_rfl PRE_first_tail_x15_r0_body.k724 from PRE_first_tail_x15_r0_body.s724 to PRE_first_tail_x15_r0_body.s725 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB214 ((nth? PRE_first_tail_x15_r0_body.ks 724).getD 0) PRE_first_tail_x15_r0_body.s724 PRE_first_tail_x15_r0_body.S724 = some (PRE_first_tail_x15_r0_body.s725, PRE_first_tail_x15_r0_body.S725)
boot_rfl PRE_first_tail_x15_r0_body.stepA215 from PRE_first_tail_x15_r0_body.s725 to PRE_first_tail_x15_r0_body.s726 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s725).run PRE_first_tail_x15_r0_body.S725 = some (PRE_first_tail_x15_r0_body.s726, PRE_first_tail_x15_r0_body.S726)
boot_rfl PRE_first_tail_x15_r0_body.patchB215 from PRE_first_tail_x15_r0_body.s726 to PRE_first_tail_x15_r0_body.s727 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s726).run PRE_first_tail_x15_r0_body.S726 = some (PRE_first_tail_x15_r0_body.s727, PRE_first_tail_x15_r0_body.S727)
boot_rfl PRE_first_tail_x15_r0_body.k727 from PRE_first_tail_x15_r0_body.s727 to PRE_first_tail_x15_r0_body.s728 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB215 ((nth? PRE_first_tail_x15_r0_body.ks 727).getD 0) PRE_first_tail_x15_r0_body.s727 PRE_first_tail_x15_r0_body.S727 = some (PRE_first_tail_x15_r0_body.s728, PRE_first_tail_x15_r0_body.S728)
end Host.Load.Run.Tpl
