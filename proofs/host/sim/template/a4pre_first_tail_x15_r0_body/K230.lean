import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.k921 from PRE_first_tail_x15_r0_body.s921 to PRE_first_tail_x15_r0_body.s922 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB272 ((nth? PRE_first_tail_x15_r0_body.ks 921).getD 0) PRE_first_tail_x15_r0_body.s921 PRE_first_tail_x15_r0_body.S921 = some (PRE_first_tail_x15_r0_body.s922, PRE_first_tail_x15_r0_body.S922)
boot_rfl PRE_first_tail_x15_r0_body.stepA273 from PRE_first_tail_x15_r0_body.s922 to PRE_first_tail_x15_r0_body.s923 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s922).run PRE_first_tail_x15_r0_body.S922 = some (PRE_first_tail_x15_r0_body.s923, PRE_first_tail_x15_r0_body.S923)
boot_rfl PRE_first_tail_x15_r0_body.patchB273 from PRE_first_tail_x15_r0_body.s923 to PRE_first_tail_x15_r0_body.s924 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s923).run PRE_first_tail_x15_r0_body.S923 = some (PRE_first_tail_x15_r0_body.s924, PRE_first_tail_x15_r0_body.S924)
end Host.Load.Run.Tpl
