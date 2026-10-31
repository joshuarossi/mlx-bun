import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.k961 from PRE_first_tail_x15_r0_body.s961 to PRE_first_tail_x15_r0_body.s962 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB284 ((nth? PRE_first_tail_x15_r0_body.ks 961).getD 0) PRE_first_tail_x15_r0_body.s961 PRE_first_tail_x15_r0_body.S961 = some (PRE_first_tail_x15_r0_body.s962, PRE_first_tail_x15_r0_body.S962)
boot_rfl PRE_first_tail_x15_r0_body.stepA285 from PRE_first_tail_x15_r0_body.s962 to PRE_first_tail_x15_r0_body.s963 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s962).run PRE_first_tail_x15_r0_body.S962 = some (PRE_first_tail_x15_r0_body.s963, PRE_first_tail_x15_r0_body.S963)
boot_rfl PRE_first_tail_x15_r0_body.patchB285 from PRE_first_tail_x15_r0_body.s963 to PRE_first_tail_x15_r0_body.s964 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s963).run PRE_first_tail_x15_r0_body.S963 = some (PRE_first_tail_x15_r0_body.s964, PRE_first_tail_x15_r0_body.S964)
end Host.Load.Run.Tpl
