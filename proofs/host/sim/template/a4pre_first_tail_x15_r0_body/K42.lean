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
boot_rfl PRE_first_tail_x15_r0_body.k168 from PRE_first_tail_x15_r0_body.s168 to PRE_first_tail_x15_r0_body.s169 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB50 ((nth? PRE_first_tail_x15_r0_body.ks 168).getD 0) PRE_first_tail_x15_r0_body.s168 PRE_first_tail_x15_r0_body.S168 = some (PRE_first_tail_x15_r0_body.s169, PRE_first_tail_x15_r0_body.S169)
boot_rfl PRE_first_tail_x15_r0_body.stepA51 from PRE_first_tail_x15_r0_body.s169 to PRE_first_tail_x15_r0_body.s170 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s169).run PRE_first_tail_x15_r0_body.S169 = some (PRE_first_tail_x15_r0_body.s170, PRE_first_tail_x15_r0_body.S170)
boot_rfl PRE_first_tail_x15_r0_body.patchB51 from PRE_first_tail_x15_r0_body.s170 to PRE_first_tail_x15_r0_body.s171 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s170).run PRE_first_tail_x15_r0_body.S170 = some (PRE_first_tail_x15_r0_body.s171, PRE_first_tail_x15_r0_body.S171)
boot_rfl PRE_first_tail_x15_r0_body.k171 from PRE_first_tail_x15_r0_body.s171 to PRE_first_tail_x15_r0_body.s172 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB51 ((nth? PRE_first_tail_x15_r0_body.ks 171).getD 0) PRE_first_tail_x15_r0_body.s171 PRE_first_tail_x15_r0_body.S171 = some (PRE_first_tail_x15_r0_body.s172, PRE_first_tail_x15_r0_body.S172)
end Host.Load.Run.Tpl
