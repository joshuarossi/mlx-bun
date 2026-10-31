import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.stepA9 from PRE_first_tail_x15_r0_body.s32 to PRE_first_tail_x15_r0_body.s33 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s32).run PRE_first_tail_x15_r0_body.S32 = some (PRE_first_tail_x15_r0_body.s33, PRE_first_tail_x15_r0_body.S33)
boot_rfl PRE_first_tail_x15_r0_body.patchB9 from PRE_first_tail_x15_r0_body.s33 to PRE_first_tail_x15_r0_body.s34 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s33).run PRE_first_tail_x15_r0_body.S33 = some (PRE_first_tail_x15_r0_body.s34, PRE_first_tail_x15_r0_body.S34)
boot_rfl PRE_first_tail_x15_r0_body.k34 from PRE_first_tail_x15_r0_body.s34 to PRE_first_tail_x15_r0_body.s35 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB9 ((nth? PRE_first_tail_x15_r0_body.ks 34).getD 0) PRE_first_tail_x15_r0_body.s34 PRE_first_tail_x15_r0_body.S34 = some (PRE_first_tail_x15_r0_body.s35, PRE_first_tail_x15_r0_body.S35)
boot_rfl PRE_first_tail_x15_r0_body.stepA10 from PRE_first_tail_x15_r0_body.s35 to PRE_first_tail_x15_r0_body.s36 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s35).run PRE_first_tail_x15_r0_body.S35 = some (PRE_first_tail_x15_r0_body.s36, PRE_first_tail_x15_r0_body.S36)
end Host.Load.Run.Tpl
