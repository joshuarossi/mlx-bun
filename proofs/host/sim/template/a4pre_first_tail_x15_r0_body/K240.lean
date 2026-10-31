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
boot_rfl PRE_first_tail_x15_r0_body.k960 from PRE_first_tail_x15_r0_body.s960 to PRE_first_tail_x15_r0_body.s961 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB259 ((nth? PRE_first_tail_x15_r0_body.ks 960).getD 0) PRE_first_tail_x15_r0_body.s960 PRE_first_tail_x15_r0_body.S960 = some (PRE_first_tail_x15_r0_body.s961, PRE_first_tail_x15_r0_body.S961)
boot_rfl PRE_first_tail_x15_r0_body.stepA260 from PRE_first_tail_x15_r0_body.s961 to PRE_first_tail_x15_r0_body.s962 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s961).run PRE_first_tail_x15_r0_body.S961 = some (PRE_first_tail_x15_r0_body.s962, PRE_first_tail_x15_r0_body.S962)
boot_rfl PRE_first_tail_x15_r0_body.patchB260 from PRE_first_tail_x15_r0_body.s962 to PRE_first_tail_x15_r0_body.s963 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s962).run PRE_first_tail_x15_r0_body.S962 = some (PRE_first_tail_x15_r0_body.s963, PRE_first_tail_x15_r0_body.S963)
boot_rfl PRE_first_tail_x15_r0_body.k963 from PRE_first_tail_x15_r0_body.s963 to PRE_first_tail_x15_r0_body.s964 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB260 ((nth? PRE_first_tail_x15_r0_body.ks 963).getD 0) PRE_first_tail_x15_r0_body.s963 PRE_first_tail_x15_r0_body.S963 = some (PRE_first_tail_x15_r0_body.s964, PRE_first_tail_x15_r0_body.S964)
end Host.Load.Run.Tpl
