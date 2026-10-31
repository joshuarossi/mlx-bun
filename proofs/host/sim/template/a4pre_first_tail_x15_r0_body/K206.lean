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
boot_rfl PRE_first_tail_x15_r0_body.stepA223 from PRE_first_tail_x15_r0_body.s824 to PRE_first_tail_x15_r0_body.s825 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s824).run PRE_first_tail_x15_r0_body.S824 = some (PRE_first_tail_x15_r0_body.s825, PRE_first_tail_x15_r0_body.S825)
boot_rfl PRE_first_tail_x15_r0_body.patchB223 from PRE_first_tail_x15_r0_body.s825 to PRE_first_tail_x15_r0_body.s826 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s825).run PRE_first_tail_x15_r0_body.S825 = some (PRE_first_tail_x15_r0_body.s826, PRE_first_tail_x15_r0_body.S826)
boot_rfl PRE_first_tail_x15_r0_body.k826 from PRE_first_tail_x15_r0_body.s826 to PRE_first_tail_x15_r0_body.s827 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB223 ((nth? PRE_first_tail_x15_r0_body.ks 826).getD 0) PRE_first_tail_x15_r0_body.s826 PRE_first_tail_x15_r0_body.S826 = some (PRE_first_tail_x15_r0_body.s827, PRE_first_tail_x15_r0_body.S827)
boot_rfl PRE_first_tail_x15_r0_body.k827 from PRE_first_tail_x15_r0_body.s827 to PRE_first_tail_x15_r0_body.s828 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB223 ((nth? PRE_first_tail_x15_r0_body.ks 827).getD 0) PRE_first_tail_x15_r0_body.s827 PRE_first_tail_x15_r0_body.S827 = some (PRE_first_tail_x15_r0_body.s828, PRE_first_tail_x15_r0_body.S828)
end Host.Load.Run.Tpl
