import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.k192 from PRE_first_tail_x15_r0_body.s192 to PRE_first_tail_x15_r0_body.s193 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB57 ((nth? PRE_first_tail_x15_r0_body.ks 192).getD 0) PRE_first_tail_x15_r0_body.s192 PRE_first_tail_x15_r0_body.S192 = some (PRE_first_tail_x15_r0_body.s193, PRE_first_tail_x15_r0_body.S193)
boot_rfl PRE_first_tail_x15_r0_body.stepA58 from PRE_first_tail_x15_r0_body.s193 to PRE_first_tail_x15_r0_body.s194 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s193).run PRE_first_tail_x15_r0_body.S193 = some (PRE_first_tail_x15_r0_body.s194, PRE_first_tail_x15_r0_body.S194)
boot_rfl PRE_first_tail_x15_r0_body.patchB58 from PRE_first_tail_x15_r0_body.s194 to PRE_first_tail_x15_r0_body.s195 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s194).run PRE_first_tail_x15_r0_body.S194 = some (PRE_first_tail_x15_r0_body.s195, PRE_first_tail_x15_r0_body.S195)
boot_rfl PRE_first_tail_x15_r0_body.k195 from PRE_first_tail_x15_r0_body.s195 to PRE_first_tail_x15_r0_body.s196 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB58 ((nth? PRE_first_tail_x15_r0_body.ks 195).getD 0) PRE_first_tail_x15_r0_body.s195 PRE_first_tail_x15_r0_body.S195 = some (PRE_first_tail_x15_r0_body.s196, PRE_first_tail_x15_r0_body.S196)
end Host.Load.Run.Tpl
