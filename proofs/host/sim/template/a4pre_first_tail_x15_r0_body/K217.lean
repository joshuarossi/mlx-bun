import host.sim.template.a4pre_first_tail_x15_r0_body.H27
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
boot_rfl PRE_first_tail_x15_r0_body.k868 from PRE_first_tail_x15_r0_body.s868 to PRE_first_tail_x15_r0_body.s869 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB234 ((nth? PRE_first_tail_x15_r0_body.ks 868).getD 0) PRE_first_tail_x15_r0_body.s868 PRE_first_tail_x15_r0_body.S868 = some (PRE_first_tail_x15_r0_body.s869, PRE_first_tail_x15_r0_body.S869)
boot_rfl PRE_first_tail_x15_r0_body.stepA235 from PRE_first_tail_x15_r0_body.s869 to PRE_first_tail_x15_r0_body.s870 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s869).run PRE_first_tail_x15_r0_body.S869 = some (PRE_first_tail_x15_r0_body.s870, PRE_first_tail_x15_r0_body.S870)
boot_rfl PRE_first_tail_x15_r0_body.patchB235 from PRE_first_tail_x15_r0_body.s870 to PRE_first_tail_x15_r0_body.s871 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s870).run PRE_first_tail_x15_r0_body.S870 = some (PRE_first_tail_x15_r0_body.s871, PRE_first_tail_x15_r0_body.S871)
boot_rfl PRE_first_tail_x15_r0_body.k871 from PRE_first_tail_x15_r0_body.s871 to PRE_first_tail_x15_r0_body.s872 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB235 ((nth? PRE_first_tail_x15_r0_body.ks 871).getD 0) PRE_first_tail_x15_r0_body.s871 PRE_first_tail_x15_r0_body.S871 = some (PRE_first_tail_x15_r0_body.s872, PRE_first_tail_x15_r0_body.S872)
end Host.Load.Run.Tpl
