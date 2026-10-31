import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.stepA218 from PRE_first_tail_x15_r0_body.s808 to PRE_first_tail_x15_r0_body.s809 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s808).run PRE_first_tail_x15_r0_body.S808 = some (PRE_first_tail_x15_r0_body.s809, PRE_first_tail_x15_r0_body.S809)
boot_rfl PRE_first_tail_x15_r0_body.patchB218 from PRE_first_tail_x15_r0_body.s809 to PRE_first_tail_x15_r0_body.s810 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s809).run PRE_first_tail_x15_r0_body.S809 = some (PRE_first_tail_x15_r0_body.s810, PRE_first_tail_x15_r0_body.S810)
boot_rfl PRE_first_tail_x15_r0_body.k810 from PRE_first_tail_x15_r0_body.s810 to PRE_first_tail_x15_r0_body.s811 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB218 ((nth? PRE_first_tail_x15_r0_body.ks 810).getD 0) PRE_first_tail_x15_r0_body.s810 PRE_first_tail_x15_r0_body.S810 = some (PRE_first_tail_x15_r0_body.s811, PRE_first_tail_x15_r0_body.S811)
boot_rfl PRE_first_tail_x15_r0_body.stepA219 from PRE_first_tail_x15_r0_body.s811 to PRE_first_tail_x15_r0_body.s812 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s811).run PRE_first_tail_x15_r0_body.S811 = some (PRE_first_tail_x15_r0_body.s812, PRE_first_tail_x15_r0_body.S812)
end Host.Load.Run.Tpl
